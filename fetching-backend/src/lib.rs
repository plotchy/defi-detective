pub mod endpoint_handler;
pub mod bytecode_analyzer;
pub mod configuration;
pub mod node_watcher;

use ethers::prelude::*;
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use tracing::{warn};
use tracing_subscriber::fmt::format;

#[derive(Debug, Clone, Deserialize)]
pub struct NodeBytecodeMessage {
    pub network: Chain,
    pub address: Address,
    pub bytecode: Bytes,
    pub block_number: Option<u64>,
    pub new_creation: bool,
    pub address_from: Address,
    pub block_timestamp: u64,
    pub gas_used_for_deploy: u64,
    pub logs_emitted_on_deploy: Vec<Log>,
}


#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct WSMessage {
    pub network: String,
    pub address: Address,
    pub block_number: Option<u64>,
    pub new_creation: bool,
    pub address_from: Address,
    pub events: Vec<String>,
    pub functions: Vec<String>,
    pub most_similar_contracts: Vec<String>,
    pub timestamp: u64,
    pub gas_used_for_deploy: u64,
    pub logs_emitted_on_deploy: String,
}

impl WSMessage {


    pub fn from_node_bytecode_message_events_fns(msg: NodeBytecodeMessage, events: Vec<String>, fns: Vec<String>, most_similar_contracts: Vec<String>) -> Self {
        
        let logs = format!("{:?}", msg.logs_emitted_on_deploy);
        Self {
            network: msg.network.to_string(),
            address: msg.address,
            block_number: msg.block_number,
            new_creation: msg.new_creation,
            address_from: msg.address_from,
            events,
            functions: fns,
            most_similar_contracts,
            timestamp: msg.block_timestamp,
            gas_used_for_deploy: msg.gas_used_for_deploy,
            logs_emitted_on_deploy: logs,
        }
    }

}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProtocolEventsFns {
    pub protocol: String,
    pub events: Vec<(String, String)>,
    pub fns: Vec<(String, String)>,
}


#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Events {
    pub events: Vec<Event>,
}

impl Events {
    pub fn new() -> Self {
        Self {
            events: Vec::new(),
        }
    }

    pub fn add_event(&mut self, name: String, hash: String) {
        self.events.push(Event {
            name,
            hash,
        });
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Event {
    pub name: String,
    pub hash: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct Selectors {
    pub selectors: Vec<Selector>,
}

impl Selectors {
    pub fn new() -> Self {
        Self {
            selectors: Vec::new(),
        }
    }

    pub fn add_selector(&mut self, name: String, hash: String) {
        self.selectors.push(Selector {
            name,
            hash,
        });
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct Selector {
    pub name: String,
    pub hash: String,
}

#[derive(Serialize, Deserialize)]
pub struct MatchesOutput {
    pub matches: Vec<Match>,
}

#[derive(Serialize, Deserialize)]
pub struct Match {
    pub address: String,
    pub network: String,
    pub events: Vec<String>,
    pub selectors: Vec<String>,
    pub deployer: Option<String>,
}

impl Match {
    pub fn new(
        address: String,
        network: String,
        events: Vec<String>,
        selectors: Vec<String>,
        deployer: Option<String>,
    ) -> Self {
        Self {
            address,
            network,
            events,
            selectors,
            deployer,
        }
    }
}

impl MatchesOutput {
    pub fn new() -> Self {
        Self {
            matches: Vec::new(),
        }
    }

    pub fn add_new_match(
        &mut self,
        address: String,
        network: String,
        events: Vec<String>,
        selectors: Vec<String>,
        deployer: Option<String>,
    ) {
        // first search through existing matches to see if this address already exists

        for match_ in self.matches.iter_mut() {
            if match_.address == address {
                // address already exists, so add new events and selectors to existing match
                for event in events {
                    if !match_.events.contains(&event) {
                        match_.events.push(event);
                    }
                }
                for selector in selectors {
                    if !match_.selectors.contains(&selector) {
                        match_.selectors.push(selector);
                    }
                }
                // return early
                return;
            }
        }

        // otherwise address does not exist, so add new match
        self.matches.push(Match {
            address,
            network,
            events,
            selectors,
            deployer,
        });
    }

    pub fn write_to_file(&self, path: &str) {
        warn!("Writing matches to file: {}", path);
        let json = serde_json::to_string_pretty(&self).unwrap();
        std::fs::write(path, json).unwrap();
    }
}



static RE_EVENTHASH_STRING_SET: Lazy<regex::RegexSet> = Lazy::new( || {
    // Load event hashes from file
    let events = serde_json::from_str::<Events>(include_str!("../inputs/events.json")).unwrap();
    let events_strings = events
        .events
        .iter()
        .map(|event| {
            if event.hash.starts_with("0x") {
                event.hash[2..].to_string()
            } else {
                event.hash.to_string()
            }
        })
        .collect::<Vec<String>>();

    let mut builder = regex::RegexSetBuilder::new(events_strings);

    builder.unicode(false).build().unwrap()
});

static RE_SELECTOR_STRING_SET: Lazy<regex::RegexSet> = Lazy::new(|| {
    // Load event hashes from file
    let selectors =
        serde_json::from_str::<Selectors>(include_str!("../inputs/selectors.json")).unwrap();
    let selectors_strings = selectors
        .selectors
        .iter()
        .map(|selector| {
            if selector.hash.starts_with("0x") {
                format!("8063{}", selector.hash[2..].to_string())
            } else {
                format!("8063{}", selector.hash[2..].to_string())
            }
        })
        .collect::<Vec<String>>();

    let mut builder = regex::RegexSetBuilder::new(selectors_strings);

    builder.unicode(false).build().unwrap()
});
