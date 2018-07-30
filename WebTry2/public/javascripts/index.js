const functions = require ('firebase-functions');
const admin = require ('firebase-admin');
//const serviceAccount = require ('../../../contractor-s-business-manager-firebase-adminsdk-1stxo-d20fe1fc82.json');

const app = admin.initializeApp(functions.config().firebase);

const uid = 'MoaOT0dgtaXDkJYXFw5Gcgvm4Qv1';

admin.auth().setCustomUserClaims(uid, {admin: true}).then(() => {
  
});

admin.auth().getUser(uid).then((userRecord) => {
  console.log(userRecord.customClaims.admin);
});

exports.app = functions.https.onRequest((req, res) => {
  
});