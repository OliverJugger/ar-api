CREATE OR REPLACE PACKAGE ARTHUS."PK_RUWA"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_ruwa.sql      1.4  03/10/28
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
--@pub
-- Traitement d'une remise et renvoi des lignes fichier
--
   PROCEDURE p_traite_remise (
      i_numremise     IN       remise_externe.numremise%TYPE,
      o_attest_prec   OUT      VARCHAR2,
      o_entete        OUT      VARCHAR2,
      o_expedition    OUT      VARCHAR2,
      o_attest_1      OUT      VARCHAR2,
      o_attest_2      OUT      VARCHAR2,
      o_attest_3      OUT      VARCHAR2
   );

--
-- Mise a jour de date_trans de remise_externe
--
   PROCEDURE p_maj_remise_externe (
      i_numremise   IN   remise_externe.numremise%TYPE
   );
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_RUWA"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_ruwa.sql      1.4  03/10/28
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --
-- -- TYPES PRIVEES -----------------------------------------------------------
   TYPE t_adresse IS TABLE OF VARCHAR2 (32)
      INDEX BY BINARY_INTEGER;

   TYPE t_domaine IS TABLE OF VARCHAR2 (10)
      INDEX BY BINARY_INTEGER;

   TYPE t_ayd IS TABLE OF VARCHAR2 (50)
      INDEX BY BINARY_INTEGER;

   TYPE t_renvoi IS TABLE OF VARCHAR2 (85)
      INDEX BY BINARY_INTEGER;

   TYPE t_garayd IS TABLE OF VARCHAR2 (7)
      INDEX BY BINARY_INTEGER;                                  -- 16/01/2004

-- --------------------------------------------------- Fin des types privees --
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--@global
-- Parametres de la demande
   g_numremise       remise_externe.numremise%TYPE;
-- Information client
   g_client          NUMBER;
-- Infos porte
   g_numsoc          pers_societe.numsoc%TYPE;
   g_numorg          contrat.numorg%TYPE;
   g_numgar          contrat.numgar%TYPE;
   g_lnumgar         contrat.numgar%TYPE;
   g_numfor          gar_param_tp.numfor%TYPE;                  -- 05/01/2004
   g_refcontrat      VARCHAR2 (30);                   -- inserer en posit 164
   g_refcontrat_n    VARCHAR2 (30);                  -- inserer en posit 1270
   g_idparam_tp      param_tiers_payant.idparam_tp%TYPE;
   g_carte           param_tiers_payant.type_carte%TYPE;
   g_carte_prec      param_tiers_payant.type_carte%TYPE;
   g_idporte         porte_adhesion.idporte%TYPE;
   g_numindiv        porte_adhesion.numindiv%TYPE;
   g_numporte        porte_adhesion.numporte%TYPE;
   g_idadhesion      adhe_cntrt.idadhesion%TYPE;
   g_sous_regime     VARCHAR2 (15);
   g_numayd          porte_adhesion.numindiv%TYPE;
-- Infos personne
   g_adresse         t_adresse;
   g_adr_null        t_adresse;
-- Infos param_tiers_payant
   g_type_carte      param_tiers_payant.type_carte%TYPE;
   g_mode_exp        param_tiers_payant.mode_exp%TYPE;
   g_numdest         param_tiers_payant.numdest%TYPE;
   g_code_lettre     param_tiers_payant.code_lettre%TYPE;
   g_calcul          param_tiers_payant.calcul%TYPE;
   g_famille         param_tiers_payant.famille%TYPE;
   g_organisme       param_tiers_payant.organisme%TYPE;
   g_centre          param_tiers_payant.centre%TYPE;
   g_type_poch       param_tiers_payant.type_poch%TYPE;
   g_garantie        param_tiers_payant.garantie%TYPE;
   g_debiteur_aphp   param_tiers_payant.debiteur_aphp%TYPE;
-- Informations domaines
   g_domaine         t_domaine;
   g_circuit         t_domaine;
   g_regle           t_domaine;
   g_renvoi          t_domaine;
   g_lib_renvoi      t_renvoi;
-- Informations assure
   g_adr_assu        t_adresse;
   g_numassu         VARCHAR2 (15);
   g_nomassu         VARCHAR2 (40);
   g_matorg          VARCHAR2 (15);
   g_regime          VARCHAR2 (5);
   g_datnais_assu    VARCHAR2 (8);
   g_contrat         VARCHAR2 (16);
   g_debut           VARCHAR2 (8);
   g_fin             VARCHAR2 (8);
   g_amc             VARCHAR2 (25);
-- Infos ayant droits
   g_ayd             t_ayd;
   g_garayd          t_garayd;
   g_nb_ayd          NUMBER                                  := 0;
   g_a_traiter       NUMBER                                  := 0;
-- Enregistrements en sortie
   g_entete          VARCHAR2 (550);
   g_expedition      VARCHAR2 (256);
   g_attestation     VARCHAR2 (2500);
   g_attest_1        VARCHAR2 (2500);
   g_attest_2        VARCHAR2 (2500);
   g_attest_3        VARCHAR2 (2500);
--
   g_nomdest         VARCHAR2 (32);
   g_lnumdest        NUMBER                                  := 0;
   g_datdeb          DATE;
   flag_fin          BOOLEAN                                 := FALSE;
-- DonnÚes Emetteur (Identifiant - AMC);
   g_numreg          parporte.numreg%TYPE;

-- -------------------------------------- Fin des variables globales privees
-- -- DECLARATION DES CURSEURS PRIVES ---------------------------------------
--@curs
-----------------------------------------------------------------------------
   CURSOR c_remise
   IS
      SELECT   contrat.numinterm numsoc, contrat.numorg,
               contrat.refcie refcontrat, adhe_cntrt.numgar,
               adhe_cntrt.idadhesion, demande_tp.idparam_tp,
               param_tiers_payant.type_carte, porte_adhesion.idporte,
               porte_adhesion.numindiv, porte_adhesion.numporte,
               TO_CHAR (porte_adhesion.debut, 'ddmmyyyy') debut,
               TO_CHAR (porte_adhesion.fin, 'ddmmyyyy') fin
          FROM contrat,
               adhe_cntrt,
               porte_adhesion,
               demande_tp,
               param_tiers_payant
         WHERE contrat.numgar = adhe_cntrt.numgar
           AND adhe_cntrt.idadhesion = porte_adhesion.idadhesion
           AND porte_adhesion.numremise = g_numremise
           AND porte_adhesion.transmis = 2
           AND porte_adhesion.idporte = demande_tp.idporte
           AND param_tiers_payant.idparam_tp = demande_tp.idparam_tp
      ORDER BY param_tiers_payant.type_carte,
               demande_tp.idparam_tp,
               contrat.numinterm,
               contrat.numgar;

