use crate::bytecode_analyzer::get_most_similar_contracts;
use crate::*;
use std::time::Instant;
use std::{str::FromStr, time::Duration};
use tokio::net::TcpListener;
use tokio::sync::mpsc::UnboundedSender;
use tokio::sync::oneshot;
use tokio_tungstenite::{self, tungstenite::Message};
use tokio_tungstenite::{accept_async, WebSocketStream};
use walkdir::WalkDir;
use warp::{reply, Filter};
use warp::http::header::HeaderValue;

const HTTP_PORT: u16 = 9003;

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct BytecodeAndNetwork {
    pub bytecode: String,
    pub network: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct MostSimilarContracts {
    pub most_similar_contracts: Vec<Contract>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Contract {
    pub name: String,
    pub source_code: String,
    pub network: String,
}

pub async fn run_endpoint_handler() -> eyre::Result<()> {

    // Create a CORS policy that allows all origins and all methods
    // let cors = warp::cors()
    //     .allow_any_origin()
    //     .allow_methods(vec!["GET", "POST", "PUT", "DELETE"])
    //     .allow_headers(vec![HeaderValue::from_static("*")])
    //     .build();

    let cors = warp::cors()
        .allow_any_origin();
        // // .allow_methods(vec!["*"])
        // .allow_credentials(true)
        // .expose_headers(vec!["*"])
        // .max_age(Duration::from_secs(86400))
        // .allow_methods(vec!["GET", "POST", "OPTIONS"])
        // // .allow_headers(vec!["*"]);
        // .allow_headers(vec!["User-Agent", "Sec-Fetch-Mode", "Referer", "Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers", "Content-Type",])
        // .build();


    let similar_contracts = serde_json::from_str::<Vec<ProtocolEventsFns>>(include_str!(
        "../../inputs/protocol_events_fns.json"
    ))
    .unwrap();
    let selectors =
        serde_json::from_str::<Selectors>(include_str!("../../inputs/selectors.json")).unwrap();
    let events = serde_json::from_str::<Events>(include_str!("../../inputs/events.json")).unwrap();

    let get_contract_bytecode = warp::path!("get_bytecode_for_address" / Address).map( move |address: Address| {
        // use address to find matching bytecode txt file within db/filtered_bytecodes/*
        let address_str = format!("{:?}", address);
        for entry in WalkDir::new("./db/filtered_bytecodes").into_iter().filter_map(|e| e.ok()).filter(|e| e.file_type().is_file()) {

            // check that the file name contains the address
            let entry_filename = entry.file_name().to_str().unwrap();
            if entry_filename.contains(&address_str) {
                let entry_path = entry.path();
                let entry_filename = entry.file_name().to_str().unwrap();
                // read the file and return the contents
                let bytecode_contents = std::fs::read_to_string(entry_path.clone()).unwrap();
                // convert bytecode_contents to Bytes type
                let bytecode_and_network = BytecodeAndNetwork {
                    bytecode: bytecode_contents,
                    network: entry_filename.split("_").collect::<Vec<&str>>()[0].to_string(),
                };
                return Ok(reply::json(&bytecode_and_network));
            } else {
                continue;
            }
        }
        return Ok(reply::json(&"No matches found"));
    });


    let get_similar_contracts =
        warp::path!("get_similar_contract_for_address" / Address).map(move |address: Address| {
            // use address to find matching bytecode txt file within db/filtered_bytecodes/*
            let address_str = format!("{:?}", address);
            for entry in WalkDir::new("./db/filtered_bytecodes").into_iter().filter_map(|e| e.ok()).filter(|e| e.file_type().is_file()) {

                // check that the file name contains the address
                let entry_filename = entry.file_name().to_str().unwrap();
                if entry_filename.contains(&address_str) {
                    let entry_path = entry.path();
                    let entry_filename = entry.file_name().to_str().unwrap();
                    // read the file and return the contents
                    let bytecode_contents = std::fs::read_to_string(entry_path.clone()).unwrap();
                    // convert bytecode_contents to Bytes type
                    let bytecode_contents = Bytes::from_str(&bytecode_contents).unwrap();
                    // run bytecode through bytecode analyzer
                    let (events_matches, selector_matches) =
                        bytecode_analyzer::retreive_matches_for_markers(&bytecode_contents);

                    if events_matches.is_some() || selector_matches.is_some() {
                        // add matches to abs_match_output_path
                        let events_to_add: Vec<String> = if events_matches.is_some() {
                            let event_matches = events_matches.unwrap();
                            let event_matches = event_matches.iter();
                            let event_matches = event_matches
                                .map(|index| {
                                    // match index to events position, and then get event.name
                                    events.events[index].name.as_str().to_string()
                                })
                                .collect();
                            event_matches
                        } else {
                            vec![]
                        };

                        let selectors_to_add: Vec<String> = if selector_matches.is_some() {
                            let selector_matches = selector_matches.unwrap();
                            let selector_matches = selector_matches.iter();
                            let selector_matches = selector_matches
                                .map(|index| {
                                    // match index to events position, and then get event.name
                                    selectors.selectors[index].name.as_str().to_string()
                                })
                                .collect();
                            selector_matches
                        } else {
                            vec![]
                        };

                        let contracts = bytecode_analyzer::get_most_similar_contracts(
                            &similar_contracts,
                            &events_to_add,
                            &selectors_to_add,
                        );

                        let mut actual_contracts: Vec<Contract> = vec![];
                        // for each contract, get the source code by matching the contract name to the file name in ../scraping/data/source/*
                        for contract in contracts.iter() {
                            let contract_name = contract.clone();
                            for entry in WalkDir::new("../scraping/data/source")
                                .into_iter()
                                .filter_map(|e| e.ok())
                                .filter(|e| e.file_type().is_file())
                            {
                                let entry_filename = entry.file_name().to_str().unwrap();
                                if entry_filename.contains(&contract_name) {
                                    let entry_path = entry.path();
                                    let entry_filename = entry.file_name().to_str().unwrap();
                                    // read the file and return the contents
                                    let source_code_contents =
                                        std::fs::read_to_string(entry_path.clone()).unwrap();
                                    let contract_msg = Contract {
                                        name: contract_name,
                                        source_code: source_code_contents,
                                        network: "mainnet".to_string(),
                                    };
                                    actual_contracts.push(contract_msg);
                                    break;
                                } else {
                                    continue;
                                }
                            }
                        }

                        

                        let most_similar_contracts = MostSimilarContracts {
                            most_similar_contracts: actual_contracts,
                        };
                        // let contents = serde_json::to_string(&most_similar_contracts).unwrap();
                        return Ok(reply::json(&most_similar_contracts));
                    }

                } else {
                    continue;
                }

                
            }
            Ok(reply::json(&"No matches found"))
        });

    // let contracts = serde_json::from_str::<Vec<ProtocolEventsFns>>(include_str!(
    //     "../../inputs/protocol_events_fns.json"
    // ))
    // .unwrap();

    // let hello = warp::path!("get_similar_contract_for_address" / Address).map(move |address| {
    //     let bytecode = include_str!("../../inputs/{}", address);
    //     let (events_to_add, selectors_to_add) =
    //         bytecode_analyzer::get_events_and_selectors(bytecode);
    //     let contracts = get_most_similar_contracts(&contracts, events_to_add, selectors_to_add);
    // });

    let routes = get_similar_contracts
        .with(cors.clone())
        .or(get_contract_bytecode)
        .with(cors);
    

    warp::serve(routes)
        .run(([0, 0, 0, 0], HTTP_PORT))
        .await;
    Ok(())
}
