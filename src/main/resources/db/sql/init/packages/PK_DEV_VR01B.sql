CREATE OR REPLACE PACKAGE ARTHUS."PK_DEV_VR01B"
AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_VR03B.sql                                            */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Génération des fichiers de virements à la norme ETBAC et    */
/*                appel de la Génération des fichiers de virements SEPA       */
/*============================================================================*/
/* Evolution    : Mise en place du cartouche, appel de la Génération des      */
/*                fichiers de virements SEPA                                  */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*============================================================================*/
/* Correction   : 29/11/2016    Mantis 5203 PHA BIC non obligatoire           */
/*============================================================================*/
--
   PROCEDURE p_dev_vr01b (
      i_numremise    IN       remise_vire.numremise%TYPE DEFAULT NULL,
      i_session      IN       NUMBER DEFAULT 1,
      i_niv_msg      IN       NUMBER DEFAULT 1,
      i_pause        IN       NUMBER DEFAULT 0,
      i_repertoire   IN       VARCHAR2 DEFAULT NULL,
      i_fichier      IN       VARCHAR2 DEFAULT NULL,
      o_found        OUT      NUMBER,
      o_erreur       OUT      VARCHAR2
   );
--

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
-- Aucune
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_DEV_VR01B"
AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_VR03B.sql                                            */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Génération des fichiers de virements à la norme ETBAC et    */
/*                appel de la Génération des fichiers de virements SEPA       */
/*============================================================================*/
/* Evolution    : Mise en place du cartouche, appel de la Génération des      */
/*                fichiers de virements SEPA                                  */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*============================================================================*/

-- Chaine de reconnaissance SCCS
-- %W%   %E%

   -- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --

   -- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

   -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
--
   PROCEDURE p_traitement_principal;

--
   PROCEDURE p_entete_info;

--
   PROCEDURE p_corps_info;

--
   PROCEDURE p_total_info;

--
   PROCEDURE p_select_reference;

--
   PROCEDURE p_nom_fichier;

--
   PROCEDURE p_debut_traitement;

--
   PROCEDURE p_fin_traitement;

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

   -- Variables de sortie
   g_date                      VARCHAR2 (8);
   g_heure                     VARCHAR2 (8);
   g_bdx                       VARCHAR2 (10);
   g_bqe                       NUMBER (3);
--
   g_emetteur                  compte.emetteur%TYPE;
   g_lemetteur                 VARCHAR2 (6);
--
   g_numremise                 remise_vire.numremise%TYPE;
   g_lnumremise                VARCHAR2 (10);
   g_refsoc                    VARCHAR2 (30);
--
   g_numcpte                   compte.numcpte%TYPE;
   g_codbque_soc               VARCHAR2 (5);
   g_guichet_soc               VARCHAR2 (5);
   g_compte_soc                VARCHAR2 (11);
   g_rib_soc                   VARCHAR2 (2);
--
   ed_parenthese               VARCHAR2 (1);
--
   g_ident                     NUMBER (2);
   ed_ident                    VARCHAR2 (1);
--
   g_identifiant               compte.identifiant%TYPE;
   ed_identifiant              VARCHAR2 (14);
--
   g_rais_soc                  compte.rais_soc%TYPE;
   g_numvirement               remise_vire_detail.numvirement%TYPE;
   g_codbque                   remise_vire_detail.codbque%TYPE;
   g_guichet                   remise_vire_detail.guichet%TYPE;
   g_compte                    remise_vire_detail.compte%TYPE;
   g_clerib                    remise_vire_detail.clerib%TYPE;
   g_intitule                  remise_vire_detail.intitule%TYPE;
   g_montant                   remise_vire_detail.montant%TYPE;
   g_numdecaismt               remise_vire_detail.numdecaismt%TYPE;
--
   g_beneficiaire              VARCHAR2 (18);
   ed_beneficiaire             VARCHAR2 (18);
