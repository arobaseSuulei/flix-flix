-- ============================================================
-- Arcstream  — Plateforme de streaming vidéo type Netflix
--  Script SQL — Création des tables + jeu de données
--  SGBD cible : PostgreSQL
-- ============================================================

-- -----------------------------------------------
-- 1. Plan d'abonnement
-- -----------------------------------------------
CREATE TABLE Plan (
    idPlan       SERIAL       PRIMARY KEY,
    libelle      VARCHAR(50)  NOT NULL UNIQUE,
    prixMensuel  NUMERIC(6,2) NOT NULL CHECK (prixMensuel >= 0),
    qualiteMax   VARCHAR(10)  NOT NULL CHECK (qualiteMax IN ('SD', 'HD', '4K')),
    nbProfilsMax INTEGER      NOT NULL CHECK (nbProfilsMax BETWEEN 1 AND 5)
);

-- -----------------------------------------------
-- 2. Pays d'origine
-- -----------------------------------------------
CREATE TABLE Pays (
    idPays  SERIAL        PRIMARY KEY,
    nom     VARCHAR(100)  NOT NULL UNIQUE
);

-- -----------------------------------------------
-- 3. Genre
-- -----------------------------------------------
CREATE TABLE Genre (
    idGenre  SERIAL       PRIMARY KEY,
    libelle  VARCHAR(80)  NOT NULL UNIQUE
);

-- -----------------------------------------------
-- 4. Compte client
-- -----------------------------------------------
CREATE TABLE Compte (
    idCompte        SERIAL        PRIMARY KEY,
    email           VARCHAR(255)  NOT NULL UNIQUE,
    motDePasse      VARCHAR(255)  NOT NULL,
    dateInscription DATE          NOT NULL DEFAULT CURRENT_DATE,
    idPlan          INTEGER       NOT NULL,
    FOREIGN KEY (idPlan) REFERENCES Plan(idPlan)
);

-- -----------------------------------------------
-- 5. Profil (appartient à un compte)
-- -----------------------------------------------
CREATE TABLE Profil (
    idProfil  SERIAL        PRIMARY KEY,
    pseudo    VARCHAR(100)  NOT NULL,
    avatar    VARCHAR(255),
    idCompte  INTEGER       NOT NULL,
    FOREIGN KEY (idCompte) REFERENCES Compte(idCompte) ON DELETE CASCADE
);

-- -----------------------------------------------
-- 6. Contenu (entité mère — spécialisation ISA)
-- -----------------------------------------------
CREATE TABLE Contenu (
    idContenu  SERIAL        PRIMARY KEY,
    titre      VARCHAR(255)  NOT NULL,
    annee      INTEGER       NOT NULL CHECK (annee BETWEEN 1888 AND 2100),
    duree      INTEGER       CHECK (duree > 0),  -- en minutes (NULL pour les séries)
    idPays     INTEGER       NOT NULL,
    type       VARCHAR(10)   NOT NULL CHECK (type IN ('film', 'serie')),
    FOREIGN KEY (idPays) REFERENCES Pays(idPays)
);

-- -----------------------------------------------
-- 7. Film (sous-classe)
-- -----------------------------------------------
CREATE TABLE Film (
    idContenu    INTEGER       PRIMARY KEY,
    realisateur  VARCHAR(200)  NOT NULL,
    FOREIGN KEY (idContenu) REFERENCES Contenu(idContenu) ON DELETE CASCADE
);

-- -----------------------------------------------
-- 8. Série (sous-classe)
-- -----------------------------------------------
CREATE TABLE Serie (
    idContenu  INTEGER       PRIMARY KEY,
    createur   VARCHAR(200)  NOT NULL,
    nbSaisons  INTEGER       NOT NULL CHECK (nbSaisons > 0),
    FOREIGN KEY (idContenu) REFERENCES Contenu(idContenu) ON DELETE CASCADE
);

-- -----------------------------------------------
-- 9. Saison
-- -----------------------------------------------
CREATE TABLE Saison (
    idSaison   SERIAL    PRIMARY KEY,
    numero     INTEGER   NOT NULL CHECK (numero > 0),
    idContenu  INTEGER   NOT NULL,
    UNIQUE (idContenu, numero),
    FOREIGN KEY (idContenu) REFERENCES Serie(idContenu) ON DELETE CASCADE
);

-- -----------------------------------------------
-- 10. Episode
-- -----------------------------------------------
CREATE TABLE Episode (
    idEpisode  SERIAL        PRIMARY KEY,
    numero     INTEGER       NOT NULL CHECK (numero > 0),
    titre      VARCHAR(255)  NOT NULL,
    duree      INTEGER       NOT NULL CHECK (duree > 0),  -- en minutes
    idSaison   INTEGER       NOT NULL,
    UNIQUE (idSaison, numero),
    FOREIGN KEY (idSaison) REFERENCES Saison(idSaison) ON DELETE CASCADE
);

