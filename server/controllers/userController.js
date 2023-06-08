require('dotenv').config({path: '../.env'});

const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const connection = require('../config/database');
const {authenticateToken} = require("../middleware/auth.middleware");

    // Route pour récupérer tous les utilisateurs
    router.get('/', authenticateToken, (req, res) => {
        // Exécute la requête SQL pour récupérer tous les utilisateurs
        const query = 'SELECT * FROM users';
        connection.query(query, (error, results) => {
            if (error) {
                console.error('Erreur lors de la récupération des utilisateurs :', error);
                res.status(500).json({error: 'Erreur lors de la récupération des utilisateurs'});
            } else {
                res.json(results);
            }
        });
    });

    // Route pour récupérer un utilisateur par son ID
    router.get('/:id', authenticateToken, (req, res) => {
        const userId = req.params.id;
        // Exécute la requête SQL pour récupérer l'utilisateur avec l'ID spécifié
        const query = 'SELECT * FROM users WHERE id = ?';
        connection.query(query, [userId], (error, results) => {
            if (error) {
                console.error('Erreur lors de la récupération de l\'utilisateur :', error);
                res.status(500).json({error: 'Erreur lors de la récupération de l\'utilisateur'});
            } else if (results.length === 0) {
                res.status(404).json({error: 'Utilisateur non trouvé'});
            } else {
                res.json(results[0]);
            }
        });
    });

    // Route pour ajouter un utilisateur
    router.post('/', (req, res) => {
        const {nom, prenom, pwd, mail} = req.body;
        // Exécuter la requête SQL pour insérer un nouvel utilisateur
        const query = 'INSERT INTO users (nom, prenom, pwd, mail) VALUES (?, ?, ?, ?)';
        connection.query(query, [nom, prenom, pwd, mail], (error, results) => {
            if (error) {
                console.error('Erreur lors de l\'ajout de l\'utilisateur :', error);
                res.status(500).json({error: 'Erreur lors de l\'ajout de l\'utilisateur'});
            } else {
                res.status(201).json({message: 'Utilisateur ajouté avec succès'});
            }
        });
    });

    // Route pour modifier un utilisateur
    router.put('/:id', authenticateToken, (req, res) => {
        const userId = req.params.id;
        const {nom, prenom, pwd, mail} = req.body;
        // Exécuter la requête SQL pour mettre à jour l'utilisateur avec l'ID spécifié
        const query = 'UPDATE users SET nom = ?, prenom = ?, pwd = ?, mail = ? WHERE id = ?';
        connection.query(query, [nom, prenom, pwd, mail, userId], (error, results) => {
            if (error) {
                console.error('Erreur lors de la mise à jour de l\'utilisateur :', error);
                res.status(500).json({error: 'Erreur lors de la mise à jour de l\'utilisateur'});
            } else if (results.affectedRows === 0) {
                res.status(404).json({error: 'Utilisateur non trouvé'});
            } else {
                res.json({message: 'Utilisateur mis à jour avec succès'});
            }
        });
    });


    // Route pour la connexion
    router.post('/login', (req, res) => {
        const { mail, pwd } = req.body;

        // Vérifier les informations d'identification dans la base de données
        const query = 'SELECT * FROM users WHERE mail = ? AND pwd = ?';
        connection.query(query, [mail, pwd], (error, results) => {
            if (error) {
                console.error('Erreur lors de la connexion :', error);
                res.status(500).json({ error: 'Erreur lors de la connexion' });
            } else if (results.length === 0) {
                res.status(401).json({ error: 'Email ou mot de passe incorrect' });
            } else {
                // Les informations d'identification sont valides
                // Générer le token JWT
                const user = results[0];
                const token = jwt.sign({ id: user.id, mail: user.mail }, process.env.SECRET_KEY, { expiresIn: '1h' });

                // Renvoyer le token JWT dans la réponse
                res.json({ token });
            }
        });
    });


module.exports = router;
