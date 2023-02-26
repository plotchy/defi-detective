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

