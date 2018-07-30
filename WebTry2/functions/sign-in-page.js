const functions = require ('firebase-functions');
const admin = require ('firebase-admin');
var serviceAccount = require ('./key/rangelincbsnssmngr-firebase-adminsdk-cbwgc-74b19be2ae.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://rangelincbsnssmngr.firebaseio.com'
});

const uid = 'GwD2FfuxOLWyELaBPPooc9ZKGWp2';

console.log('Hi');

exports.testOut = console.log('currentUser is: ' + firebase.auth().currentUser);