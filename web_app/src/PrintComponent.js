import React from "react";

class ComponentToPrint extends React.Component {


    render() {
      return (
        <div>
          {window.utils.generateCardPrint()}
        </div>
      );
    }
  }

  export default ComponentToPrint