import { useState } from 'react';
import Web3 from 'web3';
import returnStorageAbi from './stor_abi';
import returnFrontEndAbi from './front_abi';


function Web3Listener(request) {
    let web3 = require('web3');
    const ethereum = window.ethereum;
    web3 = new Web3(web3.givenProvider);
    var [addr, setAddr] = useState('');
    const bulletproof_frontend_addr = "0xd351e6172d3F1E6013c0a05bCC7DA057d0151C86";
    const bulletproof_storage_addr = "0xA2A47E0733Ed153e0c263334Ec92a34AB4A15B70";
    const frontEnd_abi = returnFrontEndAbi();
    const storage_abi = returnStorageAbi();
    const bulletproof = new web3.eth.Contract(frontEnd_abi, bulletproof_frontend_addr);
    const storage = new web3.eth.Contract(storage_abi, bulletproof_storage_addr);

    window.addEventListener('load', async () => {

        //await ethereum.enable();
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