-- -----------------------------------------------
-- 11. Association Contenu <-> Genre (N:M)
-- -----------------------------------------------
CREATE TABLE ContenuGenre (
    idContenu  INTEGER  NOT NULL,
    idGenre    INTEGER  NOT NULL,
    PRIMARY KEY (idContenu, idGenre),
    FOREIGN KEY (idContenu) REFERENCES Contenu(idContenu),
    FOREIGN KEY (idGenre)   REFERENCES Genre(idGenre)
);

-- -----------------------------------------------
-- 12. Disponibilité linguistique d'un contenu
-- -----------------------------------------------
CREATE TABLE ContenuLangue (
    idContenu          INTEGER      NOT NULL,
    langue             VARCHAR(50)  NOT NULL,
    typeDisponibilite  VARCHAR(20)  NOT NULL CHECK (typeDisponibilite IN ('audio', 'sous-titre')),
    PRIMARY KEY (idContenu, langue, typeDisponibilite),
    FOREIGN KEY (idContenu) REFERENCES Contenu(idContenu)
);

-- -----------------------------------------------
-- 13. Visionnage d'un film par un profil
-- -----------------------------------------------
CREATE TABLE VisionnageFilm (
    idProfil    INTEGER   NOT NULL,
    idContenu   INTEGER   NOT NULL,
    dateDebut   TIMESTAMP NOT NULL DEFAULT NOW(),
    progression INTEGER   NOT NULL DEFAULT 0 CHECK (progression >= 0),  -- en secondes
    PRIMARY KEY (idProfil, idContenu, dateDebut),
    FOREIGN KEY (idProfil)  REFERENCES Profil(idProfil),
    FOREIGN KEY (idContenu) REFERENCES Film(idContenu)
);

-- -----------------------------------------------
-- 14. Visionnage d'un épisode par un profil
-- -----------------------------------------------
CREATE TABLE Visionnage (
    idProfil    INTEGER   NOT NULL,
    idEpisode   INTEGER   NOT NULL,
    dateDebut   TIMESTAMP NOT NULL DEFAULT NOW(),
    progression INTEGER   NOT NULL DEFAULT 0 CHECK (progression >= 0),  -- en secondes
    PRIMARY KEY (idProfil, idEpisode, dateDebut),
    FOREIGN KEY (idProfil)  REFERENCES Profil(idProfil),
    FOREIGN KEY (idEpisode) REFERENCES Episode(idEpisode)
);

-- -----------------------------------------------
-- 15. Ma Liste — contenus sauvegardés par un profil
-- -----------------------------------------------
CREATE TABLE MaListe (
    idProfil   INTEGER   NOT NULL,
    idContenu  INTEGER   NOT NULL,
    dateAjout  TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (idProfil, idContenu),
    FOREIGN KEY (idProfil)  REFERENCES Profil(idProfil),
    FOREIGN KEY (idContenu) REFERENCES Contenu(idContenu)
);


-- ============================================================
--  JEU DE DONNÉES
-- ============================================================

-- Plans
INSERT INTO Plan (libelle, prixMensuel, qualiteMax, nbProfilsMax) VALUES
    ('Essentiel', 5.99,  'SD', 1),
    ('Standard',  13.99, 'HD', 2),
    ('Premium',   19.99, '4K', 5);

-- Pays
INSERT INTO Pays (nom) VALUES
    ('États-Unis'),   -- 1
    ('France'),       -- 2
    ('Royaume-Uni'),  -- 3
    ('Corée du Sud'), -- 4
    ('Espagne');      -- 5

-- Genres
INSERT INTO Genre (libelle) VALUES
    ('Action'),       -- 1
    ('Drame'),        -- 2
    ('Comédie'),      -- 3
    ('Thriller'),     -- 4
    ('Science-fiction'), -- 5
    ('Horreur'),      -- 6
    ('Romance'),      -- 7
    ('Documentaire'); -- 8

-- Comptes
INSERT INTO Compte (email, motDePasse, dateInscription, idPlan) VALUES
    ('alice@mail.com',   'hashed_pwd_1', '2023-01-15', 3),
    ('bob@mail.com',     'hashed_pwd_2', '2023-03-22', 2),
    ('claire@mail.com',  'hashed_pwd_3', '2024-06-01', 1),
    ('david@mail.com',   'hashed_pwd_4', '2024-09-10', 3),
    ('emma@mail.com',    'hashed_pwd_5', '2025-01-05', 2);

