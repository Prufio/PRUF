import React, { useState } from 'react';
import './App.css';
import NewRecord from './NewRecord';
import Web3Listener from './Web3Listener';
import Transfer from './Transfer';
import Compare from './Compare';
import DeepCompare from './DeepCompare'

function App() {

  return (
    <div className="App">
      Currently serving: {Web3Listener('addr')}
      {/* {ethereum && <p>currently serving: {addr} </p>}
      {!ethereum && <p>Metamask not currently installed</p>} */}
      <header className="App-header">
        <Compare />
        <NewRecord />
        <Transfer />
        <DeepCompare/>
      </header>
    </div>
  );
}

export default App;
