import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import returnABIs from "./returnABIs";


class SetupAndResolveContracts extends Component {
    constructor(props) {
        super(props);

        //State declaration.....................................................................................................

        this.abis = returnABIs();

        this.state = {
            STOR_ADDR: "",
            APP_ADDR: "",
            APPNC_ADDR: "",
            NP_ADDR: "",
            NPNC_ADDR: "",
            ATKN_ADDR: "",
            ACTKN_ADDR: "",
            ACMGR_ADDR: "",
            ECR_ADDR: "",
            ECRMGR_ADDR: "",
            ECRNC_ADDR: "",
            NAKED_ADDR: "",
            RCLR_ADDR: "",
            VERIFY_ADDR: "",
        };
    }

    //component state-change events......................................................................................................

    componentDidMount() {//stuff to do when component mounts in window
    }

    componentDidUpdate() {//stuff to do when state updates

    }

    componentWillUnmount() {//stuff do do when component unmounts from the window

    }

    render() {//render continuously produces an up-to-date stateful document  
        const self = this;

        const resolveContractAddresses = async () => {
            await this.state.APP.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in APP");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.NP.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in NP");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.APP_NC.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in APP_NC");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.NP_NC.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in NP_NC");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.ECR.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in ECR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.ECR_NC.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in ECR_NC");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.ECR_MGR.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in ECR_MGR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.A_TKN.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in A_TKN");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.AC_TKN.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in AC_TKN");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.AC_MGR.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in AC_MGR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.RCLR.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in RCLR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.NAKED.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in NAKED");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.VERIFY.methods.OO_resolveContractAddresses().send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("Resolved in VERIFY");
                    console.log("tx receipt: ", receipt);
                });
        }

        const addStorageToContracts = async () => {
            await this.state.APP.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in APP");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.NP.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in NP");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.APP_NC.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in APP_NC");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.NP_NC.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in NP_NC");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.ECR.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in ECR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.ECR_NP.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in ECR_NC");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.ECR_MGR.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in ECR_MGR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.A_TKN.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in A_TKN");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.AC_TKN.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in AC_TKN");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.AC_MGR.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in AC_MGR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.RCLR.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in RCLR");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.NAKED.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in NAKED");
                    console.log("tx receipt: ", receipt);
                });
            await this.state.VERIFY.methods.OO_setStorageContract(this.state.STOR_ADDR).send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("STOR added in VERIFY");
                    console.log("tx receipt: ", receipt);
                });

            resolveContractAddresses()
        }

        const addContractsToStorage = async () => {
            await this.state.STOR.methods
                .OO_addContract(
                    "APP",
                    this.state.APP_ADDR,
                    "0",
                    "1"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: APP");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "NP",
                    this.state.NP_ADDR,
                    "0",
                    "1"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: NP");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "APP_NC",
                    this.state.APPNC_ADDR,
                    "0",
                    "2"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: APP_NC");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "NP_NC",
                    this.state.NPNC_ADDR,
                    "0",
                    "2"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: NP_NC");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "ECR",
                    this.state.ECR_ADDR,
                    "0",
                    "3"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: ECR");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "ECR_NC",
                    this.state.ECRNC_ADDR,
                    "0",
                    "3"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: ECR_NC");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "ECR_MGR",
                    this.state.ECRMGR_ADDR,
                    "0",
                    "3"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: ECR_MGR");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "A_TKN",
                    this.state.ATKN_ADDR,
                    "0",
                    "1"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: A_TKN");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "AC_TKN",
                    this.state.ACTKN_ADDR,
                    "0",
                    "1"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: AC_TKN");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "AC_MGR",
                    this.state.ACMGR_ADDR,
                    "0",
                    "1"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: AC_MGR");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "RCLR",
                    this.state.RCLR_ADDR,
                    "0",
                    "3"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: RCLR");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "NAKED",
                    this.state.NAKED_ADDR,
                    "0",
                    "2"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: NAKED");
                    console.log("tx receipt: ", receipt);
                });

            await this.state.STOR.methods
                .OO_addContract(
                    "VERIFY",
                    this.state.VERIFY_ADDR,
                    "0",
                    "1"
                )
                .send({ from: window.addr })
                .on("error", function (_error) {
                    console.log("ERR: ", _error)
                })
                .on("receipt", (receipt) => {
                    console.log("contract added: VERIFY");
                    console.log("tx receipt: ", receipt);
                });

            addStorageToContracts()
        }

        const setupContracts = async () => {
            await this.setState({
                STOR: new window.web3.eth.Contract(this.abis.STOR, this.state.STOR_ADDR),
                APP: new window.web3.eth.Contract(this.abis.APP, this.state.APP_ADDR),
                APP_NC: new window.web3.eth.Contract(this.abis.APP_NC, this.state.APPNC_ADDR),
                NP: new window.web3.eth.Contract(this.abis.NP, this.state.NP_ADDR),
                NP_NC: new window.web3.eth.Contract(this.abis.NP_NC, this.state.NPNC_ADDR),
                ECR: new window.web3.eth.Contract(this.abis.ECR, this.state.ECR_ADDR),
                ECR_NC: new window.web3.eth.Contract(this.abis.ECR_NC, this.state.ECRNC_ADDR),
                ECR_MGR: new window.web3.eth.Contract(this.abis.ECR_MGR, this.state.ECRMGR_ADDR),
                A_TKN: new window.web3.eth.Contract(this.abis.A_TKN, this.state.ATKN_ADDR),
                AC_TKN: new window.web3.eth.Contract(this.abis.AC_TKN, this.state.ACTKN_ADDR),
                AC_MGR: new window.web3.eth.Contract(this.abis.AC_MGR, this.state.ACMGR_ADDR),
                NAKED: new window.web3.eth.Contract(this.abis.NAKED, this.state.NAKED_ADDR),
                RCLR: new window.web3.eth.Contract(this.abis.RCLR, this.state.RCLR_ADDR),
                VERIFY: new window.web3.eth.Contract(this.abis.VERIFY, this.state.VERIFY_ADDR),
            })
            addContractsToStorage()
        }

        return (
            <div>
                <Form className="StartupForm">
                    {window.addr === undefined && (
                        <div className="VRresults">
                            <h2>User address unreachable</h2>
                Please connect web3 provider.
                        </div>
                    )}

                    {window.addr !== undefined && (
                        <div>
                            <h2 className="Headertext">SET AND RESOLVE</h2>
                            <br></br>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">STOR :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ STOR_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">APP :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ APP_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">APP_NC :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ APPNC_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">NP :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ NP_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">NP_NC :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ NPNC_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">ECR :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ ECR_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">ECR_NC :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ ECRNC_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">ECR_MGR :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ ECRMGR_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">A_TKN :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ ATKN_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">AC_TKN :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ ACTKN_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">AC_MGR :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ ACMGR_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">NAKED :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ NAKED_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>
                            <Form.Group as={Col} controlId="formGridNewOwner">
                                <Form.Label className="formFont">RCLR :</Form.Label>
                                <Form.Control
                                    placeholder="Address"
                                    required
                                    onChange={(e) => this.setState({ RCLR_ADDR: e.target.value })}
                                    size="lg"
                                />
                            </Form.Group>

                            <div>
                                <Form.Group>
                                    <Button
                                        className="ownerButtonDisplay"
                                        variant="primary"
                                        type="button"
                                        size="lg"
                                        onClick={setupContracts}
                                    >
                                        Create AC
                                </Button>
                                </Form.Group>
                            </div>
                        </div>
                    )}
                </Form>
            </div>
        );
    }
}
export default SetupAndResolveContracts;
