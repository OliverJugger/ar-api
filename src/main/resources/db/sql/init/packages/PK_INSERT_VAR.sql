CREATE OR REPLACE PACKAGE ARTHUS."PK_INSERT_VAR"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_insert_var.sql   1.6   01/07/06
--
-- ============================================================================
-- CONSTANTES PUBLIQUE
-- Aucune
-- ============================ Fin des Constantes Publiques ===============

   -- ============================================================================
-- EXCEPTIONS PUBLIQUES
-- Aucune
-- ============================ Fin des Exceptions Publiques ==================

   -- ============================================================================
-- ========================== Fin des types publiques =========================

   -- ============================================================================
-- VARIABLES PUBLIQUES
--
-- ========================== Fin des Variables publiques =====================
--
-- ============================================================================
/* -------------------------------------------------------------------- */
/* Recuperation des parametres                  */
/* Paramtre I_etendue : Etendue  -> 1, Contrat           */
/*          -> 2, Adhesion contrat        */
/*          -> 5, proposition       */
/* Paramtre I_numgar : contrat                  */
/*           ou idadhesion -> nom du chps       */
/* Paramtre I_numfor : garantie     -> nom du chps       */
/* Paramtre I_numindiv : individu   -> nom du chps       */
/* Paramtre I_ins_journal : test -> insertion                 */
/*                                         journal_adm              */
/* Paramtre I_valeur :           -> rien ou champs          */
/* Paramtre I_code_pays, I_session et I_date                             */
/*           servent a alimenter la table journal_adm       */
/* Paramtre O_code_msg   -> code message pour affichage     */
/*                          dans Sqlforms                   */
/* -----------------------------------------------------    */
-- appel particulier de P_INS_val_var a partir de gg05.inp via le
-- Menu contextuel declenchant le trigger gc01. Lors de cet appel le
-- parametre I_numfor n'est pas renseigne et la procedure traite
-- l'ensemble des garanties du contrat(I_numgar) passé en parametre.
-- ABO 27/12/2016 M5222 analyse de données contrat

   -- PROCEDURES ET FONCTIONS PUBLIQUES
-- Procedure de creation de variables relatives a un contrat
--
   PROCEDURE p_ins_val_var (
      i_etendue       IN       NUMBER,
      i_numgar        IN       NUMBER,
      i_numfor        IN       NUMBER,
      i_numindiv      IN       NUMBER DEFAULT 0,
      i_ins_journal   IN       BOOLEAN DEFAULT FALSE,
      i_valeur        IN       NUMBER,
      i_code_pays     IN       NUMBER,
      i_session       IN       NUMBER,
      i_date          IN       DATE,
      o_code_msg      OUT      mess_erreur.code_msg%TYPE
   );
-- ========================== Fin des Procedures publiques =====================
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_INSERT_VAR"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_insert_var.sql   1.6   01/07/06

   -- ============================================================================
-- CONSTANTES PRIVEES
--
-- ========================== Fin des constantes privees ======================

   -- ============================================================================
-- -- EXCEPTIONS PRIVEES
-- Aucune
-- ========================== Fin des exceptions privees ======================

   -- ============================================================================
-- TYPES PRIVEES
-- Type adhesion contrat ou proposition
   TYPE typ_r_contrat IS RECORD (
      numprod      contrat.numprod%TYPE,
      numcli       contrat.numcli%TYPE,
      numorg       contrat.numorg%TYPE,
      numsoc       contrat.numinterm%TYPE,
      edebut       NUMBER,
      insdate      NUMBER,
      numgar       contrat.numgar%TYPE,
      idadhesion   adhe_cntrt.idadhesion%TYPE,
      idpropo      NUMBER
   );

-- insdate est la date a inserer dans val_variable
-- edebut correspond a la date sur laquelle on fait les tests de periodes
--
-- ========================== Fin des types privees ===========================

   -- ============================================================================
-- VARIABLES GLOBALES PRIVEES
--
-- Variable TYPE RECORD
   g_r_contrat        typ_r_contrat;
--
-- Variable concernant la Trace
   g_nom_traitement   journal_adm.nom_traitement%TYPE  DEFAULT 'pk_insert_var';
   g_session          NUMBER;
   g_niv_msg          journal_adm.niv_msg%TYPE          DEFAULT 1;
   g_msg_adm          journal_adm.msg_adm%TYPE;
   g_date             DATE;
   g_idligne          journal_adm.idligne%TYPE;
   g_ins_journal      BOOLEAN;
--
-- Variables recuperant les parametres
   g_valeur           NUMBER;
   g_numassu          NUMBER;
   g_numindiv         NUMBER;
   g_etendue          NUMBER;
   g_flag_insert      NUMBER;

--
-- ===================== Fin des variables globales privees ===================

   -- ============================================================================
-- DEFINITION DES PROCEDURES PRIVEES
-- Appel de la procedure d'insertion dans la table journal_adm
   PROCEDURE p_appel_pk_trace
   IS
   BEGIN
      IF g_ins_journal
      THEN
         pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                                     i_session             => g_session,
                                     i_niv_msg             => g_niv_msg,
                                     i_msg_adm             => g_msg_adm,
                                     i_date                => g_date,
                                     i_idligne             => g_idligne
                                    );
      END IF;
   END;

