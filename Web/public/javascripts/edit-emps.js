document.addEventListener ('DOMContentLoaded', () =>{
	initPage();
})

var uidDict = {};
var dbref = firebase.database().ref('Businesses');

/*
 * Function to initialize the dropdown selector for employees and the custom
 * confirm modal
 */
function initPage() {
	const getUserClaims = firebase.functions().httpsCallable('getUserClaims');
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
	window.onclick = function(event) {
	    if (event.target == modal) {
	        modal.style.display = "none";
	    }
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
							snap.forEach(function (snapchild) {
								// Associate their uid's with their names for db retrieval and setting later
								uidDict[snapchild.val()] = snapchild.key;
								/*uidDict.push({
									key: snapchild.val(),
									value: snapchild.key});*/

								elem = document.createElement('option');
								elem.value = snapchild.val();
								list.appendChild (elem);
							});
							console.log ('Finished Loading');
						}
					});
			});
		}
	})
}

/*
 * Function to handle confirm button press: verifies at least one field is
 * filled, alerts the user what they are going to change, then calls setInDB
 */
function didPressConfirm () {
	if (document.getElementById('emp').value == '') {
		alert ('Need to choose an employee.');
		return;
	}
	document.getElementById('confirmModal').style.display = "block";
}

function didPressYes (empToEdit, pph, st, vt, a) {
	const uid = uidDict[empToEdit];

	setInDB (uid, pph, st, vt, a);
}

function didPressNo (empToEdit, pph, st, vt) {
	if (pph === '' && st === '' && vt === '') {
		return;
	}

	const uid = uidDict[empToEdit];

	setInDB (uid, pph, st, vt, '');
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
		})
		.catch((err) => {
			console.log ('Database Removal Error: ' + err);
		});
}

/*
 * Function to update the values in the Database, and Auth in the case of
 * an administrator status change
 */
function setInDB (uid, pph, st, vt, a) {
	var updates = {};

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

	dbref.update(updates)
	.then (() => {
		console.log('Update complete.');
	})
	.catch((err) => {
		console.log(err);
	});
}

/*
 * Function to get the DataSnapshot from the database
 */
/*readFromDB(uid).then((snap) => {
	//can use snap.val()
});*/
function readFromDB (uid) {
	return dbref.child('Users/' + uid).once('value');
}


