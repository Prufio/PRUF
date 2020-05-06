exports.get_decrement = function(req, res, next) {
  res.render('get_decrement', { title: 'Bulletproof Asset Provenance' });
}

exports.decrement_record = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("Decrement Amount", req.body.decrement);
  res.redirect('/');
}