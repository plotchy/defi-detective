pub mod bytecode_analyzer;
pub mod configuration;
pub mod node_watcher;

use ethers::prelude::*;
use once_cell::sync::Lazy;
use regex::bytes;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize)]
pub struct NodeBytecodeMessage {
    pub network: Chain,
    pub address: Address,
    pub bytecode: Bytes,
    pub block_number: Option<u64>,
    pub new_creation: bool,
}

const RE_ERC20_SELECTORS_BYTES_SET: Lazy<bytes::RegexSet> = Lazy::new(|| {
    bytes::RegexSetBuilder::new(&[
        r"\x63\x06\xfd\xde\x03", // push4 name()
        r"\x63\x95\xd8\x9b\x41", // push4 symbol()
        r"\x63\x31\x3c\xe5\x67", // push4 decimals()
        r"\x63\x18\x16\x0d\xdd", // push4 totalSupply()
        r"\x63\x70\xa0\x82\x31", // push4 balanceOf(address)
        r"\x63\xdd\x62\xed\x3e", // push4 allowance(address,address)
        r"\x63\x09\x5e\xa7\xb3", // push4 approve(address,uint256)
        r"\x63\xa9\x05\x9c\xbb", // push4 transfer(address,uint256)
        r"\x63\x23\xb8\x72\xdd", // push4 transferFrom(address,address,uint256)
    ])
    .unicode(false)
    .build()
    .unwrap()
});

const RE_ERC20_SELECTORS_STRING_SET: Lazy<regex::RegexSet> = Lazy::new(|| {
    regex::RegexSetBuilder::new(&[
        r"6306fdde03", // push4 name()
        r"6395d89b41", // push4 symbol()
        r"63313ce567", // push4 decimals()
        r"6318160ddd", // push4 totalSupply()
        r"6370a08231", // push4 balanceOf(address)
        r"63dd62ed3e", // push4 allowance(address,address)
        r"63095ea7b3", // push4 approve(address,uint256)
        r"63a9059cbb", // push4 transfer(address,uint256)
        r"6323b872dd", // push4 transferFrom(address,address,uint256)
    ])
    .unicode(false)
    .build()
    .unwrap()
});

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
}

impl Match {
    pub fn new(
        address: String,
        network: String,
        events: Vec<String>,
        selectors: Vec<String>,
    ) -> Self {
        Self {
            address,
            network,
            events,
            selectors,
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
        });
    }

    pub fn write_to_file(&self, path: &str) {
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
