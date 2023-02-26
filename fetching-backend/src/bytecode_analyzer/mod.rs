pub mod bytecode_runner;


use config::Config;
use config::File;
use regex::{Match, SetMatchesIntoIter, SetMatches};
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
use std::time::Duration;
use futures::future::join_all;
use std::sync::RwLock;
use tokio::time;
use std::time::{Instant};

pub async fn run_bytecode_analyzer(bytecode_settings: BytecodeSettings, mut node_msg_rx: UnboundedReceiver<NodeBytecodeMessage>)-> eyre::Result<()> {

    let abs_match_output_path = format!("{}/{}", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_match_output_path);
    let matches_str = std::fs::read_to_string(&abs_match_output_path).unwrap();
    let mut matches = match serde_json::from_str::<MatchesOutput>(&matches_str) {
        Ok(matches) => matches,
        Err(_) => MatchesOutput::new(),
    };
    let write_interval = Duration::from_secs(bytecode_settings.write_to_matches_interval_secs);

    // init selectors and events from file
    // Load event hashes from file
    let selectors = serde_json::from_str::<Selectors>(include_str!("../../inputs/selectors.json")).unwrap();
    let events = serde_json::from_str::<Events>(include_str!("../../inputs/events.json")).unwrap();

    let mut last_write = Instant::now();



    loop {
        let msg = node_msg_rx.recv().await.unwrap();
        info!("Message received from: {}", &msg.network);


        // filter bytecode with regex
        // let matches = retreive_matches_for_markers(&msg.bytecode);
        let (event_matches, selector_matches) = retreive_matches_for_markers(&msg.bytecode);
        // if !matches.is_empty() {
        //     // write bytecode to file
        //     let abs_bytecode_path = format!("{}/{}/{}_{}.txt", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_filtered_bytecodes_path, msg.network, msg.address);
        //     write_bytecode_to_file(&msg.bytecode, &abs_bytecode_path);
        // }

        if event_matches.is_some() || selector_matches.is_some() {
            // add matches to abs_match_output_path
            let events_to_add: Vec<String> = if event_matches.is_some() {
                let event_matches = event_matches.unwrap();
                let event_matches = event_matches.iter();
                let event_matches = event_matches.map(|index| {
                    // match index to events position, and then get event.name
                    events.events[index].name.as_str().to_string()
                }).collect();
                event_matches
            } else {
                vec![]
            };

            let selectors_to_add: Vec<String> = if selector_matches.is_some() {
                let selector_matches = selector_matches.unwrap();
                let selector_matches = selector_matches.iter();
                let selector_matches = selector_matches.map(|index| {
                    // match index to events position, and then get event.name
                    selectors.selectors[index].name.as_str().to_string()
                }).collect();
                selector_matches
            } else {
                vec![]
            };


            matches.add_new_match(format!("{:?}", msg.address), msg.network.to_string(), events_to_add, selectors_to_add);

            // write bytecode to file
            let abs_bytecode_path = format!("{}/{}/{}_{}.txt", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_filtered_bytecodes_path, msg.network, msg.address);
            write_bytecode_to_file(&msg.bytecode, &abs_bytecode_path);
        }


        // periodically write matches to file
        if last_write.elapsed() > write_interval {
            matches.write_to_file(&abs_match_output_path);
            last_write = Instant::now();
        }
    }
}

pub fn retreive_matches_for_markers(bytecode: &Bytes) -> (Option<SetMatches>, Option<SetMatches>) {
    let bytecode_string = format!("{}", bytecode);
    let event_matches = RE_EVENTHASH_STRING_SET.matches(&bytecode_string);
    let selector_matches = RE_SELECTOR_STRING_SET.matches(&bytecode_string);

    let event_matches = if event_matches.matched_any() {
        Some(event_matches)
    } else {
        None
    };

    let selector_matches = if selector_matches.matched_any() {
        Some(selector_matches)
    } else {
        None
    };


    (event_matches, selector_matches)

}

pub fn write_bytecode_to_file(bytecode: &Bytes, abs_file_path: &str) {
    let mut file = std::fs::File::create(abs_file_path).unwrap();
    file.write_all(format!("{}", bytecode).as_bytes()).unwrap();
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