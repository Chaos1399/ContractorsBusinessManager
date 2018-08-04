/*
 * Function to handle confirm button press: verifies all fields are filled,
 * reauthenticates user, verifies the new and confirm passwords are the same,
 * then calls the handlePasswordReset function from the outer page.
 */
function verifyOldPassword () {
const oldPass = document.getElementById('oldpass').value;
const newPass = document.getElementById('newpass').value;
const confPass = document.getElementById('confpass').value;

if (oldPass === '' || newPass === '' || confPass === '') {
	alert ('All fields need to be filled.');
	return;
}

const email = firebase.auth().currentUser.email;
const cred = firebase.auth.EmailAuthProvider.credential(email, oldPass);

firebase.auth().currentUser.reauthenticateAndRetrieveDataWithCredential(cred)
		.then(() => {
			if (newPassword === confPassword) {
				window.parent.handlePasswordReset(
					window.parent.getParameterByName('oobCode'),
					newPass,
					email);
			} else {
				alert('Passwords don\'t match');
			}
		})
		.catch((err) => {
			console.log(err);
		});
}

/*
 * Function to handle cancel button press: resets all fields
 */
function didPressCancel () {
document.getElementById('oldpass').value = '';
document.getElementById('newpass').value = '';
document.getElementById('confpass').value = '';
}