--
   g_montant_total             NUMBER (15);
   g_datejour                  VARCHAR2 (6);
   g_monnaie                   remise_vire_detail.monnaie%TYPE;
   g_trait_entete              VARCHAR2 (1);
   g_symbole                   VARCHAR2 (3);
--

   -- Variables globales priv‚es
--
   g_typbene                   decaismt.typbene%TYPE;
   g_numbene                   decaismt.numbene%TYPE;
--
   g_numbene_trouve            VARCHAR2 (1);
--

   -- Variables d'écriture de fichier
--
   virement                    UTL_FILE.file_type;
   g_repertoire                typ_batch.repertoire%TYPE;
   g_fichier                   VARCHAR2 (200);
--
   ligne_1                     VARCHAR2 (160);
   ligne_2                     VARCHAR2 (160);
   ligne_3                     VARCHAR2 (160);
--

   -- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                               := FALSE;
   g_rollback                  BOOLEAN                               := FALSE;
   g_auto_valide               BOOLEAN                               := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                       DEFAULT 'pk_dev_vr01B';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE          DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE              := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE              := 1;
   g_idligne                   journal_adm.idligne%TYPE              := 0;
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
   CURSOR c_select_reference
   IS
      SELECT societe.refsoc, compte.numcpte, compte.codbque, compte.guichet,
             compte.compte, compte.clerib, compte.emetteur,
             NVL (compte.type_ident, 0) ident,
             RPAD (compte.identifiant, 14) identifiant, compte.rais_soc
        FROM remise_vire, compte, societe
       WHERE remise_vire.numremise = g_numremise
         AND remise_vire.numcpte = compte.numcpte
         AND compte.numsoc = societe.numsoc;

--
   CURSOR c_select_info
   IS
      SELECT   rem.numvirement, rem.codbque, rem.guichet, rem.compte, rem.clerib,
               RPAD (rem.intitule, 24, ' ') intitule,
               SUM (rem.montant_d * 100) montant, rem.monnaie_d monnaie,
               SUBSTR (pk_devise.symbole (rem.monnaie_d), 1, 3) symbole,
               MIN (rem.numdecaismt) numdecaismt, rem.numremise
               , rem.numcpte , cpt.bic
          FROM remise_vire_detail rem
          inner join compte cpt on (rem.numcpte = cpt.numcpte) -- SEPA : ajout jointure sur COMPTE pour test sur BIC du compte de tresorerie - BIC null alors tjrs ETEBAC
         WHERE numremise = g_numremise
         --#SBA 20111005#
		 -- TLE : SUPPRESSION DES COMMENTAIRES SUR LES 3 DERNIERES LIGNES DU WHERE
       AND (NOT ( -- rem.bic            IS  NOT NULL AND
                      rem.clef_iban  IS  NOT NULL
                  AND rem.bban       IS  NOT NULL)

            --or cpt.bic is null
            )
      GROUP BY rem.numvirement,
               rem.codbque,
               rem.guichet,
               rem.compte,
               rem.clerib,
               rem.intitule,
               rem.numremise,
               rem.monnaie_d
               ,rem.numcpte , cpt.bic;

--
/* VCR 30/01/2007
Ajout du curseur pour récupérer la valeur "Numcpte" de la remise
à intégrer dans le nom du fichier
*/
   CURSOR c_remise_vire
   IS
      SELECT remise_vire.numcpte
        FROM remise_vire
       WHERE remise_vire.numremise = g_numremise;

