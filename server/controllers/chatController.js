require('dotenv').config({path: '../.env'});

const express = require('express');
const router = express.Router();
const connection = require('../config/database');
const {Configuration, OpenAIApi} = require('openai');

const apiKey = process.env.OPENAI_API_KEY;
const configuration = new Configuration({
    apiKey: apiKey,
});
const openai = new OpenAIApi(configuration);
const {authenticateToken} = require('../middleware/auth.middleware');

// Supprimer une conversation par son ID
router.delete('/:id', authenticateToken, (req, res) => {
    const conversationId = req.params.id;
    const deleteQuery = 'DELETE FROM conversation WHERE id = ?';
    connection.query(deleteQuery, [conversationId], (error, results) => {
        if (error) {
            console.error('Erreur lors de la suppression de la conversation :', error);
            res.status(500).json({error: 'Erreur lors de la suppression de la conversation'});
        } else if (results.affectedRows === 0) {
            res.status(404).json({error: 'Conversation non trouvée'});
        } else {
            res.json({message: 'Conversation supprimée avec succès'});
        }
    });
});

// Envoyer un message à OpenAI et enregistrer la conversation dans la base de données
router.post('/:characterId', authenticateToken, async (req, res) => {
    const userId = req.user.id;
    const characterId = req.params.characterId;

    // Récupérer l'id du jeu associé au personnage
    const queryGameID = 'SELECT game_id FROM characters WHERE id = ?';
    connection.query(queryGameID, [characterId], async (error, results) => {
        if (error) {
            console.error('Erreur lors de la récupération du jeu associé au personnage :', error);
            res.status(500).json({error: 'Erreur lors de la récupération du jeu associé au personnage'});
        } else if (results.length === 0) {
            res.status(404).json({error: 'Personnage non trouvé'});
        } else {
            const gameId = results[0].game_id;

            // Récupérer le nom du jeu depuis son id
            const queryGameName = 'SELECT nom FROM games WHERE id = ?';
            connection.query(queryGameName, [gameId], async (error, results) => {
                if (error) {
                    console.error('Erreur lors de la récupération du nom du jeu :', error);
                    res.status(500).json({error: 'Erreur lors de la récupération du nom du jeu'});
                } else if (results.length === 0) {
                    res.status(404).json({error: 'Jeu non trouvé'});
                } else {
                    const gameName = results[0].nom;

                    // Récupérer le nom du personnage depuis son id
                    const queryName = 'SELECT name FROM characters WHERE id = ?';
                    connection.query(queryName, [characterId], async (error, results) => {
                        if (error) {
                            console.error('Erreur lors de la récupération du nom du personnage :', error);
                            res.status(500).json({error: 'Erreur lors de la récupération du nom du personnage'});
                        } else if (results.length === 0) {
                            res.status(404).json({error: 'Personnage non trouvé'});
                        } else {
                            const characterName = results[0].name;

                            // Créer le tableau contenant le nom du personnage et le nom du jeu
                            const data = {
                                character: characterName,
                                game: gameName
                            };

                            let message = req.body.message; // Message à envoyer à OpenAI

                            // Vérifier si une conversation existe déjà entre l'utilisateur et le personnage
                            const query = 'SELECT * FROM conversation WHERE user_id = ? AND character_id = ?';
                            connection.query(query, [userId, characterId], async (error, results) => {
                                if (error) {
                                    console.error('Erreur lors de la recherche de la conversation :', error);
                                    res.status(500).json({error: 'Erreur lors de la recherche de la conversation'});
                                } else {
                                    if (results.length === 0) {
                                        console.log("Nouvelle conversation créée");
                                        createConversationAndSaveMessage(userId, characterId, message)
                                            .then(async (conversationId) => {
                                                console.log("Conversation créée avec l'id : ", conversationId);
                                                const IDconversation = conversationId;
                                                const responseOpenAI = await sendMessageToOpenAI(data, message);
                                                saveMessageInConversation(IDconversation, responseOpenAI, 'AI');
                                                res.status(200).json({response: responseOpenAI});
                                            });

                                    } else {
                                        console.log("La conversation existe déjà");
                                        const conversationId = results[0].id;
                                        const historyOfConversation = await getConversationHistory(conversationId);

                                        historyOfConversation.push("Maintenant reprenons la conversation : ")
                                        historyOfConversation.push(message);

                                        saveMessageInConversation(conversationId, message, 'user');

                                        const response2OpenAI = await sendMessageToOpenAI(data, historyOfConversation);
                                        saveMessageInConversation(conversationId, response2OpenAI, 'AI');
/*                                        message = "user : " + message;
                                        historyOfConversation.push(message);
                                        console.log("Historique de la conversation avec le message ajouté : ", historyOfConversation);

                                        saveMessageInConversation(conversationId, message, 'user');
                                        const historySendToOpenAi = await sendMessageToOpenAI(data, historyOfConversation); // Envoyer l'historique de la conversation à OpenAI
                                        console.log("Réponse d'OpenAI : ", historySendToOpenAi);
                                        saveMessageInConversation(conversationId, historySendToOpenAi, 'AI'); // Enregistrer la réponse d'OpenAI dans la base de données
                                        res.status(200).json({response: historySendToOpenAi});*/
                                        res.status(200).json({response: response2OpenAI});
                                    }
                                }
                            });
                        }
                    });
                }
            });
        }
    });
});