-- Profils
INSERT INTO Profil (pseudo, avatar, idCompte) VALUES
    ('Alice',       'avatar_alice.png',   1),  -- id=1
    ('Mini-Alice',  'avatar_kids.png',    1),  -- id=2  (2e profil compte 1)
    ('Bob',         'avatar_bob.png',     2),  -- id=3
    ('Bob Films',   'avatar_cinema.png',  2),  -- id=4
    ('Claire',      'avatar_claire.png',  3),  -- id=5
    ('David',       'avatar_david.png',   4),  -- id=6
    ('Emma',        'avatar_emma.png',    5);  -- id=7

-- Contenus (films)
INSERT INTO Contenu (titre, annee, duree, idPays, type) VALUES
    ('Inception',           2010, 148, 1, 'film'),  -- id=1
    ('Intouchables',        2011, 112, 2, 'film'),  -- id=2
    ('Parasite',            2019, 132, 4, 'film'),  -- id=3
    ('Dunkerque',           2017, 107, 3, 'film'),  -- id=4
    ('Interstellar',        2014, 169, 1, 'film');  -- id=5

-- Contenus (séries)
INSERT INTO Contenu (titre, annee, duree, idPays, type) VALUES
    ('Stranger Things',     2016, NULL, 1, 'serie'),  -- id=6
    ('Casa de Papel',       2017, NULL, 5, 'serie'),  -- id=7
    ('Dark',                2017, NULL, 5, 'serie'),  -- id=8  (Allemagne via Espagne ici simplifié)
    ('Squid Game',          2021, NULL, 4, 'serie'),  -- id=9
    ('Lupin',               2021, NULL, 2, 'serie');  -- id=10

-- Films
INSERT INTO Film (idContenu, realisateur) VALUES
    (1, 'Christopher Nolan'),
    (2, 'Olivier Nakache, Éric Toledano'),
    (3, 'Bong Joon-ho'),
    (4, 'Christopher Nolan'),
    (5, 'Christopher Nolan');

-- Séries
INSERT INTO Serie (idContenu, createur, nbSaisons) VALUES
    (6,  'Matt Duffer, Ross Duffer', 4),
    (7,  'Álex Pina',                5),
    (8,  'Baran bo Odar',            3),
    (9,  'Hwang Dong-hyuk',          2),
    (10, 'George Kay, François Uzan', 3);

-- Saisons
INSERT INTO Saison (numero, idContenu) VALUES
    (1, 6), (2, 6), (3, 6), (4, 6),  -- Stranger Things S1-S4
    (1, 7), (2, 7),                   -- Casa de Papel S1-S2
    (1, 9),                           -- Squid Game S1
    (1, 10), (2, 10);                 -- Lupin S1-S2

-- Episodes (extraits représentatifs)
INSERT INTO Episode (numero, titre, duree, idSaison) VALUES
    -- Stranger Things S1 (idSaison=1)
    (1, 'Le Monde à l''envers',        47, 1),
    (2, 'La Barbe-Fleurie',            55, 1),
    (3, 'Holly, jolly',                51, 1),
    -- Stranger Things S2 (idSaison=2)
    (1, 'Le Garçon de retour',         48, 2),
    (2, 'Trick or Treat, Freak',       56, 2),
    -- Casa de Papel S1 (idSaison=5)
    (1, 'Episode 1',                   70, 5),
    (2, 'Episode 2',                   50, 5),
    (3, 'Episode 3',                   49, 5),
    -- Squid Game S1 (idSaison=7)
    (1, 'Red Light, Green Light',      60, 7),
    (2, 'L''Enfer c''est les autres',  63, 7),
    (3, 'L''Homme au parapluie',       56, 7),
    -- Lupin S1 (idSaison=8)
    (1, 'Arsène',                      53, 8),
    (2, 'La Comtesse de Cagliostro',   47, 8);

-- Genres des contenus
INSERT INTO ContenuGenre (idContenu, idGenre) VALUES
    (1, 1), (1, 5),   -- Inception : Action, Sci-fi
    (2, 2), (2, 3),   -- Intouchables : Drame, Comédie
    (3, 2), (3, 4),   -- Parasite : Drame, Thriller
    (4, 1), (4, 2),   -- Dunkerque : Action, Drame
    (5, 1), (5, 5),   -- Interstellar : Action, Sci-fi
    (6, 5), (6, 6),   -- Stranger Things : Sci-fi, Horreur
    (7, 1), (7, 4),   -- Casa de Papel : Action, Thriller
    (8, 5), (8, 4),   -- Dark : Sci-fi, Thriller
    (9, 2), (9, 4),   -- Squid Game : Drame, Thriller
    (10, 2), (10, 4); -- Lupin : Drame, Thriller

