import React from 'react';
import './App.css';
import NewRecord from './NewRecord';
import Web3Listener from './Web3Listener';
import Transfer from './Transfer';
import Compare from './Compare';
import DeepCompare from './DeepCompare'

function App() {
  let ethereum = Web3Listener('ethereum')

  return (
    <div className="App">
      {ethereum && <p>Currently serving: {Web3Listener('addr')} </p>}
      {!ethereum && <p>Not connected to injected WEB3, please connect to your preferred ethereum provider.</p>}
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
