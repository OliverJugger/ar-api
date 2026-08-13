CREATE OR REPLACE PACKAGE ARTHUS."PK_TEXTE"
AS
   /*===========================================================================*/
   /* Package      : PK_TEXTE.sql                                               */
   /* Domaine      : Editique                                                   */
   /* Version      : V1.0                                                       */
   /* Auteur       : ARTHUS                                                     */
   /* Création     : DD/MM/AAAA                                                 */
   /* Description  : Package utilisé pour les éditions et courriers             */
   /*              : pour récupérer les données                                 */
   /*              :                                                            */
   /*===========================================================================*/
   /* Evolution    :                                                            */
   /* Auteur       :                                                            */
   /* Date         :                                                            */
   /* Commentaire  :                                                            */
   /*===========================================================================*/
   /* Correction   : jbn / 25/03/2011  / évolution sur les ribs                 */
   /*                PHA / 13/06/2012 / M3790: PK_TEXTE.f_eval_donnee modifié   */
   /*                PHA / 19/10/2012 / MANTIS 3883 correctif sur contrôle date */
   /*                ABO / 04/11/2013 / correction clef 45 BENE sinistre prev   */
   /*                ABO / 04/11/2013 / correction val_variable sinistre prev   */
   /*                PHA / 03/01/2014 / MANTIS 4290                             */
   /*                TLE / 19/02/2014 / FUSION VERSION SEPA ET PREVOYANCE GEREP */
   /*                TLE / 03/03/2014 / MANTIS-4433 : retour arrière Ligne 747  */
   /*                                   on conserve la test IF (t_cle (13) != 0)*/
   /*                PHA / 11/03/2014 / Gestion debut et fin au niveau de       */
   /*                                   (t_cle (13)                             */
   /*                TLE / 12/03/2014 / MANTIS 4445                             */
   /*                MUR / 27/03/2014 / SEPA EPAI prelevements                  */
   /*                TLE / 15/10/2014 / MERGE SEPA V7 ET EPAI                   */
   /*                PHA / 10/11/2016 / MANTIS  5191 ajout infos prêts          */
   /*                PHA / 06/04/2018 / M0005586: ajout CTRLDBL                 */
   /*===========================================================================*/

   -- Chaine de reconnaissance SCCS
   -- %W%  %E%
   -- -- CONSTANTES PUBLIQUE -----------------------------------------------------
   -- Aucune
   -- -------------------------------------------- Fin des constantes publiques --
   -- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
   -- Aucune
   -- -------------------------------------------- Fin des exceptions publiques --
   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------
FUNCTION f_eval_variable(
      a_nom_variable IN VARCHAR2,
      a_contexte     IN NUMBER,
      a_cle          IN NUMBER,
      a_format       IN NUMBER DEFAULT 2,
      a_debut        IN DATE DEFAULT NULL,
      a_fin          IN DATE DEFAULT NULL )
   RETURN VARCHAR2;
   --Pragma Restrict_References(f_eval_variable,WNDS);
FUNCTION f_eval_donnee(
      a_type_donnee IN NUMBER,
      a_id_donnee   IN NUMBER,
      a_contexte    IN NUMBER,
      a_cle         IN NUMBER )
   RETURN VARCHAR2;
   --Pragma Restrict_References(f_eval_donnee,RNPS);
   --WNDS,RNDS,WNPS,RNPS);
FUNCTION f_decode_texte(
      a_texte         IN VARCHAR2,
      a_contexte      IN NUMBER,
      a_contexte_base IN NUMBER,
      a_cle           IN NUMBER DEFAULT 0,
      a_niveau        IN NUMBER,
      a_nombre        IN NUMBER DEFAULT 1,
      a_test          IN NUMBER DEFAULT 1,
      a_cle1          IN NUMBER DEFAULT 0,
      a_debut         IN DATE DEFAULT SYSDATE,
      a_fin           IN DATE DEFAULT SYSDATE,
      a_cle2          IN NUMBER DEFAULT 0,
      a_idtexte       IN NUMBER DEFAULT 0,
      a_numenvoi      IN NUMBER DEFAULT 0,
      a_numutil       IN NUMBER DEFAULT f_numutil,
      a_codfrais      IN VARCHAR2 DEFAULT NULL )
   RETURN VARCHAR2;
   --Pragma Restrict_References(f_decode_texte,WNDS);
PROCEDURE charge_prch(
      a_numpc IN NUMBER,
      t_donnee OUT PK_texte.donnee);
   --Pragma Restrict_References(charge_prch, WNDS);
   -- -------------------------------------------- Fin des procedures publiques --
   -- -- TYPES PUBLIQUES ---------------------------------------------------------
TYPE donnee
IS
   TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
   -- David 18/03/2005 type donnee is table of varchar2(100) index by binary_integer;
TYPE clefs
IS
   TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   -- ------------------------------------------------- Fin des types publiques --
   -- -- VARIABLES PUBLIQUES -----------------------------------------------------
   comm_debut DATE DEFAULT TRUNC (SYSDATE);
   /* Date de debut */
   comm_date_debut DATE DEFAULT TRUNC (SYSDATE);
   /* Date de debut */
   comm_fin DATE DEFAULT TRUNC (SYSDATE);
   /* Date de fin */
   comm_date_fin DATE DEFAULT TRUNC (SYSDATE);
   /* Date de fin */
   comm_contexte      NUMBER        := 0;
   comm_contexte_init NUMBER        := 0;
   comm_contexte_base NUMBER        := 0;
   comm_nombre        NUMBER        := 1;
   comm_niveau        NUMBER        := 0;
   comm_cle           NUMBER        := 0;
   comm_cle1          NUMBER        := 0;
   comm_cle2          NUMBER        := 0;
   comm_objet         NUMBER        := 0;
   comm_test          NUMBER        := 1;
   comm_numenvoi      NUMBER        := 0;
   comm_idtexte       NUMBER        := 0;
   comm_numutil       NUMBER        := f_numutil;
   comm_retour        VARCHAR2 (20) := 'traite';
   comm_codfrais      VARCHAR2 (5)  := '';
   g_type_adresse adhe_pret.type_adresse%TYPE DEFAULT 1;
   g_devise_ref monnaie.codmon%TYPE := PK_devise.devise_ref;
   g_euro monnaie.codmon%TYPE       := PK_devise.euro;
   g_idadhesion adhe_cntrt.idadhesion%TYPE;
   g_idrib NUMBER := 0;
   g_mregl NUMBER := 0; -- NSO 25-01-2008
   t_cle_primaire clefs;
   t_cle clefs;
   t_cle_base clefs;
   t_cle_passage clefs;
   t_contexte clefs;
   t_donnee donnee;
   t_tableau donnee;
   -- --------------------------------------------- Fin des variables publiques --
