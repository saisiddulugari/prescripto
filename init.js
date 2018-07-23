var web3 = require('web3');
fs = require('fs');
solc  = require('solc');

web3 = new web3(new web3.providers.HttpProvider("http://localhost:8545"));
code = fs.readFileSync('prescrip.sol').toString();
//contract = web3.eth.compile.solidity(code);
contract = solc.compile(code);

function after2Delay() {
    contractInstance = presContract.at(deployedContract.address);
    console.log(contractInstance.address);
}

function afterDelay() {
    abiDefinition = JSON.parse(contract.contracts[':kyc'].interface);
    byteCode = contract.contracts[':kyc'].bytecode;
    presContract = web3.eth.contract(abiDefinition);
    deployedContract = presContract.new({data: byteCode, from: web3.eth.accounts[0], gas: 4700000});
    setTimeout(after2Delay, 3000);
}

setTimeout(afterDelay, 8000);
