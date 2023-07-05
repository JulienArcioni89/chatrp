const request = require('supertest');
const sinon = require('sinon');
const { expect } = require('chai');
const express = require('express');
const bodyParser = require('body-parser');

const userModel = require('../models/userModel');
const userController = require('../controllers/userController');

const app = express();
app.use(bodyParser.json());
app.use('/', userController);

describe('POST /', function() {
    let createUserStub;

    beforeEach(function() {
        createUserStub = sinon.stub(userModel, 'createUser');
    });

    afterEach(function() {
        createUserStub.restore();
    });

    it('should return 201 for a new user', async function() {
        createUserStub.returns(Promise.resolve({ insertId: 123 }));

        const response = await request(app)
            .post('/')
            .send({ nom: 'Doe', prenom: 'John', pwd: 'password123', mail: 'john.doe@example.com' });

        expect(response.status).to.equal(201);
        expect(response.body).to.deep.equal({ message: 'Utilisateur ajouté avec succès' });
    });

    it('should return 500 for a server error', async function() {
        createUserStub.throws(new Error('Fake server error'));

        const response = await request(app)
            .post('/')
            .send({ nom: 'Doe', prenom: 'John', pwd: 'password123', mail: 'john.doe@example.com' });

        expect(response.status).to.equal(500);
        expect(response.body).to.deep.equal({ error: 'Erreur lors de l\'ajout de l\'utilisateur' });
    });
});