END PK_texte;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_TEXTE" 
AS
-- $Rev:: 795                                    $:  Revision du dernier commit
-- $Author:: s.calvez                            $:  Auteur du dernier commit
-- $Date: 2023-09-07 17:31:39 +0200 (jeu., 07 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PACKAGE_BODIES/PK_TEXTE.pkb $:  Chemin

   -- Chaine de reconnaissance SCCS
   -- %W%  %E%
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
   --@priv
   --
   -- Chargement donnees contrat
PROCEDURE P_Charge_Contrat(
      i_numgar IN NUMBER,
      o_donnee OUT PK_texte.donnee );
   --Chargement donnees societe
PROCEDURE Charge_Societe(
      a_numindiv IN NUMBER,
      o_donnee OUT PK_texte.donnee );
   -- Chargement donnees Adhesion Collective
PROCEDURE P_Charge_AdheColl(
      i_numgar IN NUMBER,
      o_donnee OUT PK_texte.donnee );
   -- ----------------------------- Fin des declarations des procedures privees --
   -- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
PROCEDURE Init_Cle
IS
   lble libelle%ROWTYPE;
BEGIN
   FOR lble IN
   (SELECT code
    , DECODE (tableau, 0, sens, TO_NUMBER (codapli) ) sens
   FROM libelle
   WHERE mnemo = 'CLE_BASE'
   AND code    > -1
   )
   LOOP
      t_cle (lble.code)      := 0;
      t_cle_base (lble.code) := lble.sens;
   END LOOP;
   g_type_adresse := 1;
   g_idadhesion   := NULL;
END Init_Cle;
--
-- -- Charge_Cle --------------------------------------------
--
PROCEDURE Charge_Cle(
      a_contexte IN NUMBER,
      a_cle      IN NUMBER)
IS
   CURSOR c_adhe_pret
   IS
      SELECT idpret
       , type_adresse
      FROM adhe_pret
      WHERE idadhesion = t_cle (13);
   CURSOR c_apporteur
   IS
      SELECT numindiv
      FROM apporteur
      WHERE etendue = 4
      AND cle       = t_cle (13)
      AND comm_debut BETWEEN debut AND NVL (fin, comm_debut)
      AND type_apport = 1;
   CURSOR c_apporteur_global
   IS
      SELECT numindiv
      FROM apporteur
      WHERE etendue = 2
      AND cle       = t_cle (2)
      AND comm_debut BETWEEN debut AND NVL (fin, comm_debut)
      AND type_apport = 1;
   l_debut1 DATE;
   l_fin1 DATE;
BEGIN
   PK_Texte.Init_Cle;
   comm_contexte      := a_contexte;
   comm_cle           := a_cle;
   t_cle (a_contexte) := a_cle;
   IF (a_contexte      = 18) THEN
      /* Numquit */
      BEGIN
         SELECT qttc_global.numgar
          , qttc_global.idadhesion
          , qttc_global.numindiv
          , qttc_global.debut
          , qttc_global.fin
          , qttc_global.numquerable
          ,
            -- f_bene_rib(qttc_global.numquerable,4,qttc_global.numgar,2),
            PK_treso.f_idrib (qttc_global.numquerable, 2, 4, qttc_global.numgar, qttc_global.debut, qttc_global.idadhesion )
          , qttc_global.numquerable
          , qttc_global.numindiv
          , contrat.delegataire
         INTO t_cle (2)
          , t_cle (13)
          , t_cle (4)
          , comm_debut
          , comm_fin
          , t_cle (21)
          , g_idrib
          , t_cle (46)
          , t_cle (12)
          , t_cle (38)
         FROM contrat
          , qttc_global
         WHERE qttc_global.numquit = t_cle (18)
         AND qttc_global.numgar    = contrat.numgar
         AND comm_test             = 1
         UNION
         SELECT numgar
          , idadhesion
          , numindiv
          , comm_date_debut
          , comm_date_fin
          , numquerable1
          , benerib
          , numquerable
          , numadhe
          , delegataire
         FROM (
               SELECT DISTINCT adhe_cntrt.numgar
                , adhe_cntrt.idadhesion
                , adhe_cntrt.numadhe numindiv
                , comm_date_debut
                , comm_date_fin
                , adhe_cntrt.numquerable numquerable1
                , f_bene_rib (adhe_cntrt.numquerable, 4, adhe_cntrt.numgar, 2 ) benerib
                , adhe_cntrt.numquerable
                , adhe_cntrt.numadhe
                , contrat.delegataire
               FROM contrat
                , adhe_cntrt
               WHERE adhe_cntrt.numquerable = t_cle (18)
                 AND adhe_cntrt.numgar        = comm_cle1
                 AND adhe_cntrt.numgar        = contrat.numgar
                 AND comm_test                = 2
                 AND comm_date_debut BETWEEN adhe_cntrt.date_adhe-365 AND NVL (adhe_cntrt.date_fin_adhe, comm_date_debut )+365
               ORDER BY 2 DESC
               FETCH FIRST 1 ROWS ONLY
              ) CTRLDBL;
              -- M0005586: Edition fiscale cotisation en erreur, ajout CTRLDBL, PHA 06/04/2018
              --           -1 an et +1 an pour tenir compte des résil/ouverture par rapport au peiment ex edition fiscale
      END;
   END IF;
   IF (a_contexte = 17) THEN
      /* Instruction sinistre */
      BEGIN
         SELECT repartition.idadhesion
          , sin_prev.nosin
          , sin_prev.numindiv
          , sin_prev.datesurv
          , NULL
         INTO t_cle (13)
          , t_cle (15)
          , t_cle (4)
          , comm_debut
          , comm_fin
         FROM sin_prev
          , repartition
         WHERE sin_prev.nosin          = repartition.nosin
         AND repartition.idrepartition = t_cle (17);
      END;
   END IF;
   IF (a_contexte = 15) THEN
      BEGIN
         IF (comm_test = 1) THEN
            SELECT decaismt.numdest
             , decompte_prev.idadhesion
             , sin_prev.numindiv
             , sin_prev.datesurv
             , NULL
             ,
               --f_bene_rib (sin_prev.numindiv, 2, f_numgar (decompte_prev.idadhesion), 1 ), -- jbn
               f_bene_rib(sin_prev.numindiv,2, f_numgar(decompte_prev.idadhesion),1,decompte_prev.monnaie_d)
             ,
               /*jbn 24/03/11*/
               decaismt.numdest
             , decaismt.numbene
             , sin_prev.numindiv
             , sin_prev.nosin
             , decaismt.numdecaismt
             , contrat.deleg_prest
            INTO t_cle (27)
             , t_cle (13)
             , t_cle (4)
             , comm_debut
             , comm_fin
             , g_idrib
             , t_cle (39)
             , t_cle (45)
             , t_cle (12)
             , t_cle (15)
             , t_cle (53)
             , t_cle (38)
            FROM contrat
             , adhe_cntrt
             , decaismt
             , affectation
             , decompte_prev
             , sin_prev
            WHERE decaismt.numdecaismt       = affectation.numdecaismt
            AND decompte_prev.numdec         = affectation.numaffec
            AND affectation.codope           = 2
            AND decompte_prev.numdec         = t_cle (15)
            AND f_sin (decompte_prev.numdec) = sin_prev.nosin
            AND contrat.numgar               = adhe_cntrt.numgar
            AND adhe_cntrt.idadhesion        = decompte_prev.idadhesion;
         ELSIF (comm_test                    = 2) THEN
            SELECT sin_prev.numindiv
             , repartition.idadhesion
             , sin_prev.numindiv
             , sin_prev.datesurv
             , NULL
             , f_bene_rib (sin_prev.numindiv, 2, f_numgar (repartition.idadhesion), 1 )
             , repartition_bene.numbene_dest
             , repartition_bene.numbene
             , sin_prev.numindiv
             , contrat.deleg_prest
            INTO t_cle (27)
             , t_cle (13)
             , t_cle (4)
             , comm_debut
             , comm_fin
             , g_idrib
             , t_cle (39)
             , t_cle (45)
             , t_cle (12)
             , t_cle (38)
            FROM contrat
             , adhe_cntrt
             , repartition
             , repartition_bene
             , sin_prev
            WHERE sin_prev.nosin               = repartition.nosin
            AND repartition_bene.idrepartition = repartition.idrepartition
            AND repartition.idrepartition      = t_cle (15)
            AND repartition_bene.numbene       = comm_cle1
            AND contrat.numgar                 = adhe_cntrt.numgar
            AND adhe_cntrt.idadhesion          = repartition.idadhesion;
         ELSIF (comm_test                      = 4) THEN
            --ABO 09/10/2013 on n'utilise pas comm_debut pour val_variable
            SELECT sin_prev.numindiv_corres
             , comm_cle1
             , sin_prev.numindiv
             ,
               --  sin_prev.datesurv,
               --    NULL,
               f_bene_rib (sin_prev.numindiv, 2, f_numgar (comm_cle1), 1 )
             , comm_cle2
             , comm_cle2
             , sin_prev.numindiv
             , TO_NUMBER ('')
             , SUBSTR(nosin,0,7)
            INTO t_cle (27)
             , t_cle (13)
             , t_cle (4)
             ,
               --comm_debut,
               --comm_fin,
               g_idrib
             , t_cle (39)
             , t_cle (45)
             , t_cle (12)
             , t_cle (38)
             , t_cle(16)
            FROM sin_prev
            WHERE sin_prev.nosin = t_cle (15);
         ELSIF (comm_test        = 3) THEN
            SELECT t_cle (15)
             , 0
             , t_cle (15)
             , SYSDATE
             , NULL
             , f_bene_rib (t_cle (15), 2, 0, 1)
             , t_cle (15)
             , t_cle (15)
             , t_cle (15)
             , TO_NUMBER ('')
            INTO t_cle (27)
             , t_cle (13)
             , t_cle (4)
             , comm_debut
             , comm_fin
             , g_idrib
             , t_cle (39)
             , t_cle (45)
             , t_cle (12)
             , t_cle (38)
            FROM DUAL;
         END IF;
      END;
   END IF;
   IF (a_contexte = 19) THEN
      BEGIN
         SELECT pricharge.numgar
          , f_prch_idadhesion (pricharge.numpc)
          , pricharge.numindiv
          , pricharge.numassu
          , pricharge.datehospi
          , f_bene_rib (pricharge.numindiv, 1, pricharge.numgar, 1)
          , pricharge.numtiers
          , 1
         INTO t_cle (2)
          , t_cle (13)
          , t_cle (12)
          , t_cle (4)
          , comm_debut
          , g_idrib
          , t_cle (6)
          , t_cle (50)
         FROM pricharge
         WHERE pricharge.numpc = t_cle (19);
      END;
   END IF;
   IF (a_contexte = 9) THEN
      t_cle (4)  := t_cle (9);
      t_cle (12) := t_cle (9);
   END IF;
   IF (a_contexte = 10) THEN
      BEGIN
         IF (comm_test = 2) THEN
     -- TLE - 11/03/2014 - MANTIS 4445 - AJOUT DU DISTINCT
            SELECT distinct adhe_cntrt.numgar
             , adhe_cntrt.idadhesion
             , t_cle (10)
             , f_bene_rib (t_cle (10), 1, adhe_cntrt.numgar, 1)
             , t_cle (10)
             , 0
             , t_cle (10)
            INTO t_cle (2)
             , t_cle (13)
             , t_cle (4)
             , g_idrib
             , t_cle (52)
             , t_cle (53)
             , t_cle (12)
            FROM porte_adhesion
             , adhe_cntrt
            WHERE adhe_cntrt.idadhesion  = porte_adhesion.idadhesion
            AND porte_adhesion.numindiv  = t_cle (10)
            AND porte_adhesion.transmis  = 1
            AND porte_adhesion.mouvement = 'C'
            AND porte_adhesion.debut    != NVL (porte_adhesion.fin, porte_adhesion.debut + 1)
            AND comm_date_debut BETWEEN adhe_cntrt.date_adhe AND NVL (adhe_cntrt.date_fin_adhe, comm_date_debut )
            AND comm_date_debut BETWEEN porte_adhesion.debut AND NVL (porte_adhesion.fin, comm_date_debut )
            AND comm_test = 2;
         ELSIF (comm_test = 1) THEN
            SELECT DISTINCT v_cvrt.numgar
             , v_cvrt.idadhesion
             , t_cle (10)
             , f_bene_rib (t_cle (10), 1, v_cvrt.numgar, 1)
             , t_cle (10)
             , 0
             , t_cle (10)
            INTO t_cle (2)
             , t_cle (13)
             , t_cle (4)
             , g_idrib
             , t_cle (52)
             , t_cle (53)
             , t_cle (12)
            FROM v_cvrt
            WHERE v_cvrt.numindiv = t_cle (10)
            AND v_cvrt.typfor     = 1
            AND v_cvrt.datapli   != NVL (v_cvrt.datper, v_cvrt.datapli + 1)
            AND comm_date_debut BETWEEN v_cvrt.datapli AND NVL (v_cvrt.datper, comm_date_debut )
            AND comm_test = 1;
         ELSIF (comm_test = 3) THEN
            SELECT dcpt.numgar
             , f_dcpt_idadhesion (dcpt.numdec)
             , dcpt.numindiv
             ,
               -- f_bene_rib (dcpt.numindiv, 1, dcpt.numgar, 1), -- jbn
               f_bene_rib(dcpt.numindiv,1,dcpt.numgar,1,dcpt.monnaie_d)
             ,
               /*jbn 24/03/11*/
               decaismt.numbene
             , decaismt.numdecaismt
             , dcpt.numindiv
            INTO t_cle (2)
             , t_cle (13)
             , t_cle (4)
             , g_idrib
             , t_cle (52)
             , t_cle (53)
             , t_cle (12)
            FROM decaismt
             , affectation
             , dcpt
            WHERE dcpt.numdec        = t_cle (10)
            AND affectation.numaffec = dcpt.numdec
            AND affectation.codope   = 1
            AND decaismt.numdecaismt = affectation.numdecaismt
            AND decaismt.codope + 0  = 1
            AND comm_test            = 3;
         END IF;
      EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         t_cle (2) := 0;
         g_idrib   := f_bene_rib (t_cle (10), 1, 0, 1);
         t_cle (4) := t_cle (10);
      WHEN NO_DATA_FOUND THEN
         t_cle (2) := 0;
         g_idrib   := f_bene_rib (t_cle (10), 1, 0, 1);
         t_cle (4) := t_cle (10);
      END;
      --
      t_cle (59) := 0435800005;
      --
   END IF;
   IF (a_contexte   = 16) THEN
      IF (comm_test = 1) THEN
         SELECT sntr.numgar
          , f_dcpt_idadhesion (sntr.numdec)
          , sntr.numindiv
          ,
            -- f_bene_rib (sntr.numindiv, 1, sntr.numgar, 1), -- jbn
            f_bene_rib(sntr.numindiv,1,sntr.numgar,1,decaismt.monnaie_d)
          ,
            /*jbn 24/03/11*/
            decaismt.numbene
          , decaismt.numdecaismt
          , sntr.numindiv
          , sntr.codfrais
          , sntr.numdec
         INTO t_cle (2)
          , t_cle (13)
          , t_cle (4)
          , g_idrib
          , t_cle (52)
          , t_cle (53)
          , t_cle (12)
          , comm_codfrais
          , t_cle (10)
         FROM decaismt
          , affectation
          , sntr
         WHERE affectation.numaffec = sntr.numdec
         AND affectation.codope     = 1
         AND decaismt.numdecaismt   = affectation.numdecaismt
         AND decaismt.codope + 0    = 1
         AND sntr.numsin            = t_cle (16);
      ELSIF (comm_test              = 2) THEN
         t_cle (2)                 := comm_cle1;
         t_cle (16)                := 0;
      END IF;
   END IF;
   IF (a_contexte = 53) THEN
      SELECT decaismt.numdest
       ,
         -- f_bene_rib (decaismt.numdest, 0, 0, 1) -- jbn
         f_bene_rib(decaismt.numdest,0,0,1,decaismt.monnaie_d)
         /*jbn 24/03/11*/
      INTO t_cle (0)
       , g_idrib
      FROM decaismt
      WHERE decaismt.numdecaismt = t_cle (53);
      IF (comm_test              = 2) THEN
         BEGIN
            SELECT dette.iddette
            INTO t_cle (55)
            FROM dette
            WHERE iddette IN
               (SELECT dcpt.numdcptcie
               FROM dcpt
                , affectation
                , decaismt
               WHERE affectation.numdecaismt = decaismt.numdecaismt
               AND affectation.numaffec      = dcpt.numdec
               AND decaismt.numdecaismt      = t_cle (53)
               );
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            t_cle (55) := 0;
         END;
      END IF;
   END IF;
   IF (a_contexte = 54) THEN
      SELECT encaismt.numcli
       ,
         -- f_bene_rib (encaismt.numcli, 0, 0, 1) -- jbn
         f_bene_rib(encaismt.numcli,0,0,1,encaismt.monnaie_d)
         /*jbn 24/03/11*/
      INTO t_cle (0)
       , g_idrib
      FROM encaismt
      WHERE encaismt.numencaismt = t_cle (54);
   END IF;
   IF (a_contexte = 55) THEN
      BEGIN
         SELECT dette.numcli
          ,
            -- f_bene_rib (dette.numcli, 10, 0, 1), -- jbn
            f_bene_rib(dette.numcli,10,0,1,dette.devise_d)
          ,
            /*jbn 24/03/11*/
            contrat.deleg_prest
          , contrat.numgar
         INTO t_cle (0)
          , g_idrib
          , t_cle (38)
          , t_cle (2)
         FROM contrat
          , dette
         WHERE dette.iddette = t_cle (55)
         AND contrat.numgar IN
            (SELECT sntr.numgar
            FROM sntr
             , dcpt
            WHERE sntr.numdec   = dcpt.numdec
            AND dcpt.numdcptcie = t_cle (55)
            );
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         t_cle (55) := 0;
      WHEN TOO_MANY_ROWS THEN
         BEGIN
            SELECT MIN (contrat.numgar)
             , dette.numcli
             ,
               -- f_bene_rib (dette.numcli, 10, 0, 1), -- jbn
               f_bene_rib(dette.numcli,10,0,1,dette.devise_d)
             ,
               /*jbn 24/03/11*/
               contrat.deleg_prest
            INTO t_cle (2)
             , t_cle (0)
             , g_idrib
             , t_cle (38)
            FROM contrat
             , dette
            WHERE dette.iddette = t_cle (55)
            AND contrat.numgar IN
               (SELECT sntr.numgar
               FROM sntr
                , dcpt
               WHERE sntr.numdec   = dcpt.numdec
               AND dcpt.numdcptcie = t_cle (55)
               )
            GROUP BY dette.numcli
             ,
               -- f_bene_rib (dette.numcli, 10, 0, 1), -- jbn
               f_bene_rib(dette.numcli,10,0,1,dette.devise_d)
             ,
               /*jbn 24/03/11*/
               contrat.deleg_prest;
         END;
      END;
   END IF;
   -- David 22/11/2004
   IF (a_contexte = 59) THEN
      ------------------------------
      SELECT dossier_sante.num_dossier
         /*,
         dossier_sante.ref_dossier,
         dossier_sante.numindiv,
         dossier_sante.typbene,
         dossier_sante.numbene,
         dossier_sante.devise,
         dossier_sante.devise_out,
         dossier_sante.creation,
         dossier_sante.dateouv,
         dossier_sante.dateferm,
         dossier_sante.maj,
         dossier_sante.numutil,
         dossier_sante.numassu,
         dossier_sante.nat_doss,
         dossier_sante.type_doss,
         dossier_sante.numprescrip,
         dossier_sante.numtiers,
         dossier_sante.pec,
         dossier_sante.num_dossier_pec,
         dossier_sante.num_fact_pec,
         dossier_sante.num_entree_pec,
         dossier_sante.reseau,
         histo_dossier.debut,
         histo_dossier.etat,
         histo_dossier.motif,
         histo_dossier.datsai,
         courr_dest.numindiv dest_courrier
         */
      INTO t_cle (0)
      FROM dossier_sante
       , histo_dossier
       , courr_dest
      WHERE dossier_sante.num_dossier = t_cle (59)
      AND dossier_sante.num_dossier   = histo_dossier.num_dossier
      AND dossier_sante.num_dossier   = courr_dest.ID
      AND courr_dest.valide           = 1;
   END IF;
   IF (a_contexte = 13) THEN
      BEGIN
         SELECT numgar
          , numadhe
          , numadhe
          , numadhe
          , date_adhe
          , date_fin_adhe
          ,
            -- f_bene_rib(numadhe,0,numgar,1),
            --PK_treso.f_idrib (numadhe, 2, 0, numgar, date_adhe, idadhesion ),
            --SDA M0003400
            PK_treso.f_idrib (numadhe, 2, 0, numgar, comm_date_debut,idadhesion )
          , adhe_cntrt.numquerable
         INTO t_cle (2)
          , t_cle (20)
          , t_cle (12)
          , t_cle (4)
          , comm_debut
          , comm_fin
          , g_idrib
          , t_cle (21)
         FROM adhe_cntrt
         WHERE idadhesion = t_cle (13);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         t_cle (2) := 0;
      END;
      OPEN c_adhe_pret;
      FETCH c_adhe_pret
      INTO t_cle (57)
       , -- Idpret
         g_type_adresse;
      CLOSE c_adhe_pret;
   END IF;
   /* -- PHA pour gestion debut et fin */
   IF (t_cle (13) != 0) THEN
      BEGIN
         l_debut1 := NULL;
         l_fin1   := NULL;
         SELECT numgar
          , numadhe
          , date_adhe
          , date_fin_adhe
         INTO t_cle (2)
          , t_cle (20)
          , l_debut1
          , l_fin1
         FROM adhe_cntrt
         WHERE idadhesion = t_cle (13);
         IF comm_debut   IS NULL THEN
            comm_debut   := l_debut1;
            IF comm_fin  IS NULL THEN
               comm_fin  := l_fin1;
            END IF;
         END IF;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         t_cle (2) := 0;
      END;
      OPEN c_apporteur;
      FETCH c_apporteur INTO t_cle (38);
      IF (c_apporteur%NOTFOUND) THEN
         OPEN c_apporteur_global;
         FETCH c_apporteur_global INTO t_cle (38);
         CLOSE c_apporteur_global;
      END IF;
      CLOSE c_apporteur;
   END IF;
   IF (t_cle (14) != 0) THEN
      BEGIN
         SELECT proposition.objet
         INTO comm_objet
         FROM proposition
         WHERE proposition.idpropo = t_cle (14);
         IF (comm_objet            = 2) THEN
            SELECT proposition.numindiv
             , proposition.numindiv
             , proposition.numindiv
             , contrat.numgar
             , f_bene_rib (proposition.numindiv, 0, contrat.numgar, 1)
             , proposition.numindiv
            INTO t_cle (12)
             , t_cle (4)
             , t_cle (0)
             , t_cle (2)
             , g_idrib
             , t_cle (22)
            FROM proposition
             , contrat
            WHERE proposition.idpropo = t_cle (14)
            AND proposition.objet     = 2
            AND contrat.numgar        = proposition.idobjet;
         ELSE
            SELECT proposition.numindiv
             , proposition.numindiv
             , proposition.numindiv
             , produit.numprod
             , f_bene_rib (proposition.numindiv, 0, 0, 1)
             , proposition.numindiv
            INTO t_cle (12)
             , t_cle (4)
             , t_cle (0)
             , t_cle (7)
             , g_idrib
             , t_cle (22)
            FROM proposition
             , produit
            WHERE proposition.idpropo = t_cle (14)
            AND proposition.objet     = 1
            AND produit.numprod       = proposition.idobjet;
         END IF;
      END;
   END IF;
   IF (a_contexte = 2) THEN
      SELECT f_bene_rib (contrat.numcli, 1, t_cle (2), 1)
      INTO g_idrib
      FROM contrat
      WHERE numgar = t_cle (2);
   END IF;
   IF (t_cle (2) != 0) THEN
      BEGIN
         SELECT contrat.numprod
          , contrat.numcli
          , contrat.numorg
          , contrat.numinterm
         INTO t_cle (7)
          , t_cle (3)
          , t_cle (5)
          , t_cle (9)
         FROM contrat
         WHERE numgar = t_cle (2);
      END;
   END IF;
   IF (t_cle (12) != 0 AND t_cle (4) = 0) THEN
      BEGIN
         SELECT assu.numassu
          , f_bene_rib (numassu, 0, 0, 1)
         INTO t_cle (4)
          , g_idrib
         FROM assu
         WHERE numindiv = t_cle (12);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         t_cle (4) := 0;
      END;
   END IF;
   IF (t_cle (4) != 0 AND g_idrib = 0) THEN
      BEGIN
         SELECT f_bene_rib (numassu, 0, 0, 1)
         INTO g_idrib
         FROM assu
         WHERE numindiv = t_cle (4);
      END;
   END IF;
   -- 25-01-2008 NSO Correction des fiches Humanis (2037-2065-2064 etc...)
   IF (t_cle (18)) != 0 THEN
      BEGIN
         SELECT mregl
         INTO g_mregl
         FROM facture
         WHERE numfact = t_cle (18);
      END;
   END IF;
   -- 25-01-2008 NSO Correction des fiches Humanis (2037-2065-2064 etc...)
   IF (a_contexte = 0) THEN
      g_idrib    := f_bene_rib (t_cle (0), 0, 0, 1);
   END IF;
   g_idadhesion := t_cle (13);
END Charge_Cle;
--
-- -- P_Charge_Variable --------------------------------------------
--
PROCEDURE P_Charge_Variable(
      i_texte IN VARCHAR2,
      o_variable OUT libelle.mnemo%TYPE,
      o_indice OUT NUMBER,
      o_type OUT BINARY_INTEGER,
      o_chaine OUT VARCHAR2 )
IS
   /*
   Extrait la variable texte de I_texte
   Renvoie :
   O_variable  -> le nom de la variable
   O_indice -> l'indice de la variable
   O_type      -> le type de variable ( # -> 1, $ -> 2
   0 -> pas de variable )
   O_chaine -> la chaine variable ( avec les x )
   */
   l_pos_$ BINARY_INTEGER       := 0;
   l_pos_# BINARY_INTEGER       := 0;
   l_pos_debut BINARY_INTEGER   := 0;
   l_par_ouverte BINARY_INTEGER := 0;
   l_par_fermee BINARY_INTEGER  := 0;
   l_fin_variable BINARY_INTEGER;
   l_chaine VARCHAR2(4000);
   l_len_indice BINARY_INTEGER;
   i BINARY_INTEGER;
BEGIN
   l_pos_#        := INSTR (i_texte, '#');
   l_pos_$        := INSTR (i_texte, '$');
   l_chaine       := NULL;
   IF (l_pos_#     > 0) THEN
      o_type      := 1;
      l_pos_debut := l_pos_#;
   ELSIF (l_pos_$  > 0) THEN
      o_type      := 2;
      l_pos_debut := l_pos_$;
   ELSE
      o_type := 0;
   END IF;
   IF (l_pos_debut    > 0) THEN
      l_fin_variable := INSTR (i_texte, ')', l_pos_debut)            - l_pos_debut;
      l_chaine       := SUBSTR (i_texte, l_pos_debut, l_fin_variable + 1);
      l_par_ouverte  := INSTR (l_chaine, '(');
      l_par_fermee   := INSTR (i_texte, ')');
      o_variable     := SUBSTR (l_chaine, 2, l_par_ouverte         - 2);
      l_len_indice   := LENGTH (l_chaine)                          - l_par_ouverte - 1;
      o_indice       := TO_NUMBER (SUBSTR (l_chaine, l_par_ouverte + 1, l_len_indice));
      /* On complete la chaine avec les x */
      FOR i IN l_pos_debut + l_fin_variable + 1 .. LENGTH (i_texte)
      LOOP
         IF (SUBSTR (i_texte, i, 1) = 'x') THEN
            l_chaine               := l_chaine || 'x';
         ELSE
            EXIT;
         END IF;
      END LOOP;
      o_chaine := l_chaine;
   END IF;
END P_Charge_Variable;
--
-- -- Charge_Donnee--------------------------------------------
--
PROCEDURE Charge_Donnee(
      a_texte         IN VARCHAR2,
      a_contexte_base IN NUMBER,
      a_cle           IN NUMBER,
      o_texte_decode OUT VARCHAR2,
      o_found OUT BOOLEAN )
IS
   l_texte          VARCHAR2(4000) := a_texte;
   l_texte_variable VARCHAR2(4000);
   l_nom_variable libelle.mnemo%TYPE;
   l_mnemo_donnee libelle.mnemo%TYPE;
   l_indice NUMBER;
   l_type_variable BINARY_INTEGER := 0;
   l_type_specif     VARCHAR2 (4);
   l_longueur_donnee NUMBER;
   l_cle_logique     NUMBER;
   l_valeur          VARCHAR2(4000);
   CURSOR C_don_base (p_nom_variable libelle_bis.code%TYPE)
   IS
      SELECT sens
      FROM libelle_bis
      WHERE mnemo = 'DON_BASE'
      AND code    = p_nom_variable;
   R_don_base C_don_base%ROWTYPE;
   CURSOR C_cle_logique (p_cle_logique libelle.code%TYPE)
   IS
      SELECT code
       , codapli
       , tableau
      FROM libelle
      WHERE mnemo = 'CLE_BASE'
      AND code    = p_cle_logique;
   R_cle_logique C_cle_logique%ROWTYPE;
   CURSOR C_donnee_variable ( p_mnemo_donnee libelle.mnemo%TYPE, p_indice libelle.mnemo%TYPE )
   IS
      SELECT sens
       , tableau
      FROM libelle
      WHERE mnemo = p_mnemo_donnee
      AND code    = p_indice;
   R_donnee_variable C_donnee_variable%ROWTYPE;
BEGIN
   o_found := TRUE;
   PK_texte.P_Charge_Variable (i_texte => l_texte, o_variable => l_nom_variable, o_indice => l_indice, o_type => l_type_variable, o_chaine => l_texte_variable );
   IF (l_type_variable NOT IN (1, 2)) THEN
      o_found              := FALSE;
      l_valeur             := l_texte;
   END IF;
   IF (l_type_variable = 1) THEN
      OPEN C_don_base (l_nom_variable);
      FETCH C_don_base INTO R_don_base;
      IF C_don_base%FOUND THEN
         l_cle_logique := R_don_base.sens;
      END IF;
      CLOSE C_don_base;
      OPEN C_cle_logique (l_cle_logique);
      FETCH C_cle_logique INTO R_cle_logique;
      IF C_cle_logique%found THEN
         IF (R_cle_logique.tableau > 0) THEN
            l_cle_logique         := TO_NUMBER (R_cle_logique.codapli);
         END IF;
      END IF;
      CLOSE C_cle_logique;
      l_mnemo_donnee := 'D_' || f_mnemo_donnee (l_cle_logique);
      OPEN C_donnee_variable (l_mnemo_donnee, l_indice);
      FETCH C_donnee_variable INTO R_donnee_variable;
      IF C_donnee_variable%FOUND THEN
         l_longueur_donnee            := R_donnee_variable.sens;
         IF R_donnee_variable.tableau IS NULL THEN
            l_valeur                  := PK_texte.F_Eval_Donnee (l_cle_logique, l_indice, a_contexte_base, a_cle );
         ELSE
            l_valeur := TRIM(R_donnee_variable.tableau);
         END IF;
      END IF;
      CLOSE C_donnee_variable;
   END IF;
   IF (l_type_variable = 2) THEN
      l_valeur        := PK_texte.F_Eval_Variable (l_nom_variable, a_contexte_base, a_cle, l_indice );
   END IF;
   /*
   o_texte_decode := REPLACE (a_texte, l_texte_variable, TRIM (l_valeur));
   IF (l_type_specif IS NOT NULL)
   THEN
   o_texte_decode := l_type_specif;
   END IF;
   */
   IF l_texte_variable IS NOT NULL THEN
      o_texte_decode   := REPLACE (a_texte, l_texte_variable, TRIM (l_valeur));
   ELSE
      o_texte_decode := TRIM (l_valeur);
   END IF;
END Charge_Donnee;
--
-- ----------------------- Debut chargement entites
--P_ CHARGE_RIB --------------------------------------------
--
PROCEDURE P_Charge_RIB(
      o_donnee OUT PK_texte.donnee)
IS
   CURSOR c_rib
   IS
      SELECT TYPE
       , debut
       , codope
       , numgar
       , modpmt
       , devise_compte
       , devise_ope
       , codbque
       , guichet
       , compte
       , clerib
       , intitule
       , domiciliation
       , bban
       , clef_iban
       , bic
      FROM rib
      WHERE idrib = g_idrib;
   rec_c_rib c_rib%ROWTYPE;
BEGIN
   OPEN c_rib;
   FETCH c_rib INTO rec_c_rib;
   CLOSE c_rib;
   o_donnee (1)      := rec_c_rib.numgar;
   o_donnee (2)      := SUBSTR (PK_libelle.f_lib ('OPE', rec_c_rib.codope), 1, 15);
   IF (rec_c_rib.TYPE = 1) THEN
      o_donnee (3)   := SUBSTR (PK_libelle.f_lib ('MOPM', rec_c_rib.modpmt), 1, 15);
   ELSE
      o_donnee (3) := SUBSTR (PK_libelle.f_lib ('MREGL', rec_c_rib.modpmt), 1, 15);
   END IF;
   o_donnee (4)  := rec_c_rib.codbque || ' ' || rec_c_rib.guichet || ' ' || rec_c_rib.compte || ' ' || rec_c_rib.clerib;
   o_donnee (5)  := SUBSTR (rec_c_rib.intitule, 1, 25);
   o_donnee (6)  := d2e (rec_c_rib.debut);
   o_donnee (7)  := SUBSTR (PK_libelle.f_lib ('DEVISE', rec_c_rib.devise_compte), 1, 15);
   o_donnee (8)  := SUBSTR (PK_libelle.f_lib ('DEVISE', rec_c_rib.devise_ope), 1, 15);
   o_donnee (9)  := rec_c_rib.domiciliation;
   o_donnee (10) := rec_c_rib.bban;
   o_donnee (11) := rec_c_rib.clef_iban;
   o_donnee (12) := rec_c_rib.bic;
END P_Charge_RIB;
--
-- -- Charge_Indvs --------------------------------------------
--
PROCEDURE Charge_Indvs(
      i_numindiv IN individu.numindiv%TYPE,
      o_donnee OUT PK_texte.donnee )
IS
   t_donnee_rib PK_texte.donnee;
   l_idadresse pers_adresse.idadresse%TYPE;
BEGIN
   l_idadresse := PK_personne.f_idadresse (a_numindiv => i_numindiv, a_codope => 0, a_debut => SYSDATE, a_defaut => 'O', a_numgar => 0, a_type_adr => g_type_adresse );
   -- Charge_rib(G_idrib,t_donnee_rib);
   PK_Texte.P_Charge_RIB (o_donnee => t_donnee_rib);
   o_donnee (31) := t_donnee_rib (1);
   o_donnee (32) := t_donnee_rib (2);
   o_donnee (33) := t_donnee_rib (3);
   o_donnee (34) := t_donnee_rib (4);
   o_donnee (35) := t_donnee_rib (5);
   o_donnee (36) := t_donnee_rib (6);
   o_donnee (37) := t_donnee_rib (7);
   o_donnee (38) := t_donnee_rib (8);
   o_donnee (40) := t_donnee_rib (9);
   o_donnee (42) := t_donnee_rib (10);
   o_donnee (46) := substr(t_donnee_rib (10), 1, 3)||lpad(substr(t_donnee_rib (10),length(t_donnee_rib (10))-2,length(t_donnee_rib (10))),length(t_donnee_rib (10))-3,'x'); -- MUR M0005580
   o_donnee (43) := t_donnee_rib (11);
   o_donnee (44) := t_donnee_rib (12);
   SELECT numindiv
    , refcie
    , SUBSTR (PK_libelle.f_lib ('QLTE', qualite), 1, 15)
    , SUBSTR (PK_libelle.f_lib ('CODC1', codcourrier1), 1, 15)
    , SUBSTR (PK_libelle.f_lib ('CODC2', codcourrier2), 1, 15)
    , SUBSTR (PK_libelle.f_lib ('TITRE', codtitre), 1, 15)
    , SUBSTR (PK_personne.f_nom (numindiv, 30, 0), 1, 30)
    , SUBSTR (nom, 1, 30)
    , SUBSTR (prenom, 1, 20)
    , PK_personne.f_adresse (l_idadresse, 1, numindiv)
    , PK_personne.f_adresse (l_idadresse, 2, numindiv)
    , PK_personne.f_adresse (l_idadresse, 3, numindiv)
    , PK_personne.f_adresse (l_idadresse, 4, numindiv)
    , SUBSTR (f_pays (codpays), 1, 15)
    , tel
    , fax
    , d2e (datnais)
    , SUBSTR (PK_libelle.f_lib ('TPAS', typassu), 1, 15)
    , DECODE (natur, 1, 'Ouvreur de droit', 2, 'Ayant-Droit')
    , SUBSTR (PK_libelle.f_lib ('TYAD', typadr), 1, 15)
    , matorg
    , cless
    , SUBSTR (PK_libelle.f_lib ('REGIME', regime), 1, 15)
    , SUBSTR (PK_libelle.f_lib ('ORGNS', orgbase), 1, 15)
    , caisse
    , guichetorg
    , cle
    , rang
    , numassu
    , email
    , matorg2
   INTO o_donnee (1)
    , o_donnee (2)
    , o_donnee (3)
    , o_donnee (4)
    , o_donnee (5)
    , o_donnee (6)
    , o_donnee (7)
    , o_donnee (8)
    , o_donnee (9)
    , o_donnee (10)
    , o_donnee (11)
    , o_donnee (12)
    , o_donnee (13)
    , o_donnee (14)
    , o_donnee (15)
    , o_donnee (16)
    , o_donnee (17)
    , o_donnee (18)
    , o_donnee (19)
    , o_donnee (20)
    , o_donnee (21)
    , o_donnee (22)
    , o_donnee (23)
    , o_donnee (24)
    , o_donnee (25)
    , o_donnee (26)
    , o_donnee (27)
    , o_donnee (28)
    , o_donnee (29)
    , o_donnee (39)
    , o_donnee (45)
   FROM indvs
   WHERE numindiv = i_numindiv;
END Charge_Indvs;
--
-- P_Sel_Cotis_Adhesion --------------------------------------------
--
PROCEDURE P_SEL_cotis_adhesion(
      I_idadhesion IN NUMBER,
      I_date       IN DATE,
      O_cotis OUT donnee )
IS

  -- -- DEBUT MODIFS TLE - MANTIS 3858 - 01/09/2014
   CURSOR C_cotis_comptant
   IS
      /*SELECT SUM(facture.montant) montant
       , MIN(qttc_global.debut) debut
       , MAX(qttc_global.fin) fin
       , MIN(facture.echeance) echeance
      FROM facture
       , qttc_global
       , adhe_cntrt
      WHERE adhe_cntrt.idadhesion = I_idadhesion
      AND adhe_cntrt.mregl        = 2
      AND facture.codope          = 4
      AND facture.mregl           = 2
      AND facture.numfact         = qttc_global.numquit
      AND qttc_global.idadhesion  = adhe_cntrt.idadhesion
      AND qttc_global.type_qttc   = 2
      AND facture.numfact NOT    IN
         (SELECT numfact
         FROM prelevement_detail
         WHERE codope=4
         )
   UNION ALL
   SELECT facture.montant
    , qttc_global.debut
    , qttc_global.fin
    , facture.echeance
   FROM facture
    , qttc_global
    , adhe_cntrt
   WHERE adhe_cntrt.idadhesion = I_idadhesion
   AND adhe_cntrt.mregl        = 1
   AND facture.codope          = 4
   AND facture.mregl           = 1
   AND facture.numfact         = qttc_global.numquit
   AND qttc_global.idadhesion  = adhe_cntrt.idadhesion
   AND qttc_global.comptant    = 'C';
   */

   -- MUR M0005580 : specifique EPAI : ajout test f_client = 4
    SELECT SUM(facture.montant) montant
       , MIN(qttc_global.debut) debut
       , MAX(qttc_global.fin)   fin
       , MIN(facture.echeance)  echeance
      FROM facture
       , qttc_global
       , adhe_cntrt
      WHERE adhe_cntrt.idadhesion = I_idadhesion
      AND adhe_cntrt.mregl        = 2
      AND facture.codope          = 4
      AND facture.mregl           = 2
      AND facture.numfact         = qttc_global.numquit
      AND qttc_global.idadhesion  = adhe_cntrt.idadhesion
      AND qttc_global.type_qttc   = 2
      AND NOT EXISTS
         (SELECT 1
         FROM emission
         WHERE qttc_global.numquit = emission.numfact
         AND emission.codope       = 4
         AND emission.NUMRELANCE   =99
         )
   AND qttc_global.COMPTANT        != 'R'
   -- AND TO_CHAR(qttc_global.debut, 'YYYY') = TO_CHAR(I_DATE, 'YYYY')
   AND facture.numfact NOT IN (SELECT numfact FROM prelevement_detail WHERE codope=4)
   and f_client = 5 -- MUR M0005580
   UNION ALL
   SELECT SUM(facture.montant) montant
       , MIN(qttc_global.debut) debut
       , MAX(qttc_global.fin) fin
       , MIN(facture.echeance) echeance
   FROM facture
    , qttc_global
    , adhe_cntrt
   WHERE adhe_cntrt.idadhesion = I_idadhesion
   AND adhe_cntrt.mregl        = 1
   AND facture.codope          = 4
   AND facture.mregl           = 1
   AND facture.numfact         = qttc_global.numquit
   AND qttc_global.idadhesion  = adhe_cntrt.idadhesion
   AND qttc_global.comptant    = 'C'
   AND NOT EXISTS
      (SELECT 1
      FROM emission
      WHERE qttc_global.numquit = emission.numfact
      AND emission.codope       = 4
      AND emission.NUMRELANCE   =99
      )
   AND qttc_global.COMPTANT              != 'R'
   -- AND TO_CHAR(qttc_global.debut, 'YYYY') = TO_CHAR(I_DATE, 'YYYY')
   and f_client = 5 -- MUR M0005580

   -- MUR M0005580 : curseur v7 sauf EPAI
   union all
       SELECT facture.montant montant
       , MIN(qttc_global.debut) debut
       , MIN (qttc_global.fin) fin
       , MIN(facture.echeance) echeance
      FROM facture
       , qttc_global
       , adhe_cntrt
      WHERE adhe_cntrt.idadhesion = I_idadhesion
      AND adhe_cntrt.mregl        = 2
      AND facture.codope          = 4
      AND facture.mregl           = 2
      AND facture.numfact         = qttc_global.numquit
      AND qttc_global.idadhesion  = adhe_cntrt.idadhesion
      AND qttc_global.type_qttc   = 2
      AND NOT EXISTS
         (SELECT 1
         FROM emission
         WHERE qttc_global.numquit = emission.numfact
         AND emission.codope       = 4
         AND emission.NUMRELANCE   =99
         )
   AND qttc_global.COMPTANT              != 'R'
   AND TO_CHAR(qttc_global.debut, 'YYYY') = TO_CHAR(I_DATE, 'YYYY')
   AND qttc_global.MT_NET                 > 0
   and f_client != 5 -- MUR M0005580
   GROUP BY montant
   UNION ALL
   SELECT facture.montant
    , qttc_global.debut
    , qttc_global.fin
    , facture.echeance
   FROM facture
    , qttc_global
    , adhe_cntrt
   WHERE adhe_cntrt.idadhesion = I_idadhesion
   AND adhe_cntrt.mregl        = 1
   AND facture.codope          = 4
   AND facture.mregl           = 1
   AND facture.numfact         = qttc_global.numquit
   AND qttc_global.idadhesion  = adhe_cntrt.idadhesion
   AND qttc_global.comptant    = 'C'
   AND NOT EXISTS
      (SELECT 1
      FROM emission
      WHERE qttc_global.numquit = emission.numfact
      AND emission.codope       = 4
      AND emission.NUMRELANCE   =99
      )
   AND qttc_global.COMPTANT              != 'R'
   AND TO_CHAR(qttc_global.debut, 'YYYY') = TO_CHAR(I_DATE, 'YYYY')
   AND qttc_global.MT_NET                 > 0
   and f_client != 5 -- MUR M0005580
   ;


   CURSOR C_cotis_terme
   IS
      SELECT facture.montant
       , qttc_global.debut
       , qttc_global.fin
      FROM facture
       , qttc_global
      WHERE facture.codope       = 4
      AND facture.numfact        = qttc_global.numquit
      AND qttc_global.idadhesion = I_idadhesion
      AND qttc_global.comptant   = 'N'
      ORDER BY debut DESC;
   Rec_C_cotis_comptant C_cotis_comptant%RowType;
   Rec_C_cotis_terme C_cotis_terme%RowType;
BEGIN
   --
   OPEN C_cotis_comptant;
   FETCH C_cotis_comptant
   INTO Rec_C_cotis_comptant;
   CLOSE C_cotis_comptant;
   O_cotis(1) := TO_CHAR( Rec_C_cotis_comptant.montant, '9G999G999D99' );
   O_cotis(2) := TO_CHAR( Rec_C_cotis_comptant.debut, 'dd/mm/yyyy' );
   O_cotis(3) := TO_CHAR( Rec_C_cotis_comptant.fin, 'dd/mm/yyyy' );
   O_cotis(4) := TO_CHAR( Rec_C_cotis_comptant.echeance, 'dd/mm/yyyy' );
   O_cotis(6) := Rec_C_cotis_comptant.montant;
   --
   OPEN C_cotis_terme;
   FETCH C_cotis_terme INTO Rec_C_cotis_terme;
   CLOSE C_cotis_terme;
   O_cotis(5) := TO_CHAR( Rec_C_cotis_terme.montant, '9G999G999D99' );
   O_cotis(7) := Rec_C_cotis_terme.montant;
   --
END P_SEL_cotis_adhesion;
--
-- -- Charge_Adhe_Cntrt --------------------------------------------
--
PROCEDURE Charge_Adhe_Cntrt(
      i_idadhesion IN NUMBER,
      i_date       IN DATE,
      o_donnee OUT PK_texte.donnee )
IS
   CURSOR c_adhe_cntrt
   IS
      --SELECT idadhesion
      -- , ref_ext
      -- , numgar
      -- , numadhe
      -- , date_adhe
      -- , meme_gar
      -- , date_fin_adhe
      -- , numquerable
      -- , fract
      -- , echesuiv
      -- , dereche
      -- , mregl
      -- , delai
      -- , dsous
      -- , numutil
      --FROM adhe_cntrt
      --WHERE idadhesion = i_idadhesion;
    -- TLE 15/10/2014 - MERGE SEPA V7 ET EPAI
      SELECT -- SEPA : MUR le 27/03/2014 : prise en compte  mandat et mandat_maitre
      adh.idadhesion,
      adh.ref_ext,
      adh.numgar,
      adh.numadhe,
      adh.date_adhe,
      adh.meme_gar,
      adh.date_fin_adhe,
      adh.numquerable,
      adh.fract,
      adh.echesuiv,
      adh.dereche,
      adh.mregl,
      adh.delai,
      adh.dsous,
      adh.numutil,
      hq.mandat,        -- TLE 15/10/2014 - MERGE SEPA V7 ET EPAI
      hq.mandat_maitre     -- TLE 15/10/2014 - MERGE SEPA V7 ET EPAI
    FROM adhe_cntrt adh
    left outer join histo_querable HQ on (hq.idadhesion = adh.idadhesion and hq.numgar = adh.numgar and hq.numquerable = adh.numquerable and hq.etat = 1)
    WHERE adh.idadhesion = i_idadhesion;
   rec_c_adhe_cntrt c_adhe_cntrt%ROWTYPE;
   t_cotis PK_texte.donnee;
   s_Sepa VARCHAR2(8);
BEGIN
   -- loc_tableau :=f_qttc_comptant(I_idadhesion);
   OPEN c_adhe_cntrt;
   FETCH c_adhe_cntrt INTO rec_c_adhe_cntrt;
   CLOSE c_adhe_cntrt;
   PK_Texte.P_Sel_Cotis_Adhesion (i_idadhesion => i_idadhesion, i_date => i_date, o_cotis => t_cotis );
   o_donnee (1)  := rec_c_adhe_cntrt.idadhesion;
   o_donnee (2)  := rec_c_adhe_cntrt.numadhe;
   o_donnee (3)  := rec_c_adhe_cntrt.numquerable;
   o_donnee (4)  := rec_c_adhe_cntrt.ref_ext;
   o_donnee (5)  := d2e (rec_c_adhe_cntrt.dsous);
   o_donnee (6)  := d2e (rec_c_adhe_cntrt.date_fin_adhe);
   o_donnee (7)  := SUBSTR (PK_libelle.f_lib ('FRAC', rec_c_adhe_cntrt.fract), 1, 15);
   o_donnee (8)  := SUBSTR (PK_libelle.f_lib ('MREGL', rec_c_adhe_cntrt.mregl), 1, 15);
   o_donnee (9)  := SUBSTR (PK_libelle.f_lib ('USER', rec_c_adhe_cntrt.numutil), 1, 15);
   o_donnee (10) := d2e (rec_c_adhe_cntrt.date_adhe);
   o_donnee (11) := SUBSTR (PK_libelle.f_lib ('ET_ADHE', f_etat_adhe (a_idadhesion => i_idadhesion, a_date => SYSDATE ) ), 1, 15 );
   o_donnee (12) := SUBSTR (PK_libelle.f_lib ('HISTO_ADHE', f_etat_adhe (a_idadhesion => i_idadhesion, a_date => SYSDATE, a_type => 2 ) ), 1, 15 );
   o_donnee (13) := TO_CHAR (f_qttc_annuelle (i_idadhesion, i_date, 1), '9G999G999D99');
   o_donnee (14) := t_cotis (1);
   o_donnee (15) := t_cotis (2);
   o_donnee (16) := t_cotis (3);
   o_donnee (18) := d2e (j2d (f_etat_adhe (a_idadhesion => i_idadhesion, a_date => GREATEST (rec_c_adhe_cntrt.date_adhe, SYSDATE ), a_type => 3 ) ) );
   o_donnee (20) := TO_CHAR (PK_devise.f_convert_euro (i_montant => f_qttc_annuelle (i_idadhesion, i_date, 1 ) ), '9G999G999D99' );
   o_donnee (21) := TO_CHAR (PK_devise.f_convert_euro (i_montant => t_cotis (6)), '9G999G999D99' );
   o_donnee (22) := rec_c_adhe_cntrt.delai;
   o_donnee (23) := t_cotis (4);
   o_donnee (24) := t_cotis (5);
   o_donnee (25) := TO_CHAR (PK_devise.f_convert_euro (i_montant => t_cotis (7)), '9G999G999D99' );     -- TLE 15/10/2014 - MERGE SEPA V7 ET EPAI
   o_donnee (26)  := rec_c_adhe_cntrt.mandat;                                                           -- TLE 15/10/2014 - MERGE SEPA V7 ET EPAI
   o_donnee (27)  := rec_c_adhe_cntrt.mandat_maitre;                          -- TLE 15/10/2014 - MERGE SEPA V7 ET EPAI
   /*
   BEGIN -- M0003107 : Welcare Editique FS
   CASE F_Client() -- Gestion de séparateur en fonction du n° de client
   WHEN 11 THEN s_Sepa := CHR(10);
   WHEN 12 THEN s_Sepa := ' avec ';
   ELSE s_Sepa := NULL;
   END CASE;
   O_donnee(26) := PK_ADHESION.F_FORMULE_Option(I_idadhesion,s_Sepa,I_date);
   END;
   */
END Charge_Adhe_Cntrt;
--
-- P_Charge_Contrat--------------------------------------------
--
PROCEDURE P_Charge_Contrat(
      i_numgar IN NUMBER,
      o_donnee OUT PK_texte.donnee)
IS
   CURSOR c_contrat
   IS
      SELECT numgar
       , refcie
       , datsous
       , dateff
       , typgar
       , fract
       , renouv
       , typequit
       , numquerable
       , eche_anniv
       , revision
       , refcie_chapeau
       , type_calc
       , nat_calc
       , gest_prest
       , gest_cotis
       , mregl
       , college
       , type_contrat
       , type_terme
       , arrondi
       , delegataire
       , deleg_prest
       , delai
      FROM contrat
      WHERE numgar = i_numgar;
   rec_c_contrat c_contrat%ROWTYPE;
BEGIN
   OPEN c_contrat;
   FETCH c_contrat INTO rec_c_contrat;
   CLOSE c_contrat;
   o_donnee (1)  := rec_c_contrat.numgar;
   o_donnee (2)  := rec_c_contrat.refcie;
   o_donnee (3)  := d2e (rec_c_contrat.datsous);
   o_donnee (4)  := d2e (rec_c_contrat.dateff);
   o_donnee (5)  := SUBSTR (PK_libelle.f_lib ('TYPG', rec_c_contrat.typgar), 1, 15);
   o_donnee (6)  := SUBSTR (PK_libelle.f_lib ('FRAC', rec_c_contrat.fract), 1, 15);
   o_donnee (7)  := rec_c_contrat.renouv;
   o_donnee (8)  := SUBSTR (PK_libelle.f_lib ('ET_CONT', PK_histo_contrat.f_sel_etat (rec_c_contrat.numgar) ), 1, 15 );
   o_donnee (9)  := SUBSTR (PK_libelle.f_lib ('TYPQ', rec_c_contrat.typequit), 1, 15);
   o_donnee (10) := rec_c_contrat.numquerable;
   o_donnee (11) := TO_CHAR (rec_c_contrat.eche_anniv, 'dd/mm');
   o_donnee (12) := rec_c_contrat.revision;
   o_donnee (13) := rec_c_contrat.refcie_chapeau;
   o_donnee (14) := SUBSTR (PK_libelle.f_lib ('TYPC', rec_c_contrat.type_calc), 1, 15);
   o_donnee (15) := SUBSTR (PK_libelle.f_lib ('NATC', rec_c_contrat.nat_calc), 1, 15);
   o_donnee (16) := SUBSTR (PK_libelle.f_lib ('GESRP', rec_c_contrat.gest_prest), 1, 15);
   o_donnee (17) := SUBSTR (PK_libelle.f_lib ('GESCO', rec_c_contrat.gest_cotis), 1, 15);
   o_donnee (18) := SUBSTR (PK_libelle.f_lib ('MREGL', rec_c_contrat.mregl), 1, 15);
   o_donnee (19) := SUBSTR (PK_libelle.f_lib ('COLLEGE', rec_c_contrat.college), 1, 45);   -- TLE - 22/09/2014 - M4603
   o_donnee (21) := SUBSTR (PK_libelle.f_lib ('TYP_CONT', rec_c_contrat.type_contrat), 1, 15 );
   o_donnee (22) := SUBSTR (PK_libelle.f_lib ('TYPE_TERME', rec_c_contrat.type_terme), 1, 15 );
   o_donnee (23) := SUBSTR (PK_libelle.f_lib ('ARRONDI', rec_c_contrat.arrondi), 1, 15);
   o_donnee (24) := PK_personne.f_nom (rec_c_contrat.delegataire, 32, 1);
   o_donnee (25) := PK_personne.f_nom (rec_c_contrat.deleg_prest, 32, 1);
   o_donnee (26) := rec_c_contrat.delai;
END P_Charge_Contrat;
--
--Procedure charge societe
--
PROCEDURE Charge_Societe(
      a_numindiv IN NUMBER,
      o_donnee OUT PK_texte.donnee)
IS
   CURSOR c_societe
   IS
      SELECT indvs.numindiv
       , indvs.refcie
       , indvs.qualite
       , indvs.codcourrier1
       , indvs.nom
       , indvs.prenom
       , indvs.codpays
       , indvs.tel
       , indvs.fax
       , indvs.email
       , pers_morale.creation
       , pers_morale.siret
       , pers_morale.ape
       , pers_morale.code_naf
       , pers_morale.vip
       , pers_morale.convention
       , pers_morale.potentiel
       , pers_societe.entete
       , pers_societe.abrege
       , pers_societe.lieu
      FROM indvs
       , pers_societe
       , pers_morale
      WHERE indvs.numindiv      = a_numindiv
      AND indvs.numindiv        = pers_morale.numindiv
      AND pers_societe.numindiv = indvs.numindiv;
   rec_c_societe c_societe%ROWTYPE;
BEGIN
   OPEN c_societe;
   FETCH c_societe INTO rec_c_societe;
   CLOSE c_societe;
   o_donnee (1)  := rec_c_societe.numindiv;
   o_donnee (2)  := rec_c_societe.refcie;
   o_donnee (3)  := SUBSTR (PK_libelle.f_lib ('QLTE', rec_c_societe.qualite), 1, 25);
   o_donnee (4)  := SUBSTR (PK_libelle.f_lib ('CODC1', rec_c_societe.codcourrier1), 1, 25 );
   o_donnee (5)  := SUBSTR (PK_personne.f_nom (rec_c_societe.numindiv, 30, 0), 1, 30);
   o_donnee (6)  := SUBSTR (rec_c_societe.nom, 1, 30);
   o_donnee (7)  := SUBSTR (rec_c_societe.prenom, 1, 20);
   o_donnee (8)  := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_societe.numindiv, 0, SYSDATE, 'O', 0 ), 1 );
   o_donnee (9)  := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_societe.numindiv, 0, SYSDATE, 'O', 0 ), 2 );
   o_donnee (10) := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_societe.numindiv, 0, SYSDATE, 'O', 0 ), 3 );
   o_donnee (11) := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_societe.numindiv, 0, SYSDATE, 'O', 0 ), 4 );
   o_donnee (12) := SUBSTR (f_pays (rec_c_societe.codpays), 1, 15);
   o_donnee (13) := rec_c_societe.tel;
   o_donnee (14) := rec_c_societe.fax;
   o_donnee (15) := rec_c_societe.email;
   o_donnee (16) := d2e (rec_c_societe.creation);
   o_donnee (17) := rec_c_societe.siret;
   o_donnee (18) := rec_c_societe.ape;
   o_donnee (19) := rec_c_societe.code_naf;
   o_donnee (20) := rec_c_societe.vip;
   o_donnee (21) := SUBSTR (PK_libelle.f_lib ('CONVENTION', rec_c_societe.convention), 1, 25 );
   o_donnee (22) := SUBSTR (PK_libelle.f_lib ('POTENTIEL', rec_c_societe.potentiel), 1, 25 );
   o_donnee (23) := rec_c_societe.entete;
   o_donnee (24) := rec_c_societe.abrege;
   o_donnee (25) := rec_c_societe.lieu;
   BEGIN
      --ABO 09/12/2013 Récupération de l'ICS, doit être normalement unique pour une société et associé à un compte ouvert en cotisation et prélèvement
      SELECT DISTINCT c.ics
      INTO o_donnee (27)
      FROM type_ope t
       , papier_ope p
       , compte c
      WHERE numope  = 4 --cotisation
      AND t.numcpte = p.numcpte
      AND t.numope  = p.codope
      AND p.modpmt  =2 --prelèvement
      AND t.numcpte =c.numcpte
      AND c.numsoc  =a_numindiv
      and c.ics is not null ; -- SEPA prelevement : ajout MUR le 31/03/2014 suite retour GEREP
   EXCEPTION
   WHEN OTHERS THEN
      o_donnee (27):='';
   END;
