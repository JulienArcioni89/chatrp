const connection = require('../config/database');
const bcrypt = require('bcrypt');

const getAllUsers = () => {
    return new Promise((resolve, reject) => {
        connection.query('SELECT * FROM users', (error, results) => {
            if (error) reject(error);
            resolve(results);
        });
    });
}

const deleteUserById = (userId) => {
    return new Promise((resolve, reject) => {
        connection.query('DELETE FROM users WHERE id = ?', [userId], (error, results) => {
            if (error) reject(error);
            resolve(results);
        });
    });
}

const getUserById = (userId) => {
    return new Promise((resolve, reject) => {
        connection.query('SELECT * FROM users WHERE id = ?', [userId], (error, results) => {
            if (error) reject(error);
            resolve(results);
        });
    });
}

const createUser = async (nom, prenom, pwd, mail) => {
    const hashedPwd = await bcrypt.hash(pwd, 10);
    return new Promise((resolve, reject) => {
        connection.query('INSERT INTO users (nom, prenom, pwd, mail) VALUES (?, ?, ?, ?)', [nom, prenom, hashedPwd, mail], (error, results) => {
            if (error) reject(error);
            resolve(results);
        });
    });
}

const updateUser = async (userId, nom, prenom, pwd, mail) => {
    const hashedPwd = await bcrypt.hash(pwd, 10);
    return new Promise((resolve, reject) => {
        connection.query('UPDATE users SET nom = ?, prenom = ?, pwd = ?, mail = ? WHERE id = ?', [nom, prenom, hashedPwd, mail, userId], (error, results) => {
            if (error) reject(error);
            resolve(results);
        });
    });
}

const getUserByMail = (mail) => {
    return new Promise((resolve, reject) => {
        connection.query('SELECT * FROM users WHERE mail = ?', [mail], (error, results) => {
            if (error) reject(error);
            resolve(results);
        });
    });
}

module.exports = {
    getAllUsers,
    deleteUserById,
    getUserById,
    createUser,
    updateUser,
    getUserByMail
}
