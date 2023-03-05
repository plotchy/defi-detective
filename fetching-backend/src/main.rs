use config::Config;
use config::File;
use defi_explorer::{configuration::*, endpoint_handler::run_endpoint_handler};
use ethers::{utils::keccak256};
use serde_json::Value;
use std::{io::Write};
use walkdir::WalkDir;
use defi_explorer::node_watcher::*;
use defi_explorer::bytecode_analyzer::*;
use std::collections::HashSet;
use tracing_subscriber;
use tracing::{info};
use tokio::sync::mpsc;
use defi_explorer::*;


#[tokio::main]
async fn main () {
    
    // initialize tracing
    tracing_subscriber::fmt::init();

    info!("Init'ing configuration");

    let builder = Config::builder()
        .add_source(File::with_name("configuration.yaml"));
    let config = builder.build().unwrap();
    let fetch_settings: FetchSettings = config.get("fetch_settings").unwrap();
    let bytecode_settings: BytecodeSettings = config.get("bytecode_settings").unwrap();

    info!("fetch_settings: {:?}", &fetch_settings);
    info!("bytecode_settings: {:?}", &bytecode_settings);

    // check if a "clean" argument was passed
    let args: Vec<String> = std::env::args().collect();
    let clean = args.len() > 1 && args[1] == "clean";
    let add_events_selectors = args.len() > 1 && args[1] == "add";
    let try_ctc = args.len() > 1 && args[1] == "ctc";

    if clean {
        // read the matches file and keep only the network/address pairs related in the db/fetched_addresses, db/filtered_bytecodes
        println!("Cleaning up");

        // TODO need to make this work. seems to delete all rows? rather than the specific ones?
        let abs_match_output_path = format!("{}/{}", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_existing_contract_matches_path);
        let matches_str = std::fs::read_to_string(&abs_match_output_path).unwrap();
        let matches = match serde_json::from_str::<MatchesOutput>(&matches_str) {
            Ok(matches) => matches,
            Err(_) => MatchesOutput::new(),
        };

        let network_addresses_vec = matches.matches.iter().map(|match_| {
            (match_.network.clone(), match_.address.clone())
        }).collect::<Vec<(String, String)>>();

        // iterate over all files in the db/fetched_addresses directory and remove any lines that are addresses not in the matches file
        let abs_fetched_addresses_path = format!("{}/{}", std::env::current_dir().unwrap().to_str().unwrap(), &fetch_settings.rel_db_dir);
        for entry in WalkDir::new(abs_fetched_addresses_path).into_iter().filter_map(|e| e.ok()).filter(|e| e.file_type().is_file()) {
            let network = entry.path().file_name().unwrap().to_str().unwrap().to_string();
            let mut file_string = std::fs::read_to_string(entry.path()).unwrap();
            let temp_file_string = file_string.clone();

            for line in temp_file_string.lines() {
                let address = line.to_string();
                if !network_addresses_vec.contains(&(network.clone(), address.clone())) {
                    println!("Removing {} from {}", address, entry.path().to_str().unwrap());
                    let temp_file_string_ = file_string.clone();
                    file_string = temp_file_string_.replace(&format!("{}\n", address), "");
                }
            }

            // write the file back
            let mut file = std::fs::File::create(entry.path()).unwrap();
            file.write_all(file_string.as_bytes()).unwrap();
        }
        println!("Done cleaning up");
        return;
    } else if add_events_selectors {
        let abs_json_dir = format!("{}/../scraping/data/contracts", std::env::current_dir().unwrap().to_str().unwrap());
        jsons_to_abi(&abs_json_dir);
        println!("Done adding events and selectors");
        return;
    } else if try_ctc {
        
        return;
    }



    // set up channel passing of addresses / bytecode

    // Create a new channel unbounded capacity
    let (node_watcher_tx, bytecode_analyzer_rx) = mpsc::unbounded_channel();
    let (endpoint_msg_tx, message_handler_rx) = mpsc::unbounded_channel();

    // run node watchers
    let node_watcher_handle = tokio::spawn(async move {
        run_node_watcher(fetch_settings, node_watcher_tx).await.expect("Node watcher failed");
    });

    // run bytecode analyzer
    let bytecode_analyzer_handle = tokio::spawn(async move {
        run_bytecode_analyzer(bytecode_settings, bytecode_analyzer_rx, message_handler_rx).await.expect("Bytecode analyzer failed");
    });

    let endpoint_msg_handle = tokio::spawn(async move {
        run_endpoint_handler().await.expect("Endpoint msg handler failed");
    });


    // run threads until termination / errors
    let join_result = tokio::join!(node_watcher_handle, bytecode_analyzer_handle, endpoint_msg_handle);

    match join_result {
        (Ok(_), Ok(_), Ok(_)) => {
            println!("All handles exited")
        },
        _ => {
            println!("Errors in any of the handles");
        },
        // (Err(e1), Ok(_)) => {
        //     println!("Error: {}", e1);
        // },
        // (Err(e1), Err(e2)) => {
        //     println!("Errors: {}, and also {}", e1, e2);
        // },
    }

    println!("Program exited")
}



