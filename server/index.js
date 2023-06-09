const express = require('express');
const connection = require('./config/database.js');
const bodyParser = require('body-parser');
const app = express();

// Controllers
const userController = require('./controllers/userController');
const gameController = require('./controllers/gameController');
const characterController = require('./controllers/characterController');
const chatController = require('./controllers/chatController');
const convController = require('./controllers/convController');
const {authenticateToken} = require("./middleware/auth.middleware");

app.use(bodyParser.json());
app.use(express.json());

// Routes
app.use('/users', userController);
app.use('/games', gameController);
app.use('/characters', characterController);
app.use('/chat', chatController);
app.use('/conv', convController);

// Middleware
app.use(authenticateToken);



// Définis les routes de l'API
app.get('/', (req, res) => {
    res.send('API fonctionne !');
});

const port = 3000;
app.listen(port, () => {
    console.log(`Serveur API démarré sur le port ${port}`);
});