// Générer la description du personnage en utilisant OpenAI
function sendMessageToOpenAI(data, message) {
    return new Promise(async (resolve, reject) => {
        const promptMessage = `A partir de maintenant on va jouer un jeu de role où tu vas incarner le personnage de ${data.character} du jeu vidéo ${data.game}. Comporte toi comme ${data.character} dans ${data.game}. \n${message}`;
        console.log('Prompt envoyé à OpenAI :', promptMessage);
        try {
            const response = await openai.createCompletion({
                model: 'text-ada-001',
                prompt: promptMessage,
                temperature: 1,
                max_tokens: 50,
                top_p: 1,
                frequency_penalty: 0,
                presence_penalty: 0,
            });

            const responseText = response.data.choices[0].text.replace(/^\s*\n/g, '');
            resolve(responseText);
        } catch (error) {
            reject(error);
        }
    });
}


function createConversationAndSaveMessage(userId, characterId, message) {
    return new Promise((resolve, reject) => {
        if (!message) {
            console.error('Le message est vide');
            reject(new Error('Le message est vide'));
            return;
        }

        const query = 'INSERT INTO conversation (user_id, character_id) VALUES (?, ?)';
        connection.query(query, [userId, characterId], (error, results) => {
            if (error) {
                console.error('Erreur lors de la création de la conversation :', error);
                reject(error);
            } else {
                const conversationId = results.insertId;
                saveMessageInConversation(conversationId, message, 'user');
                resolve(conversationId);
            }
        });
    });
}

// Fonction pour enregistrer un message dans une conversation existante dans la BDD
function saveMessageInConversation(conversationId, message, sender) {
    if (!message) {
        console.error('OpenAI a répondu un message vide');
        return;
    }
    const query = 'INSERT INTO chat (id_conv, messages, sender) VALUES (?, ?, ?)';
    connection.query(query, [conversationId, message, sender], (error) => {
        if (error) {
            console.error('Erreur lors de l\'enregistrement du message :', error);
        } else {
            console.log('Message enregistré avec succès dans la BDD');
        }
    });
}

// Récupérer l'historique complet d'une conversation avec son ID
async function getConversationHistory(conversationId) {
    return new Promise((resolve, reject) => {
        const query = 'SELECT * FROM chat WHERE id_conv = ?';
        connection.query(query, [conversationId], (error, results) => {
            if (error) {
                console.error('Erreur lors de la récupération de l\'historique de la conversation :', error);
                reject(error);
            } else {
                const history = results.map((message) => {
                    const sender = message.sender;
                    const content = `${sender}: ${message.messages}`;
                    return content;
                });
                resolve(history);
            }
        });
    });
}

module.exports = router;