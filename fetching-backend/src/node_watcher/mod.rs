pub mod fetcher;


use crate::configuration::FetchSettings;
use config::Config;
use config::File;
use crate::configuration::*;
use std::{io::Write, str::FromStr, sync::atomic::{AtomicUsize, Ordering}};
use walkdir::WalkDir;
use std::collections::HashSet;
use tracing_subscriber;
use tracing::{info, warn, error, debug, trace, instrument, span, Level};
use tokio::join;
use tokio::sync::mpsc::{UnboundedSender};
use crate::*;
use dotenv::dotenv;
use std::collections::HashMap;
use tokio::task::JoinSet;
use ethers::providers::{SubscriptionStream, TransactionStream};
use nanoid::nanoid;
use ethers::providers::{Provider, Http, Ws, Middleware};
use std::time::Duration;

static COUNTER: AtomicUsize = AtomicUsize::new(1);
pub fn get_id() -> usize { COUNTER.fetch_add(1, Ordering::Relaxed) }

pub struct NodeWatcher {
    pub chain: Chain,
    pub rpc_url: String,
    pub node_msg_txr: UnboundedSender<NodeBytecodeMessage>,
    pub subscription_id: usize,
}

impl NodeWatcher {

    pub fn new(chain: Chain, rpc_url: String, node_msg_txr: UnboundedSender<NodeBytecodeMessage>) -> Self {
        let subscription_id = get_id();
        Self {
            chain,
            rpc_url,
            node_msg_txr,
            subscription_id,
        }
    }

    pub async fn run(&self) {
        // this fn subscribes to an RPC's block output

        // use ethers-rs provider to subscribe to block output
        // then, iterate over all transactions in block
        // if transaction is a contract creation, then fetch bytecode

        let mut ws_provider = ethers::providers::Ws::connect(&self.rpc_url).await.unwrap();
        let provider = Provider::new(ws_provider).interval(Duration::from_millis(2000));
        let mut stream = provider.watch_blocks().await.unwrap().take(1);
        while let Some(block) = stream.next().await {
            let block = match provider.get_block(block).await {
                Ok(block_opt) => {
                    match block_opt {
                        Some(block) => block,
                        None => {
                            warn!("no provider error but found empty block?");
                            continue;
                        }
                    }
                },
                Err(e) => {
                    error!("Got providererror on get_block: {e}");
                    continue;
                },
            };
            println!(
                "Ts: {:?}, block number: {} -> {:?}",
                block.timestamp,
                block.number.unwrap(),
                block.hash.unwrap()
            );


            let block_number = block.number.unwrap().as_u64();
            let block_hash = block.hash.unwrap();
            let block_timestamp = block.timestamp.as_u64();
            let block_transactions = block.transactions;

            for transaction_hash in block_transactions {
                let transaction = match provider.get_transaction(transaction_hash).await {
                    Ok(tx_opt) => {
                        match tx_opt {
                            Some(tx) => tx,
                            None => {
                                error!("No tx found for hash? {:?}", transaction_hash);
                                continue;
                            }
                        }
                    },
                    Err(e) => {
                        error!("No tx found for hash? {:?}. ProviderErr: {:?}", transaction_hash, e);
                        continue;
                    }
                };

                let transaction_from = transaction.from;
                let transaction_to = transaction.to;
                let transaction_value = transaction.value;
                let transaction_gas_price = match transaction.gas_price {
                    Some(price) => price,
                    None => {
                        // This is type 2. probably a different fn
                    }
                };
                let transaction_gas_limit = transaction.gas.unwrap().as_u64();
                let transaction_input = transaction.input.unwrap();
                let transaction_nonce = transaction.nonce.unwrap().as_u64();
                let transaction_block_hash = transaction.block_hash.unwrap();
                let transaction_block_number = transaction.block_number.unwrap().as_u64();
                let transaction_transaction_index = transaction.transaction_index.unwrap().as_u64();
                let transaction_contract_address = transaction.contract_address.unwrap();
                let transaction_cumulative_gas_used = transaction.cumulative_gas_used.unwrap().as_u64();
                let transaction_gas_used = transaction.gas_used.unwrap().as_u64();
                let transaction_root = transaction.root.unwrap();
                let transaction_status = transaction.status.unwrap().as_u64();
                let transaction_logs_bloom = transaction.logs_bloom.unwrap();
                let transaction_logs = transaction.logs.unwrap();

                // if transaction is a contract creation, then fetch bytecode
                if transaction_to == None {
                    let bytecode = provider.get_code(transaction_contract_address, None).await.unwrap();
                    let bytecode = bytecode.unwrap();
                    let bytecode = bytecode.as_bytes().to_vec();

                    let node_msg = NodeBytecodeMessage {
                        chain: self.chain,
                        block_number,
                        block_hash,
                        block_timestamp,
                        transaction_hash,
                        transaction_from,
                        transaction_to,
                        transaction_value,
                        transaction_gas_price,
                        transaction_gas_limit,
                        transaction_input,
                        transaction_nonce,
                        transaction_block_hash,
                        transaction_block_number,
                        transaction_transaction_index,
                        transaction_contract_address,
                        transaction_cumulative_gas_used,
                        transaction_gas_used,
                        transaction_root,
                        transaction_status,
                        transaction_logs_bloom,
                        transaction_logs,
                        bytecode,
                    };

                    self.node_msg_txr.send(node_msg).unwrap();
                }
            }
        }


    }


}

