CREATE OR REPLACE PACKAGE ARTHUS.PK_COMPTA AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_compta.sql  1.4  01/08/09
--
-- SCR 20090716 : ajout compte_aux et alimentation des zonex de 6 a 13
-- ACA 20100617 : ajout de la table maître reversement (OC511)
-- ACA 20100622 : ajout des tables maîtres decompte_annul et affectation_annul (OC121 et OC122)
-- ACA 20100623 : ajout/modif paramètre codope_entite sur les procédures p_upd_facture, p_upd_compte_client et p_upd_affectation.
--                MàJ effectuée pour prendre en compte les différents codes ope possibles sur les tables facture, compte_client et affectation.
--                La donnée à renseigner dans les vues est scdope. Vues impactées : 331, 332, 342, 731, 732, 112 et 512.
-- ACA 23082010 : - mise à jour des tables d'annulation à l'annulation du bordereau comptable
--                - mise à jour de l'idcompta_init des tables d'annulation à la comptabilisation 'positive'
-- SBA 20110919 : L'operation comptable 132 relatant un numero d'affectation, l'appel a la procedure <p_upd_affectation> a ete remplace par <p_upd_affec_enc>
-- ABO 20120412 : Ajout de trace et du defaire_transaction syst‚matique pour ‚viter en cas de plantage d'une OC, un m‚lange de donn‚es dans OC + optimisation
-- ABO 20120821 : Ajout du regroupement sur le compte auxiliaire REG35
-- ============================================================================
-- CONSTANTES PUBLIQUE
-- Aucune
-- ============================ Fin des Constantes Publiques ==================

-- ============================================================================
-- EXCEPTIONS PUBLIQUES
-- Aucune
-- ============================ Fin des Exceptions Publiques ==================

-- ============================================================================
-- TYPES PUBLIQUES
-- Aucun
-- ========================== Fin des types publiques =========================

-- ============================================================================
-- VARIABLES PUBLIQUES
-- Variables de Trace Servant au journal_adm
--
-- G_niv_msg prend 2 Valeurs 1 --> Message informatif(tout se passe bien)
--                           2 --> Message d'erreurs (Erreur ORACLE)
--
-- G_nom_traitement journal_adm.nom_traitement%TYPE;
G_lib_msg        journal_adm.msg_adm%TYPE;
--G_session        journal_adm.id_session%TYPE;
--G_niv_msg        journal_adm.niv_msg%TYPE;
--
G_nb_uple_inserer NUMBER;
 --
-- Variables de P_INS_journal

G_nom_traitement  Constant journal_adm.nom_traitement%TYPE default 'PK_Compta';
G_msg_adm    journal_adm.msg_adm%TYPE;
G_session    journal_adm.id_session%TYPE default 1;
G_niv_msg    journal_adm.niv_msg%TYPE := 1;
G_max_msg    journal_adm.niv_msg%TYPE := 3;
G_idligne    journal_adm.idligne%TYPE := 0;
G_erreur    journal_adm.msg_adm%TYPE;


-- G_niv_msg prend les Valeurs :
--  0 --> Message d'erreurs (Erreur ORACLE)
--  1 --> Message informatif(tout se passe bien)
--  2 et + Niveau de detail

-- ========================== Fin des Variables publiques =====================

-- ============================================================================
-- PROCEDURES ET FONCTIONS PUBLIQUES
--
PROCEDURE P_DEFAIRE_transaction(I_idcompta IN compta.idcompta%TYPE);
--
PROCEDURE P_SEL_ECRITURE
( I_numsoc         IN V_compta.numsoc%TYPE,
  I_deb_codope     IN V_compta.codope%TYPE DEFAULT NULL,
  I_fin_codope     IN V_compta.codope%TYPE DEFAULT NULL,
  I_date_debut     IN DATE DEFAULT NULL,
  I_date_fin       IN DATE DEFAULT NULL,
  I_session        IN NUMBER DEFAULT 1

);
--
Procedure P_centralise (
    I_idcompta  IN compta.idcompta%type,
    I_QueRefP   IN NUMBER default 0
    );
   FUNCTION f_lib_ventil (
      i_numsoc     IN   compta.numsoc%TYPE,
      i_codope     IN   compta.codope%TYPE,
      i_scdope     IN   compta.scdope%TYPE,
      i_rolesoc    IN   compta.rolesoc%TYPE,
      i_numordre   IN   compta.numordre%TYPE
   )
      RETURN VARCHAR2;

FUNCTION F_LIB_ECRITURE (I_numsoc    IN Compta.numsoc%TYPE,
                         I_codope    IN Compta.codope%TYPE,
                         I_type_ope  IN Compta.type_ope%TYPE,
                         I_lib_piece_1 IN Compta.lib_piece_1%TYPE DEFAULT NULL,
                         I_lib_piece_2 IN Compta.lib_piece_2%TYPE DEFAULT NULL,
                         I_central   IN Compta.central%TYPE DEFAULT 'N')
                RETURN VARCHAR2;
-- Pragma Restrict_References(F_LIB_ECRITURE, WNDS,WNPS);

--
-- ========================== Fin des Procedures publiques ====================
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_compta
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_compta.sql 1.4   01/08/09

   -- ============================================================================
-- CONSTANTES PRIVEES
   l_cst_decaissement         CONSTANT compta.entite%TYPE  DEFAULT 'decaismt';
   l_cst_encaissement         CONSTANT compta.entite%TYPE  DEFAULT 'encaismt';
   l_cst_annul_encaissement   CONSTANT compta.entite%TYPE   DEFAULT 'annul';
   l_cst_facture              CONSTANT compta.entite%TYPE   DEFAULT 'facture';
   l_cst_compte_client        CONSTANT compta.entite%TYPE
                                                      DEFAULT 'compte_client';
   l_cst_compte_tiers         CONSTANT compta.entite%TYPE
                                                      DEFAULT 'compte_tiers';--ACA251010
   l_cst_facture_annul        CONSTANT compta.entite%TYPE
                                                         DEFAULT 'fact_annul';
   l_cst_decompte             CONSTANT compta.entite%TYPE  DEFAULT 'decompte';
   l_cst_facture_regul        CONSTANT compta.entite%TYPE
                                                         DEFAULT 'fact_regul';
   l_cst_pnul                 CONSTANT compta.entite%TYPE  DEFAULT 'pnul';
   l_cst_affectation          CONSTANT compta.entite%TYPE  DEFAULT 'affectation';
   l_cst_affec_enc            CONSTANT compta.entite%TYPE  DEFAULT 'affec_enc';   -- SBA, le 19/9/2011 : L'operation comptable 132 relatant un numero d'affectation, l'appel a la procedure <p_upd_affectation> a ete remplace par <p_upd_affec_enc>
   l_cst_reversement          CONSTANT compta.entite%TYPE  DEFAULT 'reversement'; --ACA170610
   l_cst_retrocession         CONSTANT compta.entite%TYPE  DEFAULT 'retrocession'; --ACA251010
   l_cst_decompte_annul       CONSTANT compta.entite%TYPE  DEFAULT 'dcpte_annul'; --ACA220610
   l_cst_affectation_annul    CONSTANT compta.entite%TYPE  DEFAULT 'affec_annul'; --ACA220610
-- CTT : Plus de rollback segment pour les tests  L_CST_Rollback_segment        CONSTANT VARCHAR2(32) DEFAULT 'rbs_batch';
   l_cst_rollback_segment     CONSTANT VARCHAR2 (32)        DEFAULT NULL;
   l_cst_compte_equilibre     CONSTANT compta.compte%TYPE DEFAULT 'CPT_EQUIL';

   --4740000';

   --
-- ========================== Fin des constantes privees ======================

   -- ============================================================================
-- -- EXCEPTIONS PRIVEES
-- Aucune
-- ========================== Fin des exceptions privees ======================

   -- ============================================================================
-- TYPES PRIVEES
-- Aucun
-- ========================== Fin des types privees ===========================

   -- ============================================================================
-- VARIABLES GLOBALES PRIVEES
-- Aucune
-- ===================== Fin des variables globales privees ===================

   -- ============================================================================
-- DEFINITION DES PROCEDURES PRIVEES
--
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

