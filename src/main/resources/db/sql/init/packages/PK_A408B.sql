CREATE OR REPLACE PACKAGE ARTHUS."PK_A408B"
AS
--
-- Chaine de reconnaissance SCCS
-- %W%   %E%

   -- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --

   -- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --

   -- -- TYPES PUBLIQUES ---------------------------------------------------------
-- Aucun
-- ------------------------------------------------- Fin des types publiques --

   -- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--
   PROCEDURE p_a408b (
      i_numporte     IN   porte_adhesion.numporte%TYPE DEFAULT NULL,
      i_numsoc_deb   IN   noemie.numsoc%TYPE DEFAULT NULL,
      i_numsoc_fin   IN   noemie.numsoc%TYPE DEFAULT NULL,
      i_repertoire   IN   VARCHAR2 DEFAULT NULL,
      i_fichier      IN   VARCHAR2 DEFAULT NULL
   );
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_A408B"
AS
-- Chaine de reconnaissance SCCS
-- %W%   %E%

   -- -- CONSTANTES PRIVEES ------------------------------------------------------
--ABO 01/02/2010 NOE-TYD variable type_dest          CONSTANT VARCHAR2 (2)                      := 'CP';
   type_emetteur      CONSTANT VARCHAR2 (2)                      := 'SI';
   porte_maj          CONSTANT VARCHAR2 (1)                      := 'N';
-- ---------------------------------------------- Fin des constantes privees --

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
   e_par_repertoire_vide       EXCEPTION;
   e_par_fichier_vide          EXCEPTION;

-- ---------------------------------------------- Fin des exceptions privees --

   -- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

   -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
   FUNCTION format_nb (nbre IN NUMBER, taille IN NUMBER)
      RETURN VARCHAR2;

--
   PROCEDURE upd_porte_adhesion;

--
   PROCEDURE upd_remise_externe;

--
   PROCEDURE enrg_000;

--
   PROCEDURE enrg_010;

--
   PROCEDURE enrg_110;

--
   PROCEDURE enrg_120;

--
   PROCEDURE enrg_140;

--
   PROCEDURE enrg_990 (
      niveau_990   IN   VARCHAR2,
      compteur     IN   NUMBER,
      ident        IN   VARCHAR2
   );

--
   PROCEDURE enrg_999;

--
   PROCEDURE entete (i_numporte IN NUMBER);

--
   PROCEDURE p_nom_fichier;

--
   PROCEDURE p_ins_journal;

--
-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
--
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
--
-- Declaration des variables
-- Variables de sortie
   g_date                      VARCHAR2 (8);
   g_heure                     VARCHAR2 (8);
--
   old_porte_numremise         NUMBER (9);
-- compteur pour compter tous les enregistrements de 000 … 999
   compteur_000                NUMBER;
-- compteur pour les enregistrements de 110 compris entre 010 et 990 (niv 1)
   compteur_010                NUMBER;
-- compteur pour les enregistrements de 120 et 140 compris entre 110 et 990 (niv 2)
   compteur_110                NUMBER;
   edatejours                  VARCHAR2 (6);
   numemetteur                 NUMBER (25);
   numcentre                   NUMBER (10);
-- porte_maj      Char;
   numorg                      NUMBER (7);
   cle_numorg                  NUMBER (1);
   noe_numsoc_old              NUMBER (7);
   noe_numorg_old              NUMBER (7);
   noe_numassu_old             NUMBER (9);
   noe_regime_old              NUMBER;
   noe_caisse_old              NUMBER (3);
-- ABO 0102200 ajout centre et type destinataire
   noe_centre_old              NUMBER (3);
   noe_typdest_old             VARCHAR2 (2);
   ident_9902_old              VARCHAR2 (17);
   f_sortie                    UTL_FILE.file_type;
   g_fichier                   VARCHAR2 (200);
   buffer                      VARCHAR2 (32767);
--
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                           DEFAULT 'pk_a408b';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 3;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;

