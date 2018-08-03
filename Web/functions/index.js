const functions = require ('firebase-functions');
const admin = require ('firebase-admin');
const crypto = require ('crypto-random-string');

/*
 * Service Account is specific to the project's location in Firebase. To use
 * with another project, need to 'Generate a private key' from the Service
 * Account section of project settings on the Firebase Console, then move
 * the json into a subfolder of the project parent directory, then add that
 * relative path here in the require. 'databaseURL' is the URL of the Firebase
 * Database.
 */
const serviceAccount = require ('./key/contractor-s-business-manager-firebase-adminsdk-1stxo-17d27be284.json');
const app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://contractor-s-business-manager.firebaseio.com'
});


/*
 * Email verification must be initiated by the user that needs their email
 * verified, so in the employee version apps
 */


/*
 * Function to set Custom Claims, specified by the passed in 'claims'
 * on the user specified by the passed in 'uid'.
 */
exports.setClaimsOnNewUser = functions.https.onCall((data, context) => {
	var uid = data.uid;
	var claims = data.claims;

	admin.auth().setCustomUserClaims(uid, claims)
  .then(function () {
    console.log('Claims set for employee ' + uid);
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
	  	return userRecord.customClaims;
	  });
})

/*
 * Function to create an employee with the passed 'email', 'empname',
 * and 'password', and makes them admin or not based on the passed 'admin'
 * value, and assigns them to the correct company based on the company to which
 * the logged in admin belongs
 */
exports.createEmp = functions.https.onCall((data, context) => {
	const email = data.email;
	const name = data.empname;
	const password = crypto (8);
	const administrator = data.admin;
	var business = data.business;

	if (email == null || name == null || password == null || admin == null) {
		return Promise.reject(new Error('Empty field'));
	}

	return admin.auth().createUser({
	  email: email,
	  emailVerified: false,
	  password: password,
	  displayName: name
	})
	  .then((userRecord) => {
	    console.log("Successfully created new employee: ", userRecord.uid);
	    return admin.auth().setCustomUserClaims(userRecord.uid, {admin: administrator, business: business})
			  .then(function () {
			    console.log('Claims set for employee: ' + userRecord.uid);

					return {pass: password, uid: userRecord.uid};
			  });
	  })
	  .catch((err) => {
	  	console.log (err);
	  	throw (err);
	  });
});






