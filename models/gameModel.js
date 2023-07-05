const connection = require('../config/database');

const gameModel = {};

// Fonction pour obtenir un jeu spécifique par son ID
gameModel.getGameById = (gameId) => {
    return new Promise((resolve, reject) => {
        const sql = "SELECT * FROM games WHERE id = ?";
        connection.query(sql, [gameId], (err, result) => {
            if (err) reject(err);
            resolve(result);
        });
    });
}

// Fonction pour obtenir tous les jeux
gameModel.getAllGames = () => {
    return new Promise((resolve, reject) => {
        const sql = "SELECT * FROM games";
        connection.query(sql, (err, results) => {
            if (err) reject(err);
            resolve(results);
        });
    });
}

// Fonction pour créer un nouveau jeu
gameModel.createGame = (gameName, userId) => {
    return new Promise((resolve, reject) => {
        const sql = "INSERT INTO games (nom, user_id) VALUES (?, ?)";
        connection.query(sql, [gameName, userId], (err, result) => {
            if (err) reject(err);
            resolve(result);
        });
    });
}

// Fonction pour supprimer un jeu par son ID
gameModel.deleteGameById = (gameId) => {
    return new Promise((resolve, reject) => {
        const sql = "DELETE FROM games WHERE id = ?";
        connection.query(sql, [gameId], (err, result) => {
            if (err) reject(err);
            resolve(result);
        });
    });
}

// Fonction pour mettre à jour le nom d'un jeu
gameModel.updateGameName = (gameId, gameName) => {
    return new Promise((resolve, reject) => {
        const sql = "UPDATE games SET nom = ? WHERE id = ?";
        connection.query(sql, [gameName, gameId], (err, result) => {
            if (err) reject(err);
            resolve(result);
        });
    });
}

module.exports = gameModel;
