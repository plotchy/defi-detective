use crate::configuration::FetchSettings;
use std::{io::Write, str::FromStr, sync::atomic::{AtomicUsize, Ordering}};
use std::collections::HashSet;
use tracing::{info, warn, error, trace};
use tokio::sync::mpsc::{UnboundedSender};
use crate::*;
use dotenv::dotenv;
use ethers::providers::{Provider, Middleware};
use std::time::Duration;
use futures::future::join_all;
use tokio::time;

static COUNTER: AtomicUsize = AtomicUsize::new(1);
pub fn get_id() -> usize { COUNTER.fetch_add(1, Ordering::Relaxed) }

pub struct NodeWatcher {
    pub chain: Chain,
    pub rpc_url: String,
    pub node_msg_txr: UnboundedSender<NodeBytecodeMessage>,
    pub subscription_id: usize,
    pub fetched_addresses_set: HashSet<Address>,
    pub write_interval: std::time::Duration,
    pub last_write_time: time::Instant,
    pub abs_db_path: String,
}

impl NodeWatcher {

    pub fn new(chain: Chain, rpc_url: String, node_msg_txr: UnboundedSender<NodeBytecodeMessage>, rel_db_path: &str, write_interval: u64) -> Self {
        let subscription_id = get_id();

        let abs_db_path = format!("{}/{}/{}.txt", std::env::current_dir().unwrap().to_str().unwrap(), rel_db_path, chain);
        let fetched_addresses_set = NodeWatcher::init_fetched_addresses_set_from_file(&abs_db_path, &chain);
        let write_interval = Duration::from_secs(write_interval);
        Self {
            chain,
            rpc_url,
            node_msg_txr,
            subscription_id,
            fetched_addresses_set,
            write_interval,
            last_write_time: time::Instant::now(),
            abs_db_path: abs_db_path,
        }
    }

    pub fn init_fetched_addresses_set_from_file(abs_file_path: &str, _chain: &Chain) -> HashSet<Address> {
        let mut fetched_addresses_set = HashSet::new();

        if !std::path::Path::new(abs_file_path).exists() {
            return fetched_addresses_set;
        }

        let file_contents = std::fs::read_to_string(abs_file_path).unwrap();
        for line in file_contents.lines() {

            let address = match Address::from_str(&line) {
                Ok(address) => address,
                Err(e) => {
                    error!("Error parsing address from file: {e}");
                    error!("Line: {line}");
                    continue;
                }
            };
            fetched_addresses_set.insert(address);
        }
        fetched_addresses_set
    }

    pub fn write_fetched_addresses_set_to_file(fetched_addresses_set: &HashSet<Address>, abs_file_path: &str) {
        let mut file = std::fs::File::create(abs_file_path).unwrap();
        for address in fetched_addresses_set.iter() {
            file.write_all(format!("{:?}\n", address).as_bytes()).unwrap();
        }
    }

