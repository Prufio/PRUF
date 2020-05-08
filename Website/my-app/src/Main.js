import React from 'react';
import { useState } from 'react';
import './App.css';


function Main(props) {
    const [isRed, setRed] = useState(false);
    const [count, setCount] = useState(0);

    const increment = () => {
        setCount(count + 1);
        setRed(!isRed);

    }
    const sendMessage = () => {
        alert("I am a certified doctor");
    }
    if (props.mode === 1) {
        return (
            <div className='increment'>
                <h4 className={isRed ? 'red' : ''}>Change My Color</h4>
                <button onClick={increment}>Increment</button>
                <h2>{count}</h2>
                <button onClick={sendMessage}>Request Secret Message</button>
            </div>
        );
    }
    else if (props.mode === 0) {
        return (
            <div className='increment_plus'>
                <h4 className={isRed ? 'red' : ''}>Change My Color</h4>
                <button onClick={increment}>Increment</button>
                <h2>{count}</h2>
                <button onClick={sendMessage}>Request Secret Message</button>
            </div>
        );
    }
}

export default Main;