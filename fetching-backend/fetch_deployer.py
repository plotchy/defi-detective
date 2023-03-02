# python

import ctc
from ctc import evm
import asyncio
import json
import ctc.rpc
import ctc.spec
import os

# load .env variables
from dotenv import load_dotenv
load_dotenv()

# set rpcs
rpc_urls = {
    'mainnet': os.getenv("ETH_MAINNET_RPC_URL"),
    'goerli': os.getenv("ETH_GOERLI_RPC_URL"),
    'arbitrum': os.getenv("ARBITRUM_MAINNET_RPC_URL"),
    'arbitrum-goerli': os.getenv("ARBITRUM_GOERLI_RPC_URL"),
    'optimism': os.getenv("OPTIMISM_MAINNET_RPC_URL"),
    'polygon': os.getenv("POLYGON_MAINNET_RPC_URL"),
    'mumbai': os.getenv("POLYGON_MUMBAI_RPC_URL"),
    'avalanche': os.getenv("INFURA_AVALANCHE_CCHAIN_RPC_URL"),
    'fuji': os.getenv("INFURA_AVALANCHE_FUJI_RPC_URL"),
}


def get_provider_from_network(network):
    # get provider from evm.rpc_urls[network]
    print(network)
    provider = rpc_urls[network]
    print(os.getenv("ETH_MAINNET_RPC_URL"))
    print(provider)
    return provider


async def grab_deployer(address, context):
    deployer = await evm.async_get_contract_deployer(address, context=context)
    return deployer

async def get_txs_of_deployer(address, context):
    transactions = await ctc.async_get_transactions_from_address(address, context=context)
    print(transactions)


def main():

    # walk over filepath cwd+outputs/new_contract_matches.json
    # for each item in json, use "address" and "network" to grab_deployer(address, network)
    # add "deployer" key to each item in json

    # write json to cwd+outputs/new_contract_matches.json

    with open("outputs/new_contract_matches.json", "r") as f:
        json_data = json.load(f)
        matches = json_data["matches"]
        for match in matches:
            print(match)
            address = match["address"]
            network = match["network"]
            provider = get_provider_from_network(network)
            # create context based on network
            context = ctc.spec.ShorthandContext(provider=provider)

            deployer = asyncio.run(grab_deployer(address, context=context))
            print(deployer)
            match["deployer"] = deployer
            break
        
    # with open("outputs/new_contract_matches.json", "w") as f:
    #     json.dump(json_data, f)

main()
