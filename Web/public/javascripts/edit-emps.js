var uidDict = {};
var dbref = firebase.database().ref('Businesses');
const getUserClaims = firebase.functions().httpsCallable('getUserClaims');
const setUserClaims = firebase.functions().httpsCallable('setUserClaims');
var expanded = false;
var justOpened = false;

/*
 * Function to initialize the dropdown selector for employees and the custom
 * confirm modal
 */
function initPage() {
	const modal = document.getElementById('confirmModal');
	const cancel = document.getElementById('close');
	const mYes = document.getElementById('mYes');
	const mNo = document.getElementById('mNo');
	const empToEdit = document.getElementById('emp').value;
	const pph = document.getElementById('pphfield').value;
	const st = document.getElementById('sicktime').value;
	const vt = document.getElementById('vacationtime').value;
	var administrator = document.getElementById('administrator').checked;

	cancel.onclick = () => {
		modal.style.display = "none";
	}
	mYes.onclick = () => {
		modal.style.display = "none";
		didPressYes (
			document.getElementById('emp').value,
			document.getElementById('pphfield').value,
			document.getElementById('sicktime').value,
			document.getElementById('vacationtime').value,
			document.getElementById('administrator').checked);
	}
	mNo.onclick = () => {
		modal.style.display = "none";
		didPressNo (
			document.getElementById('emp').value,
			document.getElementById('pphfield').value,
			document.getElementById('sicktime').value,
			document.getElementById('vacationtime').value);
	}

	firebase.auth().onAuthStateChanged ((user) => {
		if (user) {
			getUserClaims({uid: user.uid})
			.then((result) => {
				const claims = result.data;
				const list = document.getElementById('elist');
				var elem;

				dbref = dbref.child(claims.business);
				dbref.child('PersistenceStartup/Employees').orderByValue().once('value')
					.then((snap) => {
						if (snap.exists()) {
							snap.forEach((snapchild) => {
								// Associate their uid's with their names for db retrieval and setting later
								uidDict[snapchild.val()] = snapchild.key;

								elem = document.createElement('option');
								elem.value = snapchild.val();
								list.appendChild (elem);
							});
							console.log ('Finished Loading');
						}
					});
			});
		}
	});
}

/*
 * Function to handle field value initialization when an employee is selected
 */
function empSelected () {
	const uid = uidDict[document.getElementById('emp').value];

	alert ('Gathering Employee Role Data.');

	getUserClaims ({uid: uid})
		.then((result) => {
			const claims = result.data;

			document.getElementById('administrator').checked = claims.admin;
			document.getElementById('manager').checked = claims.roles.manager;
			document.getElementById('materials_runner').checked = claims.roles.materials_runner;
			document.getElementById('trailer_mover').checked = claims.roles.trailer_mover;
			document.getElementById('contractor').checked = claims.roles.contractor;
		})
		.then(() => { alert('Done.'); })
		.catch((err) => {
			console.log(err);
		});
}

/*
 * Function to handle confirm button press: verifies an employee is selected,
 * then presents admin status change modal if the admin checkbox is not equal
 * to the selected employee's admin status
 */
function didPressConfirm () {
	if (document.getElementById('emp').value == '') {
		alert ('Need to choose an employee.');
		return;
	}
	document.getElementById('confirmModal').style.display = "block";
}

/*
 * Function to handle custom modal Yes button press: calls the function to set
 * all of the changed information into the database
 */
function didPressYes (empToEdit, pph, st, vt, a) {
	const uid = uidDict[empToEdit];

	updateUser (uid, pph, st, vt, a);
}

/*
 * Function to handle custom modal No button press: checks if any fields have
 * information in them. if not, return, if so, then calls the function to set
 * all of the changed information into the database
 */
function didPressNo (empToEdit, pph, st, vt) {
	const uid = uidDict[empToEdit];

	updateUser (uid, pph, st, vt, '');
}

/*
 * Function to handle delete button press: removes the user from Firebase Auth
 * and the Database
 */
function didPressDelete () {
	const deleteEmp = firebase.functions().httpsCallable('deleteEmp');
	const uid = uidDict[document.getElementById('emp').value];

	deleteEmp({uid: uid})
		.then(() => {
			console.log ('Auth Removal Success');
		})
		.catch((err) => {
			console.log ('Auth Removal Error: ' + err);
		});
		
	dbref.child('Users/' + uid).set({})
		.then(() =>
		dbref.child('PersistenceStartup/Employees/' + uid).set({}))
		.then(() => {
			console.log ('Database Removal Success');
			alert ('Employee Successfully Removed!');
		})
		.catch((err) => {
			console.log (err);
		});
}

/*
 * Function to handle cancel button press: resets all fields
 */
function didPressCancel () {
	document.getElementById('pphfield').value = '';
	document.getElementById('emp').value = '';
	document.getElementById('sicktime').value = '';
	document.getElementById('vacationtime').value = '';

	document.getElementById('administrator').checked = false;
	document.getElementById('manager').checked = false;
	document.getElementById('materials_runner').checked = false;
	document.getElementById('trailer_mover').checked = false;
	document.getElementById('contractor').checked = false;
}

/*
 * Function to update the values in the Database, and Auth in the case of
 * an administrator status change
 */
function updateUser (uid, pph, st, vt, a) {
	var updates = {};
	var newclaims = {};

	if (pph !== '') {
		updates['/Users/' + uid + '/pph'] = pph;
	}
	if (st !== '') {
		updates['/Users/' + uid + '/sicktime'] = st;
	}
	if (vt !== '') {
		updates['/Users/' + uid + '/vacaytime'] = vt;
	}
	if (a !== '') {
		updates['/Users/' + uid + '/admin'] = a;
	}

	getUserClaims({uid: uid})
		.then((result) => {
			const claims = result.data;
			var newroles = getRoles();

			newclaims['admin'] = (a !== '')? a : claims.admin;
			newclaims['business'] = claims.business;
			newclaims['roles'] = newroles;
		})
		.then(() => {
			setUserClaims({uid: uid, claims: newclaims});
		})
		.then(() => {
			console.log('Claims Update Success');
		})
		.catch((err) => {
			console.log(err);
			alert (err.message);
		});

	dbref.update(updates)
	.then (() => {
		console.log('Update complete.');
		alert('Employee Updated Successfully!');
	})
	.catch((err) => {
		console.log(err);
	});
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
	const materials_runner = document.getElementById('materials_runner').checked;
	const trailer_mover = document.getElementById('trailer_mover').checked;
	const contractor = document.getElementById('contractor').checked;
	var toret = {};

	toret['manager'] = manager;
	toret['materials_runner'] = materials_runner;
	toret['trailer_mover'] = trailer_mover;
	toret['contractor'] = contractor;

	return toret;
}



window.onload = function () {
	initPage();
}
window.onclick = function(event) {
	// Closes the custom confirm modal
  if (event.target == document.getElementById('confirmModal')) {
      document.getElementById('confirmModal').style.display = "none";
      return;
  }
  // Causes off-menu clicks to close the role-select list, if it's open
  if (expanded && !justOpened && event.target.className !== 'role') {
  	document.getElementById("roles").style.display = "none";
    expanded = false;
  }
}


