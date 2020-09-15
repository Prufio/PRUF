import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class MintPipAsset extends Component {
    constructor(props) {
        super(props);

        //State declaration.....................................................................................................

        this.state = {
            addr: "",
            lookupIPFS1: "",
            lookupIPFS2: "",
            error: undefined,
            NRerror: undefined,
            result: null,
            assetClass: undefined,
            type: "",
            manufacturer: "",
            model: "",
            serial: "",
            authCode: "",
            isNFA: false,
            txStatus: null,
        };
    }

    //component state-change events......................................................................................................

    componentDidMount() {//stuff to do when component mounts in window

    }

    componentWillUnmount() {//stuff do do when component unmounts from the window

    }
    componentDidUpdate() {//stuff to do on a re-render

    }

    render() {//render continuously produces an up-to-date stateful document  
        const self = this;

        async function tenThousandHashesOf(varToHash) {
            var tempHash = varToHash;
            for (var i = 0; i < 10000; i++) {
                tempHash = window.web3.utils.soliditySha3(tempHash);
                console.log(tempHash);
            }
            return tempHash;
        }

        async function checkExists(idxHash) {//check whether record of asset exists in the database
            window.contracts.STOR.methods
                .retrieveShortRecord(idxHash)
                .call({ from: self.state.addr }, function (_error, _result) {
                    if (_error) {
                        console.log("IN ERROR IN ERROR IN ERROR")
                        self.setState({ error: _error.message });
                        self.setState({ result: 0 });
                    } else if (
                        Object.values(_result)[4] ===
                        "0"
                    ) {
                    } else {
                        self.setState({ result: _result });
                        alert(
                            "WARNING: Record already exists! Reject in metamask and change asset info."
                        );
                    }
                    console.log("In checkExists, _result, _error: ", _result, _error);
                });
        }

        const mintPipAsset = () => {//create a new asset record
            this.setState({ txStatus: false });
            this.setState({ txHash: "" });
            this.setState({ error: undefined })
            this.setState({ result: "" })
            //reset state values before form resubmission
            var idxHash;
            var hashedAuthCode;

            idxHash = window.web3.utils.soliditySha3(
                this.state.type,
                this.state.manufacturer,
                this.state.model,
                this.state.serial,
            );


            hashedAuthCode = window.web3.utils.soliditySha3(
                this.state.assetClass,
                this.state.authCode,
            );

            console.log("idxHash", idxHash);
            console.log("hashedAuthCode", hashedAuthCode);
            console.log(window.assetClass);

            checkExists(idxHash);

            window.contracts.Pip.methods
                .mintPipAsset(
                    idxHash,
                    hashedAuthCode,
                    window.assetClass,
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    // self.setState({ NRerror: _error });
                    self.setState({ txHash: Object.values(_error)[0].transactionHash });
                    self.setState({ txStatus: false });
                    console.log(Object.values(_error)[0].transactionHash);
                })
                .on("receipt", (receipt) => {
                    this.setState({ txHash: receipt.transactionHash });
                    this.setState({ txStatus: receipt.status });
                });

            document.getElementById("MainForm").reset(); //clear form inputs
        };

        return (//default render
            <div>
                <Form className="MPAform" id='MainForm'>
                    {window.addr === undefined && (
                        <div className="errorResults">
                            <h2>User address unreachable</h2>
                            <h3>Please connect web3 provider.</h3>
                        </div>
                    )}
                    {window.addr > 0 && (
                        <div>
                            <h2 className="Headertext">Mint Pip Asset</h2>
                            <br></br>
                            <Form.Row>
                                <Form.Group as={Col} controlId="formGridType">
                                    <Form.Label className="formFont">Type:</Form.Label>
                                    <Form.Control
                                        placeholder="Type"
                                        required
                                        onChange={(e) => this.setState({ type: e.target.value })}
                                        size="lg"
                                    />{/* )} */}
                                </Form.Group>

                                <Form.Group as={Col} controlId="formGridManufacturer">
                                    <Form.Label className="formFont">Manufacturer:</Form.Label>
                                    <Form.Control
                                        placeholder="Manufacturer"
                                        required
                                        onChange={(e) => this.setState({ manufacturer: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>
                            </Form.Row>
                            <Form.Row>
                                <Form.Group as={Col} controlId="formGridModel">
                                    <Form.Label className="formFont">Model:</Form.Label>
                                    <Form.Control
                                        placeholder="Model"
                                        required
                                        onChange={(e) => this.setState({ model: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>
                                <Form.Group as={Col} controlId="formGridSerial">
                                    <Form.Label className="formFont">Serial:</Form.Label>
                                    <Form.Control
                                        placeholder="Serial"
                                        required
                                        onChange={(e) => this.setState({ serial: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>
                            </Form.Row>
                            <Form.Row>
                                <Form.Group as={Col} controlId="formGridAuthCode">
                                    <Form.Label className="formFont">Auth Code:</Form.Label>
                                    <Form.Control
                                        placeholder="Auth Code"
                                        required
                                        onChange={(e) => this.setState({ authCode: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>
                            </Form.Row>
                            <Form.Row>
                                <Form.Group className="buttonDisplay">
                                    <Button
                                        variant="primary"
                                        type="button"
                                        size="lg"
                                        onClick={mintPipAsset}
                                    >
                                        Mint Pip Asset
                                    </Button>
                                </Form.Group>

                            </Form.Row>

                            <br></br>

                        </div>
                    )}
                </Form>
                {this.state.txHash > 0 && ( //conditional rendering
                    <div className="Results">
                        {this.state.txStatus === false && (
                            <div>
                                !ERROR! :
                                <a
                                    href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                >
                                    KOVAN Etherscan:{this.state.txHash}
                                </a>
                            </div>
                        )}
                        {this.state.txStatus === true && (
                            <div>
                                {" "}
                No Errors Reported :
                                <a
                                    href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                >
                                    KOVAN Etherscan:{this.state.txHash}
                                </a>
                            </div>
                        )}
                    </div>
                )}
            </div>
        );
    }
}

export default MintPipAsset;
