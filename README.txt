===================================================
  StreamDB — Plateforme de streaming vidéo (type Netflix)
  README - Projet de Modélisation de Base de Données
===================================================

SGBD utilisé : PostgreSQL (version >= 13)

-----------------------------------------------
DÉPENDANCES
-----------------------------------------------
- PostgreSQL installé et en cours d'exécution
- psql (client CLI) OU pgAdmin 4

-----------------------------------------------
STRUCTURE DES FICHIERS
-----------------------------------------------
streamdb_schema.sql  → Script unique contenant :
                        - CREATE TABLE (15 relations)
                        - INSERT (jeu de données, 5+ tuples/table)
                        - 4 requêtes d'illustration commentées

-----------------------------------------------
INSTALLATION & EXÉCUTION
-----------------------------------------------

1. Créer la base de données :

   psql -U postgres -c "CREATE DATABASE streamdb;"

2. Exécuter le script :

   psql -U postgres -d streamdb -f streamdb_schema.sql

3. Vérifier le contenu :

   psql -U postgres -d streamdb
   \dt                     -- liste les 15 tables
   SELECT * FROM Contenu;  -- affiche tous les contenus

-----------------------------------------------
TABLES CRÉÉES (15 relations)
-----------------------------------------------
Plan, Pays, Genre,
Compte, Profil,
Contenu, Film, Serie,
Saison, Episode,
ContenuGenre, ContenuLangue,
VisionnageFilm, Visionnage,
MaListe

-----------------------------------------------
SPÉCIALISATION ISA
-----------------------------------------------
Contenu → Film  (attribut : realisateur)
        → Serie (attributs : createur, nbSaisons)
Disjointe et totale (colonne 'type' + CHECK).

-----------------------------------------------
NOTES
-----------------------------------------------
- email du Compte est UNIQUE (clé candidate).
- La progression de visionnage est en secondes.
- ContenuLangue couvre audio ET sous-titres séparément.
- Les requêtes d'illustration sont en fin de script.
===================================================
