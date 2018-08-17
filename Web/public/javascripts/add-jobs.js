/*
 * Function to handle confirm button press: verifies that all fields are filled,
 * adds the new location to the database
 */
function didPressConfirm () {
  const client = document.getElementById('client').value;
  const streetaddress = document.getElementById('streetaddress').value;
  const city = document.getElementById('city').value;
  const alias = document.getElementById('alias').value;
  const jtype = document.getElementById('type').value;
  const start = document.getElementById('start').value;
  const end = document.getElementById('end').value;
  var desc = document.getElementById('desc').value;
  const useAlias = !(document.getElementById('aliasBlock').style.visibility === 'hidden');

  const getUserClaims = firebase.functions().httpsCallable('getUserClaims');
  var dbref = firebase.database().ref('Businesses/');

  if ((client === '') ||
     (!useAlias && (streetaddress === '' || city === '' )) ||
     (useAlias && alias === '') ||
     (jtype === '') ||
     (start === '') ||
     (end === '')) {
    alert ('All fields must be filled, with the exception\nof the Description field.');
    return;
  }

  if (desc === '') {
    desc = null;
  }

  getUserClaims({uid: firebase.auth().currentUser.uid})
    .then((result) => {
      const business = result.data.business;
      var updates = {};
      var cid, lid, jid;
      var wasFound = false;

      dbref = dbref.child(business);

      dbref.child('Clients').once('value')
        .then((snap) => {
          if (snap.exists()) {
            snap.forEach((snapchild) => {
              if (snapchild.val().name === client) {
                cid = snapchild.key;
              }
            })
          }
        })
        .then(() => dbref.child('Locations/' + cid).once('value'))
        .then((snap) => {
          if (snap.exists()) {
            snap.forEach((snapchild) => {
              if (useAlias && snapchild.val().alias === alias) {
                lid = snapchild.key;
                jid = snapchild.val().numJobs;
                updates['/numJobs'] = (jid + 1);
                wasFound = true;
                return true;
              } else if (!useAlias &&
                         snapchild.val().streetAddress === streetaddress &&
                         snapchild.val().city === city) {
                lid = snapchild.key;
                jid = snapchild.val().numJobs;
                updates['/numJobs'] = (jid + 1);
                wasFound = true;
                return true;
              }
            })
            if (!wasFound) {
                throw new Error('Location not found, please check your spelling.\nAlso, the correct location search type must be selected.');
              }
          }
        })
        .then(() => dbref.child('Locations/' + cid + '/' + lid).update(updates))
        .then(() => dbref.child('Jobs/' + cid + '/' + lid + '/' + jid).set({
          end: end,
          start: start,
          type: jtype,
          details: desc
        }))
        .then(() => {
          console.log('Database Add Successful');
          alert ('Job Added Successfully!');
        })
        .catch((err) => {
          alert (err.message);
          console.log ('Error Finding Location');
        });
    });
}

function didChangeLocSelectStyle () {
  const addressBtn = document.getElementById('addressBtn').checked;
  const addressBlock = document.getElementById('addressBlock');
  const aliasBlock = document.getElementById('aliasBlock');

  if (addressBtn) {
    addressBlock.style.visibility = "visible";
    aliasBlock.style.visibility = "hidden";
  } else {
    addressBlock.style.visibility = "hidden";
    aliasBlock.style.visibility = "visible";
  }
}

/*
 * Function to handle cancel button press: resets all fields
 */
function didPressCancel () {
  document.getElementById('client').value = '';
  document.getElementById('streetaddress').value = '';
  document.getElementById('city').value = '';
}