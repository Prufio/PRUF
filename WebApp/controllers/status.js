exports.change_status = function(req, res, next) {
  res.render('change_status', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_status = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("New Status", req.body.status);
  res.redirect('/');
}