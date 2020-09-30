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

    this.updateAssets = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }

      if (this.state.hasLoadedAssets !== window.hasLoadedAssets) {
        this.setState({ hasLoadedAssets: window.hasLoadedAssets })
      }
    }, 100)

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
      accessPermitted: true,
      idxHash: "",
      elementType: 0,
      elementName: "",
      elementValue: "",
      nameTag: "",
      hasLoadedAssets: false,
      assets: { descriptions: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] },

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
      let element;
      if (type === "description") {
        element = ('"description": ' + '"' + this.state.elementValue + '",')
      }

      else if(this.state.elementName === ""){
        element = ('"0x0": ' + '"' + this.state.elementValue + '",')
      }

      else if(this.state.elementName === ""){
        element = ('"0x0": ' + '"' + this.state.elementValue + '",')
      }

      else {
        element = ('"' + this.state.elementName + '": ' + '"' + this.state.elementValue + '",')
      }


      if (this.state.elementValue === "" && this.state.elementName === "" && this.state.nameTag === "") {
        return alert("All fields are required for submission")
      }
      if (type === "photo") {
        window.additionalElementArrays.photo.push(element)
      }
      else if (type === "text" || type === "description") {
        window.additionalElementArrays.text.push(element)
      }

      else if (type === "nameTag") {
        window.additionalElementArrays.name = this.state.nameTag
      }

      else { return alert("Please use the dropdown menu to select an element type") }

      console.log("Added", element, "to element array")
      console.log("Which now looks like: ", window.additionalElementArrays)
      this.setState({ elementType: "0", hashPath: "" })
      return document.getElementById("MainForm").reset();
    }

    const _removeElement = async (type) => {

      console.log("Existing description before edits: ", this.state.oldDescription)
      let element = (this.state.removeElement)
      let oldDescription = this.state.oldDescription;

      if (this.state.element === "" && this.state.nameTag === "") {
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
      this.setState({
        oldDescription: oldDescription,
        hashPath: ""
      })
      this.setState({ elementType: "0" })
      return document.getElementById("MainForm").reset();

    }

    const publishIPFS1 = async () => {
      console.log(this.state.oldDescription)
      let newDescription;

      let newDescriptionName;

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

      if (window.additionalElementArrays.name === "") {
        newDescriptionName = {}
      }
      /* else if (window.additionalElementArrays.name === "" && this.state.oldDescription.name !== undefined){
        newDescriptionName = this.state.oldDescription.name
        console.log(newDescriptionName)
      } */
      else {
        newDescriptionName = { name: window.additionalElementArrays.name }
      }

      console.log("Now they should be objects: ", newDescriptionPhoto, newDescriptionText, newDescriptionName)

      console.log("comparing to old description elements")

      if (this.state.oldDescription !== undefined && this.state.oldDescription !== "0") {
        let oldDescription = this.state.oldDescription;
        console.log("Found old description: ", oldDescription.photo, oldDescription.text);
        console.log("New description: ", newDescriptionPhoto, newDescriptionText)
        console.log("Old nameTag: ", oldDescription.name)
        if (oldDescription.name === undefined) { oldDescription.name = {} }
        let tempDescription = Object.assign({}, newDescriptionPhoto, newDescriptionText, newDescriptionName)
        console.log(tempDescription)
        let newPhoto = { photo: Object.assign({}, oldDescription.photo, tempDescription.photo) }
        console.log(newPhoto)
        let newText = { text: Object.assign({}, oldDescription.text, tempDescription.text) }
        console.log(newText)
        let test = Object.assign({}, oldDescription, tempDescription)
        console.log(test)
        let newName = Object.assign({}, { name: oldDescription.name }, newDescriptionName)

        console.log(newName)
        newDescription = Object.assign({}, newPhoto, newText, newName)
        console.log("Payload", newDescription);
      }

      else if (Number(newDescriptionPhoto + newDescriptionText) === 0) {
        return alert("No new data added to payload! Add some data before submission.")
      }

      else {
        console.log("No existing description to compare.");
        newDescription = Object.assign({}, newDescriptionPhoto, newDescriptionText, newDescriptionName)
        console.log("payload: ", newDescription)
      }

      console.log("Uploading file to IPFS...");
      await window.ipfs.add(JSON.stringify(newDescription), (error, hash) => {
        if (error) {
          console.log("Something went wrong. Unable to upload to ipfs");
        } else {
          console.log("uploaded at hash: ", hash);
        }
        self.setState({
          hashPath: getBytes32FromIpfsHash(hash),
          oldDescription: newDescription
        });
      });
    }

    const _checkIn = async (e) => {
      if (e === "0" || e === undefined) { return }
      else if (e === "reset") {
        return window.resetInfo = true;
      }
      this.setState({ selectedAsset: e })
      console.log("Changed component idx to: ", window.assets.ids[e])

      this.setState({
        assetClass: window.assets.assetClasses[e],
        idxHash: window.assets.ids[e],
        name: window.assets.descriptions[e].name,
        photos: window.assets.descriptions[e].photo,
        text: window.assets.descriptions[e].text,
        oldDescription: window.assets.descriptions[e],
        status: window.assets.statuses[e],
      })
    }

    const _updateDescription = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })

      var _ipfs1 = this.state.hashPath;

      console.log("idxHash", this.state.idxHash);
      console.log("addr: ", window.addr);

      window.contracts.NP_NC.methods
        ._modIpfs1(this.state.idxHash, _ipfs1)
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
          window.resetInfo = true;
          //Stuff to do when tx confirms
        });

      console.log(this.state.txHash);
      self.setState({ hashPath: "" });
      window.additionalElementArrays.photo = [];
      window.additionalElementArrays.text = [];
      window.additionalElementArrays.name = "";
      //self.setState({ accessPermitted: false });
      //self.setState({ oldDescription: undefined });
      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>

              <h2 className="Headertext">Modify Description</h2>
              <br></br>
              {this.state.accessPermitted && (
                <div>
                  <Form.Row>
                    <Form.Group as={Col} controlId="formGridAsset">
                      <Form.Label className="formFont"> Select an Asset to Modify :</Form.Label>
                      <Form.Control
                        as="select"
                        size="lg"
                        onChange={(e) => { _checkIn(e.target.value) }}
                      >
                        {this.state.hasLoadedAssets && (<><option value="null"> Select an asset </option><option value="reset">Refresh Assets</option>{window.utils.generateAssets()}</>)}
                        {!this.state.hasLoadedAssets && (<option value="null"> Loading Assets... </option>)}

                      </Form.Control>
                    </Form.Group>
                  </Form.Row>
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
                        <option value="nameTag"> Edit Name Tag</option>
                        <option value="description">Edit Description</option>
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

                  {this.state.elementType === "description" && (
                    <>
                      <Form.Row>
                        <Form.Group as={Col} controlId="formGridMiscValue">
                          <Form.Label className="formFont">
                            Description Text:
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

                  {this.state.elementType === "nameTag" && (
                    <>
                      <Form.Row>
                        <Form.Group as={Col} controlId="formGridNameTag">
                          <Form.Label className="formFont">
                            New Name Tag:
                      </Form.Label>
                          <Form.Control
                            placeholder="Type a New NameTag"
                            onChange={(e) => this.setState({ nameTag: e.target.value })}
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

              {this.state.hashPath !== "" && this.state.accessPermitted && (
                <Form.Row>
                  <Form.Group >
                    <Button className="buttonDisplay"
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
                  <Form.Group >
                    <Button className="buttonDisplay"
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
                  <Form.Group>
                    <Button className="buttonDisplay"
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
                  <Form.Group>
                    <Button className="buttonDisplay"
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

              {this.state.elementType === "description" && (
                <Form.Row>
                  <Form.Group>
                    <Button className="buttonDisplay"
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

              {this.state.elementType === "nameTag" && (
                <Form.Row>
                  <Form.Group>
                    <Button className="buttonDisplay"
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
                  <Form.Group>
                    <Button className="buttonDisplay"
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
                  <Form.Group>
                    <Button className="buttonDisplay"
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
