var cidDict = {};
var lidDict = {};
var numProps = 0;
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
 * Function to handle location list initialization when a client is selected
 */
function clientSelected (client) {
	const list = document.getElementById('llist');
	var elem;

	dbref.child('Locations/' + cidDict[client]).orderByValue().once('value')
		.then ((snap) => {
			if (snap.exists()) {
				snap.forEach((snapchild) => {
					lidDict[snapchild.val().streetAddress + ', ' +
									snapchild.val().city] = snapchild.key;

					elem = document.createElement('option');
					elem.value = snapchild.val().streetAddress + ', ' +
											 snapchild.val().city;
					list.appendChild (elem);
				})
			}
		})
		.catch((err) => {
			console.log (err);
		});
}

/*
 * Function to handle field value initialization when a location is selected
 */
function locationSelected (loc) {
	dbref.child('Locations/' +
							cidDict[document.getElementById('client')] +
							'/' + lidDict[loc]).orderByValue().once('value')
		.then((snap) => {
			if (snap.exists()) {
				const locSnap = snap.val();

				document.getElementById('streetaddress').value = locSnap.streetAddress;
				document.getElementById('city').value = locSnap.city;
				document.getElementById('alias').value = locSnap.alias;
			}
		})
		.catch((err) => {
			console.log(err);
		})
}

/*
 * Function to handle confirm button press: verifies a client was selected,
 * verifies at least one field is filled, then updates the Database
 */
function didPressConfirm () {
	const client = document.getElementById('client').value;
	const locToEdit = document.getElementById('location').value;
	const newAddress = document.getElementById('streetaddress').value;
	const newCity = document.getElementById('city').value;
	const newAlias = document.getElementById('alias').value;
	var updates = {};

	if (client === '') {
		alert ('You must choose a client whose location you wish to edit.');
		return;
	} else if (locToEdit === '') {
		alert ('You must choose a location to edit.');
		return;
	}

	if (newAddress !== '') {
		updates['/streetAddress'] = newAddress;
	}
	if (newCity !== '') {
		updates['/city'] = newCity;
	}
	if (newAlias !== '') {
		updates['/alias'] = newAlias;
	}

	dbref.child('/Locations/' + cidDict[client] + '/' + lidDict[locToEdit]).update(updates)
		.then(() => {
			console.log ('Location Update Success');
			alert ('Successfully Updated Location!');
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
	document.getElementById('client').value = '';
	document.getElementById('location').value = '';
	document.getElementById('streetaddress').value = '';
	document.getElementById('city').value = '';
	document.getElementById('alias').value = '';
}

/*
 * Function to handle delete button press: removes chosen location from the
 * Locations section of the Database, decrements the client's property count,
 * and removes all job listings for that location from the Jobs section of the
 * Database
 */
function didPressDelete () {
	const cid = cidDict[document.getElementById('client').value];
	const lid = lidDict[document.getElementById('location').value];
	var updates = {};

	if (lid === undefined) {
		alert ('Location not found, please check your spelling.');
		return;
	}

	dbref.child('Locations/' + cid + '/' + lid).set({})
		.then(() =>
			dbref.child('Clients/' + cid).once('value')
				.then((snap) => {
					numProps = snap.val().numProps;
					updates['/numProps'] = (numProps - 1);
				}))
		.then(() =>
			dbref.child('Clients/' + cid).update(updates))
		.then(() =>
			dbref.child('Jobs/' + cid + '/' + lid).set({}))
		.then(() => {
			console.log('Location Removal Success');
			alert ('Location Successfully Removed!');
		})
		.catch ((err) => {
			console.log (err);
			alert (err.message);
		})
}



window.onload = function () {
	initPage();
}