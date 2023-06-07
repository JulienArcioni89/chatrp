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

                            // Créer le prompt contenant le nom du personnage et du jeu pour OpenAI
                            const prompt = {
                                character: characterName,
                                game: gameName
                            };

                            const message = req.body.message; // Message à envoyer à OpenAI
                            const openAiResponse = await sendMessageToOpenAI(prompt, message); // Envoyer le message à OpenAI et obtenir la réponse

                            // Vérifier si une conversation existe déjà entre l'utilisateur et le personnage
                            const query = 'SELECT * FROM conversation WHERE user_id = ? AND character_id = ?';
                            connection.query(query, [userId, characterId], (error, results) => {
                                if (error) {
                                    console.error('Erreur lors de la recherche de la conversation :', error);
                                    res.status(500).json({error: 'Erreur lors de la recherche de la conversation'});
                                } else {
                                    if (results.length === 0) {
                                        createConversationAndSaveMessage(userId, characterId, message);
                                    } else {
                                        const conversationId = results[0].id;
                                        saveMessageInConversation(conversationId, message, 'user');
                                        saveMessageInConversation(conversationId, openAiResponse, 'AI'); // Enregistrer la réponse d'OpenAI dans la base de données
                                    }
                                    res.status(200).json({response: openAiResponse});
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
function sendMessageToOpenAI(prompt, message) {
    return new Promise(async (resolve, reject) => {
        const promptMessage = `Tu vas maintenant incarner le personnage ${prompt.character} du jeu ${prompt.game}. Tu incarneras à la perfection ce personnage à partir de maintenant.\n\n${message}`;
        try {
            const response = await openai.createCompletion({
                model: 'text-davinci-003',
                prompt: promptMessage,
                temperature: 1,
                max_tokens: 50,
                top_p: 1,
                frequency_penalty: 0,
                presence_penalty: 0,
                stop: ['AI:', 'Human:'],
            });

            const responseText = response.data.choices[0].text.replace(/^\s*\n/g, '');
            resolve(responseText);
        } catch (error) {
            reject(error);
        }
    });
}

// Fonction pour créer une nouvelle conversation et enregistrer le premier message
function createConversationAndSaveMessage(userId, characterId, message) {
    if (!message) {
        console.error('Le message est vide');
        return;
    }
    const query = 'INSERT INTO conversation (user_id, character_id) VALUES (?, ?)';
    connection.query(query, [userId, characterId], (error, results) => {
        if (error) {
            console.error('Erreur lors de la création de la conversation :', error);
        } else {
            const conversationId = results.insertId;
            saveMessageInConversation(conversationId, message, 'user');
        }
    });
}

// Fonction pour enregistrer un message dans une conversation existante
function saveMessageInConversation(conversationId, message, sender) {
    if (!message) {
        console.error('Le message est vide');
        return;
    }
    const query = 'INSERT INTO chat (id_conv, messages, sender) VALUES (?, ?, ?)';
    connection.query(query, [conversationId, message, sender], (error) => {
        if (error) {
            console.error('Erreur lors de l\'enregistrement du message :', error);
        }
    });
}

module.exports = router;
