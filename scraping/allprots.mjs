import fs from 'fs';
import dotenv from 'dotenv';
import fetch from 'node-fetch';

dotenv.config();

let protocols = JSON.parse(fs.readFileSync('./data/allprots.json'));
protocols = protocols.filter((p) => !!p.address);

console.log(protocols.length);

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
console.log(ETHERSCAN_API_KEY);
async function getCode(address) {
  const query = `https://api.etherscan.io/api?module=contract&action=getsourcecode&address=${address}&apikey=${ETHERSCAN_API_KEY}`;
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
          `./data/contracts/${p.name.replace(/\s+/g, '-').toLowerCase()}.json`,
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