END Charge_Societe;
--
-- P_Charge_Pret --------------------------------------------
--
PROCEDURE P_Charge_Pret(
      i_idpret IN pret.idpret%TYPE,
      o_donnee OUT PK_texte.donnee )
IS
   l_numindiv adhe_pret.numindiv%TYPE     := t_cle (4);
   l_idadhesion adhe_pret.idadhesion%TYPE := t_cle (13);
   CURSOR c_pret
   IS
      SELECT idpret
       , preteur
       , situation
       , type_pret
       , nature_pret
       , duree_pret
       , duree_differe
       , montant
       , devise
       , numutil
       , date_signature
       , date_deblocage
       , ref_ext
      FROM pret
      WHERE idpret = i_idpret;
   CURSOR c_adhe_pret
   IS
      SELECT adhe_pret.pourc_assure
       , adhe_pret.majoration
       , adhe_pret.type_adresse
       , adhe_pret.idarchive
       , adhe_cntrt.delai
      FROM adhe_cntrt
       , adhe_pret
      WHERE adhe_cntrt.idadhesion = adhe_pret.idadhesion
      AND adhe_pret.idadhesion    = l_idadhesion;
   CURSOR c_bene
   IS
      SELECT numbene
      FROM beneficiaire
      WHERE idadhesion = l_idadhesion
      AND numindiv     = l_numindiv
      AND type_bene   != 0
      AND valide       = 'O';

   CURSOR c_cotis
   IS
   SELECT facture.montant
    , qttc_global.debut
    , qttc_global.fin
   FROM facture
    , qttc_global
    , adhe_cntrt
   WHERE adhe_cntrt.idadhesion = l_idadhesion
   AND facture.codope          = 4
   AND facture.numfact         = qttc_global.numquit
   AND qttc_global.idadhesion  = adhe_cntrt.idadhesion
   AND NOT EXISTS (SELECT 1 FROM facture_annul WHERE qttc_global.numquit = facture_annul.numfact AND facture_annul.codope = 4)
   AND qttc_global.COMPTANT   != 'R'
   AND TRUNC(comm_date_debut) BETWEEN TRUNC(qttc_global.debut) AND TRUNC(qttc_global.fin)
   ORDER BY debut DESC;

   CURSOR c_interm
   IS
   SELECT apporteur.numindiv, pers_banque.guichet
   FROM apporteur, pers_banque
   WHERE type_interm = 2
   AND apporteur.cle = l_idadhesion
   AND TRUNC(comm_date_debut) BETWEEN TRUNC(apporteur.debut) AND TRUNC(NVL(apporteur.fin, comm_date_debut ))
   AND apporteur.numindiv = pers_banque.numindiv
   ORDER BY debut DESC;

   rec_c_pret c_pret%ROWTYPE;
   rec_c_adhe_pret c_adhe_pret%ROWTYPE;
   l_numbene beneficiaire.numbene%TYPE;
   rec_c_cotis c_cotis%ROWTYPE;
   rec_c_interm c_interm%ROWTYPE;
   l_montant   NUMBER;
   l_idadresse NUMBER;
   l_fin_pret DATE;
   l_fin_prelev DATE;
   t_bene PK_texte.donnee;
