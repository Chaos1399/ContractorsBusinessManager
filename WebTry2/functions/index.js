const functions = require ('firebase-functions');
const admin = require ('firebase-admin');

/*
 * Service Account is specific to the project's location in Firebase. To use
 * with another project, need to 'Generate a private key' from the Service
 * Account section of project settings on the Firebase Console, then move
 * the json into a subfolder of the project parent directory, then add that
 * relative path here in the require. 'databaseURL' is the URL of the Firebase
 * Database.
 */
var serviceAccount = require ('./key/rangelincbsnssmngr-firebase-adminsdk-cbwgc-74b19be2ae.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://rangelincbsnssmngr.firebaseio.com'
});

/*
 * Function to set Custom Claims, specified by the passed in 'claims'
 * on the user specified by the passed in 'uid'.
 */
exports.setClaimsOnNewUser = functions.https.onCall((data, context) => {
	var uid = data.uid;
	var claims = data.claims;

	admin.auth().setCustomUserClaims(uid, claims)
  .then(function () {
    console.log('Claims set for user ' + uid);
  })
  .catch(function(err) {
  	console.log(err);
  });
});

/*
 * Function to get the Custom Claims associated with the user
 * specified by the passed in 'uid'.
 */
exports.getUserClaims = functions.https.onCall((data, context) => {
	var uid = data.uid;

	return admin.auth().getUser(uid)
	  .then((userRecord) => {
	  	console.log ('user claims:\n' + userRecord.customClaims);

	  	return userRecord.customClaims;
	  });
})
