use config::Config;
use config::File;
use defi_explorer::configuration::*;
use std::{io::Write};
use walkdir::WalkDir;
use defi_explorer::node_watcher::*;
use defi_explorer::bytecode_analyzer::*;
use std::collections::HashSet;
use tracing_subscriber;
use tracing::{info, warn, error, debug, trace, instrument, span, Level};
use tokio::join;
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

    if clean {
        // read the matches file and keep only the network/address pairs related in the db/fetched_addresses, db/filtered_bytecodes
        println!("Cleaning up");

        let abs_match_output_path = format!("{}/{}", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_match_output_path);
        let matches_str = std::fs::read_to_string(&abs_match_output_path).unwrap();
        let mut matches = match serde_json::from_str::<MatchesOutput>(&matches_str) {
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
    }



    // set up channel passing of addresses / bytecode

    // Create a new channel with a capacity of at most 32.
    let (node_watcher_tx, bytecode_analyzer_rx) = mpsc::unbounded_channel();

    // run node watchers
    let node_watcher_handle = tokio::spawn(async move {
        run_node_watcher(fetch_settings, node_watcher_tx).await;
    });

    // run bytecode analyzer
    let bytecode_analyzer_handle = tokio::spawn(async move {
        run_bytecode_analyzer(bytecode_settings, bytecode_analyzer_rx).await;
    });


    // run threads until termination / errors
    let join_result = tokio::join!(node_watcher_handle, bytecode_analyzer_handle);

    match join_result {
        (Ok(_), Ok(_)) => {
            println!("All handles exited")
        },
        (Ok(_), Err(e2)) => {
            println!("Error: {}", e2);
        },
        (Err(e1), Ok(_)) => {
            println!("Error: {}", e1);
        },
        (Err(e1), Err(e2)) => {
            println!("Errors: {}, and also {}", e1, e2);
        },
    }

    println!("Program exited")
}

