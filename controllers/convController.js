require('dotenv').config({path: './.env'});

const express = require('express');
const router = express.Router();
const {Configuration, OpenAIApi} = require('openai');
const {authenticateToken} = require('../middleware/auth.middleware');
const convModel = require('../models/convModel'); // Importer le modèle

const apiKey = process.env.OPENAI_API_KEY;
const configuration = new Configuration({
    apiKey: apiKey,
});
const openai = new OpenAIApi(configuration);


//route pour récupérer une conversation en fonction de son id
router.get('/:id', authenticateToken, async (req, res) => {
    const id = req.params.id;
    try {
        const result = await convModel.getConversationById(id);
        res.json(result);
    } catch (err) {
        console.error(err);
        res.status(500).json({error: 'Erreur lors de la récupération de la conversation'});
    }
});


//route pour récupérer toutes les conversations
router.get('/', authenticateToken, async (req, res) => {
    try {
        const result = await convModel.getAllConversations();
        res.json(result);
    } catch (err) {
        console.error(err);
        res.status(500).json({error: 'Erreur lors de la récupération des conversations'});
    }
});

module.exports = router;
