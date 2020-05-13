import React from 'react';
import {useState} from 'react';
import Tweet from './Tweet';
import Main from './Main';

function App() {
  var [pageJob, setJob] = useState(1);

  const changeJob = () => {
    console.log("changing page job")
    //alert("It's Changing!")
    if (pageJob === 1){
      setJob(0);
    }
    else if (pageJob === 0){
      setJob(1);
    }
    //refreshPage();
  }

  const refreshPage = () => {
    window.location.reload(false);
  }

  return (
    <div>
      <div className = 'header'>
        <h1>Twitter</h1>
        <button onClick = {changeJob}>Toggle Page Job</button>
      </div>
      <Main mode = {pageJob}/>
    <div className = 'app'>
      <Tweet name = "@BeanStockpile663" content = "Who ate all of my beans? Life could not be worse." likes = "4.1k likes"/>
      <Tweet name = "@BeanChugger" content = "out of bean" likes = "98.2k likes"/>
      <Tweet name = "@Mr_Fursuit" content = "Yiff" likes = "783 likes"/>
    </div>
    </div>
  );
}

export default App;
