import  React, { useState } from 'react';
import Web3 from 'web3';
import returnAbi from './abi';
import returnSAbi from './sAbi';


function Web3Listener(request) {
    let web3 = require('web3');
    const ethereum = window.ethereum;
    web3 = new Web3(web3.givenProvider);
    var [addr, setAddr] = useState('');
    const bulletproof_frontend_addr = "0xe9d8A17cD975Fc36734E09D68Fe3535c61E64CB6";
    const bulletproof_storage_addr = "0xe9B2AdeFe20f38Bb9B1Ce951baDafbf011eB4544";
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

    const checkReport =() => {
        storage.events.REPORT({fromBlock: 'latest', toBlock: 'latest'}.then((error, event) => {
        
        if(error){
            console.log(error);
        }
    
        else{
            return (JSON.stringify(event));
        }
    }));

    }

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

     else if (request === 'REPORT') {
        return (checkReport);
     }



}

export default Web3Listener;