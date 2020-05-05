var express = require('express');
var router = express.Router();

let control = require('../controllers/control');
let home = require('../controllers/home');

/* GET home page. */
router.get('/', home.index);

router.get('/new', control.new_record);
router.post('/new', control.submit_record);

router.get('/transfer', control.transfer_record);
router.post('/transfer', control.submit_transfer);

router.get('/retrieve', control.retrieve_record);
router.post('/retrieve', control.submit_retrieve);

router.get('/count', control.get_decrement);
router.post('/count', control.decrement_record);

router.get('/status', control.change_status);
router.post('/status', control.submit_status);

router.get('/description', control.change_description);
router.post('/description', control.submit_description);

router.get('/note', control.add_note);
router.post('/note', control.submit_note);

router.get('/force', control.force_mod);
router.post('/force', control.submit_mod);

module.exports = router;