-- Langues disponibles
INSERT INTO ContenuLangue (idContenu, langue, typeDisponibilite) VALUES
    (1, 'Anglais',  'audio'),
    (1, 'Français', 'sous-titre'),
    (1, 'Français', 'audio'),
    (2, 'Français', 'audio'),
    (2, 'Anglais',  'sous-titre'),
    (3, 'Coréen',   'audio'),
    (3, 'Français', 'sous-titre'),
    (3, 'Anglais',  'sous-titre'),
    (9, 'Coréen',   'audio'),
    (9, 'Français', 'sous-titre'),
    (10, 'Français', 'audio'),
    (10, 'Anglais',  'sous-titre');

-- Visionnages de films
INSERT INTO VisionnageFilm (idProfil, idContenu, dateDebut, progression) VALUES
    (1, 1, '2025-01-10 20:00:00', 8880),  -- Alice a fini Inception (148min=8880s)
    (1, 2, '2025-01-15 21:00:00', 3200),  -- Alice a vu 53min d'Intouchables
    (3, 3, '2025-02-01 19:30:00', 7920),  -- Bob a fini Parasite
    (6, 5, '2025-03-05 22:00:00', 5400),  -- David a vu 90min d'Interstellar
    (7, 4, '2025-03-10 18:00:00', 6420);  -- Emma a fini Dunkerque

-- Visionnages d'épisodes
INSERT INTO Visionnage (idProfil, idEpisode, dateDebut, progression) VALUES
    (1, 1,  '2025-01-20 20:00:00', 2820),  -- Alice : ST S1E1 fini
    (1, 2,  '2025-01-21 20:00:00', 3300),  -- Alice : ST S1E2 fini
    (3, 9,  '2025-02-10 21:00:00', 3600),  -- Bob : Squid Game S1E1 fini
    (3, 10, '2025-02-10 22:01:00', 1800),  -- Bob : Squid Game S1E2 à mi-chemin
    (6, 6,  '2025-03-01 20:00:00', 4200),  -- David : Casa de Papel S1E1 fini
    (7, 12, '2025-03-15 21:00:00', 3180),  -- Emma : Lupin S1E1 fini
    (7, 13, '2025-03-15 22:00:00', 900);   -- Emma : Lupin S1E2 commencé

-- Ma Liste
INSERT INTO MaListe (idProfil, idContenu, dateAjout) VALUES
    (1, 6,  '2025-01-19 10:00:00'),  -- Alice sauve Stranger Things
    (1, 9,  '2025-01-22 11:00:00'),  -- Alice sauve Squid Game
    (3, 5,  '2025-02-05 09:00:00'),  -- Bob sauve Interstellar
    (6, 8,  '2025-03-02 14:00:00'),  -- David sauve Dark
    (7, 10, '2025-03-14 20:00:00');  -- Emma sauve Lupin


-- ============================================================
--  REQUÊTES D'ILLUSTRATION
-- ============================================================

-- 1. Catalogue complet avec genres (films + séries)
SELECT c.idContenu, c.titre, c.annee, c.type, p.nom AS pays,
       STRING_AGG(g.libelle, ', ') AS genres
FROM Contenu c
JOIN Pays p ON c.idPays = p.idPays
JOIN ContenuGenre cg ON c.idContenu = cg.idContenu
JOIN Genre g ON cg.idGenre = g.idGenre
GROUP BY c.idContenu, c.titre, c.annee, c.type, p.nom
ORDER BY c.type, c.titre;

-- 2. Historique de visionnage complet d'un profil (id=1 : Alice)
SELECT 'film' AS type, f.idContenu AS id, c.titre,
       vf.dateDebut, vf.progression AS progression_sec
FROM VisionnageFilm vf
JOIN Film f ON vf.idContenu = f.idContenu
JOIN Contenu c ON f.idContenu = c.idContenu
WHERE vf.idProfil = 1
UNION ALL
SELECT 'episode', e.idEpisode, c.titre || ' — ' || e.titre,
       v.dateDebut, v.progression
FROM Visionnage v
JOIN Episode e ON v.idEpisode = e.idEpisode
JOIN Saison s ON e.idSaison = s.idSaison
JOIN Contenu c ON s.idContenu = c.idContenu
WHERE v.idProfil = 1
ORDER BY dateDebut;

-- 3. Nombre de profils par compte et plan souscrit
SELECT co.email, pl.libelle AS plan, pl.nbProfilsMax,
       COUNT(pr.idProfil) AS nb_profils_actifs
FROM Compte co
JOIN Plan pl ON co.idPlan = pl.idPlan
LEFT JOIN Profil pr ON co.idCompte = pr.idCompte
GROUP BY co.idCompte, co.email, pl.libelle, pl.nbProfilsMax;

-- 4. Contenus disponibles en français (audio ou sous-titre)
SELECT DISTINCT c.titre, c.type, cl.typeDisponibilite
FROM Contenu c
JOIN ContenuLangue cl ON c.idContenu = cl.idContenu
WHERE cl.langue = 'Français'
ORDER BY c.titre;
