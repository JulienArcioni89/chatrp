const express = require('express');
const router = express.Router();
const gameModel = require('../models/gameModel.js');
const {authenticateToken} = require("../middleware/auth.middleware");

// fonction création de jeu
async function createGame(req, res) {
    const {nom} = req.body;
    const userId = req.user.id;
    try {
        // Check if game already exists
        const existingGame = await gameModel.getGameById(nom);
        if (existingGame.length > 0) {
            res.status(409).json({error: 'Un jeu avec le même nom existe déjà'});
        } else {
            // If no existing game, create a new one
            await gameModel.createGame(nom, userId);
            res.status(201).json({message: 'Jeu créé avec succès'});
        }
    } catch (error) {
        console.error('Erreur lors de la création du jeu : ', error);
        res.status(500).json({error: 'Erreur lors de la création du jeu'});
    }
}

router.post('/', authenticateToken, createGame);

async function deleteGameById(req, res) {
    const gameId = req.params.id;
    try {
        const result = await gameModel.deleteGameById(gameId);
        if (result.affectedRows === 0) {
            res.status(404).json({error: 'Jeu non trouvé'});
        } else {
            res.json({message: 'Jeu supprimé avec succès'});
        }
    } catch (error) {
        console.error('Erreur lors de la suppression du jeu :', error);
        res.status(500).json({error: 'Erreur lors de la suppression du jeu'});
    }
}

router.delete('/:id', authenticateToken, deleteGameById);

async function getGameById(req, res) {
    const gameId = req.params.id;
    try {
        const game = await gameModel.getGameById(gameId);
        if (game.length === 0) {
            res.status(404).json({error: 'Jeu non trouvé'});
        } else {
            res.json(game[0]);
        }
    } catch (error) {
        console.error('Erreur lors de la récupération du jeu :', error);
        res.status(500).json({error: 'Erreur lors de la récupération du jeu'});
    }
}

router.get('/:id', authenticateToken, getGameById);

async function getAllGames(req, res) {
    try {
        const games = await gameModel.getAllGames();
        if (games.length === 0) {
            res.status(404).json({error: 'Aucun jeu trouvé'});
        } else {
            res.json(games);
        }
    } catch (error) {
        console.error('Erreur lors de la récupération des jeux :', error);
        res.status(500).json({error: 'Erreur lors de la récupération des jeux'});
    }
}

router.get('/', authenticateToken, getAllGames);

async function updateGameName(req, res) {
    const gameId = req.params.id;
    const {nom} = req.body;
    try {
        const result = await gameModel.updateGameName(gameId, nom);
        if (result.affectedRows === 0) {
            res.status(404).json({error: 'Jeu non trouvé'});
        } else {
            res.json({message: 'Jeu renommé avec succès'});
        }
    } catch (error) {
        console.error('Erreur lors du renommage du jeu :', error);
        res.status(500).json({error: 'Erreur lors du renommage du jeu'});
    }
}

router.put('/:id', authenticateToken, updateGameName);


    module.exports = {
        router,
        createGame,
        deleteGameById,
        getGameById,
        getAllGames,
        updateGameName
    };
