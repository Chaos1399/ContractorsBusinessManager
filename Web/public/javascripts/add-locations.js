/*
 * Function to handle confirm button press: verifies that all fields are filled,
 * adds the new location to the database
 */
function didPressConfirm () {
	const client = document.getElementById('client').value;
	const streetaddress = document.getElementById('streetaddress').value;
	const city = document.getElementById('city').value;
	const alias = document.getElementById('alias').value;
	const getUserClaims = firebase.functions().httpsCallable('getUserClaims');
	var dbref = firebase.database().ref('Businesses/');

	if (client === '' || streetaddress === '' || city === '') {
		alert ('All fields must be filled');
		return;
	}

	getUserClaims({uid: firebase.auth().currentUser.uid})
		.then((result) => {
			const business = result.data.business;
			var updates = {};
			var lid, cid;

			dbref = dbref.child(business);

			dbref.child('Clients').once('value')
				.then((snap) => {
					if (snap.exists()) {
						snap.forEach((snapchild) => {
							if (snapchild.val().name === client) {
								cid = snapchild.key;
								lid = snapchild.val().numProps;
								updates['/numProps'] = (lid + 1);
							}
						})
					}
				})
				.then(() => dbref.child('Locations/' + cid + '/' + lid).set({
					city: city,
					jobs: dbref.child('Jobs/' + lid).toString(),
					numJobs: 0,
					streetAddress: streetaddress,
					alias: alias
				}))
				.then(() => {
					dbref.child('Clients/' + cid).update(updates);
				})
				.then(() => {
					console.log ('Database Add Successful');
					alert ('Location Successfully Added!');
				})
				.catch((err) => {
					console.log('Database Add Error: ' + err);
				})

		})
}

/*
 * Function to handle cancel button press: resets all fields
 */
function didPressCancel () {
	document.getElementById('client').value = '';
	document.getElementById('streetaddress').value = '';
	document.getElementById('city').value = '';
}