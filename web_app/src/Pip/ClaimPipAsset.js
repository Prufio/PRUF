import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class ClaimPipAsset extends Component {
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
            type: "",
            manufacturer: "",
            model: "",
            serial: "",
            authCode: "",
            assetClass: "",
            first: "",
            middle: "",
            surname: "",
            countDownStart: "",
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

        const $claimPipAsset = () => {//create a new asset record
            this.setState({ txStatus: false });
            this.setState({ txHash: "" });
            this.setState({ error: undefined })
            this.setState({ result: "" })
            //reset state values before form resubmission
            var idxHash;
            var rgtRaw;
            var rgtHash;

            idxHash = window.web3.utils.soliditySha3(
                this.state.type,
                this.state.manufacturer,
                this.state.model,
                this.state.serial,
            );


            rgtRaw = window.web3.utils.soliditySha3(
                this.state.first,
                this.state.middle,
                this.state.surname,
            );

            var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
            //rgtHash = tenThousandHashesOf(rgtHash)

            console.log("idxHash", idxHash);
            console.log("New rgtRaw", rgtRaw);
            console.log("New rgtHash", rgtHash);
            console.log("addr: ", window.addr);
            console.log(window.assetClass);

            window.contracts.Pip.methods
                .$claimPipAsset(
                    idxHash,
                    this.state.authCode,
                    this.state.assetClass,
                    rgtHash,
                    this.state.countDownStart,
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
                <Form className="CPAform" id='MainForm'>
                    {window.addr === undefined && (
                        <div className="errorResults">
                            <h2>User address unreachable</h2>
                            <h3>Please connect web3 provider.</h3>
                        </div>
                    )}
                    {window.addr > 0 && (
                        <div>
                            <h2 className="Headertext">Claim Pip Asset</h2>
                            <br></br>
                            <Form.Row>
                                <Form.Group as={Col} controlId="formGridType">
                                    <Form.Label className="formFont">Type:</Form.Label>
                                    <Form.Control
                                        placeholder="Type"
                                        required
                                        onChange={(e) => this.setState({ type: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>

                                <Form.Group as={Col} controlId="formGridManufacturer">
                                    <Form.Label className="formFont">Manufacturer:</Form.Label>
                                    <Form.Control
                                        placeholder="Manufacturer"
                                        required
                                        size="lg"
                                        onChange={(e) => this.setState({ manufacturer: e.target.value })}
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
                                <Form.Group as={Col} controlId="formGridAssetClass">
                                    <Form.Label className="formFont">Asset Class:</Form.Label>
                                    <Form.Control
                                        placeholder="Asset Class"
                                        required
                                        onChange={(e) => this.setState({ assetClass: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>
                                <Form.Group as={Col} controlId="formGridcountDownStart">
                                    <Form.Label className="formFont">countDownStart:</Form.Label>
                                    <Form.Control
                                        placeholder="countDownStart"
                                        required
                                        onChange={(e) => this.setState({ countDownStart: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>
                            </Form.Row>
                            <Form.Row>
                                <Form.Group as={Col} controlId="formGridFirstName">
                                    <Form.Label className="formFont">First Name:</Form.Label>
                                    <Form.Control
                                        placeholder="First Name"
                                        required
                                        onChange={(e) => this.setState({ first: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>

                                <Form.Group as={Col} controlId="formGridMiddleName">
                                    <Form.Label className="formFont">Middle Name:</Form.Label>
                                    <Form.Control
                                        placeholder="Middle Name"
                                        required
                                        onChange={(e) => this.setState({ middle: e.target.value })}
                                        size="lg"
                                    />
                                </Form.Group>

                                <Form.Group as={Col} controlId="formGridLastName">
                                    <Form.Label className="formFont">Last Name:</Form.Label>
                                    <Form.Control
                                        placeholder="Last Name"
                                        required
                                        onChange={(e) => this.setState({ surname: e.target.value })}
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
                                        onClick={$claimPipAsset}
                                    >
                                        Claim Pip Asset
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

export default ClaimPipAsset;