-- ----------------------------- Fin des declarations des procedures privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--@priv
-------------------------------------------------------------------------------
-- Complete une chaine avec un charactere
-------------------------------------------------------------------------------
   FUNCTION f_fill (
      i_chaine       IN   VARCHAR2,
      i_longueur     IN   NUMBER,
      i_character    IN   VARCHAR2 DEFAULT ' ',
      i_alignement   IN   NUMBER DEFAULT 1       /* si 1, complete a droite */
   )
      RETURN VARCHAR2;

-------------------------------------------------------------------------------
--
-- Construction de l'enregistrement entete
--
   PROCEDURE p_trt_entete;

--
-- Construction de l'enregistrement adresse
--
   PROCEDURE p_trt_adresse;

--
-- Construction de l'enregistrement attestation
--
   PROCEDURE p_trt_attestation;

--
-- Construction de l'attestation ( entete )
--
   PROCEDURE p_trt_entete_attes (i_traite IN NUMBER);

--
-- Construction de l'attestation ( corps )
--
   PROCEDURE p_trt_corps_attes (i_traite IN NUMBER);

--
-- Infos societe emettrice
--
   PROCEDURE p_sel_societe (
      o_abrege   OUT   pers_morale.abrege%TYPE,
      o_nom      OUT   VARCHAR2
   );

--
-- Infos assure
--
   PROCEDURE p_sel_assure;

--
-- Infos ayant droits
--
   PROCEDURE p_sel_ayd;

--
-- Infos adresse
--
   PROCEDURE p_sel_adresse (i_numindiv IN pers_adresse.numindiv%TYPE);

--
-- Infos adresse assure
--
   PROCEDURE p_sel_adr_assu (i_numindiv IN pers_adresse.numindiv%TYPE);

--
-- Infos param_tiers_payant
--
   PROCEDURE p_sel_param_tp;

--
-- Infos domaines
--
   PROCEDURE p_sel_domaine;

--
-- Translation de refcontrat
--
   PROCEDURE p_sel_refcontrat;

--
-- Mise a jour transmis de porte_adhesion
--
   PROCEDURE p_maj_porte_adhesion;

--
-- libelles des renvois
--
   PROCEDURE p_sel_lib_renvoi;

--
-- Sous regime de l assure
--
   PROCEDURE p_sel_sous_regime;

--
-- Numero AMC
--
   PROCEDURE p_sel_amc (
      a_regime     IN   NUMBER,
      a_numsoc     IN   NUMBER,
      a_numorg     IN   NUMBER,
      a_numporte   IN   NUMBER
   );

-- 05/01/2004
-- Modification du chargement de la zone garantie
-- Paramtrage GLOBAL CONTRAT >>> garantie = PARAM_TIERS_PAYANT
--                                            (pas de changement)
-- Paramtrage par garantie et COUVERTURE >>> garantie = libelle
--                                        (table GAR_CNTRT)
--
   PROCEDURE p_sel_numfor;

--
   PROCEDURE p_sel_garantie;

--
-- 05/01/2004
--
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
-------------------------------------------------------------------------------
-- Traitement d'une remise et renvoi des lignes fichier
-------------------------------------------------------------------------------
   PROCEDURE p_traite_remise (
      i_numremise     IN       remise_externe.numremise%TYPE,
      o_attest_prec   OUT      VARCHAR2,
      o_entete        OUT      VARCHAR2,
      o_expedition    OUT      VARCHAR2,
      o_attest_1      OUT      VARCHAR2,
      o_attest_2      OUT      VARCHAR2,
      o_attest_3      OUT      VARCHAR2
   )
   IS
      rec_c_remise   c_remise%ROWTYPE;
      flag_entete    BOOLEAN            := FALSE;
   BEGIN
--
      g_client := f_client;
--
      flag_entete := FALSE;
      g_numremise := i_numremise;

--
      IF NOT c_remise%ISOPEN
      THEN
         OPEN c_remise;

         flag_entete := TRUE;
      END IF;

--
      FETCH c_remise
       INTO rec_c_remise;

--
      IF (c_remise%NOTFOUND)
      THEN
         CLOSE c_remise;

         RAISE NO_DATA_FOUND;
      END IF;

--
      IF (rec_c_remise.type_carte != NVL (g_carte, -1))
      THEN
         flag_entete := TRUE;
      END IF;

--      G_idadhesion     := Rec_C_remise.idadhesion;
      IF (rec_c_remise.idparam_tp != NVL (g_idparam_tp, -1))
      THEN
         g_idparam_tp := rec_c_remise.idparam_tp;

         IF (rec_c_remise.idadhesion != NVL (g_idadhesion, -1))  --05/01/2004
         THEN                                                   -- 05/01/2004
            g_idadhesion := rec_c_remise.idadhesion;            -- 05/01/2004
         END IF;                                                 -- 05/01/2004

         g_numindiv := rec_c_remise.numindiv;                    -- 05/01/2004

         IF (g_client != 2)
         THEN
            g_refcontrat := rec_c_remise.refcontrat;
         END IF;

         p_sel_param_tp;
         p_sel_refcontrat;
      END IF;

--      if ( Rec_C_remise.idadhesion != nvl(G_idadhesion, -1) )
--       or ( Rec_C_remise.refcontrat != nvl(G_refcontrat, -1)) then
      IF (rec_c_remise.idadhesion != NVL (g_idadhesion, -1))
      THEN
         g_idadhesion := rec_c_remise.idadhesion;
         g_refcontrat := rec_c_remise.refcontrat;
         p_sel_refcontrat;
      END IF;

