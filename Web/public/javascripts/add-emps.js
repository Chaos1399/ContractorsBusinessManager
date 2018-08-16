var expanded = false;
var justOpened = false;

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
 * Function to handle confirm button press: Gather's the form data and creates a new
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
	const setUserClaims = firebase.functions().httpsCallable('setUserClaims');
	const db = firebase.database().ref;
	var uid = false;
	var updates = {};

	alert ('Adding Employee ' + name + '...');

	firebase.auth().onAuthStateChanged ((user) => {
	  if (user) {
	    getUserClaims({uid: user.uid})
	      .then ((result) => {
	        const claims = result.data;
	        business = claims.business;
					const dbbase = firebase.database().ref('Businesses/' + business);

					// Adding to Firebase Auth
	        createEmp({empname: name, email: email,
	                   admin: admin, business: business})
	        	// Adding to Firebase Database
	          .then((result) => {
	          	console.log (name + ' added to Firebase Auth');
							uid = result.data.uid;

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
									console.log(name + ' added to Firebase Database');
								});

							updates [uid] = name;

							dbbase.child('PersistenceStartup/Employees').update(updates);
							
	            alert ('Employee ' + name + ' successfully added.\n' +
	            	'Your employee\'s temporary password is ' + result.data.pass +
	            	'\nPlease encourage them to change it as soon as possible.');
	          })
	          // Adding Roles to Auth Claims
	          .then(() => {
	          	var newclaims = {};

	          	newclaims['admin'] = admin;
	          	newclaims['business'] = business;
	          	newclaims['roles'] = getRoles();

	          	setUserClaims({uid: uid, claims: newclaims})
	          		.catch((err) => {
	          			console.log (err);
	          			alert (err.message);
	          		});
	          })
	          .catch((err) => {
	          	console.log (err);
	            alert ('Error adding employee, please retry.');
	          });
	      })
	      .catch ((err) => {
	        console.log ('Error when getting User Claims\n' + err);
	      });
	  }
	});
}

/*
 * Function to handle cancel button press: resets all fields
 */
function didPressCancel () {
  document.getElementById('name').value = '';
  document.getElementById('email').value = '';
  document.getElementById('pph').value = '';
  document.getElementById('admin').checked = false;

	document.getElementById('administrator').checked = false;
	document.getElementById('manager').checked = false;
	document.getElementById('materials-runner').checked = false;
	document.getElementById('trailer-mover').checked = false;
	document.getElementById('contractor').checked = false;
}

/*
 * Function to handle role dropdown menu
 */
function showRoles() {
  var roles = document.getElementById("roles");
  if (!expanded) {
    roles.style.display = "block";
    expanded = true;
    justOpened = true;
    setTimeout(function () { justOpened = false }, 50);
  } else {
    roles.style.display = "none";
    expanded = false;
    justOpened = false;
  }
}

/*
 * Function to retrieve all role values and return them as a dictionary
 */
function getRoles () {
	const manager = document.getElementById('manager').checked;
	const materials_runner = document.getElementById('materials-runner').checked;
	const trailer_mover = document.getElementById('trailer-mover').checked;
	const contractor = document.getElementById('contractor').checked;
	var toret = {};

	toret['manager'] = manager;
	toret['materials_runner'] = materials_runner;
	toret['trailer_mover'] = trailer_mover;
	toret['contractor'] = contractor;

	return toret;
}



window.onclick = function(event) {
  if (expanded && !justOpened && event.target.className !== 'role') {
  	document.getElementById("roles").style.display = "none";
    expanded = false;
  }
}



