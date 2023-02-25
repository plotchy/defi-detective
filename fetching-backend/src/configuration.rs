use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Settings {
    pub fetch_settings: FetchSettings,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct FetchSettings {
    pub rel_path_of_addresses: String,
    pub network: String,
    pub rate_interval_ms: u64,
    pub rel_output_dir: String,
    pub rpc_url: String,
}