--
      g_numsoc := rec_c_remise.numsoc;
      g_numorg := rec_c_remise.numorg;
      g_numgar := rec_c_remise.numgar;
      g_numporte := rec_c_remise.numporte;
      g_idparam_tp := rec_c_remise.idparam_tp;

--
      IF (g_carte = NULL)
      THEN
         g_carte_prec := rec_c_remise.type_carte;
      ELSE
         g_carte_prec := g_carte;
      END IF;

--
      g_carte := rec_c_remise.type_carte;
      g_idporte := rec_c_remise.idporte;
      g_numindiv := rec_c_remise.numindiv;
      g_debut := rec_c_remise.debut;
      g_fin := rec_c_remise.fin;
--
      g_datdeb := TO_DATE (g_debut, 'DDMMYYYY');

--
      IF (g_carte_prec != g_carte)
      THEN
         flag_fin := TRUE;
      END IF;

--
      IF (flag_fin)
      THEN
         o_attest_prec := '99';
         flag_fin := FALSE;
      ELSE
         o_attest_prec := NULL;
      END IF;

--
-- Enregistrement entete
--
      IF (flag_entete)
      THEN
         p_trt_entete;
         flag_entete := FALSE;
         o_entete := g_entete;
         g_entete := NULL;
      END IF;

--
-- Enregistrement adresse
--
      IF (g_mode_exp = 99)
      THEN
         IF (g_numdest != g_lnumdest)
         THEN
            g_lnumdest := g_numdest;
            --
            g_nomdest :=
               f_fill (UPPER (f_desaccentue (pk_personne.f_nom (g_numdest, 32))
                             ),
                       32
                      );
            p_sel_adresse (i_numindiv => g_numdest);
            p_trt_adresse;
            o_expedition := g_expedition;
            g_expedition := NULL;
         --
         END IF;
      ELSE
         g_lnumdest := g_numindiv;
         g_nomdest :=
            f_fill (UPPER (f_desaccentue (pk_personne.f_nom (g_numindiv, 32))),
                    32
                   );
         p_sel_adresse (i_numindiv => g_numindiv);
         p_trt_adresse;
         o_expedition := g_expedition;
         g_expedition := NULL;
      --
      END IF;

--
      p_sel_sous_regime;
      p_sel_assure;
-- 19/01/2004  par Nabil
      p_sel_amc (a_regime        => g_numreg,                    -- 19/01/2004
                 a_numsoc        => g_numsoc,                    -- 19/01/2004
                 a_numorg        => g_numorg,                    -- 19/01/2004
                 a_numporte      => g_numporte
                );                                               -- 19/01/2004
--  19/01/2004
      p_sel_domaine;
      p_sel_ayd;
      p_sel_lib_renvoi;
      p_trt_attestation;
--
      o_attest_1 := g_attest_1;
      o_attest_2 := g_attest_2;
      o_attest_3 := g_attest_3;
--
      g_attest_1 := NULL;
      g_attest_2 := NULL;
      g_attest_3 := NULL;
      g_attestation := NULL;
--
      p_maj_porte_adhesion;
   END p_traite_remise;

-------------------------------------------------------------------------------
-- Mise a jour de date_trans de remise_externe
-------------------------------------------------------------------------------
   PROCEDURE p_maj_remise_externe (
      i_numremise   IN   remise_externe.numremise%TYPE
   )
   IS
   BEGIN
      UPDATE remise_externe
         SET date_trans = TRUNC (SYSDATE)
       WHERE numremise = i_numremise;
   END p_maj_remise_externe;

-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--@cpriv
--
-- Complete une chaine avec un charactere
--
-------------------------------------------------------------------------------
   FUNCTION f_fill (
      i_chaine       IN   VARCHAR2,
      i_longueur     IN   NUMBER,
      i_character    IN   VARCHAR2 DEFAULT ' ',
      i_alignement   IN   NUMBER DEFAULT 1
   )
      RETURN VARCHAR2
   IS
      l_chaine   VARCHAR2 (250) := i_chaine;
   BEGIN
      LOOP
         EXIT WHEN (LENGTH (l_chaine) >= i_longueur);

         IF (i_alignement = 1)
         THEN
            l_chaine := l_chaine || i_character;
         ELSE
            l_chaine := i_character || l_chaine;
         END IF;
      END LOOP;

--
      RETURN (l_chaine);
   END f_fill;

-------------------------------------------------------------------------------
-- Construction de l'enregistrement entete
-------------------------------------------------------------------------------
   PROCEDURE p_trt_entete
   IS
      l_abrege   pers_morale.abrege%TYPE;
      l_nom      VARCHAR2 (32);
      i          BINARY_INTEGER;
   BEGIN
      g_entete := '00';
--
      p_sel_societe (o_abrege => l_abrege, o_nom => l_nom);
-- Identifiant et nom societe
      g_entete := g_entete || l_abrege || f_fill ('', 6) || l_nom;

-- Adresse societe
      FOR i IN 1 .. 5
      LOOP
         g_entete := g_entete || g_adresse (i);
      END LOOP;

-- Type de carte
      g_entete :=
            g_entete
         || f_fill (UPPER (f_desaccentue (pk_libelle.f_lib ('TYPE_CARTE',
                                                            g_type_carte
                                                           )
                                         )
                          ),
                    32
                   );
-- Version de programme et date de commande
      g_entete := g_entete || '06' || TO_CHAR (SYSDATE, 'ddmmyy');
      DBMS_OUTPUT.put_line ('Entete ' || g_entete);
-- Quantites commandees ( sans controle )
      g_entete :=
            g_entete
         || f_fill ('', 5, '0')
         || f_fill ('', 5, '0')
         || f_fill ('', 5, '0');
-- Mode d'expedition ( en prevision )
      g_entete := g_entete || f_fill ('', 1);

-- Adresse expedition de la bande ( en prevision )
      FOR i IN 1 .. 6
      LOOP
         g_entete := g_entete || f_fill ('', 32);
      END LOOP;

