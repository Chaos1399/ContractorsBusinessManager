var cidDict = {};
var expanded = false;
var justOpened = false;
var dbref = firebase.database().ref('Businesses');

/*
 * Function to initialize the dropdown selector for clients
 */
function initPage() {
	const clientToEdit = document.getElementById('client').value;
	const getUserClaims = firebase.functions().httpsCallable('getUserClaims');

	firebase.auth().onAuthStateChanged ((user) => {
		if (user) {
			getUserClaims({uid: user.uid})
			.then((result) => {
				const claims = result.data;
				const list = document.getElementById('clist');
				var elem;

				dbref = dbref.child(claims.business);
				dbref.child('PersistenceStartup/Clients').orderByValue().once('value')
					.then((snap) => {
						if (snap.exists()) {
							snap.forEach(function (snapchild) {
								// Associate their uid's with their names for db retrieval and setting later
								cidDict[snapchild.val()] = snapchild.key;

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
 * Function to handle field value initialization when a client is selected
 */
function clientSelected () {
	dbref.child('Clients/' + cidDict[document.getElementById('client').value]).orderByValue().once('value')
		.then ((snap) => {
			if (snap.exists()) {
				const clientSnap = snap.val();

				document.getElementById('name').value = clientSnap.name;
				document.getElementById('email').value = clientSnap.email;
				document.getElementById('address').value = clientSnap.address;
			} else {
				throw new Error ('Path not found, please check your spelling.');
			}
		})
		.catch ((err) => {
			console.log (err);
			alert (err.message);
		});
}

/*
 * Function to handle confirm button press: verifies a client was selected,
 * verifies at least one field is filled, then updates the Database
 */
function didPressConfirm () {
	const clientToEdit = document.getElementById('client').value;
	const newName = document.getElementById('name').value;
	const newEmail = document.getElementById('email').value;
	const newAddress = document.getElementById('address').value;
	var updates = {};

	if (clientToEdit === '') {
		alert ('You must choose a client to edit.');
		return;
	}

	if (newName !== '') {
		updates['/Clients/' + cidDict[clientToEdit] + '/name'] = newName;
		updates['/PersistenceStartup/Clients/' + cidDict[clientToEdit]] = newName;
	}
	if (newEmail !== '') {
		updates['/Clients/' + cidDict[clientToEdit] + '/email'] = newEmail;
	}
	if (newAddress !== '') {
		updates['/Clients/' + cidDict[clientToEdit] + '/address'] = newAddress;
	}

	dbref.update(updates)
		.then(() => {
			console.log ('Client Update Success');
			alert ('Successfully Updated Client!');
		})
		.catch ((err) => {
			console.log (err);
			alert (err.message);
		})
}

/*
 * Function to handle cancel button press: resets all fields
 */
function didPressCancel () {
	document.getElementById('name').value = '';
	document.getElementById('email').value = '';
	document.getElementById('address').value = '';
	document.getElementById('client').value = '';
}

/*
 * Function to handle delete button press: deletes the client from the Clients,
 * PersistenceStartup, Locations, and Jobs portions of the database, which
 * subsequently deletes all locations and jobs associated with that client
 */
function didPressDelete () {
	const cid = cidDict[document.getElementById('client').value];

	if (cid === undefined) {
		alert ('Client not found, please check your spelling.');
		return;
	}

	dbref.child('Clients/' + cid).once('value')
		.then((snap) => {
			if (snap.exists()) {
				dbref.child('Clients/' + cid).set({})
					.then(() =>
						dbref.child('PersistenceStartup/' + cid).set({}))
					.then(() =>
						dbref.child('Locations/' + cid).set({}))
					.then(() =>
						dbref.child('Jobs/ ' + cid).set({}))
					.then(() => {
						console.log('Client Removal Success');
						alert ('Client Successfully Removed!');
					})
					.catch ((err) => {
						console.log (err);
						alert (err.message);
					});
			} else {
				console.log('Client DNE');
				alert ('Error Deleting: Client does not exist.');
			}
		});
}



window.onload = function () {
	initPage();
}