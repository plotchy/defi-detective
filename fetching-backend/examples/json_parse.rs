use serde_json::Value;
use std::fs;

fn main() {
    // read a file into a string
    let data = fs::read_to_string("../scraping/data/contracts/0.exchange.json").unwrap();
    let v: Value = serde_json::from_str(&data).unwrap();
    let abi = v[0]["ABI"].as_str().unwrap();
    let abi: Value = serde_json::from_str(&abi).unwrap();
    println!("{}", serde_json::to_string_pretty(&abi).unwrap())
}