-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
---------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
--
----------------------------------------------------------------------------
      -- NS 02-mai-2006 remplacement de la datnais par datnais_regime dans la table noemie
      -- to_char(noemie.datnais,'DDMMYY') as noe_datnais,
   /*CURSOR c_assu_secu (
      i_numporte     IN   NUMBER,
      i_numsoc_deb   IN   NUMBER,
      i_numsoc_fin   IN   NUMBER
   )
   IS
      SELECT   noemie.orgbase AS noe_regime, noemie.numsoc AS noe_numsoc,
               noemie.numorg AS noe_numorg, noemie.caisse AS noe_caisse,
               noemie.numassu AS noe_numassu, noemie.natur AS noe_natur,
               noemie.mouvement AS noe_mouvement,
               DECODE (noemie.natur,
                       '1', noemie.nom,
                       '2', indvs.nom
                      ) AS princ_nom,
               DECODE (noemie.natur,
                       '1', noemie.prenom,
                       '2', indvs.prenom
                      ) AS princ_prenom,
               DECODE (noemie.natur,
                       '1', noemie.nomjf,
                       '2', indvs.nomjf
                      ) AS princ_nomjf,
               noemie.matorg AS noe_matorg,
               SUBSTR (TO_CHAR (noemie.cless, '00'), 2, 2) AS noe_cle_matorg,
                  noemie.matorg
               || SUBSTR (TO_CHAR (noemie.cless, '00'), 2, 2) AS ident_9902,
               'P' AS nature_nom_p, 'M' AS nature_nom_m,
               porte_adhesion.numremise AS porte_numremise,
               porte_adhesion.idadhesion AS porte_idadhesion,
               porte_adhesion.idporte AS porte_idporte,
               noemie.numindiv AS noe_numindiv, noemie.nom AS noe_nom,
               noemie.prenom AS noe_prenom,
               noemie.datnais_regime AS noe_datnais,
               TO_CHAR (porte_adhesion.debut, 'YYYYMMDD')
                                                         AS porte_debut_cvrt,
               NVL (TO_CHAR (porte_adhesion.fin, 'YYYYMMDD'),
                    '20241231'
                   ) AS porte_fin_cvrt,
               noemie.rang AS noe_rang
          FROM indvs, noemie, remise_externe, porte_adhesion
         WHERE remise_externe.numremise = porte_adhesion.numremise
           AND remise_externe.valide = 'O'
           AND porte_adhesion.transmis = 2
           AND porte_adhesion.numremise != 0
           AND noemie.numsoc BETWEEN NVL (i_numsoc_deb, noemie.numsoc)
                                 AND NVL (i_numsoc_fin,
                                          NVL (i_numsoc_deb, noemie.numsoc)
                                         )
           AND noemie.numassu = indvs.numindiv
           AND porte_adhesion.idporte = noemie.idporte
           AND porte_adhesion.numporte = i_numporte
      ORDER BY noemie.orgbase,
               noemie.numsoc,
               noemie.numorg,
               noemie.caisse,
               noemie.numassu,
               noemie.natur,
               noemie.mouvement;*/

    CURSOR c_assu_secu (
      i_numporte     IN   NUMBER,
      i_numsoc_deb   IN   NUMBER,
      i_numsoc_fin   IN   NUMBER
   )
   IS
      SELECT   noemie.orgbase AS noe_regime, noemie.numsoc AS noe_numsoc,
               noemie.numorg AS noe_numorg, noemie.caisse AS noe_caisse,
               noemie.centre AS noe_centre,
               noemie.numassu AS noe_numassu, noemie.natur AS noe_natur,
               noemie.mouvement AS noe_mouvement,
               DECODE (noemie.natur,
                       '1', noemie.nom,
                       '2', indvs.nom
                      ) AS princ_nom,
               DECODE (noemie.natur,
                       '1', noemie.prenom,
                       '2', indvs.prenom
                      ) AS princ_prenom,
               DECODE (noemie.natur,
                       '1', noemie.nomjf,
                       '2', indvs.nomjf
                      ) AS princ_nomjf,
               noemie.matorg AS noe_matorg,
               SUBSTR (TO_CHAR (noemie.cless, '00'), 2, 2) AS noe_cle_matorg,
                  noemie.matorg
               || SUBSTR (TO_CHAR (noemie.cless, '00'), 2, 2) AS ident_9902,
               'P' AS nature_nom_p, 'M' AS nature_nom_m,
               porte_adhesion.numremise AS porte_numremise,
               porte_adhesion.idadhesion AS porte_idadhesion,
               porte_adhesion.idporte AS porte_idporte,
               noemie.numindiv AS noe_numindiv, noemie.nom AS noe_nom,
               noemie.prenom AS noe_prenom,
               noemie.datnais_regime AS noe_datnais,
               TO_CHAR (porte_adhesion.debut, 'YYYYMMDD')
                                                         AS porte_debut_cvrt,
               NVL (TO_CHAR (porte_adhesion.fin, 'YYYYMMDD'),
                    '20241231'
                   ) AS porte_fin_cvrt,
               noemie.rang AS noe_rang,
               libelle.codapli as noe_typdest
          FROM indvs, noemie, remise_externe, porte_adhesion,libelle
         WHERE remise_externe.numremise = porte_adhesion.numremise
           AND remise_externe.valide = 'O'
           AND porte_adhesion.transmis = 2
           AND porte_adhesion.numremise != 0
           AND noemie.numsoc BETWEEN NVL (i_numsoc_deb, noemie.numsoc)
                                 AND NVL (i_numsoc_fin,
                                          NVL (i_numsoc_deb, noemie.numsoc)
                                         )
           AND noemie.numassu = indvs.numindiv
           AND porte_adhesion.idporte = noemie.idporte
           AND porte_adhesion.numporte = i_numporte
           AND libelle.code = noemie.orgbase
           AND libelle.mnemo = 'REGIME'
      ORDER BY noemie.orgbase,
               noemie.numsoc,
               noemie.numorg,
               noemie.caisse,
               noemie.centre,
               noemie.numassu,
               noemie.natur,
               noemie.mouvement;