--  CTT : maintenu pour coexistence avec utilisation du package PK_Trace...
   PROCEDURE p_ins_journal_adm (
      i_nom_traitement   journal_adm.nom_traitement%TYPE,
      i_session          journal_adm.id_session%TYPE,
      i_niv_msg          journal_adm.niv_msg%TYPE,
      i_msg_adm          journal_adm.msg_adm%TYPE,
      i_date             journal_adm.date_adm%TYPE DEFAULT SYSDATE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION; /* ACA */
   BEGIN
      --
      INSERT INTO journal_adm
                  (nom_traitement, id_session, niv_msg, msg_adm, date_adm
                  )
           VALUES (i_nom_traitement, i_session, i_niv_msg, i_msg_adm, i_date
                  );
      COMMIT; /* ACA */
   END;

--
   PROCEDURE p_use_rollback_commit (i_rollback_segment IN VARCHAR2)
   IS
   BEGIN
      COMMIT;
-- IF I_rollback_segment Is Not Null THEN
--  DBMS_TRANSACTION.use_rollback_segment(I_rollback_segment);
-- END IF;
   END;

--
   PROCEDURE p_upd_decaissement (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   -- CTT 13/01/2004 I_codope_entite IN V_compta.codope%TYPE)
   IS
   BEGIN
      UPDATE decaismt
         SET idcompta = i_idcompta
       WHERE numdecaismt = i_cle;
--  And       codope      = I_codope_entite;
   END;

--
   PROCEDURE p_upd_encaissement (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   -- CTT 13/01/2004 I_codope_entite IN V_compta.codope%TYPE)
   IS
   BEGIN
      UPDATE encaismt
         SET idcompta = i_idcompta
       WHERE numencaismt = i_cle;
-- And       codope      = I_codope_entite;
   END;

--
   PROCEDURE p_upd_annul_encaissement (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   IS
   BEGIN
      UPDATE annul_encais
         SET idcompta = i_idcompta
       WHERE numencaismt = i_cle;
   END;

--
   PROCEDURE p_upd_facture (
      i_idcompta        IN   remise_compta.idcompta%TYPE,
      i_cle             IN   v_compta.cle%TYPE,
      i_codope_entite   IN   v_compta.scdope%TYPE
   )
   IS
   BEGIN
      UPDATE facture
         SET idcompta = i_idcompta
       WHERE numfact = i_cle AND codope = to_number(i_codope_entite);
   END;

--
   PROCEDURE p_upd_facture_annul (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   -- CTT 13/01/2004 I_codope_entite IN V_compta.codope%TYPE)
   IS
   BEGIN
      UPDATE facture_annul
         SET idcompta = i_idcompta
       WHERE numfact = i_cle;
-- And       codope    = I_codope_entite;
   END;

--
   PROCEDURE p_upd_compte_client (
      i_idcompta      IN   remise_compta.idcompta%TYPE,
      i_cle           IN   v_compta.cle%TYPE,
      i_codope_entite IN   v_compta.scdope%TYPE
   )
   IS
   BEGIN
      UPDATE compte_client
         SET idcompta = i_idcompta
       WHERE idaffec = i_cle AND idcompta + 0 = -1 AND codope = to_number(i_codope_entite);
   END;

--
   PROCEDURE p_upd_compte_tiers (
      i_idcompta      IN   remise_compta.idcompta%TYPE,
      i_cle           IN   v_compta.cle%TYPE,
      i_codope_entite IN   v_compta.scdope%TYPE
   )
   IS
   BEGIN
      UPDATE compte_tiers
         SET idcompta = i_idcompta
       WHERE cle = i_cle AND idcompta + 0 = -1 AND codope = to_number(i_codope_entite);
   END;

--
   PROCEDURE p_upd_decompte (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   IS
   BEGIN
      UPDATE decompte
         SET idcompta = i_idcompta
       WHERE numdec = i_cle AND idcompta + 0 = -1;
      /* ACA 23082010 M3224 */
      UPDATE decompte_annul
         SET idcompta_init = i_idcompta
       WHERE numdec = i_cle AND idcompta + 0 = -1
         AND NOT EXISTS (SELECT 1
                           FROM decompte
                          WHERE numdec = decompte_annul.numdec );
      /* ACA fin */
   END;

--
   PROCEDURE p_upd_facture_regul (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   IS
   BEGIN
      UPDATE facture_regul
         SET idcompta = i_idcompta
       WHERE numfact_regul = i_cle;
   END;

--
   PROCEDURE p_upd_pnul (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   IS
   BEGIN
      UPDATE pnul
         SET idcompta = i_idcompta
       WHERE numdecaismt = i_cle;
   END;

--
   PROCEDURE p_upd_affectation (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE,
      i_codope_entite IN   v_compta.scdope%TYPE
   )
   IS
   BEGIN
      UPDATE affectation
         SET idcompta = i_idcompta
       WHERE numdecaismt = i_cle AND codope = to_number(i_codope_entite);

      /* ACA 23082010 M3224 */
      UPDATE affectation_annul
         SET idcompta_init = i_idcompta
       WHERE numdecaismt = i_cle AND codope = to_number(i_codope_entite);
      /* ACA fin */

   END;

-- SBA, le 19/9/2011 : L'operation comptable 132 relatant un numero d'affectation, l'appel a la procedure <p_upd_affectation> a ete remplace par <p_upd_affec_enc>
   PROCEDURE p_upd_affec_enc (
      i_idcompta      IN  remise_compta.idcompta%TYPE,
      i_cle           IN  v_compta.cle%TYPE,
      i_codope_entite IN  v_compta.scdope%TYPE
   )
   IS
   BEGIN
      UPDATE affectation
         SET idcompta = i_idcompta
       WHERE NUMAFFEC = i_cle AND codope = to_number(i_codope_entite);

      UPDATE affectation_annul
         SET idcompta_init = i_idcompta
       WHERE NUMAFFEC = i_cle AND codope = to_number(i_codope_entite);
   END;

--
   PROCEDURE p_upd_reversement (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   -- CTT 13/01/2004 I_codope_entite IN V_compta.codope%TYPE)
   IS
   BEGIN
      UPDATE reversement
         SET idcompta = i_idcompta
       WHERE idrevers = i_cle;
   END;

--
   PROCEDURE p_upd_retrocession (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   -- CTT 13/01/2004 I_codope_entite IN V_compta.codope%TYPE)
   IS
   BEGIN
      UPDATE retrocession
         SET idcompta = i_idcompta
       WHERE idrevers = i_cle;
   END;

--
   PROCEDURE p_upd_decompte_annul (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   -- CTT 13/01/2004 I_codope_entite IN V_compta.codope%TYPE)
   IS
   BEGIN
      UPDATE decompte_annul
         SET idcompta = i_idcompta
       WHERE numdec = i_cle;
   END;

--
   PROCEDURE p_upd_affectation_annul (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_cle        IN   v_compta.cle%TYPE
   )
   -- CTT 13/01/2004 I_codope_entite IN V_compta.codope%TYPE)
   IS
   BEGIN
      UPDATE affectation_annul
         SET idcompta = i_idcompta
       WHERE idpiece = i_cle;
   END;

--
   PROCEDURE p_equilibre_piece (
      i_idcompta    IN   compta.idcompta%TYPE,
      i_journal     IN   compta.journal%TYPE,
      i_numsoc      IN   compta.numsoc%TYPE,
      i_codope      IN   compta.codope%TYPE,
      i_rolesoc     IN   compta.rolesoc%TYPE,
      i_refpiece    IN   compta.refpiece%TYPE,
      i_dat_piece   IN   compta.dat_piece%TYPE,
      i_solde       IN   NUMBER
   )
   IS
   BEGIN
      BEGIN
         INSERT INTO compta
                     (idcompta, numsoc, codope, type_ope, rolesoc, journal,
                      refpiece, dat_piece, compte, sens, montant, montant_ct,
                      devise, devise_ct)
            SELECT i_idcompta, i_numsoc, i_codope, 99, i_rolesoc, i_journal,
                   i_refpiece, i_dat_piece, l_cst_compte_equilibre,
                   DECODE (SIGN (i_solde), -1, 'C', 1, 'D'), ABS (i_solde),
                   ABS (i_solde), 1, 1
              FROM DUAL;
      END;
   END p_equilibre_piece;

--
   PROCEDURE p_verif_compta (
      i_idcompta    IN   compta.idcompta%TYPE,
      i_numsoc      IN   compta.numsoc%TYPE,
      i_codope      IN   compta.codope%TYPE,
      i_rolesoc     IN   compta.rolesoc%TYPE,
      i_refpiece    IN   compta.refpiece%TYPE,
      i_dat_piece   IN   compta.dat_piece%TYPE
   )
   IS
/*Cursor C_piece Is
   Select   codope,
      rolesoc,
      journal,
      refpiece,
      dat_piece,
      Sum( Decode(sens,
            'D', -montant,
            'C', montant)
         )  solde
   From  compta
   Where idcompta = I_idcompta
   and   codope      = I_codope
   and   codope      = I_rolesoc
   and   refpiece = I_refpiece
   and   dat_piece   = I_dat_piece
   Group By
      idcompta,
      codope,
      rolesoc,
      journal,
      refpiece,
      dat_piece;*/
      CURSOR c_piece
      IS
         SELECT   codope, journal, refpiece, dat_piece,
                  SUM (DECODE (sens, 'D', -montant, 'C', montant)) solde
             FROM compta
            WHERE idcompta = i_idcompta
              AND codope = i_codope
              AND refpiece = i_refpiece
              AND dat_piece = i_dat_piece
         GROUP BY idcompta, codope, journal, refpiece, dat_piece;

      rec_c_piece   c_piece%ROWTYPE;
   BEGIN
      OPEN c_piece;

      LOOP
         FETCH c_piece
          INTO rec_c_piece;

         EXIT WHEN c_piece%NOTFOUND;

         IF (rec_c_piece.solde != 0)
         THEN
            g_msg_adm :=
                  'Ecriture déséquilibrée '
               || 'Codope = '
               || rec_c_piece.codope
               || ' Ref. = '
               || rec_c_piece.refpiece
               || ' Datpiece = '
               || rec_c_piece.dat_piece
               || ' Solde = '
               || TO_CHAR (rec_c_piece.solde);
            --
            p_ins_journal;      /*_adm; (I_nom_traitement => G_nom_traitement,
                                      I_session        => G_session,
                                   I_niv_msg        => G_niv_msg,
                                   I_msg_adm        => G_lib_msg);*/
            p_equilibre_piece (i_idcompta       => i_idcompta,
                               i_journal        => rec_c_piece.journal,
                               i_numsoc         => i_numsoc,
                               i_codope         => i_codope,
                               i_rolesoc        => i_rolesoc,
                               i_refpiece       => i_refpiece,
                               i_dat_piece      => i_dat_piece,
                               i_solde          => rec_c_piece.solde
                              );
         END IF;
      END LOOP;

      CLOSE c_piece;
   END p_verif_compta;

--
   PROCEDURE p_ins_trav_compta (
      i_numsoc         v_compta.numsoc%TYPE,
      i_rolesoc        v_compta.rolesoc%TYPE,
      i_sur_entite     v_compta.sur_entite%TYPE,
      i_cle_unique     v_compta.cle_unique%TYPE,
      i_entite         v_compta.entite%TYPE,
      i_reg_piece      v_compta.reg_piece%TYPE,
      i_cle            v_compta.cle%TYPE,
      i_idcompta       remise_compta.idcompta%TYPE,
      i_codope         v_compta.codope%TYPE,
      i_scdope         v_compta.scdope%TYPE,
      i_codjnal        v_compta.codjnal%TYPE,
      i_cie            v_compta.cie%TYPE,
      i_indv           v_compta.indv%TYPE,
      i_gar            v_compta.gar%TYPE,
      i_int            v_compta.INT%TYPE,
      i_bqe            v_compta.bqe%TYPE,
      i_refpiece       v_compta.refpiece%TYPE,
      i_dat_piece      v_compta.dat_piece%TYPE,
      i_lib_piece_1    v_compta.lib_piece_1%TYPE,
      i_lib_piece_2    v_compta.lib_piece_2%TYPE,
      i_type_ope       v_compta.type_ope%TYPE,
      i_montant1       v_compta.montant1%TYPE,
      i_montant2       v_compta.montant2%TYPE,
      i_montant3       v_compta.montant3%TYPE,
      i_montant4       v_compta.montant4%TYPE,
      i_montant5       v_compta.montant5%TYPE,
      i_montant6       v_compta.montant6%TYPE,
      i_montant7       v_compta.montant7%TYPE,
      i_montant8       v_compta.montant8%TYPE,
      i_montant9       v_compta.montant9%TYPE,
      i_montant10      v_compta.montant10%TYPE,
      i_montant11      v_compta.montant11%TYPE,
      i_montant12      v_compta.montant12%TYPE,
      i_montant13      v_compta.montant13%TYPE,
      i_montant14      v_compta.montant14%TYPE,
      i_montant15      v_compta.montant15%TYPE,
      i_montant16      v_compta.montant16%TYPE,
      i_montant17      v_compta.montant17%TYPE,
      i_montant18      v_compta.montant18%TYPE,
      i_montant19      v_compta.montant19%TYPE,
      i_montant20      v_compta.montant20%TYPE,
      i_montant21      v_compta.montant21%TYPE,
      i_montant22      v_compta.montant22%TYPE,
      i_montant23      v_compta.montant23%TYPE,
      i_montant24      v_compta.montant24%TYPE,
      i_montant25      v_compta.montant25%TYPE,
      i_montant26      v_compta.montant26%TYPE,
      i_montant27      v_compta.montant27%TYPE,
      i_montant28      v_compta.montant28%TYPE,
      i_montant29      v_compta.montant29%TYPE,
      i_montant30      v_compta.montant30%TYPE,
      i_devise         v_compta.devise%TYPE,
      i_montant1_ct    v_compta.montant1_ct%TYPE,
      i_montant2_ct    v_compta.montant2_ct%TYPE,
      i_montant3_ct    v_compta.montant3_ct%TYPE,
      i_montant4_ct    v_compta.montant4_ct%TYPE,
      i_montant5_ct    v_compta.montant5_ct%TYPE,
      i_montant6_ct    v_compta.montant6_ct%TYPE,
      i_montant7_ct    v_compta.montant7_ct%TYPE,
      i_montant8_ct    v_compta.montant8_ct%TYPE,
      i_montant9_ct    v_compta.montant9_ct%TYPE,
      i_montant10_ct   v_compta.montant10_ct%TYPE,
      i_montant11_ct   v_compta.montant11_ct%TYPE,
      i_montant12_ct   v_compta.montant12_ct%TYPE,
      i_montant13_ct   v_compta.montant13_ct%TYPE,
      i_montant14_ct   v_compta.montant14_ct%TYPE,
      i_montant15_ct   v_compta.montant15_ct%TYPE,
      i_montant16_ct   v_compta.montant16_ct%TYPE,
      i_montant17_ct   v_compta.montant17_ct%TYPE,
      i_montant18_ct   v_compta.montant18_ct%TYPE,
      i_montant19_ct   v_compta.montant19_ct%TYPE,
      i_montant20_ct   v_compta.montant20_ct%TYPE,
      i_montant21_ct   v_compta.montant21_ct%TYPE,
      i_montant22_ct   v_compta.montant22_ct%TYPE,
      i_montant23_ct   v_compta.montant23_ct%TYPE,
      i_montant24_ct   v_compta.montant24_ct%TYPE,
      i_montant25_ct   v_compta.montant25_ct%TYPE,
      i_montant26_ct   v_compta.montant26_ct%TYPE,
      i_montant27_ct   v_compta.montant27_ct%TYPE,
      i_montant28_ct   v_compta.montant28_ct%TYPE,
      i_montant29_ct   v_compta.montant29_ct%TYPE,
      i_montant30_ct   v_compta.montant30_ct%TYPE,
      i_devise_ct      v_compta.devise_ct%TYPE,
      i_var01          v_compta.var01%TYPE,
      i_var02          v_compta.var02%TYPE,
      i_var03          v_compta.var03%TYPE,
      i_var04          v_compta.var04%TYPE,
      i_var05          v_compta.var05%TYPE,
      i_var06          v_compta.var06%TYPE,
      i_var07          v_compta.var07%TYPE,
      i_var08          v_compta.var08%TYPE,
      i_var09          v_compta.var09%TYPE,
      i_var10          v_compta.var10%TYPE,
      i_var11          v_compta.var11%TYPE,
      i_var12          v_compta.var12%TYPE,
      i_var13          v_compta.var13%TYPE,
      i_var14          v_compta.var14%TYPE,
      i_var15          v_compta.var15%TYPE,
      i_var16          v_compta.var16%TYPE,
      i_var17          v_compta.var17%TYPE,
      i_var18          v_compta.var18%TYPE,
      i_var19          v_compta.var19%TYPE,
      i_var20          v_compta.var20%TYPE,
      i_var21          v_compta.var21%TYPE,
      i_var22          v_compta.var22%TYPE,
      i_var23          v_compta.var23%TYPE,
      i_var24          v_compta.var24%TYPE,
      i_var25          v_compta.var25%TYPE,
      i_var26          v_compta.var26%TYPE,
      i_var27          v_compta.var27%TYPE,
      i_var28          v_compta.var28%TYPE,
      i_var29          v_compta.var29%TYPE,
      i_var30          v_compta.var30%TYPE,
      i_var31          v_compta.var31%TYPE,
      i_var32          v_compta.var32%TYPE,
      i_var33          v_compta.var33%TYPE,
      i_var34          v_compta.var34%TYPE,
      i_var35          v_compta.var35%TYPE
   )
   IS
   BEGIN
      INSERT INTO trav_compta
                  (numsoc, rolesoc, sur_entite, cle_unique,
                   entite, reg_piece, cle, idcompta, codope,
                   scdope, codjnal, cie, indv, gar, INT, bqe,
                   refpiece, dat_piece, lib_piece_1, lib_piece_2,
                   type_ope, montant1, montant2, montant3,
                   montant4, montant5, montant6, montant7,
                   montant8, montant9, montant10, montant11,
                   montant12, montant13, montant14, montant15,
                   montant16, montant17, montant18, montant19,
                   montant20, montant21, montant22, montant23,
                   montant24, montant25, montant26, montant27,
                   montant28, montant29, montant30, devise,
                   montant1_ct, montant2_ct, montant3_ct,
                   montant4_ct, montant5_ct, montant6_ct,
                   montant7_ct, montant8_ct, montant9_ct,
                   montant10_ct, montant11_ct, montant12_ct,
                   montant13_ct, montant14_ct, montant15_ct,
                   montant16_ct, montant17_ct, montant18_ct,
                   montant19_ct, montant20_ct, montant21_ct,
                   montant22_ct, montant23_ct, montant24_ct,
                   montant25_ct, montant26_ct, montant27_ct,
                   montant28_ct, montant29_ct, montant30_ct,
                   devise_ct, var01, var02, var03, var04, var05,
                   var06, var07, var08, var09, var10, var11,
                   var12, var13, var14, var15, var16, var17,
                   var18, var19, var20, var21, var22, var23,
                   var24,
                   var25,
                   var26, var27, var28, var29, var30,
                   var31, var32, var33, var34, var35

                  )
           VALUES (i_numsoc, i_rolesoc, i_sur_entite, i_cle_unique,
                   i_entite, i_reg_piece, i_cle, i_idcompta, i_codope,
                   i_scdope, i_codjnal, i_cie, i_indv, i_gar, i_int, i_bqe,
                   i_refpiece, i_dat_piece, i_lib_piece_1, i_lib_piece_2,
                   i_type_ope, i_montant1, i_montant2, i_montant3,
                   i_montant4, i_montant5, i_montant6, i_montant7,
                   i_montant8, i_montant9, i_montant10, i_montant11,
                   i_montant12, i_montant13, i_montant14, i_montant15,
                   i_montant16, i_montant17, i_montant18, i_montant19,
                   i_montant20, i_montant21, i_montant22, i_montant23,
                   i_montant24, i_montant25, i_montant26, i_montant27,
                   i_montant28, i_montant29, i_montant30, i_devise,
                   i_montant1_ct, i_montant2_ct, i_montant3_ct,
                   i_montant4_ct, i_montant5_ct, i_montant6_ct,
                   i_montant7_ct, i_montant8_ct, i_montant9_ct,
                   i_montant10_ct, i_montant11_ct, i_montant12_ct,
                   i_montant13_ct, i_montant14_ct, i_montant15_ct,
                   i_montant16_ct, i_montant17_ct, i_montant18_ct,
                   i_montant19_ct, i_montant20_ct, i_montant21_ct,
                   i_montant22_ct, i_montant23_ct, i_montant24_ct,
                   i_montant25_ct, i_montant26_ct, i_montant27_ct,
                   i_montant28_ct, i_montant29_ct, i_montant30_ct,
                   i_devise_ct, i_var01, i_var02, i_var03, i_var04, i_var05,
                   i_var06, i_var07, i_var08, i_var09, i_var10, i_var11,
                   i_var12, i_var13, i_var14, i_var15, i_var16, i_var17,
                   i_var18, i_var19, i_var20, i_var21, i_var22, i_var23,
                   i_var24,
                   f_cpta_var (i_var25,
                               i_var01,
                               i_var02,
                               i_var03,
                               i_var04,
                               i_var05,
                               i_var06,
                               i_var07,
                               i_var08,
                               i_var09,
                               i_var10,
                               i_var11,
                               i_var12,
                               i_var13,
                               i_var14,
                               i_var15,
                               i_var16,
                               i_var17,
                               i_var18,
                               i_var19,
                               i_var20,
                               i_var21,
                               i_var22,
                               i_var23,
                               i_var24,
                               i_var25,
                               i_var26,
                               i_var27,
                               i_var28,
                               i_var29,
                               i_var30,
                               i_var31,
                               i_var32,
                               i_var33,
                               i_var34,
                               i_var35
                              ),
                   i_var26, i_var27, i_var28, i_var29, i_var30,
                   i_var31, i_var32, i_var33, i_var34, i_var35
                  );
   END;

--
   PROCEDURE p_ins_compta (
      i_idcompta          IN       compta.idcompta%TYPE,
      i_numsoc            IN       compta.numsoc%TYPE,
      i_codope            IN       compta.codope%TYPE,
      i_rolesoc           IN       compta.rolesoc%TYPE,
      i_refpiece          IN       compta.refpiece%TYPE,
      i_dat_piece         IN       compta.dat_piece%TYPE,
      o_nb_uple_inserer   OUT      NUMBER
   )
   IS
   BEGIN
      INSERT INTO compta
                  (idcompta, numsoc, codope, rolesoc, journal, refpiece,
                   dat_piece, lib_piece_1, lib_piece_2, type_ope, scdope,
                   compte, compte_aux, sens, numordre, central, montant,
                   montant_ct, entite, reg_piece, cle, numtiers, devise,
                   devise_ct, libelle, axana1, axana2, axana3, axana4,
                   axana5, zonex1, zonex2, zonex3, zonex4, zonex5,
-- SCR 20090716 :  alimentation des zonex de 6 a 13
                    zonex6, zonex7, zonex8, zonex9,
                    zonex10, zonex11, zonex12, zonex13,
-- --
                   nature,
                   zserv1, zserv2, zserv3, zserv4, zserv5,
                    zreg)
         SELECT   i_idcompta, i_numsoc, i_codope, i_rolesoc,
                  TRIM (v_ecriture.codjnal), SUBSTR (i_refpiece, 1, 12),
                  i_dat_piece, v_ecriture.lib_piece_1,
                  v_ecriture.lib_piece_2, v_ecriture.type_ope,
                  v_ecriture.scdope, SUBSTR (v_ecriture.compte, 1, 13),
                  SUBSTR (v_ecriture.compte_aux, 1, 13),
                  DECODE (SIGN (v_ecriture.montant),
                          -1, DECODE (v_ecriture.sens, 'D', 'C', 'C', 'D'),
                          v_ecriture.sens
                         ),
                  v_ecriture.numordre, v_ecriture.central,
                  SUM (ABS (v_ecriture.montant)),
                  SUM (ABS (v_ecriture.montant_ct)), v_ecriture.sur_entite,
                  v_ecriture.reg_piece, v_ecriture.cle_unique,
                  v_ecriture.indv, v_ecriture.devise, v_ecriture.devise_ct,
                  v_ecriture.libelle, v_ecriture.axana1, v_ecriture.axana2,
                  v_ecriture.axana3, v_ecriture.axana4, v_ecriture.axana5,
                  v_ecriture.zonex1, v_ecriture.zonex2, v_ecriture.zonex3,
                  v_ecriture.zonex4, v_ecriture.zonex5,
-- SCR 20090716 :  alimentation des zonex de 6 a 13
                  v_ecriture.zonex6, v_ecriture.zonex7, v_ecriture.zonex8,
                  v_ecriture.zonex9, v_ecriture.zonex10, v_ecriture.zonex11,
                  v_ecriture.zonex12, v_ecriture.zonex13,
-- --
                  v_ecriture.nature,
                  v_ecriture.zserv1, v_ecriture.zserv2, v_ecriture.zserv3,
                  v_ecriture.zserv4, v_ecriture.zserv5, v_ecriture.zreg
             FROM v_ecriture
            WHERE v_ecriture.montant != 0
              AND v_ecriture.codope = i_codope
              AND v_ecriture.refpiece = i_refpiece
              AND v_ecriture.rolesoc = i_rolesoc
              AND TRUNC (v_ecriture.dat_piece) = i_dat_piece
         GROUP BY v_ecriture.codjnal,
                  v_ecriture.sur_entite,
                  v_ecriture.reg_piece,
                  v_ecriture.cle_unique,
                  v_ecriture.indv,
                  v_ecriture.type_ope,
                  v_ecriture.scdope,
                  v_ecriture.lib_piece_1,
                  v_ecriture.lib_piece_2,
                  v_ecriture.compte,
                  v_ecriture.compte_aux,
                  DECODE (SIGN (v_ecriture.montant),
                          -1, DECODE (v_ecriture.sens, 'D', 'C', 'C', 'D'),
                          v_ecriture.sens
                         ),
                  v_ecriture.numordre,
                  v_ecriture.central,
                  v_ecriture.devise,
                  v_ecriture.devise_ct,
                  v_ecriture.libelle,
                  v_ecriture.axana1,
                  v_ecriture.axana2,
                  v_ecriture.axana3,
                  v_ecriture.axana4,
                  v_ecriture.axana5,
                  v_ecriture.zonex1,
                  v_ecriture.zonex2,
                  v_ecriture.zonex3,
                  v_ecriture.zonex4,
                  v_ecriture.zonex5,
-- SCR 20090716 :  alimentation des zonex de 6 a 13
                  v_ecriture.zonex6,
                  v_ecriture.zonex7,
                  v_ecriture.zonex8,
                  v_ecriture.zonex9,
                  v_ecriture.zonex10,
                  v_ecriture.zonex11,
                  v_ecriture.zonex12,
                  v_ecriture.zonex13,
-- --
                  v_ecriture.nature,
                  v_ecriture.zserv1,
                  v_ecriture.zserv2,
                  v_ecriture.zserv3,
                  v_ecriture.zserv4,
                  v_ecriture.zserv5,
                  v_ecriture.zreg;

      o_nb_uple_inserer := SQL%ROWCOUNT;
      p_verif_compta (i_idcompta       => i_idcompta,
                      i_numsoc         => i_numsoc,
                      i_codope         => i_codope,
                      i_rolesoc        => i_rolesoc,
                      i_refpiece       => i_refpiece,
                      i_dat_piece      => i_dat_piece
                     );
--
   END;

--
   PROCEDURE p_upd_compta (
      i_numpiece       IN       compta.numpiece%TYPE,
      i_idcompta       IN       compta.idcompta%TYPE,
      i_codope         IN       compta.codope%TYPE,
      i_journal        IN       compta.journal%TYPE,
      i_refpiece       IN       compta.refpiece%TYPE,
      i_dat_piece      IN       compta.dat_piece%TYPE,
      io_nb_uple_maj   IN OUT   NUMBER
   )
   IS
   BEGIN
      UPDATE compta
         SET numpiece = i_numpiece
       WHERE compta.idcompta = i_idcompta
         AND compta.codope = i_codope
         AND compta.journal = i_journal
         AND compta.refpiece = i_refpiece
         AND TRUNC (compta.dat_piece) = i_dat_piece;

      io_nb_uple_maj := SQL%ROWCOUNT + io_nb_uple_maj;
   --
   END;

--
   PROCEDURE p_ins_remise_compta (
      i_idcompta          IN       remise_compta.idcompta%TYPE,
      i_date_deb_remise   IN       DATE DEFAULT NULL,
      i_date_fin_remise   IN       DATE DEFAULT NULL,
      o_nb_uple_inserer   OUT      NUMBER
   )
   IS
   BEGIN
      INSERT INTO remise_compta
                  (idcompta, numsoc, codope, journal, datcompta, debut, fin,
                   debit, credit, nombre)
         SELECT   i_idcompta, compta.numsoc, compta.codope, compta.journal,
                  TRUNC (SYSDATE),
                  NVL (i_date_deb_remise, TRUNC (MIN (compta.dat_piece))),
                  NVL (i_date_fin_remise, TRUNC (MAX (compta.dat_piece))),
                  SUM (DECODE (compta.sens, 'D', compta.montant, 0)),
                  SUM (DECODE (compta.sens, 'C', compta.montant, 0)),
                  COUNT (*)
             FROM compta
            WHERE compta.idcompta = i_idcompta
         GROUP BY compta.numsoc,
                  compta.codope,
                  compta.journal,
                  TRUNC (SYSDATE);

      o_nb_uple_inserer := SQL%ROWCOUNT;
   END;

--
   PROCEDURE p_ins_remise_compta_globale (
      i_idcompta          IN       remise_compta.idcompta%TYPE,
      o_nb_uple_inserer   OUT      NUMBER
   )
   IS
   BEGIN
      INSERT INTO remise_compta_globale
                  (idcompta, numsoc, datcompta, debut, fin, debit, credit,
                   nombre, creation, valide)
         SELECT   i_idcompta, remise_compta.numsoc, remise_compta.datcompta,
                  MIN (remise_compta.debut), MAX (remise_compta.fin),
                  SUM (remise_compta.debit), SUM (remise_compta.credit),
                  SUM (remise_compta.nombre), TRUNC (SYSDATE), 'N'
             FROM remise_compta
            WHERE remise_compta.idcompta = i_idcompta
         GROUP BY remise_compta.numsoc, remise_compta.datcompta;

      o_nb_uple_inserer := SQL%ROWCOUNT;
   END;

--
   PROCEDURE p_del_trav_compta (
      i_codope      trav_compta.codope%TYPE,
      i_refpiece    trav_compta.refpiece%TYPE,
      i_dat_piece   trav_compta.dat_piece%TYPE
   )
   IS
   BEGIN
      -- Suppression des lignes de la table temporaire
      DELETE FROM trav_compta
            WHERE trav_compta.codope = i_codope
              AND trav_compta.refpiece = i_refpiece
              AND TRUNC (trav_compta.dat_piece) = i_dat_piece;
   --
   END;

--
   PROCEDURE p_trt_trav_compta (
      i_idcompta   IN   remise_compta.idcompta%TYPE,
      i_numsoc     IN   compta.numsoc%TYPE
   )
   IS
      CURSOR c_trav_compta
      IS
         SELECT DISTINCT trav_compta.codope, trav_compta.refpiece,
                         trav_compta.rolesoc,
                         TRUNC (trav_compta.dat_piece) dat_piece
                    FROM trav_compta;

--
      rec_c_trav_compta         c_trav_compta%ROWTYPE;
--
      l_nb_uple_total_inserer   NUMBER                  := 0;
   BEGIN
      --
      OPEN c_trav_compta;

      LOOP
         FETCH c_trav_compta
          INTO rec_c_trav_compta;

         EXIT WHEN c_trav_compta%NOTFOUND;
         --
         -- Insertion dans la table compta
         --
         p_ins_compta (i_idcompta             => i_idcompta,
                       i_numsoc               => i_numsoc,
                       i_codope               => rec_c_trav_compta.codope,
                       i_rolesoc              => rec_c_trav_compta.rolesoc,
                       i_refpiece             => rec_c_trav_compta.refpiece,
                       i_dat_piece            => rec_c_trav_compta.dat_piece,
                       o_nb_uple_inserer      => g_nb_uple_inserer
                      );
         --
         l_nb_uple_total_inserer :=
                                   l_nb_uple_total_inserer + g_nb_uple_inserer;
         --
         /*G_msg_adm  := 'Insertion dans COMPTA pour '  ||
                       '(cod. : '||Rec_c_trav_compta.codope ||
                       ' ref. : '||Rec_c_trav_compta.refpiece ||
                   ' role. : '||Rec_c_trav_compta.rolesoc ||
                       ' datpiece : '||Rec_c_trav_compta.dat_piece ||')==> '||
                       to_char(G_nb_uple_inserer)||' Lignes - Cumul '||
                       to_char(L_nb_uple_total_inserer);*/
         --P_INS_journal;

         /*_adm(I_nom_traitement => G_nom_traitement,
                           I_session        => G_session,
                           I_niv_msg        => G_niv_msg,
                           I_msg_adm        => G_lib_msg);*/
         --
         -- Suppression des lignes de la table de travail trav_compta
         -- et validation
         --CTT Ne pas oublier d'enlever les commentaires .....
         --P_DEL_trav_compta( I_codope       => Rec_c_trav_compta.codope,
         --                   I_refpiece     => Rec_c_trav_compta.refpiece,
         --                   I_dat_piece    => Rec_c_trav_compta.dat_piece);
         --
         p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);
      --
      END LOOP;

      CLOSE c_trav_compta;                        -- NS/VC ajout le 21/08/2006

      --
      g_niv_msg := 1;
      g_msg_adm :=
            TO_CHAR (SYSDATE, 'DD/MM/YYYY - HH24:MI')
         || ' - Fin insertion dans COMPTA : '
         || TO_CHAR (l_nb_uple_total_inserer)
         || ' ecritures';
      p_ins_journal;
      g_niv_msg := 3;
      g_msg_adm :=
            TO_CHAR (SYSDATE, 'DD/MM/YYYY - HH24:MI')
         || ' - Nb Lignes ins. dans COMPTA : '
         || TO_CHAR (l_nb_uple_total_inserer);
      --
      p_ins_journal;              /*_adm(I_nom_traitement => G_nom_traitement,
                                       I_session        => G_session,
                                       I_niv_msg        => G_niv_msg,
                                       I_msg_adm        => G_lib_msg);*/
      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);
   END;

--
   PROCEDURE p_trt_piece (
      i_idcompta       IN       remise_compta.idcompta%TYPE,
      i_numsoc         IN       remise_compta.numsoc%TYPE,
      io_nb_uple_maj   IN OUT   NUMBER
   )
   IS
--
      CURSOR c_max_numpiece (
         p_idcompta   remise_compta.idcompta%TYPE,
         p_numsoc     remise_compta.numsoc%TYPE
      )
      IS
         SELECT NVL (MAX (numpiece), 0) max_numpiece
           FROM compta
          WHERE compta.idcompta = p_idcompta AND compta.numsoc = p_numsoc;

--
      rec_c_max_numpiece      c_max_numpiece%ROWTYPE;

--
      CURSOR c_select_numpiece (p_idcompta remise_compta.idcompta%TYPE)
      IS
         SELECT codope, journal, refpiece, TRUNC (dat_piece) dat_piece
           FROM v_numpiece
          WHERE v_numpiece.idcompta = p_idcompta;

--
      rec_c_select_numpiece   c_select_numpiece%ROWTYPE;
--
   BEGIN
      --
      -- Recherche du dernier numero de piece dans compta
      --
      OPEN c_max_numpiece (i_idcompta, i_numsoc);

      FETCH c_max_numpiece
       INTO rec_c_max_numpiece;

      CLOSE c_max_numpiece;

      --
      io_nb_uple_maj := 0;

      --
      OPEN c_select_numpiece (i_idcompta);

      LOOP
         FETCH c_select_numpiece
          INTO rec_c_select_numpiece;

         EXIT WHEN c_select_numpiece%NOTFOUND;
         rec_c_max_numpiece.max_numpiece :=
                                          rec_c_max_numpiece.max_numpiece + 1;
         --
         -- mise a jour dans compta du numero de piece
         --
         p_upd_compta (i_numpiece          => rec_c_max_numpiece.max_numpiece,
                       i_idcompta          => i_idcompta,
                       i_codope            => rec_c_select_numpiece.codope,
                       i_journal           => rec_c_select_numpiece.journal,
                       i_refpiece          => rec_c_select_numpiece.refpiece,
                       i_dat_piece         => rec_c_select_numpiece.dat_piece,
                       io_nb_uple_maj      => io_nb_uple_maj
                      );
      --
      END LOOP;

      CLOSE c_select_numpiece;
   --
   END;

--
   PROCEDURE p_sel_refcentral (
      i_idcompta   IN       compta_central.idcompta%TYPE,
      i_sequence   IN       NUMBER,
      o_refpiece   OUT      compta_central.refpiece%TYPE
   )
   IS
      l_len_idcompta   NUMBER := LENGTH (TO_CHAR (i_idcompta));
   BEGIN
      o_refpiece :=
            TO_CHAR (i_idcompta)
            || LPAD (i_sequence, 8 - l_len_idcompta, '0');
   END p_sel_refcentral;

-- ============== Fin des definitions des procedures privees =================

   -- ============================================================================
-- CORPS DES PROCEDURES ET FONCTIONS PUBLIQUES
--
   FUNCTION f_lib_ventil (
      i_numsoc     IN   compta.numsoc%TYPE,
      i_codope     IN   compta.codope%TYPE,
      i_scdope     IN   compta.scdope%TYPE,
      i_rolesoc    IN   compta.rolesoc%TYPE,
      i_numordre   IN   compta.numordre%TYPE
   )
      RETURN VARCHAR2
   IS
      l_lib_ventil   VARCHAR2 (45);
   BEGIN
      SELECT libelle
        INTO l_lib_ventil
        FROM libelle
       WHERE code = i_codope
         AND mnemo = 'VENTIL'
         AND sens =
                (SELECT DISTINCT (compta_schema.ventilation)
                            FROM compta_schema
                           WHERE (    (i_numsoc = compta_schema.numsoc)
                                  AND (i_codope = compta_schema.codope)
                                  AND (i_scdope = compta_schema.scdope)
                                  AND (i_rolesoc = compta_schema.rolesoc)
                                  AND (i_numordre = compta_schema.numordre)
                                 ));

      RETURN l_lib_ventil;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_lib_ventil := NULL;
         RETURN l_lib_ventil;
   END;

   FUNCTION f_lib_ecriture (
      i_numsoc        IN   compta.numsoc%TYPE,
      i_codope        IN   compta.codope%TYPE,
      i_type_ope      IN   compta.type_ope%TYPE,
      i_lib_piece_1   IN   compta.lib_piece_1%TYPE DEFAULT NULL,
      i_lib_piece_2   IN   compta.lib_piece_2%TYPE DEFAULT NULL,
      i_central       IN   compta.central%TYPE DEFAULT 'N'
   )
      RETURN VARCHAR2
   IS
      --
      CURSOR c_lib_ecriture
      IS
         SELECT lib_1, lib_2, lib_central
           FROM lib_ecriture
          WHERE numsoc = i_numsoc
            AND codope = i_codope
            AND type_ope = i_type_ope;

      --
      rec_c_lib_ecriture   c_lib_ecriture%ROWTYPE;
      --
      l_lib_ecriture       VARCHAR2 (45);
   --
   BEGIN
      --
      OPEN c_lib_ecriture;

      FETCH c_lib_ecriture
       INTO rec_c_lib_ecriture;

      IF c_lib_ecriture%NOTFOUND
      THEN
         l_lib_ecriture := 'Libellé non paramétré';
      ELSE
         IF i_central = 'O'
         THEN
            IF rec_c_lib_ecriture.lib_central IS NULL
            THEN
               l_lib_ecriture := 'Libellé non paramétré';
            ELSE
               l_lib_ecriture := rec_c_lib_ecriture.lib_central;
            END IF;
         --
         ELSE                                               -- I_central = 'N'
            IF (    rec_c_lib_ecriture.lib_1 IS NULL
                AND rec_c_lib_ecriture.lib_2 IS NULL
               )
            THEN
               l_lib_ecriture := 'Libellé non paramétré';
            ELSE
               IF (    rec_c_lib_ecriture.lib_1 IS NOT NULL
                   AND rec_c_lib_ecriture.lib_2 IS NOT NULL
                  )
               THEN
                  l_lib_ecriture :=
                        rec_c_lib_ecriture.lib_1
                     || ' '
                     || i_lib_piece_1
                     || ' '
                     || rec_c_lib_ecriture.lib_2
                     || ' '
                     || i_lib_piece_2;
               --
               ELSIF rec_c_lib_ecriture.lib_1 IS NOT NULL
               THEN
                  l_lib_ecriture :=
                             rec_c_lib_ecriture.lib_1 || ' ' || i_lib_piece_1;
               ELSE                                     -- Lib_2 est renseigne
                  l_lib_ecriture :=
                             rec_c_lib_ecriture.lib_2 || ' ' || i_lib_piece_2;
               END IF;
            END IF;
         END IF;
      END IF;

      CLOSE c_lib_ecriture;

      --
      RETURN l_lib_ecriture;
   END;

   PROCEDURE p_defaire_idpiece (i_idcompta compta.idcompta%TYPE)
   IS
      CURSOR sel_compta_idpiece
      IS
         SELECT   journal,
                  NVL (MIN (TO_NUMBER (SUBSTR (refpiece, -7))), 1) min_cpt
             FROM compta_central
            WHERE idcompta = i_idcompta AND refpiece IS NOT NULL
         GROUP BY journal;

      rec_sel_compta_idpiece   sel_compta_idpiece%ROWTYPE;
   BEGIN
      --
      OPEN sel_compta_idpiece;

      LOOP
         FETCH sel_compta_idpiece
          INTO rec_sel_compta_idpiece;

         EXIT WHEN sel_compta_idpiece%NOTFOUND;

         UPDATE compta_idpiece
            SET compteur = rec_sel_compta_idpiece.min_cpt - 1
          WHERE journal = rec_sel_compta_idpiece.journal;
      END LOOP;

      CLOSE sel_compta_idpiece;
   END p_defaire_idpiece;

--
   PROCEDURE p_defaire_transaction (i_idcompta compta.idcompta%TYPE)
   IS
   BEGIN
      --
      UPDATE decaismt
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE encaismt
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE annul_encais
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE facture
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      --
      UPDATE facture_annul
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      /* ACA 23082010 M3224 */
      UPDATE facture_annul
         SET idcompta_init = -1
       WHERE idcompta_init = i_idcompta;
      /* ACA fin */
      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE compte_client
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      UPDATE compte_tiers
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE decompte
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      UPDATE facture_regul
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE pnul
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      /* ACA 23082010 M3224 */
      UPDATE pnul
         SET idcompta_init = -1
       WHERE idcompta_init = i_idcompta;
      /* ACA fin */
      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE affectation
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      --
      UPDATE reversement
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      UPDATE retrocession
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      UPDATE decompte_annul
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      /* ACA 23082010 M3224 */
      UPDATE decompte_annul
         SET idcompta_init = -1
       WHERE idcompta_init = i_idcompta;
      /* ACA fin */
      --
      UPDATE affectation_annul
         SET idcompta = -1
       WHERE idcompta = i_idcompta;

      --
      /* ACA 23082010 M3224 */
      UPDATE affectation_annul
         SET idcompta_init = -1
       WHERE idcompta_init = i_idcompta;
      /* ACA fin */
      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      DELETE FROM compta
            WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);
      --
      p_defaire_idpiece (i_idcompta);

      DELETE FROM compta_central
            WHERE idcompta = i_idcompta;

      --
      DELETE FROM remise_compta
            WHERE idcompta = i_idcompta;

      --
      DELETE FROM remise_compta_globale
            WHERE idcompta = i_idcompta;

      --
      p_use_rollback_commit (i_rollback_segment => NULL);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         g_niv_msg := 3;
         g_msg_adm :=
               SUBSTR (SQLERRM (SQLCODE), 1, 76)
            || ' Erreur sur le traitement P_defaire_transaction ';
         --   G_nom_traitement := 'Pk_compta.sql';
         g_niv_msg := 2;
         p_ins_journal;           /*_adm(I_nom_traitement => G_nom_traitement,
                                    I_session         => G_session,
                                    I_niv_msg        => G_niv_msg,
                                    I_msg_adm        => G_lib_msg);*/
         --
         p_use_rollback_commit (i_rollback_segment => NULL);
         --
         RAISE;
   --
   END;

   PROCEDURE p_val_zreg
   IS
/* Curseur principal (Tous les enregesitriments à valoriser ) */
      CURSOR c_cpta
      IS
         SELECT     *
               FROM compta
              WHERE zreg_val IS NULL
         FOR UPDATE;

      r_cpta   c_cpta%ROWTYPE;
   BEGIN
      OPEN c_cpta;

      LOOP
         FETCH c_cpta
          INTO r_cpta;

         EXIT WHEN c_cpta%NOTFOUND;

         UPDATE compta
            SET compta.zreg_val =
                   NVL
                     (REPLACE
                        (REPLACE
                            (REPLACE
                                (REPLACE
                                    (REPLACE
                                        (REPLACE
                                            (REPLACE
                                                (REPLACE
                                                    (REPLACE
                                                        (REPLACE
                                                            (REPLACE
                                                                (REPLACE
                                                                    (REPLACE
                                                                        (REPLACE
                                                                            (REPLACE
                                                                                (REPLACE
                                                                                    (REPLACE
                                                                                        (REPLACE
                                                                                            (REPLACE
                                                                                                (REPLACE
                                                                                                    (REPLACE
                                                                                                        (REPLACE
                                                                                                            (REPLACE
                                                                                                                (REPLACE
                                                                                                                    (REPLACE
                                                                                                                        (REPLACE
                                                                                                                            (REPLACE
                                                                                                                                (REPLACE
                                                                                                                                    (REPLACE
                                                                                                                                        (REPLACE
                                                                                                                                            (REPLACE
                                                                                                                                                (REPLACE
                                                                                                                                                    (REPLACE
                                                                                                                                                        (REPLACE
                                                                                                                                                            (REPLACE
                                                                                                                                                                (compta.zreg,
                                                                                                                                                                 '#REG01',
                                                                                                                                                                 r_cpta.journal
                                                                                                                                                                ),
                                                                                                                                                             '#REG02',
                                                                                                                                                             r_cpta.compte
                                                                                                                                                            ),
                                                                                                                                                         '#REG03',
                                                                                                                                                         r_cpta.sens
                                                                                                                                                        ),
                                                                                                                                                     '#REG04',
                                                                                                                                                     r_cpta.devise_ct
                                                                                                                                                    ),
                                                                                                                                                 '#REG05',
                                                                                                                                                 r_cpta.montant_ct
                                                                                                                                                ),
                                                                                                                                             '#REG06',
                                                                                                                                             r_cpta.montant
                                                                                                                                            ),
                                                                                                                                         '#REG07',
                                                                                                                                         r_cpta.libelle
                                                                                                                                        ),
                                                                                                                                     '#REG08',
                                                                                                                                     TO_CHAR
                                                                                                                                        (r_cpta.dat_piece,
                                                                                                                                         'DDMMYY'
                                                                                                                                        )
                                                                                                                                    ),
                                                                                                                                 '#REG09',
                                                                                                                                 r_cpta.refpiece
                                                                                                                                ),
                                                                                                                             '#REG10',
                                                                                                                             TO_CHAR
                                                                                                                                (r_cpta.dat_piece,
                                                                                                                                 'DDMMYY'
                                                                                                                                )
                                                                                                                            ),
                                                                                                                         '#REG11',
                                                                                                                         r_cpta.nature
                                                                                                                        ),
                                                                                                                     '#REG12',
                                                                                                                     r_cpta.axana1
                                                                                                                    ),
                                                                                                                 '#REG13',
                                                                                                                 r_cpta.axana2
                                                                                                                ),
                                                                                                             '#REG14',
                                                                                                             r_cpta.axana3
                                                                                                            ),
                                                                                                         '#REG15',
                                                                                                         r_cpta.axana4
                                                                                                        ),
                                                                                                     '#REG16',
                                                                                                     r_cpta.axana5
                                                                                                    ),
                                                                                                 '#REG17',
                                                                                                 r_cpta.zonex1
                                                                                                ),
                                                                                             '#REG18',
                                                                                             r_cpta.zonex2
                                                                                            ),
                                                                                         '#REG19',
                                                                                         r_cpta.zonex3
                                                                                        ),
                                                                                     '#REG20',
                                                                                     r_cpta.zonex4
                                                                                    ),
                                                                                 '#REG21',
                                                                                 r_cpta.zonex5
                                                                                ),
  -- SCR : AJOUT de l'alimentation des zones 6 a 13
                                                                             '#REG22',
                                                                             r_cpta.zonex6
                                                                            ),
                                                                         '#REG23',
                                                                         r_cpta.zonex7
                                                                        ),
                                                                     '#REG24',
                                                                     r_cpta.zonex8
                                                                    ),
                                                                 '#REG25',
                                                                 r_cpta.zonex9
                                                                ),
                                                             '#REG26',
                                                             r_cpta.zonex10
                                                            ),
                                                         '#REG27',
                                                         r_cpta.zonex11
                                                        ),
                                                     '#REG28',
                                                     r_cpta.zonex12
                                                    ),
                                                 '#REG29',
                                                 r_cpta.zonex13
                                                ),
  -- --
                                             '#REG30',
                                             r_cpta.zserv1
                                            ),
                                         '#REG31',
                                         r_cpta.zserv2
                                        ),
                                     '#REG32',
                                     r_cpta.zserv3
                                    ),
                                 '#REG33',
                                 r_cpta.zserv4
                                ),
                             '#REG34',
                             r_cpta.zserv5
                            ),
                           '#REG35',
                           r_cpta.compte_aux
                          ),
                       0
                      )
          WHERE CURRENT OF c_cpta;
      END LOOP;

      CLOSE c_cpta;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END p_val_zreg;

--
   PROCEDURE p_sel_ecriture (
      i_numsoc       IN   v_compta.numsoc%TYPE,
      i_deb_codope   IN   v_compta.codope%TYPE DEFAULT NULL,
      i_fin_codope   IN   v_compta.codope%TYPE DEFAULT NULL,
      i_date_debut   IN   DATE,
      i_date_fin     IN   DATE,
      i_session      IN   NUMBER DEFAULT 1
   )
   IS
      --
      l_cst_validation   CONSTANT NUMBER (4)                DEFAULT 1000;
      loc_devise                  v_compta.devise_ct%TYPE;

      --
      CURSOR c_sel_devise
      IS
         SELECT DISTINCT (devise_ct)
                    FROM v_compta
                   WHERE v_compta.idcompta = -1
                     AND v_compta.numsoc = i_numsoc
                     AND v_compta.codope BETWEEN NVL (i_deb_codope,
                                                      v_compta.codope
                                                     )
                                             AND NVL (i_fin_codope,
                                                      NVL (i_deb_codope,
                                                           v_compta.codope
                                                          )
                                                     )
                     AND TRUNC(v_compta.dat_piece) BETWEEN i_date_debut AND i_date_fin
                     AND v_compta.devise_ct IS NOT NULL;

      CURSOR c_sel_ecriture
      IS
         SELECT v_compta.numsoc, v_compta.rolesoc, v_compta.entite,
                v_compta.reg_piece, v_compta.codope, v_compta.scdope,
                v_compta.codjnal,
                DECODE (v_compta.type_ope,
                        3, 4,
                        v_compta.type_ope
                       ) codope_entite,
                v_compta.cle, v_compta.sur_entite, v_compta.cle_unique,
                v_compta.cie, v_compta.indv, v_compta.gar, v_compta.INT,
                v_compta.bqe, v_compta.refpiece,
                TRUNC (v_compta.dat_piece) dat_piece, v_compta.lib_piece_1,
                v_compta.lib_piece_2, v_compta.type_ope, v_compta.montant1,
                v_compta.montant2, v_compta.montant3, v_compta.montant4,
                v_compta.montant5, v_compta.montant6, v_compta.montant7,
                v_compta.montant8, v_compta.montant9, v_compta.montant10,
                v_compta.montant11, v_compta.montant12, v_compta.montant13,
                v_compta.montant14, v_compta.montant15, v_compta.montant16,
                v_compta.montant17, v_compta.montant18, v_compta.montant19,
                v_compta.montant20, v_compta.montant21, v_compta.montant22,
                v_compta.montant23, v_compta.montant24, v_compta.montant25,
                v_compta.montant26, v_compta.montant27, v_compta.montant28,
                v_compta.montant29, v_compta.montant30, v_compta.devise,
                v_compta.montant1_ct, v_compta.montant2_ct,
                v_compta.montant3_ct, v_compta.montant4_ct,
                v_compta.montant5_ct, v_compta.montant6_ct,
                v_compta.montant7_ct, v_compta.montant8_ct,
                v_compta.montant9_ct, v_compta.montant10_ct,
                v_compta.montant11_ct, v_compta.montant12_ct,
                v_compta.montant13_ct, v_compta.montant14_ct,
                v_compta.montant15_ct, v_compta.montant16_ct,
                v_compta.montant17_ct, v_compta.montant18_ct,
                v_compta.montant19_ct, v_compta.montant20_ct,
                v_compta.montant21_ct, v_compta.montant22_ct,
                v_compta.montant23_ct, v_compta.montant24_ct,
                v_compta.montant25_ct, v_compta.montant26_ct,
                v_compta.montant27_ct, v_compta.montant28_ct,
                v_compta.montant29_ct, v_compta.montant30_ct,
                v_compta.devise_ct, v_compta.var01, v_compta.var02,
                v_compta.var03, v_compta.var04, v_compta.var05,
                v_compta.var06, v_compta.var07, v_compta.var08,
                v_compta.var09, v_compta.var10, v_compta.var11,
                v_compta.var12, v_compta.var13, v_compta.var14,
                v_compta.var15, v_compta.var16, v_compta.var17,
                v_compta.var18, v_compta.var19, v_compta.var20,
                v_compta.var21, v_compta.var22, v_compta.var23,
                v_compta.var24, v_compta.var25, v_compta.var26,
                v_compta.var27, v_compta.var28, v_compta.var29,
                v_compta.var30, v_compta.var31, v_compta.var32,
                v_compta.var33, v_compta.var34, v_compta.var35
           FROM v_compta
          WHERE v_compta.idcompta = -1
            AND v_compta.numsoc = i_numsoc
            AND v_compta.devise_ct = loc_devise
            AND v_compta.codope BETWEEN NVL (i_deb_codope, v_compta.codope)
                                    AND NVL (i_fin_codope,
                                             NVL (i_deb_codope,
                                                  v_compta.codope
                                                 )
                                            )
            AND TRUNC(v_compta.dat_piece) BETWEEN i_date_debut AND i_date_fin;

--
      rec_c_sel_ecriture          c_sel_ecriture%ROWTYPE;

--
      CURSOR c_sel_idcompta
      IS
         SELECT NVL (MAX (idcompta), 0) + 1 idcompta
           FROM remise_compta;

--
      rec_c_sel_idcompta          c_sel_idcompta%ROWTYPE;
--
      l_suite_traitement          BOOLEAN                   := TRUE;
      l_compteur_validation       NUMBER                    := 0;
--
   BEGIN
      --
      g_session := i_session;
      g_niv_msg := 3;
      g_msg_adm :=
            TO_CHAR (SYSDATE, 'DD/MM/YYYY - HH24:MI')
         || ' - Debut du traitement - P_SEL_ECRITURE ';
      --
      p_ins_journal;

        /*_adm(I_nom_traitement => G_nom_traitement,
                          I_session        => G_session,
                          I_niv_msg        => G_niv_msg,
                          I_msg_adm        => G_lib_msg);*/
      ---- Bordereau par devise
      OPEN c_sel_devise;

      LOOP
         FETCH c_sel_devise
          INTO loc_devise;

         EXIT WHEN c_sel_devise%NOTFOUND;

         -- Suppression des Lignes de la table de Travail
         DELETE FROM trav_compta;

         --

         --
         OPEN c_sel_idcompta;

         FETCH c_sel_idcompta
          INTO rec_c_sel_idcompta;

         CLOSE c_sel_idcompta;

         --
         g_niv_msg := 1;
         g_session := i_session;
         g_msg_adm :=
               TO_CHAR (SYSDATE, 'dd/mm/yyyy - hh24:mi')
            || ' - Debut traitement du bordereau numero :  '
            || TO_CHAR (rec_c_sel_idcompta.idcompta);
         p_ins_journal;
         --
         g_niv_msg := 3;
         g_session := i_session;
         g_msg_adm :=
               'AV. OPEN C_sel_ecriture-P_SEL_ECRITURE idcompta = '
            || TO_CHAR (rec_c_sel_idcompta.idcompta);
         p_ins_journal;
         g_nb_uple_inserer := 0;

         OPEN c_sel_ecriture;

         LOOP
            FETCH c_sel_ecriture
             INTO rec_c_sel_ecriture;

            EXIT WHEN c_sel_ecriture%NOTFOUND;

            /* test ACA */
       /*     g_msg_adm :=
               TO_CHAR (SYSDATE, 'dd/mm/yyyy - hh24:mi')
            || ' - Ligne nÝ '
            || TO_CHAR (g_nb_uple_inserer);
            p_ins_journal;*/
            /* test ACA fin */

            --
            IF rec_c_sel_ecriture.entite = l_cst_decaissement
            THEN
               --
               p_upd_decaissement (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                   i_cle           => rec_c_sel_ecriture.cle
                                  );
                                 -- CTT 13/01/2004 I_codope_entite => Rec_c_sel_ecriture.codope_entite);
            --
            ELSIF rec_c_sel_ecriture.entite = l_cst_encaissement
            THEN
               --
               p_upd_encaissement (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                   i_cle           => rec_c_sel_ecriture.cle
                                  );
                                    -- CTT 13/01/2004 I_codope_entite => Rec_c_sel_ecriture.codope_entite);
            --
            ELSIF rec_c_sel_ecriture.entite = l_cst_annul_encaissement
            THEN
               --
               p_upd_annul_encaissement
                                  (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                   i_cle           => rec_c_sel_ecriture.cle
                                  );
            --
            ELSIF rec_c_sel_ecriture.entite = l_cst_facture
            THEN
               --
               p_upd_facture (i_idcompta           => rec_c_sel_idcompta.idcompta,
                              i_cle                => rec_c_sel_ecriture.cle,
                              i_codope_entite      => rec_c_sel_ecriture.scdope
                             );
                             -- i_codope_entite      => 4
            --
            ELSIF rec_c_sel_ecriture.entite = l_cst_facture_annul
            THEN
               --
               p_upd_facture_annul
                                  (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                   i_cle           => rec_c_sel_ecriture.cle
                                  );
                                    -- CTT 13/01/2004 I_codope_entite => Rec_c_sel_ecriture.codope_entite);
            --
            ELSIF rec_c_sel_ecriture.entite = l_cst_compte_client
            THEN
               --
               p_upd_compte_client
                                  (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                   i_cle           => rec_c_sel_ecriture.cle,
                                   i_codope_entite => rec_c_sel_ecriture.scdope
                                  );
            -- ACA 25/10/2010 Ajout des retrocessions de commissions
            ELSIF rec_c_sel_ecriture.entite = l_cst_compte_tiers
            THEN
               --
               p_upd_compte_tiers
                                  (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                   i_cle           => rec_c_sel_ecriture.cle,
                                   i_codope_entite => rec_c_sel_ecriture.scdope
                                  );
            -- CTT 01/02/2005 ajout des prestations
            ELSIF rec_c_sel_ecriture.entite = l_cst_decompte
            THEN
               --
               p_upd_decompte (i_idcompta      => rec_c_sel_idcompta.idcompta,
                               i_cle           => rec_c_sel_ecriture.cle
                              );
            -- JPF 06/02/2006
            ELSIF rec_c_sel_ecriture.entite = l_cst_facture_regul
            THEN
               --
               p_upd_facture_regul
                                  (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                   i_cle           => rec_c_sel_ecriture.cle
                                  );
            -- JPF 06/02/2006
            ELSIF rec_c_sel_ecriture.entite = l_cst_pnul
            THEN
               --
               p_upd_pnul (i_idcompta      => rec_c_sel_idcompta.idcompta,
                           i_cle           => rec_c_sel_ecriture.cle
                          );
            -- JPF 10/08/2006
            ELSIF rec_c_sel_ecriture.entite = l_cst_affectation
            THEN
               --
               p_upd_affectation (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                  i_cle           => rec_c_sel_ecriture.cle,
                                  i_codope_entite => rec_c_sel_ecriture.scdope
                                 );
            -- SBA, le 19/9/2011 : L'operation comptable 132 relatant un numero d'affectation, l'appel a la procedure <p_upd_affectation> a ete remplace par c<p_upd_affec_enc>
            ELSIF rec_c_sel_ecriture.entite = l_cst_affec_enc
            THEN
               --
               p_upd_affec_enc (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                i_cle           => rec_c_sel_ecriture.cle,
                                i_codope_entite => rec_c_sel_ecriture.scdope
                               );
            ELSIF rec_c_sel_ecriture.entite = l_cst_reversement
            THEN
               --
               p_upd_reversement (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                  i_cle           => rec_c_sel_ecriture.cle
                                  );
            ELSIF rec_c_sel_ecriture.entite = l_cst_retrocession
            THEN
               --
               p_upd_retrocession (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                  i_cle           => rec_c_sel_ecriture.cle
                                  );
            ELSIF rec_c_sel_ecriture.entite = l_cst_decompte_annul
            THEN
               --
               p_upd_decompte_annul (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                     i_cle           => rec_c_sel_ecriture.cle
                                    );
            ELSIF rec_c_sel_ecriture.entite = l_cst_affectation_annul
            THEN
               --
               p_upd_affectation_annul (i_idcompta      => rec_c_sel_idcompta.idcompta,
                                        i_cle           => rec_c_sel_ecriture.cle
                                       );
            END IF;

            /* test ACA */
           /* g_msg_adm :=
               TO_CHAR (SYSDATE, 'dd/mm/yyyy - hh24:mi')
            || ' p_upd_ effectué';
            p_ins_journal;*/
            /* test ACA fin */

            --
            -- Insertion dans la table de travail Compta
            --
            p_ins_trav_compta
               (i_numsoc            => rec_c_sel_ecriture.numsoc,
                i_rolesoc           => rec_c_sel_ecriture.rolesoc,
                i_sur_entite        => rec_c_sel_ecriture.sur_entite,
                i_cle_unique        => rec_c_sel_ecriture.cle_unique,
                i_entite            => rec_c_sel_ecriture.entite,
                i_reg_piece         => rec_c_sel_ecriture.reg_piece,
                i_cle               => rec_c_sel_ecriture.cle,
                i_idcompta          => rec_c_sel_idcompta.idcompta,
                i_codope            => rec_c_sel_ecriture.codope,
                i_scdope            => rec_c_sel_ecriture.scdope,
                i_codjnal           => rec_c_sel_ecriture.codjnal,
                i_cie               => rec_c_sel_ecriture.cie,
                i_indv              => rec_c_sel_ecriture.indv,
                i_gar               => rec_c_sel_ecriture.gar,
                i_int               => rec_c_sel_ecriture.INT,
                i_bqe               => rec_c_sel_ecriture.bqe,
                i_refpiece          => rec_c_sel_ecriture.refpiece,
                i_dat_piece         => rec_c_sel_ecriture.dat_piece,
                i_lib_piece_1       => rec_c_sel_ecriture.lib_piece_1,
                i_lib_piece_2       => rec_c_sel_ecriture.lib_piece_2,
                i_type_ope          => rec_c_sel_ecriture.type_ope,
                i_montant1          => rec_c_sel_ecriture.montant1,
                i_montant2          => rec_c_sel_ecriture.montant2,
                i_montant3          => rec_c_sel_ecriture.montant3,
                i_montant4          => rec_c_sel_ecriture.montant4,
                i_montant5          => rec_c_sel_ecriture.montant5,
                i_montant6          => rec_c_sel_ecriture.montant6,
                i_montant7          => rec_c_sel_ecriture.montant7,
                i_montant8          => rec_c_sel_ecriture.montant8,
                i_montant9          => rec_c_sel_ecriture.montant9,
                i_montant10         => rec_c_sel_ecriture.montant10,
                i_montant11         => rec_c_sel_ecriture.montant11,
                i_montant12         => rec_c_sel_ecriture.montant12,
                i_montant13         => rec_c_sel_ecriture.montant13,
                i_montant14         => rec_c_sel_ecriture.montant14,
                i_montant15         => rec_c_sel_ecriture.montant15,
                i_montant16         => rec_c_sel_ecriture.montant16,
                i_montant17         => rec_c_sel_ecriture.montant17,
                i_montant18         => rec_c_sel_ecriture.montant18,
                i_montant19         => rec_c_sel_ecriture.montant19,
                i_montant20         => rec_c_sel_ecriture.montant20,
                i_montant21         => rec_c_sel_ecriture.montant21,
                i_montant22         => rec_c_sel_ecriture.montant22,
                i_montant23         => rec_c_sel_ecriture.montant23,
                i_montant24         => rec_c_sel_ecriture.montant24,
                i_montant25         => rec_c_sel_ecriture.montant25,
                i_montant26         => rec_c_sel_ecriture.montant26,
                i_montant27         => rec_c_sel_ecriture.montant27,
                i_montant28         => rec_c_sel_ecriture.montant28,
                i_montant29         => rec_c_sel_ecriture.montant29,
                i_montant30         => rec_c_sel_ecriture.montant30,
                i_devise            => rec_c_sel_ecriture.devise,
                i_montant1_ct       => rec_c_sel_ecriture.montant1_ct,
                i_montant2_ct       => rec_c_sel_ecriture.montant2_ct,
                i_montant3_ct       => rec_c_sel_ecriture.montant3_ct,
                i_montant4_ct       => rec_c_sel_ecriture.montant4_ct,
                i_montant5_ct       => rec_c_sel_ecriture.montant5_ct,
                i_montant6_ct       => rec_c_sel_ecriture.montant6_ct,
                i_montant7_ct       => rec_c_sel_ecriture.montant7_ct,
                i_montant8_ct       => rec_c_sel_ecriture.montant8_ct,
                i_montant9_ct       => rec_c_sel_ecriture.montant9_ct,
                i_montant10_ct      => rec_c_sel_ecriture.montant10_ct,
                i_montant11_ct      => rec_c_sel_ecriture.montant11_ct,
                i_montant12_ct      => rec_c_sel_ecriture.montant12_ct,
                i_montant13_ct      => rec_c_sel_ecriture.montant13_ct,
                i_montant14_ct      => rec_c_sel_ecriture.montant14_ct,
                i_montant15_ct      => rec_c_sel_ecriture.montant15_ct,
                i_montant16_ct      => rec_c_sel_ecriture.montant16_ct,
                i_montant17_ct      => rec_c_sel_ecriture.montant17_ct,
                i_montant18_ct      => rec_c_sel_ecriture.montant18_ct,
                i_montant19_ct      => rec_c_sel_ecriture.montant19_ct,
                i_montant20_ct      => rec_c_sel_ecriture.montant20_ct,
                i_montant21_ct      => rec_c_sel_ecriture.montant21_ct,
                i_montant22_ct      => rec_c_sel_ecriture.montant22_ct,
                i_montant23_ct      => rec_c_sel_ecriture.montant23_ct,
                i_montant24_ct      => rec_c_sel_ecriture.montant24_ct,
                i_montant25_ct      => rec_c_sel_ecriture.montant25_ct,
                i_montant26_ct      => rec_c_sel_ecriture.montant26_ct,
                i_montant27_ct      => rec_c_sel_ecriture.montant27_ct,
                i_montant28_ct      => rec_c_sel_ecriture.montant28_ct,
                i_montant29_ct      => rec_c_sel_ecriture.montant29_ct,
                i_montant30_ct      => rec_c_sel_ecriture.montant30_ct,
                i_devise_ct         => rec_c_sel_ecriture.devise_ct,
                i_var01             => rec_c_sel_ecriture.var01,
                i_var02             => rec_c_sel_ecriture.var02,
                i_var03             => rec_c_sel_ecriture.var03,
                i_var04             => rec_c_sel_ecriture.var04,
                i_var05             => TO_CHAR (i_date_debut, 'DDMMYY'),
                i_var06             => TO_CHAR (i_date_fin, 'DDMMYY'),
                i_var07             => rec_c_sel_ecriture.var07,
                i_var08             => rec_c_sel_ecriture.var08,
                i_var09             => rec_c_sel_ecriture.var09,
                i_var10             => rec_c_sel_ecriture.var10,
                i_var11             => rec_c_sel_ecriture.var11,
                i_var12             => rec_c_sel_ecriture.var12,
                i_var13             => rec_c_sel_ecriture.var13,
                i_var14             => rec_c_sel_ecriture.var14,
                i_var15             => rec_c_sel_ecriture.var15,
                i_var16             => rec_c_sel_ecriture.var16,
                i_var17             => rec_c_sel_ecriture.var17,
                i_var18             => rec_c_sel_ecriture.var18,
                i_var19             => rec_c_sel_ecriture.var19,
                i_var20             => rec_c_sel_ecriture.var20,
                i_var21             => rec_c_sel_ecriture.var21,
                i_var22             => rec_c_sel_ecriture.var22,
                i_var23             => rec_c_sel_ecriture.var23,
                i_var24             => rec_c_sel_ecriture.var24,
                i_var25             => rec_c_sel_ecriture.var25,
                i_var26             => rec_c_sel_ecriture.var26,
                i_var27             => SUBSTR
                                          (f_lib_ecriture
                                              (rec_c_sel_ecriture.numsoc,
                                               rec_c_sel_ecriture.codope,
                                               rec_c_sel_ecriture.type_ope,
                                               rec_c_sel_ecriture.lib_piece_1,
                                               rec_c_sel_ecriture.lib_piece_2,
                                               'O'
                                              ),
                                           1,
                                           15
                                          ),
                i_var28             => rec_c_sel_ecriture.var28,
                i_var29             => rec_c_sel_ecriture.var29,
                i_var30             => rec_c_sel_ecriture.var30,
                i_var31             => rec_c_sel_ecriture.var31,
                i_var32             => rec_c_sel_ecriture.var32,
                i_var33             => rec_c_sel_ecriture.var33,
                i_var34             => rec_c_sel_ecriture.var34,
                i_var35             => rec_c_sel_ecriture.var35
               );

            /* test ACA */
        /*    g_msg_adm :=
               TO_CHAR (SYSDATE, 'dd/mm/yyyy - hh24:mi')
            || ' p_ins_trav_compta OK';
            p_ins_journal;*/
            /* test ACA fin */

            --
            g_nb_uple_inserer := g_nb_uple_inserer + 1;
         END LOOP;

         --
         CLOSE c_sel_ecriture;

         --
         g_niv_msg := 3;
         g_msg_adm :=
               'Nombre d''Enreg. ins. dans Trav_compta :'
            || TO_CHAR (g_nb_uple_inserer)
            || ' - '
            || TO_CHAR (rec_c_sel_idcompta.idcompta);
         --
         p_ins_journal;           /*_adm(I_nom_traitement => G_nom_traitement,
                                     I_session        => G_session,
                                     I_niv_msg        => G_niv_msg,
                                     I_msg_adm        => G_lib_msg);*/
         --
         p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);
         --
         g_nb_uple_inserer := 0;
         --
         -- Appel de la procedure de lecture sur la table de travail compta
         --
         p_trt_trav_compta (i_idcompta      => rec_c_sel_idcompta.idcompta,
                            i_numsoc        => i_numsoc
                           );
         -- Valorisation de la zone de regroupement
         p_val_zreg;
         g_niv_msg := 3;
         g_msg_adm := ' Mise a jour de ZREG dans la table Compta effectuée';
         --
         p_ins_journal;
         -- Appel de la procedure de traitement des pieces
         --
         p_trt_piece (i_idcompta          => rec_c_sel_idcompta.idcompta,
                      i_numsoc            => i_numsoc,
                      io_nb_uple_maj      => g_nb_uple_inserer
                     );
         --
         g_niv_msg := 3;
         g_msg_adm :=
               ' Mise a jour dans la table Compta a partir de V_numpiece : '
            || TO_CHAR (g_nb_uple_inserer)
            || ' Lignes';
         --
         p_ins_journal;           /*_adm(I_nom_traitement => G_nom_traitement,
                                     I_session       => G_session,
                                     I_niv_msg        => G_niv_msg,
                                     I_msg_adm        => G_lib_msg);*/
         --
         p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);
         --
         -- Appel de la procedure d'insertion des remises
         --
         p_ins_remise_compta (i_idcompta             => rec_c_sel_idcompta.idcompta,
                              i_date_deb_remise      => i_date_debut,
                              i_date_fin_remise      => i_date_fin,
                              o_nb_uple_inserer      => g_nb_uple_inserer
                             );
         --
         g_niv_msg := 3;
         g_msg_adm :=
               'Insertion dans la table REMISE_COMPTA : '
            || TO_CHAR (g_nb_uple_inserer)
            || ' Lignes';
         --
         p_ins_journal;           /*_adm(I_nom_traitement => G_nom_traitement,
                                     I_session      => G_session,
                                     I_niv_msg        => G_niv_msg,
                                     I_msg_adm        => G_lib_msg);*/
         --
         p_ins_remise_compta_globale
                                   (i_idcompta             => rec_c_sel_idcompta.idcompta,
                                    o_nb_uple_inserer      => g_nb_uple_inserer
                                   );
         --
         g_niv_msg := 3;
         g_msg_adm :=
               'Insertion dans la table REMISE_COMPTA_GLOBALE : '
            || TO_CHAR (g_nb_uple_inserer)
            || ' Lignes';
         --
         p_ins_journal;           /*_adm(I_nom_traitement => G_nom_traitement,
                                     I_session      => G_session,
                                     I_niv_msg     => G_niv_msg,
                                     I_msg_adm     => G_lib_msg);*/
         --
         p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);
         p_centralise (i_idcompta => rec_c_sel_idcompta.idcompta);
         --
         g_niv_msg := 1;
         g_session := i_session;
         g_msg_adm :=
               TO_CHAR (SYSDATE, 'dd/mm/yyyy - hh24:mi')
            || ' - Fin traitement du bordereau numero :  '
            || TO_CHAR (rec_c_sel_idcompta.idcompta);
         p_ins_journal;
         /*g_niv_msg := 1;
         g_msg_adm :=
               'Fin normale du traitement'
            || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI');
         --
         p_ins_journal;           _adm(I_nom_traitement => G_nom_traitement,
                                     I_session      => G_session,
                                     I_niv_msg    => G_niv_msg,
                                     I_msg_adm        => G_lib_msg);*/
         --
         p_use_rollback_commit (i_rollback_segment => NULL);
      END LOOP;

      CLOSE c_sel_devise;
   EXCEPTION
      WHEN OTHERS
      THEN
         --ROLLBACK;
         g_niv_msg := 3;
         g_msg_adm := 'PK_COMPTA' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         --
         -- Insertion dans journal_adm du message d'erreur
         --
         p_ins_journal;          /*_adm(I_nom_traitement => G_nom_traitement,
                                    I_session         => G_session,
                                    I_niv_msg        => G_niv_msg,
                                    I_msg_adm        => G_lib_msg);*/
         --
         p_use_rollback_commit (i_rollback_segment => NULL);
         --
         -- Defaire les tables facture,encaissement etc...
         --
         --P_DEFAIRE_transaction(I_idcompta => Rec_c_sel_idcompta.idcompta);
         --
         RAISE;
   END;

