/* async function RCFJ () {
let contracts = fs.readFile('contracts.json', 'utf8', async function readFileCallback(err, result) {
    let _contracts;
    if (err) {
        console.log(err);
    } else {
        console.log('Successful file read: ')
        _contracts = JSON.parse(result);
        console.log('parsed data: ', contracts);
        console.log('parsed data element: ', _contracts.content[0]);
        return _contracts;
    }
  });
  return contracts
}

export default RCFJ */