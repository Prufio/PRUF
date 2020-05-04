
web3Client = require("./web3.min.js");
var accountChecks = 0;

var web3 = new Web3(web3.currentProvider);

 window.addEventListener('load', async () => {
      console.log("in metamask launcher");
      if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        console.log("in window.eth");
        try {
          await ethereum.enable();
          console.log("ethereum acct access enabled");
		  console.log(web3.eth.getAccounts());
          console.log("acct 0:", web3.eth.accounts[0]);
		}
		  catch{
          $('#status').html('User denied account access', err)
		  }
        
		
      } else if (window.web3) {
        window.web3 = new Web3(web3.currentProvider)
        console.log("in window.web3");
      } else {
          console.log("no metamask detected");
        $('#status').html('No Metamask (or other Web3 Provider) installed')
      }
	  console.log("Current Web3 Provider: ", Web3.givenProvider);
	
    })



function resetCounter(){
    accountChecks = 0;
    console.log("*******************Attempts Reset********************")
}
function checkForAccounts () {
    accountChecks ++;
    console.log("Getting accounts, attempt#", accountChecks);

    var account1;
    var account2;

    web3.eth.getAccounts().then(function(result){account1 = result[0];})
    console.log("Current account using getAcoounts(): ", account1);

    account2 = web3.eth.accounts[0];
    console.log("Current account using accounts[0] read: ", account2);
    console.log();
   
}