BEGIN
   OPEN c_pret;
   FETCH c_pret INTO rec_c_pret;
   CLOSE c_pret;
   OPEN c_adhe_pret;
   FETCH c_adhe_pret INTO rec_c_adhe_pret;
   CLOSE c_adhe_pret;
   OPEN c_bene;
   FETCH c_bene INTO l_numbene;
   CLOSE c_bene;
   l_montant     := PK_pret.f_mt_assure (a_idpret => i_idpret, a_numindiv => l_numindiv);
   l_fin_pret    := PK_pret.f_fin_pret (a_idpret => i_idpret);
   l_fin_prelev  := TRUNC (l_fin_pret, 'Q') + rec_c_adhe_pret.delai - 1;
   l_idadresse   := PK_personne.f_idadresse (l_numbene, 0, SYSDATE, 'O', 0);
   o_donnee (1)  := rec_c_pret.idpret;
   o_donnee (2)  := rec_c_pret.ref_ext;
   o_donnee (3)  := rec_c_adhe_pret.idarchive;
   o_donnee (4)  := TO_CHAR (l_montant, '9G999G999D99');
   o_donnee (5)  := PK_devise.symbole (a_codmon => rec_c_pret.devise);
   o_donnee (6)  := PK_libelle.f_lib ('TYP_PRET', rec_c_pret.type_pret);
   o_donnee (7)  := PK_libelle.f_lib ('NAT_PRET', rec_c_pret.nature_pret);
   o_donnee (8)  := rec_c_pret.duree_pret;
   o_donnee (9)  := rec_c_pret.duree_differe;
   o_donnee (10) := d2e (rec_c_pret.date_signature);
   o_donnee (11) := d2e (rec_c_pret.date_deblocage);
   o_donnee (12) := f_nomutil (rec_c_pret.numutil, 2);
   o_donnee (13) := d2e (l_fin_pret);
   o_donnee (14) := d2e (l_fin_prelev);
   o_donnee (15) := SUBSTR (PK_personne.f_nom (l_numbene, 30, 0), 1, 30);
   o_donnee (16) := PK_personne.f_adresse (l_idadresse, 1, l_numbene);
   o_donnee (17) := PK_personne.f_adresse (l_idadresse, 2, l_numbene);
   o_donnee (18) := PK_personne.f_adresse (l_idadresse, 3, l_numbene);
   o_donnee (19) := PK_personne.f_adresse (l_idadresse, 4, l_numbene);
   o_donnee (20) := TO_CHAR( Rec_C_pret.montant, '9G999G999D99');
   o_donnee (21) := (Rec_C_pret.duree_pret + Rec_C_pret.duree_differe) || ' Mois';
   o_donnee (22) := Rec_C_adhe_pret.pourc_assure || ' %';

