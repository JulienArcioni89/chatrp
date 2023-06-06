const mysql = require('mysql');

// Créer une connexion à la base de données
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'root',
    database: 'openai',
    port: 8889
});

// Établir la connexion à la base de données
connection.connect((error) => {
    if (error) {
        console.error('Erreur lors de la connexion à la base de données :', error);
        return;
    }
    console.log('Connexion à la base de données établie.');
});

module.exports = connection;
