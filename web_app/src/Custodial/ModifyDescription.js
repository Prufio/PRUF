import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import ButtonGroup from "react-bootstrap/ButtonGroup";
import DropdownButton from 'react-bootstrap/DropdownButton'
import Dropdown from 'react-bootstrap/Dropdown'
import bs58 from "bs58";


class ModifyDescription extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      IPFS: require("ipfs-mini"),
      hashPath: "",
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      assetClass: undefined,
      ipfs1: "",
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      isNFA: false,
      surname: "",
      id: "",
      secret: "",
      idxHash: "",
      rgtHash: "",
      elementType: 0,
      elementName: "",
      elementValue: "",
      removePhotoElement: "",
      removeTextElement: "",
      additionalElementArrays: {
        photo: [],
        text: [],
      }
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



    const getBytes32FromIpfsHash = (ipfsListing) => {
      return "0x" + bs58.decode(ipfsListing).slice(2).toString("hex");
    };

    const _addToMiscArray = async (type) => {
      let element = ('"' + this.state.elementName + '": ' + '"' + this.state.elementValue + '",')
      if (this.state.elementName === "" || this.state.elementValue === "") {
        return alert("All fields are required for submission")
      }
      if (type === "photo") {
        window.additionalElementArrays.photo.push(element)
      }
      else if (type === "text") {
        window.additionalElementArrays.text.push(element)
      }
      else { return alert("Please use the dropdown menu to select an element type") }

      console.log("Added", element, "to element array")
      console.log("Which now looks like: ", window.additionalElementArrays)
      this.setState({ elementType: "0" })
      return document.getElementById("MainForm").reset();
    }

    const _removeElement = async (type) => {
      console.log("Existing description before edits: ", this.state.oldDescription)
      let element = (this.state.removeElement)
      let oldDescription = JSON.parse(this.state.oldDescription);
      let resultDescription;
      let oldDescriptionPhoto = {photo: oldDescription.photo}
      let oldDescriptionText = {text: oldDescription.text}


      if (this.state.element === "") {
        return alert("All fields are required for submission")
      }

      if (type === "removePhoto") {
        if (oldDescription.photo[element]) {
          delete oldDescription.photo[element]
          console.log("Removed", element, "from photo object")
        }
        else { alert("Element does not exist in existing photo object") }
      }

      else if (type === "removeText") {
        if (oldDescription.text[element]) {
          delete oldDescription.text[element]
          console.log("Removed", element, "from text object")
        }
        else { alert("Element does not exist in existing text object") }
      }

      else { return alert("Please use the dropdown menu to select an element type") }

      console.log("oldDescription after edits: ", oldDescription)
      this.setState({ oldDescription: JSON.stringify(oldDescription) })
      this.setState({elementType: "0"})
      return document.getElementById("MainForm").reset();

    }

    const getIpfsHashFromBytes32 = (bytes32Hex) => {

      // Add our default ipfs values for first 2 bytes:
      // function:0x12=sha2, size:0x20=256 bits
      // and cut off leading "0x"
      const hashHex = "1220" + bytes32Hex.slice(2);
      const hashBytes = Buffer.from(hashHex, "hex");
      const hashStr = bs58.encode(hashBytes);
      return hashStr;

    };

    const publishIPFS1 = async () => {
      console.log(this.state.oldDescription)
      let newDescription;

      console.log("Checking payload...")

      let newDescriptionPhoto = '"photo": {';

      for (let i = 0; i < window.additionalElementArrays.photo.length; i++) {
        newDescriptionPhoto += (window.additionalElementArrays.photo[i])
      }

      if (newDescriptionPhoto.charAt(newDescriptionPhoto.length - 1) === ",") { newDescriptionPhoto = newDescriptionPhoto.substring(0, newDescriptionPhoto.length - 1); }
      newDescriptionPhoto += '}}'

      let newDescriptionText = '"text": {';

      for (let i = 0; i < window.additionalElementArrays.text.length; i++) {
        newDescriptionText += (window.additionalElementArrays.text[i])
      }

      if (newDescriptionText.charAt(newDescriptionText.length - 1) === ",") { newDescriptionText = newDescriptionText.substring(0, newDescriptionText.length - 1); }
      newDescriptionText += "}}"

      console.log("Text...Should look like JSON", newDescriptionText)
      console.log("Photo...Should look like JSON", newDescriptionPhoto, newDescriptionPhoto.charAt(8))

      newDescriptionPhoto = JSON.parse('{' + newDescriptionPhoto);
      newDescriptionText = JSON.parse('{' + newDescriptionText);

      console.log("Now they should be objects: ", newDescriptionPhoto, newDescriptionText)

      console.log("comparing to old description elements")

      if (this.state.oldDescription !== undefined) {
        let oldDescription = JSON.parse(this.state.oldDescription);
        console.log("Found old description: ", oldDescription.photo, oldDescription.text);
        console.log("New description: ", newDescriptionPhoto, newDescriptionText)
        let tempDescription = Object.assign({}, newDescriptionPhoto, newDescriptionText)
        console.log(tempDescription)
        let newPhoto = { photo: Object.assign({}, oldDescription.photo, tempDescription.photo) }
        console.log(newPhoto)
        let newText = { text: Object.assign({}, oldDescription.text, tempDescription.text) }
        console.log(newText)
        newDescription = Object.assign({}, newPhoto, newText)
        console.log("Payload", newDescription);
      }

      else if (Number(newDescriptionPhoto + newDescriptionText) === 0) {
        return alert("No new data added to payload! Add some data before submission.")
      }

      else {
        console.log("No existing description to compare.");
        newDescription = Object.assign({}, newDescriptionPhoto, newDescriptionText)
        console.log("payload: ", newDescription)
      }

      console.log("Uploading file to IPFS...");
      await window.ipfs.add(JSON.stringify(newDescription), (error, hash) => {
        if (error) {
          console.log("Something went wrong. Unable to upload to ipfs");
        } else {
          console.log("uploaded at hash: ", hash);
        }
        self.setState({ hashPath: getBytes32FromIpfsHash(hash) });
      });
    }

    const _accessAsset = async () => {
      const self = this;
      let oldDescription;

      let idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
      );
      await window.utils.getDescriptionHash(idxHash)

      let rgtRaw = window.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );
      let bytes32refHash = window.descriptionBytes32Hash;
      let refHash = await getIpfsHashFromBytes32(bytes32refHash)

      var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);

      await window.ipfs.cat(refHash, (error, result) => {
        if (error) {
          console.log("Something went wrong. Unable to find file on IPFS");
        } else {
          console.log("IPFS1 Here's what we found: ", result);
          self.setState({ oldDescription: result })
        }
      });

      var doesExist = await window.utils.checkAssetExists(idxHash);
      var infoMatches = await window.utils.checkMatch(idxHash, rgtHash);

      if (!doesExist) {
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      if (!infoMatches) {
        return alert("Owner data fields do not match data on record. Ensure data fields are correct before submission.")
      }

      await this.setState({ idxHash: idxHash })
      await this.setState({ rgtHash: rgtHash })
      return this.setState({ accessPermitted: true })

    }

    const _updateDescription = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })

      var _ipfs1 = this.state.hashPath;

      console.log("idxHash", this.state.idxHash);
      console.log("New rgtHash", this.state.rgtHash);
      console.log("addr: ", window.addr);

      window.contracts.NP.methods
        ._modIpfs1(this.state.idxHash, this.state.rgtHash, _ipfs1)
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
          console.log(receipt.status);
          //Stuff to do when tx confirms
        });

      console.log(this.state.txHash);
      self.setState({ hashPath: "" });
      window.additionalElementArrays.photo = [];
      window.additionalElementArrays.text = [];
      self.setState({ accessPermitted: false });
      self.setState({ oldDescription: undefined });
      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <Form className="MDform" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}{window.assetClass === undefined && (
            <div className="errorResults">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass > 0 && (
            <div>

              <h2 className="Headertext">Modify Description</h2>
              <br></br>
              {!this.state.accessPermitted && (
                <>
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
                    <Form.Group as={Col} controlId="formGridIdNumber">
                      <Form.Label className="formFont">ID Number:</Form.Label>
                      <Form.Control
                        placeholder="ID Number"
                        required
                        onChange={(e) => this.setState({ id: e.target.value })}
                        size="lg"
                      />
                    </Form.Group>

                    <Form.Group as={Col} controlId="formGridPassword">
                      <Form.Label className="formFont">Password:</Form.Label>
                      <Form.Control
                        placeholder="Password"
                        type="password"
                        required
                        onChange={(e) => this.setState({ secret: e.target.value })}
                        size="lg"
                      />
                    </Form.Group>
                  </Form.Row>
                </>
              )}

              {this.state.accessPermitted && (
                <div>
                  <Form.Row>
                    <Form.Group as={Col} controlId="formGridMiscType">
                      <Form.Label className="formFont">
                        Element Type:
                      </Form.Label>
                      <Form.Control
                        as="select"
                        size="lg"
                        onChange={(e) => this.setState({ elementType: e.target.value })}
                      >
                        <option value="0">Select Element Type</option>
                        <option value="text">Add Custom Text</option>
                        <option value="photo">Add Image URL</option>
                        <option value="removeText">Remove Existing Text Element</option>
                        <option value="removePhoto">Remove Existing Image URL</option>

                      </Form.Control>
                    </Form.Group>
                  </Form.Row>
                  {this.state.elementType === "text" && (
                    <>
                      <Form.Row>
                        <Form.Group as={Col} controlId="formGridMiscName">
                          <Form.Label className="formFont">
                            Submission Title:
                      </Form.Label>
                          <Form.Control
                            placeholder="Name This Text Submission (No Spaces)"
                            onChange={(e) => this.setState({ elementName: e.target.value })}
                            size="lg"
                          />
                        </Form.Group>
                      </Form.Row><Form.Row>
                        <Form.Group as={Col} controlId="formGridMiscValue">
                          <Form.Label className="formFont">
                            Text to Submit:
                      </Form.Label>
                          <Form.Control
                            placeholder="Text Submission Goes Here"
                            onChange={(e) => this.setState({ elementValue: e.target.value })}
                            size="lg"
                          />
                        </Form.Group>
                      </Form.Row>
                    </>
                  )}

                  {this.state.elementType === "removePhoto" && (
                    <>
                      <Form.Row>
                        <Form.Group as={Col} controlId="formGridRemovePhoto">
                          <Form.Label className="formFont">
                            Image Name:
                      </Form.Label>
                          <Form.Control
                            placeholder="Name of Image You Wish to Remove"
                            onChange={(e) => this.setState({ removeElement: e.target.value })}
                            size="lg"
                          />
                        </Form.Group>
                      </Form.Row>
                    </>
                  )}

                  {this.state.elementType === "removeText" && (
                    <>
                      <Form.Row>
                        <Form.Group as={Col} controlId="formGridRemoveText">
                          <Form.Label className="formFont">
                            Element Name:
                      </Form.Label>
                          <Form.Control
                            placeholder="Name of Element You Wish to Remove"
                            onChange={(e) => this.setState({ removeElement: e.target.value })}
                            size="lg"
                          />
                        </Form.Group>
                      </Form.Row>
                    </>
                  )}

                  {this.state.elementType === "photo" && (
                    <>
                      <Form.Row>
                        <Form.Group as={Col} controlId="formGridMiscName">
                          <Form.Label className="formFont">
                            Image Title:
                      </Form.Label>
                          <Form.Control
                            placeholder="Name This Image (No Spaces)"
                            onChange={(e) => this.setState({ elementName: e.target.value })}
                            size="lg"
                          />
                        </Form.Group>
                      </Form.Row><Form.Row>
                        <Form.Group as={Col} controlId="formGridMiscValue">
                          <Form.Label className="formFont">
                            Source URL:
                      </Form.Label>
                          <Form.Control
                            placeholder="Image URL"
                            onChange={(e) => this.setState({ elementValue: e.target.value })}
                            size="lg"
                          />
                        </Form.Group>
                      </Form.Row>
                    </>
                  )}
                </div>
              )}

              {!this.state.accessPermitted && (
                <>
                  <Form.Row>
                    <Form.Group className="buttonDisplay">
                      <Button
                        variant="primary"
                        type="button"
                        size="lg"
                        onClick={_accessAsset}
                      >
                        Check Asset
                    </Button>
                    </Form.Group>
                  </Form.Row>
                </>
              )}

              {this.state.hashPath !== "" && this.state.accessPermitted && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={_updateDescription}
                    >
                      Update Description
                    </Button>
                  </Form.Group>
                </Form.Row>
              )}

              {this.state.hashPath === "" && this.state.accessPermitted && this.state.elementType === "0" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={publishIPFS1}
                    >
                      Load to IPFS
                    </Button>
                  </Form.Group>
                  <br></br>
                </Form.Row>

              )}
              {this.state.elementType === "text" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    >
                      Add Element
              </Button>
                  </Form.Group>
                  <br></br>
                </Form.Row>
              )}
              {this.state.elementType === "photo" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    >
                      Add Element
              </Button>
                  </Form.Group>
                  <br></br>
                </Form.Row>
              )}

              {this.state.elementType === "removePhoto" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={() => { _removeElement(this.state.elementType) }}
                    >
                      Remove Element
              </Button>
                  </Form.Group>
                  <br></br>
                </Form.Row>
              )}

              {this.state.elementType === "removeText" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={() => { _removeElement(this.state.elementType) }}
                    >
                      Remove Element
              </Button>
                  </Form.Group>
                  <br></br>
                </Form.Row>
              )}
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

export default ModifyDescription;
