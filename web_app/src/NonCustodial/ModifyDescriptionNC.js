import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import bs58 from "bs58";
import { ArrowRightCircle, Home, XSquare } from 'react-feather'


class ModifyDescription extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.updateAssets = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }

      if (this.state.hasLoadedAssets !== window.hasLoadedAssets && this.state.runWatchDog === true) {
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
      count: 1,
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
    if (window.sentPacket !== undefined) {
      this.setState({
        name: window.sentPacket.name,
        idxHash: window.sentPacket.idxHash,
        assetClass: window.sentPacket.assetClass,
        status: window.sentPacket.status,
        oldDescription: window.sentPacket.descriptionObj,
        wasSentPacket: true,
        
      })
      window.sentPacket = undefined
    }


    this.setState({runWatchDog: true})
  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ idxHash: undefined, txStatus: undefined, txHash: "0" })
    }

    const getBytes32FromIpfsHash = (ipfsListing) => {
      return "0x" + bs58.decode(ipfsListing).slice(2).toString("hex");
    };

    const _addToMiscArray = async (type) => {
      let element;
      if (type === "description") {
        element = ('"description": ' + '"' + this.state.elementValue + '",')
      }

      else if (this.state.elementName === "") {
        element = ('"Image' + (String(Object.values(this.state.oldDescription.photo).length + this.state.count)) + '"' + ':' + '"' + this.state.elementValue + '",')
        this.setState({ count: this.state.count + 1 })
      }

      else {
        element = ('"' + this.state.elementName + '": ' + '"' + this.state.elementValue + '",')
      }


      if (this.state.elementValue === "" && this.state.elementName === "" && this.state.nameTag === "") {
        return alert("All fields are required for submission")
      }
      if (type === "photo") {
        console.log("Pushing photo element: ", element)
        window.additionalElementArrays.photo.push(element)
      }
      else if (type === "text" || type === "description") {
        console.log("Pushing text element: ", element)
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
          window.location.href = '/#/check-in'
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
    if (this.state.wasSentPacket) {
      return (
        <div>
          <div>
            <div className="mediaLinkAD-home">
              <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
            </div>
            <h2 className="FormHeader">Modify Description</h2>
            <div className="mediaLink-clearForm">
              <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { clearForm() }} /></a>
            </div>
          </div>
          <Form className="Form" id='MainForm'>
            {window.addr === undefined && (
              <div className="errorResults">
                <h2>User address unreachable</h2>
                <h3>Please connect web3 provider.</h3>
              </div>
            )}
            {window.addr > 0 && (
              <div>
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
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { _updateDescription() }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.hashPath === "" && this.state.accessPermitted && this.state.elementType === "0" && (
                  <Form.Row>
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { publishIPFS1() }}
                        />
                      </div>
                    </div>
                  </Form.Row>

                )}
                {this.state.elementType === "text" && (
                  <Form.Row>
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}
                {this.state.elementType === "photo" && (
                  <Form.Row>
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "description" && (
                  <Form.Row>
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "nameTag" && (
                  <Form.Row>
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "removePhoto" && (
                  <Form.Row>
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { _removeElement(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "removeText" && (
                  <Form.Row>
                    <div className="submitButtonMD">
                      <div className="submitButtonMD-content">
                        <ArrowRightCircle
                          onClick={() => { _removeElement(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}
              </div>
            )}
          </Form>
          <div className="assetSelectedResults">
          <Form.Row>
            {this.state.idxHash !== undefined && (
              <Form.Group>
                <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                {/* <div className="assetSelectedContentHead"> Asset Description: <span className="assetSelectedContent">{this.state.description}</span> </div> */}
                <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
              </Form.Group>
            )}
          </Form.Row>
        </div>
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
    return (
      <div>
        <div>
          <div className="mediaLinkAD-home">
            <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
          </div>
          <h2 className="FormHeader">Modify Description</h2>
          <div className="mediaLink-clearForm">
            <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { clearForm() }} /></a>
          </div>
        </div>
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="Results">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              {this.state.accessPermitted && (
                <div>
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
                  {this.state.elementType === "text" && (
                    <>
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
                    </>
                  )}

                  {this.state.elementType === "description" && (
                    <>
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
                    </>
                  )}

                  {this.state.elementType === "removePhoto" && (
                    <>
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
                    </>
                  )}

                  {this.state.elementType === "nameTag" && (
                    <>
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
                    </>
                  )}

                  {this.state.elementType === "removeText" && (
                    <>
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
                    </>
                  )}

                  {this.state.elementType === "photo" && (
                    <>
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
                    </>
                  )}
                </div>
              )}

              {this.state.hashPath !== "" && this.state.accessPermitted && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { _updateDescription() }}
                    />
                  </div>
                </div>
              )}

              {this.state.hashPath === "" && this.state.accessPermitted && this.state.elementType === "0" && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { publishIPFS1() }}
                    />
                  </div>
                </div>

              )}
              {this.state.elementType === "text" && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}
              {this.state.elementType === "photo" && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "description" && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "nameTag" && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "removePhoto" && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { _removeElement(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "removeText" && (
                <div className="submitButtonMD">
                  <div className="submitButtonMD-content">
                    <ArrowRightCircle
                      onClick={() => { _removeElement(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}
            </div>
          )}
        </Form>
        <div className="assetSelectedResults">
          <Form.Row>
            {this.state.idxHash !== undefined && (
              <Form.Group>
                <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                {/* <div className="assetSelectedContentHead"> Asset Description: <span className="assetSelectedContent">{this.state.description}</span> </div> */}
                <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
              </Form.Group>
            )}
          </Form.Row>
        </div>
        <div className="Results">
          {this.state.txHash > 0 && ( //conditional rendering
            <Form.Row>
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
            </Form.Row>
          )}
        </div>
      </div>
    );
  }
}

export default ModifyDescription;
