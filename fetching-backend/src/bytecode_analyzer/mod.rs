pub mod deployer_analyzer;


use futures::SinkExt;
use regex::{SetMatches};
use crate::configuration::*;
use std::{io::Write, collections::HashSet};
use tracing::{info};
use crate::*;
use tokio::sync::mpsc::{UnboundedReceiver};
use std::time::Duration;
use std::time::{Instant};
use tokio_tungstenite::{self, tungstenite::Message};
use tokio::net::TcpListener;
use tokio_tungstenite::{accept_async, WebSocketStream};
use tokio::sync::oneshot;

pub async fn run_bytecode_analyzer(bytecode_settings: BytecodeSettings, mut node_msg_rx: UnboundedReceiver<NodeBytecodeMessage>, mut message_handler_rx: UnboundedReceiver<(Address, oneshot::Sender<WSMessage>)>)-> eyre::Result<()> {

    // seed the websocket with ~30 messages from the cache at ./db/cache_of_ws_msgs.json
    let mut ws_msg_cache = match serde_json::from_str::<Vec<WSMessage>>(include_str!("../../db/cache_of_ws_msgs.json")) {
        Ok(cache) => cache,
        Err(_) => Vec::new(),
    };

    let abs_cache_path = format!("{}/{}", std::env::current_dir().unwrap().to_str().unwrap(), "db/cache_of_ws_msgs.json");
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
    let similar_contracts = serde_json::from_str::<Vec<ProtocolEventsFns>>(include_str!("../../inputs/protocol_events_fns.json")).unwrap();


    let mut last_write = Instant::now();

    const PORT: &str = "9002";
    let addr = format!("0.0.0.0:{}", PORT);

    let listener = TcpListener::bind(&addr)
        .await
        .expect("Listening to TCP failed.");


    println!("Listening on: {}", addr);

    // let (stream, _) = listener.accept().await.unwrap();
    // let ws_stream = accept_async(stream).await.expect("Failed to accept");
    // info!("New WebSocket connection");
    // let (mut ws_sender, mut _ws_receiver) = ws_stream.split();
    while let Ok((stream, addr)) = listener.accept().await {
        
        let ws_stream = accept_async(stream).await.expect("Failed to accept");
        info!("New WebSocket connection: {}", addr);
        let (mut ws_sender, mut _ws_receiver) = ws_stream.split();
        // send all messages in cache to new websocket
        for msg in ws_msg_cache.iter() {
            let msg = serde_json::to_string(&msg).unwrap();
            let msg = Message::Text(msg);
            ws_sender.send(msg).await.unwrap();
        }
        'analyzer: loop {
            let msg = node_msg_rx.recv().await.unwrap();
            if !bytecode_settings.enable_existing_contract_matches && !&msg.new_creation {
                // we are not analyzing existing contracts, and this is not a new contract, so skip
                continue;
            }
            let start_time = Instant::now();
            // info!("New contract from: {}", &msg.network);
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
                    new_matches.add_new_match(format!("{:?}", msg.address), msg.network.to_string(), events_to_add.clone(), selectors_to_add.clone(), Some(format!("{:?}", msg.address_from)));

                    let most_similar_contracts = get_most_similar_contracts(&similar_contracts, &events_to_add, &selectors_to_add);

                    // create a WSMessage from a NodeBytecodeMessage
                    let ws_message = WSMessage::from_node_bytecode_message_events_fns(msg.clone(), events_to_add.clone(), selectors_to_add.clone(), most_similar_contracts);
                    ws_msg_cache.push(ws_message.clone());
                    
                    let ws_message = serde_json::to_string(&ws_message).unwrap();
                    write_ws_msg_vec_to_cache(&mut ws_msg_cache, &abs_cache_path);
                    info!("Sending WSMessage to : {}", addr);
                    match ws_sender.send(Message::Text(ws_message)).await {
                        Ok(_) => (),
                        Err(error) => {
                            eprintln!("Error sending message: {}", error);
                            // continue; // commented out as i switched to looping reconnects
                            break 'analyzer;
                        },
                    };

                    
                } else {
                    existing_matches.add_new_match(format!("{:?}", msg.address), msg.network.to_string(), events_to_add, selectors_to_add, None);
                }

                // write bytecode to file
                let abs_bytecode_path = format!("{}/{}/{}_{:?}.txt", std::env::current_dir().unwrap().to_str().unwrap(), &bytecode_settings.rel_filtered_bytecodes_path, msg.network, msg.address);
                write_bytecode_to_file(&msg.bytecode, &abs_bytecode_path);
            }


            // periodically write matches to file
            if last_write.elapsed() > write_interval {
                new_matches.write_to_file(&abs_new_contract_matches_path);
                if bytecode_settings.enable_existing_contract_matches {
                    existing_matches.write_to_file(&abs_existing_contract_matches_path);
                }
                last_write = Instant::now();
            }
            // info!("Finished processing msg from: {} in {}ms", &msg.network, start_time.elapsed().as_millis());
        }
    }
    Ok(())
}

