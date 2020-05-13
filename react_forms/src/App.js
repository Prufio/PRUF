//import ReactDOM from 'react-dom'
import React, { useState } from 'react';
import { useFormin } from 'formin';
import { Formin } from 'formin';
const axios = require('axios');

class App extends React.Component {
	render() {
  	return (
    	<div>
      <Form/>
    	</div>
    );
  }	
}

function Form() {
  const { getInputProps, getFormProps } = useFormin({
    onSubmit: ({ values }) => {
      console.log(values)
    },
  })

  return (
    <form {...getFormProps()}>
      <input {...getInputProps({ name: 'foo' })} />
      <input {...getInputProps({ name: 'bar' })} />
      <button>Submit</button>
    </form>
  )
}

function MyForm() {
  return (
    <Formin
      onSubmit={({ values }) => {
        console.log(values)
      }}
    >
      {({ getFormProps, getInputProps }) => (
        <form {...getFormProps()}>
          <input {...getInputProps({ name: 'foo' })} />
          <input {...getInputProps({ name: 'bar' })} />
          <button>Submit</button>
        </form>
      )}
    </Formin>
  )
}
 
export default App;