use crate::*;
use tokio::sync::mpsc::{UnboundedSender};
use std::{time::Duration, str::FromStr};
use std::time::{Instant};
use tokio_tungstenite::{self, tungstenite::Message};
use tokio::net::TcpListener;
use tokio_tungstenite::{accept_async, WebSocketStream};
use warp::Filter;
use tokio::sync::oneshot;


const HTTP_PORT: u16 = 9003;

pub async fn reply_with_ws() -> Result<impl warp::Reply, warp::Rejection> {
    let reply = warp::reply::html("Hello, warp!");
    Ok(reply)
}

pub async fn run_endpoint_handler(mut node_msg_tx: UnboundedSender<(Address, oneshot::Sender<WSMessage>)>)-> eyre::Result<()> {
    // GET /hello/warp => 200 OK with body "Hello, warp!"
    let hello = warp::path!("get_similar_contract_for_address" / Address)
        .map( move |address| { 
            
            let (oneshot_tx, oneshot_rx) = oneshot::channel::<WSMessage>();

            // let address = Address::from_str(&name).unwrap();

            node_msg_tx.send((address, oneshot_tx)).unwrap();
            let ws_message = async {
                let ws_message = oneshot_rx.await.unwrap();
                    // format bytecode_message as websocket message
                let ws_message = serde_json::to_string(&ws_message).unwrap();
                ws_message
            };
            ws_message

        });
    
    warp::serve(hello)
        .run(([0, 0, 0, 0], HTTP_PORT))
        .await;
    Ok(())
}