import bs58 from "bs58";
import Button from "react-bootstrap/Button";
import { QRCode } from 'react-qrcode-logo';
import React, { useRef } from 'react';
import { useReactToPrint } from 'react-to-print';
import "./../index.css";

function buildWindowUtils() {

  //UTIL_TKN.methods.currentACtokenInfo

  const _tenThousandHashesOf = (varToHash, web3) => {
    var tempHash = varToHash;
    for (var i = 0; i < 10000; i++) {
      tempHash = web3.utils.soliditySha3(tempHash);
      console.log(tempHash);
    }
    return tempHash;
  }

  const _getBytes32FromIPFSHash = (hash) => {
    return "0x" + bs58.decode(hash).slice(2).toString("hex");
  };

  const _getIpfsHashFromBytes32 = (bytes32Hex) => {

    // Add our default ipfs values for first 2 bytes:
    // function:0x12=sha2, size:0x20=256 bits
    // and cut off leading "0x"
    const hashHex = "1220" + bytes32Hex.slice(2);
    const hashBytes = Buffer.from(hashHex, "hex");
    const hashStr = bs58.encode(hashBytes);
    console.log("got: ", hashStr, "from: ", bytes32Hex)
    return hashStr;
  };

  const _convertTimeTo = (rawTime, to) => {
    var time;
    if (to === "seconds") { time = rawTime }
    else if (to === "minutes") { time = rawTime * 60 }
    else if (to === "hours") { time = rawTime * 3600 }
    else if (to === "days") { time = rawTime * 86400 }
    else if (to === "weeks") { time = rawTime * 604800 }
    else { alert("Invalid time unit") }
    return (time);
  }

  const _getETHBalance = async (addr, web3) => {
    if (addr === undefined) { return 0 }
    let tempETHBalance;
    await web3.eth.getBalance(addr, (err, balance) => {
      if (err) { } else {
        tempETHBalance = web3.utils.fromWei(balance, "ether")
        console.log("UTILS: Wallet balance: ", window.ETHBalance)
      }
    });

    return tempETHBalance;
  }

  const _seperateKeysAndValues = (obj) => {
    if (obj === {} || obj === undefined) {
      return (alert("Oops, something went wrong"))
    }

    console.log(obj)

    let textPairsArray = [];
    let photoKeyArray = [];
    let photoValueArray = [];

    if (obj.photo !== undefined && obj.photo !== null) {
      let photoKeys = Object.keys(obj.photo);
      let photoVals = Object.values(obj.photo);
      for (let i = 0; i < photoKeys.length; i++) {
        photoValueArray.push(photoVals[i])
        photoKeyArray.push(photoKeys[i])
      }
    }

    if (obj.text !== undefined && obj.text !== null) {
      let textKeys = Object.keys(obj.text);
      let textVals = Object.values(obj.text);
      for (let i = 0; i < textKeys.length; i++) {
        textPairsArray.push(textKeys[i] + ": " + textVals[i])
      }
    }

    let newObj = { photoKeys: photoKeyArray, photoValues: photoValueArray, text: textPairsArray }
    return newObj;
  }

  const _generateAssets = (assets) => {
    if (assets.names.length > 0) {
      let component = [
        <option key="noselect" value="null"> Select an asset </option>,
        <option key="assetDashLink" value="assetDash">View Assets in Dashboard</option>,
        <option key="resetList" value="reset">Refresh Assets</option>];

      for (let i = 0; i < assets.ids.length; i++) {
        component.push(<option size="lg" key={"asset " + String(i)} value={i}>
          {i + 1}:
          Name: {assets.names[i]},
          ID: {assets.ids[i].substring(0, 10) + "..." + assets.ids[i].substring(58, 68)} </option>);
      }

      return component
    }

    else { return <></> }

  }

  const _generateRemoveElements = (arr) => {
    let component = [
      <option size="lg" key={"selectElement "} value={null}>
        Select Element to Remove
      </option>
    ];

    for (let i = 0; i < arr.length; i++) {
      // console.log(arr[i].key)
      // console.log(arr[i].val)
      component.push(
        <option size="lg" key={"element " + String(i)} value={arr[i].key}>
          Element Name: {arr[i].key.substring(0, 20) + "..."},
          Element Value: {arr[i].val.substring(0, 25) + "..."}
        </option>
      );
    }

    return component

  }

  const _generateAssetDash = (obj) => {
    if (obj.names.length > 0) {
      let component = [];

      for (let i = 0; i < obj.ids.length; i++) {
        component.push(
          <div>
            <style type="text/css"> {`

            .card {
              width: 100%;
              max-width: 100%;
              height: 12rem;
              max-height: 100%;
              background-color: #005480;
              margin-top: 1rem;
              color: white;
              word-break: break-all;
            }

          `}
            </style>
            <div className="card">
              <div className="row no-gutters">
                <div className="col-auto">
                  <button
                    className="imageButton"
                  >
                    <img src={obj.displayImages[i]} className="assetImage" />
                  </button>
                </div>
                <div>
                  <p className="card-name">Name : {obj.names[i]}</p>
                  <p className="card-ac">Asset Class : {obj.assetClasses[i]}</p>
                  <p className="card-status">Status : {obj.statuses[i]}</p>
                  <br></br>
                  <div className="cardDescription"><h4 className="card-description">Description : {obj.descriptions[i].text.description}</h4></div>
                </div>
                <div className="cardButton">
                  <Button
                    variant="primary"
                  >
                    More Info
              </Button>
                </div>
              </div>
            </div>
          </div>
        );
      }

      return component
    }

    else { return <></> }

  }
  const _generateRemElementsPreview = (removedObj) => {
    let component = [];
    let text = removedObj.text;
    let images = removedObj.images;

    component.push(
      <>
        <br></br>
        <div className="assetSelectedContentHead">
          Removed Text Elements:
    </div>
      </>)
    for (let y = 0; y < text.length; y++) {
      component.push(
        <div key={"remText" + String(y)}>
          <div className="assetSelectedContentHead">
            {"--Removed Text " + String(y) + ": "}
            <span className="assetSelectedContent">
              {text[y]}
            </span>
          </div>
        </div>)
    }
    component.push(
      <>
        <div className="assetSelectedContentHead">
          Removed Image Elements:
    </div>
      </>)
    for (let z = 0; z < images.length; z++) {
      component.push(
        <div key={"remImage" + String(z)}>
          <div className="assetSelectedContentHead">
            {"--Removed Image " + String(z) + ": "}
            <span className="assetSelectedContent">
              {images[z]}
            </span>
          </div>
        </div>)
    }

    return component;

  }

  const _generateNewElementsPreview = (obj) => {
    let component = [];
    let photoVals = obj.photo;
    let textVals = obj.text;
    let name = obj.name;

    component.push(
      <>
        <br></br>
        <div className="assetSelectedContentHead">
          New Image Elements:
        </div>
      </>
    )
    for (let i = 0; i < photoVals.length; i++) {
      component.push(
        <div key={"newPhoto" + String(i)}>
          <div className="assetSelectedContentHead">
            {"--Image " + String(i) + ": "}
            <span className="assetSelectedContent">
              {photoVals[i]}
            </span>
          </div>
        </div>)
    }

    component.push(
      <>
        <div className="assetSelectedContentHead">
          New Text Elements:
        </div>
      </>
    )

    for (let x = 0; x < textVals.length; x++) {
      component.push(
        <div key={"newText" + String(x)}>
          <div className="assetSelectedContentHead">
            {"--Text " + String(x) + ": "}
            <span className="assetSelectedContent">
              {textVals[x]}
            </span>
          </div>
        </div>)
    }

    component.push(
      <>
        <div key={"newName"}>
          <div className="assetSelectedContentHead">
            {"New Name: " + name}
          </div>
        </div>
      </>
    )

    return component;

  }

  const _generateDescription = (obj) => {

    //console.log(self.state.descriptionElements)

    let component = [<><h4>Images Found:</h4> <br></br></>];

    for (let i = 0; i < obj.photoKeys.length; i++) {
      //console.log("adding photo", obj.photoKeys[i])
      component.push(<div key={String(i)}>{obj.photoKeys[i]}<br></br><img key={"img" + String(i)} src={String(obj.photoValues[i])} /> <br></br></div>);
    }

    component.push(<> <br></br> <h4>Text Values Found:</h4> <br></br> </>);
    for (let x = 0; x < obj.text.length; x++) {
      //console.log("adding text ", obj.text[x])
      component.push(<div key={String(x)}>{String(obj.text[x])} <br></br></div>);
    }

    //console.log(component)
    return component
  }

  const _checkAssetExists = async (idxHash, contracts) => {
    let tempBool;
    console.log(idxHash.substring(0, 2))
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[2] === "0"
        ) {
          tempBool = false;
        } else {
          tempBool = true;
        }

      });
    console.log(tempBool);
    return tempBool;
  }

  const _checkAssetExportable = async (idxHash, contracts) => {
    let tempBool;
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[0] === "51"
        ) {
          tempBool = true;
        } else {
          tempBool = false;
        }

      });
    console.log(tempBool);
    return tempBool;
  }

  const _checkAssetExported = async (idxHash, contracts) => {
    let tempBool;
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[0] === "70"
        ) {
          tempBool = true;
        } else {
          tempBool = false;
        }

      });
    console.log(tempBool);
    return tempBool;
  }

  const _checkAssetDiscarded = async (idxHash, contracts) => {
    let tempBool;
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[0] === "60"
        ) {
          tempBool = true;
        } else {
          tempBool = false;
        }

      });
    console.log(tempBool);
    return tempBool;
  }

  const _checkAssetCount = async (idxHash, contracts) => {
    let tempAmount;
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        }
        else {
          tempAmount = Object.values(_result)[3]
        }
      });
    console.log(tempAmount);
    return tempAmount;
  }

  const _checkAssetCounterStart = async (idxHash, contracts) => {
    let tempAmount;
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        }
        else {
          tempAmount = Object.values(_result)[4]
        }
      });
    console.log(tempAmount);
    return tempAmount;
  }

  const _checkAssetTransferable = async (idxHash, contracts) => {
    let tempBool;
    console.log(idxHash)
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        }
        else if (
          Object.values(_result)[0] === "51"
        ) {
          tempBool = true;
        } else {
          tempBool = false;
        }

      });
    console.log(tempBool);
    return tempBool;
  }

  const _getStatusString = async (status) => {
    let tempStat;
    console.log(status)
    if (status === "0") {
      tempStat = "No Status"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "1") {
      tempStat = "Transferrable"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "2") {
      tempStat = "Non-Transferable"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "3") {
      tempStat = "Stolen"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "4") {
      tempStat = "Lost"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "5") {
      tempStat = "Transfered"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "6") {
      tempStat = "Supervised Escrow"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "7") {
      tempStat = "Out of Supervised Escrow"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "50") {
      tempStat = "Locked Escrow"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "51") {
      tempStat = "Transferrable"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "52") {
      tempStat = "Non-Transferable"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "53") {
      tempStat = "Stolen"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "54") {
      tempStat = "Lost"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "55") {
      tempStat = "Transfered"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "56") {
      tempStat = "Supervised Escrow"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "57") {
      tempStat = "Out of Supervised Escrow"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "58") {
      tempStat = "Out of Locked Escrow"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "59") {
      tempStat = "Discardable"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "60") {
      tempStat = "Discarded"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "70") {
      tempStat = "importable"
      console.log("Asset in :", tempStat, "status.")
    }

    else if (status === "") {
      tempStat = "Undefined"
      console.log("Asset in :", tempStat, "status.")
    }

    else {
      console.log("Asset in unauthorized status (Does not exist)")
    }

    return (tempStat)
  }

  const _checkAssetRootMatch = async (AC, idxHash, contracts) => {
    let tempBool;
    if (idxHash.substring(0, 2) !== "0x") {
      return (false)
    }
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[2] === AC
        ) {
          tempBool = true;
          window.fetchAC = Object.values(_result)[2];
        } else {
          tempBool = false;
        }
      });

    console.log(tempBool);
    return tempBool;
  }

  const _checkMatch = async (idxHash, rgtHash, contracts) => {
    let tempBool;
    await contracts.STOR.methods
      ._verifyRightsHolder(idxHash, rgtHash)
      .call(function (_error, _result) {
        if (_error) {
          console.log(_error);
        } else if (_result === "0") {
          tempBool = false;
        } else {
          tempBool = true;
        }
        console.log("check debug, _result, _error: ", _result, _error);
      });
    return tempBool;
  }

  const _checkHoldsToken = async (req, id, contracts, addr) => {
    let tempBool;
    if (req === "asset") {
      await contracts.A_TKN.methods
        .ownerOf(id)
        .call(function (_error, _result) {
          if (_error) {
            console.log(_error);
          } else {
            if (_result === addr) {
              tempBool = true
            }
            else { tempBool = false }
          }
          console.log("checked in A_TKN");
        });
    }
    else if (req === "AC") {
      await contracts.AC_TKN.methods
        .ownerOf(id)
        .call(function (_error, _result) {
          if (_error) {
            console.log(_error);
          } else {
            if (_result === addr) {
              tempBool = true
            }
            else { tempBool = false }

          }
          console.log("checked in AC_TKN");
        });
    }

    return tempBool;
  }

  const _checkStats = async (idxHash, posArr, contracts) => {
    let tempArr = [];
    for (let i = 0; i < posArr.length; i++) {
      await contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call(function (_error, _result) {
          if (_error) {
            console.log(_error);
          }

          else {
            tempArr.push(Object.values(_result)[posArr[i]])
          }
        });
    }

    console.log(tempArr)
    return tempArr;
  }

  const _checkEscrowStatus = async (idxHash, contracts) => {
    let tempBool;
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          console.log(_error);
        } else if (Object.values(_result)[2] === '6' || Object.values(_result)[2] === '12') {
          tempBool = true
        }
        else { tempBool = false }
      });

    return tempBool;
  }

  const _checkNoteExists = async (idxHash, contracts) => {
    let tempBool;
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[8] > 0
        ) {
          tempBool = true
        } else {
          tempBool = false
        }

      });

    return tempBool;
  }

  const _resolveAC = async (AC, contracts, assetClass) => {
    if (contracts !== undefined) {
      await contracts.AC_MGR.methods
        .resolveAssetClass(AC)
        .call((_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            assetClass = _result
            console.log("resolved AC name ", AC, " as: ", assetClass);
          }
        });
    }

    let acData = await window.utils.getACData("id", assetClass)
    await window.utils.checkCreds(acData);
    await window.utils.getCosts(6);
    await console.log("User authLevel: ", window.authLevel);
    return (assetClass)

  }

  const _getACNames = async (assetClasses, contracts) => {

    if (contracts !== undefined) {
      let tempArr = [];

      for (let i = 0; i < assetClasses.length; i++) {
        await contracts.AC_MGR.methods
          .getAC_name(assetClasses[i])
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              console.log("resolved AC name ", _result, " from AC index ", assetClasses[i]);
              tempArr.push(_result)
            }
          });
      }

      return tempArr;
    }


  }

  const _resolveACFromID = async (AC, contracts, addr) => {
    let temp;
    if (contracts !== undefined) {
      await contracts.AC_MGR.methods
        .getAC_name(AC)
        .call((_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            temp = _result
            console.log("resolved AC name ", window.assetClassName, " from AC index ", AC);

          }
        });
    }
    let acData = await window.utils.getACData("id", AC)
    if (addr !== undefined) {
      await window.utils.checkCreds(acData, AC);
      await window.utils.getCosts(6, AC);
    }

    await console.log("User authLevel: ", window.authLevel);
    window.assetClassName = temp; //DEV REMOVE ALL window. REFS
    return (temp)

  }

  const _checkCreds = async (acData, AC, contracts, addr, assetClass) => {
    window.isAuthUser = undefined;
    let custodyType = acData.custodyType

    if (contracts !== undefined) {


      await contracts.AC_TKN.methods
        .ownerOf(AC)
        .call((_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            if (_result === addr) {
              window.isACAdmin = true;
            }
            else {
              window.isACAdmin = false;
            }
          }
        });

      if (custodyType === "Custodial") {
        await contracts.AC_MGR.methods
          .getUserType(window.web3.utils.soliditySha3(addr), assetClass)
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (_result === "0" && window.isACAdmin === false) { window.authLevel = "Standard User"; window.isAuthUser = false; }
              else if (_result === "1" && window.isACAdmin === false) { window.authLevel = "Authorized User"; window.isAuthUser = true; }
              else if (_result === "9" && window.isACAdmin === false) { window.authLevel = "Robot"; window.isAuthUser = false; }
              else if (_result === "1" && window.isACAdmin === true) { window.authLevel = "Authorized User/AC Admin"; window.isAuthUser = true; }
              else if (_result === "9" && window.isACAdmin === true) { window.authLevel = "Robot/AC Admin"; window.isAuthUser = false; }
              else if (_result === "0" && window.isACAdmin === true) { window.authLevel = "AC Admin"; window.isAuthUser = false; }
              console.log(_result)
              return (window.custodyType = "Custodial")
            }
          });
      }

      else if (custodyType === "Non-Custodial") {
        await contracts.ID_TKN.methods
          .balanceOf(addr)
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (Number(_result) === 1 && window.isACAdmin === false) { window.authLevel = "Pruf Minter"; window.isAuthUser = false; }
              else if (Number(_result) !== 1 && window.isACAdmin === true) { window.authLevel = "Pruf User/AC Admin"; window.isAuthUser = false; }
              else if (Number(_result) === 1 && window.isACAdmin === true) { window.authLevel = "Pruf Minter/AC Admin"; window.isAuthUser = false; }
              else if (Number(_result) !== 1 && window.isACAdmin === false) { window.authLevel = "Pruf User"; window.isAuthUser = false; }
              console.log(_result)
              return (window.custodyType = "Non-Custodial")
            }
          });
      }



    }

    else {
      console.log("window.contracts object is undefined.")
    }
  }

  const _checkForAC = async (ref, ac, contracts) => {
    let tempBool;
    if (contracts !== undefined) {
      if (ref === "id") {
        console.log("Using id ref")
        await contracts.AC_MGR.methods
          .getAC_name(ac)
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (_result !== "") { tempBool = true }
              else { tempBool = false }
            }
          });
      }

      else if (ref === "name") {
        console.log("Using name ref")
        await contracts.AC_MGR.methods
          .resolveAssetClass(ac)
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (Number(_result) > 0) { tempBool = true }
              else { tempBool = false }
            }
          });
      }

      return tempBool;
    }

  }

  const _checkACName = async (name, contracts) => {
    if (contracts !== undefined) {
      await contracts.AC_MGR.methods
        .resolveAssetClass(name)
        .call((_error, _result) => {
          if (_error) { console.log(_error) }
          else {
            console.log("resolved successfully to AC: ", _result)
            if (Number(_result) > 0) { return (true) }
            else { return false }
          }
        });
    }
  }

  const _getEscrowData = async (idxHash, contracts) => {
    let tempArray = [];

    if (contracts !== undefined) {
      await contracts.ECR_MGR.methods
        .retrieveEscrowData(idxHash)
        .call((_error, _result) => {
          if (_error) { console.log(_error) }
          else {
            console.log("Got escrow data: ", _result)
            tempArray = Object.values(_result)
            console.log("tempArray: ", tempArray)
          }
        });
      return tempArray;
    }
  }

  const _getACData = async (ref, ac, contracts) => {
    let tempData;
    let tempAC;

    if (contracts !== undefined) {

      if (ref === "name") {
        console.log("Using name ref")
        await contracts.AC_MGR.methods
          .resolveAssetClass(ac)
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (Number(_result) > 0) { tempAC = Number(_result) }
              else { return 0 }
            }
          });

      }

      else if (ref === "id") { tempAC = ac; }

      await contracts.AC_MGR.methods
        .getAC_data(tempAC)
        .call((_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            let _custodyType;

            if (Object.values(_result)[1] === "1") {
              _custodyType = "Custodial"
            }

            else {
              _custodyType = "Non-Custodial"
            }

            tempData = {
              root: Object.values(_result)[0],
              custodyType: _custodyType,
              discount: Object.values(_result)[2],
              exData: Object.values(_result)[3],
              AC: tempAC
            }
          }
        });
      window.tempACData = tempData;
      return tempData;
    }

  }

  const _getCosts = async (numOfServices, AC, contracts) => {
    window.costArray = [];
    if (contracts !== undefined) {
      //console.log("Getting cost array");

      for (var i = 1; i <= numOfServices; i++) {
        await contracts.AC_MGR.methods
          .getServiceCosts(AC, i)
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              //console.log("result in getCosts: ", Object.values(_result));
              window.costArray.push(Number((Object.values(_result)[1])) + Number((Object.values(_result)[3])))
            }
          })
      }

      //console.log("before setting window-level costs")

      window.costs = {
        newRecordCost: window.costArray[0],
        transferAssetCost: window.costArray[1],
        createNoteCost: window.costArray[2],
        remintAssetCost: window.costArray[3],
        changeAssetCost: window.costArray[4],
        forceTransferCost: window.costArray[5],
      }

      //window.utils.checkCreds()

      console.log("window costs object: ", window.costs);
      //console.log("this should come last");
    }
    else {
      console.log("Window.contracts object is undefined.")
    }
  }
  const _getDescriptionHash = async (idxHash, contracts) => {
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[5] === "0"
        ) {
        } else {
          window.descriptionBytes32Hash = Object.values(_result)[5];
          console.log(window.descriptionBytes32Hash)
          return (Object.values(_result)[5])
        }
      });
  }

  const _getACFromIdx = async (idxHash, contracts) => {
    await contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call(function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else {
          window.assetClass = Object.values(_result)[2];
          console.log("Now operating in AC: ", window.assetClass)
        }
      });

    await window.utils.getCosts(6, window.assetClass)

  }

  const _determineTokenBalance = async (addr, contracts) => {

    if (addr !== undefined) {
      let _assetClassBal;
      let _assetBal;
      let _IDTokenBal;
      console.log("getting balance info from token contracts...")
      await contracts.A_TKN.methods.balanceOf(addr).call((error, result) => {
        if (error) { console.log(error) }
        else { _assetBal = result; console.log("assetBal: ", _assetBal); }
      });

      await contracts.AC_TKN.methods.balanceOf(addr).call((error, result) => {
        if (error) { console.log(error) }
        else { _assetClassBal = result; console.log("assetClassBal", _assetClassBal); }
      });

      await contracts.ID_TKN.methods.balanceOf(addr).call((error, result) => {
        if (error) { console.log(error) }
        else { _IDTokenBal = result; console.log("IDTokenBal", _IDTokenBal); }
      });

      if (Number(_assetBal) > 0) {
        window.assetHolderBool = true
      }

      else if (Number(_assetBal) === 0 || _assetBal === undefined) {
        window.assetHolderBool = false
      }

      if (Number(_assetClassBal) > 0) {
        window.assetClassHolderBool = true
      }

      else if (Number(_assetClassBal) === 0 || _assetClassBal === undefined) {
        window.assetClassHolderBool = false
      }

      if (Number(_IDTokenBal) > 0 && Number(_IDTokenBal) < 2) {
        window.IDHolderBool = true
      }

      else if (Number(_IDTokenBal) === 0 || _IDTokenBal === undefined || _IDTokenBal > 1) {
        window.IDHolderBool = false
      }
      window.balances = {
        assetClassBalance: _assetClassBal,
        assetBalance: _assetBal,
        IDTokenBalance: _IDTokenBal
      }
    }
  }
  const _getAssetTokenInfo = async (assetBalance, contracts, addr, web3) => {

    if (window.balances === undefined) { return }

    console.log("GATI: In _getAssetTokenInfo")

    if (Number(assetBalance) > 0) {

      let tknIDArray = [];
      let ipfsHashArray = [];
      let noteArray = []
      let statuses = [];
      let countPairs = [];
      let assetClasses = [];

      for (let i = 0; i < window.balances.assetBalance; i++) {
        await contracts.A_TKN.methods.tokenOfOwnerByIndex(addr, i)
          .call((_error, _result) => {
            if (_error) {
              return (console.log("IN ERROR IN ERROR IN ERROR"))
            } else {
              console.log(web3.utils.numberToHex(_result))
              tknIDArray.push(web3.utils.numberToHex(_result));
            }
          });
        //console.log(i)
      }

      for (let x = 0; x < tknIDArray.length; x++) {
        await contracts.STOR.methods.retrieveShortRecord(tknIDArray[x])
          .call((_error, _result) => {
            if (_error) {
              console.log("IN ERROR IN ERROR IN ERROR")
            } else {
              //console.log(tknIDArray[x])
              //console.log(_result)
              if (Number(Object.values(_result)[5]) > 0) {
                ipfsHashArray.push(window.utils.getIpfsHashFromBytes32(Object.values(_result)[5]))
              }
              else {
                ipfsHashArray.push("0")
              }
              if (Number(Object.values(_result)[6]) > 0) {
                noteArray.push("https://ipfs.io/ipfs/" + String(window.utils.getIpfsHashFromBytes32(Object.values(_result)[6])))
              }
              else {
                noteArray.push("0")
              }

              if (_result[0] === "50") { statuses.push("In Locked Escrow") }
              else if (_result[0] === "51") { statuses.push("Transferrable") }
              else if (_result[0] === "52") { statuses.push("Non-Transferrable") }
              else if (_result[0] === "53") { statuses.push("MARKED STOLEN") }
              else if (_result[0] === "54") { statuses.push("MARKED LOST") }
              else if (_result[0] === "55") { statuses.push("Transferred/Unclaimed") }
              else if (_result[0] === "56") { statuses.push("In Escrow") }
              else if (_result[0] === "57") { statuses.push("Escrow Ended") }
              else if (_result[0] === "58") { statuses.push("Imported") }
              else if (_result[0] === "59") { statuses.push("Discardable") }
              else if (_result[0] === "60") { statuses.push("Recyclable") }
              else if (_result[0] === "70") { statuses.push("Exported") }
              else if (_result[0] === "0") { statuses.push("Status Not Set") }
              assetClasses.push(Object.values(_result)[2]);
              countPairs.push([Object.values(_result)[3], Object.values(_result)[4]]);

            }
          })
        //console.log(x)
      }

      let ACNames = await window.utils.getACNames(assetClasses)

      console.log(ipfsHashArray)

      //console.log(window.aTknIDs, " tknID-> ", tknIDArray);

      let assetInfo = {
        statuses,
        countPairs,
        assetClasses,
        notes: noteArray,
        ids: tknIDArray,
        ipfsHashArray, 
        ACNames
      }

      return assetInfo;

    }

    else { console.log("No assets held by user"); return window.hasNoAssets = true }
  }

  const _getAssetTokenName = async (ipfs, assets) => {
    let temp;

    if (ipfs !== "0") {
      temp = await window.utils.getIPFSJSONObject(ipfs)
    }

    else { temp = "N/A" }

    assets.names.push(temp);
  }

  const _addIPFSJSONObject = async (payload) => {
    console.log("Uploading file to IPFS...");
    await window.ipfs.add(JSON.stringify(payload), (error, hash) => {
      if (error) {
        console.log("Something went wrong. Unable to upload to ipfs");
      } else {
        console.log("uploaded at hash: ", hash);
        return window.rawIPFSHashTemp = hash;
      }
    });
  }

  const _getIPFSJSONObject = async (lookup) => {
    console.log(lookup)
    let temp
    await window.ipfs.cat(lookup, (error, result) => {
      if (error) {
        console.log("Something went wrong. Unable to find file on IPFS");
      } else {
        console.log("Here's what we found for asset description: ", result);
        temp = result;
        return JSON.parse(temp);
      }
    });
  };

  const _getIPFSRaw = async (lookup) => {
    console.log(lookup)
    let temp;
    await window.ipfs.cat(lookup, (error, result) => {
      if (error) {
        console.log("Something went wrong. Unable to find file on IPFS");
      } else {
        console.log("Here's what we found for asset description: ", result);
        temp = result;
      }
    });

    console.log(temp);
    return temp
  };

  const _generateCardPrint = () => {
    return (
      <div className="PrintForm">
        <div className="QRPrint">
          <QRCode
            value={window.printObj.idxHash}
            size="256"
            fgColor="#002a40"
            logoWidth="48.8"
            logoHeight="64"
            logoImage="https://pruf.io/assets/images/pruf-u-logo-with-border-323x429.png"
          />
        </div>
        <div className="card-href">https://pruf.io</div>
        <div className="PrintFormContent">
          <img
            className="PrintImageBackgroundForm"
            src={require("../Resources/PrufPrintBackground.png")}
            alt="Pruf Print Background" />
          <div className="QRPrint2">
            <QRCode
              value={window.printObj.idxHash}
              size="160"
              fgColor="#002a40"
              logoWidth="32"
              logoHeight="41.6"
              logoImage="https://pruf.io/assets/images/pruf-u-logo-with-border-323x429.png"
            />
          </div>
          <p className="card-name-print">Name : {window.printObj.name}</p>
          <p className="card-ac-print">Asset Class : {window.printObj.assetClass}</p>
          <h4 className="card-idx-print">IDX : {window.printObj.idxHash}</h4>
        </div>
      </div >
    )
  }

  window.utils = {

    checkCreds: _checkCreds,
    getCosts: _getCosts,
    determineTokenBalance: _determineTokenBalance,
    getACData: _getACData,
    resolveAC: _resolveAC,
    checkACName: _checkACName,
    checkAssetExists: _checkAssetExists,
    checkStats: _checkStats,
    getStatusString: _getStatusString,
    checkAssetExportable: _checkAssetExportable,
    checkAssetExported: _checkAssetExported,
    checkAssetDiscarded: _checkAssetDiscarded,
    checkAssetRootMatch: _checkAssetRootMatch,
    checkAssetTransferable: _checkAssetTransferable,
    checkAssetCounterStart: _checkAssetCounterStart,
    checkAssetCount: _checkAssetCount,
    checkNoteExists: _checkNoteExists,
    checkMatch: _checkMatch,
    checkEscrowStatus: _checkEscrowStatus,
    tenThousandHashesOf: _tenThousandHashesOf,
    convertTimeTo: _convertTimeTo,
    resolveACFromID: _resolveACFromID,
    checkForAC: _checkForAC,
    getDescriptionHash: _getDescriptionHash,
    getEscrowData: _getEscrowData,
    getBytes32FromIPFSHash: _getBytes32FromIPFSHash,
    getIpfsHashFromBytes32: _getIpfsHashFromBytes32,
    getIPFSJSONObject: _getIPFSJSONObject,
    getIPFSRaw: _getIPFSRaw,
    generateNewElementsPreview: _generateNewElementsPreview,
    generateDescription: _generateDescription,
    seperateKeysAndValues: _seperateKeysAndValues,
    getAssetTokenInfo: _getAssetTokenInfo,
    checkHoldsToken: _checkHoldsToken,
    getAssetTokenName: _getAssetTokenName,
    getACNames: _getACNames,
    getACFromIdx: _getACFromIdx,
    generateAssets: _generateAssets,
    generateRemoveElements: _generateRemoveElements,
    generateRemElementsPreview: _generateRemElementsPreview,
    getETHBalance: _getETHBalance,
    generateAssetDash: _generateAssetDash,
    addIPFSJSONObject: _addIPFSJSONObject,
    generateCardPrint: _generateCardPrint,

  }

  console.log("Setting up window utils")
  return console.log("Utils loaded: ", window.utils)
}

export default buildWindowUtils