pub async fn run_node_watcher(fetch_settings: FetchSettings, node_msg_txr: UnboundedSender<NodeBytecodeMessage>) -> eyre::Result<()> { 
    // first, gather dotenv variables for all RPCs
    dotenv().ok();
    
    let rpcs: Vec<(Chain, String)> = vec![
        (Chain::Mainnet, std::env::var("ETH_MAINNET_RPC_URL").unwrap()),
        (Chain::Goerli, std::env::var("ETH_GOERLI_RPC_URL").unwrap()),
        (Chain::Arbitrum, std::env::var("ARBITRUM_MAINNET_RPC_URL").unwrap()),
        (Chain::ArbitrumGoerli, std::env::var("ARBITRUM_GOERLI_RPC_URL").unwrap()),
        (Chain::Optimism, std::env::var("OPTIMISM_MAINNET_RPC_URL").unwrap()),
        (Chain::OptimismGoerli, std::env::var("OPTIMISM_GOERLI_RPC_URL").unwrap()),
        (Chain::OptimismKovan, std::env::var("OPTIMISM_KOVAN_RPC_URL").unwrap()),
        (Chain::Avalanche, std::env::var("AVALANCHE_MAINNET_RPC_URL").unwrap()),
        (Chain::AvalancheFuji, std::env::var("AVALANCHE_FUJI_RPC_URL").unwrap()),
        (Chain::Polygon, std::env::var("POLYGON_MAINNET_RPC_URL").unwrap()),
        (Chain::PolygonMumbai, std::env::var("POLYGON_MUMBAI_RPC_URL").unwrap()),
        
        // (Chain::BaseGoerli, std::env::var("BASE_GOERLI_RPC_URL").unwrap()), // TODO
    ];

    // iterate over all RPCs
    // clone Arc of txr for each RPC
    // then, spawn a thread for each RPC

    let mut handles_set = JoinSet::new();
    for (chain, rpc_url) in rpcs {
        let node_msg_txr = node_msg_txr.clone();
        let handle = handles_set.spawn(async move {
            let mut node_watcher = NodeWatcher::new(chain, rpc_url, node_msg_txr);
            node_watcher.run().await;
        });
    }

    // wait for all threads to finish
    while let Some(res) = handles_set.join_next().await {
        // Does this block sequentially?
        let out = res?;
    }

    /*
    calldata
    emitted events
    to
    from
    internal to's
    value
    */
    
    todo!()
} 

