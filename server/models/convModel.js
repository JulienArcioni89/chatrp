const connection = require('../config/database');

const convModel = {};

// Fonction pour obtenir une conversation spécifique par son ID
convModel.getConversationById = (convId) => {
    return new Promise((resolve, reject) => {
        const sql = "SELECT * FROM chat WHERE id_conv = ?";
        connection.query(sql, [convId], (error, results) => {
            if (error) {
                reject(error);
            } else {
                resolve(results);
            }
        });
    });
};

// Fonction pour obtenir toutes les conversations
convModel.getAllConversations = () => {
    return new Promise((resolve, reject) => {
        const sql = "SELECT * FROM conversation";
        connection.query(sql, (error, results) => {
            if (error) {
                reject(error);
            } else {
                resolve(results);
            }
        });
    });
};

module.exports = convModel;
