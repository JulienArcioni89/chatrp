const express = require('express');
const connection = require('./config/database.js');
const bodyParser = require('body-parser');
const app = express();

// Controllers
const userController = require('./controllers/userController');
const gameController = require('./controllers/gameController');
const characterController = require('./controllers/characterController');

app.use(bodyParser.json());
app.use(express.json());

// Routes
app.use('/users', userController(connection));
app.use('/games', gameController);
app.use('/characters', characterController);


// Définis les routes de ton API
app.get('/', (req, res) => {
    res.send('API fonctionne !');
});

// Écoute sur un port spécifique
const port = 3000;
app.listen(port, () => {
    console.log(`Serveur API démarré sur le port ${port}`);
});
