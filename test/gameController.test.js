const chai = require('chai');
const sinon = require('sinon');
const expect = chai.expect;
const gameModel = require('../models/gameModel');
const gameController = require('../controllers/gameController');
const { mockRequest, mockResponse } = require('mock-req-res');

describe('Game Controller', () => {
    afterEach(() => {
        sinon.restore();
    });

    it('should return 201 and a success message when creating a game', async () => {
        const req = mockRequest({
            body: { nom: 'MonJeu' },
            user: { id: 1 }
        });
        const res = mockResponse();
        const getGameByIdStub = sinon.stub(gameModel, 'getGameById').returns([]);
        const createGameStub = sinon.stub(gameModel, 'createGame').resolves();

        await gameController.createGame(req, res);

        expect(getGameByIdStub.calledOnce).to.be.true;
        expect(createGameStub.calledOnce).to.be.true;
        expect(res.status.calledOnceWith(201)).to.be.true;
        expect(res.json.calledOnceWith({ message: 'Jeu créé avec succès' })).to.be.true;
    });

    it('should return the game when getting a game by id', async () => {
        const req = mockRequest({ params: { id: 1 } });
        const res = mockResponse();
        const game = { id: 1, nom: 'MonJeu' };
        const getGameByIdStub = sinon.stub(gameModel, 'getGameById').returns([game]);

        await gameController.getGameById(req, res);

        expect(getGameByIdStub.calledOnce).to.be.true;
        expect(res.json.calledOnceWith(game)).to.be.true;
    });



    it('should delete the game and return a success message', async () => {
        const req = mockRequest({ params: { id: 1 } });
        const res = mockResponse();
        const deleteGameByIdStub = sinon.stub(gameModel, 'deleteGameById').returns({ affectedRows: 1 });

        await gameController.deleteGameById(req, res);

        expect(deleteGameByIdStub.calledOnce).to.be.true;
        expect(res.json.calledOnceWith({ message: 'Jeu supprimé avec succès' })).to.be.true;
    });



    it('should return all games', async () => {
        const req = mockRequest();
        const res = mockResponse();
        const games = [{ id: 1, nom: 'MonJeu' }, { id: 2, nom: 'AutreJeu' }];
        const getAllGamesStub = sinon.stub(gameModel, 'getAllGames').returns(games);

        await gameController.getAllGames(req, res);

        expect(getAllGamesStub.calledOnce).to.be.true;
        expect(res.json.calledOnceWith(games)).to.be.true;
    });



    it('should update the game name and return a success message', async () => {
        const req = mockRequest({
            params: { id: 1 },
            body: { nom: 'NouveauNom' }
        });
        const res = mockResponse();
        const updateGameNameStub = sinon.stub(gameModel, 'updateGameName').returns({ affectedRows: 1 });

        await gameController.updateGameName(req, res);

        expect(updateGameNameStub.calledOnce).to.be.true;
        expect(res.json.calledOnceWith({ message: 'Jeu renommé avec succès' })).to.be.true;
    });
});

