CREATE OR REPLACE PACKAGE ARTHUS."PK_RUWA_TPE"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_ruwa_tpe.sql      1.4  06/10/2005

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
      i_fr_cpfixe     IN       VARCHAR2,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_RUWA_TPE"
AS
/*===========================================================================*/
/* Package      : PK_RUWA_TPE                                                */
/* Domaine      :                                                            */
/* Version      : V9                                                         */
/* Auteur       : ???                                                        */
/* Création     : ??/??/????                                                 */
/* Description  : Construction du fichier plat des cartes de Tp              */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       : XHU                                                        */
/* Date         : 29/11/2010                                                 */
/* Commentaire  : Passage à la V8 du fichier plat (GEREP)                    */
/* Auteur       : ABO                                                        */
/* Date         : 14/12/2010                                                 */
/* Commentaire  : Ajout * pour domaine paramétré et parcourt SP santé (GEREP)*/
/*===========================================================================*/
/* Evolution   : ABO / 25/11/2016 / v9 mise en place du datamatrix           */
/* Evolution   : ABO / 16/11/2018 / v9 mise en place des services innovants  */
/*===========================================================================*/

/* ==========================================================================*/
-- PROCEDURES ET FONCTIONS PUBLIQUES
-- p_traite_remise
-- p_maj_remise_externe
/* ========================== Fin des Procedures publiques ==================*/

