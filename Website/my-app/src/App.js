import React from 'react';
import {useState} from 'react';
import Tweet from './Tweet';

function sendMessage(){
  alert("I am a certified doctor");
}

function App() {
  const [isRed, setRed] = useState(false);
  const [count, setCount] = useState(0);
  const increment = () => {
    setCount(count + 1);
    setRed(!isRed);
   
  }


  return (
    <div>
      <div className = 'header'>
        <h1>Twitter</h1>
        <h2>Welcome to real twitter</h2>
        <h3>This is actually twitter</h3>
        <br>
        </br>
        <h4>Holy shit</h4>
      </div>
    <div className = 'app'>
      <div className = 'increment'>
          <h4 className = {isRed ? 'red' : ''}>Change My Color</h4>
          <button onClick = {increment}>Increment</button>
          <h2>{count}</h2>
          <button onClick = {sendMessage}>Request Secret Message</button>
      </div>
      <Tweet name = "@BeanStockpile663" content = "Who ate all of my beans? Life could not be worse." likes = "4.1k likes"/>
      <Tweet name = "@BeanChugger" content = "out of bean" likes = "98.2k likes"/>
      <Tweet name = "@Mr_Fursuit" content = "Today I was arrested for having sex with a racoon. SMH." likes = "783 likes"/>
    </div>
    </div>
  );
}

export default App;
