exports.force_mod = function(req, res, next) {
  res.render('force_mod', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_mod = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("New Rights holder", req.body.new);
  res.redirect('/');
}