-- Chaine de reconnaissance SCCS
-- @(#)pk_ruwa_tpe.sql      1.4  03/10/28

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

   TYPE t_ayd IS TABLE OF VARCHAR2 (72)                         -- 29/11/2010
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
   g_fr_cpfixe       VARCHAR2 (1)                            := '0';
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
   g_promoteur       param_tiers_payant.promoteur%TYPE;       -- 29/11/2010
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
  -- g_a_traiter       NUMBER                                  := 0;
-- Enregistrements en sortie
   g_entete          VARCHAR2 (2000);
   g_expedition      VARCHAR2 (1000);
   g_attestation     VARCHAR2 (10000);
   g_attest_1        VARCHAR2 (10000);
   g_attest_2        VARCHAR2 (10000);
   g_attest_3        VARCHAR2 (10000);
--
   g_nomdest         VARCHAR2 (32);
   g_lnumdest        NUMBER                                  := 0;
   g_datdeb          DATE;
   flag_fin          BOOLEAN                                 := FALSE;
-- Donn es Emetteur (Identifiant - AMC);
   g_numreg          parporte.numreg%TYPE;
   g_datamatrix      Varchar2(200);

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
               TO_CHAR (porte_adhesion.fin, 'ddmmyyyy') fin,
               param_tiers_payant.promoteur                      -- 29/11/2010
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
   PROCEDURE p_trt_entete_attes;

--
-- Construction de l'attestation ( corps )
--
   PROCEDURE p_trt_corps_attes (i_traite IN NUMBER, i_a_traiter IN NUMBER);

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

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_TRAITE_REMISE                                           */
/* Type         :  Public                                                    */
/* Description  :  Traitement d'une remise et renvoi des lignes fichier      */
/* Entree       :  i_numremise                                               */
/*                 i_fr_cpfixe                                               */
/* Sortie       :  o_attest_prec                                             */
/*                 o_entete                                                  */
/*                 o_expedition                                              */
/*                 o_attest_1                                                */
/*                 o_attest_2                                                */
/*                 o_attest_3                                                */
/*---------------------------------------------------------------------------*/
   PROCEDURE p_traite_remise (
      i_numremise     IN       remise_externe.numremise%TYPE,
      i_fr_cpfixe     IN       VARCHAR2,
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
	  loc_OPTI       NUMBER;
   BEGIN
--
      g_client := f_client;
--
      flag_entete := FALSE;
      g_numremise := i_numremise;

      SELECT NVL (i_fr_cpfixe, '0')
        INTO g_fr_cpfixe
        FROM DUAL;

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
      g_promoteur := rec_c_remise.promoteur;



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

	  --14/12/2016 ABO le code promoteur peut varier en fonction de la garantie souscrite, variable fixée a la garantie contrat LOGO_OPTI
	  --la demande correspond au périmètre particulier Itelis
	  --vérification faite hélas systématiquement
	  loc_OPTI:=NULL;
	  BEGIN
     --le code promoteur est surchargé en fonction des garanties adhérent, il est stocké dans la colonne sens du libelle promoteur
		  SELECT code INTO loc_OPTI
      FROM LIBELLE WHERE mnemo = 'PROMOTEUR'
      AND sens =
      (SELECT MAX(F_VAL_VAR_ALL(numfor,F_FIND_VAR('LOGO_OPTI'),g_datdeb))
		  FROM adhesion
		  WHERE  numindiv = g_numindiv
       --AND idadhesion = g_idadhesion--on doit pouvoir le faire pour tous les contrats base et option
		  AND g_datdeb BETWEEN datapli AND NVL(datper,g_datdeb)
      AND EXISTS (select numporte from porte_contrat,adhe_cntrt
      where numporte =22 and porte_contrat.numgar = adhe_cntrt.numgar
      AND adhe_cntrt.idadhesion=g_idadhesion)); --enfant avec double adhesion M6330

    EXCEPTION
	    WHEN OTHERS THEN loc_OPTI:=NULL;
	  END;

	  g_promoteur := NVL(loc_OPTI, g_promoteur);



	  IF (g_carte_prec != g_carte)
      THEN
         flag_fin := TRUE;
      END IF;

--
      IF (flag_fin)
      THEN
         IF (g_fr_cpfixe != '1')
         THEN
            o_attest_prec := '99';
            flag_fin := FALSE;
         END IF;
      ELSE
         o_attest_prec := NULL;
      END IF;

--

      -- Enregistrement entete
--
      IF (flag_entete)
      THEN
         IF (g_fr_cpfixe != '1')
         THEN
            p_trt_entete;
            o_entete := g_entete;
            g_entete := NULL;
         END IF;

         flag_entete := FALSE;
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

            IF (g_fr_cpfixe != '1')
            THEN
               p_trt_adresse;
               o_expedition := g_expedition;
               g_expedition := NULL;
            END IF;
         --
         END IF;
      ELSE
         g_lnumdest := g_numindiv;
         g_nomdest :=
            f_fill (UPPER (f_desaccentue (pk_personne.f_nom (g_numindiv, 32))),
                    32
                   );
         p_sel_adresse (i_numindiv => g_numindiv);

         IF (g_fr_cpfixe != '1')
         THEN
            p_trt_adresse;
            o_expedition := g_expedition;
            g_expedition := NULL;
         END IF;
      --
      END IF;

--
      p_sel_sous_regime;
      p_sel_assure;

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
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  f_fill                                                    */
/* Type         :  Privé                                                     */
/* Description  :  Complète une chaîne avec un caractere                     */
/* Entree       :  i_chaine, chaine à compéter                               */
/*                 i_longueur, longueur finale de la chaine                  */
/*                 i_character, caractère de complétude (espace par défaut)  */
/*                 i_alignement, sens de complétion                          */
/* Retour       :  Chaine complétée                                          */
/*---------------------------------------------------------------------------*/
   FUNCTION f_fill (
      i_chaine       IN   VARCHAR2,
      i_longueur     IN   NUMBER,
      i_character    IN   VARCHAR2 DEFAULT ' ',
      i_alignement   IN   NUMBER DEFAULT 1
   )
      RETURN VARCHAR2
   IS
      l_chaine   VARCHAR2 (500) := i_chaine;   -- 29/11/2010
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
      g_entete := g_entete || '09' || TO_CHAR (SYSDATE, 'ddmmyy');
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
    --  DBMS_OUTPUT.put_line (g_expedition);
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
      --dbms_output.put_line('début p_trt_attestation');
      p_trt_entete_attes;
      p_trt_corps_attes (i_traite => 0, i_a_traiter=> 5); --on ne gère que 5 bénéficiaires par carte, on multiplie les cartes si sup

      --p_trt_corps_attes (i_traite => 5 ,i_a_traiter=> 7);

      IF (g_attest_1 IS NULL) THEN
        g_attest_1 := g_attestation;
      END IF;
     -- dbms_output.put_line(' g_nb_ayd '||g_nb_ayd);

      IF (5 <  g_nb_ayd)  THEN
        p_trt_entete_attes ;
        p_trt_corps_attes (i_traite => 5,i_a_traiter=>10);
        IF (g_attest_2 IS NULL)  THEN
           g_attest_2 := g_attestation;
        END IF;
      END IF;

      IF (10 <  g_nb_ayd)  THEN
        p_trt_entete_attes ;
        p_trt_corps_attes (i_traite => 10,i_a_traiter=>15);
        IF (g_attest_3 IS NULL AND g_attest_2 IS NOT NULL)THEN
           g_attest_3 := g_attestation;
        END IF;
      END IF;

--
      --END IF;

--                                                              -- 05/01/2004
-- 05/01/2004 Fin des lignes ajout es
--                                                              -- 05/01/2004
      --dbms_output.put_line('fin p_trt_attestation');
   END p_trt_attestation;

-------------------------------------------------------------------------------
-- Construction de l'attestation ( entete )
-------------------------------------------------------------------------------
   PROCEDURE p_trt_entete_attes
   IS
      i          BINARY_INTEGER := 0;
   --   l_traite   NUMBER         := i_traite;
   BEGIN
      --dbms_output.put_line('début p_trt_entete_attes');
      g_attestation := 'FR';
-- Code lettre
      g_attestation := g_attestation || f_fill (g_code_lettre, 2);
-- Codes divers ( cas a voir )
      g_attestation :=
                   g_attestation || f_fill ('', 2, '0')
                   || f_fill ('', 2, '0');
-- Code pochette
      g_attestation := g_attestation || TO_CHAR (g_type_poch);
-- Utilisation future : Modif pour préciser le LOGO
-- 06/10/2005 G_attestation := G_attestation || F_fill('', 10);

      g_attestation := g_attestation || f_fill ('', 4);       -- 29/11/2010 6->4

-- Code SPH
      g_attestation := g_attestation || '0';                  -- 29/11/2010
-- Code REF
      g_attestation := g_attestation || '1';                  -- 29/11/2010
-- Code LOGO
      g_attestation := g_attestation || '2';                  -- NOUVEAU LOGO
-- Type Attestation
      g_attestation := g_attestation || '0';                  -- 29/11/2010
      g_attestation := g_attestation || f_fill ('', 2);       -- 29/11/2010 3->2
-- Numero AMC ( Sintia -> futur )
      g_attestation := g_attestation || f_fill (g_amc, 15);
-- Numero d'adherent -> futur
      g_attestation := g_attestation || f_fill (f_fill(g_numindiv,8,'0',2), 15);
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
      --DBMS_OUTPUT.put_line (g_attestation);
--
      --dbms_output.put_line('fin p_trt_entete_attes');
   END p_trt_entete_attes;

-------------------------------------------------------------------------------
-- Construction de l'attestation ( corps )
-------------------------------------------------------------------------------
   PROCEDURE p_trt_corps_attes (i_traite IN NUMBER, i_a_traiter IN NUMBER )
   IS
      i          BINARY_INTEGER := 0;
      l_traite   NUMBER         := i_traite;
      v_circuit VARCHAR2(5);
      loc_circuit1 VARCHAR2(100);
      loc_circuit2  VARCHAR2(100);
      loc_circuit3  VARCHAR2(100);
      loc_circuit4  VARCHAR2(100);
      loc_circuit5  VARCHAR2(100);
      loc_sous_circuit NUMBER :=1;
      l_is_demat     NUMBER :=0;
      loc_bloc_320  VARCHAR2(320);

      CURSOR C_services (i_numgar NUMBER) IS
      --SELECT l.libelle||substr(regexp_replace(serv.telephone,'([[:digit:]]{2})','\1 '),2) lib ,serv.telephone, d.nom_variable
      SELECT l.libelle||NVL(TRIM(regexp_replace(serv.telephone,'([[:digit:]]{2})','\1 ')),serv.site_web)||decode(serv.email,'','','#'||serv.email) lib ,-- M0007236 prioritairement le téléphone sinon le site web + infos variantes concaténées au libellé : Assistance santé au # 05 49 76 98 35 Code KLP SKA
      serv.telephone, d.nom_variable
      FROM table (PK_WS_WEB_BACK.F_GET_SERVICES(i_numgar)) serv, def_variable d, LIBELLE_BIS l
      WHERE serv.idservice = d.idvariable
      AND d.etendue =7
      AND l.mnemo = 'SERVTPE'
      AND l.code = d.nom_variable
      order by d.idvariable ; -- MUR 05/12/2018
   BEGIN

      --gestion du datamatrix qui est généré à partir des couvertures du 1er ayant droits et du numéro de l'ouvreur de droit g_numindiv
      --AMC#1#00401554##225043#SPPGSFLRIKY231TCOAD#SCOAD#ISE#OCH/
      BEGIN
        SELECT DISTINCT 1 INTO l_is_demat
        FROM courrier_info c, adhe_cntrt a
        WHERE c.numindiv = a.numadhe
        AND c.type_crrr=50
        AND c.moyen_info = 2
        AND a.idadhesion = g_idadhesion;
      EXCEPTION
        WHEN OTHERS THEN l_is_demat:=0;
      END;
      IF  i_a_traiter in (0,5,10) THEN


         FOR i IN 1 .. 12 LOOP
          loc_sous_circuit:=1;
           IF TRIM(g_domaine (i)) IS NOT NULL  THEN
                <<sous_circuit>>
                IF INSTR(TRIM(g_circuit (i)),'/') <> 0 THEN
                  v_circuit :=substr(TRIM(g_circuit (i)),loc_sous_circuit,2);
                ELSE
                  v_circuit := TRIM(g_circuit (i));
                END IF;
                IF loc_circuit1 IS NULL THEN
                   loc_circuit1 :='#'|| v_circuit;
                ELSIF loc_circuit2 IS NULL
                AND substr(loc_circuit1,2,2) <> v_circuit THEN
                  loc_circuit2 :='#'||v_circuit;
                ELSIF loc_circuit3 IS NULL
                AND substr(loc_circuit1,2,2) <> v_circuit
                AND substr(loc_circuit2,2,2) <> v_circuit THEN
                  loc_circuit3 :='#'||v_circuit;
                ELSIF loc_circuit4 IS NULL
                AND substr(loc_circuit1,2,2) <> v_circuit
                AND substr(loc_circuit2,2,2) <> v_circuit
                AND substr(loc_circuit3,2,2) <> v_circuit THEN
                  loc_circuit4 :='#'||v_circuit;
                ELSIF loc_circuit5 IS NULL
                AND substr(loc_circuit1,2,2) <> v_circuit
                AND substr(loc_circuit2,2,2) <> v_circuit
                AND substr(loc_circuit3,2,2) <> v_circuit
                AND substr(loc_circuit4,2,2) <> v_circuit THEN
                  loc_circuit5 :='#'||v_circuit;
                END IF;
              --DBMS_OUTPUT.put_line ('loc_circuit1 '  || substr(loc_circuit1,2,2)  );

               IF  substr(loc_circuit1,2,2) = v_circuit THEN
                 loc_circuit1:=loc_circuit1 ||f_lib('DOM_TPDX',replace(TRIM(g_domaine (i)),'*',''));
               ELSIF  substr(loc_circuit2,2,2) = v_circuit THEN
                 loc_circuit2:=loc_circuit2 ||f_lib('DOM_TPDX',replace(TRIM(g_domaine (i)),'*',''));
               ELSIF  substr(loc_circuit3,2,2) = v_circuit THEN
                 loc_circuit3:=loc_circuit3 ||f_lib('DOM_TPDX',replace(TRIM(g_domaine (i)),'*',''));
               ELSIF  substr(loc_circuit4,2,2) = v_circuit THEN
                 loc_circuit4:=loc_circuit4 ||f_lib('DOM_TPDX',replace(TRIM(g_domaine (i)),'*',''));
               ELSIF  substr(loc_circuit5,2,2) = v_circuit THEN
                 loc_circuit5:=loc_circuit5 ||f_lib('DOM_TPDX',replace(TRIM(g_domaine (i)),'*',''));
               END IF;

               IF INSTR(TRIM(g_circuit (i)),'/') <> 0 AND loc_sous_circuit =1 THEN
                 loc_sous_circuit:=4;
                 GOTO sous_circuit;
               END IF;
            -- g_datamatrix := g_datamatrix || f_lib('DOM_TPDX',TRIM(g_domaine (i)));
           END IF;
         END LOOP;
         g_datamatrix:='AMC#1#'||g_amc||'##'||f_fill(g_numindiv,8,'0',2)|| loc_circuit1|| loc_circuit2|| loc_circuit3|| loc_circuit4 ||loc_circuit5||'/';
         --DBMS_OUTPUT.put_line ('g_datamatrix '  || g_datamatrix  );
      END IF;



-- Abreviation des domaines
      FOR i IN 1 .. 12                                          -- 29/11/2010
      LOOP
         g_attestation := g_attestation || g_domaine (i);
      END LOOP;

-- Abreviation des circuits
      FOR i IN 1 .. 12                                          -- 29/11/2010
      LOOP
         g_attestation := g_attestation || g_circuit (i);
                                   --  Modif LOGO dans table param_demande_tp
      END LOOP;

     -- g_a_traiter := l_traite + 5;                               -- 05/01/2004

      FOR i IN (l_traite + 1) .. i_a_traiter
      LOOP                                                       -- 05/01/2004
         p_sel_garantie;                                        -- 16/01/2004
         g_attestation := g_attestation || g_ayd (i);

         --
         IF (g_ayd (i) != f_fill ('', 71))                      -- 29/11/2010
         THEN


            -- Les 12 taux
            FOR i IN 1 .. 12                      -- 29/11/2010 12 taux au lieu de 9
            LOOP
               g_attestation := g_attestation || NVL (g_regle (i), f_fill ('', 10));
            END LOOP;

            -- Les 12 renvois
            FOR i IN 1 .. 12                      -- 29/11/2010 12 renvois au lieu de 9
            LOOP
               g_attestation := g_attestation || NVL (g_renvoi (i), f_fill ('', 5));
            END LOOP;
         ELSE
            --g_attestation := g_attestation || f_fill ('', 7);   -- 29/11/2010

            -- Les 9 taux
            FOR i IN 1 .. 12                      -- 29/11/2010 12 taux au lieu de 9
            LOOP
               g_attestation := g_attestation || f_fill ('', 10);
            END LOOP;

            -- Les 9 renvois
            FOR i IN 1 .. 12                      -- 29/11/2010 12 renvois au lieu de 9
            LOOP
               g_attestation := g_attestation || f_fill ('', 5);
            END LOOP;
         END IF;

         --
         l_traite := l_traite + 1;
      --
      END LOOP;



-- Ancienne reference Sante Pharma
-- 06/10/2005   G_attestation := G_attestation || F_fill( G_calcul || G_famille || G_organisme || G_centre, 11 );
      g_attestation := g_attestation || f_fill ('', 11);
-- Numero de contrat (donnee numerique recuperee dans P_SEL_refcontrat)
-- 06/10/2005   G_attestation := G_attestation || G_refcontrat_N;
      g_attestation := g_attestation || f_fill ('', 16);
-- libelles des renvois
      g_attestation := g_attestation || g_lib_renvoi (1);

      FOR i IN 2 .. 5                                            -- 29/11/2010
      LOOP
         g_attestation := g_attestation || f_fill (g_lib_renvoi (i), 85);
      END LOOP;

--
  --    DBMS_OUTPUT.put_line (SUBSTR (g_attestation, 1259, 255));

--
-- Adresse a mettre sur la lettre
      FOR i IN 1 .. 6
      LOOP
         g_attestation := g_attestation || f_fill (g_adr_assu (i), 32); -- 29/11/2010 ajout f_fill
      END LOOP;

--
-- CTT : 23/11/2006 :
-- code postal insere a partir de la position 1818....
--
      IF (g_fr_cpfixe = '1')
      THEN
         g_attestation := g_attestation || f_fill (f_codpos (g_numindiv), 160);  -- 29/11/2010 ajout f_fill
      ELSE
         g_attestation := g_attestation || f_fill ('', 160); -- 29/11/2010 ajout
      END IF;

-- Partie vide                                                  -- 29/11/2010 début ajout
      IF l_is_demat = 1 THEN
         loc_bloc_320 := f_fill ('DEMAT', 32);
      ELSE
         loc_bloc_320 := f_fill ('', 32);
      END IF;

      FOR R_services IN C_services(g_numgar) LOOP
        loc_bloc_320 := loc_bloc_320 ||  f_fill (replace(regexp_substr(R_services.lib,'[^#]+',1,1),'#'),32);--1er morceau
        loc_bloc_320 := loc_bloc_320 ||  f_fill (replace(regexp_substr(R_services.lib,'[^#]+',1,2),'#'),32);--2ème morceau
      END LOOP;

      g_attestation := g_attestation|| f_fill (loc_bloc_320, 320);

-- Code Marque
      g_attestation := g_attestation || f_fill ('', 10);
-- Code Promoteur
      g_attestation := g_attestation || f_fill (g_promoteur, 10);
-- Code Marqueur
      g_attestation := g_attestation || f_fill ('', 1);         -- 29/11/2010 fin ajout

     g_attestation := g_attestation ||  f_fill ('', 251); --6ème bénéficiaire
     g_attestation := g_attestation ||  f_fill ('', 251);--7ème bénéfciaire
  -- Code Datamatrix
     g_attestation := g_attestation || f_fill (g_datamatrix, 200);
  -- Code DROIT ouvert IDB
     g_attestation := g_attestation || f_fill ('N', 1);


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
            pk_personne.f_adresse (pk_personne.f_idadresse (i_numindiv,
                                                            0,
                                                            SYSDATE,
                                                            'O',
                                                            0
                                                           ),
                                   i,
                                   i_numindiv,
                                   0,
                                   11
                                  );
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
                organisme, centre, type_poch, garantie, debiteur_aphp,
                numamc  -- NS 2006-02-08 (AMC de la table PARAM_TIERS_PAYANT)
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
      g_amc := SUBSTR (rec_c_tp.numamc, 1, 15);
                        -- NS 2006-02-08 (AMC de la table PARAM_TIERS_PAYANT)
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
      l_sens     libelle_bis.sens%TYPE;
      l_etoile   VARCHAR2(1) :='';
   BEGIN
      OPEN c_domaine;

      LOOP
         FETCH c_domaine
          INTO rec_c_domaine;

         EXIT WHEN c_domaine%NOTFOUND;
         --
         nb_domaine := nb_domaine + 1;
         --ABO 13/12/2010 ajout * si type circuit est SP santé et domaine concerné
         l_etoile:='';
         IF rec_c_domaine.circuit IN ('OC','SP','SP/SC','SP/SV') THEN
          BEGIN
            SELECT sens INTO l_sens
            FROM  Libelle_bis
            WHERE mnemo='DOM_TP'
            AND code = rec_c_domaine.domaine;
          IF l_sens=2 THEN
            l_etoile:='*';
          END IF;

          EXCEPTION
            WHEN OTHERS THEN NULL;
          END;
         END IF;

         g_domaine (nb_domaine) := f_fill (rec_c_domaine.domaine||l_etoile, 5);
         g_circuit (nb_domaine) := f_fill (rec_c_domaine.circuit, 5);
         g_regle (nb_domaine) := f_fill (rec_c_domaine.regle, 10);
         g_renvoi (nb_domaine) := f_fill (rec_c_domaine.renvoi, 5);
      --
      END LOOP;

--
      FOR i IN nb_domaine + 1 .. 12                          -- 29/11/2010
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
                demande_tp_ad.rang,
                individu.matorg, individu.cless                 -- 29/11/2010
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
                          || rec_c_ayd.rang
                          || f_fill ('', 7)                      -- 29/11/2010
                          || rec_c_ayd.matorg                    -- 29/11/2010
                          || SUBSTR (TO_CHAR (rec_c_ayd.cless, '00'), 2, 2); -- 29/11/2010
         g_ayd (nb_ayd) := f_fill (g_ayd (nb_ayd), 71);          -- 29/11/2010
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
         g_ayd (i) := f_fill ('', 71);                           -- 29/11/2010
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
         SELECT   renvoi
             FROM param_demande_tp
            WHERE idparam_tp = g_idparam_tp
              AND param_demande_tp.renvoi IS NOT NULL
         GROUP BY param_demande_tp.renvoi
         ORDER BY param_demande_tp.renvoi;

--
      l_renvoi    param_demande_tp.renvoi%TYPE;
      i           BINARY_INTEGER                 := 0;
      nb_renvoi   BINARY_INTEGER                 := 1;
   BEGIN
      g_lib_renvoi (1) :=
         SUBSTR ('*' || ' ' || pk_libelle.f_lib ('RENVOI_TP', '*'), 1,
                 85);
      g_lib_renvoi (1) := f_fill (g_lib_renvoi (1), 85);

--
      OPEN c_renvoi;

      LOOP
         FETCH c_renvoi
          INTO l_renvoi;

         EXIT WHEN c_renvoi%NOTFOUND;
         EXIT WHEN nb_renvoi >= 5;                           -- 29/11/2010
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
      FOR i IN nb_renvoi + 1 .. 5                            -- 29/11/2010
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

-----------------------------------------------------------------------------------------
-- Recherche du numero AMC pour la porte 3, suite a evolution 169 CGRCR
-- CTT 16/12/2005 : Le n° AMC qui doit apparaître sur l'attestation est le n°
--             identifiant unique (parporte.numident). Si ce n° n'est pas
--             renseigné on utilise le n° identifiant détaillé (paporte.numemetteur)
-----------------------------------------------------------------------------------------
   PROCEDURE p_sel_amc (
      a_regime     IN   NUMBER,
      a_numsoc     IN   NUMBER,
      a_numorg     IN   NUMBER,
      a_numporte   IN   NUMBER
   )
   IS
      CURSOR c_parporte
      IS
         SELECT parporte.numident, parporte.numemetteur
           FROM parporte
          WHERE parporte.numreg = a_regime
            AND parporte.numsoc = a_numsoc
            AND parporte.numorg = a_numorg
            AND parporte.numporte = a_numporte
            AND parporte.numcaisse = '0'
            AND parporte.numdpt = '00';

      l_numident      parporte.numident%TYPE;
      l_numemetteur   parporte.numemetteur%TYPE;
   BEGIN
      OPEN c_parporte;

      FETCH c_parporte
       INTO l_numident, l_numemetteur;

      IF (l_numident IS NOT NULL AND SUBSTR (l_numident, 1, 1) <> ' ')
      THEN
         g_amc := SUBSTR (l_numident, 1, 15);
      ELSIF (l_numemetteur IS NOT NULL AND SUBSTR (l_numemetteur, 1, 1) <> ' '
            )
      THEN
         g_amc := SUBSTR (l_numemetteur, 1, 15);
      ELSE
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
-- Recherche,   partir du fichier ADHESION de la liste des GARANTIES
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