-- variable de retour du curseur C_assu_secu
   assu_secu                   c_assu_secu%ROWTYPE;

   /*CURSOR c_pers_tp (numind IN NUMBER)
   IS
      SELECT centre
        FROM pers_tierspayant
       WHERE numindiv = numind;*/

--
------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_a408b (
      i_numporte     IN   porte_adhesion.numporte%TYPE DEFAULT NULL,
      i_numsoc_deb   IN   noemie.numsoc%TYPE DEFAULT NULL,
      i_numsoc_fin   IN   noemie.numsoc%TYPE DEFAULT NULL,
      i_repertoire   IN   VARCHAR2 DEFAULT NULL,
      i_fichier      IN   VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
-- Vérification des paramètres en entrée de la procédure P_A408B
/*    G_niv_msg   := 3;
      G_msg_adm   := 'Numporte = '||I_numporte;
      P_INS_journal;
--
      G_niv_msg   := 3;
      G_msg_adm    := 'Numsoc_deb = '||I_numsoc_deb;
      P_INS_journal;
--
      G_niv_msg   := 3;
      G_msg_adm    := 'Numsoc_fin = '||I_numsoc_fin;
      P_INS_journal;
--
      G_niv_msg   := 3;
      G_msg_adm    := 'PATH_repertoire = '||I_Repertoire;
      P_INS_journal;
--
      G_niv_msg   := 3;
      G_msg_adm    := 'Nom fichier = '||I_Fichier;
      P_INS_journal;
*/
      g_fichier := i_fichier;
--
   -- Formatage du nom de fichier
      p_nom_fichier;
      --
      f_sortie := UTL_FILE.fopen (i_repertoire, g_fichier, 'W', 32767);

-- f_sortie := UTL_FILE.FOPEN('EXPORT', I_fichier||'.lis', 'W');
-- NS 08-07-2005
-- UTL_FILE.PUT_LINE( f_sortie, I_Repertoire);
-- UTL_FILE.PUT_LINE( f_sortie, I_Fichier);
-- NS 08-07-2005
--
      IF i_repertoire IS NULL
      THEN
         RAISE e_par_repertoire_vide;
      END IF;

      IF i_fichier IS NULL OR i_fichier = ''
      THEN
         RAISE e_par_fichier_vide;
      END IF;

-- r‚cup‚ration des paramŠtres
/* VCR 22/12/2006 : récupération des paramètres dans la BA21 directement
   PK_EXPORT.P_Recup( I_Fichier );  */
--
--NS 08-07-2005
-- UTL_FILE.PUT_LINE(f_sortie, PK_EXPORT.enr_param_dmnde.valdeb1);
-- UTL_FILE.PUT_LINE(f_sortie, PK_EXPORT.enr_param_dmnde.valdeb2);
-- UTL_FILE.PUT_LINE(f_sortie, PK_EXPORT.enr_param_dmnde.valfin2);
--
--NS  f_sortie := UTL_FILE.FOPEN( I_Repertoire, I_Fichier, 'W');
      noe_regime_old := -1;
      edatejours := TO_CHAR (SYSDATE, 'DDMMYY');

      FOR rec_assu_secu IN c_assu_secu (i_numporte, i_numsoc_deb,
                                        i_numsoc_fin)
      LOOP
         assu_secu := rec_assu_secu;

         IF noe_regime_old = -1
         THEN
            -- 1er passage => en-tete
            --
            entete (i_numporte);
         ELSE
            -- recherche rupture niveau 1
            IF    assu_secu.noe_numsoc != noe_numsoc_old
               OR assu_secu.noe_numorg != noe_numorg_old
               OR assu_secu.noe_regime != noe_regime_old
               OR assu_secu.noe_caisse != noe_caisse_old
--ABO 01/02/2010 ajout rupture centre
               OR assu_secu.noe_centre != noe_centre_old
            THEN
               enrg_990 ('02', compteur_110, ident_9902_old);
-- ctt 17/07/07 : foramttage du n° emetteur sur 8 caractères numériques cadrés à droite)
--          enrg_990('01', compteur_010, numemetteur);
               enrg_990 ('01', compteur_010, format_nb (numemetteur, 8));
               enrg_999;
               upd_remise_externe;
               entete (i_numporte);
            -- recherche rupture niveau 2 (assur‚)
            ELSE
               IF assu_secu.noe_numassu != noe_numassu_old
               THEN
                  enrg_990 ('02', compteur_110, ident_9902_old);
                  compteur_110 := 0;
                  enrg_110;
               END IF;
            END IF;
         END IF;

         enrg_140;
         enrg_120;
         upd_porte_adhesion;
         noe_numassu_old := assu_secu.noe_numassu;
         noe_numsoc_old := assu_secu.noe_numsoc;
         noe_numorg_old := assu_secu.noe_numorg;
         noe_regime_old := assu_secu.noe_regime;
         noe_caisse_old := assu_secu.noe_caisse;
