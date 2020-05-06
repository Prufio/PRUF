exports.transfer_record = function(req, res, next) {
  res.render('transfer_record', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_transfer = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Old Rights holder", req.body.old);
  console.log("New Rights holder", req.body.new);
  res.redirect('/');
}