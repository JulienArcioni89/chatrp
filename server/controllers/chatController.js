require('dotenv').config({path: '../.env'});

const express = require('express');
const router = express.Router();
const {Configuration, OpenAIApi} = require('openai');
const chatModel = require('../models/chatModel'); // modèle pour les opérations de chat
const characterModel = require('../models/characterModel'); // modèle pour les opérations des personnages
const gameModel = require('../models/gameModel'); // modèle pour les opérations des jeux
const {authenticateToken} = require('../middleware/auth.middleware');

const apiKey = process.env.OPENAI_API_KEY;
const configuration = new Configuration({
    apiKey: apiKey,
});
const openai = new OpenAIApi(configuration);

// Supprimer une conversation par son ID
router.delete('/:id', authenticateToken, async (req, res) => {
    const conversationId = req.params.id;

    try {
        const deleteResult = await chatModel.deleteConversationById(conversationId);
        if (deleteResult.affectedRows === 0) {
            return res.status(404).json({ error: 'Conversation non trouvée' });
        }
        res.json({ message: 'Conversation supprimée avec succès' });
    } catch (error) {
        console.error('Erreur lors de la suppression de la conversation :', error);
        res.status(500).json({ error: 'Erreur lors de la suppression de la conversation' });
    }
});

// Envoyer un message à OpenAI et enregistrer la conversation dans la base de données
router.post('/:characterId', authenticateToken, async (req, res) => {
    const userId = req.user.id;
    const characterId = req.params.characterId;

    try {
        const characterResults = await characterModel.getCharacterById(characterId);
        if (characterResults.length === 0) {
            return res.status(404).json({ error: 'Personnage non trouvé' });
        }

        const characterName = characterResults[0].name;
        const gameId = characterResults[0].game_id;

        const gameResults = await gameModel.getGameById(gameId);
        if (gameResults.length === 0) {
            return res.status(404).json({ error: 'Jeu non trouvé' });
        }

        const gameName = gameResults[0].nom;
        const data = {
            character: characterName,
            game: gameName
        };

        let message = req.body.message; // Message à envoyer à OpenAI
        console.log("Message envoyé a open AI après le prompt : ", message);

        const existingConversationResults = await chatModel.getConversationByUserIdAndCharacterId(userId, characterId);

        if (existingConversationResults.length === 0) {
            console.log("Nouvelle conversation créée");
            const conversationId = await chatModel.createConversationAndSaveMessage(userId, characterId, message);
            console.log("Conversation créée avec l'id : ", conversationId);

            const responseOpenAI = await sendMessageToOpenAI(data, message);
            await chatModel.saveMessageInConversation(conversationId, responseOpenAI, 'AI');

            res.status(200).json({response: responseOpenAI});
        } else {
            console.log("La conversation existe déjà");
            const conversationId = existingConversationResults[0].id;

            const historyOfConversation = await chatModel.getConversationHistory(conversationId);
            historyOfConversation.push(message);

            await chatModel.saveMessageInConversation(conversationId, message, 'user');

            const response2OpenAI = await sendMessageToOpenAI(data, historyOfConversation);
            await chatModel.saveMessageInConversation(conversationId, response2OpenAI, 'AI');

            res.status(200).json({response: response2OpenAI});
        }
    } catch (error) {
        console.error('Erreur lors de l\'envoi du message :', error);
        res.status(500).json({ error: 'Erreur lors de l\'envoi du message' });
    }
});

// Générer la description du personnage en utilisant OpenAI
function sendMessageToOpenAI(data, message) {
    return new Promise(async (resolve, reject) => {
        const promptMessage = `Tu es ${data.character} du jeu vidéo ${data.game}. Tu doit répondre uniquement en imitant ce personnage et ne pas sortir de ce personnage sous aucun raison`;
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

module.exports = router;
