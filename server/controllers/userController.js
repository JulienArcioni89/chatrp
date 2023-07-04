require('dotenv').config({path: '../.env'});

const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const userModel = require('../models/userModel');
const {authenticateToken} = require("../middleware/auth.middleware");
const bcrypt = require('bcrypt');

router.get('/', authenticateToken, async (req, res) => {
    try {
        const users = await userModel.getAllUsers();
        res.json(users);
    } catch (error) {
        console.error('Erreur lors de la récupération des utilisateurs :', error);
        res.status(500).json({error: 'Erreur lors de la récupération des utilisateurs'});
    }
});

router.delete('/:id', authenticateToken, async (req, res) => {
    const userId = req.params.id;
    try {
        const result = await userModel.deleteUserById(userId);
        if (result.affectedRows === 0) {
            res.status(404).json({error: 'Utilisateur non trouvé'});
        } else {
            res.json({message: 'Utilisateur supprimé avec succès'});
        }
    } catch (error) {
        console.error('Erreur lors de la suppression de l\'utilisateur :', error);
        res.status(500).json({error: 'Erreur lors de la suppression de l\'utilisateur'});
    }
});

router.get('/:id', authenticateToken, async (req, res) => {
    const userId = req.params.id;
    try {
        const users = await userModel.getUserById(userId);
        if (users.length === 0) {
            res.status(404).json({error: 'Utilisateur non trouvé'});
        } else {
            res.json(users[0]);
        }
    } catch (error) {
        console.error('Erreur lors de la récupération de l\'utilisateur :', error);
        res.status(500).json({error: 'Erreur lors de la récupération de l\'utilisateur'});
    }
});

router.post('/', async (req, res) => {
    const {nom, prenom, pwd, mail} = req.body;
    try {
        await userModel.createUser(nom, prenom, pwd, mail);
        res.status(201).json({message: 'Utilisateur ajouté avec succès'});
    } catch (error) {
        console.error('Erreur lors de l\'ajout de l\'utilisateur :', error);
        res.status(500).json({error: 'Erreur lors de l\'ajout de l\'utilisateur'});
    }
});

router.put('/:id', authenticateToken, async (req, res) => {
    const userId = req.params.id;
    const {nom, prenom, pwd, mail} = req.body;
    try {
        const result = await userModel.updateUser(userId, nom, prenom, pwd, mail);
        if (result.affectedRows === 0) {
            res.status(404).json({error: 'Utilisateur non trouvé'});
        } else {
            res.json({message: 'Utilisateur mis à jour avec succès'});
        }
    } catch (error) {
        console.error('Erreur lors de la mise à jour de l\'utilisateur :', error);
        res.status(500).json({error: 'Erreur lors de la mise à jour de l\'utilisateur'});
    }
});

router.post('/login', async (req, res) => {
    const {mail, pwd} = req.body;
    try {
        const users = await userModel.getUserByMail(mail);
        if (users.length === 0) {
            res.status(401).json({error: 'Email ou mot de passe incorrect'});
        } else {
            const user = users[0];
            const username = ('user : ', user.nom);
            const isMatch = await bcrypt.compare(pwd, user.pwd);
            if (!isMatch) {
                res.status(401).json({error: 'Email ou mot de passe incorrect'});
            } else {
                const token = jwt.sign({id: user.id, mail: user.mail, username: username}, process.env.SECRET_KEY, {expiresIn: '7h'});
                res.json({token});
            }
        }
    } catch (error) {
        console.error('Erreur lors de la connexion :', error);
        res.status(500).json({error: 'Erreur lors de la connexion'});
    }
});

module.exports = router;
