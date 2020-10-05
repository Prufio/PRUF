import bs58 from "bs58";
import React from "react";
import Button from "react-bootstrap/Button";
import "./../index.css";

function buildWindowUtils() {

  //UTIL_TKN.methods.currentACtokenInfo

  const _tenThousandHashesOf = (varToHash) => {
    var tempHash = varToHash;
    for (var i = 0; i < 10000; i++) {
      tempHash = window.web3.utils.soliditySha3(tempHash);
      console.log(tempHash);
    }
    return tempHash;
  }

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

  const _getETHBalance = async () => {
    if (window.addr === undefined) { return 0 }
    let addr = window.addr;
    await window.web3.eth.getBalance(addr, (err, balance) => {
      if (err) { } else {
        window.ETHBalance = window.web3.utils.fromWei(balance, "ether")
        console.log("UTILS: Wallet balance: ", window.ETHBalance)
      }
    });
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

  const _generateAssets = () => {
    if (window.assets.names.length > 0) {
      let component = [];

      for (let i = 0; i < window.assets.ids.length; i++) {
        //console.log(i, "Adding: ", window.assets.descriptions[i], "and ", window.assets.ids[i])
        component.push(<option key={"asset " + String(i)} value={i}>Name: {window.assets.descriptions[i].name}, ID: {window.assets.ids[i]} </option>);
      }

      return component
    }

    else { return <></> }

  }

  const _generateAssetDash = (obj) => {
    if (obj.names.length > 0) {
      let component = [];

      for (let i = 0; i < obj.ids.length; i++) {
        //console.log(i, "Adding: ", window.assets.descriptions[i], "and ", window.assets.ids[i])
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
            <div class="card">
              <div class="row no-gutters">
                <div class="col-auto">
                  <button
                    class="imageButton"
                  >
                    <img src={obj.displayImages[i]} className="assetImage" />
                  </button>
                </div>
                <div>
                  <p class="card-name">Name : {obj.names[i]}</p>
                  <p class="card-ac">Asset Class : {obj.assetClasses[i]}</p>
                  <p class="card-status">Status : {obj.statuses[i]}</p>
                  <br></br>
                  <div className="cardDescription"><h4 class="card-description">Description : {obj.descriptions[i].text.description}</h4></div>
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

  const _checkAssetExists = async (idxHash) => {
    let tempBool;
    console.log(idxHash.substring(0,2))
      if(idxHash.substring(0,2) !== "0x") {
        return(false)
      }
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call( function (_error, _result) {
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

  const _checkMatch = async (idxHash, rgtHash) => {
    let tempBool;
    await window.contracts.STOR.methods
      ._verifyRightsHolder(idxHash, rgtHash)
      .call( function (_error, _result) {
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

  const _checkHoldsToken = async (req, id) => {
    let tempBool;
    if (req === "asset") {
      await window.contracts.A_TKN.methods
        .ownerOf(id)
        .call( function (_error, _result) {
          if (_error) {
            console.log(_error);
          } else {
            if (_result === window.addr) {
              tempBool = true
            }
            else { tempBool = false }
          }
          console.log("checked in A_TKN");
        });
    }
    else if (req === "AC") {
      await window.contracts.AC_TKN.methods
        .ownerOf(id)
        .call( function (_error, _result) {
          if (_error) {
            console.log(_error);
          } else {
            if (_result === window.addr) {
              tempBool = true
            }
            else { tempBool = false }

          }
          console.log("checked in AC_TKN");
        });
    }

    return tempBool;
  }

  const _checkEscrowStatus = async (idxHash) => {
    let tempBool;
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call( function (_error, _result) {
        if (_error) {
          console.log(_error);
        } else if (Object.values(_result)[2] === '6' || Object.values(_result)[2] === '12') {
          tempBool = true
        }
        else { tempBool = false }
      });

    return tempBool;
  }

  const _checkNoteExists = async (idxHash) => {
    let tempBool;
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call( function (_error, _result) {
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

  const _resolveAC = async () => {
    if (window.contracts !== undefined) {
      await window.contracts.AC_MGR.methods
        .resolveAssetClass(window.assetClassName)
        .call( (_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            window.assetClass = _result
            console.log("resolved AC name ", window.assetClassName, " as: ", window.assetClass);
          }
        });
    }

    let acData = await window.utils.getACData("id", window.assetClass)
    await window.utils.checkCreds(acData);
    await window.utils.getCosts(6);
    await console.log("User authLevel: ", window.authLevel);
    return (window.assetClass)

  }

  const _resolveACFromID = async () => {
    if (window.contracts !== undefined) {
      await window.contracts.AC_MGR.methods
        .getAC_name(window.assetClass)
        .call( (_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            window.assetClassName = _result
            console.log("resolved AC name ", window.assetClassName, " from AC index ", window.assetClass);

          }
        });
    }
    let acData = await window.utils.getACData("id", window.assetClass)
    if(window.addr !== undefined){
      await window.utils.checkCreds(acData);
      await window.utils.getCosts(6);
    }
    
    await console.log("User authLevel: ", window.authLevel);
    return (window.assetClassName)

  }

  const _checkCreds = async (acData) => {
    window.isAuthUser = undefined;
    let custodyType = acData.custodyType

    if (window.contracts !== undefined) {


      await window.contracts.AC_TKN.methods
        .ownerOf(window.assetClass)
        .call( (_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            if (_result === window.addr) {
              window.isACAdmin = true;
            }
            else {
              window.isACAdmin = false;
            }
          }
        });

      if (custodyType === "Custodial") {
        await window.contracts.AC_MGR.methods
          .getUserType(window.web3.utils.soliditySha3(window.addr), window.assetClass)
          .call( (_error, _result) => {
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
        await window.contracts.ID_TKN.methods
          .balanceOf(window.addr)
          .call( (_error, _result) => {
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

  const _checkForAC = async (ref, ac) => {
    let tempBool;
    if (window.contracts !== undefined) {
      if (ref === "id") {
        console.log("Using id ref")
        await window.contracts.AC_MGR.methods
          .getAC_name(ac)
          .call( (_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (_result !== "") { tempBool = true }
              else { tempBool = false }
            }
          });
      }

      else if (ref === "name") {
        console.log("Using name ref")
        await window.contracts.AC_MGR.methods
          .resolveAssetClass(ac)
          .call( (_error, _result) => {
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

  const _checkACName = async (name) => {
    if (window.contracts !== undefined) {
      await window.contracts.AC_MGR.methods
        .resolveAssetClass(name)
        .call( (_error, _result) => {
          if (_error) { console.log(_error) }
          else {
            console.log("resolved successfully to AC: ", _result)
            if (Number(_result) > 0) { return (true) }
            else { return false }
          }
        });
    }
  }

  const _getEscrowData = async (idxHash) => {
    if (window.contracts !== undefined) {
      await window.contracts.ECR_MGR.methods
        .retrieveEscrowData(idxHash)
        .call( (_error, _result) => {
          if (_error) { console.log(_error) }
          else {
            console.log("Got escrow data: ", _result)
            return Object.values(_result)
          }
        });
    }
  }

  const _getACData = async (ref, ac) => {
    let tempData;
    let tempAC;

    if (window.contracts !== undefined) {

      if (ref === "name") {
        console.log("Using name ref")
        await window.contracts.AC_MGR.methods
          .resolveAssetClass(ac)
          .call( (_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (Number(_result) > 0) { tempAC = Number(_result) }
              else { return 0 }
            }
          });

      }

      else if (ref === "id") { tempAC = ac; }

      await window.contracts.AC_MGR.methods
        .getAC_data(tempAC)
        .call( (_error, _result) => {
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
      return tempData;
    }

  }

  const _getCosts = async (numOfServices) => {
    window.costArray = [];
    if (window.contracts !== undefined) {
      //console.log("Getting cost array");

      for (var i = 1; i <= numOfServices; i++) {
        await window.contracts.AC_MGR.methods
          .getServiceCosts(window.assetClass, i)
          .call( (_error, _result) => {
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
  const _getDescriptionHash = async (idxHash) => {
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call( function (_error, _result) {
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

  const _getACFromIdx = async (idxHash) => {
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call( function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else {
          window.assetClass = Object.values(_result)[2];
          console.log("Now operating in AC: ", window.assetClass)
          return (Object.values(_result)[2])
        }
      });
  }

  const _getContracts = async () => {
    console.log("contracts: ", window.contracts)
  };

  const _determineTokenBalance = async () => {

    if (window.addr !== undefined) {
      let _assetClassBal;
      let _assetBal;
      let _IDTokenBal;
      console.log("getting balance info from token contracts...")
      await window.contracts.A_TKN.methods.balanceOf(window.addr).call( (error, result) => {
        if (error) { console.log(error) }
        else { _assetBal = result; console.log("assetBal: ", _assetBal); }
      });

      await window.contracts.AC_TKN.methods.balanceOf(window.addr).call( (error, result) => {
        if (error) { console.log(error) }
        else { _assetClassBal = result; console.log("assetClassBal", _assetClassBal); }
      });

      await window.contracts.ID_TKN.methods.balanceOf(window.addr).call( (error, result) => {
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
  const _getAssetTokenInfo = async () => {

    if(window.balances === undefined){return}

    console.log("GATI: In _getAssetTokenInfo")

    if (Number(window.balances.assetBalance) > 0) {
      let tknIDArray = [];
      let ipfsHashArray = [];
      let statuses = [];
      let assetClasses = [];

      for (let i = 0; i < window.balances.assetBalance; i++) {
        await window.contracts.A_TKN.methods.tokenOfOwnerByIndex(window.addr, i)
          .call( (_error, _result) => {
            if (_error) {
              return (console.log("IN ERROR IN ERROR IN ERROR"))
            } else {
              console.log(window.web3.utils.numberToHex(_result))
              tknIDArray.push(window.web3.utils.numberToHex(_result));
            }
          });
        //console.log(i)
      }

      for (let x = 0; x < tknIDArray.length; x++) {
        await window.contracts.STOR.methods.retrieveShortRecord(tknIDArray[x])
          .call( (_error, _result) => {
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
              statuses.push(Object.values(_result)[0])
              assetClasses.push(Object.values(_result)[2])

            }
          })
        //console.log(x)
      }

      console.log(ipfsHashArray)

      window.aTknIDs = tknIDArray;
      //console.log(window.aTknIDs, " tknID-> ", tknIDArray);
      window.ipfsHashArray = ipfsHashArray;

      window.assets.assetClasses = assetClasses;
      window.assets.statuses = statuses;

    }

    else { console.log("No assets held by user"); return window.hasNoAssets = true }
  }

  const _getAssetTokenName = async (ipfs) => {
    let temp;

    if (ipfs !== "0") {
      temp = await window.utils.getIPFSJSONObject(ipfs)
    }

    else { temp = "N/A" }

    window.assets.names.push(temp);
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

  window.utils = {

    checkCreds: _checkCreds,
    getCosts: _getCosts,
    getContracts: _getContracts,
    determineTokenBalance: _determineTokenBalance,
    getACData: _getACData,
    resolveAC: _resolveAC,
    checkACName: _checkACName,
    checkAssetExists: _checkAssetExists,
    checkNoteExists: _checkNoteExists,
    checkMatch: _checkMatch,
    checkEscrowStatus: _checkEscrowStatus,
    tenThousandHashesOf: _tenThousandHashesOf,
    convertTimeTo: _convertTimeTo,
    resolveACFromID: _resolveACFromID,
    checkForAC: _checkForAC,
    getDescriptionHash: _getDescriptionHash,
    getEscrowData: _getEscrowData,
    getIpfsHashFromBytes32: _getIpfsHashFromBytes32,
    getIPFSJSONObject: _getIPFSJSONObject,
    getIPFSRaw: _getIPFSRaw,
    generateDescription: _generateDescription,
    seperateKeysAndValues: _seperateKeysAndValues,
    getAssetTokenInfo: _getAssetTokenInfo,
    checkHoldsToken: _checkHoldsToken,
    getAssetTokenName: _getAssetTokenName,
    getACFromIdx: _getACFromIdx,
    generateAssets: _generateAssets,
    getETHBalance: _getETHBalance,
    generateAssetDash: _generateAssetDash,

  }

  console.log("Setting up window utils")
  return console.log("Utils loaded: ", window.utils)
}

export default buildWindowUtils