pub fn write_ws_msg_vec_to_cache(ws_msg_vec: &mut Vec<WSMessage>, abs_cache_path: &str) {
    // only keep the last 50 messages in the cache
    if ws_msg_vec.len() > 50 {
        ws_msg_vec.drain(0..ws_msg_vec.len() - 50);
    }

    
    let mut file = std::fs::File::create(abs_cache_path).unwrap();

    let ws_msg = serde_json::to_string(&ws_msg_vec).unwrap();
    file.write_all(ws_msg.as_bytes()).unwrap();
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




pub fn get_most_similar_contracts(similar_contracts: &Vec<ProtocolEventsFns>, events_to_add: &Vec<String>, selectors_to_add: &Vec<String>) -> Vec<String> {
    // TODO change ProtocolEventsFns to HashSet<Strings>
    
    let mut most_similar_contracts: Vec<String> = vec![];




    let mut highest_score = 0;
    // calculate the similarity score for each contract based on set intersection
    for contract in similar_contracts {
        let mut score = 0;
        for event in &contract.events {
            if events_to_add.contains(&event.0) {
                score += 1;
            }
        }
        for selector in &contract.fns {
            if selectors_to_add.contains(&selector.0) {
                score += 1;
            }
        }
        if score > highest_score {
            highest_score = score;
            most_similar_contracts = vec![];
            most_similar_contracts.push(contract.protocol.clone());
        } else if score == highest_score {
            most_similar_contracts.push(contract.protocol.clone());
        }
    }

    // retain only the contracts with the highest score
    most_similar_contracts.retain(|contract| {
        let mut score = 0;
        for event in &similar_contracts.iter().find(|contract_| contract_.protocol == *contract).unwrap().events {
            if events_to_add.contains(&event.0) {
                score += 1;
            }
        }
        for selector in &similar_contracts.iter().find(|contract_| contract_.protocol == *contract).unwrap().fns {
            if selectors_to_add.contains(&selector.0) {
                score += 1;
            }
        }
        score == highest_score
    });



    most_similar_contracts
}



fn most_similar_set<'a>(a: &'a HashSet<String>, all_items: &'a Vec<HashSet<String>>) -> HashSet<String> {
    let mut max_f1_score = 0.0;
    let mut most_similar_set = &HashSet::new();

    for b in all_items {
        let f1 = f1_score(a, b);
        if f1 > max_f1_score {
            max_f1_score = f1;
            most_similar_set = b;
        }
    }

    most_similar_set.clone()
}

fn f1_score(set_a: &HashSet<String>, set_b: &HashSet<String>) -> f64 {
    let true_positives = set_a.intersection(set_b).count() as f64;
    let false_positives = set_b.difference(set_a).count() as f64;
    let false_negatives = set_a.difference(set_b).count() as f64;

    let precision = true_positives / (true_positives + false_positives);
    let recall = true_positives / (true_positives + false_negatives);

    2.0 * (precision * recall) / (precision + recall)
}

pub fn write_bytecode_to_file(bytecode: &Bytes, abs_file_path: &str) {
    let mut file = std::fs::File::create(abs_file_path).unwrap();
    file.write_all(format!("{}", bytecode).as_bytes()).unwrap();
}