--
-- Procedure recherchant les infos sur adhesion
   PROCEDURE p_sel_adhesion (
      i_numgar      IN       contrat.numgar%TYPE,
      o_r_contrat   OUT      typ_r_contrat
   )
   IS
      CURSOR c_adhesion
      IS
         SELECT contrat.numprod, contrat.numcli, contrat.numorg,
                contrat.numinterm,
                TO_NUMBER (TO_CHAR (adhe_cntrt.date_adhe, 'j')) date_adhe,
                contrat.numgar, adhe_cntrt.idadhesion
           FROM contrat, adhe_cntrt
          WHERE contrat.numgar = adhe_cntrt.numgar
            AND adhe_cntrt.idadhesion = i_numgar;

--
      rec_c_adhesion   c_adhesion%ROWTYPE;
--
   BEGIN
      OPEN c_adhesion;

      FETCH c_adhesion
       INTO rec_c_adhesion;

      IF c_adhesion%FOUND
      THEN
         o_r_contrat.numprod := rec_c_adhesion.numprod;
         o_r_contrat.numcli := rec_c_adhesion.numcli;
         o_r_contrat.numorg := rec_c_adhesion.numorg;
         o_r_contrat.numsoc := rec_c_adhesion.numinterm;
         o_r_contrat.insdate := rec_c_adhesion.date_adhe;
         o_r_contrat.edebut := rec_c_adhesion.date_adhe;
         o_r_contrat.numgar := rec_c_adhesion.numgar;
         o_r_contrat.idadhesion := rec_c_adhesion.idadhesion;
         -- Trace
         g_idligne := 8;
         g_msg_adm :=
                    'N° idadhesion : ' || TO_CHAR (rec_c_adhesion.idadhesion);
         p_appel_pk_trace;
      ELSE
         o_r_contrat.numgar := i_numgar;
      END IF;

      CLOSE c_adhesion;
   END;

--
-- Procedure recherchant les infos sur proposition
   PROCEDURE p_sel_proposition (
      i_numgar      IN       contrat.numgar%TYPE,
      o_r_contrat   OUT      typ_r_contrat
   )
   IS
--
      CURSOR c_proposition
      IS
         SELECT contrat.numprod, contrat.numcli, contrat.numorg,
                contrat.numinterm
           FROM contrat
          WHERE contrat.numgar = i_numgar
         UNION
         SELECT produit.numprod, 0, 0, 0
           FROM produit
          WHERE produit.numprod = i_numgar;

--
      rec_c_proposition   c_proposition%ROWTYPE;
--
   BEGIN
      OPEN c_proposition;

      FETCH c_proposition
       INTO rec_c_proposition;

      IF c_proposition%FOUND
      THEN
         o_r_contrat.numprod := rec_c_proposition.numprod;
         o_r_contrat.numcli := rec_c_proposition.numcli;
         o_r_contrat.numorg := rec_c_proposition.numorg;
         o_r_contrat.numsoc := rec_c_proposition.numinterm;
         o_r_contrat.edebut := f_etat_propo (g_numindiv, SYSDATE, 3);
         o_r_contrat.insdate := o_r_contrat.edebut;
         o_r_contrat.idpropo := g_numindiv;
         -- Trace
         g_idligne := 10;
         g_msg_adm :=
               'Recherche date de la proposition : '
            || TO_CHAR (i_numgar)
            || '-->'
            || TO_CHAR (j2d (o_r_contrat.edebut), 'DD/MM/YYYY');
         p_appel_pk_trace;
      END IF;

      o_r_contrat.numgar := i_numgar;

      --
      CLOSE c_proposition;
   END;

--
-- Procedure recherchant les infos sur Contrat
   PROCEDURE p_sel_contrat (
      i_numgar      IN       contrat.numgar%TYPE,
      o_r_contrat   OUT      typ_r_contrat
   )
   IS
      CURSOR c_contrat
      IS
         SELECT contrat.numprod, contrat.numcli, contrat.numorg,
                contrat.numinterm
           FROM contrat
          WHERE contrat.numgar = i_numgar;

      --
      rec_c_contrat   c_contrat%ROWTYPE;
   --
   BEGIN
      OPEN c_contrat;

      FETCH c_contrat
       INTO rec_c_contrat;

      IF c_contrat%FOUND
      THEN
         o_r_contrat.numprod := rec_c_contrat.numprod;
         o_r_contrat.numcli := rec_c_contrat.numcli;
         o_r_contrat.numorg := rec_c_contrat.numorg;
         o_r_contrat.numsoc := rec_c_contrat.numinterm;
         -- Trace
         g_idligne := 4;
         g_msg_adm := 'Recherche données du contrat :' || TO_CHAR (i_numgar);
         p_appel_pk_trace;
      END IF;

      o_r_contrat.numgar := i_numgar;

      CLOSE c_contrat;
   END;

--
--
   FUNCTION f_comm_clef (i_etendue NUMBER)
      RETURN NUMBER
   IS
      l_comm_clef   NUMBER;
   BEGIN
      IF i_etendue IN (0, 12)
      THEN
         l_comm_clef := g_numindiv;
      ELSIF i_etendue IN ( 2,24)
      THEN
         l_comm_clef := g_r_contrat.numgar;
      ELSIF i_etendue = 3
      THEN
         l_comm_clef := g_r_contrat.numcli;
      ELSIF i_etendue = 4
      THEN
         l_comm_clef := g_numassu;
      ELSIF i_etendue = 5
      THEN
         l_comm_clef := g_r_contrat.numorg;
      ELSIF i_etendue = 7
      THEN
         l_comm_clef := g_r_contrat.numprod;
      ELSIF i_etendue = 9
      THEN
         l_comm_clef := g_r_contrat.numsoc;
      ELSIF i_etendue = 13
      THEN
         l_comm_clef := g_r_contrat.idadhesion;
      ELSIF i_etendue = 14
      THEN
         l_comm_clef := g_r_contrat.idpropo;
      ELSE
         l_comm_clef := NULL;
      END IF;

      RETURN (l_comm_clef);
   END;

