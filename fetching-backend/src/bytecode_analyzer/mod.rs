pub mod bytecode_runner;


use config::Config;
use config::File;
use crate::configuration::*;
use std::{io::Write};
use walkdir::WalkDir;
use crate::node_watcher::*;
use std::collections::HashSet;
use tracing_subscriber;
use tracing::{info, warn, error, debug, trace, instrument, span, Level};
use tokio::join;
use crate::*;
use tokio::sync::mpsc::{UnboundedReceiver};


pub async fn run_bytecode_analyzer(bytecode_settings: BytecodeSettings, node_msg_rx: UnboundedReceiver<NodeBytecodeMessage>)-> eyre::Result<()> {

    todo!()
}

pub fn filter_with_selectors() {
    // iterate over all files within output_codes/total and run regex for match on bytecode in file
    
    // if match, write file name to output_codes/have_erc20_fns.txt


    let path = std::path::Path::new("output_codes/total");
    let path = path.canonicalize().unwrap();
    let mut has_erc20_fns: Vec<String> = Vec::new();
    for entry in WalkDir::new(path).into_iter().filter_map(|e| e.ok()) {
        if entry.path().is_file() {
            let file_name = entry.file_name().to_str().unwrap();
            // read file to string
            let file_contents = std::fs::read_to_string(entry.path()).unwrap();
            if RE_ERC20_SELECTORS_STRING_SET.matches(&file_contents).into_iter().count() == 9 {
                has_erc20_fns.push(file_name.to_string());
            }
        }
    }

    // write to file
    let mut file = std::fs::File::create("output_codes/have_erc20_fns.txt").unwrap();
    for file_name in has_erc20_fns {
        file.write_all(file_name.as_bytes()).unwrap();
        // insert newline
        file.write_all("\n".as_bytes()).unwrap();
    }
}