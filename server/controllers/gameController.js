const express = require('express');
const router = express.Router();
const connection = require('../config/database');


// Route pour créer un jeu
    router.post('/', (req, res) => {
        const {nom} = req.body;
        const query = 'INSERT INTO games (nom) VALUES (?)';
        connection.query(query, [nom], (error, results) => {
            if (error) {
                console.error('Erreur lors de la création du jeu :', error);
                res.status(500).json({error: 'Erreur lors de la création du jeu'});
            } else {
                res.status(201).json({message: 'Jeu créé avec succès'});
            }
        });
    });

// Route pour récupérer un jeu par son ID
    router.get('/:id', (req, res) => {
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

// Route pour récupérer tous les jeux
    router.get('/', (req, res) => {
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

// Route pour renommer un jeu
    router.put('/:id', (req, res) => {
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