--ABO 01/02/2010 ajout centre et type destinataire
         noe_centre_old := assu_secu.noe_centre;
         noe_typdest_old := assu_secu.noe_typdest;
         ident_9902_old := assu_secu.ident_9902;
      END LOOP;

      IF noe_regime_old <> -1
      THEN
         -- pas d'anomalie en lecture, donc on termine d'‚crire
         enrg_990 ('02', compteur_110, ident_9902_old);
-- ctt 17/07/07 : foramttage du n° emetteur sur 8 caractères numériques cadrés à droite)
--    enrg_990('01', compteur_010, numemetteur);
         enrg_990 ('01', compteur_010, format_nb (numemetteur, 8));
         enrg_999;
         upd_remise_externe;
      END IF;

      UTL_FILE.fclose (f_sortie);
-- commit;
   EXCEPTION
      WHEN e_par_repertoire_vide
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'Nom du répertoire de sortie manquant';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
      WHEN e_par_fichier_vide
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'Nom du fichier de sortie manquant';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
      WHEN UTL_FILE.internal_error
      THEN
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'UTL_FILE.INTERNAL_ERROR';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_filehandle
      THEN
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'UTL_FILE.INVALID_FILEHANDLE';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_mode
      THEN
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'UTL_FILE.INVALID_MODE';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_operation
      THEN
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'UTL_FILE.INVALID_OPERATION';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_path
      THEN
--
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'UTL_FILE.INVALID_PATH';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.read_error
      THEN
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'UTL_FILE.READ_ERROR';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.write_error
      THEN
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'UTL_FILE.WRITE_ERROR';
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN VALUE_ERROR
      THEN
-- Rollback;
         g_niv_msg := 0;
         g_msg_adm := 'VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
-- Insertion dans journal_adm du message d'erreur
         p_ins_journal;
         UTL_FILE.fclose (f_sortie);
      WHEN OTHERS
      THEN
