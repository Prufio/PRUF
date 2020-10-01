import React, { Component } from 'react'
import QrReader from 'react-qr-reader'
 
class QRReader extends Component {
  state = {
    result: 'No result'
  }
 
  handleScan = data => {
    if (data) {
      this.setState({
        result: data
      })
    }
  }
  handleError = err => {
    console.error(err)
  }
  render() {
    return (
      <div className="Form">
        <QrReader
          delay={300}
          onError={this.handleError}
          onScan={this.handleScan}
          style={{ width: '100%' }}
        />
        <div className="RRresults">{this.state.result}</div>
      </div>
    )
  }
}

export default QRReader;