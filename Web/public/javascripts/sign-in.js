/*
 * Handles the sign in button press
 */
function toggleSignIn() {
  if (firebase.auth().currentUser) {
    firebase.auth().signOut();
  } else {
    var email = document.getElementById('email').value;
    var password = document.getElementById('password').value;
    if (email.length < 4 || !email.includes(".")) {
      alert('Please enter an email address.');
      return;
    }
    if (password.length < 4) {
      alert('Please enter a password.');
      return;
    }
    firebase.auth().signInWithEmailAndPassword(email, password).catch(function(error) {
      var errorCode = error.code;
      var errorMessage = error.message;
      if (errorCode === 'auth/wrong-password') {
        alert('Wrong password.');
      } else {
        alert(errorMessage);
      }

      console.log(error);
      document.getElementById('sign-in').disabled = false;
    });
  }
  document.getElementById('sign-in').disabled = true;
}

/*
 * Sends a verification email to the user
 */
function sendEmailVerification() {
  firebase.auth().currentUser.sendEmailVerification().then(function() {
    alert('Email Verification Sent!');
  });
}

/*
 * Changes the user's email
 */
 function changeEmailRequest() {
  firebase.auth().currentUser.updateEmail(document.getElementById('newEmail').value)
    .then(() => {
      alert ('email changed');
    })
    .catch ((err) => {
      console.log (err);
    })
 }

/*
 * Sends a password reset email to the user
 */
function sendPasswordReset() {
  var email = firebase.auth().currentUser.email;

  firebase.auth().sendPasswordResetEmail(email).then(function() {
    alert('Password Reset Email Sent!');
  }).catch(function(error) {
    var errorCode = error.code;
    var errorMessage = error.message;
    
    if (errorCode === 'auth/invalid-email') {
      alert(errorMessage);
    } else if (errorCode === 'auth/user-not-found') {
      alert(errorMessage);
    }
    console.log(error);
  });
}

/*
 * initApp handles setting up the page
 */
function initApp() {
  firebase.auth().onAuthStateChanged(function(user) {
    document.getElementById('verify-email').disabled = true;
    if (user) {
      var displayName = user.displayName;
      var email = user.email;
      var emailVerified = user.emailVerified;
      var uid = user.uid;
      
      document.getElementById('sign-in').textContent = 'Sign out';
      document.getElementById('name-display').textContent = 'Name: ' + displayName;
      document.getElementById('name-display').style = 'display:block;margin-bottom:0';
      document.getElementById('email-display').textContent = 'Email: ' + email;
      document.getElementById('email-display').style = 'display:block;margin-top:0';
      if (!emailVerified) {
        document.getElementById('verify-email').disabled = false;
      }
    } else {
      document.getElementById('sign-in').textContent = 'Sign in';
      document.getElementById('account-details').textContent = 'null';
    }
    document.getElementById('sign-in').disabled = false;
  });

  document.getElementById('sign-in').addEventListener('click', toggleSignIn, false);
  document.getElementById('verify-email').addEventListener('click', sendEmailVerification, false);
  document.getElementById('password-reset').addEventListener('click', sendPasswordReset, false);
}

window.onload = function() {
  initApp();
};