-- Rollback;
-- Insertion dans journal_adm du message d'erreur
         g_niv_msg := 0;
         g_msg_adm := 'PK_A408B - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         IF UTL_FILE.is_open (f_sortie)
         THEN
            UTL_FILE.fclose (f_sortie);
         END IF;
   END p_a408b;

-- formatage des num‚riques
   FUNCTION format_nb (nbre IN NUMBER, taille IN NUMBER)
      RETURN VARCHAR2
   IS
      retour   VARCHAR2 (25);
   BEGIN
      retour := SUBSTR ('0000000000000000000000000', 1, taille);

      IF nbre IS NOT NULL
      THEN
         retour := LTRIM (TO_CHAR (nbre, retour));
      ELSE
         --  ATTENTION ... Si la donn‚e est … NULL le d‚calage ne s'effectue pas. Il faut transformer le NULL en espace
         retour := ' ';
      END IF;

      RETURN retour;
   END;

   PROCEDURE upd_porte_adhesion
   IS
   BEGIN
      UPDATE porte_adhesion
         SET transmis = 1
       WHERE numremise = old_porte_numremise;
   END;

   PROCEDURE upd_remise_externe
   IS
   BEGIN
      UPDATE remise_externe
         SET date_trans = TRUNC (SYSDATE)
       WHERE numremise = old_porte_numremise;
   END;

   PROCEDURE enrg_000
   IS
   BEGIN
-- longueur totale 128

      -- Longueur d'enregistrement     X(4)
      buffer := '0128';
-- Type d'enregistrement         X(3)
      buffer := buffer || '000';
-- Type d'emetteur            X(2)
--NS 12-08-2005   buffer := buffer || type_emetteur;
      buffer := buffer || RPAD (NVL (type_emetteur, ' '), 2, ' ');
-- Numero d'emetteur       N(8)
-- NS 11-08-2005  buffer := buffer || format_nb(numemetteur,8);
      buffer := buffer || RPAD (format_nb (numemetteur, 8), 8, ' ');
-- filler nø emetteur         X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Programme emetteur         X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Type de destinataire Annexe 2    X(2)
-- NS 12-08-2005  buffer := buffer || type_dest;
-- ABO 01-02-2010 NOE-TYD codification en base buffer := buffer || RPAD (NVL (type_dest, ' '), 2, ' ');
      buffer := buffer || RPAD (NVL (assu_secu.noe_typdest, ' '), 2, ' ');
-- Vide              X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Grand regime            99
-- NS 11-08-2005  buffer := buffer || format_nb(assu_secu.noe_regime, 2);
      buffer := buffer || RPAD (format_nb (assu_secu.noe_regime, 2), 2, ' ');
-- Organisme gestionnaire        999
      buffer := buffer || RPAD (format_nb (assu_secu.noe_caisse, 3), 3, ' ');
-- Centre gestionnaire        999
-- NS 11-08-2005  buffer := buffer || format_nb(numcentre,3);
-- ABO 01-02-2010 centre en BD  buffer := buffer || RPAD (format_nb (numcentre, 3), 3, ' ');
      buffer := buffer || RPAD (format_nb (assu_secu.noe_centre, 3), 3, ' ');
-- Programme destinataire        X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Application - type d'echange Mise à jour mutualiste annexe 26    X(2)
      buffer := buffer || 'MU';
-- Identification du fichier     X(6)
      buffer := buffer || 'NOEVAL';
-- Date de creation de fichier JJMMAA  X(6)
      buffer := buffer || edatejours;
-- Norme utilisee - -Referencede l'echange   X(4)
      buffer := buffer || '408 ';
-- Version utilisee        X(2)
      buffer := buffer || '  ';
-- Compactage           X(1)
-- 0 - Pas de compactage
      buffer := buffer || '0';
-- Cryptage          X(1)
      buffer := buffer || 'N';
-- Vide              x(13)
      buffer := buffer || RPAD (' ', 13, ' ');
-- Longeur d'enregistrement      999
      buffer := buffer || '128';
-- Mot de passe            X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Zone Message            X(36)
      buffer := buffer || RPAD (' ', 36, ' ');
