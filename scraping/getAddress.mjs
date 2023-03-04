import fs from 'fs';

fs.readdirSync('../00').forEach((p) => {
  const newName = p.slice(0, 40) + '.sol';
  const code = fs.readFileSync('../00/' + p);
  fs.writeFileSync('../00byaddress/' + newName, code);
});
