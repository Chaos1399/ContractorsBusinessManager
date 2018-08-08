/*
 * Function to handle confirm button press: verifies that all fields are filled,
 * adds the new client to the database
 */
function didPressConfirm () {
	const name = document.getElementById('name').value;
	const email = document.getElementById('email').value;
	const address = document.getElementById('address').value;
	const getUserClaims = firebase.functions().httpsCallable('getUserClaims');
	var dbref = firebase.database().ref('Businesses/');

	if (name === '' || email === '' || address === '') {
		alert ('All fields must be filled');
		return;
	}

	getUserClaims({uid: firebase.auth().currentUser.uid})
		.then((result) => {
			const business = result.data.business;

			dbref = dbref.child(business);
			var updates = {};

			dbref.child('PersistenceStartup/Clients').once('value')
				.then((snap) => {
					const cid = snap.numChildren() + 1;
					updates['/' + cid] = name;

					dbref.child('PersistenceStartup/Clients').update(updates);
					dbref.child('Clients/' + cid).set ({
						name: name,
						email: email,
						address: address,
						properties: dbref.toString() + '/Locations/' + cid,
						numProps: 0
					})
					.then (() => {
						console.log('Database Add Successful');
						document.getElementById('name').value = '';
						document.getElementById('email').value = '';
						document.getElementById('address').value = '';
						alert ('Client added successfully!');
					})
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
	document.getElementById('name').value = '';
	document.getElementById('email').value = '';
	document.getElementById('address').value = '';
}