-- Zone Message            X(1)
      buffer := buffer || ' ';
      UTL_FILE.put_line (f_sortie, buffer);
      buffer := '';
      compteur_000 := 1;
   END;

   PROCEDURE enrg_010
   IS
   BEGIN
-- longueur totale 14

      -- Longueur enregistrement       X(4)
      buffer := '0014';
-- Type d'enregistrement         X(3)
      buffer := buffer || '010';
-- Niveau de rupture       X(2)
      buffer := buffer || '01';
-- Numero d'organisme complementaire   N(8)
-- NS 11-08-2005  buffer := buffer || format_nb(numemetteur,8);
      buffer := buffer || RPAD (format_nb (numemetteur, 8), 8, ' ');
-- Fin d'entite            X(1)
      buffer := buffer || '@';
      UTL_FILE.put_line (f_sortie, buffer);
      buffer := '';
      compteur_000 := compteur_000 + 1;
   END;

   PROCEDURE enrg_110
   IS
   BEGIN
-- longueur totale 89

      -- Longueur enregistrement       X(4)
      buffer := '0088';
--
      buffer := buffer || '110';
-- Niveau               9(2)
      buffer := buffer || '02';
-- Matricule SS            X(13)
      buffer := buffer || RPAD (NVL (assu_secu.noe_matorg, ' '), 13, ' ');
-- Cle Matricule SS        N(2)
      buffer := buffer || RPAD (NVL (assu_secu.noe_cle_matorg, ' '), 2, ' ');

      IF assu_secu.princ_nomjf IS NOT NULL
      THEN
-- nature du nom           X(1)
         buffer := buffer || NVL (assu_secu.nature_nom_m, ' ');
-- nom du beneficiaire        X(25)
         buffer := buffer || RPAD (NVL (assu_secu.princ_nom, ' '), 25, ' ');
-- nature               X(1)
         buffer := buffer || NVL (NVL (assu_secu.nature_nom_p, ' '), ' ');
-- nom jf               X(25)
-- NS 12-08-2005     buffer := buffer || rpad(assu_secu.princ_nomjf, 25,' ');
         buffer := buffer || RPAD (NVL (assu_secu.princ_nomjf, ' '), 25, ' ');
      ELSE
-- nature du nom           X(1)
         buffer := buffer || NVL (assu_secu.nature_nom_p, ' ');
-- nom du beneficiaire        X(25)
         buffer := buffer || RPAD (NVL (assu_secu.princ_nom, ' '), 25, ' ');
         buffer := buffer || RPAD (' ', 26, ' ');
      END IF;

-- pr‚nom d'usage du beneficiaire      X(15)
      buffer := buffer || RPAD (NVL (assu_secu.princ_prenom, ' '), 15, ' ');
      buffer := buffer || '@';
      UTL_FILE.put_line (f_sortie, buffer);
      buffer := '';
      compteur_010 := compteur_010 + 1;
      compteur_000 := compteur_000 + 1;
   END;

   PROCEDURE enrg_120
   IS
   BEGIN
-- longueur totale 57

      -- Longueur enregistrement       X(4)
      buffer := '0057';
      buffer := buffer || '120';
-- niveau de rupture       N(2)
      buffer := buffer || '99';
-- Date de naissance du beneficiaire      N(6)
-- NS 12-08-2005  buffer := buffer || assu_secu.noe_datnais;
      buffer := buffer || RPAD (format_nb (assu_secu.noe_datnais, 6), 6, ' ');
-- Rang de naissance       X(1)
-- NS 12-08-2005  buffer := buffer || assu_secu.noe_rang;
-- VCR 27/12/2006 buffer := buffer || nvl(assu_secu.noe_rang, ' ');
      buffer := buffer || NVL (TO_CHAR (assu_secu.noe_rang), ' ');
-- nom du beneficiaire        X(25)
      buffer := buffer || RPAD (NVL (assu_secu.noe_nom, ' '), 25, ' ');
-- prenom du beneficiaire        X(15)
      buffer := buffer || RPAD (NVL (assu_secu.noe_prenom, ' '), 15, ' ');