--
------------------------------------------------------------------
--
-- Le corps des diff‚rentes procedures
--
------------------------------------------------------------------
--
--
  PROCEDURE p_dev_vr01b (
     i_numremise    IN       remise_vire.numremise%TYPE DEFAULT NULL,
     i_session      IN       NUMBER DEFAULT 1,
     i_niv_msg      IN       NUMBER DEFAULT 1,
     i_pause        IN       NUMBER DEFAULT 0,
     i_repertoire   IN       VARCHAR2 DEFAULT NULL,
     i_fichier      IN       VARCHAR2 DEFAULT NULL,
     o_found        OUT      NUMBER,
     o_erreur       OUT      VARCHAR2
  )
  IS
    r_select_info c_select_info%ROWTYPE;
    --#SBA 20111005#
    n_found       NUMBER;
    v_erreur      VARCHAR2(1024);
  BEGIN
     --
     o_found := 1;
     g_erreur := NULL;
     --
     g_numremise := i_numremise;
     --
     g_repertoire := i_repertoire;
     g_fichier := i_fichier;
     --
     g_max_msg := i_niv_msg;
     g_session := i_session;

     --G_idligne     := F_max_idligne(I_session => G_session);
     --
     -- OUVERTURE du Curseur
     --
     IF NOT c_select_info%ISOPEN
     THEN
        p_debut_traitement;

--*
---debut-debogage
        g_niv_msg := 3;
        g_msg_adm := 'G_trait_entete 1 ? : ' || g_trait_entete;
        p_ins_journal;
---fin-debogage
--*

     END IF;

     --
     -- LECTURE D'1 Ligne dans la table principale
     --
     FETCH c_select_info
      INTO r_select_info;

     IF c_select_info%NOTFOUND
     THEN
        o_found := 0;
        p_fin_traitement;
/*
        --#SBA 20111005#
        pk_dev_vr01b_sepa.p_generer_virements_bordereaux
          ( ii_numremise_debut=>i_numremise
          , in_session        =>i_session
          , in_niv_msg        =>1
          , in_idligne        =>g_idligne
          , on_found          =>n_found
          , ov_erreur         =>v_erreur
          );*/
     ELSE
        o_found := 1;
        g_numvirement := r_select_info.numvirement;
        g_codbque := r_select_info.codbque;
        g_guichet := r_select_info.guichet;
        g_compte := r_select_info.compte;
        g_clerib := r_select_info.clerib;
        g_intitule := r_select_info.intitule;
        g_montant := r_select_info.montant;
        g_monnaie := r_select_info.monnaie;
        g_symbole := r_select_info.symbole;
        g_numdecaismt := r_select_info.numdecaismt;
        g_numremise := r_select_info.numremise;
        --
        p_traitement_principal;
     END IF;

     --
     o_erreur := g_erreur;

  --
  EXCEPTION
     WHEN OTHERS
     THEN
        g_niv_msg := 0;
        g_msg_adm := 'PK_DEV_VR01B - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
        o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
        p_ins_journal;

        CLOSE c_select_info;
--
  END;

--
-- -----------------------------
   PROCEDURE p_traitement_principal
   IS
   BEGIN
--
      g_proc := 'P_traitement_principal';
--
--*
----debut-debogage
      g_niv_msg := 3;
      g_msg_adm := 'G_trait_entete 2 ? : ' || g_trait_entete;
      p_ins_journal;

----fin-debogage
--*
      IF g_trait_entete IS NULL
      THEN
--*
----debut-debogage
         g_niv_msg := 3;
         g_msg_adm := 'Trt Entete';
         p_ins_journal;
----fin-debogage
--*
      --
         p_select_reference;
         --
         g_lemetteur := LPAD (NVL (TO_CHAR (g_emetteur), '0'), 6, '0');
         g_lnumremise := LPAD (NVL (TO_CHAR (g_numremise), '0'), 7, '0');
         g_datejour := TO_CHAR (SYSDATE, 'DDMMY');
         --
         g_montant_total := 0;
      --
      -- ouverture du fichier à écrire
      --
/*          G_suffixe_fich_vire  := nvl(to_char(G_numremise),'0');
      Nom_fich_vire     := 'VIREMENT-'||G_date||'-'||G_suffixe_fich_vire||'-'||G_heure||'.txt';
*/
      --
      -- Formatage du nom de fichier
         p_nom_fichier;
         --
         -- Ouverture du fichier de sortie
         --
         virement := UTL_FILE.fopen (g_repertoire, g_fichier, 'W');
         --
         p_entete_info;
         --
         g_trait_entete := '1';
      --
      END IF;