-- PHA 09/11/2016 M0005191
-- 0005191: Aménagement Certificats assurance reactualise : ajout données 23 à 31
   o_donnee (23) := d2e(comm_date_debut);
   BEGIN
     OPEN c_interm;
     FETCH c_interm INTO rec_c_interm;
     CLOSE c_interm;
     o_donnee (24) := SUBSTR (PK_personne.f_nom (rec_c_interm.numindiv, 30, 0), 1, 30);
     o_donnee (25) := rec_c_interm.guichet;
     o_donnee (26) := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_interm.numindiv, 0, SYSDATE, 'O', 0 ), 1 );
     o_donnee (27) := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_interm.numindiv, 0, SYSDATE, 'O', 0 ), 2 );
     o_donnee (28) := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_interm.numindiv, 0, SYSDATE, 'O', 0 ), 3 );
     o_donnee (29) := PK_personne.f_adresse (PK_personne.f_idadresse (rec_c_interm.numindiv, 0, SYSDATE, 'O', 0 ), 4 );
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     o_donnee (24) := ' ';
     o_donnee (25) := ' ';
     o_donnee (26) := ' ';
     o_donnee (27) := ' ';
     o_donnee (28) := ' ';
     o_donnee (29) := ' ';
   END;

   IF l_montant = 0 THEN
     o_donnee (30) := ' ';
     o_donnee (31) := ' ';
   ELSE
     BEGIN

       OPEN c_cotis;
       FETCH c_cotis INTO rec_c_cotis;
       CLOSE c_cotis;


      -- o_donnee (30)  montant de cotisation restant
      -- o_donnee (31)  taux de cotisation assurance
      SELECT ROUND(( ( Tcotisation.M3 * rec_c_cotis.montant ) + ( ( Tcotisation.M2 / Tcotisation.M1)  * rec_c_cotis.montant ) ), 2)
           , TO_CHAR( ROUND( ((rec_c_cotis.montant*12/Tcotisation.M1) / l_montant) * 100 , 2 ) ,'FM99990.00' ) || ' %'
      INTO o_donnee (30), o_donnee (31)
      FROM (
            SELECT T1.M1, MOD(MONTHS_BETWEEN( l_fin_pret+1 , comm_date_debut ), T1.M1 ) M2 ,
                   (MONTHS_BETWEEN( l_fin_pret+1 , comm_date_debut ) -
                   MOD(MONTHS_BETWEEN( l_fin_pret+1 , comm_date_debut ), T1.M1) ) / T1.M1 M3
            FROM ( SELECT MONTHS_BETWEEN( rec_c_cotis.fin+1 , rec_c_cotis.debut ) M1 FROM dual ) T1
           ) Tcotisation;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       o_donnee (30) := ' ';
       o_donnee (31) := ' ';
     END;
   END IF;

