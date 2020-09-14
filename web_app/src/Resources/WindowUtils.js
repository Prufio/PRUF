function buildWindowUtils () {

    const _checkCreds = async () => {
        window.isAuthUser = undefined;
        if (window.contracts !== undefined) {
            window.contracts.AC_MGR.methods
                .getUserType(window.web3.utils.soliditySha3(window.addr), window.assetClass)
                .call({ from: window.addr }, (_error, _result) => {
                    if (_error) { console.log("Error: ", _error) }
                    else {
                        if (_result === "0") { window.authLevel = "Standard User (read-only access)"; window.isAuthUser = false;}
                        else if (_result === "1") { window.authLevel = "Authorized User"; window.isAuthUser = true;}
                        else if (_result === "9") { window.authLevel = "Robot"; window.isAuthUser = false;}
                        console.log(_result)
                        return (window.authLevel)
                    }
                });
        }

        else{
            console.log("window.contracts object is undefined.")
        }
    }

    const _getCosts = async (numOfServices) => {
        window.costArray = [];
        if (window.contracts !== undefined) {
            //console.log("Getting cost array");
            for(var i=1; i <= numOfServices; i++){
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
        else{
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
          NAKED: window._contracts.content[13],
        }
  
        console.log("contracts: ", window.contracts)
      };
  
      const _determineTokenBalance = async () => {
        
        if(window.addr !== undefined){
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
        
        else if (Number(_assetBal === 0 || _assetBal === undefined)){
          window.assetHolderBool = false
        }
  
        if (Number(_assetClassBal) > 0) {
          window.assetClassHolderBool = true
        }

        else if (Number(_assetClassBal === 0 || _assetClassBal === undefined)){
          window.assetClassHolderBool = false
        }
  
        window.balances = {
          assetBal: Number(_assetBal),
          assetClassBal: Number(_assetClassBal)
        }
  
        console.log("token balances: ", window.balances)
        return window.hasFetchedBalances = true;
      }

      else{
        console.log("Not connected to web3 provider...") 
      }

      }

    console.log("Setting up window utils")

    window.utils = {
        checkCreds: _checkCreds,
        getCosts: _getCosts,
        getContracts: _getContracts,
        determineTokenBalance: _determineTokenBalance,
    }

    return console.log("Utils loaded: ", window.utils)
}

export default buildWindowUtils

