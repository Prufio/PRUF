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











    