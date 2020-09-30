import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";


class RetrieveRecord extends Component {
  constructor(props) {
    super(props);
      
      this.updateAssets = setInterval(() => {
        if (this.state.ipfsObject !== undefined && this.state.runWatchDog === true && this.state.assetObj === undefined) {
          let tempIPFS = this.state.ipfsObject;
          console.log(tempIPFS)
          this.setState({
            assetObj: {
            idxHash: this.state.idxHash,
            name: tempIPFS.name,
            assetClass: window.assetInfo.assetClass,
            status: window.assetInfo.status,
            description: tempIPFS.text.description,
            text: tempIPFS.text,
            photo: tempIPFS.photo,
            
            }, selectedImage: tempIPFS.photo.displayImage, moreInfo: true})
        }

      }, 100)
    //State declaration.....................................................................................................

    this.getIPFSJSONObject = (lookup) => {
      //console.log(lookup)
      window.ipfs.cat(lookup, async (error, result) => {
        if (error) {
          console.log(lookup, "Something went wrong. Unable to find file on IPFS");
          return this.setState({ipfsObject: undefined})
        } else {
          console.log(lookup, "Here's what we found for asset description: ", result);
          return this.setState({ipfsObject: JSON.parse(result)})
        }
      });
    };

    this.generateAssetInfo = (obj) => {
      let images = Object.values(obj.photo)
      let text = Object.values(obj.text)
      let imageNames = Object.keys(obj.photo)
      let textNames = Object.keys(obj.text)

      const showImage = (e) => {
        console.log(this.state.selectedImage)
        console.log(e)
        this.setState({selectedImage: e})
      }

      const openPhotoNT = (url) => {
        const newWindow = window.open(url, '_blank', 'noopener,noreferrer')
        if (newWindow) {newWindow.opener = null}
      }

      const generateThumbs = () => {
        let component = [];
        
        for(let i = 0; i < images.length; i++){
          component.push(
            <button value={images[i]} class="assetImageButton" onClick={()=>{showImage(images[i])}}>
            <img src={images[i]} className="imageSelectorImage" />
            </button>
          )
        }

        return component

      }

      const generateTextList = () => {
        let component = [];
        
        for(let i = 0; i < text.length; i++){
          component.push(
            <>
            <h4 class="card-description-selected">{textNames[i]}: {text[i]}</h4>
            <br />
            </>
          )
        }

        return component
      }

      return (
        <div className="assetDashboardSelected">
          <style type="text/css"> {`
  
              .card {
                width: 100%;
                max-width: 100%;
                height: 50rem;
                max-height: 100%;
                background-color: #005480;
                margin-top: 0.3rem;
                color: white;
                word-break: break-all;
              }
  
            `}
          </style>
          <div class="card" value="100">
            <div class="row no-gutters">
              <div className="assetSelecedInfo">
                <button class="assetImageButton" onClick={()=>{openPhotoNT(this.state.selectedImage)}}>
                  <img src={this.state.selectedImage} className="assetImageSelected" />
                </button>
                <p class="card-name-selected">Name : {obj.name}</p>
                <p class="card-ac-selected">Asset Class : {obj.assetClass}</p>
                <p class="card-status-selected">Status : {obj.status}</p>
                <div className="imageSelector">
                  {generateThumbs()}
                </div>
                <div className="cardDescription-selected">
                  {generateTextList()}
                </div>
              </div>
              <div className="cardButton-selected">
                {this.state.moreInfo && (
                  <Button
                    variant="primary"
                    onClick={()=>{this.setState({moreInfo: false, ipfsObject: undefined, assetObj: undefined})}}
                  >
                    New Search
                  </Button>
                )}

              </div>
            </div>
          </div >
        </div >


      )
    }

    this.handlePacket = async () => {
      let idxHash = window.sentPacket;

      this.setState({ 
        idxHash: window.sentPacket.idxHash, 
        wasSentPacket: true, 
        name: window.sentPacket.name, 
        assetClass: window.sentPacket.assetClass })

      window.sentPacket = undefined;
      let hash;
      let assetClass;
      let status;

      await window.contracts.STOR.methods.retrieveShortRecord(idxHash)
        .call({ from: window.addr }, (_error, _result) => {
          if (_error) {
            console.log("IN ERROR IN ERROR IN ERROR")
          } else {
            if (Number(Object.values(_result)[5]) > 0) {
              hash = Object.values(_result)[5]

            }
            else {
              return hash = "0"
            }
            assetClass = Object.values(_result)[2]
            status = Object.values(_result)[0]
          }
        })
      
      return this.getIPFSJSONObject(window.utils.getIpfsHashFromBytes32(hash))

    }

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      hashPath: "",
      error: undefined,
      NRerror: undefined,
      result: [],
      assetClass: undefined,
      ipfs1: "",
      ipfs2: "",
      txHash: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      status: "",
      assetObj: undefined,
      wasSentPacket: false,
      ipfsObject: undefined,
      showDescription: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

    if (window.sentPacket !== undefined) {

      this.handlePacket()
    }

    this.setState({runWatchDog: true})


  }

