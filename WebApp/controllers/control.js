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

exports.transfer_record = function(req, res, next) {
  res.render('transfer_record', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_transfer = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Old Rights holder", req.body.old);
  console.log("New Rights holder", req.body.new);
  res.redirect('/');
}

exports.retrieve_record = function(req, res, next) {
  res.render('retrieve_record', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_retrieve = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  res.redirect('/');
}

exports.get_decrement = function(req, res, next) {
  res.render('get_decrement', { title: 'Bulletproof Asset Provenance' });
}

exports.decrement_record = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("Decrement Amount", req.body.decrement);
  res.redirect('/');
}

exports.change_status = function(req, res, next) {
  res.render('change_status', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_status = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("New Status", req.body.status);
  res.redirect('/');
}

exports.change_description = function(req, res, next) {
  res.render('change_description', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_description = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("New Description", req.body.description);
  res.redirect('/');
}

exports.add_note = function(req, res, next) {
  res.render('add_note', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_note = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("Rights Holder", req.body.rightsHolder);
  console.log("Permenant Note", req.body.note);
  res.redirect('/');
}

exports.force_mod = function(req, res, next) {
  res.render('force_mod', { title: 'Bulletproof Asset Provenance' });
}

exports.submit_mod = function(req, res, next) {
  console.log("Asset Id", req.body.assetId);
  console.log("New Rights holder", req.body.new);
  res.redirect('/');
}