-- Procedure Recursive appele a partir de P_SEL_frm_prime
--
   PROCEDURE p_recurs_evaluation (i_idvariable IN NUMBER)
   IS
--
      CURSOR c_def_variable
      IS
         SELECT DECODE (def_variable.statique, 'O', 1, 0) statique,
                def_variable.etendue, def_variable.valeur
           FROM def_variable
          WHERE def_variable.idvariable = i_idvariable;

--
      CURSOR c_count_frmlvar (p_etendue def_variable.etendue%TYPE)
      IS
         SELECT COUNT (*) nombre
           FROM v_clef_corres, histo_frmlvar
          WHERE v_clef_corres.etendue = p_etendue
            AND v_clef_corres.etendue = 2
            AND v_clef_corres.numgar =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
            AND v_clef_corres.clef = histo_frmlvar.clef
            AND histo_frmlvar.idvariable = i_idvariable
            AND histo_frmlvar.clef IS NOT NULL
            AND histo_frmlvar.valide = 'O';

--
-- Curseur sur Formules generales
--
      CURSOR c_formule_gene
      IS
         SELECT frmlvar_detail.idvariable
           FROM histo_frmlvar, frmlvar_detail
          WHERE histo_frmlvar.idformule = frmlvar_detail.idformule
            AND frmlvar_detail.idvariable != i_idvariable
            AND histo_frmlvar.idvariable = i_idvariable
            AND histo_frmlvar.clef IS NULL
            AND j2d (g_r_contrat.edebut) BETWEEN histo_frmlvar.debut
                                             AND NVL (histo_frmlvar.fin,
                                                      j2d (g_r_contrat.edebut)
                                                     )
            AND histo_frmlvar.valide = 'O';

--
-- Curseur sur Formules Specifiques
--
      CURSOR c_formule_specif (p_etendue def_variable.etendue%TYPE)
      IS
         SELECT frmlvar_detail.idvariable
           FROM histo_frmlvar, frmlvar_detail, v_clef_corres
          WHERE v_clef_corres.etendue = p_etendue
            AND v_clef_corres.etendue = 2
            AND v_clef_corres.numgar =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
            AND v_clef_corres.clef = histo_frmlvar.clef
            AND histo_frmlvar.idformule = frmlvar_detail.idformule
            AND frmlvar_detail.idvariable != i_idvariable
            AND histo_frmlvar.idvariable = i_idvariable
            AND j2d (g_r_contrat.edebut) BETWEEN histo_frmlvar.debut
                                             AND NVL (histo_frmlvar.fin,
                                                      j2d (g_r_contrat.edebut)
                                                     )
            AND histo_frmlvar.valide = 'O';


      CURSOR c_val_variable (
         p_etendue     def_variable.etendue%TYPE,
         p_statique    def_variable.statique%TYPE,
         p_comm_clef   NUMBER
      )
      IS
         SELECT 'X'
           FROM val_variable
          WHERE idvariable = i_idvariable
            AND etendue = p_etendue
            AND statique = DECODE (p_statique, 1, 'O', 'N')
            AND clef = p_comm_clef
            --MANTIS 4265
            --SDA si la variable existe déja ne pas crée de doublon de variable
            --a l'opérateur de saisir l'historique
            --AND to_date(G_R_contrat.edebut,'j') BETWEEN debut
            --AND NVL(fin,to_date(G_R_contrat.edebut,'j'))
            AND valide = 'O'
            AND (   (    p_etendue IN (2, 8, 15, 16, 17)
                     AND NVL (numgar,
                              pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                             ) = pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                    )
                 OR (    p_etendue IN (4, 12, 13,24)
                     AND NVL (numgar, g_r_contrat.numgar) = g_r_contrat.numgar
                    )
                );

--
      CURSOR c_produit (p_numprod NUMBER)
      IS
         SELECT deffet
           FROM produit
          WHERE numprod = p_numprod;

--
      rec_c_def_variable     c_def_variable%ROWTYPE;
      rec_c_count_frmlvar    c_count_frmlvar%ROWTYPE;
      rec_c_formule_gene     c_formule_gene%ROWTYPE;
      rec_c_formule_specif   c_formule_specif%ROWTYPE;
      rec_c_val_variable     c_val_variable%ROWTYPE;
      rec_c_produit          c_produit%ROWTYPE;