    pub async fn run(&mut self) {
        // this fn subscribes to an RPC's block output

        // check if self.rpc_url is a wss or a http link
        
        // use ethers-rs provider to subscribe to block output
        // then, iterate over all transactions in block
        // if transaction is a contract creation, then fetch bytecode

        
        // let ws_provider = ethers::providers::Ws::connect(&self.rpc_url).await.unwrap();
        // let provider = Provider::new(ws_provider).interval(Duration::from_millis(2000));
        let http_provider = ethers::providers::Http::from_str(&self.rpc_url).unwrap();
        let provider = Provider::new(http_provider).interval(Duration::from_millis(2000));
        let mut stream = provider.watch_blocks().await.unwrap();
        let mut send_count = 0;
        while let Some(block) = stream.next().await {
            let block = match provider.get_block_with_txs(block).await {
                Ok(resp) => {
                    if resp.is_none() {
                        warn!("no provider error but found empty block?");
                        continue;
                    } else {
                        resp.unwrap()
                    }
                },
                Err(e) => {
                    error!("Got providererror on get_block_with_txs: {e}");
                    continue;
                },
            };

            // let block = match provider.get_block(block).await {
            //     Ok(block_opt) => {
            //         match block_opt {
            //             Some(block) => block,
            //             None => {
            //                 warn!("no provider error but found empty block?");
            //                 continue;
            //             }
            //         }
            //     },
            //     Err(e) => {
            //         error!("Got providererror on get_block: {e}");
            //         continue;
            //     },
            // };
            trace!(
                "New block, Net: {:?}, Time: {:?}, block number: {} -> bhash {:?}",
                &self.chain,
                block.timestamp,
                block.number.unwrap(),
                block.hash.unwrap()
            );

            let block_number = block.number.unwrap().as_u64();
            // let block_hash = block.hash.unwrap();
            let block_timestamp = block.timestamp.as_u64();
            let block_transactions = block.transactions;

            

            for transaction in block_transactions {
                // let transaction = match provider.get_transaction(transaction_hash).await {
                //     Ok(tx_opt) => {
                //         match tx_opt {
                //             Some(tx) => tx,
                //             None => {
                //                 error!("No tx found for hash? {:?}", transaction_hash);
                //                 continue;
                //             }
                //         }
                //     },
                //     Err(e) => {
                //         error!("No tx found for hash? {:?}. ProviderErr: {:?}", transaction_hash, e);
                //         continue;
                //     }
                // };

                let transaction_from = transaction.from;
                let transaction_to = transaction.to;
                // if we've already fetched this to address, then skip it
                if transaction_to.is_some() && self.fetched_addresses_set.contains(&transaction_to.unwrap()) {
                    continue;
                }
                let _transaction_value = transaction.value;
                let _transaction_gas_price = match transaction.gas_price {
                    Some(price) => price,
                    None => {
                        // This is type 2. just add the two fees
                        transaction.max_fee_per_gas.unwrap() + transaction.max_priority_fee_per_gas.unwrap()
                    }
                };

                let _transaction_gas_limit = transaction.gas;
                let _transaction_input = transaction.input.clone();
                let transaction_nonce = transaction.nonce.as_u64();
                // let transaction_block_hash = transaction.block_hash.unwrap();
                // let transaction_transaction_index = transaction.transaction_index.unwrap().as_u64();

                // These would be useful, but are under TransactionReceipt
                let transaction_receipt = match provider.get_transaction_receipt(transaction.hash).await {
                    Ok(Some(tx_r)) => tx_r,
                    Ok(None) => {
                        warn!("No receipt for tx included in finished block???: block {:?}, tx {:?}", block_number, &transaction);
                        continue;
                    }
                    Err(e) => {
                        error!("ProviderErr on transaction_receipt: {:?}", e);
                        continue;
                    }
                };
                let transaction_gas_used = transaction_receipt.gas_used.unwrap().as_u64();
                let _transaction_logs_bloom = transaction_receipt.logs_bloom;
                let transaction_logs = transaction_receipt.logs;

                // if transaction is a contract creation, then fetch bytecode
                if transaction_to == None && transaction_receipt.contract_address.is_some() {
                    let transaction_created_address = transaction_receipt.contract_address.unwrap();

                    

                    let bytecode = provider.get_code(transaction_created_address, None).await.unwrap();



                    let node_msg = NodeBytecodeMessage {
                        network: self.chain,
                        address: transaction_created_address,
                        bytecode,
                        block_number: Some(block_number),
                        new_creation: true,
                        address_from: transaction_from,
                        block_timestamp,
                        gas_used_for_deploy: transaction_gas_used,
                        logs_emitted_on_deploy: transaction_logs,

                    };

                    info!("Sending new deployed contract to bytecode analyzer on network {:?}", &self.chain);
                    self.node_msg_txr.send(node_msg).unwrap();
                    send_count += 1;
                    self.fetched_addresses_set.insert(transaction_created_address);
                    let elasped_since_last_write = std::time::Instant::now().duration_since(self.last_write_time.into());
                    if elasped_since_last_write > self.write_interval {
                        NodeWatcher::write_fetched_addresses_set_to_file(&self.fetched_addresses_set, &self.abs_db_path);
                        self.last_write_time = std::time::Instant::now().into();
                    } 
                } else {
                    // otherwise, look into the transaction trace, and record each of the touched addresses
                    // let mut touched_addresses = HashSet::from([transaction_from, transaction_to.unwrap()]); // from can never be a contract
                    let to_address = match transaction_to {
                        Some(address) => address,
                        None => {
                            error!("No to address for tx: {:?}", transaction);
                            continue;
                        }
                    };
                    let touched_addresses = HashSet::from([to_address]); // from can never be a contract


                    // let traces_for_tx = match provider.trace_transaction(transaction.hash).await {
                    //     Ok(trace) => trace,
                    //     Err(e) => {
                    //         error!("ProviderErr on trace_transaction: {:?}", e);
                    //         continue;
                    //     }
                    // };

                    // // check if any traces_for_tx are Action::Call
                    // // if so, add the to address to the touched_addresses vec
                    // for trace in traces_for_tx {
                    //     match trace.action {
                    //         Action::Call(call) => {
                    //             touched_addresses.insert(call.to);
                    //         },
                    //         _ => {}
                    //     }
                    // }


                    // now, for each touched address, fetch the bytecode
                    for address in touched_addresses.iter() {
                        let bytecode = match provider.get_code(*address, None).await {
                            Ok(bytecode) => {
                                self.fetched_addresses_set.insert(*address);
                                bytecode
                            },
                            Err(e) => {
                                if e.to_string().contains("no code at given address") {
                                    self.fetched_addresses_set.insert(*address);
                                }
                                error!("ProviderErr on get_code: {:?}", e);
                                continue;
                            }
                        };
                        let elasped_since_last_write = std::time::Instant::now().duration_since(self.last_write_time.into());
                        if elasped_since_last_write > self.write_interval {
                            NodeWatcher::write_fetched_addresses_set_to_file(&self.fetched_addresses_set, &self.abs_db_path);
                            self.last_write_time = std::time::Instant::now().into();
                        } 

                        let node_msg = NodeBytecodeMessage {
                            network: self.chain,
                            address: *address,
                            bytecode,
                            block_number: Some(block_number),
                            new_creation: false,
                            address_from: transaction_from,
                            block_timestamp,
                            gas_used_for_deploy: transaction_gas_used,
                            logs_emitted_on_deploy: transaction_logs.clone(),
                        };

                        // info!("Sending new touched contract to bytecode analyzer on network {:?}", &self.chain);
                        self.node_msg_txr.send(node_msg).unwrap();
                        send_count += 1;
                        
                    }
                }
                if send_count % 100 == 0 {
                    // info!("Sent {} new contracts to bytecode analyzer on network {:?}", send_count, &self.chain);
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
        // (Chain::OptimismGoerli, std::env::var("OPTIMISM_GOERLI_RPC_URL").unwrap()),
        // (Chain::OptimismKovan, std::env::var("OPTIMISM_KOVAN_RPC_URL").unwrap()),
        // (Chain::Avalanche, std::env::var("AVALANCHE_MAINNET_RPC_URL").unwrap()),
        // (Chain::AvalancheFuji, std::env::var("INFURA_AVALANCHE_FUJI_RPC_URL").unwrap()),
        (Chain::Polygon, std::env::var("POLYGON_MAINNET_RPC_URL").unwrap()),
        (Chain::PolygonMumbai, std::env::var("POLYGON_MUMBAI_RPC_URL").unwrap()),
        // (Chain::Avalanche, std::env::var("FLARE_RPC_URL").unwrap()),
        // (Chain::BinanceSmartChain, std::env::var("POKT_BSC_RPC_URL").unwrap()),
        // (Chain::Aurora, std::env::var("AURORA_RPC_URL").unwrap()),

        
        // (Chain::BaseGoerli, std::env::var("INFURA_BASE_GOERLI_RPC_URL").unwrap()), // TODO
    ];

    // iterate over all RPCs
    // clone Arc of txr for each RPC
    // then, spawn a thread for each RPC


    // HANDLES SET 
    // let mut handles_set = JoinSet::new();
    // for (chain, rpc_url) in rpcs {
    //     let node_msg_txr = node_msg_txr.clone();
    //     let handle = handles_set.spawn(async move {
    //         let mut node_watcher = NodeWatcher::new(chain, rpc_url, node_msg_txr);
    //         node_watcher.run().await;
    //     });
    // }

    // // wait for all threads to finish
    // while let Some(res) = handles_set.join_next().await {
    //     // Does this block sequentially?
    //     let out = res?;
    // }


    // SINGLE HANDLE
    // let node_msg_txr = node_msg_txr.clone();
    // let handle = tokio::spawn(async move {
    //     let mut node_watcher = NodeWatcher::new(rpcs[0].0, rpcs[0].1.clone(), node_msg_txr);
    //     node_watcher.run().await;
    // });

    // tokio::join!(handle);


    // FUTURES JOIN ALL VEC
    let mut handles = Vec::new();
    for (chain, rpc_url) in rpcs {
        let node_msg_txr = node_msg_txr.clone();
        let rel_db_dir = fetch_settings.rel_db_dir.clone();
        let write_interval = fetch_settings.write_to_db_interval_secs.clone();
        let handle = tokio::spawn(async move {
            let mut node_watcher = NodeWatcher::new(chain, rpc_url, node_msg_txr, &rel_db_dir, write_interval);
            node_watcher.run().await;
        });
        handles.push(handle);
    }

    join_all(handles).await;
    /*
    calldata
    emitted events
    to
    from
    internal to's
    value
    */
    
    todo!() // this shouldnt be hit as its infinite loop
} 

