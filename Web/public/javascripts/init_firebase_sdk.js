document.addEventListener('DOMContentLoaded', function() {
    // // The Firebase SDK is initialized and available here!
    //
    // firebase.auth().onAuthStateChanged(user => { });
    // firebase.database().ref('/path/to/ref').on('value', snapshot => { });

    try {
      let app = firebase.app();
    } catch (e) {
      console.error(e);
    }
});