END P_Charge_Pret;
--
-- -- P_Charge_AdheColl --------------------------------------------
--
PROCEDURE P_Charge_AdheColl(
      i_numgar IN NUMBER,
      o_donnee OUT PK_texte.donnee )
IS
   CURSOR c_adhec
   IS
      SELECT numgar
       , refcie
       , datsous
       , dateff
       , typgar
       , fract
       , renouv
       , typequit
       , numquerable
       , eche_anniv
       , revision
       , refcie_chapeau
       , type_calc
       , nat_calc
       , gest_prest
       , gest_cotis
       , mregl
       , college
       , type_contrat
       , type_terme
       , arrondi
       , delegataire
       , deleg_prest
       , delai
       , numgar_ref
      FROM contrat
      WHERE numgar = i_numgar;
   rec_c_adhec c_adhec%ROWTYPE;
BEGIN
   OPEN c_adhec;
   FETCH c_adhec INTO rec_c_adhec;
   CLOSE c_adhec;
   o_donnee(1)  := rec_c_adhec.numgar;
   o_donnee(2)  := rec_c_adhec.refcie;
   o_donnee(3)  := d2e (rec_c_adhec.datsous);
   o_donnee(4)  := d2e (rec_c_adhec.dateff);
   o_donnee(5)  := SUBSTR (PK_libelle.f_lib ('TYPG', rec_c_adhec.typgar), 1, 15);
   o_donnee(6)  := SUBSTR (PK_libelle.f_lib ('FRAC', rec_c_adhec.fract), 1, 15);
   o_donnee(7)  := rec_c_adhec.renouv;
   o_donnee(8)  := SUBSTR (PK_libelle.f_lib ('ET_CONT', PK_histo_contrat.f_sel_etat (rec_c_adhec.numgar) ), 1, 15 );
   o_donnee(9)  := SUBSTR (PK_libelle.f_lib ('TYPQ', rec_c_adhec.typequit), 1, 15);
   o_donnee(10) := rec_c_adhec.numquerable;
   o_donnee(11) := TO_CHAR (rec_c_adhec.eche_anniv, 'dd/mm');
   o_donnee(12) := rec_c_adhec.revision;
   o_donnee(13) := rec_c_adhec.refcie_chapeau;
   o_donnee(14) := SUBSTR (PK_libelle.f_lib ('TYPC', rec_c_adhec.type_calc), 1, 15);
   o_donnee(15) := SUBSTR (PK_libelle.f_lib ('NATC', rec_c_adhec.nat_calc), 1, 15);
   o_donnee(16) := SUBSTR (PK_libelle.f_lib ('GESRP', rec_c_adhec.gest_prest), 1, 15);
   o_donnee(17) := SUBSTR (PK_libelle.f_lib ('GESCO', rec_c_adhec.gest_cotis), 1, 15);
   o_donnee(18) := SUBSTR (PK_libelle.f_lib ('MREGL', rec_c_adhec.mregl), 1, 15);
   o_donnee(19) := SUBSTR (PK_libelle.f_lib ('COLLEGE', rec_c_adhec.college), 1, 15);
   o_donnee(21) := SUBSTR (PK_libelle.f_lib ('TYP_CONT', rec_c_adhec.type_contrat), 1, 15 );
   o_donnee(22) := SUBSTR (PK_libelle.f_lib ('TYPE_TERME', rec_c_adhec.type_terme), 1, 15 );
   o_donnee(23) := SUBSTR (PK_libelle.f_lib ('ARRONDI', rec_c_adhec.arrondi), 1, 15);
   o_donnee(24) := PK_personne.f_nom (rec_c_adhec.delegataire, 32, 1);
   o_donnee(25) := PK_personne.f_nom (rec_c_adhec.deleg_prest, 32, 1);
   o_donnee(26) := rec_c_adhec.delai;
   o_donnee(27) := rec_c_adhec.numgar_ref;
