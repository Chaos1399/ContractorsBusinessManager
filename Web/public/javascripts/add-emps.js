/*
 * Function to get the currently signed in user, checks to ensure that they
 * are marked as an admin, and then enables the button if so, or sends an alert
 * to the screen if they aren't, or aren't signed in.
 */
firebase.auth().onAuthStateChanged(function(user) {
	if (user) {
		const getUserClaims = firebase.functions().httpsCallable('getUserClaims');

		getUserClaims({uid: user.uid})
			.then((result) => {
				const claims = result.data;

				if (claims != null && claims.admin === true) {
					document.getElementById('confirm').disabled = false;
				} else {
					alert ('Only an administrator for your company can add new employees.');
				}
			});
	} else {
		alert ('You must be signed in to add employees for your company.');
	}
});

/*
 * OnClick for the confirm button: Gather's the form data and creates a new
 * employee with it, alerting the admin to the employee's temporary password
 */
function didPressConfirm () {
	const name = document.getElementById('name').value;
	const email = document.getElementById('email').value;
	const pph = document.getElementById('pph').value;
	const admin = document.getElementById('admin').checked;
	var business = "";
	const createEmp = firebase.functions().httpsCallable('createEmp');
	const getUserClaims = firebase.functions().httpsCallable('getUserClaims');
	const setClaimsOnNewUser = firebase.functions().httpsCallable('setClaimsOnNewUser');
	const db = firebase.database().ref;

	firebase.auth().onAuthStateChanged ((user) => {
	  if (user) {
	    getUserClaims({uid: user.uid})
	      .then ((result) => {
	        const claims = result.data;
	        business = claims.business;
					const dbbase = firebase.database().ref('Businesses/' + business);

	        createEmp({empname: name, email: email,
	                   admin: admin, business: business})
	          .then((result) => {
							const uid = result.data.uid;

							dbbase.child('Users/' + uid).set ({
								name: name,
								email: email,
								admin: admin,
								numDays: 0,
								numPers: 0,
								payPeriodHistory: dbbase.child('PayPeriodHistories/' + uid).toString(),
								pph: pph,
								scheduled: dbbase.child('Schedules/' + uid).toString(),
								sicktime: 0,
								vacaytime: 0
							})
								.then(() => {
									console.log('Successful add to database.');
								})
								.catch((err) => {
									console.log('Database write failed: ' + err);
								});
	            console.log('Successful return from createEmp');
	            alert ('Employee ' + name + ' successfully added.\n' +
	            	'Your employee\'s temporary password is ' + result.data.pass);
	          })
	          .catch((err) => {
	          	console.log ('createEmp failed: ' + err)
	            alert ('Error adding employee.');
	          });
	      })
	      .catch ((err) => {
	        console.log (err);
	      });
	  }
	});
}

/*
 * OnCLick for the cancel button
 */
function didPressCancel () {
  document.getElementById('name').value = '';
  document.getElementById('email').value = '';
  document.getElementById('pph').value = '';
  document.getElementById('admin').checked = false;
}