--
      p_corps_info;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- -----------------------
   PROCEDURE p_entete_info
   IS
   BEGIN
--
      g_proc := 'P_ENTETE_info';

--
/*
   G_niv_msg  := 1;
      G_msg_adm   := '02 '||G_emetteur||' '||'0'||' '||G_datejour||G_rais_soc||G_numremise;
   P_INS_journal;
   -- Fin ecriture dans le Journal
   --
   IF G_ident is NULL or G_ident = '0'
      THEN
      G_msg_adm   := G_monnaie||'     '||G_guichet_soc||G_compte_soc||
                G_ident||G_identifiant||G_codbque_soc;
   ELSE
      G_msg_adm   := G_monnaie||'     '||G_guichet_soc||G_compte_soc||G_codbque_soc;
   END IF;
   --
   G_niv_msg   := 1;
   P_INS_journal;
   -- Fin ecriture dans le Journal
*/
--
      IF g_ident = 0
      THEN
         ed_parenthese := RPAD (' ', 1, ' ');
         ed_ident := RPAD (' ', 1, ' ');
         ed_identifiant := RPAD (' ', 14, ' ');
      ELSE
         ed_parenthese := ')';
         ed_ident := TO_CHAR (g_ident);
         ed_identifiant := RPAD (NVL (g_identifiant, ' '), 14, ' ');
      END IF;

--
      ligne_1 := NULL;
--
      ligne_1 := '03';
      ligne_1 := ligne_1 || '02';
      ligne_1 := ligne_1 || RPAD (' ', 8, ' ');
      ligne_1 := ligne_1 || g_lemetteur;
      ligne_1 := ligne_1 || RPAD (' ', 1, ' ');
      ligne_1 := ligne_1 || '0';
      ligne_1 := ligne_1 || RPAD (' ', 5, ' ');
      ligne_1 := ligne_1 || g_datejour;
      ligne_1 := ligne_1 || RPAD (NVL (g_rais_soc, ' '), 24, ' ');
      ligne_1 := ligne_1 || g_lnumremise;
      ligne_1 := ligne_1 || RPAD (' ', 19, ' ');
      ligne_1 := ligne_1 || g_symbole;
      ligne_1 := ligne_1 || RPAD (' ', 3, ' ');
      ligne_1 := ligne_1 || g_guichet_soc;
      ligne_1 := ligne_1 || g_compte_soc;
      ligne_1 := ligne_1 || ed_parenthese;
      ligne_1 := ligne_1 || ed_ident;
      ligne_1 := ligne_1 || ed_identifiant;
      ligne_1 := ligne_1 || RPAD (' ', 31, ' ');
      ligne_1 := ligne_1 || g_codbque_soc;
      ligne_1 := ligne_1 || RPAD (' ', 6, ' ');
--
      g_niv_msg := 3;
      g_msg_adm := 'Ligne 1 - a : ' || SUBSTR (ligne_1, 1, 80);
      p_ins_journal;
      g_niv_msg := 3;
      g_msg_adm := 'Ligne 1 - b : ' || SUBSTR (ligne_1, 81, 80);
      p_ins_journal;
