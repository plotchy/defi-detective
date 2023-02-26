pub mod fetcher;


use crate::configuration::FetchSettings;
use config::Config;
use config::File;
use crate::configuration::*;
use std::{io::Write};
use walkdir::WalkDir;
use std::collections::HashSet;
use tracing_subscriber;
use tracing::{info, warn, error, debug, trace, instrument, span, Level};
use tokio::join;



pub async fn run_node_watcher(fetch_settings: FetchSettings) -> eyre::Result<()> {
    // this fn subscribes to an RPC's block output
    
    todo!()
} 