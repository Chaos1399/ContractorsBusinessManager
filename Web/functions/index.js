const admin = require ('firebase-admin');
const functions = require ('firebase-functions');

const express = require ('express');
const app = express();

admin.initializeApp();

app.get('/index.html', (request, response) => {
  response.send(`${Date.now()}`);
});

exports.app = functions.https.onRequest(app);

/*fs.readFile('index.html', (err, html) => {
  if (err) {
   throw err;
  }

  const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-type', 'text/html');
    res.write(html);
    res.end ();
  });

  server.listen(port, hostname, () => {
    console.log('Server started on port ' + port);
  });

});*/