--
      l_comm_clef            NUMBER;
      l_exist_variable       BOOLEAN;
   BEGIN
      --
      OPEN c_def_variable;

      FETCH c_def_variable
       INTO rec_c_def_variable;

      --
      -- Recherche de la clef (numcli,numgar,numsoc ...) suivant l'etendue
      l_comm_clef := f_comm_clef (i_etendue => rec_c_def_variable.etendue);

      --
      -- Recherche si formule generale ou specifique
      OPEN c_count_frmlvar (rec_c_def_variable.etendue);

      FETCH c_count_frmlvar
       INTO rec_c_count_frmlvar;

      --
      IF rec_c_count_frmlvar.nombre = 0
      THEN                                                -- formule generale
         --
         OPEN c_formule_gene;

         FETCH c_formule_gene
          INTO rec_c_formule_gene;

         IF c_formule_gene%FOUND
         THEN
            l_exist_variable := FALSE;    -- Correspond a un noeud de l'arbre

            WHILE (c_formule_gene%FOUND)    -- donc ce n'est pas une variable
            LOOP
               -- Trace
               g_idligne := 16;
               g_msg_adm :=
                     'Variable de formule generale :'
                  || TO_CHAR (i_idvariable)
                  || ' contenant d''autres Sous variable';
               p_appel_pk_trace;
               --
               -- Parcours recursif de l'arbre(empilement).
               p_recurs_evaluation
                                (i_idvariable      => rec_c_formule_gene.idvariable);

               FETCH c_formule_gene
                INTO rec_c_formule_gene;
            --
            END LOOP;
         ELSE
            l_exist_variable := TRUE;      -- Correspond a une feuille de
                                           -- l'arbre donc c'est une variable
            -- Trace
            g_idligne := 18;
            g_msg_adm :=
                  'Variable de formule generale :'
               || TO_CHAR (i_idvariable)
               || ' ne contenant pas d''autres Sous variable';
            p_appel_pk_trace;
         END IF;
      ELSE                                               -- formule specifique
         --
         OPEN c_formule_specif (rec_c_def_variable.etendue);

         FETCH c_formule_specif
          INTO rec_c_formule_specif;

         IF c_formule_specif%FOUND
         THEN
            l_exist_variable := FALSE;    -- Correspond a un noeud de l'arbre

            WHILE (c_formule_specif%FOUND
                  )                          -- donc ce n'est pas une variable
            LOOP
               -- Trace
               g_idligne := 20;
               g_msg_adm :=
                     'Variable de formule specifique :'
                  || TO_CHAR (i_idvariable)
                  || 'contenant d''autres Sous variable';
               p_appel_pk_trace;
               --
               -- Parcours recursif de l'arbre(empilement).
               p_recurs_evaluation
                              (i_idvariable      => rec_c_formule_specif.idvariable);

               FETCH c_formule_specif
                INTO rec_c_formule_specif;
            --
            END LOOP;
         ELSE
            l_exist_variable := TRUE;    -- C'est une feuille de l'arbre donc
                                         -- c'est une variable.
            g_idligne := 22;
            g_msg_adm :=
                  'Variable de formule specifique :'
               || TO_CHAR (i_idvariable)
               || ' ne contenant pas d''autres Sous variable';
            p_appel_pk_trace;
         END IF;
      END IF;

      --
      -- desempilage de l'appel recursif et insertion des variables
      -- (L_exist_variable := TRUE) dans la table Val_variable.
      IF l_exist_variable
      THEN
         IF rec_c_def_variable.statique = 1
         THEN
            IF NOT (   (    g_numindiv = 0
                        AND rec_c_def_variable.etendue IN
                                                   (8, 4, 12, 13, 15, 16, 17)
                       )
                    OR (    g_numindiv <> 0
                        AND rec_c_def_variable.etendue NOT IN (4, 12, 13)
                       )
                   )
            THEN
               OPEN c_val_variable
                                  (p_etendue        => rec_c_def_variable.etendue,
                                   p_statique       => rec_c_def_variable.statique,
                                   p_comm_clef      => l_comm_clef
                                  );

               FETCH c_val_variable
                INTO rec_c_val_variable;

               IF c_val_variable%FOUND
               THEN
                  IF g_valeur <> 2
                  THEN
                     g_flag_insert := 2;
                  END IF;
               --
               ELSE
                  -- Si etendue produit alors on insere la date d'effet du produit
                  IF rec_c_def_variable.etendue = 7
                  THEN
                     OPEN c_produit (l_comm_clef);

                     FETCH c_produit
                      INTO rec_c_produit;

                     g_r_contrat.insdate := d2j (rec_c_produit.deffet);

                     CLOSE c_produit;
                  END IF;

                  --
                  g_idligne := 24;
                  g_msg_adm :=
                        'Insertion variable '
                     || TO_CHAR (i_idvariable)
                     || ' a la date '
                     || TO_CHAR (TO_DATE (g_r_contrat.insdate, 'j'),
                                 'DD/MM/YYYY'
                                );
                  p_appel_pk_trace;

                  -- Insertion dans la Table Val_variable
                  INSERT INTO val_variable
                              (idvariable, etendue,
                               clef,
                               statique,
                               debut, fin, valide,
                               valeur,
                               numgar
                              )
                       VALUES (i_idvariable, rec_c_def_variable.etendue,
                               DECODE (rec_c_def_variable.etendue,
                                       2, g_r_contrat.numgar,
                                       3, g_r_contrat.numcli,
                                       4, g_numassu,
                                       5, g_r_contrat.numorg,
                                       7, g_r_contrat.numprod,
                                       9, g_r_contrat.numsoc,
                                       12, g_numindiv,
                                       13, g_r_contrat.idadhesion,
                                       14, g_r_contrat.idpropo,
                                       24, G_R_contrat.numgar
                                      ),
                               DECODE (rec_c_def_variable.statique,
                                       1, 'O',
                                       'N'
                                      ),
                               TO_DATE (g_r_contrat.insdate, 'j'), '', 'O',
                               rec_c_def_variable.valeur,
                               DECODE (rec_c_def_variable.etendue,
                                       7, NULL,
                                       g_r_contrat.numgar
                                      )
                              );

                  --
                  IF g_valeur <> 2
                  THEN
                     g_flag_insert := 1;
                  END IF;
               END IF;

               --
               IF g_valeur = 2
               THEN
                  g_flag_insert := 0;
               END IF;
            --
            END IF;
         END IF;
      END IF;

      IF c_def_variable%ISOPEN
      THEN
         CLOSE c_def_variable;
      END IF;

      IF c_count_frmlvar%ISOPEN
      THEN
         CLOSE c_count_frmlvar;
      END IF;

      IF c_formule_gene%ISOPEN
      THEN
         CLOSE c_formule_gene;
      END IF;

      IF c_formule_specif%ISOPEN
      THEN
         CLOSE c_formule_specif;
      END IF;

      IF c_val_variable%ISOPEN
      THEN
         CLOSE c_val_variable;
      END IF;
   END;

