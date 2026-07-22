-- -- Jeu de données de démo, exécuté à chaque démarrage (spring.sql.init.mode=always).
-- -- Les MERGE rendent ce script idempotent pour éviter les doublons/erreurs de clé
-- -- unique lors des redémarrages successifs.

-- -- Utilisateur de test : olivier.mignot83 / password123 (mot de passe encodé en base64)
-- MERGE INTO APP_USER u
-- USING (SELECT 'olivier.mignot83' AS username FROM dual) src
-- ON (u.username = src.username)
-- WHEN NOT MATCHED THEN
--     INSERT (username, password, display_name, avatar_initials)
--     VALUES ('olivier.mignot83', 'cGFzc3dvcmQxMjM=', 'Olivier Mignot', 'OM');

-- -- Stat 1
-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT1' AS stat_group, 'Catégorie A' AS name, 42 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);

-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT1' AS stat_group, 'Catégorie B' AS name, 28 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);

-- -- Stat 2
-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT2' AS stat_group, 'Janvier' AS name, 15 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);

-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT2' AS stat_group, 'Février' AS name, 22 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);

-- -- Stat 3
-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT3' AS stat_group, 'Produit X' AS name, 8 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);

-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT3' AS stat_group, 'Produit Y' AS name, 19 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);

-- -- Stat 4
-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT4' AS stat_group, 'Région Nord' AS name, 33 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);

-- MERGE INTO STATISTIC_ENTRY t
-- USING (SELECT 'STAT4' AS stat_group, 'Région Sud' AS name, 27 AS value FROM dual) src
-- ON (t.stat_group = src.stat_group AND t.name = src.name)
-- WHEN NOT MATCHED THEN INSERT (stat_group, name, value) VALUES (src.stat_group, src.name, src.value);
