require('dotenv').config({path: '.env'});

const mysql = require('mysql');
const password_BDD = process.env.PASSWORD_BDD_ROOT;

// Créer une connexion à la base de données avec un utilisateur possédant tous les droits
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: password_BDD,
    database: 'openai',
    port: 8889
});


// DROITS LIMITES
/*const connection = mysql.createConnection({
    host: 'localhost',
    user: 'openai',
    password: 'restricted',
    database: 'openai',
    port: 8889
});*/

// Établir la connexion à la base de données
connection.connect((error) => {
    if (error) {
        console.error('Erreur lors de la connexion à la base de données :', error);
        return;
    }
    console.log('Connexion à la base de données établie.');
});

module.exports = connection;