-- Unite de gestion de rattachement    N(4)
      buffer := buffer || '0000';
      buffer := buffer || '@';
      UTL_FILE.put_line (f_sortie, buffer);
      buffer := '';
      compteur_110 := compteur_110 + 1;
      compteur_000 := compteur_000 + 1;
   END;

   PROCEDURE enrg_140
   IS
   BEGIN
-- longueur totale 69

      -- Longueur enregistrement       X(4)
      buffer := '0069';
-- Type d'enregistrement         X(3)
      buffer := buffer || '140';
-- Niveau de rupture       X(2)
      buffer := buffer || '99';
-- numero adh‚rent            X(8)
/* VCR 27/12/2006 - ORA-06502
   buffer := buffer || lpad(nvl(assu_secu.noe_numindiv, ' '),8,'0'); */
      buffer :=
               buffer || LPAD (format_nb (assu_secu.noe_numindiv, 8), 8, '0');
-- Code mouvement Creation, Annulation, Mise a jour   X(1)
      buffer := buffer || NVL (assu_secu.noe_mouvement, ' ');
-- Type de contrat adherent         N(2)
      buffer := buffer || '01';
-- Debut de couverture du malade       N(8)
-- NS 12-08-2005  buffer := buffer || assu_secu.porte_debut_cvrt;
      buffer :=
           buffer || RPAD (format_nb (assu_secu.porte_debut_cvrt, 8), 8, ' ');
-- Fin de couverture du malade Bornee au 31/12/2024   N(8)
--NS 12-08-2005   buffer := buffer || assu_secu.porte_fin_cvrt;
      buffer :=
             buffer || RPAD (format_nb (assu_secu.porte_fin_cvrt, 8), 8, ' ');
-- type de contrat adh‚rent         N(2)
      buffer := buffer || '00';
-- date debut de contrat adh‚rent         N(8)
      buffer := buffer || '00000000';
-- date fin de contrat adh‚rent        N(8)
      buffer := buffer || '00000000';
-- filler            X(18)
      buffer := buffer || RPAD ('0', 18, '0');
      buffer := buffer || '@';
      UTL_FILE.put_line (f_sortie, buffer);
      buffer := '';
      compteur_110 := compteur_110 + 1;
      compteur_000 := compteur_000 + 1;
   END;

   PROCEDURE enrg_990 (
      niveau_990   IN   VARCHAR2,
      compteur     IN   NUMBER,
      ident        IN   VARCHAR2
   )
   IS
   BEGIN
-- Longueur enregistrement       X(4)
      buffer := '0043';
      buffer := buffer || '990';
-- Niveau de rupture       X(2)
      buffer := buffer || niveau_990;
-- Identification du niveau de rupture X(17)
      buffer := buffer || RPAD (NVL (ident, ' '), 17, ' ');
-- Compteur de niveau inferieur     N(8)
-- NS 11-08-2005  buffer := buffer || format_nb(compteur,8);
      buffer := buffer || RPAD (format_nb (compteur, 8), 8, ' ');
-- Cumul des montants         N(11)
      buffer := buffer || RPAD ('0', 11, '0');
-- Signe de l'acte
      buffer := buffer || ' ';
      buffer := buffer || '@';
      UTL_FILE.put_line (f_sortie, buffer);
      buffer := '';
      compteur_000 := compteur_000 + 1;
   END;

   PROCEDURE enrg_999
   IS
   BEGIN
      compteur_000 := compteur_000 + 1;
-- Longueur d'enregistrement     X(4)
      buffer := '0128';
-- Type d'enregistrement         X(3)
      buffer := buffer || '999';
-- Type d'emetteur            X(2)
-- NS 12-08-2005  buffer := buffer || type_emetteur;
      buffer := buffer || RPAD (NVL (type_emetteur, ' '), 2, ' ');
-- Numero d'emetteur       N(8)
-- NS 11-08-2005  buffer := buffer || format_nb(numemetteur,8);
      buffer := buffer || RPAD (format_nb (numemetteur, 8), 8, ' ');
-- filler nø emetteur         X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Programme emetteur         X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Type de destinataire Annexe 2    X(2)
-- NS 12-08-2005  buffer := buffer || type_dest;
-- ABO 01-02-2010 NOE-TYD codification en base  buffer := buffer || RPAD (NVL (type_dest, ' '), 2, ' ');
      buffer := buffer || RPAD (NVL (noe_typdest_old, ' '), 2, ' ');
