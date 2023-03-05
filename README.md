# 🕵🏻 DeFi Detective

Explore a real-time feed of recently deployed smart contracts. Use our tools to analyze similarity and detect imitations, forks and novel DeFi protocols.

## Features

- Real time detection of new projects
- Cluster graphs based on smart contract code embeddings
- Code diffs for verified smart contract code

## How to run

### Frontend

```sh
npm i -g pnpm
cd frontend
pnpm i
pnpm dev
```

### Fetching backend

```sh
# (Install Rust)
cd fetching-backend
pnpm i
pnpm build
pnpm start
```

### ML backend

Add your openai secret key to `ml-backend/.env`
