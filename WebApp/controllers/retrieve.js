exports.retrieve_record = function(req, res, next) {
  res.render('retrieve_record', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_retrieve = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  res.redirect('/');
}