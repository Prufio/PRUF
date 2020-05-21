import { useState } from 'react';
import Web3 from 'web3';
import returnStorageAbi from './stor_abi';
import returnFrontEndAbi from './front_abi';


function Web3Listener(request) {
    let web3 = require('web3');
    const ethereum = window.ethereum;
    web3 = new Web3(web3.givenProvider);
    var [addr, setAddr] = useState('');
    var [web3connection, setWeb3connection] = useState(false);
    const bulletproof_frontend_addr = "0x755414B4137F418810bd399E22da19ec9ddfdEaE";
    const bulletproof_storage_addr = "0xC600741749E4c90Ad553E31DF5f2EA9fe51aB4e0";
    const frontEnd_abi = returnFrontEndAbi();
    const storage_abi = returnStorageAbi();
    const frontend = new web3.eth.Contract(frontEnd_abi, bulletproof_frontend_addr);
    const storage = new web3.eth.Contract(storage_abi, bulletproof_storage_addr);
    window.addEventListener('load', async () => {

        if (ethereum.isMetaMask === false){
            setWeb3connection(false);
        }

        ethereum.on('networkChanged', function () {

            if (!ethereum.isMetaMask){
                setWeb3connection(false);
            }

            else if (ethereum.isMetaMask){
                setWeb3connection(true);
            }
        })
    })
    console.log("Web 3 connection", web3connection)


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

    else if (request === 'frontend') {
        return (frontend);
    }

    else if (request === 'storage') {
        return (storage);
    }

    else if (request === 'connection'){
        return (addr !== '');
    }



}

export default Web3Listener;