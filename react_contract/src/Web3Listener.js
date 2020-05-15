import  { useState } from 'react';
import Web3 from 'web3';
import returnAbi from './abi';
import returnSAbi from './sAbi';


function Web3Listener(request) {
    let web3 = require('web3');
    const ethereum = window.ethereum;
    web3 = new Web3(web3.givenProvider);
    var [addr, setAddr] = useState('');
    const bulletproof_frontend_addr = "0xCc2CBfd27fbf7AEF15FFfe119B91c3006B5DE0b0";
    const bulletproof_storage_addr = "0xec7C54c5A4F454fA951077A6D200A73910eB1ae0";
    const myAbi = returnAbi();
    const sAbi = returnSAbi();
    const bulletproof = new web3.eth.Contract(myAbi, bulletproof_frontend_addr);
    const storage = new web3.eth.Contract(sAbi, bulletproof_storage_addr);

    window.addEventListener('load', async () => {

        await ethereum.enable();
        web3.eth.getAccounts().then(e => setAddr(e[0]));

        if (web3.eth.getAccounts().then(e => e === addr)) {
            console.log("Serving current metamask address at accounts[0]");

        }

        ethereum.on('accountsChanged', function (accounts) {
            console.log('trying to change active address');
            web3.eth.getAccounts().then(e => setAddr(e[0]));
        })

    })

    if (request === 'addr') {
        return (addr);
    }

    else if (request === 'web3') {
        return (web3);
    }

    else if (request === 'bulletproof') {
        return (bulletproof);
    }

    else if (request === 'storage') {
        return (storage);
    }



}

export default Web3Listener;