END P_Charge_AdheColl;
-- M0003279 : Mise en place des variable spécifique en fonction du client
PROCEDURE P_Charge_Specif(
      i_EntiteLogique IN NUMBER,
      i_Clef          IN Pk_Texte.Clefs,
      i_Date          IN DATE DEFAULT SYSDATE,
      o_Donnee OUT PK_texte.donnee )
IS
BEGIN
   CASE i_EntiteLogique -- F_Client() + 100
   WHEN 111 THEN
      o_Donnee(1) := PK_LIBELLE.F_LIB('PSIADHPROF',TO_NUMBER(VAL_VAR(F_IDVARIABLE('PSIADHPROF'),i_Clef(0),NVL(i_Date,SYSDATE)))); -- SMI : Contrat PSI - Profession /Adhésion
      -- VDA :
      /*
      o_Donnee(2) := PK_FUNCT.F_TAB1(PK_FUNCT.F_TAB('PSIPRESTDC'),i_Clef(0),NVL(i_Date,SYSDATE)))); -- SMI : Contrat PSI - Montant Versement Capital
      o_Donnee(3) := PK_FUNCT.F_TAB1(PK_FUNCT.F_TAB('PSIPRESTIJ'),i_Clef(0),NVL(i_Date,SYSDATE)))); -- SMI : Contrat PSI - Indémnité Journalière
      o_Donnee(4) := PK_FUNCT.F_TAB1(PK_FUNCT.F_TAB('PSIPRESTPD'),i_Clef(0),NVL(i_Date,SYSDATE)))); -- SMI : Contrat PSI - Nb. Jours de Franchise ?!
      */
   ELSE
      NULL;
   END CASE;
END P_Charge_Specif;
--
-- ------------------------------------ Fin des corps des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
FUNCTION F_Eval_Variable(
      a_nom_variable IN VARCHAR2,
      a_contexte     IN NUMBER,
      a_cle          IN NUMBER,
      a_format       IN NUMBER DEFAULT 2,
      a_debut        IN DATE DEFAULT NULL,
      a_fin          IN DATE DEFAULT NULL )
   RETURN VARCHAR2
IS
   loc_retour       VARCHAR2 (40) := '0';
   loc_idvariable   NUMBER;
   loc_lib_variable VARCHAR2 (40);
   loc_etendue      NUMBER;
   loc_statique     NUMBER;
   flag_lib         NUMBER;
   loc_type         VARCHAR2 (1);
   CURSOR fetch_variable
   IS
      SELECT val_variable.valeur
       , val_variable.debut
       , val_variable.fin
       , val_variable.numgar
       , TO_CHAR (val_variable.debut, 'dd/mm/yy') edebut
       , TO_CHAR (val_variable.fin, 'dd/mm/yy') efin
       , def_variable.STATIQUE
      FROM val_variable
       , def_variable
      WHERE ( (val_variable.clef  = NVL (t_cle_passage (1), t_cle (loc_etendue)) )
      OR (val_variable.clef       = t_cle (12)
      AND loc_etendue             = 12)
      OR (comm_contexte           = 14
      AND val_variable.clef       = t_cle (0)) )
      AND val_variable.idvariable = loc_idvariable
      AND def_variable.idvariable = val_variable.idvariable
      ORDER BY debut DESC;
   val_var fetch_variable%ROWTYPE;
BEGIN
   IF ((comm_contexte != a_contexte) OR (comm_cle != a_cle)) THEN
      PK_Texte.Charge_Cle (a_contexte, a_cle);
   END IF;
   BEGIN
      SELECT idvariable
       , etendue
       , DECODE (statique, 'O', 1, 0)
       , TYPE
       , DECODE (nomenclature, 'O', 1, 0)
       , lib_variable
      INTO loc_idvariable
       , loc_etendue
       , loc_statique
       , loc_type
       , flag_lib
       , loc_lib_variable
      FROM def_variable
      WHERE nom_variable = a_nom_variable;
      IF (a_format       = 1) THEN
         RETURN loc_lib_variable;
      END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 'Inexistante';
   END;
   IF (a_debut   IS NOT NULL) THEN
      comm_debut := a_debut;
   END IF;
   IF (a_fin   IS NOT NULL) THEN
      comm_fin := a_fin;
   END IF;
   FOR val_var IN fetch_variable
   LOOP
      /*   IF (val_var.debut BETWEEN comm_debut
      AND NVL (val_var.fin, val_var.debut ) )
      correctif 19/10/2012 PHA*/
      --loc_retour :=  TO_CHAR (comm_debut, 'dd/mm/yyyy hh:mi:ss'); exit;
      -- comm_debut:=NULL;
      --05/12/2013 PHA pour les variables calculées,
      -- on prend systématiquement la dernière valeur (car non historisée)
      --IF ((NVL(comm_debut, val_var.debut) BETWEEN val_var.debut AND NVL (val_var.fin, NVL(comm_debut, val_var.debut) ) ) OR val_var.STATIQUE = 'C' OR (comm_date_debut IS NOT NULL AND comm_date_debut BETWEEN val_var.debut AND NVL (val_var.fin, comm_date_debut))) THEN
      IF ((val_var.debut BETWEEN NVL(comm_debut, val_var.debut) AND NVL (val_var.fin, val_var.debut ) ) OR (NVL(comm_debut, val_var.debut) BETWEEN val_var.debut AND NVL (val_var.fin, NVL(comm_debut, val_var.debut) ) ) OR val_var.STATIQUE = 'C' OR (comm_date_debut IS NOT NULL AND comm_date_debut BETWEEN val_var.debut AND NVL (val_var.fin, comm_date_debut))) THEN
         IF ( ((val_var.numgar = t_cle (2)) AND (t_cle (2) != 0)) OR (val_var.numgar IS NULL) ) THEN
            SELECT DECODE (a_format, 2, val_var.valeur, 3, DECODE (loc_type, 'N', TO_CHAR (TO_NUMBER (val_var.valeur,'999999999D999999','NLS_NUMERIC_CHARACTERS = ''.,'''), '999999999.90' ), val_var.valeur ), 4, DECODE (flag_lib, 1, PK_libelle.f_lib (a_nom_variable, TO_NUMBER (val_var.valeur) ), val_var.valeur ), 5, val_var.edebut, 6, val_var.efin, 7, DECODE (loc_type, 'N', TO_CHAR (
               f_convert_montant (TO_NUMBER (val_var.valeur,'999999999D999999','NLS_NUMERIC_CHARACTERS = ''.,'''), prmt.dfdev, prmt.dfsoc, SYSDATE ), '9999999990.90' ) ), val_var.valeur )
            INTO loc_retour
            FROM prmt;
            EXIT;
         END IF;
      END IF;
   END LOOP;
   RETURN (loc_retour);
END F_Eval_Variable;
--
--- -- F_Eval_Donnee --------------------------------------------
--
FUNCTION F_Eval_Donnee(
      a_type_donnee IN NUMBER,
      a_id_donnee   IN NUMBER,
      a_contexte    IN NUMBER,
      a_cle         IN NUMBER )
   RETURN VARCHAR2
IS
   loc_idrib NUMBER;