-- Remarque concernant le traitement ( en prevision )
      FOR i IN 1 .. 3
      LOOP
         g_entete := g_entete || f_fill ('', 32);
      END LOOP;
   END p_trt_entete;

-------------------------------------------------------------------------------
-- Construction de l'enregistrement adresse
-------------------------------------------------------------------------------
   PROCEDURE p_trt_adresse
   IS
   BEGIN
      g_expedition := '01';
-- Nom du destinataire
      g_expedition := g_expedition || g_nomdest;

-- Adresse destinataire
      FOR i IN 1 .. 5
      LOOP
         g_expedition := g_expedition || g_adresse (i);
      END LOOP;

-- Filler
      g_expedition := g_expedition || f_fill ('', 8);

-- Mode d'expedition
      IF (g_mode_exp = 88)
      THEN
         g_mode_exp := 77;
      END IF;

      g_expedition := g_expedition || g_mode_exp;
-- Nombre d'enregistrements ( pas de controle )
      g_expedition := g_expedition || f_fill ('', 5, '0');
-- Adresse expedition ( en prevision )
      g_expedition := g_expedition || f_fill ('', 32);

-- Code lettre pour envoi groupe
      IF (g_mode_exp = 99)
      THEN
         g_expedition := g_expedition || 'G1';
      ELSE
         g_expedition := g_expedition || f_fill ('', 2);
      END IF;

-- Code interne
      g_expedition := g_expedition || f_fill ('', 10, '0');
      DBMS_OUTPUT.put_line (g_expedition);
-- Titre ( en prevision )
      g_expedition := g_expedition || f_fill ('', 2);
   END p_trt_adresse;

-------------------------------------------------------------------------------
-- Construction de l'enregistrement attestation
-------------------------------------------------------------------------------
   PROCEDURE p_trt_attestation
   IS
      i   BINARY_INTEGER := 0;
   BEGIN
--
      p_trt_entete_attes (i_traite => 0);
      p_trt_corps_attes (i_traite => 0);

--                                                                              -- 05/01/2004
-- 05/01/2004 A aprtir de ce point, les lignes sont ajoutÚes
--                                                                              -- 05/01/2004
      IF (g_attest_1 IS NULL)
      THEN
         g_attest_1 := g_attestation;
      END IF;

--
      IF (g_a_traiter < g_nb_ayd)
      THEN
         p_trt_entete_attes (i_traite => 5);
         p_trt_corps_attes (i_traite => 5);

         IF (g_attest_2 IS NULL)
         THEN
            g_attest_2 := g_attestation;
         END IF;

--
         IF (g_a_traiter < g_nb_ayd)
         THEN
            p_trt_entete_attes (i_traite => 10);
            p_trt_corps_attes (i_traite => 10);

            IF (g_attest_2 IS NULL)
            THEN
               g_attest_2 := g_attestation;
            END IF;

--
            IF (g_attest_3 IS NULL AND g_attest_2 IS NOT NULL)
            THEN
               g_attest_3 := g_attestation;
            END IF;
         END IF;
--
      END IF;
--                                                              -- 05/01/2004
-- 05/01/2004 Fin des lignes ajoutÚes
--                                                              -- 05/01/2004
   END p_trt_attestation;

-------------------------------------------------------------------------------
-- Construction de l'attestation ( entete )
-------------------------------------------------------------------------------
   PROCEDURE p_trt_entete_attes (i_traite IN NUMBER)
   IS
      i          BINARY_INTEGER := 0;
      l_traite   NUMBER         := i_traite;
   BEGIN
      g_attestation := 'FR';
-- Code lettre
      g_attestation := g_attestation || f_fill (g_code_lettre, 2);
-- Codes divers ( cas a voir )
      g_attestation :=
                   g_attestation || f_fill ('', 2, '0')
                   || f_fill ('', 2, '0');
-- Code pochette
      g_attestation := g_attestation || TO_CHAR (g_type_poch);
-- Utilisation future
      g_attestation := g_attestation || f_fill ('', 10);
-- Numero AMC ( Sintia -> futur )
      g_attestation := g_attestation || f_fill (g_amc, 15);
-- Numero d'adherent -> futur
      g_attestation := g_attestation || f_fill (g_numindiv, 15);
-- Code debiteur
      g_attestation := g_attestation || f_fill (g_debiteur_aphp, 15);
-- Utilisation future
      g_attestation := g_attestation || f_fill ('', 20);
-- Nom et prenom de l'assure
      g_attestation := g_attestation || g_nomassu;
-- N° INSEE
      g_attestation := g_attestation || g_matorg;
-- Regime, caisse
      g_attestation := g_attestation || g_regime;
-- Autre
      g_attestation := g_attestation || f_fill ('', 4);
-- Complement grand regime
      g_attestation := g_attestation || f_fill (g_sous_regime, 15);
-- Numero de contrat (donnee alpha numerique recuperee dans P_SEL_refcontrat)
      g_attestation := g_attestation || g_refcontrat;
-- Utilisation future
      g_attestation := g_attestation || f_fill ('', 10);
-- Periode de garantie
      g_attestation := g_attestation || g_debut || g_fin || f_fill ('', 8);
--
      DBMS_OUTPUT.put_line (g_attestation);
--
   END p_trt_entete_attes;

-------------------------------------------------------------------------------
-- Construction de l'attestation ( corps )
-------------------------------------------------------------------------------
   PROCEDURE p_trt_corps_attes (i_traite IN NUMBER)
   IS
      i          BINARY_INTEGER := 0;
      l_traite   NUMBER         := i_traite;
   BEGIN
-- Abreviation des domaines
      FOR i IN 1 .. 9
      LOOP
         g_attestation := g_attestation || g_domaine (i);
      END LOOP;

-- Abreviation des circuits
      FOR i IN 1 .. 9
      LOOP
         g_attestation := g_attestation || g_circuit (i);
      END LOOP;

---------------------------------------------------------------------------------
-- Beneficiaires -> ouvreur de droits
--
-- 05/01/2004   If ( I_traite = 0 )
-- 05/01/2004           then
-- 05/01/2004           L_traite        := 0;
        -- Nom
-- 05/01/2004           G_attestation := G_attestation || G_nomassu;
        -- Date de naissance et rang
