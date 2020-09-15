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

  const _checkAssetExists = async (idxHash) => {
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call({ from: window.addr }, function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[4] ===
          "0"
        ) {
          return (false)
        } else {
          return (true)
        }

      });
  }

  const _checkMatch = async (idxHash, rgtHash) => {
    await window.contracts.STOR.methods
      ._verifyRightsHolder(idxHash, rgtHash)
      .call({ from: window.addr }, function (_error, _result) {
        if (_error) {
          console.log(_error);
        } else if (_result === "0") {
          return (false)
        } else {
          return (true)
        }
        console.log("check debug, _result, _error: ", _result, _error);
      });
  }

  const _checkEscrowStatus = async (idxHash) => {
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call({ from: window.addr }, function (_error, _result) {
        if (_error) {
          console.log(_error);
        } else if (Object.values(_result)[2] === '6' || Object.values(_result)[2] === '12') {
          return true
        }
        else { return false }
      });
  }

  const _checkNoteExists = async (idxHash) => {
    await window.contracts.STOR.methods
      .retrieveShortRecord(idxHash)
      .call({ from: window.addr }, function (_error, _result) {
        if (_error) {
          return (console.log("IN ERROR IN ERROR IN ERROR"))
        } else if (
          Object.values(_result)[8] > 0
        ) {
          return (true)
        } else {
          return (false)
        }

      });
  }

  const _resolveAC = async () => {
    if (window.contracts !== undefined) {
      await window.contracts.AC_MGR.methods
        .resolveAssetClass(window.assetClassName)
        .call({ from: window.addr }, (_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            window.assetClass = _result
            console.log("resolved AC name ", window.assetClassName, " as: ", window.assetClass);
          }
        });
    }

    window.utils.checkCreds();
    window.utils.getCosts(6);
    console.log("User authLevel: ", window.authLevel);

  }

  const _resolveACFromID = async () => {
    if (window.contracts !== undefined) {
      await window.contracts.AC_MGR.methods
        .getAC_name(window.assetClass)
        .call({ from: window.addr }, (_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            window.assetClassName = _result
            console.log("resolved AC name ", window.assetClassName, " from AC index ", window.assetClass);
            return (window.assetClassName)
          }
        });
    }

    window.utils.checkCreds();
    window.utils.getCosts(6);
    console.log("User authLevel: ", window.authLevel);

  }

  const _checkForAC = async (ref, ac) => {
    let tempBool;
    if (window.contracts !== undefined) {
      if (ref === "id") {
        console.log("Using id ref")
        await window.contracts.AC_MGR.methods
          .getAC_name(ac)
          .call({ from: window.addr }, (_error, _result) => {
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
          .call({ from: window.addr }, (_error, _result) => {
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
        .call({ from: window.addr }, (_error, _result) => {
          if (_error) { console.log(_error) }
          else {
            console.log("resolved successfully to AC: ", _result)
            if (Number(_result) > 0) { return (true) }
            else { return false }
          }
        });
    }

    window.utils.checkCreds();
    window.utils.getCosts(6);
    console.log("User authLevel: ", window.authLevel);

  }

  const _getACData = async (ref, ac) => {
    let tempData;
    let tempAC;

    if (window.contracts !== undefined) {

      if (ref === "name") {
        console.log("Using name ref")
        await window.contracts.AC_MGR.methods
          .resolveAssetClass(ac)
          .call({ from: window.addr }, (_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              if (Number(_result) > 0) { tempAC = Number(_result) }
              else { return 0 }
            }
          });

      }

      else if (ref === "id"){tempAC = ac;}

      await window.contracts.AC_MGR.methods
        .getAC_data(tempAC)
        .call({ from: window.addr }, (_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            let _custodyType;

            if(Object.values(_result)[1] === "1"){
              _custodyType = "Custodial"
            }

            else{
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

  const _checkCreds = async () => {
    window.isAuthUser = undefined;
    if (window.contracts !== undefined) {

      await window.contracts.AC_TKN.methods
        .ownerOf(window.assetClass)
        .call({ from: window.addr }, (_error, _result) => {
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

      await window.contracts.AC_MGR.methods
        .getUserType(window.web3.utils.soliditySha3(window.addr), window.assetClass)
        .call({ from: window.addr }, (_error, _result) => {
          if (_error) { console.log("Error: ", _error) }
          else {
            if (_result === "0" && window.isACAdmin === false) { window.authLevel = "Standard User"; window.isAuthUser = false; }
            else if (_result === "1" && window.isACAdmin === false) { window.authLevel = "Authorized User"; window.isAuthUser = true; }
            else if (_result === "9" && window.isACAdmin === false) { window.authLevel = "Robot"; window.isAuthUser = false; }
            else if (_result === "1" && window.isACAdmin === true) { window.authLevel = "Authorized User/AC Admin"; window.isAuthUser = true; }
            else if (_result === "9" && window.isACAdmin === true) { window.authLevel = "Robot/AC Admin"; window.isAuthUser = false; }
            else if (_result === "0" && window.isACAdmin === true) { window.authLevel = "AC Admin"; window.isAuthUser = false; }
            console.log(_result)
            return (window.authLevel)
          }
        });

    }

    else {
      console.log("window.contracts object is undefined.")
    }
  }

  const _getCosts = async (numOfServices) => {
    window.costArray = [];
    if (window.contracts !== undefined) {
      //console.log("Getting cost array");

      for (var i = 1; i <= numOfServices; i++) {
        await window.contracts.AC_MGR.methods
          .getServiceCosts(window.assetClass, i)
          .call({ from: window.addr }, (_error, _result) => {
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
        importAssetCost: window.costArray[4],
        forceTransferCost: window.costArray[5],
      }

      window.utils.checkCreds()

      console.log("window costs object: ", window.costs);
      //console.log("this should come last");
    }
    else {
      console.log("Window.contracts object is undefined.")
    }
  }

  const _getContracts = async () => {

    window.contracts = {
      STOR: window._contracts.content[0],
      APP: window._contracts.content[1],
      NP: window._contracts.content[2],
      AC_MGR: window._contracts.content[3],
      AC_TKN: window._contracts.content[4],
      A_TKN: window._contracts.content[5],
      ECR_MGR: window._contracts.content[6],
      ECR: window._contracts.content[7],
      VERIFY: window._contracts.content[8],
      ECR_NC: window._contracts.content[9],
      APP_NC: window._contracts.content[10],
      NP_NC: window._contracts.content[11],
      RCLR: window._contracts.content[12],
      PIP: window._contracts.content[13],
      ID_TKN: window._contracts.content[14],
      UTIL_TKN: window._contracts.content[15]
    }

    console.log("contracts: ", window.contracts)
  };

  const _determineTokenBalance = async () => {

    if (window.addr !== undefined) {
      let _assetClassBal;
      let _assetBal;
      console.log("getting balance info from token contracts...")
      await window.contracts.A_TKN.methods.balanceOf(window.addr).call({ from: window.addr }, (error, result) => {
        if (error) { console.log(error) }
        else { _assetBal = result; console.log("assetBal: ", _assetBal); }
      });

      await window.contracts.AC_TKN.methods.balanceOf(window.addr).call({ from: window.addr }, (error, result) => {
        if (error) { console.log(error) }
        else { _assetClassBal = result; console.log("assetClassBal", _assetClassBal); }
      });

      if (Number(_assetBal) > 0) {
        window.assetHolderBool = true
      }

      else if (Number(_assetBal === 0 || _assetBal === undefined)) {
        window.assetHolderBool = false
      }

      if (Number(_assetClassBal) > 0) {
        window.assetClassHolderBool = true
      }

      else if (Number(_assetClassBal === 0 || _assetClassBal === undefined)) {
        window.assetClassHolderBool = false
      }
    }
  }

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

  }

  console.log("Setting up window utils")
  return console.log("Utils loaded: ", window.utils)
}

export default buildWindowUtils