--
      --on enleve les accents generateur erreur UTF8 PH 08/07/2011
      ligne_1:= TRANSLATE(ligne_1,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO ');
      UTL_FILE.put_line (virement, ligne_1);
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- ----------------------
   PROCEDURE p_corps_info
   IS
   BEGIN
--
      g_proc := 'P_CORPS_info';
--
   --
      g_numbene_trouve := 'O';

      --
      BEGIN
         SELECT numbene, typbene
           INTO g_numbene, g_typbene
           FROM decaismt
          WHERE numdecaismt = g_numdecaismt;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_numbene_trouve := 'N';
            g_numbene := NULL;
      END;

      --
      IF g_numbene_trouve = 'O'
      THEN
         BEGIN
            SELECT f_bene_virement (g_numbene, g_typbene, g_numdecaismt, 1)
              INTO g_beneficiaire
              FROM decaismt
             WHERE numdecaismt = g_numdecaismt AND codope = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               g_beneficiaire := NULL;
         END;
      ELSE
         g_beneficiaire := NULL;
      END IF;

      --
      ed_beneficiaire := RPAD (NVL (g_beneficiaire, ' '), 18, ' ');
   --
/*
   G_niv_msg   := 2;
   G_msg_adm   := '02 '||G_lemetteur||G_numbene||G_intitule||'   '||G_guichet
      ||G_compte||G_montant||') VIR='||G_numvirement||Ed_beneficiaire||G_codbque;
   P_INS_journal;
   -- Fin ecriture dans le Journal
*/
--
      ligne_2 := NULL;
--
      ligne_2 := '06';
      ligne_2 := ligne_2 || '02';
      ligne_2 := ligne_2 || RPAD (' ', 8, ' ');
      ligne_2 := ligne_2 || g_lemetteur;
      ligne_2 := ligne_2 || RPAD (NVL (TO_CHAR (g_numbene), ' '), 12, ' ');
      ligne_2 := ligne_2 || RPAD (NVL (g_intitule, ' '), 24, ' ');
      ligne_2 := ligne_2 || RPAD (' ', 20, ' ');
      ligne_2 := ligne_2 || RPAD (' ', 4, ' ');
      ligne_2 := ligne_2 || RPAD (' ', 8, ' ');
      ligne_2 := ligne_2 || g_guichet;
      ligne_2 := ligne_2 || RPAD (NVL (g_compte, ' '), 11, ' ');
      ligne_2 := ligne_2 || LPAD (NVL (TO_CHAR (g_montant), '0'), 16, '0');
      ligne_2 := ligne_2 || ')';
      ligne_2 := ligne_2 || 'VIR=';
      ligne_2 := ligne_2 || RPAD (NVL (TO_CHAR (g_numvirement), ' '), 8, ' ');
      ligne_2 := ligne_2 || ed_beneficiaire;
      ligne_2 := ligne_2 || g_codbque;
      ligne_2 := ligne_2 || RPAD (' ', 6, ' ');
--
      g_niv_msg := 3;
      g_msg_adm := 'Ligne 2 - a : ' || SUBSTR (ligne_2, 1, 80);
      p_ins_journal;
      g_niv_msg := 3;
      g_msg_adm := 'Ligne 2 - b : ' || SUBSTR (ligne_2, 81, 80);
      p_ins_journal;
--
--
      --on enleve les accents generateur erreur UTF8 PH 08/07/2011
      ligne_2:= TRANSLATE(ligne_2,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO ');
      UTL_FILE.put_line (virement, ligne_2);
--
      g_montant_total := g_montant_total + g_montant;

      --
      UPDATE decaismt
         SET refpmt = g_numvirement,
             datpay = TRUNC (SYSDATE),
             numchq = 0
       WHERE numdecaismt IN (SELECT numdecaismt
                               FROM remise_vire_detail
                              WHERE numvirement = g_numvirement);
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- ---------------------
   PROCEDURE p_total_info
   IS
   BEGIN
--
      g_proc := 'P_TOTAL_info';
--
      --
/*
   G_niv_msg   := 1;
   G_msg_adm   := '08 '||G_lemetteur||'      '||G_montant_total;
   P_INS_journal;
   -- Fin ecriture dans le Journal
*/
--
      ligne_3 := NULL;
--
      ligne_3 := '08';
      ligne_3 := ligne_3 || '02';
      ligne_3 := ligne_3 || RPAD (' ', 8, ' ');
      ligne_3 := ligne_3 || g_lemetteur;
      ligne_3 := ligne_3 || RPAD (' ', 84, ' ');
      ligne_3 :=
              ligne_3 || LPAD (NVL (TO_CHAR (g_montant_total), '0'), 16, '0');
      ligne_3 := ligne_3 || RPAD (' ', 31, ' ');
      ligne_3 := ligne_3 || RPAD (' ', 5, ' ');
      ligne_3 := ligne_3 || RPAD (' ', 6, ' ');
--
      g_niv_msg := 3;
      g_msg_adm := 'Ligne 3 - a : ' || SUBSTR (ligne_3, 1, 80);
      p_ins_journal;
      g_niv_msg := 3;
      g_msg_adm := 'Ligne 3 - b : ' || SUBSTR (ligne_3, 81, 80);
      p_ins_journal;
--
--
      --on enleve les accents generateur erreur UTF8 PH 08/07/2011
      ligne_3:= TRANSLATE(ligne_3,'ÀÄÈÉÊËÎÏàáâäèéêëîïôûüÛÚÔ''','AAEEEEIIaaaaeeeeiiouuUUO ');
      UTL_FILE.put_line (virement, ligne_3);
--
      g_montant_total := 0;

      --
      UPDATE remise_vire
         SET datdisk = TRUNC (SYSDATE)
       WHERE numremise = g_lnumremise;
   --
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- -------------------------
   PROCEDURE p_select_reference
   IS
      r_select_reference   c_select_reference%ROWTYPE;
   BEGIN
--
      g_proc := 'P_select_reference';

--
      OPEN c_select_reference;

      FETCH c_select_reference
       INTO r_select_reference;

      IF c_select_reference%FOUND
      THEN
         g_refsoc := r_select_reference.refsoc;
         g_numcpte := r_select_reference.numcpte;
         g_codbque_soc := r_select_reference.codbque;
         g_guichet_soc := r_select_reference.guichet;
         g_compte_soc := r_select_reference.compte;
         g_rib_soc := r_select_reference.clerib;
         g_emetteur := r_select_reference.emetteur;
         g_ident := r_select_reference.ident;
         g_identifiant := r_select_reference.identifiant;
         g_rais_soc := r_select_reference.rais_soc;
      END IF;

      CLOSE c_select_reference;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
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
      g_bdx := NVL (TO_CHAR (g_numremise), '0');

      --
      OPEN c_remise_vire;

      FETCH c_remise_vire
       INTO g_bqe;

      CLOSE c_remise_vire;

      --
      SELECT REPLACE (REPLACE (REPLACE (REPLACE (g_fichier, '#DT', g_date),
                                        '#HR',
                                        g_heure
                                       ),
                               '#BQE',
                               g_bqe
                              ),
                      '#BDX',
                      g_bdx
                     )
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
--
-- DEBUT ET FIN DU TRAITEMENT
--
-- ----------------------------------------------------------------------------------------
   PROCEDURE p_debut_traitement
   IS
   BEGIN
--
      g_proc := 'P_debut_traitement';
--
      g_niv_msg := 1;
      g_msg_adm :=
         'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi:ss');
      p_ins_journal;

      -- Fin ecriture dans le Journal
      OPEN c_select_info;

      g_trait_entete := NULL;
      g_montant_total := 0;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- -----------------------
   PROCEDURE p_fin_traitement
   IS
   BEGIN
--
      g_proc := 'P_fin_traitement';

--
      IF g_trait_entete IS NOT NULL
      THEN
         p_total_info;
--
------------
         g_niv_msg := 3;
         g_msg_adm := 'fermeture fichier';
         p_ins_journal;
------------
      -- fermeture du fichier à écrire
      --
         UTL_FILE.fclose (virement);
      --
      END IF;

      --
      -- FERMETURE du Curseur
      --
      CLOSE c_select_info;

      --
      INSERT INTO lib_edition
                  (numedit,
                   editlib
                  )
           VALUES (g_session,
                   ('Generation fichier de virements' || g_numremise
                   )
                  );

      --
      g_niv_msg := 1;
      g_msg_adm :=
            'Fin Normale du traitement le '
         || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi:ss');
      p_ins_journal;
   -- Fin ecriture dans le Journal
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
----------------------- Fin des procedures publiques ------------------

   -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
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
   END p_ins_journal;
---------------- Fin des corps des procedures privees --
END;
/