-- 05/01/2004           G_attestation := G_attestation || G_datnais_assu || '1';
        -- garantie
-- 05/01/2004           G_attestation := G_attestation || F_fill(G_garantie, 7);
        -- Les 9 taux
-- 05/01/2004           For i IN 1 .. 9 Loop
-- 05/01/2004                   G_attestation := G_attestation ||
-- 05/01/2004                   nvl( G_regle(i), F_fill('', 10) );
-- 05/01/2004           End Loop;
        -- Les 9 renvois
-- 05/01/2004           For i IN 1 .. 9 Loop
-- 05/01/2004                   G_attestation := G_attestation ||
-- 05/01/2004                   nvl( G_renvoi(i), F_fill('', 5) );
-- 05/01/2004           End Loop;
        --
-- 05/01/2004           L_traite := L_traite + 1;
-- 05/01/2004           G_a_traiter := 4;
        --
-- 05/01/2004           Dbms_output.put_line( SUBSTR(G_attestation, 214, 255) );
-- 05/01/2004   End If;
--
-- Ayant droits
-- 05/01/2004   Dbms_output.put_line
-- 05/01/2004           ( 'Traite '|| L_traite || ' A traiter '|| G_a_traiter);
-- 05/01/2004   For i IN L_traite .. G_a_traiter Loop
-- 05/01/2004   L_traite := L_traite + 1;
--
---------------------------------------------------------------------------------
      g_a_traiter := l_traite + 5;                               -- 05/01/2004

      FOR i IN (l_traite + 1) .. g_a_traiter
      LOOP                                                       -- 05/01/2004
         p_sel_garantie;                                        -- 16/01/2004
         g_attestation := g_attestation || g_ayd (i);

         --
         IF (g_ayd (i) != f_fill ('', 49))
         THEN
-- 16/01/2004
                -- G_attestation := G_attestation || F_fill(G_garantie, 7);
            g_attestation := g_attestation || f_fill (g_garayd (i), 7);

-- 16/01/2004
                -- Les 9 taux
            FOR i IN 1 .. 9
            LOOP
               g_attestation :=
                          g_attestation || NVL (g_regle (i), f_fill ('', 10));
            END LOOP;

            -- Les 9 renvois
            FOR i IN 1 .. 9
            LOOP
               g_attestation :=
                          g_attestation || NVL (g_renvoi (i), f_fill ('', 5));
            END LOOP;
         ELSE
            g_attestation := g_attestation || f_fill ('', 7);

            -- Les 9 taux
            FOR i IN 1 .. 9
            LOOP
               g_attestation := g_attestation || f_fill ('', 10);
            END LOOP;

            -- Les 9 renvois
            FOR i IN 1 .. 9
            LOOP
               g_attestation := g_attestation || f_fill ('', 5);
            END LOOP;
         END IF;

         --
         l_traite := l_traite + 1;
      --
      END LOOP;

        --
--
      DBMS_OUTPUT.put_line (SUBSTR (g_attestation, 214, 255));   -- 05/01/2004
      DBMS_OUTPUT.put_line (SUBSTR (g_attestation, 495, 255));
      DBMS_OUTPUT.put_line (SUBSTR (g_attestation, 750, 255));
      DBMS_OUTPUT.put_line (SUBSTR (g_attestation, 1005, 255));
--
-- Ancienne reference Sante Pharma
--
      g_attestation :=
            g_attestation
         || f_fill (g_calcul || g_famille || g_organisme || g_centre, 11);
-- Numero de contrat (donnee numerique recuperee dans P_SEL_refcontrat)
      g_attestation := g_attestation || g_refcontrat_n;
-- libelles des renvois
      g_attestation := g_attestation || g_lib_renvoi (1);

      FOR i IN 2 .. 4
      LOOP
         g_attestation := g_attestation || f_fill (g_lib_renvoi (i), 85);
      END LOOP;

--
      DBMS_OUTPUT.put_line (SUBSTR (g_attestation, 1259, 255));

--
-- Adresse a mettre sur la lettre
      FOR i IN 1 .. 6
      LOOP
         g_attestation := g_attestation || g_adr_assu (i);
      END LOOP;

      DBMS_OUTPUT.put_line (SUBSTR (g_attestation, 1626, 255));
--
      DBMS_OUTPUT.put_line ('Traite fin ' || l_traite || ' Nb_ayd '
                            || g_nb_ayd
                           );
-- 05/01/2004   If ( G_attest_1 Is Null ) then
-- 05/01/2004           G_attest_1 := G_attestation;
-- 05/01/2004   End if;
--
-- 05/01/2004   If ( L_traite < G_nb_ayd ) then
-- 05/01/2004   G_a_traiter := G_a_traite + 5;
-- 05/01/2004           P_TRT_entete_attes
-- 05/01/2004                   (I_traite => L_traite);
-- 05/01/2004           P_TRT_corps_attes
-- 05/01/2004                   (I_traite => L_traite);
-- 05/01/2004           If ( G_attest_2 Is Null ) then
-- 05/01/2004                   G_attest_2 := G_attestation;
-- 05/01/2004                end if;
--
-- 05/01/2004           If ( G_attest_3 Is Null and G_attest_2 Is Not Null )
-- 05/01/2004              then
-- 05/01/2004                   G_attest_3 := G_attestation;
-- 05/01/2004           End If;
--
-- 05/01/2004   end if;
   END p_trt_corps_attes;

-------------------------------------------------------------------------------
-- Infos societe emettrice
-------------------------------------------------------------------------------
   PROCEDURE p_sel_societe (
      o_abrege   OUT   pers_morale.abrege%TYPE,
      o_nom      OUT   VARCHAR2
   )
   IS
      CURSOR c_soc
      IS
         SELECT UPPER (f_desaccentue (SUBSTR (pers_morale.abrege, 1, 4))
                      ) abrege,
                pers_societe.numindiv,
                UPPER
                   (f_desaccentue (pk_personne.f_nom (pers_societe.numindiv,
                                                      32
                                                     )
                                  )
                   ) nom
           FROM pers_morale, pers_societe
          WHERE pers_morale.numindiv = pers_societe.numindiv
            AND pers_societe.numsoc = g_numsoc;

      rec_c_soc   c_soc%ROWTYPE;
   BEGIN
