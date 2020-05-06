exports.index = function(req, res, next) {
  res.render('home', { title: 'BulletProof' });
}
