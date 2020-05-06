exports.change_description = function(req, res, next) {
  res.render('change_description', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_description = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("New Description", req.body.description);
  res.redirect('/');
}
