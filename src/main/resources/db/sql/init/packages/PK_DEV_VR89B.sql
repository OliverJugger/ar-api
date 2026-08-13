CREATE OR REPLACE PACKAGE ARTHUS."PK_DEV_VR89B"
AS
--
   PROCEDURE p_dev_vr89b (
      i_deb_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_fin_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_deb_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_fin_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_session       IN       NUMBER DEFAULT 1,
      i_niv_msg       IN       NUMBER DEFAULT 1,
      i_pause         IN       NUMBER DEFAULT 0,
      o_found         OUT      NUMBER,
      o_erreur        OUT      VARCHAR2
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

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_DEV_VR89B"
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

   --
   PROCEDURE p_fin_traitement;

--
   PROCEDURE p_corps_sel_numcpte;

--
   PROCEDURE p_sel_decaismt;

--
   PROCEDURE p_sel_piece_contrat;

--
   PROCEDURE p_sel_remise_op_detail;

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

   -- Variables globales privees
--
   g_numcpte                        vs_compte.numcpte%TYPE;
   g_libcompte                      vs_compte.libcompte%TYPE;
   g_monnaiecompte                  vs_compte.monnaie%TYPE;
--
   g_decaismt_numdecaismt           decaismt.numdecaismt%TYPE;
   g_decaismt_montant               decaismt.montant%TYPE;
   g_decaismt_monnaie               decaismt.monnaie%TYPE;
   g_decaismt_montant_d             decaismt.montant_d%TYPE;
   g_decaismt_monnaie_d             decaismt.monnaie_d%TYPE;
   g_decaismt_numbene               decaismt.numbene%TYPE;
   g_decaismt_numdest               decaismt.numdest%TYPE;
   g_decaismt_codope                decaismt.codope%TYPE;
   g_decaismt_modpmt                decaismt.modpmt%TYPE;
   g_decaismt_nombene               VARCHAR2 (60);
--
   g_min_numgar                     contrat.numgar%TYPE;
   g_numgar_pie                     contrat.numgar%TYPE;
   g_nb_numgar                      NUMBER (10);
--

   --G_monnaie    NUMBER(3);
   g_monnaie_old                    NUMBER (3);
--G_monnaie_d     NUMBER(3);
   g_monnaie_old_d                  NUMBER (3);
   g_modpmt_old                     decaismt.modpmt%TYPE;
   g_idrib                          rib.idrib%TYPE;
   g_idrib_old                      rib.idrib%TYPE;         -- JPF 22/02/2005
--
   g_pie_contrat_trouve             VARCHAR2 (1);
   g_rib_existe                     VARCHAR2 (1);
   g_vire_detail_ins                VARCHAR2 (1);
--
   g_rib_codbque                    rib.codbque%TYPE;
   g_rib_guichet                    rib.guichet%TYPE;
   g_rib_compte                     rib.compte%TYPE;
   g_rib_clerib                     rib.clerib%TYPE;
   g_rib_intitule                   rib.intitule%TYPE;
   g_rib_clef_iban                  rib.clef_iban%TYPE;
   g_rib_bban                       rib.bban%TYPE;
   g_rib_bic                        rib.bic%TYPE;
   g_rib_codpays                    rib.codpays%TYPE;
   g_rib_codbque_etrg               rib.codbque_etrg%TYPE;
   g_rib_guichet_etrg               rib.guichet_etrg%TYPE;
   g_rib_compte_etrg                rib.compte_etrg%TYPE;
   g_rib_clerib_etrg                rib.clerib_etrg%TYPE;
   g_rib_typ_bq_etrg                rib.typ_bq_etrg%TYPE;
   g_rib_typ_gui_etrg               rib.typ_gui_etrg%TYPE;
   g_rib_typ_cle_etrg               rib.typ_cle_etrg%TYPE;
   g_rib_numindiv_etrg              rib.numindiv_etrg%TYPE;
--
   g_premier_virement               VARCHAR2 (1);
--
   g_rib_codbque_old                rib.codbque%TYPE;
   g_rib_guichet_old                rib.guichet%TYPE;
   g_rib_compte_old                 rib.compte%TYPE;
   g_rib_clerib_old                 rib.clerib%TYPE;
   g_rib_intitule_old               rib.intitule%TYPE;
   g_rib_clef_iban_old              rib.clef_iban%TYPE;
   g_rib_bban_old                   rib.bban%TYPE;
   g_rib_bic_old                    rib.bic%TYPE;
   g_rib_codpays_old                rib.codpays%TYPE;
   g_rib_nature                     rib.nature%TYPE;
--
   g_numremise                      remise_op.numremise%TYPE;
   g_numremise_init                 remise_op.numremise%TYPE;
   g_numvirement                    remise_op_detail.numvirement%TYPE;
   g_datrem                         remise_op.datrem%TYPE;
   g_nombre                         remise_op.nombre%TYPE;
   g_valide                         remise_op.valide%TYPE;
   g_remise_op_detail_numvirement   remise_op_detail.numvirement%TYPE;
   g_remise_op_detail_numdecaismt   remise_op_detail.numdecaismt%TYPE;
                                                            -- JPF 22/02/2005
--
-- parametres du traitement
   g_numcpte_deb                    vs_compte.numcpte%TYPE;
   g_numcpte_fin                    vs_compte.numcpte%TYPE;
   g_codope_deb                     decaismt.codope%TYPE;
   g_codope_fin                     decaismt.codope%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
   g_commit                         BOOLEAN                          := FALSE;
   g_rollback                       BOOLEAN                          := FALSE;
   g_auto_valide                    BOOLEAN                          := FALSE;
--
   g_flag_test                      NUMBER;
   g_proc                           VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement        CONSTANT journal_adm.nom_traitement%TYPE
                                                       DEFAULT 'pk_dev_vr89B';
   g_msg_adm                        journal_adm.msg_adm%TYPE;
   g_session                        journal_adm.id_session%TYPE     DEFAULT 1;
   g_niv_msg                        journal_adm.niv_msg%TYPE            := 1;
   g_max_msg                        journal_adm.niv_msg%TYPE            := 1;
   g_idligne                        journal_adm.idligne%TYPE            := 0;
   g_erreur                         journal_adm.msg_adm%TYPE;

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
      SELECT   vs_compte.numcpte, vs_compte.libcompte, vs_compte.monnaie
          FROM vs_compte
         WHERE vs_compte.numcpte BETWEEN NVL (g_numcpte_deb,
                                              vs_compte.numcpte
                                             )
                                     AND NVL (g_numcpte_fin,
                                              NVL (g_numcpte_deb,
                                                   vs_compte.numcpte
                                                  )
                                             )
      GROUP BY vs_compte.numcpte, vs_compte.libcompte, vs_compte.monnaie;

--
   CURSOR c_sel_decaismt
   IS
      SELECT distinct
			   decaismt.numdecaismt, decaismt.montant, decaismt.monnaie,
               decaismt.montant_d, decaismt.monnaie_d, decaismt.numbene,
               f_bene_rib (decaismt.numdest,
                           decaismt.codope,
                           pk_qttc.f_sel_numgar (dcpt.numgar),
                           1
                           ,decaismt.monnaie_d
                           ,sysdate
                          ) idrib,
               decaismt.numdest, decaismt.codope, decaismt.modpmt,
               indvs.nom || indvs.prenom nombene
          FROM decaismt, dcpt, affectation, indvs, compte
         WHERE decaismt.numcpte = compte.numcpte
           AND decaismt.flagpay = -1
           AND decaismt.numutil + 0 >= 0
           AND decaismt.montant + 0 > 0
           AND decaismt.modpmt IN (2, 3, 7)
           AND decaismt.numcpte = g_numcpte
           AND decaismt.numbene = indvs.numindiv
           AND dcpt.numdec = affectation.numaffec
           AND affectation.numdecaismt = decaismt.numdecaismt
           AND decaismt.codope BETWEEN NVL (g_codope_deb, decaismt.codope)
                                   AND NVL (g_codope_fin,
                                            NVL (g_codope_deb,
                                                 decaismt.codope)
                                           )
           AND NOT EXISTS (
                  SELECT 1
                    FROM remise_op_detail
                   WHERE remise_op_detail.numdecaismt = decaismt.numdecaismt
                  UNION
                  SELECT 1
                    FROM remise_vire_detail
                   WHERE remise_vire_detail.numdecaismt = decaismt.numdecaismt)
      ORDER BY monnaie_d, modpmt, idrib;
                                     -- JPF 22/02/2005 rajout decaismt.numbene

--
---- Curseur - pièces affectées à un décaissement
--
   CURSOR c_pie_contrat (i_numdecaismt NUMBER)
   IS
      SELECT codope, numaffec
        FROM affectation
       WHERE affectation.numdecaismt = i_numdecaismt;

-- David 08/02/2005
/*CURSOR C_sel_remise_op_detail is
   SELECT   b.numvirement
   FROM  remise_op_detail b
   WHERE b.numremise = G_numremise;   */

   -- JPF 22/02/2005
   CURSOR c_sel_remise_op_detail
   IS
      SELECT b.numdecaismt
        FROM remise_op_detail b
       WHERE b.numremise BETWEEN g_numremise_init AND g_numremise;

--
--
------------------------------------------------------------------
--
-- Le corps des differentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_dev_vr89b (
      i_deb_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_fin_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_deb_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_fin_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_session       IN       NUMBER DEFAULT 1,
      i_niv_msg       IN       NUMBER DEFAULT 1,
      i_pause         IN       NUMBER DEFAULT 0,
      o_found         OUT      NUMBER,
      o_erreur        OUT      VARCHAR2
   )
   IS
      r_sel_numcpte   c_sel_numcpte%ROWTYPE;
   BEGIN
      --
      o_found := 1;
      g_erreur := NULL;
      --
      g_numcpte_deb := i_deb_numcpte;
      g_numcpte_fin := i_fin_numcpte;
      g_codope_deb := i_deb_codope;
      g_codope_fin := i_fin_codope;
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
         --
         g_niv_msg := 1;
         g_msg_adm :=
               'Debut de traitement le '
            || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
         p_ins_journal;

         -- Fin ecriture dans le Journal
         OPEN c_sel_numcpte;
      --
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
         g_numcpte := r_sel_numcpte.numcpte;
         g_libcompte := r_sel_numcpte.libcompte;
         g_monnaiecompte := r_sel_numcpte.monnaie;
--
--*debogage debut
         g_niv_msg := 3;
         g_msg_adm :=
               'compte treso n° '
            || TO_CHAR (g_numcpte)
            || ' - '
            || TO_CHAR (g_libcompte);
         p_ins_journal;
--*debogage fin
--
         p_corps_sel_numcpte;
--
      END IF;

      --
      o_erreur := g_erreur;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'PK_DEV_vr89B - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         CLOSE c_sel_numcpte;
   END;

--
--------------------------
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
   --
      SELECT NVL (MAX (numremise), 0) + 1
        INTO g_numremise
        FROM remise_op;

      g_numremise_init := g_numremise;
      --
      g_vire_detail_ins := 'N';
      --
      p_sel_decaismt;

      --
      -- test si virement détail insérés parmi les décaissements pour ce G_numcpte !
      IF g_vire_detail_ins = 'O'
      THEN
         -- David 08/02/2005
         p_sel_remise_op_detail;
         --
         g_proc :=
                g_proc || ' - Ins remise_op Bdx n° ' || TO_CHAR (g_numremise);

         --
         INSERT INTO remise_op
                     (numremise, numcpte, datrem, nombre, montant, monnaie,
                      montant_d, monnaie_d, valide)
            SELECT   numremise, numcpte, TRUNC (SYSDATE),
                     COUNT (DISTINCT numvirement), SUM (montant), monnaie,
                     SUM (montant_d), monnaie_d, 'N'
                FROM remise_op_detail
               WHERE remise_op_detail.numremise BETWEEN g_numremise_init
                                                    AND g_numremise
            GROUP BY numremise, numcpte, monnaie_d, monnaie, modpmt;
      END IF;
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
-- David 08/02/2005
   PROCEDURE p_sel_remise_op_detail
   IS
      r_sel_remise_op_detail   c_sel_remise_op_detail%ROWTYPE;
      l_montant_ct             NUMBER (15, 2);
      l_monnaie_ct             NUMBER (3);
   BEGIN
--
      g_proc := 'P_sel_remise_op_detail';

--
      OPEN c_sel_remise_op_detail;

      --
      g_premier_virement := 'O';

      --
      LOOP
         FETCH c_sel_remise_op_detail
          INTO r_sel_remise_op_detail;

         EXIT WHEN c_sel_remise_op_detail%NOTFOUND;
         --
         -- G_remise_op_detail_numvirement:= R_sel_remise_op_detail.numvirement;  -- JPF 22/02/2005
         g_remise_op_detail_numdecaismt := r_sel_remise_op_detail.numdecaismt;
                                                            -- JPF 22/02/2005

         SELECT   NVL (SUM (mtreel_ct), 0), dev_ct
             INTO l_montant_ct, l_monnaie_ct
             FROM sinistre_dev,
                  sinistre,
                  dcpt,
                  affectation,
                  decaismt,
                  remise_op_detail
            WHERE sinistre_dev.numsin = sinistre.numsin
              AND dcpt.numdec = sinistre.numdec
              AND affectation.numaffec = dcpt.numdec
              AND decaismt.numdecaismt = affectation.numdecaismt
              AND remise_op_detail.numdecaismt = decaismt.numdecaismt
              -- And     remise_op_detail.numvirement=G_remise_op_detail_numvirement   -- JPF 22/02/2005
              AND remise_op_detail.numdecaismt =
                               g_remise_op_detail_numdecaismt
                                                             -- JPF 22/02/2005
         GROUP BY dev_ct;

         IF l_montant_ct = 0
         THEN
            EXIT;
         ELSE
            UPDATE remise_op_detail a
               SET a.montant_ct = l_montant_ct,
                   a.monnaie_ct = l_monnaie_ct
             WHERE numdecaismt = g_remise_op_detail_numdecaismt;
                                                             -- JPF 22/02/2005
         --WHERE numvirement=G_remise_op_detail_numvirement;   -- JPF 22/02/2005
         END IF;

         --
         --
         --*debogage debut
         g_niv_msg := 3;
         g_msg_adm :=
               'upd remise_op_detail n° '
            || TO_CHAR (g_remise_op_detail_numvirement)
            || ' - '
            || 'remise n° '
            || TO_CHAR (g_numremise);
         p_ins_journal;
      --*debogage fin
      --
      END LOOP;

      CLOSE c_sel_remise_op_detail;
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
--------------------------
   PROCEDURE p_sel_piece_contrat
   IS
      r_piece_contrat   c_pie_contrat%ROWTYPE;
   BEGIN
--
      g_proc := 'P_sel_piece_contrat';

--
--
      OPEN c_pie_contrat (g_decaismt_numdecaismt);

--
      g_min_numgar := 0;
      g_numgar_pie := 0;
      g_nb_numgar := 0;
--
      g_pie_contrat_trouve := 'N';

--
      LOOP
         FETCH c_pie_contrat
          INTO r_piece_contrat;

         --
         IF c_pie_contrat%NOTFOUND
         THEN
            CLOSE c_pie_contrat;

            EXIT;
         ELSE
            --
            BEGIN
               g_numgar_pie :=
                  NVL
                     (pk_qttc.f_sel_numgar
                                    (f_piece_contrat (r_piece_contrat.codope,
                                                      r_piece_contrat.numaffec
                                                     )
                                    ),
                      0
                     );
               g_pie_contrat_trouve := 'O';

               --
               IF ((g_numgar_pie < g_min_numgar) AND g_numgar_pie <> 0)
               THEN
                  g_min_numgar := g_numgar_pie;
                  g_nb_numgar := g_nb_numgar + 1;
               ELSIF g_numgar_pie > g_min_numgar
               THEN
                  g_nb_numgar := g_nb_numgar + 1;
               END IF;
            --
            EXCEPTION
               WHEN OTHERS
               THEN
                  g_numgar_pie := 0;
                  g_pie_contrat_trouve := 'N';
                  --
                  --*msg debut
                  g_niv_msg := 2;
                  g_msg_adm :=
                        'Le decaismt n° '
                     || TO_CHAR (g_decaismt_numdecaismt)
                     || ' a un probleme de référence pièce - contrat ';
                  p_ins_journal;

                  --*msg fin
                  --
                  CLOSE c_pie_contrat;

                  EXIT;
            END;
         --
         END IF;
      --
      END LOOP;
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
   PROCEDURE p_sel_decaismt
   IS
      r_sel_decaismt   c_sel_decaismt%ROWTYPE;
   BEGIN
--
      g_proc := 'P_sel_decaismt';

--
--OPEN C_sel_decaismt;
      LOOP
         IF NOT c_sel_decaismt%ISOPEN
         THEN
            OPEN c_sel_decaismt;

            FETCH c_sel_decaismt
             INTO r_sel_decaismt;

            EXIT WHEN c_sel_decaismt%NOTFOUND;
            g_decaismt_numdecaismt := r_sel_decaismt.numdecaismt;
            g_decaismt_montant := r_sel_decaismt.montant;
            g_decaismt_monnaie := r_sel_decaismt.monnaie;
            g_decaismt_montant_d := r_sel_decaismt.montant_d;
            g_decaismt_monnaie_d := r_sel_decaismt.monnaie_d;
            g_decaismt_numbene := r_sel_decaismt.numbene;
            --G_idrib                      := R_sel_decaismt.idrib;
            g_decaismt_numdest := r_sel_decaismt.numdest;
            g_decaismt_codope := r_sel_decaismt.codope;
            g_decaismt_modpmt := r_sel_decaismt.modpmt;
            g_decaismt_nombene := r_sel_decaismt.nombene;
            --G_monnaie_old  :=G_decaismt_monnaie;
            g_monnaie_old_d := 0;
            g_modpmt_old := 0;
            g_idrib_old := 0;
         ELSE
            g_monnaie_old_d := g_decaismt_monnaie_d;
            g_modpmt_old := g_decaismt_modpmt;
            g_idrib_old := g_idrib;

            FETCH c_sel_decaismt
             INTO r_sel_decaismt;

            EXIT WHEN c_sel_decaismt%NOTFOUND;
            g_decaismt_numdecaismt := r_sel_decaismt.numdecaismt;
            g_decaismt_montant := r_sel_decaismt.montant;
            g_decaismt_monnaie := r_sel_decaismt.monnaie;
            g_decaismt_montant_d := r_sel_decaismt.montant_d;
            g_decaismt_monnaie_d := r_sel_decaismt.monnaie_d;
            g_decaismt_numbene := r_sel_decaismt.numbene;
            --G_idrib                      := R_sel_decaismt.idrib;
            g_decaismt_numdest := r_sel_decaismt.numdest;
            g_decaismt_codope := r_sel_decaismt.codope;
            g_decaismt_modpmt := r_sel_decaismt.modpmt;
            g_decaismt_nombene := r_sel_decaismt.nombene;

            IF    g_monnaie_old_d != g_decaismt_monnaie_d
               OR g_modpmt_old != g_decaismt_modpmt
            THEN
               g_numremise := g_numremise + 1;
            END IF;
         END IF;

--
         p_sel_piece_contrat;

         --
         --
         IF g_pie_contrat_trouve = 'N'
         THEN
--
--*msg debut
            g_niv_msg := 2;
            g_msg_adm :=
                  'Le decaismt n° '
               || TO_CHAR (g_decaismt_numdecaismt)
               || ' n"a pas de référence pièce - contrat ';
            p_ins_journal;
            g_niv_msg := 2;
            g_msg_adm :=
               'Les références bancaires générales de ce bénéficiaire ne sont pas définies';
            p_ins_journal;
--*msg fin
--
         ELSE
            -- P_rech_idrib;
            BEGIN
               g_idrib :=
                  f_bene_rib (g_decaismt_numdest,
                              g_decaismt_codope,
                              g_min_numgar,
                              1
                              ,G_decaismt_monnaie_d
                              ,sysdate
                             );

               --
               BEGIN
                  SELECT rib.codbque, rib.guichet, rib.compte,
                         rib.clerib, rib.intitule, rib.clef_iban,
                         rib.bban, rib.bic, rib.codpays,
                         rib.codbque_etrg, rib.guichet_etrg,
                         rib.compte_etrg, rib.clerib_etrg,
                         rib.typ_bq_etrg, rib.typ_gui_etrg,
                         rib.typ_cle_etrg, rib.numindiv_etrg,
                         rib.nature
                    INTO g_rib_codbque, g_rib_guichet, g_rib_compte,
                         g_rib_clerib, g_rib_intitule, g_rib_clef_iban,
                         g_rib_bban, g_rib_bic, g_rib_codpays,
                         g_rib_codbque_etrg, g_rib_guichet_etrg,
                         g_rib_compte_etrg, g_rib_clerib_etrg,
                         g_rib_typ_bq_etrg, g_rib_typ_gui_etrg,
                         g_rib_typ_cle_etrg, g_rib_numindiv_etrg,
                         g_rib_nature
                    --
                  FROM   rib
                   WHERE idrib = g_idrib;

                  --AND clerib is not null
                  --;
                  --
                  g_rib_existe := 'O';
               --
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     g_rib_existe := 'N';
               END;
            --
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  g_rib_existe := 'N';
            END;

            --
            IF g_rib_existe = 'N'
            THEN
               --
               --*msg debut
               g_niv_msg := 2;
               g_msg_adm :=
                     'Le RIB du decaismt n° '
                  || TO_CHAR (g_decaismt_numdecaismt)
                  || ' destiné à '
                  || g_decaismt_nombene
                  || ' n" est pas défini ';
               p_ins_journal;
            --*msg fin
            --
            ELSIF (g_nb_numgar > 1 AND g_min_numgar != 0)
            THEN
               --
               --*msg debut
               g_niv_msg := 2;
               g_msg_adm :=
                     'Le decaismt n° '
                  || TO_CHAR (g_decaismt_numdecaismt)
                  || ' concerne plusieurs contrats ';
               p_ins_journal;
               g_niv_msg := 2;
               g_msg_adm :=
                  'Les références bancaires générales de ce bénéficiaire ne sont pas définies';
               p_ins_journal;
            --*msg fin
            --
            ELSIF     g_decaismt_monnaie = g_decaismt_monnaie_d
                  AND g_decaismt_modpmt = 2
                  AND g_rib_codpays = pk_devise.pays_ref
                  AND g_rib_nature = 2
                  AND g_monnaiecompte = g_decaismt_monnaie
            THEN
               g_niv_msg := 2;
               g_msg_adm :=
                     'Le decaismt n° '
                  || TO_CHAR (g_decaismt_numdecaismt)
                  || ' sera pris dans les virements';
               p_ins_journal;
            ELSE
               g_vire_detail_ins := 'O';
               --
               --*debogage debut
               g_niv_msg := 3;
               g_msg_adm :=
                     'ins remise_op_detail decaismt n° '
                  || TO_CHAR (g_decaismt_numdecaismt)
                  || ' - '
                  || 'G_idrib n° '
                  || TO_CHAR (g_idrib);
               p_ins_journal;

               --*debogage fin

               --David 30/12/2004
               IF (   g_idrib_old != g_idrib
                   OR g_monnaie_old_d != g_decaismt_monnaie_d
                   OR g_modpmt_old != g_decaismt_modpmt
                  )
               THEN                                          -- JPF 22/02/2005
                  SELECT numop.NEXTVAL
                    INTO g_numvirement
                    FROM DUAL;
               END IF;

               --G_idrib_old  :=G_idrib;        -- JPF 22/02/2005
                                   --G_monnaie_old_d :=G_decaismt_monnaie_d;
                                   --G_modpmt_old    :=G_decaismt_modpmt;
               INSERT INTO remise_op_detail
                           (numremise, numcpte, numvirement,
                            numdecaismt, montant,
                            monnaie, montant_d,
                            monnaie_d, modpmt,
                            codbque, guichet, compte,
                            clerib, intitule, clef_iban,
                            bban, bic, codpays,
                            codbque_etrg, guichet_etrg,
                            compte_etrg, clerib_etrg,
                            typ_bq_etrg, typ_gui_etrg,
                            typ_cle_etrg, numindiv_etrg,
                            nature
                           )
                    --
               VALUES      (g_numremise, g_numcpte, g_numvirement,
                            g_decaismt_numdecaismt, g_decaismt_montant,
                            g_decaismt_monnaie, g_decaismt_montant_d,
                            g_decaismt_monnaie_d, g_decaismt_modpmt,
                            g_rib_codbque, g_rib_guichet, g_rib_compte,
                            g_rib_clerib, g_rib_intitule, g_rib_clef_iban,
                            g_rib_bban, g_rib_bic, g_rib_codpays,
                            g_rib_codbque_etrg, g_rib_guichet_etrg,
                            g_rib_compte_etrg, g_rib_clerib_etrg,
                            g_rib_typ_bq_etrg, g_rib_typ_gui_etrg,
                            g_rib_typ_cle_etrg, g_rib_numindiv_etrg,
                            g_rib_nature
                           );
            END IF;
         END IF;
      END LOOP;

      CLOSE c_sel_decaismt;
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
