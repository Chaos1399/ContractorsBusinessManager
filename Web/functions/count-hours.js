const admin = require('firebase-admin');

var serviceAccount = require('../../../contractor-s-business-manager-firebase-adminsdk-1stxo-d20fe1fc82.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://contractor-s-business-manager.firebaseio.com'
});

console.log(done);