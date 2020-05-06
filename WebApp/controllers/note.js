exports.add_note = function(req, res, next) {
  res.render('add_note', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_note = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("Permenant Note", req.body.note);
  res.redirect('/');
}