-- Vide              X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Grand regime            99
-- NS 11-08-2005  buffer := buffer || format_nb(noe_regime_old, 2);
      buffer := buffer || RPAD (format_nb (noe_regime_old, 2), 2, ' ');
-- Organisme gestionnaire        999
-- NS 11-08-2005  buffer := buffer || format_nb(noe_caisse_old, 3);
      buffer := buffer || RPAD (format_nb (noe_caisse_old, 3), 3, ' ');
-- Centre gestionnaire        999
-- NS 11-08-2005  buffer := buffer || format_nb(numcentre,3);
-- ABO 01-02-2010 centre en BD  buffer := buffer || RPAD (format_nb (numcentre, 3), 3, ' ');
      buffer := buffer || RPAD (format_nb (noe_centre_old, 3), 3, ' ');
-- Programme destinataire        X(6)
      buffer := buffer || RPAD (' ', 6, ' ');
-- Application - type d'echange     X(2)
      buffer := buffer || 'MU';
-- Identification du fichier     X(6)
      buffer := buffer || 'NOEVAL';
-- Nombre d'enregistrements bornes comprises N(8)
-- NS 11-08-2005  buffer := buffer || format_nb(compteur_000, 8);
      buffer := buffer || RPAD (format_nb (compteur_000, 8), 8, ' ');
-- Vide              X(19)
      buffer := buffer || RPAD (' ', 19, ' ');
-- Nombre de lots          999
      buffer := buffer || '001';
-- Cumul des montants du fichier    N(11)
      buffer := buffer || RPAD ('0', 11, '0');
-- Signe de l'acte            X(1)
      buffer := buffer || ' ';
-- Zone Message            X(30)
      buffer := buffer || RPAD (' ', 30, ' ');
-- Zone Message            X(1)
      buffer := buffer || ' ';
      UTL_FILE.put_line (f_sortie, buffer);
      buffer := '';
   END;

--
   PROCEDURE entete (i_numporte IN NUMBER)
   IS
   BEGIN
      numemetteur :=
         f_porte_emetteur (assu_secu.noe_regime,
                           assu_secu.noe_numsoc,
                           assu_secu.noe_numorg,
                           assu_secu.noe_caisse,
                           i_numporte
                          );
-- ABO 01/02/2010 centre dans la table noemie
      /*OPEN c_pers_tp (assu_secu.noe_numassu);

      FETCH c_pers_tp
       INTO numcentre;

      IF c_pers_tp%NOTFOUND
      THEN
         numcentre := 0;
      END IF;

      CLOSE c_pers_tp;*/

      compteur_010 := 0;
      compteur_110 := 0;
      ident_9902_old := assu_secu.ident_9902;
      enrg_000;
      enrg_010;
      enrg_110;
      old_porte_numremise := assu_secu.porte_numremise;
   END;

--
-- ----------------------------------------------------------------------------------------
--
-- Formatage du nom de fichier (variable G_fichier)
--
-- ----------------------------------------------------------------------------------------
   PROCEDURE p_nom_fichier
   IS
   BEGIN
--
      g_proc := 'p_nom_fichier';
--
   --
      g_date := TO_CHAR (SYSDATE, 'YYYYMMDD');

      --
      SELECT REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
        INTO g_heure
        FROM DUAL;

      --
      SELECT REPLACE (REPLACE (g_fichier, '#DT', g_date), '#HR', g_heure)
        INTO g_fichier
        FROM DUAL;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- ----------------------------------------------------------------------------------------
----------------------- Fin des procedures publiques ------------------

   -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
--
      IF (g_niv_msg <= g_max_msg)
      THEN
         g_idligne := g_idligne + 1;

         IF (g_niv_msg = 0)
         THEN
            l_idligne := -1 * g_idligne;
         ELSE
            l_idligne := g_idligne;
         END IF;

         pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                                     i_session             => g_session,
                                     i_niv_msg             => g_niv_msg,
                                     i_msg_adm             => g_msg_adm,
                                     i_idligne             => l_idligne
                                    );
      END IF;
--
   END p_ins_journal;
---------------- Fin des corps des procedures privees --
END;
/
