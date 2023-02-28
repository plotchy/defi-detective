pub mod deployer_analyzer;


use regex::{SetMatches};
use crate::configuration::*;
use std::{io::Write};
use tracing::{info};
use crate::*;
use tokio::sync::mpsc::{UnboundedReceiver};
use std::time::Duration;
use std::time::{Instant};

pub async fn run_bytecode_analyzer(bytecode_settings: BytecodeSettings, mut node_msg_rx: UnboundedReceiver<NodeBytecodeMessage>)-> eyre::Result<()> {

    let abs_new_contract_matches_path = format!("{}/{}", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_new_contract_matches_path);
    let abs_existing_contract_matches_path = format!("{}/{}", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_existing_contract_matches_path);
    let new_matches_str = match std::fs::read_to_string(&abs_new_contract_matches_path) {
        Ok(matches_str) => matches_str,
        Err(_) => String::new(),
    };
    let mut new_matches = match serde_json::from_str::<MatchesOutput>(&new_matches_str) {
        Ok(matches) => matches,
        Err(_) => MatchesOutput::new(),
    };
    let existing_matches_str = match std::fs::read_to_string(&abs_existing_contract_matches_path) {
        Ok(matches_str) => matches_str,
        Err(_) => String::new(),
    };
    let mut existing_matches = match serde_json::from_str::<MatchesOutput>(&existing_matches_str) {
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
        let start_time = Instant::now();
        info!("Processing msg from: {}", &msg.network);
        let msg_address = format!("{:?}", msg.address);
        let msg_network = msg.network.to_string();

        // if address and network already exists in existing_matches, then skip
        if existing_matches.matches.iter().any(|match_| match_.address == msg_address && match_.network == msg_network) {
            continue;
        }
        // if address and network already exists in new_matches, then skip
        if new_matches.matches.iter().any(|match_| match_.address == msg_address && match_.network == msg_network) {
            continue;
        }


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

            if msg.new_creation {
                new_matches.add_new_match(format!("{:?}", msg.address), msg.network.to_string(), events_to_add, selectors_to_add, Some(format!("{:?}", msg.address_from)));
            } else {
                existing_matches.add_new_match(format!("{:?}", msg.address), msg.network.to_string(), events_to_add, selectors_to_add, None);
            }

            // write bytecode to file
            let abs_bytecode_path = format!("{}/{}/{}_{}.txt", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_filtered_bytecodes_path, msg.network, msg.address);
            write_bytecode_to_file(&msg.bytecode, &abs_bytecode_path);
        }


        // periodically write matches to file
        if last_write.elapsed() > write_interval {
            new_matches.write_to_file(&abs_new_contract_matches_path);
            existing_matches.write_to_file(&abs_existing_contract_matches_path);
            last_write = Instant::now();
        }
        info!("Finished processing msg from: {} in {}ms", &msg.network, start_time.elapsed().as_millis());
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
