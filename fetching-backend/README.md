# Fetching Backend

## How to use
Fill out .env_template and rename to .env
```
cargo run --release
```

## Methodology

```mermaid
graph
    A[Monitor New Blocks] --> B[Gather Addresses in Transactions]
    B --> C[Fetch Bytecode per Address]
    C --> D[Detect Events/Selectors in Bytecode]
    D --> E[Output in Data-Friendly Format]
```

## Architecture

```mermaid
graph
    A[NodeWatcher] -->|New Addresses + Contracts| B[BytecodeAnalyzer]
    A[NodeWatcher] -->|Fetched Addresses Set| C[Save to Disk]
    B -->|Bytecode, Events, Selectors| C
    B --> D[DeployerAnalyzer]
    D -->|Previous Deployed Contracts| C
```


