exports.new_record = function(req, res, next) {
  res.render('new_record', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_record = function(req, res, next) {
  console.log("Asset ID: ", req.body.assetId);
  console.log("Rights holder: ", req.body.rightsHolder);
  console.log("Asset Class: ", req.body.assetClass);
  console.log("Countdown Start", req.body.countdownStart);
  console.log("Description", req.body.description);
  res.redirect('/');
}
var Web3 = require("../web3.min");

var web3 = new Web3(web3.currentProvider);

 window.addEventListener('load', async () => {
      console.log("in metamask launcher");
      if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        console.log("in window.eth");
        try {
          await ethereum.enable();
          console.log("ethereum acct access enabled");
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










    