--
   PROCEDURE p_centralise (
      i_idcompta   IN   compta.idcompta%TYPE,
      i_querefp    IN   NUMBER DEFAULT 0
   )
   IS
      CURSOR c_remise_compta
      IS
         SELECT numsoc, fin datcompta, TO_CHAR (debut, 'dd/mm/yy') debut,
                TO_CHAR (fin, 'dd/mm/yy') fin
           FROM remise_compta_globale
          WHERE idcompta = i_idcompta;

      CURSOR c_compta
      IS
         SELECT   numsoc, codope, rolesoc, journal, compte,
                  SUM (DECODE (sens, 'D', -montant, 'C', montant)) montant,
                  SUM (DECODE (sens, 'D', -montant_ct, 'C', montant_ct)
                      ) montant_ct,
                  compta.zreg_val
             FROM compta
            WHERE idcompta = i_idcompta
         GROUP BY numsoc, codope, rolesoc, journal, compte, compta.zreg_val;

      CURSOR c_compta_central
      IS
         SELECT   idcptacent, numsoc, codope, journal, rolesoc
             FROM compta_central
            WHERE idcompta = i_idcompta
         ORDER BY codope, scdope, journal, datope, compta_central.compte;

      --order by numsoc,rolesoc,codope,scdope,journal;

      -- order by idcptacent; JPF 20/03/2006
      rec_c_compta_central   c_compta_central%ROWTYPE;
      rec_c_remise_compta    c_remise_compta%ROWTYPE;
      rec_c_compta           c_compta%ROWTYPE;
      l_numsoc               compta_central.numsoc%TYPE;
      l_codope               compta_central.codope%TYPE;
      l_journal              compta_central.journal%TYPE;
      l_nombre_central       remise_compta.nombre_central%TYPE;
      l_refpiece             compta_central.refpiece%TYPE;
      l_tot_montant          compta_central.montant%TYPE;
      l_sequence             NUMBER                              := 0;