--
      OPEN c_soc;

      FETCH c_soc
       INTO rec_c_soc;

      CLOSE c_soc;

--
      o_abrege := f_fill (rec_c_soc.abrege, 4);
      o_nom := f_fill (rec_c_soc.nom, 32);
--
      p_sel_adresse (i_numindiv => rec_c_soc.numindiv);
--
   END p_sel_societe;

-------------------------------------------------------------------------------
-- Infos adresse
-------------------------------------------------------------------------------
   PROCEDURE p_sel_adresse (i_numindiv IN pers_adresse.numindiv%TYPE)
   IS
      i   BINARY_INTEGER;
   BEGIN
      g_adresse := g_adr_null;

      FOR i IN 1 .. 5
      LOOP
         g_adresse (i) :=
              pk_personne.f_adresse (pk_personne.f_idadresse (i_numindiv), i);
         g_adresse (i) := f_fill (UPPER (f_desaccentue (g_adresse (i))), 32);
      END LOOP;
   END p_sel_adresse;

-------------------------------------------------------------------------------
-- Infos adresse assure
-------------------------------------------------------------------------------
   PROCEDURE p_sel_adr_assu (i_numindiv IN pers_adresse.numindiv%TYPE)
   IS
      i   BINARY_INTEGER;
   BEGIN
      g_adr_assu := g_adr_null;
      g_adr_assu (1) :=
         f_fill (UPPER (f_desaccentue (pk_personne.f_nom (i_numindiv, 32))),
                 32
                );

      FOR i IN 2 .. 6
      LOOP
         g_adr_assu (i) :=
            pk_personne.f_adresse (pk_personne.f_idadresse (i_numindiv),
                                   i - 1
                                  );
         g_adr_assu (i) := f_fill (UPPER (f_desaccentue (g_adr_assu (i))), 32);
      END LOOP;
   END p_sel_adr_assu;

-------------------------------------------------------------------------------
-- Infos param_tiers_payant
-------------------------------------------------------------------------------
   PROCEDURE p_sel_param_tp
   IS
      CURSOR c_tp
      IS
         SELECT type_carte, mode_exp, numdest, code_lettre, calcul, famille,
                organisme, centre, type_poch, garantie, debiteur_aphp
           FROM param_tiers_payant
          WHERE idparam_tp = g_idparam_tp;

      rec_c_tp   c_tp%ROWTYPE;
   BEGIN
      OPEN c_tp;

      FETCH c_tp
       INTO rec_c_tp;

      CLOSE c_tp;

--
      g_type_carte := rec_c_tp.type_carte;
      g_mode_exp := rec_c_tp.mode_exp;
      g_numdest := rec_c_tp.numdest;
      g_code_lettre := rec_c_tp.code_lettre;
      g_calcul := rec_c_tp.calcul;
      g_famille := rec_c_tp.famille;
      g_organisme := rec_c_tp.organisme;
      g_centre := rec_c_tp.centre;
      g_type_poch := rec_c_tp.type_poch;
      g_debiteur_aphp := rec_c_tp.debiteur_aphp;
--
-- 05/01/2004 G_garantie        := Rec_C_tp.garantie;
--
      p_sel_numfor;               -- Chargement de G_numfor     -- 05/01/2004
--
   END p_sel_param_tp;

-------------------------------------------------------------------------------
-- Infos domaines
-------------------------------------------------------------------------------
   PROCEDURE p_sel_domaine
   IS
      CURSOR c_domaine
      IS
         SELECT   domaine, circuit, regle, renvoi
             FROM param_demande_tp
            WHERE idparam_tp = g_idparam_tp
         ORDER BY ordre;

      rec_c_domaine   c_domaine%ROWTYPE;
      nb_domaine      BINARY_INTEGER      := 0;
      i               BINARY_INTEGER      := 0;
   BEGIN
      OPEN c_domaine;

      LOOP
         FETCH c_domaine
          INTO rec_c_domaine;

         EXIT WHEN c_domaine%NOTFOUND;
         --
         nb_domaine := nb_domaine + 1;
         g_domaine (nb_domaine) := f_fill (rec_c_domaine.domaine, 5);
         g_circuit (nb_domaine) := f_fill (rec_c_domaine.circuit, 5);
         g_regle (nb_domaine) := f_fill (rec_c_domaine.regle, 10);
         g_renvoi (nb_domaine) := f_fill (rec_c_domaine.renvoi, 5);
      --
      END LOOP;

--
      FOR i IN nb_domaine + 1 .. 9
      LOOP
         g_domaine (i) := f_fill ('', 5);
         g_circuit (i) := f_fill ('', 5);
         g_regle (i) := f_fill ('', 10);
         g_renvoi (i) := f_fill ('', 5);
      END LOOP;
--
   END p_sel_domaine;

-------------------------------------------------------------------------------
-- Infos assure
-------------------------------------------------------------------------------
   PROCEDURE p_sel_assure
   IS
      CURSOR c_assu
      IS
         SELECT individu.nom, individu.prenom, demande_tp.numindiv,
                demande_tp.matorg, demande_tp.cless,
                TO_CHAR (demande_tp.datnais, 'ddmmyyyy') datnais,
                demande_tp.regime, demande_tp.caisse
           FROM individu, demande_tp
          WHERE individu.numindiv = demande_tp.numindiv
            AND demande_tp.idporte = g_idporte;

      rec_c_assu   c_assu%ROWTYPE;
   BEGIN
--
      OPEN c_assu;

      FETCH c_assu
       INTO rec_c_assu;

      CLOSE c_assu;

--
      g_nomassu :=
         UPPER (f_desaccentue (SUBSTR (   rec_c_assu.nom
                                       || ' '
                                       || rec_c_assu.prenom,
                                       1,
                                       40
                                      )
                              )
               );
      g_nomassu := f_fill (g_nomassu, 40);
      g_matorg :=
          rec_c_assu.matorg || SUBSTR (TO_CHAR (rec_c_assu.cless, '00'), 2, 2);
