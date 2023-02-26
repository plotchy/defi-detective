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
}

#[derive(Serialize, Deserialize, Debug)]
pub struct BytecodeSettings {
    pub rel_event_patterns_path: String,
    pub rel_selector_patterns_path: String,
}