-- L_zreg_val      compta.zreg_val%TYPE;
      l_idcptacent           compta_central.idcptacent%TYPE      := 0;
      l_refpiececent         compta_central.refpiece%TYPE;
      l_premier              NUMBER                              := 1;
      l_sens                 VARCHAR2 (1);
      loc_nb_centrale        NUMBER                              := 0;

      CURSOR c_piece
      IS
         SELECT /*+ RULE */
                refpiececent
           FROM compta
          WHERE idcompta = i_idcompta
            AND numsoc = rec_c_compta_central.numsoc
            AND codope = rec_c_compta_central.codope
            AND journal = rec_c_compta_central.journal
            AND rolesoc = rec_c_compta_central.rolesoc
            AND refpiececent IS NOT NULL
            AND (refpiece, reg_piece) IN (
                   SELECT /*+ RULE */
                          refpiece, reg_piece
                     FROM compta
                    WHERE idcompta = i_idcompta
                      AND numsoc = rec_c_compta_central.numsoc
                      AND codope = rec_c_compta_central.codope
                      AND journal = rec_c_compta_central.journal
                      AND rolesoc = rec_c_compta_central.rolesoc
                      AND idcptacent = rec_c_compta_central.idcptacent);

      CURSOR c_compta_reflig
      IS
         SELECT /*+ and_equal(compta, IDX2_COMPTA, IDX3_COMPTA, IDX5_COMPTA, IDX7_COMPTA) */
                *
           FROM compta
          WHERE idcompta = i_idcompta
            AND numsoc = rec_c_compta.numsoc
            AND codope = rec_c_compta.codope
            AND rolesoc = rec_c_compta.rolesoc
            AND journal = rec_c_compta.journal
            AND compte = rec_c_compta.compte
            AND zreg_val = rec_c_compta.zreg_val
            AND ROWNUM = 1;

      CURSOR c_nombre_central
      IS
         SELECT   compta_central.numsoc, compta_central.codope,
                  compta_central.journal, COUNT (*) nombre_central
             FROM compta_central
            WHERE compta_central.idcompta = i_idcompta AND montant <> 0
         GROUP BY compta_central.numsoc,
                  compta_central.codope,
                  compta_central.journal,
                  TRUNC (SYSDATE);

      rec_c_compta_reflig    c_compta_reflig%ROWTYPE;

       CURSOR c_refreg_piece(ci_idcompta in compta.idcompta%type,
                          ci_idcptacent in compta.idcptacent%type)
      IS
         SELECT refpiece, reg_piece
          FROM compta
          WHERE idcompta = ci_idcompta
           AND idcptacent =
             ci_idcptacent;

      rec_c_refreg_piece c_refreg_piece%ROWTYPE;
   BEGIN
