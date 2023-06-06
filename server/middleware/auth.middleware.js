require('dotenv').config({path: '../.env'});

const jwt = require('jsonwebtoken');

// Middleware pour vérifier l'authentification
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];

    if (authHeader == null) {
        return res.sendStatus(401); // Unauthorized
    }

    // Vérification du token
    jwt.verify(authHeader, process.env.SECRET_KEY, (err, user) => {
        if (err) {
            return res.sendStatus(403); // Forbidden
        }
        req.user = user;
        next();
    });
}

module.exports = {
    authenticateToken
};