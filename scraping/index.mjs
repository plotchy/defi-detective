import fs from 'fs';
import fetch from 'node-fetch';

const forks = JSON.parse(fs.readFileSync('./forks.json'));
console.log(forks.length);

const urls = forks.map((fork) => fork.name.replace(/\s+/g, '-').toLowerCase());

console.log(urls.slice(0, 20));

const queries = urls.map((url) => `https://api.llama.fi/protocol/${url}`);

const results = [];
for (const q of queries.slice(0, 2)) {
  const res = await fetch(q);
  const data = await res.json();
  delete data['chainTvls'];
  delete data['tvl'];
  results.push(data);
}

// save results to file
fs.writeFileSync('results.json', JSON.stringify(results));
