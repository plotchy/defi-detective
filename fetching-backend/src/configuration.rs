use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Settings {
    pub fetch_settings: FetchSettings,
    pub bytecode_settings: BytecodeSettings,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct FetchSettings {
    pub rate_interval_ms: u64,
    pub rel_output_dir: String,
    pub rel_db_dir: String,
    pub write_to_db_interval_secs: u64,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct BytecodeSettings {
    pub rel_event_patterns_path: String,
    pub rel_selector_patterns_path: String,
    pub rel_filtered_bytecodes_path: String,
    pub rel_existing_contract_matches_path: String,
    pub rel_new_contract_matches_path: String,
    pub write_to_matches_interval_secs: u64,
    pub enable_existing_contract_matches: bool,
}