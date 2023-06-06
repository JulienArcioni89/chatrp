# ChatRP

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
3. Accédez au répertoire du projet : `cd server`
4. Installez les dépendances : `npm install`
5. Configurez la base de données : [Instructions de configuration de la base de données ci-dessous]
6. Lancez l'API : `npm start` `index.js`

## Configuration de la base de données

### Méthode 1 : Création de la base de données

1. Ouvrez le fichier `config/database.js` dans un éditeur de texte.
2. Modifiez les paramètres de connexion à la base de données selon votre configuration :
    - Nom d'utilisateur : [Nom d'utilisateur MySQL]
    - Mot de passe : [Mot de passe MySQL]
    - Nom de la base de données : [Nom de la base de données]
3. Enregistrez les modifications.


### Méthode 2 : Importer la base de données

1. Ouvrir le fichier `openai.sql` dans un éditeur de texte.
2. Importez le fichier dans votre base de données MySQL.

---