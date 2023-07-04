const connection = require('../config/database');

const chatModel = {};

chatModel.deleteConversationById = (conversationId) => {
    return new Promise((resolve, reject) => {
        const deleteQuery = 'DELETE FROM conversation WHERE id = ?';
        connection.query(deleteQuery, [conversationId], (error, results) => {
            if (error) {
                return reject(error);
            }
            resolve(results);
        });
    });
};

chatModel.getConversationByUserIdAndCharacterId = (userId, characterId) => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM conversation WHERE user_id = ? AND character_id = ?';
        connection.query(query, [userId, characterId], (error, results) => {
            if (error) {
                return reject(error);
            }
            resolve(results);
        });
    });
};

chatModel.createConversationAndSaveMessage = (userId, characterId, message) => {
    return new Promise((resolve, reject) => {
        if (!message) {
            console.error('Le message est vide');
            return reject(new Error('Le message est vide'));
        }

        const query = 'INSERT INTO conversation (user_id, character_id) VALUES (?, ?)';
        connection.query(query, [userId, characterId], (error, results) => {
            if (error) {
                return reject(error);
            }
            const conversationId = results.insertId;
            chatModel.saveMessageInConversation(conversationId, message, 'user');
            resolve(conversationId);
        });
    });
};

chatModel.saveMessageInConversation = (conversationId, message, sender) => {
    return new Promise((resolve, reject) => {
        if (!message) {
            console.error('OpenAI a répondu un message vide');
            return reject(new Error('OpenAI a répondu un message vide'));
        }

        const query = 'INSERT INTO chat (id_conv, messages, sender) VALUES (?, ?, ?)';
        connection.query(query, [conversationId, message, sender], (error) => {
            if (error) {
                return reject(error);
            }
            resolve();
        });
    });
};

chatModel.getConversationHistory = (conversationId) => {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM chat WHERE id_conv = ? ORDER BY timestamp';
        connection.query(query, [conversationId], (error, results) => {
            if (error) {
                return reject(error);
            }

            const history = results.map((message) => {
                const sender = message.sender;
                const content = `${sender}: ${message.messages}`;
                return content;
            });
            resolve(history);
        });
    });
};

module.exports = chatModel;
