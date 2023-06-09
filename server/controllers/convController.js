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


//route pour récupérer une conversation en fonction de son id
router.get('/:id', authenticateToken, (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM chat WHERE id_conv = ?";
    connection.query(sql, [id], (err, result) => {
        if (err) throw err;
        res.json(result);
    });
});


//route pour récupérer toutes les conversations
router.get('/', authenticateToken, (req, res) => {
    const id = req.params.id;
    const sql = "SELECT * FROM conversation";
    connection.query(sql, (err, result) => {
        if (err) throw err;
        res.json(result);
    });
});

module.exports = router;