-- 19/01/2004 Ecarter par Nabil
      g_numreg := NVL (TO_NUMBER (rec_c_assu.regime), 0);        -- 19/01/2004
-- 19/01/2004   P_SEL_AMC (     a_regime => Rec_C_assu.regime,
-- 19/01/2004                           a_numsoc => G_numsoc,
-- 19/01/2004                           a_numorg => G_numorg,
-- 19/01/2004                   a_numporte => G_numporte  );
--
      g_regime := f_fill (rec_c_assu.regime || rec_c_assu.caisse, 5);
      g_datnais_assu := rec_c_assu.datnais;
      g_numassu := f_fill (TO_CHAR (rec_c_assu.numindiv), 15);
      p_sel_adr_assu (i_numindiv => rec_c_assu.numindiv);
   END p_sel_assure;

-------------------------------------------------------------------------------
-- Infos ayant droits
-------------------------------------------------------------------------------
   PROCEDURE p_sel_ayd
   IS
      CURSOR c_ayd
      IS
         SELECT individu.nom, individu.prenom, individu.numindiv,
                                                                -- 16/01/2004
                TO_CHAR (demande_tp_ad.datnais, 'ddmmyyyy') datnais,
                demande_tp_ad.rang
           FROM individu, demande_tp_ad
          WHERE individu.numindiv = demande_tp_ad.numindiv
            AND demande_tp_ad.idporte = g_idporte;

      rec_c_ayd   c_ayd%ROWTYPE;
      nb_ayd      BINARY_INTEGER  := 0;
      i           BINARY_INTEGER  := 0;
   BEGIN
-- 05/01/2004   G_nb_ayd := 1;
      OPEN c_ayd;

      LOOP
         FETCH c_ayd
          INTO rec_c_ayd;

         EXIT WHEN c_ayd%NOTFOUND;
         --
         nb_ayd := nb_ayd + 1;
         g_ayd (nb_ayd) :=
            UPPER (f_desaccentue (SUBSTR (   rec_c_ayd.nom
                                          || ' '
                                          || rec_c_ayd.prenom,
                                          1,
                                          40
                                         )
                                 )
                  );
         g_ayd (nb_ayd) := f_fill (g_ayd (nb_ayd), 40);
         g_ayd (nb_ayd) :=
                          g_ayd (nb_ayd) || rec_c_ayd.datnais
                          || rec_c_ayd.rang;
-- 16/01/2004
         g_numayd := rec_c_ayd.numindiv;                         -- 16/01/2004
         p_sel_garantie;                                         -- 16/01/2004
         g_garayd (nb_ayd) := g_garantie;                        -- 16/01/2004
-- 16/01/2004
      END LOOP;

-- 05/01/2004   G_nb_ayd := G_nb_ayd + Nb_ayd;
      g_nb_ayd := nb_ayd;                                        -- 05/01/2004

--
      FOR i IN nb_ayd + 1 .. g_nb_ayd + 5
      LOOP
         g_ayd (i) := f_fill ('', 49);
      END LOOP;
   END p_sel_ayd;

-------------------------------------------------------------------------------
-- Translation de refcontrat
-------------------------------------------------------------------------------
   PROCEDURE p_sel_refcontrat
   IS
      i                 BINARY_INTEGER;
      CHAR              VARCHAR2 (1);
      l_refcontrat      VARCHAR2 (30)  := g_refcontrat;
      l_refcontrat_an   VARCHAR2 (30)  := l_refcontrat;
   /* on recupere la donnee alphanum dans une var locale*/
   BEGIN
-- G_client := f_client;
      IF (g_client = 2)
      THEN
         /* CGRCR veut remplacer le refcie par le numero d'adhesion */
         g_refcontrat := f_fill (TO_CHAR (g_idadhesion), 16);
         g_refcontrat_n := f_fill (TO_CHAR (g_idadhesion), 16, '0', 2);
      ELSE
         /* on transfo la donnée alphanum en donnée numérique*/
         FOR i IN 1 .. LENGTH (g_refcontrat)
         LOOP
            CHAR := SUBSTR (g_refcontrat, i, 1);

            IF (ASCII (CHAR) NOT BETWEEN 65 AND 90)
            THEN
               IF (ASCII (CHAR) NOT BETWEEN 48 AND 57)
               THEN
                  l_refcontrat := REPLACE (l_refcontrat, CHAR, '');
               END IF;
            ELSE
               l_refcontrat := REPLACE (l_refcontrat, CHAR, '0');
            END IF;
         END LOOP;

/* transfert des 2 donnees (num et alphanum) dans les 2 variables globales
                                                                                 correspondantes*/
         g_refcontrat_n := f_fill (SUBSTR (l_refcontrat, 1, 16), 16, '0', 2);
         g_refcontrat := f_fill (SUBSTR (l_refcontrat_an, 1, 16), 16);
      END IF;
   END p_sel_refcontrat;

-------------------------------------------------------------------------------
-- Sous regime de l'assure
-------------------------------------------------------------------------------
   PROCEDURE p_sel_sous_regime
   IS
      l_regime   VARCHAR2 (45);
   BEGIN
      BEGIN
         SELECT libelle
           INTO l_regime
           FROM libelle
          WHERE mnemo = 'SS_REG' AND code = (SELECT orgbase
                                               FROM indvs
                                              WHERE numindiv = g_numindiv);

         g_sous_regime := SUBSTR (l_regime, 1, 15);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_sous_regime := NULL;
      END;
   END p_sel_sous_regime;

-------------------------------------------------------------------------------
-- libelles des renvois
-------------------------------------------------------------------------------
   PROCEDURE p_sel_lib_renvoi
   IS
      CURSOR c_renvoi
      IS
         SELECT DISTINCT renvoi renvoi
                    FROM param_demande_tp
                   WHERE idparam_tp = g_idparam_tp
                     AND param_demande_tp.renvoi IS NOT NULL;

      l_renvoi    param_demande_tp.renvoi%TYPE;
      i           BINARY_INTEGER                 := 0;
      nb_renvoi   BINARY_INTEGER                 := 1;
   BEGIN
      g_lib_renvoi (1) :=
         SUBSTR ('(*)' || ' ' || pk_libelle.f_lib ('RENVOI_TP', '(*)'), 1,
                 85);
      g_lib_renvoi (1) := f_fill (g_lib_renvoi (1), 85);

