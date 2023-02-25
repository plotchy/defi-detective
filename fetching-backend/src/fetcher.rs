use config::Config;
use config::File;
use crate::configuration::*;
use regex::Regex;
use once_cell::unsync::Lazy;
use std::{io::Write, str::FromStr};
use walkdir::WalkDir;
use tokio::runtime::Runtime;
use tokio::time::{interval, Duration};
use ethers::prelude::*;
use std::collections::HashSet;
use std::sync::Arc;
use ethers::types::Bytes;
use eyre::eyre;


pub fn filter_match_list_for_network_and_uncompleted(addresses_as_matched_line: Vec<String>, network: &str, completed_addresses: HashSet<String>) -> Vec<String> {
    // goerli/00/001358cA0b4fD3aF17a6132439962FC72112cF2f_MaskairdropCom.sol:contract MaskairdropCom is ERC20, ERC20Burnable, Ownable {
    // we need to extract after the second slash and before the first underscore, then prepend 0x
    let mut addresses: Vec<String> = Vec::new();
    for matched_line in addresses_as_matched_line {
        let mut split = matched_line.split("/");
        // only push to addresses if the network matches the first split
        let network_from_file = split.next().unwrap();
        if network_from_file != network {
            continue;
        }
        let _ = split.next();
        let address = split.next().unwrap();
        let address = address.split("_").next().unwrap();
        // make sure that the address is not in the completed addresses
        
        if completed_addresses.contains(&format!("{}_0x{}",network, address)) {
            continue;
        }
        let address = format!("0x{}", address);
        addresses.push(address);
    }

    addresses
}

pub fn fetch_addresses_code_from_rpc(addresses: Vec<String>, fetch_settings: &FetchSettings) {
    let network = fetch_settings.network.clone();
    let rate_interval_ms = fetch_settings.rate_interval_ms;
    let rpc_url = fetch_settings.rpc_url.clone();
    let rel_output_dir = fetch_settings.rel_output_dir.clone();
    
    
    let mut codes: Vec<(String, Bytes)> = Vec::new();

    // start a tokio runtime
    let rt = tokio::runtime::Runtime::new().unwrap();

    // initialize http ethers client
    let provider = Provider::<Http>::try_from(rpc_url).unwrap();
    let arc_provider = Arc::new(provider);


    // inside the runtime, spawn a task that will work on an interval
    rt.block_on(async {
        let mut interval = interval(Duration::from_millis(rate_interval_ms));
        for (i, address) in addresses.iter().enumerate() {
            let before = std::time::Instant::now();
            interval.tick().await;
            let after = before.elapsed();
            println!("tick took {} ms", after.as_millis());
            let code = match fetch_address_code_from_rpc(&address, arc_provider.clone()).await {
                Ok(code) => code,
                Err(e) => {
                    println!("{}", e);
                    continue;
                }
            };
            codes.push((address.clone(), code));
            // periodically print the codes to files and drain from vector
            if codes.len() % 100 == 0 {
                for (address, code) in &codes {
                    let mut file = std::fs::File::create(format!("{}/{}_{}.txt", rel_output_dir, network, address)).unwrap();
                    file.write_all(format!("{}",&code).as_bytes()).unwrap();

                }
                codes.clear();
            }
            if i % 100 == 0 {
                println!("{} addresses fetched", i);
            }
        }
    });
    // write the remaining codes to files
    for (address, code) in codes {
        let mut file = std::fs::File::create(format!("{}/{}_{}.txt", rel_output_dir, network, address)).unwrap();
        file.write_all(format!("{}",&code).as_bytes()).unwrap();
    }
}

pub async fn fetch_address_code_from_rpc(address: &str, arc_provider: Arc<Provider<Http>>) -> eyre::Result<ethers::types::Bytes> {
    // use ethers-rs to fetch the bytecode using the provider
    // convert address to Address type
    let address_H160 = Address::from_str(address).unwrap();
    let code = match arc_provider.get_code(address_H160, None).await {
        Ok(code) => code,
        Err(e) => {
            return Err(eyre!("error fetching code for address {}: {}", address, e));
        }
    };

    Ok(code)
}