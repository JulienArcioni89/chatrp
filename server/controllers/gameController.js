const express = require('express');
const router = express.Router();
const connection = require('../config/database');
const {authenticateToken} = require("../middleware/auth.middleware");

router.post('/', authenticateToken, (req, res) => {
    const { nom } = req.body;
    const userId = req.user.id; // Récupérer l'ID de l'utilisateur depuis le token décodé

    // Vérifier si un jeu avec le même nom existe déjà
    const checkQuery = 'SELECT id FROM games WHERE nom = ?';
    connection.query(checkQuery, [nom], (checkError, checkResults) => {
        if (checkError) {
            console.error('Erreur lors de la vérification du jeu existant :', checkError);
            res.status(500).json({ error: 'Erreur lors de la vérification du jeu existant' });
        } else if (checkResults.length > 0) {
            res.status(409).json({ error: 'Un jeu avec le même nom existe déjà' });
        } else {
            // Aucun jeu avec le même nom trouvé, procéder à la création du jeu
            const insertQuery = 'INSERT INTO games (nom, user_id) VALUES (?, ?)';
            connection.query(insertQuery, [nom, userId], (insertError, insertResults) => {
                if (insertError) {
                    console.error('Erreur lors de la création du jeu :', insertError);
                    res.status(500).json({ error: 'Erreur lors de la création du jeu' });
                } else {
                    res.status(201).json({ message: 'Jeu créé avec succès' });
                }
            });
        }
    });
});



// Récupérer un jeu par son ID
router.get('/:id', authenticateToken, (req, res) => {
    const gameId = req.params.id;
    const query = 'SELECT * FROM games WHERE id = ?';
    connection.query(query, [gameId], (error, results) => {
        if (error) {
            console.error('Erreur lors de la récupération du jeu :', error);
            res.status(500).json({error: 'Erreur lors de la récupération du jeu'});
        } else if (results.length === 0) {
            res.status(404).json({error: 'Jeu non trouvé'});
        } else {
            res.json(results[0]);
        }
    });
});

// Récupérer tous les jeux
router.get('/', authenticateToken, (req, res) => {
    const query = 'SELECT * FROM games';
    connection.query(query, (error, results) => {
        if (error) {
            console.error('Erreur lors de la récupération des jeux :', error);
            res.status(500).json({error: 'Erreur lors de la récupération des jeux'});
        } else {
            res.json(results);
        }
    });
});

// Renommer un jeu
router.put('/:id', authenticateToken, (req, res) => {
    const gameId = req.params.id;
    const {nom} = req.body;
    const query = 'UPDATE games SET nom = ? WHERE id = ?';
    connection.query(query, [nom, gameId], (error, results) => {
        if (error) {
            console.error('Erreur lors du renommage du jeu :', error);
            res.status(500).json({error: 'Erreur lors du renommage du jeu'});
        } else if (results.affectedRows === 0) {
            res.status(404).json({error: 'Jeu non trouvé'});
        } else {
            res.json({message: 'Jeu renommé avec succès'});
        }
    });
});


module.exports = router;
