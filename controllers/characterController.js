require('dotenv').config({path: './.env'});

const express = require('express');
const router = express.Router();
const {Configuration, OpenAIApi} = require('openai');
const characterModel = require('../models/characterModel');
const { authenticateToken } = require('../middleware/auth.middleware');

const apiKey = process.env.OPENAI_API_KEY;
const configuration = new Configuration({
    apiKey: apiKey,
});
const openai = new OpenAIApi(configuration);

// Créer un personnage dans un univers spécifié
router.post('/game/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    const { nom } = req.body;

    try {
        const existingCharacter = await characterModel.checkCharacterExistence(nom);
        if (existingCharacter.length > 0) {
            return res.status(409).json({ error: 'Le personnage existe déjà' });
        }

        const newCharacter = await characterModel.createCharacter(nom, id);
        const gameResults = await characterModel.getGameById(id);

        if (gameResults.length === 0) {
            return res.status(404).json({ error: 'Jeu associé au personnage non trouvé' });
        }

        const gameName = gameResults[0].nom;
        const description = await generateCharacterDescription(nom, gameName);

        await characterModel.updateCharacterDescription(description, newCharacter.insertId);

        res.status(201).json({ message: 'Personnage créé avec succès' });
    } catch (error) {
        console.error('Erreur lors de la création du personnage :', error);
        res.status(500).json({ error: 'Erreur lors de la création du personnage' });
    }
});

// Supprimer un personnage par son ID
router.delete('/:id', authenticateToken, async (req, res) => {
    const characterId = req.params.id;

    try {
        const deleteResult = await characterModel.deleteCharacterById(characterId);
        if (deleteResult.affectedRows === 0) {
            return res.status(404).json({ error: 'Personnage non trouvé' });
        }
        res.json({ message: 'Personnage supprimé avec succès' });
    } catch (error) {
        console.error('Erreur lors de la suppression du personnage :', error);
        res.status(500).json({ error: 'Erreur lors de la suppression du personnage' });
    }
});

// Récupérer un personnage par son ID
router.get('/:id', authenticateToken, async (req, res) => {
    const characterId = req.params.id;

    try {
        const characterResults = await characterModel.getCharacterById(characterId);
        if (characterResults.length === 0) {
            return res.status(404).json({ error: 'Personnage non trouvé' });
        }
        res.json(characterResults[0]);
    } catch (error) {
        console.error('Erreur lors de la récupération du personnage :', error);
        res.status(500).json({error: 'Erreur lors de la récupération du personnage'});
    }
});

// Récupérer tous les personnages d'un univers
router.get('/game/:id', authenticateToken, async (req, res) => {
    const gameId = req.params.id;

    try {
        const characters = await characterModel.getAllCharactersFromGame(gameId);
        res.json(characters);
    } catch (error) {
        console.error('Erreur lors de la récupération des personnages :', error);
        res.status(500).json({error: 'Erreur lors de la récupération des personnages'});
    }
});

// Générer une description du personnage en utilisant OpenAI
router.put('/game/:game_id/characters/:character_id', authenticateToken, async (req, res) => {
    const gameId = req.params.game_id;
    const characterId = req.params.character_id;

    try {
        const characterResults = await characterModel.getCharacterById(characterId);
        if (characterResults.length === 0) {
            return res.status(404).json({ error: 'Personnage non trouvé' });
        }

        const characterName = characterResults[0].name;
        const gameResults = await characterModel.getGameById(gameId);

        if (gameResults.length === 0) {
            return res.status(404).json({ error: 'Jeu associé au personnage non trouvé' });
        }

        const gameName = gameResults[0].nom;
        const description = await generateCharacterDescription(characterName, gameName);
        res.json({ description });
    } catch (error) {
        console.error('Erreur lors de la génération de la description du personnage :', error);
        res.status(500).json({ error: 'Erreur lors de la génération de la description du personnage' });
    }
});

// Générer la description du personnage en utilisant OpenAI
async function generateCharacterDescription(characterName, gameName) {
    const prompt = `Fait moi une courte description de ${characterName} du jeu ${gameName}.`;

    const response = await openai.createCompletion({
        model: "text-davinci-003",
        prompt,
        temperature: 1,
        max_tokens: 50,
        top_p: 1,
        frequency_penalty: 0,
        presence_penalty: 0,
        stop: ["AI:", "Human:"],
    });

    const description1 = response.data.choices[0].text;
    const description = description1.replace(/^\s*\n/g, '');
    return description;
}

module.exports = router;
