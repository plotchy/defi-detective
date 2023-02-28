import fs from 'fs';

/// Add category for each item in pca json for vizualization

const protocols = JSON.parse(
  fs.readFileSync('./data/allprots.json').toString()
);

const pca = JSON.parse(fs.readFileSync('./pca.json').toString());

const withCategory = Object.entries(pca).map(([name, data]) => ({
  name,
  data,
  category: protocols.find((p) => p.slug == name).category,
}));

fs.writeFileSync('pcacat.json', JSON.stringify(withCategory));
