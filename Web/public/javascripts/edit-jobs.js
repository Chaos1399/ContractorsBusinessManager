var cidDict = {};
var lidDict = {};
var jidDict = {};
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
			} else {
				throw new Error ('Path not found, please check your spelling.');
			}
		})
		.catch((err) => {
			console.log (err);
			alert (err.message);
		});
}

/*
 * Function to handle job list initialization when a location is selected
 */
function locationSelected (loc) {
	const list = document.getElementById('jlist');
	var elem;

	while (list.firstChild) {
		list.removeChild(list.firstChild);
	}

	dbref.child('Jobs/' +
							cidDict[document.getElementById('client').value] +
							'/' + lidDict[loc]).orderByValue().once('value')
		.then((snap) => {
			if (snap.exists()) {
				snap.forEach((snapchild) => {
					jidDict[snapchild.val().type] = snapchild.key;

					elem = document.createElement('option');
					elem.value = snapchild.val().type;
					list.appendChild (elem);
				})
			} else {
				throw new Error ('Path not found, please check your spelling.');
			}
		})
		.catch((err) => {
			console.log(err);
			alert (err.message);
		})
}

/*
 * Function to handle field value initialization when a job is selected
 */
function jobSelected (job) {
	dbref.child('Jobs/' +
							cidDict[document.getElementById('client').value] + '/' +
							lidDict[document.getElementById('location').value] + '/' +
							jidDict[job]).once('value')
		.then((snap) => {
			if (snap.exists()) {
				const jobSnap = snap.val();

				document.getElementById('type').value = jobSnap.type;
				document.getElementById('start').value = jobSnap.start;
				document.getElementById('end').value = jobSnap.end;
				document.getElementById('desc').value =
					(jobSnap.details === undefined)? '' : jobSnap.details;
			} else {
				throw new Error ('Path not found, please check your spelling.');
			}
		})
		.catch((err) => {
			console.log (err);
			alert (err.message);
		})
}

/*
 * Function to handle confirm button press: verifies a client and location were
 * selected, verifies at least one field is filled, then updates the Database
 */
function didPressConfirm () {
	const client = document.getElementById('client').value;
	const location = document.getElementById('location').value;
	const jobToEdit = document.getElementById('job').value;
	const newType = document.getElementById('type').value;
	const newStart = document.getElementById('start').value;
	const newEnd = document.getElementById('end').value;
	const newDesc = document.getElementById('desc').value;
	var updates = {};

	if (client === '') {
		alert ('You must choose a client whose location you wish to edit.');
		return;
	} else if (location === '') {
		alert ('You must choose a location to edit.');
		return;
	} else if (jobToEdit === '') {
		alert ('You must choose a job to edit.');
		return;
	}

	if (newType !== '') {
		updates['/type'] = newType;
	}
	if (newStart !== '') {
		updates['/start'] = newStart;
	}
	if (newEnd !== '') {
		updates['/end'] = newEnd;
	}
	if (newDesc !== '') {
		updates['/details'] = newDesc;
	}

	dbref.child('Jobs/' + cidDict[client] +
							'/' + lidDict[location] +
							'/' + jidDict[jobToEdit]).update(updates)
		.then(() => {
			console.log('Job Update Success');
			alert('Successfully Updated Job!');
		})
		.catch((err) => {
			console.log (err);
			alert(err.message);
		})
}

/*
 * Function to handle cancel button press: resets all fields
 */
function didPressCancel () {
	document.getElementById('client').value = '';
	document.getElementById('location').value = '';
	document.getElementById('job').value = '';
	document.getElementById('type').value = '';
	document.getElementById('start').value = '';
	document.getElementById('end').value = '';
	document.getElementById('desc').value = '';
}

/*
 * Function to handle delete button press: removes chosen job from the Jobs
 * section of the Database, decrements the location's job counter, 
 */
function didPressDelete () {
	const cid = cidDict[document.getElementById('client').value];
	const lid = lidDict[document.getElementById('location').value];
	const jid = jidDict[document.getElementById('job').value];
	var updates = {};
	var numJobs = 0;

	if (cid === undefined) {
		alert ('Client not found, please check your spelling.');
		return;
	} else if (lid === undefined) {
		alert ('Location not found, please check your spelling.');
		return;
	} else if (jid === undefined) {
		alert ('Job not found, please check your spelling.');
		return;
	}

	dbref.child('Jobs/' + cid + '/' + lid + '/' + jid).once('value')
		.then((snap) => {
			if (snap.exists()) {
				dbref.child('Jobs/' + cid + '/' + lid + '/' + jid).set({})
					.then(() =>
						dbref.child('Locations/' + cid + '/' + lid).once('value')
							.then((snap) => {
								numJobs = snap.val().numJobs;
								updates['/numJobs'] = (numJobs - 1);
							}))
					.then(() =>
						dbref.child('Locations/' + cid + '/' + lid).update(updates))
					.then(() => {
						console.log('Job Removal Success');
						alert ('Successfully Removed Job!');
					})
					.catch ((err) => {
						console.log (err);
						alert (err.message);
					});
			} else {
				console.log('Job DNE');
				alert('Error Deleting: Job does not exist.');
			}
		});
}



window.onload = function () {
	initPage();
}