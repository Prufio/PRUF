import React from 'react';
import ReactToPrint, { PrintContextConsumer } from 'react-to-print';
import { QRCode } from 'react-qrcode-logo';

class ComponentToPrint extends React.Component {
    render() {
        return (
            <div className="PrintForm" >
                <div className="QRPrint">
                    <QRCode
                        value={"0x3fb48927da95319a502ae90ec960bd70768b6986461b80f7b570b0b0d3f3c86"}
                        qrStyle="dots"
                        size="400"
                        fgColor="#002a40"
                        logoWidth="120"
                        logoHeight="159"
                        logoImage="https://pruf.io/assets/images/pruf-u-logo-with-border-323x429.png"
                    />
                </div>
                <div className="PrintFormContent">
                    <p className="card-name-print">Name : {"Carl Sagan Action Figure"}</p>
                    <p className="card-ac-print">Asset Class : {"11"}</p>
                    <h4 className="card-idx-print">IDX : {"0x3fb48927da95319a502ae90ec960bd70768b6986461b80f7b570b0b0d3f3c86"}</h4>
                </div>
            </div>
        );
    }
}

class Print extends React.Component {
    render() {
        return (
            <div>
                <ReactToPrint content={() => this.componentRef}>
                    <PrintContextConsumer>
                        {({ handlePrint }) => (
                            <button onClick={handlePrint}>Print this out!</button>
                        )}
                    </PrintContextConsumer>
                </ReactToPrint>
                <ComponentToPrint ref={el => (this.componentRef = el)} />
            </div>
        );
    }
}

export default Print;