// this is a dirty fn just to do conversions from json scraped files to events and selectors
pub fn jsons_to_abi(abs_json_dir: &str) {

    // walk over abs_json_dir and read ABI field from each json file
    let mut events_set: HashSet<(String, String)> = HashSet::new();
    let mut selectors_set: HashSet<(String, String)> = HashSet::new();

    let mut protocols: Vec<ProtocolEventsFns> = Vec::new();

    for entry in WalkDir::new(abs_json_dir).into_iter().filter_map(|e| e.ok()).filter(|e| e.file_type().is_file()) {
        
        
        let json_contents = std::fs::read_to_string(entry.path()).unwrap();
        // read a file into a string
        let v: Value = serde_json::from_str(&json_contents).unwrap();
        let abi = match v[0]["ABI"].as_str() {
            Some(abi) => {
                let abi = match serde_json::from_str(&abi) {
                    Ok(abi) => abi,
                    Err(_) => {
                        println!("Error parsing json: {}", entry.path().to_str().unwrap());
                        continue
                    },
                };
                abi
            },
            None => {
                v
            },
        };
        
        if abi.to_string().contains("Max rate limit reached") {
            println!("Max rate limit reached for {}", entry.path().to_str().unwrap());
            continue;
        }
        let (mut events_vec, mut fns_vec): (Vec<(String, String)>, Vec<(String, String)>) = parse_only_abi_dhvani(abi.clone(), &mut events_set, &mut selectors_set);


        // lastly, push a new protocol to the protocols vec
        let protocol = ProtocolEventsFns {
            // only use the filename as the protocol name, without the .json extension
            protocol: entry.file_name().to_str().unwrap().split('.').collect::<Vec<&str>>()[0].to_string(),
            events: events_vec,
            fns: fns_vec,
        };
        protocols.push(protocol);
    }

    // fill out Events struct
    let mut events = Events::new();
    for (name, hash) in events_set {
        events.add_event(name, hash);
    }

    // fill out Selectors struct
    let mut selectors = Selectors::new();
    for (human_sig, selector) in selectors_set {
        selectors.add_selector(human_sig, selector);
    }

    // write to file
    let mut file = std::fs::File::create("inputs/events.json").unwrap();
    file.write_all(serde_json::to_string_pretty(&events).unwrap().as_bytes()).unwrap();
    let mut file = std::fs::File::create("inputs/selectors.json").unwrap();
    file.write_all(serde_json::to_string_pretty(&selectors).unwrap().as_bytes()).unwrap();
    let mut file = std::fs::File::create("inputs/protocol_events_fns.json").unwrap();
    file.write_all(serde_json::to_string_pretty(&protocols).unwrap().as_bytes()).unwrap();

}


pub fn parse_only_abi_dhvani(abi: Value, events_set: &mut HashSet<(String, String)>, selectors_set: &mut HashSet<(String, String)>) -> (Vec<(String, String)>, Vec<(String, String)>) {
    let mut events_vec: Vec<(String, String)> = Vec::new();
    let mut fns_vec: Vec<(String, String)> = Vec::new();


    for item in abi.as_array().unwrap() {
        if item["type"].as_str().unwrap() == "event" {
            let name = item["name"].as_str().unwrap().to_string();
            let inputs = item["inputs"].as_array().unwrap();
            let mut signature = name.clone();
            signature = format!("{}(", signature);
            let inputs_length = inputs.len();
            for (i, input) in inputs.iter().enumerate() {
                if i != inputs_length - 1 {
                    signature = format!("{}{},", signature, input["type"].as_str().unwrap());
                } else {
                    signature = format!("{}{}", signature, input["type"].as_str().unwrap());
                }
            }
            signature = format!("{})", signature);
            // println!("{}", signature);
            let keccak_signature = format!("0x{}", hex::encode(keccak256(signature.as_bytes())));
            events_set.insert((signature.clone(), keccak_signature.clone()));
            events_vec.push((signature, keccak_signature));
        } else if item["type"].as_str().unwrap() == "function" {
            let name = item["name"].as_str().unwrap().to_string();
            let inputs = item["inputs"].as_array().unwrap();
            let mut signature = name.clone();
            signature = format!("{}(", signature);
            let inputs_length = inputs.len();
            for (i, input) in inputs.iter().enumerate() {
                if i != inputs_length - 1 {
                    signature = format!("{}{},", signature, input["type"].as_str().unwrap());
                } else {
                    signature = format!("{}{}", signature, input["type"].as_str().unwrap());
                }
            }
            signature = format!("{})", signature);
            // println!("{}", signature);
            let keccak_signature = format!("0x{}", hex::encode(keccak256(signature.as_bytes()))[0..8].to_string());
            selectors_set.insert((signature.clone(), keccak_signature.clone()));
            fns_vec.push((signature, keccak_signature));
        }
    }
    (events_vec, fns_vec)
}