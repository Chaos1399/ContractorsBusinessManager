/*
 * Function to get URL query parameters
 * Taken from the number 1 answer on StackOverflow:
 * https://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
 */
function getParameterByName(name, url) {
  if (!url) url = window.location.href;
  name = name.replace(/[\[\]]/g, '\\$&');
  var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
      results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

/*
 * Function to initiate the page once it loads: gathers the URL parameters,
 * sets the source for the iframe, calls the appropriate functions.
 */
document.addEventListener ('DOMContentLoaded', function () {
  const iframe = document.getElementById('embeddedpage');
  iframe.width = document.body.clientWidth;

  // Get the action type
  var mode = getParameterByName('mode');
  // Get the one-time code from the query parameter
  var actionCode = getParameterByName('oobCode');
  // Get the API key from the query parameter, in case it's necessary
  var apiKey = getParameterByName('apiKey');
  // Get the continue URL from the query parameter if available, in case it's necessary
  var continueUrl = getParameterByName('continueUrl');

  // Configure the Firebase SDK.
  var auth = firebase.app().auth();

  // Handle the user management action.
  switch (mode) {
    case 'resetPassword':
      iframe.src = "./password_reset.html";
      verifyPasswordResetCode(auth, actionCode, continueUrl);
      break;
    case 'recoverEmail':
      iframe.src = "./recover_email.html";
      handleRecoverEmail(auth, actionCode);
      break;
    case 'verifyEmail':
      iframe.src = "./verify_email.html";
      handleVerifyEmail(auth, actionCode, continueUrl);
      break;
    default:
      // Error: invalid mode
  }
}, false);

/*
 * Function to verify the password reset code, then set the account header in the iframe
 */
function verifyPasswordResetCode(auth, actionCode, continueUrl) {
  auth.verifyPasswordResetCode(actionCode).then(function(email) {
    window.frames['embeddedpage'].contentDocument.getElementById('account').innerText = email;
  }).catch(function(err) {
    alert ('Expired or invalid link, please try again.');
    console.log (err);
  });
}

/*
 * Function to actually perform the password reset
 */
function handlePasswordReset(actionCode, newPassword, accountEmail) {
  var auth = firebase.app().auth();
  auth.confirmPasswordReset(actionCode, newPassword).then(function(resp) {
    alert ('Password Successfully Changed!');

    auth.signInWithEmailAndPassword(accountEmail, newPassword).catch((err) => {
      alert (err.message);
      console.log ('signInWithEmailAndPassword fail: ' + err);
    });

    // TODO: If a continue URL is available, display a button which on
    // click redirects the user back to the app via continueUrl with
    // additional state determined from that URL's parameters.
  }).catch((err) => {
    // Error occurred during confirmation. The code might have expired or the
    // password is too weak.
    alert (err.message);
    console.log('confirmPasswordReset fail: ' + err);
  });
}

/*
 * Function to handle email recovery
 */
function handleRecoverEmail(auth, actionCode) {
  var restoredEmail = null;
  auth.checkActionCode(actionCode).then(function(info) {
    restoredEmail = info['data']['email'];

    return auth.applyActionCode(actionCode);
  }).then(function() {
    alert ('Email Successfully Recovered!');

    const iframe = document.getElementById('embeddedpage');
    const button = iframe.contentWindow.document.getElementsByTagName('button')[0];
    button.onclick = function () {
      auth.sendPasswordResetEmail(restoredEmail)
        .then(function() {
          alert ('Password reset email sent, please check your inbox to proceed.');
        }).catch(function(error) {
          console.log (err);
        });
      setInDB (restoredEmail);
    }
  }).catch((err) => {
    console.log(err);
  });
}

/*
 * Function to handle updating the employee's email in the database
 */
function setInDB (email) {
  const dbref = firebase.database().ref('Businesses');
  const getUserClaims = firebase.functions().httpsCallable('getUserClaims');
  const uid = firebase.auth().currentUser.uid

  getUserClaims({uid: uid})
    .then((result) => {
      const claims = result.data;

      dbref.child(claims.business + '/Users/' + uid).update({
        email: email
      })
    })
    .catch ((err) => {
      console.log (err);
    });
}

/*
 * Function to verify the action code
 */
function handleVerifyEmail(auth, actionCode, continueUrl) {
  auth.applyActionCode(actionCode).then(function(resp) {

    // TODO: If a continue URL is available, display a button which on
    // click redirects the user back to the app via continueUrl with
    // additional state determined from that URL's parameters.
  }).catch((err) => {
    // Code is invalid or expired. Ask the user to verify their email address
    // again.
    alert (err.message);
    console.log('applyActionCode error: ' + err);
  });
}