--
      OPEN c_renvoi;

      LOOP
         FETCH c_renvoi
          INTO l_renvoi;

         EXIT WHEN c_renvoi%NOTFOUND;
         EXIT WHEN nb_renvoi >= 4;
         nb_renvoi := nb_renvoi + 1;
         g_lib_renvoi (nb_renvoi) :=
            SUBSTR (   RTRIM (l_renvoi)
                    || ' '
                    || pk_libelle.f_lib ('RENVOI_TP', RTRIM (l_renvoi)),
                    1,
                    85
                   );
         g_lib_renvoi (nb_renvoi) := f_fill (g_lib_renvoi (nb_renvoi), 1, 85);
      END LOOP;

      CLOSE c_renvoi;

--
      FOR i IN nb_renvoi + 1 .. 4
      LOOP
         g_lib_renvoi (i) := f_fill ('', 85);
      END LOOP;
   END p_sel_lib_renvoi;

-------------------------------------------------------------------------------
-- Mise a jour transmis de porte_adhesion
-------------------------------------------------------------------------------
   PROCEDURE p_maj_porte_adhesion
   IS
   BEGIN
      UPDATE porte_adhesion
         SET transmis = 1
       WHERE idporte = g_idporte;
   END p_maj_porte_adhesion;

-------------------------------------------------------------------------------
-- Recherche du numero AMC pour la porte 3, suite a evolution 169 CGRCR
-- ABO 19/10/2010 Une caisse peut avoir son numéro  = 000 donc par défaut on met -1 à la place de 0
-------------------------------------------------------------------------------
   PROCEDURE p_sel_amc (
      a_regime     IN   NUMBER,
      a_numsoc     IN   NUMBER,
      a_numorg     IN   NUMBER,
      a_numporte   IN   NUMBER
   )
   IS
      CURSOR c_parporte
      IS
         SELECT parporte.numemetteur
           FROM parporte
          WHERE parporte.numreg = a_regime
            AND parporte.numsoc = a_numsoc
            AND parporte.numorg = a_numorg
            AND parporte.numporte = a_numporte
            AND parporte.numcaisse = '-1'
            AND parporte.numdpt = '-1';

      l_numemetteur   parporte.numemetteur%TYPE;
   BEGIN
      OPEN c_parporte;

      FETCH c_parporte
       INTO l_numemetteur;

      g_amc := SUBSTR (l_numemetteur, 1, 15);

      IF c_parporte%NOTFOUND
      THEN
         g_amc :=
            SUBSTR ((   'R'
                     || TO_CHAR (a_regime)
                     || 'S'
                     || TO_CHAR (a_numsoc)
                     || 'O'
                     || TO_CHAR (a_numorg)
                     || 'P'
                     || TO_CHAR (a_numporte)
                    ),
                    1,
                    15
                   );
      END IF;

      CLOSE c_parporte;
   END p_sel_amc;

-------------------------------------------------------------------------------
-- 05/01/2004 Intitule de GAR si global contrat, Sinon Libelle de la 1ier GAR
-- 05/01/2004 Nouvelle procedure
-------------------------------------------------------------------------------
--
   PROCEDURE p_sel_garantie
   IS
----------------------------------------------------------------------
-- Recherche, Ó partir du fichier ADHESION de la liste des GARANTIES
--              Couverte par le contrat (Base de recherche G_IDADHESION)
----------------------------------------------------------------------
      CURSOR c_desc
      IS
         SELECT ALL param_tiers_payant.garantie, gar_cntrt.libelle,
                    gar_cntrt.nomgar
               FROM gar_cntrt, control_adhesion, param_tiers_payant
              WHERE (    (gar_cntrt.numfor = control_adhesion.numfor)
                     AND (gar_cntrt.numgar = control_adhesion.numgar)
                     AND (param_tiers_payant.idparam_tp = g_idparam_tp)
                     AND (control_adhesion.numindiv = g_numayd)
                     AND (control_adhesion.idadhesion = g_idadhesion)
                     AND (control_adhesion.idparam_tp = g_idparam_tp)
                     AND (g_datdeb BETWEEN control_adhesion.datapli
                                       AND NVL (control_adhesion.datper,
                                                g_datdeb
                                               )
                         )
                     AND (control_adhesion.etat = 1)
                     AND (control_adhesion.numgar = g_numgar)
                     AND (control_adhesion.numgar = param_tiers_payant.numgar
                         )
                    )
           ORDER BY control_adhesion.numfor;

      rec_desc   c_desc%ROWTYPE;
   BEGIN
      g_garantie := NULL;

      OPEN c_desc;

      FETCH c_desc
       INTO rec_desc;

      IF g_numfor = 0
      THEN
         g_garantie := rec_desc.garantie;                 -- Garantie contrat
      ELSE
         --G_garantie := SUBSTR(REC_DESC.NOMGAR, 1, 7); --libelle
         g_garantie := SUBSTR (rec_desc.libelle, 1, 7);             --libelle
      END IF;

      CLOSE c_desc;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_garantie := 'GAR.Err';
   END p_sel_garantie;

----------------------------------------------------------------------
-- Recherche, Si parametrage GLOBAL CONTRAT (NUMFOR = 0)
--                ou prametrage par GARANTIE et COUVERTURE
----------------------------------------------------------------------
   PROCEDURE p_sel_numfor
   IS
      CURSOR c_gpt
      IS
         SELECT ALL gar_param_tp.numfor
               FROM gar_param_tp
              WHERE (gar_param_tp.idparam_tp = g_idparam_tp);

      rec_gpt   c_gpt%ROWTYPE;
   BEGIN
      OPEN c_gpt;

      FETCH c_gpt
       INTO rec_gpt;

      g_numfor := rec_gpt.numfor;

      CLOSE c_gpt;
   END p_sel_numfor;
--
-------------------------------------------------------------------------------
-- 05/01/2004   End
-------------------------------------------------------------------------------
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
