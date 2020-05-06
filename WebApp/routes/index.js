var express = require('express');
var router = express.Router();
const web3 = require('web3');

//let control = require('../controllers/control');
let home = require('../controllers/home');
let new_record = require('../controllers/new');
let transfer = require('../controllers/transfer');
let retrieve = require('../controllers/retrieve');
let count = require('../controllers/count');
let status = require('../controllers/status');
let description = require('../controllers/description');
let note = require('../controllers/note');
let force = require('../controllers/force');

/* GET home page. */
router.get('/', home.index);

router.get('/new', new_record.new_record);
router.post('/new', new_record.submit_record);

router.get('/transfer', transfer.transfer_record);
router.post('/transfer', transfer.submit_transfer);

router.get('/retrieve', retrieve.retrieve_record);
router.post('/retrieve', retrieve.submit_retrieve);

router.get('/count', count.get_decrement);
router.post('/count', count.decrement_record);

router.get('/status', status.change_status);
router.post('/status', status.submit_status);

router.get('/description', description.change_description);
router.post('/description', description.submit_description);

router.get('/note', note.add_note);
router.post('/note', note.submit_note);

router.get('/force', force.force_mod);
router.post('/force', force.submit_mod);

module.exports = router;

connector.start().then(() => {
  // Now go to http://localhost:3333 in your MetaMask enabled web browser.
  const web3 = new Web3(connector.getProvider());
  // Use web3 as you would normally do. Sign transactions in the browser.
});
