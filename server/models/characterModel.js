const connection = require('../config/database');

module.exports = {

    checkCharacterExistence: (nom) => {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM characters WHERE name = ?';
            connection.query(query, [nom], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

    createCharacter: (nom, id) => {
        return new Promise((resolve, reject) => {
            const query = 'INSERT INTO characters (name, game_id) VALUES (?, ?)';
            connection.query(query, [nom, id], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

    getGameById: (id) => {
        return new Promise((resolve, reject) => {
            const query = 'SELECT nom FROM games WHERE id = ?';
            connection.query(query, [id], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

    updateCharacterDescription: (description, characterId) => {
        return new Promise((resolve, reject) => {
            const query = 'UPDATE characters SET description = ? WHERE id = ?';
            connection.query(query, [description, characterId], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

    deleteCharacterById: (characterId) => {
        return new Promise((resolve, reject) => {
            const query = 'DELETE FROM characters WHERE id = ?';
            connection.query(query, [characterId], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

    getCharacterById: (characterId) => {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM characters WHERE id = ?';
            connection.query(query, [characterId], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

    getAllCharactersFromGame: (gameId) => {
        return new Promise((resolve, reject) => {
            const query = 'SELECT * FROM characters WHERE game_id = ?';
            connection.query(query, [gameId], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

    getCharacterNameById: (characterId) => {
        return new Promise((resolve, reject) => {
            const query = 'SELECT name FROM characters WHERE id = ?';
            connection.query(query, [characterId], (error, results) => {
                if (error) reject(error);
                resolve(results);
            });
        });
    },

};