--  permet de ne faire que les ref pieces
      IF i_querefp = 0
      THEN
         g_niv_msg := 3;
         g_msg_adm :=
                  TO_CHAR (SYSDATE, 'DD/MM/YYYY - HH24:MI')
                  || ' - P_Centralise';
         p_ins_journal;

         OPEN c_remise_compta;

         FETCH c_remise_compta
          INTO rec_c_remise_compta;

         CLOSE c_remise_compta;

         OPEN c_compta;
            g_niv_msg := 3;
            g_msg_adm :=
               TO_CHAR (SYSDATE, 'dd/mm/yyyy - hh24:mi')
            || ' OPEN C_COMPTA';
            p_ins_journal;
         LOOP
            FETCH c_compta
             INTO rec_c_compta;

            EXIT WHEN c_compta%NOTFOUND;

            --Exit When L_IDCPTACENT=6;
            /*L_sequence := L_sequence + 1;
            P_SEL_refcentral (
                  I_idcompta  => I_idcompta,
                  I_sequence  => L_sequence,
                  O_refpiece  => L_refpiece ); JPF Mis en comm 23122005*/
            IF rec_c_compta.montant != 0
            THEN              -- pour ne pas prendre en compte les lignes à 0
               BEGIN
                  loc_nb_centrale := loc_nb_centrale + 1;

                  OPEN c_compta_reflig;

                  FETCH c_compta_reflig
                   INTO rec_c_compta_reflig;

                  l_idcptacent := l_idcptacent + 1;

                  IF rec_c_compta.montant < 0
                  THEN
                     l_sens := 'D';
                  ELSE
                     l_sens := 'C';
                  END IF;

                  INSERT INTO compta_central
                              (idcompta, idcptacent,
                               numsoc,
                               codope,
                               journal,
                               compte,
-- SCR 20090716 : ajout compte_aux
                               compte_aux,
-- --
                               rolesoc, sens,
                               monnaie_d,
                               montant_d,
                               montant,
                               scdope,
                               libelle,
                               datope, refpiece,
                               echeance,
                               nature,
                               axana1,
                               axana2,
                               axana3,
                               axana4,
                               axana5,
                               zonex1,
                               zonex2,
                               zonex3,
                               zonex4,
                               zonex5,
-- SCR : 20090716
                               zonex6, zonex7, zonex8, zonex9,
                               zonex10, zonex11, zonex12, zonex13,
-- --
                               zserv1,
                               zserv2,
                               zserv3,
                               zserv4,
                               zserv5,
                               monnaie
                              )
                       VALUES (i_idcompta, l_idcptacent,
                               rec_c_compta_reflig.numsoc,
                               rec_c_compta_reflig.codope,
                               rec_c_compta_reflig.journal,
                               rec_c_compta_reflig.compte,
-- SCR 20090716 : ajout compte_aux
                               rec_c_compta_reflig.compte_aux,
-- --
                               rec_c_compta_reflig.rolesoc, l_sens,
                               rec_c_compta_reflig.devise_ct,
                               ABS (rec_c_compta.montant_ct),
                               ABS (rec_c_compta.montant),
                               rec_c_compta_reflig.scdope,
                               SUBSTR (rec_c_compta_reflig.zserv1, 1, 45),
                               rec_c_compta_reflig.dat_piece, NULL,
                               rec_c_compta_reflig.dat_piece,
                               rec_c_compta_reflig.nature,
                               rec_c_compta_reflig.axana1,
                               rec_c_compta_reflig.axana2,
                               rec_c_compta_reflig.axana3,
                               rec_c_compta_reflig.axana4,
                               rec_c_compta_reflig.axana5,
                               rec_c_compta_reflig.zonex1,
                               rec_c_compta_reflig.zonex2,
                               rec_c_compta_reflig.zonex3,
                               rec_c_compta_reflig.zonex4,
                               rec_c_compta_reflig.zonex5,
-- SCR : 20090716
                               rec_c_compta_reflig.zonex6,
                               rec_c_compta_reflig.zonex7,
                               rec_c_compta_reflig.zonex8,
                               rec_c_compta_reflig.zonex9,
                               rec_c_compta_reflig.zonex10,
                               rec_c_compta_reflig.zonex11,
                               rec_c_compta_reflig.zonex12,
                               rec_c_compta_reflig.zonex13,
-- --
                               rec_c_compta_reflig.zserv1,
                               rec_c_compta_reflig.zserv2,
                               rec_c_compta_reflig.zserv3,
                               rec_c_compta_reflig.zserv4,
                               rec_c_compta_reflig.zserv5,
                               rec_c_compta_reflig.devise
                              );

                  UPDATE compta
                     SET idcptacent = l_idcptacent
                   WHERE idcompta = i_idcompta
                     AND numsoc = rec_c_compta.numsoc
                     AND codope = rec_c_compta.codope
                     AND rolesoc = rec_c_compta.rolesoc
                     AND journal = rec_c_compta.journal
                     AND compte = rec_c_compta.compte
                     AND zreg_val = rec_c_compta.zreg_val;


                  CLOSE c_compta_reflig;
               END;
            ELSE

               UPDATE compta
                  SET idcptacent = 0
                WHERE idcompta = i_idcompta
                  AND numsoc = rec_c_compta.numsoc
                  AND codope = rec_c_compta.codope
                  AND rolesoc = rec_c_compta.rolesoc
                  AND journal = rec_c_compta.journal
                  AND compte = rec_c_compta.compte
                  AND zreg_val = rec_c_compta.zreg_val;
            END IF;                                             -- Fin cas à 0

            p_use_rollback_commit
                                 (i_rollback_segment      => l_cst_rollback_segment);
         END LOOP;

         CLOSE c_compta;

         --
         g_niv_msg := 1;
         g_msg_adm :=
               TO_CHAR (SYSDATE, 'dd/mm/yyyy - hh24:mi')
            || ' - Fin insertion dans COMPTA_CENTRAL : '
            || TO_CHAR (loc_nb_centrale)
            || ' ecritures';
         p_ins_journal;
         --
         g_niv_msg := 3;
         g_msg_adm :=
               'P_centralise - Maj remise_compta_globale de nombre_central =  '
            || TO_CHAR (loc_nb_centrale);
         g_niv_msg := 3;
         p_ins_journal;

         UPDATE remise_compta_globale
            SET nombre_central = loc_nb_centrale
          WHERE idcompta = i_idcompta;

         OPEN c_nombre_central;

         LOOP
            FETCH c_nombre_central
             INTO l_numsoc, l_codope, l_journal, l_nombre_central;

            EXIT WHEN c_nombre_central%NOTFOUND;

            UPDATE remise_compta
               SET nombre_central = l_nombre_central
             WHERE idcompta = i_idcompta
               AND remise_compta.numsoc = l_numsoc
               AND remise_compta.codope = l_codope
               AND remise_compta.journal = l_journal;
         END LOOP;
      END IF;                                                 -- sur I_QueRefP

