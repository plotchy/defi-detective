import fs from 'fs';

/// This script filters out contracts that are not plain solidity, and saves them

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
  if (
    data.length === 1 &&
    data[0].SourceCode &&
    data[0].SourceCode.includes('pragma solidity') &&
    !data[0].SourceCode.startsWith('{')
  ) {
    console.log(`writing ${filename}`);
    fs.writeFileSync(
      filename.replace('.json', '.sol').replace('/contracts/', '/source/'),
      data[0].SourceCode
    );
  }
});