--
-- Fetches des idvariables de Frml_prime
-- ABO 30/11/2021 correctif ARTGEREP-317 : analyse de données contrat, tarification anticipée
--
   PROCEDURE p_sel_frml_prime (i_numfor IN NUMBER)
   IS
      CURSOR c_frml_prime
      IS
         SELECT DISTINCT frml_prime.base idvariable
                    FROM frml_prime
                   WHERE frml_prime.numfor IN (
                            SELECT numfor
                              FROM gar_cntrt
                             WHERE gar_cntrt.numfor =
                                      DECODE
                                         (i_numfor,
                                          0, frml_prime.numfor,
                                          pk_qttc.f_sel_numfor
                                                          (g_r_contrat.numgar,
                                                           i_numfor
                                                          )
                                         )
                               AND gar_cntrt.numgar =
                                      pk_qttc.f_sel_numgar (g_r_contrat.numgar))
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_prime.debut
                                                      AND NVL
                                                            (frml_prime.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_prime.debut > j2d(g_r_contrat.edebut))
                     AND frml_prime.valide = 'O'
         UNION
         SELECT DISTINCT TO_NUMBER (frml_prime.taux)
                    FROM frml_prime
                   WHERE frml_prime.numfor IN (
                            SELECT numfor
                              FROM gar_cntrt
                             WHERE gar_cntrt.numfor =
                                      DECODE
                                         (i_numfor,
                                          0, frml_prime.numfor,
                                          pk_qttc.f_sel_numfor
                                                          (g_r_contrat.numgar,
                                                           i_numfor
                                                          )
                                         )
                               AND gar_cntrt.numgar =
                                      pk_qttc.f_sel_numgar (g_r_contrat.numgar))
                     AND TO_NUMBER (frml_prime.taux) != 0
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_prime.debut
                                                      AND NVL
                                                            (frml_prime.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_prime.debut > j2d(g_r_contrat.edebut))
                     AND frml_prime.valide = 'O'
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail, frml_tfc
                   WHERE frml_tfc.numfor IN (
                            SELECT numfor
                              FROM gar_cntrt
                             WHERE gar_cntrt.numfor =
                                      DECODE
                                         (i_numfor,
                                          0, frml_tfc.numfor,
                                          pk_qttc.f_sel_numfor
                                                          (g_r_contrat.numgar,
                                                           i_numfor
                                                          )
                                         )
                               AND gar_cntrt.numgar =
                                      pk_qttc.f_sel_numgar (g_r_contrat.numgar))
                     AND frml_tfc.idformule = frmlvar_detail.idformule
                     AND frml_tfc.valide = 'O'
                     AND frml_tfc.tfc != 4
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_tfc.debut
                                                      AND NVL
                                                            (frml_tfc.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_tfc.debut > j2d(g_r_contrat.edebut))
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail, frml_tfc
                   WHERE frml_tfc.numfor =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                     AND frml_tfc.idformule = frmlvar_detail.idformule
                     AND frml_tfc.valide = 'O'
                     AND frml_tfc.tfc = 4
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_tfc.debut
                                                      AND NVL
                                                            (frml_tfc.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_tfc.debut > j2d(g_r_contrat.edebut))
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail, frml_prest
                   WHERE frml_prest.numfor IN (
                            SELECT numfor
                              FROM gar_cntrt
                             WHERE gar_cntrt.numfor =
                                      DECODE
                                         (i_numfor,
                                          0, frml_prest.numfor,
                                          pk_qttc.f_sel_numfor
                                                          (g_r_contrat.numgar,
                                                           i_numfor
                                                          )
                                         )
                               AND gar_cntrt.numgar =
                                      pk_qttc.f_sel_numgar (g_r_contrat.numgar))
                     AND frml_prest.idformule = frmlvar_detail.idformule
                     AND frml_prest.valide = 'O'
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_prest.debut
                                                      AND NVL
                                                            (frml_prest.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_prest.debut > j2d(g_r_contrat.edebut))
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail, frml_reval
                   WHERE frml_reval.numfor IN (
                            SELECT numfor
                              FROM gar_cntrt
                             WHERE gar_cntrt.numfor =
                                      DECODE
                                         (i_numfor,
                                          0, frml_reval.numfor,
                                          pk_qttc.f_sel_numfor
                                                          (g_r_contrat.numgar,
                                                           i_numfor
                                                          )
                                         )
                               AND gar_cntrt.numgar =
                                      pk_qttc.f_sel_numgar (g_r_contrat.numgar))
                     AND frml_reval.idformule = frmlvar_detail.idformule
                     AND frml_reval.valide = 'O'
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_reval.debut
                                                      AND NVL
                                                            (frml_reval.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_reval.debut > j2d(g_r_contrat.edebut))
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail, frml_dedu
                   WHERE frml_dedu.numfor IN (
                            SELECT numfor
                              FROM gar_cntrt
                             WHERE gar_cntrt.numfor =
                                      DECODE
                                         (i_numfor,
                                          0, frml_dedu.numfor,
                                          pk_qttc.f_sel_numfor
                                                          (g_r_contrat.numgar,
                                                           i_numfor
                                                          )
                                         )
                               AND gar_cntrt.numgar =
                                      pk_qttc.f_sel_numgar (g_r_contrat.numgar))
                     AND frml_dedu.idformule = frmlvar_detail.idformule
                     AND frml_dedu.valide = 'O'
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_dedu.debut
                                                      AND NVL
                                                            (frml_dedu.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_dedu.debut > j2d(g_r_contrat.edebut))
         UNION
         SELECT DISTINCT idvariable
                    FROM for_variable
                   WHERE for_variable.numfor IN (
                            SELECT numfor
                              FROM gar_cntrt
                             WHERE gar_cntrt.numfor =
                                      DECODE
                                         (i_numfor,
                                          0, for_variable.numfor,
                                          pk_qttc.f_sel_numfor
                                                          (g_r_contrat.numgar,
                                                           i_numfor
                                                          )
                                         )
                               AND gar_cntrt.numgar =
                                      pk_qttc.f_sel_numgar (g_r_contrat.numgar))
                     AND for_variable.etendue = 3
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail, cond_proposition
                   WHERE cond_proposition.cle =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                     AND cond_proposition.etendue =
                            pk_qttc.f_sel_numfor (g_r_contrat.numgar,
                                                  i_numfor)
                     AND cond_proposition.idformule = frmlvar_detail.idformule
                     AND g_etendue = 5
                     AND (j2d(g_r_contrat.edebut) BETWEEN cond_proposition.debut
                                                      AND NVL
                                                            (cond_proposition.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR cond_proposition.debut > j2d(g_r_contrat.edebut))
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail, carence
                   WHERE carence.numfor =
                            DECODE (i_numfor,
                                    0, carence.numfor,
                                    pk_qttc.f_sel_numfor (g_r_contrat.numgar,
                                                          i_numfor
                                                         )
                                   )
                     AND carence.nummath = frmlvar_detail.idformule
                     AND g_etendue = 2
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail,
                         frml_reass,
                         avnt_cntrt_gart,
                         cntrt_trait
                   WHERE avnt_cntrt_gart.numfor =
                            pk_qttc.f_sel_numfor (g_r_contrat.numgar,
                                                  i_numfor)
                     AND avnt_cntrt_gart.numgar =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                     AND avnt_cntrt_gart.numav = cntrt_trait.numav
                     AND cntrt_trait.numgar =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                     AND cntrt_trait.numtr = frml_reass.numtr
                     AND frml_reass.idformule = frmlvar_detail.idformule
                     AND cntrt_trait.valide = 'O'
                     AND (j2d(g_r_contrat.edebut) BETWEEN cntrt_trait.debut
                                                      AND NVL
                                                            (cntrt_trait.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR cntrt_trait.debut > j2d(g_r_contrat.edebut))
                     AND frml_reass.valide = 'O'
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_reass.debut
                                                      AND NVL
                                                            (frml_reass.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_reass.debut > j2d(g_r_contrat.edebut))
         UNION
         SELECT DISTINCT idvariable
                    FROM frmlvar_detail,
                         frml_tfc_reass,
                         avnt_cntrt_gart,
                         cntrt_trait
                   WHERE avnt_cntrt_gart.numfor =
                            pk_qttc.f_sel_numfor (g_r_contrat.numgar,
                                                  i_numfor)
                     AND avnt_cntrt_gart.numgar =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                     AND avnt_cntrt_gart.numav = cntrt_trait.numav
                     AND cntrt_trait.numgar =
                                     pk_qttc.f_sel_numgar (g_r_contrat.numgar)
                     AND cntrt_trait.numtr = frml_tfc_reass.numtr
                     AND frml_tfc_reass.idformule = frmlvar_detail.idformule
                     AND cntrt_trait.valide = 'O'
                     AND (j2d(g_r_contrat.edebut) BETWEEN cntrt_trait.debut
                                                      AND NVL
                                                            (cntrt_trait.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR cntrt_trait.debut > j2d(g_r_contrat.edebut))
                     AND frml_tfc_reass.valide = 'O'
                     AND (j2d(g_r_contrat.edebut) BETWEEN frml_tfc_reass.debut
                                                      AND NVL
                                                            (frml_tfc_reass.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR frml_tfc_reass.debut > j2d(g_r_contrat.edebut))
        UNION
        SELECT	distinct idvariable
                FROM	frmlvar_detail,cond_adhesion_gar
        WHERE 	cond_adhesion_gar.numfor =
                decode(I_numfor,
                  0,cond_adhesion_gar.numfor,
                  pk_qttc.f_sel_numfor(G_R_contrat.numgar,I_numfor))
        AND	cond_adhesion_gar.idformule = frmlvar_detail.idformule
        AND (j2d(g_r_contrat.edebut) BETWEEN cond_adhesion_gar.debut
                                                      AND NVL
                                                            (cond_adhesion_gar.fin,
                                                             j2d(g_r_contrat.edebut))
                         OR cond_adhesion_gar.debut > j2d(g_r_contrat.edebut));

--
      rec_c_frml_prime   c_frml_prime%ROWTYPE;
--
   BEGIN
      OPEN c_frml_prime;

      LOOP
         FETCH c_frml_prime
          INTO rec_c_frml_prime;

         EXIT WHEN c_frml_prime%NOTFOUND;
         -- Trace
         g_idligne := 14;
         g_msg_adm :=
               'Recherche a partir du N° Garantie :'
            || TO_CHAR (pk_qttc.f_sel_numfor (g_r_contrat.numgar, i_numfor))
            || ' L''Idvariable :'
            || TO_CHAR (rec_c_frml_prime.idvariable);
         p_appel_pk_trace;
         --
         -- Appel de la Procedure Recursive permettant de rechercher
         -- les formules et d'inserer les variables dans la table Val_variable.
         --
         p_recurs_evaluation (i_idvariable => rec_c_frml_prime.idvariable);
      --
      END LOOP;

      CLOSE c_frml_prime;
   END;

--
-- ===================== Fin des Procedures privees ===================

   -- ============================================================================
-- CORPS DES PROCEDURES PUBLIQUES
-- Procedure de creation de variables relatives a un contrat
--
   PROCEDURE p_ins_val_var (
      i_etendue       IN       NUMBER,
      i_numgar        IN       NUMBER,
      i_numfor        IN       NUMBER,
      i_numindiv      IN       NUMBER DEFAULT 0,
      i_ins_journal   IN       BOOLEAN DEFAULT FALSE,
      i_valeur        IN       NUMBER,
      i_code_pays     IN       NUMBER,
      i_session       IN       NUMBER,
      i_date          IN       DATE,
      o_code_msg      OUT      mess_erreur.code_msg%TYPE
   )
   IS
      -- Variables
      l_code_msg        mess_erreur.code_msg%TYPE;
      l_lib_msg         mess_erreur.lib_msg%TYPE;

      --
      CURSOR c_garantie (p_numfor gar_cntrt.numfor%TYPE)
      IS
         SELECT DISTINCT grp_gar_def.numfor
                    FROM grp_gar_def
                   WHERE grp_gar_def.numgrpgar = p_numfor
         UNION
         SELECT gar_cntrt.numfor
           FROM gar_cntrt
          WHERE gar_cntrt.numfor = p_numfor;

      --
      CURSOR c_gar_cntrt (
         p_numgar   gar_cntrt.numgar%TYPE,
         p_numfor   gar_cntrt.numfor%TYPE
      )
      IS
         SELECT d2j (gar_cntrt.datapli) datapli, numfor
           FROM gar_cntrt
          WHERE gar_cntrt.numgar = p_numgar
            AND gar_cntrt.numfor = NVL (p_numfor, gar_cntrt.numfor);

      --
      CURSOR c_adhesion (
         p_numindiv     adhesion.numindiv%TYPE,
         p_idadhesion   adhesion.idadhesion%TYPE,
         p_numfor       adhesion.numfor%TYPE
      )
      IS
         SELECT   d2j (MIN (adhesion.datapli)) datapli, numfor
             FROM adhesion
            WHERE adhesion.numindiv = p_numindiv
              AND adhesion.idadhesion = p_idadhesion
              AND adhesion.numfor = NVL (p_numfor, adhesion.numfor)
         GROUP BY numfor;

      --
      rec_c_garantie    c_garantie%ROWTYPE;
      rec_c_gar_cntrt   c_gar_cntrt%ROWTYPE;
      rec_c_adhesion    c_adhesion%ROWTYPE;
   --
   BEGIN
      -- Initialisation des parametres dans variables globales
      g_etendue := i_etendue;
      g_numindiv := i_numindiv;
      g_valeur := i_valeur;
      g_session := i_session;
      g_date := sysdate;
      g_ins_journal := i_ins_journal;
       g_ins_journal := TRUE;
      g_flag_insert := 0;
      --
      g_idligne := 0;
      g_msg_adm := 'début de traitement PK_insert_var.P_INS_val_var';
      p_appel_pk_trace;


      --
      -- Recherche du numassu Suivant les parametres
      IF g_numindiv <> 0 AND g_etendue <> 5
      THEN
         g_numassu := f_numassu (g_numindiv, i_numgar);
         -- Trace
         g_idligne := 2;
         g_msg_adm := 'NUMASSU N° ' || TO_CHAR (g_numassu);
         p_appel_pk_trace;
      ELSE
         g_numassu := 0;
      END IF;

      --
      IF g_etendue = 1
      THEN                                                        -- (Contrat)
         -- Recherche des infos concernant le contrat
         p_sel_contrat (i_numgar => i_numgar, o_r_contrat => g_r_contrat);

         --
         /* Si le parametre I_numfor est passé a Null(a partir du trigger
            gc01 de la forme gg05.inp) alors les différents tests dans
            "P_recurs_evaluation" se font par rapport a date du jour
            Sinon les tests se font a partir de la date de gar_cntrt
         */
         IF i_numfor IS NULL
         THEN
            g_r_contrat.edebut := d2j(SYSDATE);
         END IF;

         --
         -- Recherche des infos dans gar_cntrt
         OPEN c_gar_cntrt (p_numgar => i_numgar, p_numfor => i_numfor);

         LOOP
            FETCH c_gar_cntrt
             INTO rec_c_gar_cntrt;

            EXIT WHEN c_gar_cntrt%NOTFOUND;
            --
            -- Dans tous les cas on insere dans val_variable la date de gar_cntrt
            g_r_contrat.insdate := rec_c_gar_cntrt.datapli;
            g_r_contrat.edebut := greatest(rec_c_gar_cntrt.datapli,g_r_contrat.edebut);--M5222

            --
            -- Si le numfor  est passe en parametre alors les tests se font
            -- a partir de la date de gar_cntrt.
            IF i_numfor IS NOT NULL
            THEN
               g_r_contrat.edebut := rec_c_gar_cntrt.datapli;
            END IF;

            --
            g_idligne := 6;
            g_msg_adm :=
                  'Recherche gar_cntrt, Numgar : '
               || TO_CHAR (i_numgar)
               || ' Numfor : '
               || TO_CHAR (rec_c_gar_cntrt.numfor)
               || ' Date : '
               || TO_CHAR (j2d (g_r_contrat.insdate), 'DD/MM/YYYY');
            p_appel_pk_trace;

            --
            OPEN c_garantie (rec_c_gar_cntrt.numfor);

            LOOP
               FETCH c_garantie
                INTO rec_c_garantie;

               EXIT WHEN c_garantie%NOTFOUND;
               --
               p_sel_frml_prime (i_numfor => rec_c_garantie.numfor);
            --
            END LOOP;

            CLOSE c_garantie;
         END LOOP;

         CLOSE c_gar_cntrt;
      --
      ELSIF g_etendue = 2
      THEN                                                         -- Adhesion
         p_sel_adhesion (i_numgar => i_numgar, o_r_contrat => g_r_contrat);

         --
         /* Si le parametre I_numfor est passé a Null(a partir du trigger
            gc01 de la forme ad01.inp) alors les différents tests dans
            "P_recurs_evaluation" se font par rapport a date du jour
            Sinon les tests se font a partir de la date de adhesion
         */
         IF i_numfor IS NULL
         THEN
            --  G_R_contrat.edebut := d2j(SYSDATE);
            /*  Mis en commentaire par JPf 10102005 car si date effet adhesion> sysdate multiplication des variables
            et remplacé par le select suivant*/
            SELECT NVL (d2j (MIN (datapli)), d2j (SYSDATE))
              INTO g_r_contrat.edebut
              FROM adhesion
             WHERE idadhesion = g_r_contrat.idadhesion
               AND numindiv = g_numindiv;
         END IF;

         -- Recherche des infos(date et garantie) dans adhesion
         OPEN c_adhesion (p_numindiv        => g_numindiv,
                          p_idadhesion      => g_r_contrat.idadhesion,
                          p_numfor          => i_numfor
                         );

         LOOP
            FETCH c_adhesion
             INTO rec_c_adhesion;

            EXIT WHEN c_adhesion%NOTFOUND;
            -- Dans tous les cas, on insere dans val_variable la date de adhesion
            g_r_contrat.insdate := rec_c_adhesion.datapli;

            --
            -- Si le numfor est passe en parametre alors les tests se font a
            -- partir de la date de adhesion
            IF i_numfor IS NOT NULL
            THEN
               g_r_contrat.edebut := rec_c_adhesion.datapli;
            END IF;

            --
            g_idligne := 9;
            g_msg_adm :=
                  'Recherche adhesion, idadhesion : '
               || TO_CHAR (g_r_contrat.idadhesion)
               || ' Numfor : '
               || TO_CHAR (rec_c_adhesion.numfor)
               || ' Date : '
               || TO_CHAR (j2d (g_r_contrat.insdate), 'DD/MM/YYYY');
            p_appel_pk_trace;

            --
            OPEN c_garantie (rec_c_adhesion.numfor);

            LOOP
               FETCH c_garantie
                INTO rec_c_garantie;

               EXIT WHEN c_garantie%NOTFOUND;
               --
               p_sel_frml_prime (i_numfor => rec_c_garantie.numfor);
            --
            END LOOP;

            CLOSE c_garantie;
         END LOOP;

         CLOSE c_adhesion;
      --
      ELSIF g_etendue = 5
      THEN                                                      -- Proposition
         p_sel_proposition (i_numgar         => i_numgar,
                            o_r_contrat      => g_r_contrat);
         --
         g_numindiv := 0;
         --
         p_sel_frml_prime (i_numfor => i_numfor);
      END IF;

      --
      IF g_flag_insert = 1
      THEN
         -- Retour code message pour affichage message concernant
         -- les donnees complementaires
         o_code_msg := 1171;
      ELSIF g_flag_insert = 2
      THEN
         -- Retour code message pour affichage message concernant
         -- les donnees complementaires
         o_code_msg := 1172;
      ELSE
         o_code_msg := NULL;
      END IF;

      --
      g_idligne := 30;
      g_msg_adm := 'Fin de traitement PK_insert_var.P_INS_val_var';
      p_appel_pk_trace;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         l_code_msg := 20001;
         --
         -- Recherche du message dans la table
         l_lib_msg :=
            pk_trace.f_aff_mess_err (i_code_msg         => l_code_msg,
                                     i_code_pays        => i_code_pays,
                                     i_liste_param      => g_nom_traitement
                                    );
         --
         -- message de la table + erreur Oracle
         l_lib_msg :=
            l_lib_msg
            || SUBSTR (SQLERRM (SQLCODE), 1, 80 - LENGTH (l_lib_msg));
         --
         -- Retour du message vers les postes clients(sqlforms)
         raise_application_error ((l_code_msg * -1), l_lib_msg);
   END;
-- ========================== Fin des corps des procedures publiques===========
--
END;
/