/* Traitement des référence de piece compta_central */
      g_niv_msg := 3;
      g_msg_adm :=
            TO_CHAR (SYSDATE, 'DD/MM/YYYY - HH24:MI')
         || ' - P_centralise - Trait. des réf. de piece';
      g_niv_msg := 3;
      p_ins_journal;
      p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);

      OPEN c_compta_central;

      LOOP
         FETCH c_compta_central
          INTO rec_c_compta_central;

         EXIT WHEN c_compta_central%NOTFOUND;

         IF (l_premier = 1)
         THEN
            SELECT racine || TRIM (TO_CHAR (compteur + 1, '0000000'))
              INTO l_refpiececent
              FROM compta_idpiece
             WHERE journal = rec_c_compta_central.journal;

            UPDATE compta_idpiece
               SET compteur = compteur + 1
             WHERE journal = rec_c_compta_central.journal;

             OPEN c_refreg_piece(i_idcompta,rec_c_compta_central.idcptacent);
             LOOP
                FETCH c_refreg_piece
                INTO rec_c_refreg_piece;

                EXIT WHEN c_refreg_piece%NOTFOUND;

            /*Update COMPTA set REFPIECECENT =  L_REFPIECECENT
               where  idcompta = I_idcompta
               and    REFPIECECENT is null
               and    numsoc = Rec_C_compta_central.numsoc
               and    codope = Rec_C_compta_central.codope
               and    journal = Rec_C_compta_central.journal
               and    refpiece in (select distinct(REFPIECE)
                           from   compta
                           where  idcompta   = I_idcompta
                           and    IDCPTACENT = Rec_C_compta_central.IDCPTACENT);*/
            UPDATE /*+ RULE */compta
               SET refpiececent = l_refpiececent
             WHERE idcompta = i_idcompta
               AND refpiececent IS NULL
               AND numsoc = rec_c_compta_central.numsoc
               AND codope = rec_c_compta_central.codope
               AND rolesoc = rec_c_compta_central.rolesoc
               AND journal =  rec_c_compta_central.journal
               AND refpiece = rec_c_refreg_piece.refpiece
               AND reg_piece = rec_c_refreg_piece.reg_piece
              /* AND idcptacent = IN (
                      SELECT          /*+ RULE */
                     /*         (idcptacent)
                                 FROM compta
                                WHERE idcompta = i_idcompta
                                  AND numsoc = rec_c_compta_central.numsoc
                                  AND codope = rec_c_compta_central.codope
                                  AND rolesoc = rec_c_compta_central.rolesoc
                                  AND journal = rec_c_compta_central.journal
                                  AND (refpiece, reg_piece) IN (
                                         SELECT /*+ RULE */
                  /*                              refpiece, reg_piece
                                           FROM compta
                                          WHERE idcompta = i_idcompta
                                            AND idcptacent =
                                                   rec_c_compta_central.idcptacent))*/;

            --and    IDCPTACENT=Rec_C_compta_central.IDCPTACENT   ;

            END LOOP;
            CLOSE c_refreg_piece;


            UPDATE compta_central
               SET refpiece = l_refpiececent
             WHERE idcompta = i_idcompta
               AND idcptacent = rec_c_compta_central.idcptacent;

            l_premier := 0;
         ELSE
            OPEN c_piece;

            FETCH c_piece
             INTO l_refpiececent;

            IF (c_piece%NOTFOUND)
            THEN
               SELECT racine || TRIM (TO_CHAR (compteur + 1, '0000000'))
                 INTO l_refpiececent
                 FROM compta_idpiece
                WHERE journal = rec_c_compta_central.journal;

               UPDATE compta_idpiece
                  SET compteur = compteur + 1
                WHERE journal = rec_c_compta_central.journal;

                 OPEN c_refreg_piece(i_idcompta,rec_c_compta_central.idcptacent);
             LOOP
                FETCH c_refreg_piece
                INTO rec_c_refreg_piece;

                EXIT WHEN c_refreg_piece%NOTFOUND;

            /*Update COMPTA set REFPIECECENT =  L_REFPIECECENT
               where  idcompta = I_idcompta
               and    REFPIECECENT is null
               and    numsoc = Rec_C_compta_central.numsoc
               and    codope = Rec_C_compta_central.codope
               and    journal = Rec_C_compta_central.journal
               and    refpiece in (select distinct(REFPIECE)
                           from   compta
                           where  idcompta   = I_idcompta
                           and    IDCPTACENT = Rec_C_compta_central.IDCPTACENT);*/
            UPDATE /*+ RULE */compta
               SET refpiececent = l_refpiececent
             WHERE idcompta = i_idcompta
               AND refpiececent IS NULL
               AND numsoc = rec_c_compta_central.numsoc
               AND codope = rec_c_compta_central.codope
               AND rolesoc = rec_c_compta_central.rolesoc
               AND journal =  rec_c_compta_central.journal
               AND refpiece = rec_c_refreg_piece.refpiece
               AND reg_piece = rec_c_refreg_piece.reg_piece
              /* AND idcptacent = IN (
                      SELECT          /*+ RULE */
                     /*         (idcptacent)
                                 FROM compta
                                WHERE idcompta = i_idcompta
                                  AND numsoc = rec_c_compta_central.numsoc
                                  AND codope = rec_c_compta_central.codope
                                  AND rolesoc = rec_c_compta_central.rolesoc
                                  AND journal = rec_c_compta_central.journal
                                  AND (refpiece, reg_piece) IN (
                                         SELECT /*+ RULE */
                  /*                              refpiece, reg_piece
                                           FROM compta
                                          WHERE idcompta = i_idcompta
                                            AND idcptacent =
                                                   rec_c_compta_central.idcptacent))*/;

            --and    IDCPTACENT=Rec_C_compta_central.IDCPTACENT   ;

            END LOOP;
            CLOSE c_refreg_piece;

               UPDATE compta_central
                  SET refpiece = l_refpiececent
                WHERE idcompta = i_idcompta
                  AND idcptacent = rec_c_compta_central.idcptacent;
            ELSE
                 OPEN c_refreg_piece(i_idcompta,rec_c_compta_central.idcptacent);
             LOOP
                FETCH c_refreg_piece
                INTO rec_c_refreg_piece;

                EXIT WHEN c_refreg_piece%NOTFOUND;

            /*Update COMPTA set REFPIECECENT =  L_REFPIECECENT
               where  idcompta = I_idcompta
               and    REFPIECECENT is null
               and    numsoc = Rec_C_compta_central.numsoc
               and    codope = Rec_C_compta_central.codope
               and    journal = Rec_C_compta_central.journal
               and    refpiece in (select distinct(REFPIECE)
                           from   compta
                           where  idcompta   = I_idcompta
                           and    IDCPTACENT = Rec_C_compta_central.IDCPTACENT);*/
            UPDATE /*+ RULE */compta
               SET refpiececent = l_refpiececent
             WHERE idcompta = i_idcompta
               AND refpiececent IS NULL
               AND numsoc = rec_c_compta_central.numsoc
               AND codope = rec_c_compta_central.codope
               AND rolesoc = rec_c_compta_central.rolesoc
               AND journal =  rec_c_compta_central.journal
               AND refpiece = rec_c_refreg_piece.refpiece
               AND reg_piece = rec_c_refreg_piece.reg_piece
              /* AND idcptacent = IN (
                      SELECT          /*+ RULE */
                     /*         (idcptacent)
                                 FROM compta
                                WHERE idcompta = i_idcompta
                                  AND numsoc = rec_c_compta_central.numsoc
                                  AND codope = rec_c_compta_central.codope
                                  AND rolesoc = rec_c_compta_central.rolesoc
                                  AND journal = rec_c_compta_central.journal
                                  AND (refpiece, reg_piece) IN (
                                         SELECT /*+ RULE */
                  /*                              refpiece, reg_piece
                                           FROM compta
                                          WHERE idcompta = i_idcompta
                                            AND idcptacent =
                                                   rec_c_compta_central.idcptacent))*/;

            --and    IDCPTACENT=Rec_C_compta_central.IDCPTACENT   ;

            END LOOP;
            CLOSE c_refreg_piece;
               UPDATE compta_central
                  SET refpiece = l_refpiececent
                WHERE idcompta = i_idcompta
                  AND idcptacent = rec_c_compta_central.idcptacent;
            END IF;

            CLOSE c_piece;
         END IF;

         p_use_rollback_commit (i_rollback_segment => l_cst_rollback_segment);
      -- G_msg_adm    := 'P_Centralise-Trait. Lig. ' ||Rec_C_compta_central.idcptacent||'-'|| to_char(sysdate, 'DD/MM/YYYY HH24:MI');
      -- G_niv_msg    := 3;
      -- P_INS_journal;
      END LOOP;

      CLOSE c_compta_central;                     -- NS/VC ajout le 21/08/2006

      --
      g_niv_msg := 1;
      g_msg_adm :=
            TO_CHAR (SYSDATE, 'DD/MM/YYYY - HH24:MI')
         || ' - Fin de la maj des ref. dans COMPTA_CENTRAL ';
      p_ins_journal;
      --
      g_niv_msg := 3;
      g_msg_adm :=
            TO_CHAR (SYSDATE, 'DD/MM/YYYY - HH24:MI')
         || ' - Fin traitement P_centralise ';
      g_niv_msg := 3;
      p_ins_journal;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 3;
         g_msg_adm :=
               SUBSTR (SQLERRM (SQLCODE), 1, 76)
            || ' Erreur sur le traitement P_centralise ';
         g_niv_msg := 1;
         p_ins_journal;
   END p_centralise;
-- ========================== Fin des corps des procedures publiques===========
END;
/
