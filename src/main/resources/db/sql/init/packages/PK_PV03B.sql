CREATE OR REPLACE PACKAGE ARTHUS."PK_PV03B"
AS
--
   PROCEDURE p_pv03b (
      i_deb_numsoc     IN       vs_compte.numsoc%TYPE DEFAULT NULL,
      i_fin_numsoc     IN       vs_compte.numsoc%TYPE DEFAULT NULL,
      i_deb_numcpte    IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_fin_numcpte    IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_deb_echeance   IN       VARCHAR2 DEFAULT NULL,
      i_fin_echeance   IN       VARCHAR2 DEFAULT NULL,
      i_session        IN       NUMBER DEFAULT 1,
      i_niv_msg        IN       NUMBER DEFAULT 1,
      i_pause          IN       NUMBER DEFAULT 0,
      o_found          OUT      NUMBER,
      o_erreur         OUT      VARCHAR2
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

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_PV03B"
AS
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
   PROCEDURE p_sel_trav_ano;

--
   PROCEDURE p_fin_traitement;

--
   PROCEDURE p_corps_sel_numcpte;

--
   PROCEDURE p_select_facture;

--
   PROCEDURE p_sel_trav_prelevement;

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
--
   g_lib_ano                   VARCHAR2 (78);
   g_contrat_numgar            NUMBER (10);
   g_facture_codope            NUMBER (3);
   g_facture_numfact           NUMBER (10);
   g_facture_numcli            NUMBER (10);
   g_facture_montant           NUMBER (10, 2);
   g_codbque                   VARCHAR2 (5);
   g_guichet                   VARCHAR2 (5);
   g_compte                    VARCHAR2 (11);
   g_clerib                    VARCHAR2 (2);
   g_intitule                  VARCHAR2 (30);
   g_idrib                     NUMBER (9);
   g_idadhesion                NUMBER (10);
   g_bban                      VARCHAR2(30);
   g_clef_iban                 VARCHAR2(4);
   g_bic                       VARCHAR2(11);

   -- Variables globales priv¿es
--
   g_numremise                 prelevement.numremise%TYPE;
   g_numprelev                 prelevement.numprelev%TYPE;
   g_numsoc                    vs_compte.numsoc%TYPE;
   g_numcpte                   vs_compte.numcpte%TYPE;
   g_idaffec                   compte_client.idaffec%TYPE;
   g_codope                    compte_client.codope%TYPE;
   g_numcli                    compte_client.numcli%TYPE;
   g_numencaismt               compte_client.numencaismt%TYPE;
   g_monnaie                   compte_client.monnaie%TYPE;
   g_datope                    compte_client.datope%TYPE;
   g_montant                   compte_client.montant%TYPE;
   g_numfact                   compte_client.numfact%TYPE;
   g_idcompta                  compte_client.idcompta%TYPE;
   g_datrem                    remise_prelev.datrem%TYPE;
   g_nombre                    remise_prelev.nombre%TYPE;
   g_valide                    remise_prelev.valide%TYPE;
--
-- parametres du traitement
   g_numsoc_deb                vs_compte.numsoc%TYPE;
   g_numsoc_fin                vs_compte.numsoc%TYPE;
   g_numcpte_deb               vs_compte.numcpte%TYPE;
   g_numcpte_fin               vs_compte.numcpte%TYPE;
   g_echeance_deb              facture.echeance%TYPE;
   g_echeance_fin              facture.echeance%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                           := FALSE;
   g_rollback                  BOOLEAN                           := FALSE;
   g_auto_valide               BOOLEAN                           := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                           DEFAULT 'pk_PV03B';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
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
   CURSOR c_sel_numcpte
   IS
      SELECT vs_compte.numsoc, vs_compte.numcpte
        FROM vs_compte
       WHERE vs_compte.numsoc BETWEEN NVL (g_numsoc_deb, vs_compte.numsoc)
                                  AND NVL (g_numsoc_fin,
                                           NVL (g_numsoc_deb,
                                                vs_compte.numsoc)
                                          )
         AND vs_compte.numcpte BETWEEN NVL (g_numcpte_deb, vs_compte.numcpte)
                                   AND NVL (g_numcpte_fin,
                                            NVL (g_numcpte_deb,
                                                 vs_compte.numcpte
                                                )
                                           );

--
   CURSOR c_select_facture
   IS
      SELECT facture.numfact, facture.montant, facture.codope, facture.numcli,
             contrat.numgar, qttc_global.idadhesion
        FROM contrat, qttc_global, facture
       WHERE NOT EXISTS (
                SELECT 1
                  FROM prelevement_detail, prelevement
                 WHERE prelevement_detail.codope = facture.codope
                   AND prelevement_detail.numfact = facture.numfact
                   AND prelevement.numprelev = prelevement_detail.numprelev
                   AND NOT EXISTS (
                          SELECT 1
                            FROM annul_encais
                           WHERE annul_encais.numencaismt =
                                                       prelevement.numencaismt))
         AND g_numcpte = f_param_compte (contrat.numgar, 4, 2)
         AND contrat.numgar = qttc_global.numgar
         AND qttc_global.comptant != 'R'
         AND qttc_global.nat_calc = 2
         AND qttc_global.numquit = facture.numfact
         AND facture.codope = 4
         AND facture.mregl = 2
         AND facture.echeance BETWEEN NVL (e2d (g_echeance_deb),
                                           facture.echeance
                                          )
                                  AND NVL (e2d (g_echeance_fin),
                                           NVL (e2d (g_echeance_deb),
                                                facture.echeance
                                               )
                                          )
         AND facture.numfact IN (
                SELECT emission.numfact
                  FROM emission
                 WHERE emission.codope = facture.codope
                   AND emission.type_doc = 1
                   AND emission.numrelance = 0
                   AND NOT EXISTS (
                          SELECT 1
                            FROM emission
                           WHERE emission.codope = facture.codope
                             AND emission.numfact = facture.numfact
                             AND emission.type_doc = 1
                             AND emission.numrelance IN (4, 99)));

--
   CURSOR c_sel_trav_prelevement
   IS
      SELECT DISTINCT trav_prelevement.codbque, trav_prelevement.guichet,
                      trav_prelevement.compte, trav_prelevement.clerib,
                      trav_prelevement.intitule
                    , trav_prelevement.bban
                    , trav_prelevement.clef_iban
                    , trav_prelevement.bic
                 FROM trav_prelevement
                WHERE trav_prelevement.numremise = g_numremise
                  AND trav_prelevement.valide = 'O';

--
   CURSOR c_sel_trav_ano
   IS
      SELECT DISTINCT    'Les references bancaires de '
                      || indvs.numindiv
                      || '-'
                      || indvs.nom
                      || ' '
                      || indvs.prenom
                      || ' sont indeterminees.' lib_ano
                 FROM trav_prelevement, indvs
                WHERE trav_prelevement.valide = 'N'
                  AND indvs.numindiv = TO_NUMBER (trav_prelevement.compte);

------------------------------------------------------------------
--
-- Le corps des diff¿rentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_pv03b (
      i_deb_numsoc     IN       vs_compte.numsoc%TYPE DEFAULT NULL,
      i_fin_numsoc     IN       vs_compte.numsoc%TYPE DEFAULT NULL,
      i_deb_numcpte    IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_fin_numcpte    IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_deb_echeance   IN       VARCHAR2 DEFAULT NULL,
      i_fin_echeance   IN       VARCHAR2 DEFAULT NULL,
      i_session        IN       NUMBER DEFAULT 1,
      i_niv_msg        IN       NUMBER DEFAULT 1,
      i_pause          IN       NUMBER DEFAULT 0,
      o_found          OUT      NUMBER,
      o_erreur         OUT      VARCHAR2
   )
   IS
      r_sel_numcpte   c_sel_numcpte%ROWTYPE;
   BEGIN
      --
      o_found := 1;
      g_erreur := NULL;
      --
      g_numsoc_deb := i_deb_numsoc;
      g_numsoc_fin := i_fin_numsoc;
      g_numcpte_deb := i_deb_numcpte;
      g_numcpte_fin := i_fin_numcpte;
      g_echeance_deb := i_deb_echeance;
      g_echeance_fin := i_fin_echeance;
      --
      g_max_msg := i_niv_msg;
      g_session := i_session;

   --G_idligne     := F_max_idligne(I_session => G_session);
   --
--
-- OUVERTURE du Curseur
--
      IF NOT c_sel_numcpte%ISOPEN
      THEN
         g_niv_msg := 1;
         g_msg_adm :=
               'Debut de traitement le '
            || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
         p_ins_journal;

         -- Fin ecriture dans le Journal
         OPEN c_sel_numcpte;
      END IF;

      --
      -- LECTURE D'1 Ligne dans la table principale
      --
      FETCH c_sel_numcpte
       INTO r_sel_numcpte;

      --
      IF c_sel_numcpte%NOTFOUND
      THEN
         o_found := 0;
         -- FERMETURE du Curseur
         p_fin_traitement;
      ELSE
         o_found := 1;
         g_numsoc := r_sel_numcpte.numsoc;
         g_numcpte := r_sel_numcpte.numcpte;
--*debogage debut
         g_niv_msg := 3;
         g_msg_adm :=
               'societe n° '
            || TO_CHAR (g_numsoc)
            || ' - '
            || 'compte n° '
            || TO_CHAR (g_numcpte);
         p_ins_journal;
--*debogage fin
--
         p_corps_sel_numcpte;
--
         p_sel_trav_ano;
--
      END IF;

      --
      o_erreur := g_erreur;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'PK_PV03B - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;
   END;

--
-- ------------------------
   PROCEDURE p_sel_trav_ano
   IS
      r_sel_trav_ano   c_sel_trav_ano%ROWTYPE;
   BEGIN
--
      g_proc := 'P_sel_trav_ano';

--
      OPEN c_sel_trav_ano;

      LOOP
         FETCH c_sel_trav_ano
          INTO r_sel_trav_ano;

         EXIT WHEN c_sel_trav_ano%NOTFOUND;
         g_lib_ano := r_sel_trav_ano.lib_ano;
         g_niv_msg := 2;
         g_msg_adm := g_lib_ano;
         p_ins_journal;

         -- Fin ecriture dans le Journal
         DELETE      trav_prelevement;
      END LOOP;

      CLOSE c_sel_trav_ano;
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
-- --------------------------
   PROCEDURE p_fin_traitement
   IS
   BEGIN
--
      g_proc := 'P_fin_traitement';
--
      g_niv_msg := 1;
      g_msg_adm :=
            'Fin Normale du traitement le '
         || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;

      -- Fin ecriture dans le Journal
      CLOSE c_sel_numcpte;
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
-- -----------------------------
   PROCEDURE p_corps_sel_numcpte
   IS
   BEGIN
--
      g_proc := 'P_CORPS_sel_numcpte';

--
      SELECT NVL (MAX (numremise), 0) + 1
        INTO g_numremise
        FROM remise_prelev;

--
      p_select_facture;
--
      p_sel_trav_prelevement;
      --
      g_proc := g_proc || ' - Ins remise_prelev';

      --
      INSERT INTO remise_prelev
                  (numremise, numcpte, datrem, nombre, montant, valide)
         SELECT   numremise, numcpte, TRUNC (SYSDATE),
                  COUNT (DISTINCT numprelev), SUM (montant), 'N'
             FROM trav_prelevement
            WHERE trav_prelevement.numremise = g_numremise
              AND valide = 'O'
              AND montant > 0
         GROUP BY numremise, numcpte;

--
      g_proc := 'P_CORPS_sel_numcpte';
-- --
      g_proc := g_proc || ' - Ins prelevement';

      --
      INSERT INTO prelevement
                  (numremise, numprelev, montant, codbque, guichet, compte,
                   clerib, intitule
                  , bban
                  , clef_iban
                  , bic)
         SELECT   numremise, numprelev, SUM (montant), codbque, guichet,
                  compte, clerib, intitule
                , bban
                , clef_iban
                , bic
             FROM trav_prelevement
            WHERE trav_prelevement.numremise = g_numremise
              AND valide = 'O'
              AND montant > 0
         GROUP BY numremise,
                  numprelev,
                  codbque,
                  guichet,
                  compte,
                  clerib,
                  intitule
                , bban
                , clef_iban
                , bic;

--
      g_proc := 'P_CORPS_sel_numcpte';
-- --
      g_proc := g_proc || ' - Ins prelevement_detail';

      --
      INSERT INTO prelevement_detail
                  (numprelev, codope, numfact, idaffec, montant, valide)
         SELECT DISTINCT numprelev, codope, numfact, idaffec, montant, valide
                    FROM trav_prelevement
                   WHERE trav_prelevement.numremise = g_numremise
                     AND valide = 'O';

--
      g_proc := 'P_CORPS_sel_numcpte';
-- --
      g_proc := g_proc || ' - Ins compte_client';

      --
      INSERT INTO compte_client
                  (idaffec, codope, numcli, numencaismt, monnaie, datope,
                   montant, numfact, idcompta)
         SELECT prelevement_detail.idaffec, prelevement_detail.codope,
                facture.numcli, 0, pk_devise.devise_ref, TRUNC (SYSDATE),
                prelevement_detail.montant, prelevement_detail.numfact, -1
           FROM prelevement_detail, prelevement, facture
          WHERE prelevement.numremise = g_numremise
            AND prelevement.numprelev = prelevement_detail.numprelev
            AND facture.codope = prelevement_detail.codope
            AND facture.numfact = prelevement_detail.numfact;
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
-- ---------------------------------
   PROCEDURE p_sel_trav_prelevement
   IS
      r_sel_trav_prelevement   c_sel_trav_prelevement%ROWTYPE;
   BEGIN
--
      g_proc := 'P_sel_trav_prelevement';

--
      OPEN c_sel_trav_prelevement;

      LOOP
         FETCH c_sel_trav_prelevement
          INTO r_sel_trav_prelevement;

         EXIT WHEN c_sel_trav_prelevement%NOTFOUND;
         g_codbque  :=R_sel_trav_prelevement.codbque;
         g_guichet  :=R_sel_trav_prelevement.guichet;
         g_compte   :=R_sel_trav_prelevement.compte;
         g_clerib   :=R_sel_trav_prelevement.clerib;
         g_intitule :=R_sel_trav_prelevement.intitule;
         g_bban     :=R_sel_trav_prelevement.bban;
         g_clef_iban:=R_sel_trav_prelevement.clef_iban;
         g_bic      :=R_sel_trav_prelevement.bic;

         --
         -- P_sel_numprelev_next;
         SELECT NVL (MAX (numprelev), 0) + 1
           INTO g_numprelev
           FROM prelevement;

         --
         UPDATE trav_prelevement
            SET trav_prelevement.numprelev                              = g_numprelev
          WHERE trav_prelevement.numremise                              = g_numremise
            AND trav_prelevement.codbque                                = g_codbque
            AND trav_prelevement.guichet                                = g_guichet
            AND trav_prelevement.compte                                 = g_compte
            AND trav_prelevement.clerib                                 = g_clerib
            AND trav_prelevement.intitule                               = g_intitule
            AND	DECODE(trav_prelevement.bban      , g_bban      , 1, 0) = 1
            AND	DECODE(trav_prelevement.clef_iban , g_clef_iban , 1, 0) = 1
            AND	DECODE(trav_prelevement.bic       , g_bic       , 1, 0) = 1
           AND valide                                                   = 'O';

   --
--*debogage debut
         g_niv_msg := 3;
         g_msg_adm :=
               'upd trav_prelev n° '
            || TO_CHAR (g_numprelev)
            || ' - '
            || 'remise n° '
            || TO_CHAR (g_numremise);
         p_ins_journal;
--*debogage fin
   --
      END LOOP;

      CLOSE c_sel_trav_prelevement;
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
-- ----------------------------
   PROCEDURE p_select_facture
   IS
      r_select_facture   c_select_facture%ROWTYPE;
   BEGIN
--
      g_proc := 'P_select_facture';

--
      OPEN c_select_facture;

      LOOP
         FETCH c_select_facture
          INTO r_select_facture;

         EXIT WHEN c_select_facture%NOTFOUND;
         g_facture_codope := r_select_facture.codope;
         g_facture_numfact := r_select_facture.numfact;
         g_facture_numcli := r_select_facture.numcli;
         g_contrat_numgar := r_select_facture.numgar;
         g_idadhesion := r_select_facture.idadhesion;
         -- G_facture_montant := R_select_facture.montant;
         g_facture_montant :=
              r_select_facture.montant
            - NVL (f_totaffec (r_select_facture.numfact,
                               r_select_facture.codope
                              ),
                   0
                  );

         -- G_idaffec      := R_select_facture.idaffec;
         SELECT NVL (MAX (idaffec), 0) + 1
           INTO g_idaffec
           FROM compte_client;

         -- P_select_idrib;
         g_idrib :=
            pk_treso.f_idrib (g_facture_numcli,
                              g_facture_codope,
                              g_contrat_numgar,
                              2,
                              SYSDATE,
                              g_idadhesion
                             );
  --
--*debogage debut
         g_niv_msg := 3;
         g_msg_adm :=
               'ins trav_prelev facture n° '
            || TO_CHAR (g_facture_numfact)
            || ' - '
            || 'G_idrib n° '
            || TO_CHAR (g_idrib);
         p_ins_journal;

--*debogage fin
         INSERT INTO trav_prelevement
                     (numremise, numcpte, numprelev, codope, numfact, idaffec,
                      montant, codbque, guichet, compte, clerib, intitule,
                      valide
                     ,  bban
                     ,  clef_iban
                     ,  bic)
            --
            SELECT g_numremise, g_numcpte, 0, g_facture_codope,
                   g_facture_numfact, g_idaffec, g_facture_montant,
                   NVL (rib.codbque, '0000'), NVL (rib.guichet, '0000'),
                   NVL (rib.compte, '0000'), NVL (rib.clerib, '00'),
                   NVL (rib.intitule, '0000'),
                   DECODE (rib.ROWID, NULL, 'N', 'O')
                 , rib.bban
                 , rib.clef_iban
                 , rib.bic
              FROM rib
             WHERE rib.idrib = g_idrib AND f_rib_valide (g_idrib) = 1
            UNION
            SELECT g_numremise, g_numcpte, 0, g_facture_codope,
                   g_facture_numfact, g_idaffec, g_facture_montant, '0000',
                   '0000', TO_CHAR (g_facture_numcli), '00', '0000', 'N'
                 , NULL
                 , NULL
                 , NULL
              FROM DUAL
             WHERE f_rib_valide (g_idrib) = 0;
      --
      END LOOP;

      CLOSE c_select_facture;
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
