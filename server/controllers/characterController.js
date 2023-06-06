const express = require('express');
const router = express.Router();
const connection = require('../config/database');
const {Configuration, OpenAIApi} = require('openai');
const apiKey = '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';
const configuration = new Configuration({
    apiKey: apiKey,
});
const openai = new OpenAIApi(configuration);

// const openaiClient = new openai.OpenAIApi(apiKey);


// Route pour créer un personnage dans un univers spécifié
router.post('/game/:id', (req, res) => {
    const {id} = req.params;
    const {nom} = req.body;
    const query = 'INSERT INTO characters (name, game_id) VALUES (?, ?)';
    connection.query(query, [nom, id], (error, results) => {
        if (error) {
            console.error('Erreur lors de la création du personnage :', error);
            res.status(500).json({error: 'Erreur lors de la création du personnage'});
        } else {
            res.status(201).json({message: 'Personnage créé avec succès'});
        }
    });
});

// Route pour récupérer un personnage par son ID
router.get('/:id', (req, res) => {
    const characterId = req.params.id;
    const query = 'SELECT * FROM characters WHERE id = ?';
    connection.query(query, [characterId], (error, results) => {
        if (error) {
            console.error('Erreur lors de la récupération du personnage :', error);
            res.status(500).json({error: 'Erreur lors de la récupération du personnage'});
        } else if (results.length === 0) {
            res.status(404).json({error: 'Personnage non trouvé'});
        } else {
            res.json(results[0]);
        }
    });
});

// Route pour récupérer tous les personnages d'un univers
router.get('/game/:id', (req, res) => {
    const gameId = req.params.id;
    const query = 'SELECT * FROM characters WHERE game_id = ?';
    connection.query(query, [gameId], (error, results) => {
        if (error) {
            console.error('Erreur lors de la récupération des personnages :', error);
            res.status(500).json({error: 'Erreur lors de la récupération des personnages'});
        } else {
            res.json(results);
        }
    });
});

// Route pour générer une description du personnage en utilisant OpenAI
router.put('/game/:game_id/characters/:character_id', (req, res) => {
    const gameId = req.params.game_id;
    const characterId = req.params.character_id;

    const characterQuery = 'SELECT name FROM characters WHERE id = ?';
    connection.query(characterQuery, [characterId], async (characterError, characterResults) => {
        if (characterError) {
            console.error('Erreur lors de la récupération du personnage :', characterError);
            res.status(500).json({ error: 'Erreur lors de la récupération du personnage' });
        } else if (characterResults.length === 0) {
            res.status(404).json({ error: 'Personnage non trouvé' });
        } else {
            const characterName = characterResults[0].name;

            const gameQuery = 'SELECT nom FROM games WHERE id = ?';
            connection.query(gameQuery, [gameId], async (gameError, gameResults) => {
                if (gameError) {
                    console.error('Erreur lors de la récupération du jeu associé au personnage :', gameError);
                    res.status(500).json({ error: 'Erreur lors de la récupération du jeu associé au personnage' });
                } else if (gameResults.length === 0) {
                    res.status(404).json({ error: 'Jeu associé au personnage non trouvé' });
                } else {
                    const gameName = gameResults[0].nom; // Utilisez "nom" au lieu de "name" pour récupérer le nom du jeu

                    try {
                        const description = await generateCharacterDescription(characterName, gameName);
                        res.json({ description });
                    } catch (generationError) {
                        console.error('Erreur lors de la génération de la description du personnage :', generationError);
                        res.status(500).json({ error: 'Erreur lors de la génération de la description du personnage' });
                    }
                }
            });
        }
    });
});


// Fonction pour générer la description du personnage en utilisant OpenAI
async function generateCharacterDescription(characterName, gameName) {
    const prompt = `Fait moi une courte description du personnage qui s'appelle ${characterName} et qui fait partie du jeu ${gameName}.`;

    const response = await openai.createCompletion({
        model: "text-davinci-003",
        prompt,
        temperature: 1,
        max_tokens: 100,
        top_p: 1,
        frequency_penalty: 0,
        presence_penalty: 0,
        stop: ["AI:", "Human:"],
    });

    const description = response.data.choices[0].text;
    return description;
}



module.exports = router;