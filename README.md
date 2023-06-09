# ChatRP

## Informations générales

*API Fonctionnelle - Front en cours de développement*\
*En conséquence, seul le répertoire `server` est fonctionnel*

## Description

ChatRP est une application de chat avec une IA qui permet aux utilisateurs de créer des personnages, les associer à un univers et de converser avec eux.

## Fonctionnalités

- Création de personnages : Les utilisateurs peuvent créer leurs propres personnages en spécifiant des caractéristiques telles que le nom et son univers.
- Chat : Les utilisateurs peuvent converser avec une intelligence artificielle (IA) qui incarne un personnage dans l'univers choisi.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les éléments suivants :

- Node.js (v18.12.1) : [Lien vers le site officiel de Node.js](https://nodejs.org)
- MySQL Server (version 5.7.39) : [Lien vers le site officiel de MySQL](https://www.mysql.com)

## Installation

1. Clonez le dépôt : `git clone https://github.com/JulienArcioni89/chatrp`
2. Accédez au répertoire du projet : `cd ChatRP`
3. Accédez au répertoire `server` du projet : `cd server`
4. Installez les dépendances : `npm install`
5. Installez dotenv : `npm install dotenv`
6. Installez bcrypt : `npm install bcrypt`
7. Configurez la base de données : [Instructions de configuration de la base de données ci-dessous]
8. Créer un fichier `.env` à la racine du projet. 
9. Insérez la variable `OPENAI_API_KEY` pour renseigner votre clé OpenAI.
10. Insérez la variable `SECRET_KEY` pour renseigner votre clé secrète et enregistrez le fichier.
11. Lancez l'API : `node index.js` dans le dossier `server`.

## Configuration de la base de données

### Etape 1 : Importer la base de données

1. Récupérer le fichier `openai.sql` qui se situe à la racine de ce projet.
2. Importez le fichier dans votre base de données MySQL.


### Etape 2 : Connexion à la base de données existante

1. Ouvrez le fichier `config/database.js` dans un éditeur de texte.
2. Modifiez les paramètres de connexion à la base de données selon votre configuration :
    - Nom d'utilisateur : [Nom d'utilisateur MySQL]
    - Mot de passe : [Mot de passe MySQL]
    - Nom de la base de données : [Nom de la base de données]
3. Enregistrez les modifications.
4. Un utilisateur avec des droits limités a été créé pour l'API. Son utilisation est possible en se rendant dans le fichier `config/database.js` et en décommentant la partie correspondante.


## Utilisation
1. Importez la collection Postman.
2. Modifier dans la collection Postman la variable `url` pour renseigner l'URL correcte de l'API.
3. Envoyer une requête Login pour obtenir un token.
4. Prendre le token et le renseigner dans la variable `token` de la collection Postman (dans `Current value`).
---