const jwt = require('jsonwebtoken');

// Middleware pour vérifier l'authentification
function authenticateToken(req, res, next) {
    const authHeader = req.headers['bearer'];
    const token = authHeader && authHeader.split(' ')[1];
    if (token == null) {
        return res.sendStatus(401); // Unauthorized
    }

    // Vérification du token
    jwt.verify(token, 'shjgeitZRGJBEhbirofvhedp', (err, user) => {
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
