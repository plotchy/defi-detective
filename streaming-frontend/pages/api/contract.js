import fs from 'fs';

const contracts = new Map();
const names = JSON.parse(fs.readFileSync('../pca.json', 'utf8'));

fs.readdir('../00', (err, files) => {
  if (err) {
    console.log(err);
    return;
  }
  files.forEach((file) => {
    contracts.set(file.slice(0, 40), file);
  });
});

export default function handler(req, res) {
  const { address } = req.query;
  const file = contracts.get(address);
  if (file) {
    const contract = fs.readFileSync(`../00/${file}`, 'utf8');
    const name = names.find((n) => n.address === address).name;
    res.status(200).json({ name, contract });
  } else {
    res.status(404).json({ error: 'Contract not found' });
  }
}
