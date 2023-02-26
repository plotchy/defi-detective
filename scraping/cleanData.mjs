import fs from 'fs';

const protocols = JSON.parse(
  fs.readFileSync('./data/allprots.json').toString()
);

protocols.forEach((p) => {
  const filename = `./data/contracts/${p.name
    .replace(/\s+/g, '-')
    .toLowerCase()}.json`;
  if (!fs.existsSync(filename)) {
    return;
  }
  const data = JSON.parse(fs.readFileSync(filename).toString());
  if (data.length === 1 && data.SourceCode.includes('pragma solidity')) {
    console.log(`Deleting ${filename}`);
    fs.unlinkSync(filename);
  }
});