BEGIN
   IF ((comm_contexte != a_contexte) OR (comm_cle != a_cle)) THEN
      PK_Texte.Charge_Cle (a_contexte, a_cle);
   END IF;
   --SDA M0003400 Rib + PHA M0003790: Tous courriers anomalie lorsque le t_cle(13) ne correspond pas à un idadhésion
   --PHA M0004290: EDITIQUE : données ICD RUM et RIB non conformes prendre le quérable si il existe 03/01/2014
   BEGIN
      loc_idrib    := g_idrib;
      IF t_cle(13) IS NOT NULL THEN
         SELECT PK_treso.f_idrib(NVL(qg.numquerable,adhe_cntrt.numadhe),2,0,adhe_cntrt.numgar,comm_date_debut,adhe_cntrt.idadhesion)
         INTO g_idrib
         FROM adhe_cntrt
         LEFT OUTER JOIN
            (SELECT idadhesion
             , numquerable
            FROM qttc_global
            WHERE idadhesion = t_cle (13)
            AND debut        =
               (SELECT MIN(debut)
               FROM qttc_global
               WHERE idadhesion = t_cle (13)
               AND debut        > comm_date_debut
               )
            ) qg
         ON adhe_cntrt.idadhesion    = qg.idadhesion
         WHERE adhe_cntrt.idadhesion = t_cle (13);
      END IF;
   EXCEPTION
   WHEN OTHERS THEN
      g_idrib := loc_idrib;
   END;
   CASE t_cle_base(a_type_donnee) -- Entité Logique
   WHEN 0 THEN
      PK_Texte.Charge_Indvs (i_numindiv => t_cle (a_type_donnee), o_donnee => t_donnee );
   WHEN 2 THEN
      PK_Texte.P_Charge_Contrat (i_numgar => PK_qttc.f_sel_numgar (t_cle (a_type_donnee) ), o_donnee => t_donnee );
   WHEN 3 THEN
      Charge_Souscr (t_cle (a_type_donnee), g_idrib, t_donnee);
   WHEN 5 THEN
      Charge_Orgns (t_cle (a_type_donnee), t_donnee);
   WHEN 6 THEN
      Charge_Tiers (t_cle (a_type_donnee), t_donnee);
   WHEN 7 THEN
      Charge_Produit (t_cle (a_type_donnee), t_donnee);
   WHEN 8 THEN
      Charge_Interm (t_cle (a_type_donnee), t_donnee);
   WHEN 9 THEN
      PK_Texte.Charge_Societe (t_cle (a_type_donnee), t_donnee);
   WHEN 13 THEN
      PK_Texte.Charge_Adhe_Cntrt (i_idadhesion => t_cle (a_type_donnee),i_date => comm_date_debut, o_donnee => t_donnee );
   WHEN 14 THEN
      Charge_Prospect (t_cle (a_type_donnee), t_donnee);
   WHEN 15 THEN
      Charge_Prev (t_cle (a_type_donnee), t_donnee);
   WHEN 16 THEN
      Charge_Prest (t_cle (a_type_donnee),comm_cle1,comm_codfrais,comm_date_debut,comm_date_fin,t_donnee );
   WHEN 18 THEN
      Charge_Cotisation (t_cle (a_type_donnee),comm_date_debut,comm_date_fin,t_donnee );
   WHEN 19 THEN
      PK_Texte.Charge_Prch (t_cle (a_type_donnee), t_donnee);
   WHEN 24 THEN
      t_cle_passage(1) := comm_cle1;
      Charge_Membre (t_cle_passage, t_donnee);
   WHEN 25 THEN
      Charge_Adhesion (t_cle_passage, t_donnee);
   WHEN 33 THEN
      Charge_Cotisation_Gar (t_cle_passage, comm_contexte_init, t_donnee);
   WHEN 36 THEN
      Charge_Frais (t_cle_passage, t_donnee);
   WHEN 37 THEN
      Charge_Echeancier (t_cle_passage, t_donnee);
   WHEN 43 THEN
      Charge_Garantie (t_cle (a_type_donnee), t_donnee);
   WHEN 46 THEN
      Charge_Decla (t_cle (a_type_donnee), t_cle (2),comm_date_debut,comm_date_fin,t_donnee );
   WHEN 47 THEN
      Charge_Parametres (a_cle,comm_contexte_init,comm_cle2,comm_numenvoi,comm_idtexte,comm_numutil,t_donnee );
   WHEN 49 THEN
      Charge_Relance (t_cle(18), g_mregl, comm_idtexte, t_donnee);
   WHEN 50 THEN
      Charge_Indice (comm_date_debut, comm_date_fin,comm_cle2,t_donnee);
   WHEN 51 THEN
      Charge_Sntrprt (comm_cle1, comm_cle2, t_donnee);
   WHEN 53 THEN
      Charge_Decaismt (t_cle (a_type_donnee), t_donnee);
   WHEN 54 THEN
      Charge_Encaismt (t_cle (a_type_donnee), t_donnee);
   WHEN 55 THEN
      Charge_Dette (t_cle (a_type_donnee), t_donnee);
   WHEN 57 THEN
      PK_Texte.P_Charge_Pret (i_idpret => t_cle (a_type_donnee),o_donnee => t_donnee );
   WHEN 59 THEN
      Charge_Dsante (t_cle (a_type_donnee), t_donnee); -- David 17/11/2004 Ajout Dossier soins de sante
   WHEN 60 THEN
      P_Charge_AdheColl (i_numgar => t_cle (2), o_donnee => t_donnee); -- JPF ajout adhesion collective 19/04/2005 -- JPF mis 2 pour numgar au lieu de a_type_donnee  05/07/2005
   ELSE
      PK_Texte.P_Charge_Specif(t_cle_base(a_type_donnee), t_cle_passage, NULL, t_donnee);
   END CASE;
   RETURN NVL(t_donnee (a_id_donnee), ' ');
END F_Eval_Donnee;
-- David 31/01/2005 modif loc_texte varchar2(100);
--
---- F_Decode_Texte--------------------------------------------
--
FUNCTION F_Decode_Texte(
      a_texte         IN VARCHAR2,
      a_contexte      IN NUMBER,
      a_contexte_base IN NUMBER,
      a_cle           IN NUMBER DEFAULT 0,
      a_niveau        IN NUMBER,
      a_nombre        IN NUMBER DEFAULT 1,
      a_test          IN NUMBER DEFAULT 1,
      a_cle1          IN NUMBER DEFAULT 0,
      a_debut         IN DATE DEFAULT SYSDATE,
      a_fin           IN DATE DEFAULT SYSDATE,
      a_cle2          IN NUMBER DEFAULT 0,
      a_idtexte       IN NUMBER DEFAULT 0,
      a_numenvoi      IN NUMBER DEFAULT 0,
      a_numutil       IN NUMBER DEFAULT f_numutil,
      a_codfrais      IN VARCHAR2 DEFAULT NULL )
   RETURN VARCHAR2
AS
   loc_texte VARCHAR2(4000);
   l_found   BOOLEAN := TRUE;
BEGIN
   loc_texte          := a_texte;
   comm_contexte_init := a_contexte;
   comm_test          := a_test;
   comm_cle1          := a_cle1;
   comm_cle2          := a_cle2;
   comm_date_debut    := a_debut;
   comm_date_fin      := a_fin;
   comm_idtexte       := a_idtexte;
   comm_numutil       := a_numutil;
   comm_numenvoi      := a_numenvoi;
   comm_codfrais      := a_codfrais;
   t_contexte (0)     := f_cle_phys (a_contexte_base);
   t_cle_primaire (0) := a_cle;
   t_cle_primaire (1) := NULL;
   t_cle_primaire (2) := NULL;
   t_cle_passage (0)  := a_cle;
   t_cle_passage (1)  := NULL;
   t_cle_passage (2)  := NULL;
   --pk_trace.p_ins_journal_adm('TEXTE',1,1,'comm_date_debut :'||comm_date_debut,sysdate); mise en commentaire MUR le 02/04/2014
   IF (a_niveau        > 0) THEN
      PK_boucle.charge_boucle (PK_texte.t_cle_primaire, f_cle_phys (a_contexte), a_contexte, PK_texte.t_donnee, comm_retour );
      IF (comm_retour        = 'fin_boucle') THEN
         l_found            := FALSE;
         loc_texte          := 'Retour PK_boucle.charge_boucle ';
      ELSIF (a_niveau        = 1) THEN
         t_cle_passage (1)  := t_donnee (1);
         t_cle_primaire (1) := t_donnee (1);
      ELSIF (a_niveau        = 2) THEN
         t_cle_passage (2)  := t_donnee (2);
         t_cle_primaire (2) := t_donnee (2);
      END IF;
   END IF;
   WHILE (l_found)
   LOOP
      PK_texte.Charge_Donnee (a_texte => loc_texte, a_contexte_base => a_contexte_base, a_cle => a_cle, o_texte_decode => loc_texte, o_found => l_found );
   END LOOP;
   --Remplacement du caractère _ par des espaces
   --loc_texte := REPLACE(loc_texte,'_',' ');
   IF LENGTH(TRIM(TRANSLATE(REPLACE(loc_texte, '_',''), ' +-.0123456789',' '))) IS NULL THEN
      loc_texte                                                                 := REPLACE(loc_texte,'_','');
   ELSE
      loc_texte := REPLACE(loc_texte,'_',' ');
   END IF;
   --Remplacement du caractère ¤ par un retour chariot
   loc_texte := REPLACE(loc_texte,'¤',CHR(10));
   RETURN loc_texte;
END F_Decode_Texte;
--
----  PK_Texte.Charge_Prch --------------------------------------------
--
PROCEDURE Charge_Prch(
      a_numpc IN NUMBER,
      t_donnee OUT PK_texte.donnee)
IS

  CURSOR c_def (i_numindiv IN NUMBER, i_datehospi IN DATE)
      IS
  SELECT distinct seq.def
    FROM calcul calcul_cp
     , porte_natfrais porte_natfrais_cp
     , seqrub seq
     , adhesion a
   WHERE porte_natfrais_cp.numporte       = 0
     AND calcul_cp.codfrais               = porte_natfrais_cp.codfrais
     AND porte_natfrais_cp.codfrais_porte in('SHO','FJ')
     AND calcul_cp.numfor                 = a.numfor
     AND i_datehospi BETWEEN calcul_cp.datapli AND NVL (calcul_cp.datper, i_datehospi)
     AND seq.numfor = a.numfor
     AND seq.codfrais = porte_natfrais_cp.codfrais
     AND a.numindiv= i_numindiv
     AND F_ETAT_ADHE(a.idadhesion, i_datehospi)=1
     AND i_datehospi BETWEEN a.datapli AND NVL (a.datper, i_datehospi)
     AND a.etat =1 
     order by seq.def;


  rec_c_def            c_def%ROWTYPE;
  loc_numindiv         PRCH.NUMINDIV%TYPE:=0;
  loc_numfor           PRCH.NUMFOR%TYPE:=0;
  loc_datehospi        PRCH.DATEHOSPI%TYPE:=NULL;

BEGIN

   SELECT prch.numpc
    , prch.numindiv
    , prch.numassu
    , prch.numtiers
    , d2e (prch.datehospi)
    , SUBSTR (PK_libelle.f_lib ('DESTI', prch.typedest), 1, 15)
    , prch.numentree
    , prch.numfact
    , ind (calcul_cp.x, prch.datehospi)
    , f_conso_reste (prch.numfor, prch.numindiv, porte_natfrais_cp.codfrais, prch.datehospi )
    , ind (calcul_fj.x, prch.datehospi)
    , f_conso_reste (prch.numfor, prch.numindiv, porte_natfrais_fj.codfrais, prch.datehospi )
    , TO_CHAR (prch.datehospi, 'yyyy')
   INTO t_donnee (1)
      , t_donnee (2)
      , t_donnee (3)
      , t_donnee (4)
      , t_donnee (5)
      , t_donnee (6)
      , t_donnee (7)
      , t_donnee (8)
      , t_donnee (9)
      , t_donnee (10)
      , t_donnee (11)
      , t_donnee (12)
      , t_donnee (14)
   FROM prch
    , calcul calcul_cp
    , calcul calcul_fj
    , porte_natfrais porte_natfrais_cp
    , porte_natfrais porte_natfrais_fj
   WHERE prch.numpc                     = a_numpc
   AND porte_natfrais_cp.numporte       = 0
   AND calcul_cp.codfrais               = porte_natfrais_cp.codfrais
   AND porte_natfrais_cp.codfrais_porte = 'SHO'
   AND calcul_cp.numfor                 = prch.numfor
   AND prch.datehospi BETWEEN calcul_cp.datapli AND NVL (calcul_cp.datper, prch.datehospi)
   AND porte_natfrais_fj.numporte       = 0
   AND calcul_fj.codfrais               = porte_natfrais_fj.codfrais
   AND porte_natfrais_fj.codfrais_porte = 'FJ'
   AND prch.datehospi BETWEEN calcul_fj.datapli AND NVL (calcul_fj.datper, prch.datehospi)
   AND calcul_fj.numfor = prch.numfor
   UNION
   SELECT prch.numpc
    , prch.numindiv
    , prch.numassu
    , prch.numtiers
    , d2e (prch.datehospi)
    , SUBSTR (PK_libelle.f_lib ('DESTI', prch.typedest), 1, 15)
    , prch.numentree
    , prch.numfact
    , 0
    , 0
    , 0
    , 0
    , TO_CHAR (prch.datehospi, 'yyyy')
   FROM prch
   WHERE prch.numpc = a_numpc
   AND NOT EXISTS
      (SELECT 1
      FROM calcul calcul_cp
       , calcul calcul_fj
       , porte_natfrais porte_natfrais_cp
       , porte_natfrais porte_natfrais_fj
      WHERE prch.numpc                     = a_numpc
      AND porte_natfrais_cp.numporte       = 0
      AND calcul_cp.codfrais               = porte_natfrais_cp.codfrais
      AND porte_natfrais_cp.codfrais_porte = 'SHO'
      AND calcul_cp.numfor                 = prch.numfor
      AND prch.datehospi BETWEEN calcul_cp.datapli AND NVL (calcul_cp.datper, prch.datehospi )
      AND porte_natfrais_fj.numporte       = 0
      AND calcul_fj.codfrais               = porte_natfrais_fj.codfrais
      AND porte_natfrais_fj.codfrais_porte = 'FJ'
      AND prch.datehospi BETWEEN calcul_fj.datapli AND NVL (calcul_fj.datper, prch.datehospi )
      AND calcul_fj.numfor = prch.numfor
      );


--- faire une requete: qui recupére ses infos
    -- nuindiv
    -- numfor
      --  ==> rajouter un union en passant les 2 infos en paramétre du curseur avec la condition ci-dessous:
        -- recupéréer ensuite adhésion valide avec numfor différent du numofor ci-dessus récupérer
  SELECT numindiv,p.datehospi
    INTO loc_numindiv, loc_datehospi
    FROM prch p
   WHERE p.numpc=a_numpc;
  t_donnee (15) :='';
  FOR rec_def IN   c_def(loc_numindiv, loc_datehospi) LOOP
    t_donnee (15) :=  t_donnee (15) ||'- '|| rec_def.def || CHR(10);
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Charge_Prch;
-- ---------------------------------- Fin des corps des procedures publiques --
END PK_TEXTE;
/