  componentDidUpdate() {//stuff to do when state updates


  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _retrieveRecord = async () => {
      const self = this;
      var ipfsHash;
      var tempResult;

      let idxHash = window.web3.utils.soliditySha3(
        String(this.state.type),
        String(this.state.manufacturer),
        String(this.state.model),
        String(this.state.serial),
      );

      this.setState({idxHash: idxHash})

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      await window.contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call({ from: window.addr }, function (_error, _result) {
          if (_error) {
            console.log(_error)
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            if (Object.values(_result)[0] === '0') { self.setState({ status: 'No status set' }); }
            else if (Object.values(_result)[0] === '1') { self.setState({ status: 'Transferrable' }); }
            else if (Object.values(_result)[0] === '2') { self.setState({ status: 'Non-transferrable' }); }
            else if (Object.values(_result)[0] === '3') { self.setState({ status: 'REPORTED STOLEN' }); }
            else if (Object.values(_result)[0] === '4') { self.setState({ status: 'REPORTED LOST' }); }
            else if (Object.values(_result)[0] === '5') { self.setState({ status: 'Asset in Transfer' }); }
            else if (Object.values(_result)[0] === '6') { self.setState({ status: 'In escrow (block.number locked)' }); }
            else if (Object.values(_result)[0] === '7') { self.setState({ status: 'Out of supervised escrow' }); }
            else if (Object.values(_result)[0] === '50') { self.setState({ status: 'In Locked Escrow (block.number locked)' }); }
            else if (Object.values(_result)[0] === '51') { self.setState({ status: 'Transferable' }); }
            else if (Object.values(_result)[0] === '52') { self.setState({ status: 'Non-transferrable' }); }
            else if (Object.values(_result)[0] === '53') { self.setState({ status: 'REPORTED STOLEN' }); }
            else if (Object.values(_result)[0] === '54') { self.setState({ status: 'REPORTED LOST' }); }
            else if (Object.values(_result)[0] === '55') { self.setState({ status: 'Asset in Transfer' }); }
            else if (Object.values(_result)[0] === '56') { self.setState({ status: 'In escrow (block.number locked)' }); }
            else if (Object.values(_result)[0] === '57') { self.setState({ status: 'Out of supervised escrow' }); }
            else if (Object.values(_result)[0] === '58') { self.setState({ status: 'Out of locked escrow' }); }
            else if (Object.values(_result)[0] === '59') { self.setState({ status: 'Discardable' }); }
            else if (Object.values(_result)[0] === '60') { self.setState({ status: 'Recycleable' }); }
            else if (Object.values(_result)[0] === '70') { self.setState({ status: 'Importable' }); }
            self.setState({ result: Object.values(_result) })
            self.setState({ error: undefined });
            tempResult = Object.values(_result);
            if (Object.values(_result)[5] > 0) { ipfsHash = window.utils.getIpfsHashFromBytes32(Object.values(_result)[5]); }
            console.log("ipfs data in promise", ipfsHash)
            if (Object.values(_result)[6] > 0) {
              console.log("Getting ipfs2 set up...")
              let knownUrl = "https://ipfs.io/ipfs/";
              let hash = String(window.utils.getIpfsHashFromBytes32(Object.values(_result)[6]));
              let fullUrl = knownUrl + hash;
              console.log(fullUrl);
              self.setState({ ipfs2: fullUrl });
            }
          }
        });

      window.assetClass = tempResult[2]

      window.assetInfo = {
        assetClass: tempResult[2],
        status: tempResult[0],
        idx: idxHash
      }
      await window.utils.resolveACFromID()
      await window.utils.getACData("id", window.assetClass)

      console.log(window.authLevel);

      await this.getIPFSJSONObject(ipfsHash);
      
      return this.setState({ authLevel: window.authLevel })
    }

    if (this.state.wasSentPacket === true) {
      return (
        <div>
        <div>
          <h2 className="assetDashboardHeader">Here's what we found: </h2>
        </div>
        <div className="assetDashboard">
          {this.state.assetObj !== undefined && (<>{this.generateAssetInfo(this.state.assetObj)}</>)}
          {this.state.assetObj === undefined && (<h4 className = "loading">Loading Asset</h4>)}
        </div>
        <div className="assetDashboardFooter">
        </div>
      </div >
      )
    }

    else {
      return (
          <>
            {window.addr === undefined && (
              <Form className="Form">
              <div className="errorResults">
                <h2>User address unreachable</h2>
                <h3>Please connect web3 provider.</h3>
              </div>
              </Form>
            )}
            {window.addr > 0 && !this.state.moreInfo && (
              <Form className="Form">
              <div>
                <h2 className="Headertext">Search Assets</h2>
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
                    <Form.Group>
                      <Button className="buttonDisplay"
                        variant="primary"
                        type="button"
                        size="lg"
                        onClick={_retrieveRecord}
                      >
                        Submit
                </Button>
                    </Form.Group>
                </Form.Row>
              </div>
              </Form>
            )}
          
          {this.state.result[2] === "0" && (
            <div className="RRresultserr">No Asset Found for Given Data</div>
          )}

          {this.state.moreInfo && ( //conditional rendering
            <div>
            <div>
              <h2 className="assetDashboardHeader">Here's what we found: </h2>
            </div>
            <div className="assetDashboard">
              {this.state.assetObj !== undefined && (<>{this.generateAssetInfo(this.state.assetObj)}</>)}
              {this.state.assetObj === undefined && (<h4 className = "loading">Loading Asset</h4>)}
            </div>
            <div className="assetDashboardFooter">
            </div>
            </div >
          )}
          </>
      );
    }
  }
}

export default RetrieveRecord;
