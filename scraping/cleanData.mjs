import fs from 'fs';

/// This script filters out contracts that are not plain solidity, and saves them

fs.readdirSync('./data/00contracts').forEach((p) => {
  const filename = `./data/00contracts/${p}`;
  const data = JSON.parse(fs.readFileSync(filename).toString());

  if (
    data.length === 1 &&
    data[0].SourceCode &&
    data[0].SourceCode.includes('pragma solidity') &&
    !data[0].SourceCode.startsWith('{')
  ) {
    console.log(`writing ${filename}`);
    fs.writeFileSync(
      filename.replace('.json', '.sol').replace('/00contracts/', '/00source/'),
      data[0].SourceCode
    );
  }
});
