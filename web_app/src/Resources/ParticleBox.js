import React, { Component } from "react";
import Particles from 'react-particles-js';



class ParticleBox extends Component {
    
  render() {//render continuously produces an up-to-date stateful document  


    return (
        <div
        style={{
        position: "absolute",
        top: 0,
        left: 0,
        width: "100%",
        height: "100%"
        }}
        >
        <Particles
          params={{
            "particles": {
                "number": {
                    "value": 90
                },
                "size": {
                    "value": 4
                }
            },
            "interactivity": {
                "events": {
                    "onhover": {
                        "enable": true,
                        "mode": "repulse"
                    }
                }
            }
        }}/>
        </div>
    );

  }
}

export default ParticleBox;