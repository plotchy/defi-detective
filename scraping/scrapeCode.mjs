import fs from 'fs';
import dotenv from 'dotenv';
import fetch from 'node-fetch';

/// This script scrapes the source code of defillama listed defi protocols from etherscan.io

dotenv.config();

// get filenames from ./00
const filenames = fs.readdirSync('../00');

const protocols = filenames.map((filename) => ({
  address: filename.slice(0, 40),
  name: filename.slice(41, -5),
}));

console.log(protocols[0], protocols[1]);

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
async function getCode(address) {
  const query = `https://api.etherscan.io/api?module=contract&action=getsourcecode&address=0x${address}&apikey=${ETHERSCAN_API_KEY}`;
  const res = await (await fetch(query)).json();
  return res;
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

for (const p of protocols) {
  await sleep(300);
  getCode(p.address)
    .then((code) => {
      try {
        fs.writeFileSync(
          `./data/00contracts/${p.name}.json`,
          JSON.stringify(code.result)
        );
      } catch (e) {
        console.log(e);
      }
    })
    .catch((e) => {
      console.log(e);
    });
}
