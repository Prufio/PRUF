import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import bs58 from "bs58";
import { ArrowRightCircle, Home, XSquare, CheckCircle, UploadCloud, Trash2 } from 'react-feather'


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

      if (this.state.hashPath !== "" && this.state.runWatchDog === true && window.isInTx !== true) {
        this.updateDescription()
      }

    }, 100)

    this.updateDescription = async () => {
      const self = this

      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      this.setState({ transaction: true })
      window.isInTx = true;

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
          self.setState({ transaction: false });
          console.log(Object.values(_error)[0].transactionHash);
          window.isInTx = false

          if (this.state.wasSentPacket) {
            return window.location.href = '/#/asset-dashboard'
          }
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          self.setState({ transaction: false });
          console.log(receipt.status);
          window.resetInfo = true;
          window.isInTx = false
          //Stuff to do when tx confirms
        });

      console.log(this.state.txHash);
      self.setState({ hashPath: "", count: 1, textCount: 1, imageCount: 1 });
      window.additionalElementArrays.photo = [];
      window.additionalElementArrays.text = [];
      window.additionalElementArrays.name = "";
      //self.setState({ accessPermitted: false });
      //self.setState({ oldDescription: undefined });
      return document.getElementById("MainForm").reset(),
      this.setState({
        idxHash: undefined, txStatus: undefined, txHash: "", elementType: 0, wasSentPacket: false
      });
    };

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
      idxHash: undefined,
      elementType: 0,
      elementName: "",
      elementValue: "",
      nameTag: "",
      hasLoadedAssets: false,
      assets: { descriptions: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] },
      imageCount: 1,
      textCount: 1,
      count: 1,
      transaction: false,
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
      if (Number(window.sentPacket.status) === 3 || Number(window.sentPacket.status) === 4 || Number(window.sentPacket.status) === 53 || Number(window.sentPacket.status) === 54) {
        alert("Cannot edit asset in lost or stolen status");
        window.sentpacket = undefined;
        return window.location.href = "/#/asset-dashboard"
      }

      if (Number(window.sentPacket.status) === 50 || Number(window.sentPacket.status) === 56) {
        alert("Cannot edit asset in escrow! Please wait until asset has met escrow conditions");
        window.sentpacket = undefined;
        return window.location.href = "/#/asset-dashboard"
      }
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


    this.setState({ runWatchDog: true })
  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ idxHash: undefined, txStatus: undefined, txHash: "", elementType: 0, wasSentPacket: false })
    }

    const _addToMiscArray = async (type) => {
      let element;
      let elementName = this.state.elementName;
      let elementValue = this.state.elementValue;

      if (type === "description") {
        element = ('"description": ' + '"' + this.state.elementValue + '",')
        this.setState({ textCount: this.state.textCount + 1, count: this.state.count + 1 })
      }

      else if (type === "displayImage") {
        element = ('"displayImage": ' + '"' + this.state.elementValue + '",')
        this.setState({ imageCount: this.state.imageCount + 1, count: this.state.count + 1 })
      }

      else if (elementName === "" && type === "photo") {
        element = ('"Image' + (String(Object.values(this.state.oldDescription.photo).length + this.state.count)) + '"' + ':' + '"' + this.state.elementValue + '",')
        this.setState({ imageCount: this.state.imageCount + 1, count: this.state.count + 1 })
      }

      else if (elementName === "" && type === "text") {
        element = ('"Text' + (String(Object.values(this.state.oldDescription.text).length + this.state.count)) + '"' + ':' + '"' + this.state.elementValue + '",')
        this.setState({ textCount: this.state.textCount + 1, count: this.state.count + 1 })
      }

      else {
        elementName.replace(" ", "_");
        for (let i = 0; i < elementName.length; i++) {
          if (elementName.charAt(i) === "'") {
            return alert(" Use of character: ' " + elementName.charAt(i) + " ' not allowed!")
          }

          if (elementName.charAt(i) === '"') {
            return alert(" Use of character: ' " + elementName.charAt(i) + " ' not allowed!")
          }
        }
        for (let i = 0; i < elementName.length; i++) {
          if (elementValue.charAt(i) === "'") {
            return alert(" Use of character: ' " + elementValue.charAt(i) + "at position" + String(i) + " ' not allowed!")
          }

          if (elementValue.charAt(i) === '"') {
            return alert(" Use of character: ' " + elementValue.charAt(i) + "at position" + String(i) + " ' not allowed!")
          }
        }
        element = ('"' + elementName + '": ' + '"' + this.state.elementValue + '",')
      }


      if (this.state.elementValue === "" && this.state.elementName === "" && this.state.nameTag === "") {
        return alert("All fields are required for submission")
      }
      if (type === "photo" || type === "displayImage") {
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
          hashPath: window.utils.getBytes32FromIPFSHash(hash),
          oldDescription: newDescription
        });
      });
    }

    const _checkIn = async (e) => {
      this.setState({
        txStatus: false,
        txHash: ""
      })
      if (e === "null" || e === undefined) {
        return clearForm()
      }
      else if (e === "reset") {
        return window.resetInfo = true;
      }
      else if (e === "assetDash") {
        return window.location.href = "/#/asset-dashboard"
      }

      let resArray = await window.utils.checkStats(window.assets.ids[e], [0, 2])

      console.log(resArray)

      if (Number(resArray[1]) === 0) {
        alert("Asset does not exist at given IDX");
      }

      if (Number(resArray[0]) === 54 || Number(resArray[0]) === 53) {
        alert("Cannot edit asset in lost or stolen status"); return clearForm()
      }

      if (Number(resArray[0]) === 50 || Number(resArray[0]) === 56) {
        alert("Cannot edit asset in escrow! Please wait until asset has met escrow conditions"); return clearForm()
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
        note: window.assets.notes[e]
      })
    }

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
                    {this.state.transaction === false && (
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
                            <optgroup className="optgroup">
                              <option value="0">Select Element Type</option>
                              <option value="nameTag"> Edit Name Tag</option>
                              <option value="description">Edit Description</option>
                              <option value="displayImage">Edit Profile Image</option>
                              <option value="text">Add Custom Text</option>
                              <option value="photo">Add Custom Image URL</option>
                              <option value="removeText">Remove Existing Text Element</option>
                              <option value="removePhoto">Remove Existing Image Element</option>
                            </optgroup>

                          </Form.Control>
                        </Form.Group>
                      </Form.Row>
                    )}
                    {this.state.transaction === true && (
                      <Form.Row>
                        <Form.Group as={Col} controlId="formGridMiscType">
                          <Form.Label className="formFont">
                            Element Type:
                        </Form.Label>
                          <Form.Control
                            as="select"
                            size="lg"
                            onChange={(e) => this.setState({ elementType: e.target.value })}
                            disabled
                          >
                            <optgroup className="optgroup">
                              <option value="0">Select Element Type</option>
                              <option value="nameTag"> Edit Name Tag</option>
                              <option value="description">Edit Description</option>
                              <option value="displayImage">Edit Profile Image</option>
                              <option value="text">Add Custom Text</option>
                              <option value="photo">Add Custom Image URL</option>
                              <option value="removeText">Remove Existing Text Element</option>
                              <option value="removePhoto">Remove Existing Image Element</option>
                            </optgroup>

                          </Form.Control>
                        </Form.Group>
                      </Form.Row>
                    )}
                    {this.state.elementType === "text" && (
                      <>
                        <Form.Row>
                          <Form.Group as={Col} controlId="formGridMiscName">
                            <Form.Label className="formFont">
                              Submission Title:
                        </Form.Label>
                            <Form.Control
                              placeholder="Name This Text Submission"
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

                    {this.state.elementType === "displayImage" && (
                      <>
                        <Form.Row>
                          <Form.Group as={Col} controlId="formGridMiscValue">
                            <Form.Label className="formFont">
                              Image Source URL:
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

                {this.state.hashPath === "" && this.state.accessPermitted && this.state.transaction === false && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <CheckCircle
                          onClick={() => { publishIPFS1() }}
                        />
                      </div>
                    </div>
                  </Form.Row>

                )}

                {this.state.elementType === "text" && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <UploadCloud
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "photo" && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <UploadCloud
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "description" && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <UploadCloud
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "nameTag" && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <UploadCloud
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "displayImage" && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <UploadCloud
                          onClick={() => { _addToMiscArray(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "removePhoto" && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <Trash2
                          onClick={() => { _removeElement(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}

                {this.state.elementType === "removeText" && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <Trash2
                          onClick={() => { _removeElement(this.state.elementType) }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                )}
              </div>
            )}
          </Form>
          {this.state.transaction === false && this.state.txHash === "" && (
            <div className="assetSelectedResults">
              <Form.Row>
                {this.state.idxHash !== undefined && this.state.txHash === "" && (
                  <Form.Group>
                    <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                    <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                    <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                    <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
                    {this.state.count > 1 && (
                      <div>
                        {window.utils.generateNewElementsPreview(window.additionalElementArrays)}
                      </div>
                    )}
                  </Form.Group>
                )}
              </Form.Row>
            </div>
          )}
          {this.state.transaction === true && (
            <div className="Results">
              <p className="loading">Transaction In Progress</p>
            </div>
          )}
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
                  {this.state.transaction === false && (
                    <Form.Row>
                      <Form.Group as={Col} controlId="formGridAsset">
                        <Form.Label className="formFont"> Select an Asset to Modify :</Form.Label>
                        <Form.Control
                          as="select"
                          size="lg"
                          onChange={(e) => { _checkIn(e.target.value) }}
                        >
                          {this.state.hasLoadedAssets && (
                            <optgroup className="optgroup">

                              {window.utils.generateAssets()}
                            </optgroup>)}
                          {!this.state.hasLoadedAssets && (<optgroup ><option value="null"> Loading Assets... </option></optgroup>)}
                        </Form.Control>
                      </Form.Group>
                    </Form.Row>
                  )}
                  {this.state.transaction === true && (
                    <Form.Row>
                      <Form.Group as={Col} controlId="formGridAsset">
                        <Form.Label className="formFont"> Select an Asset to Modify :</Form.Label>
                        <Form.Control
                          as="select"
                          size="lg"
                          onChange={(e) => { _checkIn(e.target.value) }}
                          disabled
                        >
                          {this.state.hasLoadedAssets && (
                            <optgroup className="optgroup">

                              {window.utils.generateAssets()}
                            </optgroup>)}
                          {!this.state.hasLoadedAssets && (<optgroup ><option value="null"> Loading Assets... </option></optgroup>)}
                        </Form.Control>
                      </Form.Group>
                    </Form.Row>
                  )}
                  {this.state.transaction === false && (
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
                          <optgroup className="optgroup">
                            <option value="0">Select Element Type</option>
                            <option value="nameTag"> Edit Name Tag</option>
                            <option value="description">Edit Description</option>
                            <option value="displayImage">Edit Profile Image</option>
                            <option value="text">Add Custom Text</option>
                            <option value="photo">Add Custom Image URL</option>
                            <option value="removeText">Remove Existing Text Element</option>
                            <option value="removePhoto">Remove Existing Image Element</option>
                          </optgroup>

                        </Form.Control>
                      </Form.Group>
                    </Form.Row>
                  )}
                  {this.state.transaction === true && (
                    <Form.Row>
                      <Form.Group as={Col} controlId="formGridMiscType">
                        <Form.Label className="formFont">
                          Element Type:
                        </Form.Label>
                        <Form.Control
                          as="select"
                          size="lg"
                          onChange={(e) => this.setState({ elementType: e.target.value })}
                          disabled
                        >
                          <optgroup className="optgroup">
                            <option value="0">Select Element Type</option>
                            <option value="nameTag"> Edit Name Tag</option>
                            <option value="description">Edit Description</option>
                            <option value="displayImage">Edit Profile Image</option>
                            <option value="text">Add Custom Text</option>
                            <option value="photo">Add Custom Image URL</option>
                            <option value="removeText">Remove Existing Text Element</option>
                            <option value="removePhoto">Remove Existing Image Element</option>
                          </optgroup>

                        </Form.Control>
                      </Form.Group>
                    </Form.Row>
                  )}
                  {this.state.elementType === "0" && (
                    <></>
                  )}
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

              {this.state.hashPath === "" && this.state.accessPermitted && this.state.transaction === false && (
                <div className="submitButton">
                  <div className="submitButton-content">
                    <CheckCircle
                      onClick={() => { publishIPFS1() }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "text" && (
                <div className="submitButton">
                  <div className="submitButton-content">
                    <UploadCloud
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "photo" && (
                <div className="submitButton">
                  <div className="submitButton-content">
                    <UploadCloud
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "description" && (
                <div className="submitButton">
                  <div className="submitButton-content">
                    <UploadCloud
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "nameTag" && (
                <div className="submitButton">
                  <div className="submitButton-content">
                    <UploadCloud
                      onClick={() => { _addToMiscArray(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "removePhoto" && (
                <div className="submitButton">
                  <div className="submitButton-content">
                    <Trash2
                      onClick={() => { _removeElement(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}

              {this.state.elementType === "removeText" && (
                <div className="submitButton">
                  <div className="submitButton-content">
                    <Trash2
                      onClick={() => { _removeElement(this.state.elementType) }}
                    />
                  </div>
                </div>
              )}
            </div>
          )}
        </Form>
        {this.state.transaction === false && this.state.txHash === "" && (
          <div className="assetSelectedResults">
            <Form.Row>
              {this.state.idxHash !== undefined && this.state.txHash === "" && (
                <Form.Group>
                  <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                  <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                  <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                  <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
                  {this.state.count > 1 && (
                    <div>
                      {window.utils.generateNewElementsPreview(window.additionalElementArrays)}
                    </div>
                  )}
                </Form.Group>
              )}
            </Form.Row>
          </div>
        )}
        {this.state.transaction === true && (
          <div className="Results">
            <p className="loading">Transaction In Progress</p>
          </div>
        )}
        {this.state.txHash > 0 && ( //conditional rendering
          <div className="Results">
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
          </div>
        )}

      </div>
    );
  }
}

export default ModifyDescription;
