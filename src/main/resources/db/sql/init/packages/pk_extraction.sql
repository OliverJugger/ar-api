CREATE OR REPLACE PACKAGE ARTHUS.pk_extraction AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
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
--
-- Extraction des encaissements
--
Procedure P_SEL_encaismt (
                I_deb_codope            IN encaismt.codope%Type,
                I_fin_codope            IN encaismt.codope%Type,
                I_deb_modpmt            IN encaismt.modpmt%Type,
                I_fin_modpmt            IN encaismt.modpmt%Type,
                I_deb_type_contrat      IN Number,
                I_fin_type_contrat      IN Number,
                I_deb_risque            IN Number,
                I_fin_risque            IN Number,
                I_debut                 IN Date,
                I_fin                   IN Date,
                I_deb_eche              IN Date,
                I_fin_eche              IN Date,
                I_deb_numcli            IN encaismt.numcli%Type,
                I_fin_numcli            IN encaismt.numcli%Type,
                I_numencaismt           IN encaismt.numencaismt%Type,
                I_session               IN Number,
                I_flag_test             IN Number
                );
--
-- Extraction des decaissements
--
Procedure P_SEL_decaismt (
                I_deb_codope            IN decaismt.codope%Type,
                I_fin_codope            IN decaismt.codope%Type,
                I_deb_modpmt            IN decaismt.modpmt%Type,
                I_fin_modpmt            IN decaismt.modpmt%Type,
                I_deb_type_contrat      IN Number,
                I_fin_type_contrat      IN Number,
                I_deb_risque            IN Number,
                I_fin_risque            IN Number,
                I_debut                 IN Date,
                I_fin                   IN Date,
                I_deb_numcli            IN decaismt.numdest%Type,
                I_fin_numcli            IN decaismt.numdest%Type,
                I_session               IN Number,
                I_flag_test             IN Number,
                I_flag_retro            IN Number
                );
--
-- Extraction des emissions de cotisations
--
Procedure P_SEL_emission (
  I_debut   IN Date,
  I_fin   IN Date,
  I_deb_eche  IN Date,
  I_fin_eche  IN Date,
  I_deb_type_contrat IN Number,
  I_fin_type_contrat IN Number,
  I_deb_risque  IN Number,
  I_fin_risque  IN Number,
  I_deb_numcli   IN qttc_global.numquerable%Type,
  I_fin_numcli   IN qttc_global.numquerable%Type,
  I_session        IN Number,
                I_flag_test      IN Number
  );
--
-- Exploitation de trav_treso
--
Procedure P_SEL_trav_treso (
                I_etendue       IN  Number,
                O_ligne         OUT VARCHAR
                );
--
-- Extraction du compte d'attente
--
Procedure P_SEL_compte_attente(
                I_deb_origine   IN encaismt.codope%Type,
                I_fin_origine   IN encaismt.codope%Type,
                I_deb_modpmt    IN encaismt.modpmt%Type,
                I_fin_modpmt    IN encaismt.modpmt%Type,
                I_deb_numcli    IN encaismt.numcli%Type,
                I_fin_numcli    IN encaismt.numcli%Type,
                I_datope        IN encaismt.datpay%Type,
                I_numencaismt   IN encaismt.numencaismt%Type,
                I_session       IN Number,
                I_flag_test     IN Number,
                O_ligne         OUT VARCHAR
                );
--
-- Retourne le montant affecte pour un encaissement a une date
--
Function F_totaffec (
                I_numencaismt   IN      encaismt.numencaismt%Type,
                I_datref        IN      Date
                )
Return Number;
Pragma Restrict_References(F_totaffec, WNDS, WNPS);
--
-- Retourne le type de risque pour une garantie
--
Function F_nat_risque (
                I_numfor        IN      gar_cntrt.numfor%Type
                )
Return Number;
Pragma Restrict_References(F_nat_risque, WNDS, WNPS);
--
-- Retourne le type de contrat pour une garantie
--
Function F_type_contrat (
                I_numfor        IN      gar_cntrt.numfor%Type
                )
Return Number;
Pragma Restrict_References(F_type_contrat, WNDS, WNPS);
--
-- Retourne la branche pour une garantie
--
Function F_branche (
                I_numfor        IN      gar_cntrt.numfor%Type
                )
Return Number;
Pragma Restrict_References(F_branche, WNDS, WNPS);
--
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_EXTRACTION" 
AS
-- $Rev:: 129                                    $:  Revision du dernier commit
-- $Author:: b.cortial                           $:  Auteur du dernier commit
-- $Date: 2022-12-29 15:38:06 +0100 (jeu., 29 dÃ©c. 2022) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PACKAGE_BODIES/PK_EXTRACTION.pkb $:  Chemin

-- Chaine de reconnaissance SCCS
-- %W% Extractions comptables %E%
--
-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--@global
--
-- Parametres des extractions
--
   g_deb_codope                encaismt.codope%TYPE;
   g_fin_codope                encaismt.codope%TYPE;
   g_deb_modpmt                encaismt.modpmt%TYPE;
   g_fin_modpmt                encaismt.modpmt%TYPE;
   g_deb_numcli                encaismt.numcli%TYPE;
   g_fin_numcli                encaismt.numcli%TYPE;
   g_debut                     DATE;
   g_fin                       DATE;
   g_deb_eche                  DATE;
   g_fin_eche                  DATE;
   g_deb_type_contrat          NUMBER;
   g_fin_type_contrat          NUMBER;
   g_deb_risque                NUMBER;
   g_fin_risque                NUMBER;
   g_numencaismt               NUMBER                            := NULL;
-- 1 -> Encaissements   -1 -> Decaissements
   g_etendue                   NUMBER;
   g_flag_annul                BOOLEAN                           := FALSE;
-- Ventilation des commissions reglees -> FALSE pas de ventilation
   g_flag_retro                BOOLEAN                           := FALSE;
-- Montant affecte -> Indus
   g_affectation               NUMBER;
--
-- Variables de P_INS_trav_treso
--
   g_trav_codope               trav_treso.codope%TYPE;
   g_trav_branche              trav_treso.branche%TYPE;
   g_trav_type_contrat         trav_treso.type_contrat%TYPE;
   g_trav_risque               trav_treso.risque%TYPE;
   g_trav_exercice             trav_treso.exercice%TYPE;
   g_trav_idpiece              trav_treso.idpiece%TYPE;
   g_trav_date_piece           trav_treso.date_piece%TYPE;
   g_trav_date_affec           trav_treso.date_affec%TYPE;
   g_trav_mregl                trav_treso.mregl%TYPE;
   g_trav_numtiers             trav_treso.numtiers%TYPE;
   g_trav_mt_regl              trav_treso.mt_regl%TYPE;
   g_trav_mt_affec             trav_treso.mt_affec%TYPE;
   g_trav_refpiece             trav_treso.refpiece%TYPE;
   g_trav_lib_piece            trav_treso.lib_piece%TYPE;
   g_trav_type_risque          trav_treso.type_risque%TYPE       := 0;
   g_trav_refremise            trav_treso.refremise%TYPE;
   g_trav_type_retro           trav_treso.type_retro%TYPE;
   g_trav_numgar               trav_treso.numgar%TYPE;
   g_trav_libcompte            trav_treso.libcompte%TYPE;
   g_trav_signe                NUMBER                            := 1;
--
-- Variables de P_INS_journal
--
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                      DEFAULT 'pk_extraction';
   g_id_session                journal_adm.id_session%TYPE       DEFAULT 1;
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_flag_test                 NUMBER;
   g_niv_msg                   journal_adm.niv_msg%TYPE;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_proc                      VARCHAR2 (80);

--
-- -------------------------------------- Fin des variables globales privees --
-- CURSEURS PRIVEES-------------------------------------------------------
--@curs
--
-- Curseur de trav_treso
--
   CURSOR c_sel_trav_treso
   IS
      SELECT codope, branche, type_contrat, risque, exercice, idpiece,
             date_piece, date_affec, mregl, numtiers, mt_regl, mt_affec,
             refpiece, lib_piece, type_risque, refremise, type_retro, numgar,
             libcompte
        FROM trav_treso;

--
-- Encaissements non affectes
--
   CURSOR c_sel_compte_attente
   IS
      SELECT compte_client.idaffec, encaismt.numcli, encaismt.numencaismt,
             encaismt.datpay, encaismt.montant,
             compte_client.montant mt_attente, encaismt.modpmt,
             encaismt.refpmt, encaismt.codope origine
        FROM encaismt, compte_client
       WHERE compte_client.numencaismt = encaismt.numencaismt
         AND compte_client.codope = 8
         AND encaismt.codope BETWEEN NVL (g_deb_codope, encaismt.codope)
                                 AND NVL (g_fin_codope,
                                          NVL (g_deb_codope, encaismt.codope)
                                         )
         AND encaismt.modpmt BETWEEN NVL (g_deb_modpmt, encaismt.modpmt)
                                 AND NVL (g_fin_modpmt,
                                          NVL (g_deb_modpmt, encaismt.modpmt)
                                         )
         AND compte_client.numcli BETWEEN NVL (g_deb_numcli,
                                               compte_client.numcli
                                              )
                                      AND NVL (g_fin_numcli,
                                               NVL (g_deb_numcli,
                                                    compte_client.numcli
                                                   )
                                              )
         AND compte_client.datope <= g_debut
         AND encaismt.numencaismt = NVL (g_numencaismt, encaismt.numencaismt)
         AND NOT EXISTS (
                SELECT 1
                  FROM rbtcptcli, affectation
                 WHERE rbtcptcli.idaffec = compte_client.idaffec
                   AND affectation.codope = 8
                   AND affectation.numaffec = rbtcptcli.numaffec
                   AND affectation.dataffec <= g_debut)
         AND NOT EXISTS (
                SELECT 1
                  FROM annul_encais
                 WHERE annul_encais.numencaismt = encaismt.numencaismt
                   AND annul_encais.date_annul <= g_debut)
      UNION
/*
Select  0                       idaffec,
        encaismt.numcli,
        encaismt.numencaismt,
        encaismt.datpay,
        encaismt.montant,
        encaismt.montant - F_totaffec( encaismt.numencaismt, G_debut )
                                mt_attente,
        encaismt.modpmt,
        encaismt.refpmt,
        encaismt.codope         origine
From    encaismt,
        compte_client
Where   compte_client.numencaismt = encaismt.numencaismt
and     compte_client.codope + 0 != 8
and     encaismt.codope + 0 != 10
and     encaismt.codope between nvl(G_deb_codope, encaismt.codope)
                        and nvl( G_fin_codope,
                                nvl(G_deb_codope, encaismt.codope) )
and     encaismt.modpmt between nvl(G_deb_modpmt, encaismt.modpmt)
                        and nvl( G_fin_modpmt,
                                nvl(G_deb_modpmt, encaismt.modpmt) )
and     compte_client.numcli between nvl(G_deb_numcli,compte_client.numcli)
                and  nvl( G_fin_numcli,
                        nvl(G_deb_numcli, compte_client.numcli) )
and     compte_client.datope > G_debut
and     encaismt.montant - F_totaffec( encaismt.numencaismt, G_debut ) != 0
and     encaismt.numencaismt = nvl( G_numencaismt, encaismt.numencaismt )
and     not exists (
                select  1
                from    annul_encais
                where   annul_encais.numencaismt = encaismt.numencaismt
                and     annul_encais.date_annul <= G_debut)
Group By
        encaismt.numcli,
        encaismt.numencaismt,
        encaismt.datpay,
        encaismt.montant,
        encaismt.modpmt,
        encaismt.refpmt,
        encaismt.codope,
        G_debut
Union
*/
      SELECT compte_tiers.idmvt idaffec, encaismt.numcli,
             compte_tiers.cle numencaismt, encaismt.datpay, encaismt.montant,
               compte_tiers.montant
             + pk_treso.f_contrepartie (compte_tiers.idmvt, g_debut)
                                                                   mt_attente,
             encaismt.modpmt, encaismt.refpmt, encaismt.codope origine
        FROM encaismt, compte_tiers
       WHERE encaismt.numencaismt = compte_tiers.cle
         AND compte_tiers.codope = 10
         AND compte_tiers.sens = 1
         AND encaismt.numencaismt = NVL (g_numencaismt, encaismt.numencaismt)
         AND encaismt.codope BETWEEN NVL (g_deb_codope, encaismt.codope)
                                 AND NVL (g_fin_codope,
                                          NVL (g_deb_codope, encaismt.codope)
                                         )
         AND encaismt.modpmt BETWEEN NVL (g_deb_modpmt, encaismt.modpmt)
                                 AND NVL (g_fin_modpmt,
                                          NVL (g_deb_modpmt, encaismt.modpmt)
                                         )
         AND compte_tiers.numcli BETWEEN NVL (g_deb_numcli,
                                              compte_tiers.numcli
                                             )
                                     AND NVL (g_fin_numcli,
                                              compte_tiers.numcli
                                             )
         AND compte_tiers.datope <= g_debut
         AND   compte_tiers.montant
             + pk_treso.f_contrepartie (compte_tiers.idmvt, g_debut) != 0
         AND NOT EXISTS (
                SELECT 1
                  FROM annul_encais
                 WHERE annul_encais.numencaismt = encaismt.numencaismt
                   AND annul_encais.date_annul <= g_debut);

   rec_c_attente               c_sel_compte_attente%ROWTYPE;

-- -------------------------------------------- Fin des curseurs privees --
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --
-- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--@priv
--
-- Retourne vrai si la comm a ete prelevee en une fois
--
   FUNCTION f_ctrl_one_shot (
      i_numquit   IN   one_shot.numquit%TYPE,
      i_idaffec   IN   one_shot.idaffec%TYPE
   )
      RETURN BOOLEAN;

--
-- Retourne vrai si la comm a deja ete prelevee
--
   FUNCTION f_ctrl_prelev (
      i_numquit   IN   one_shot.numquit%TYPE,
      i_idaffec   IN   one_shot.idaffec%TYPE
   )
      RETURN BOOLEAN;

--
-- Retourne la reference remise
--
   PROCEDURE p_sel_refremise (
      i_cle         IN       NUMBER,
      i_modpmt      IN       NUMBER,
      i_numcpte     IN       NUMBER,
      i_numchq      IN       NUMBER,
      i_sens        IN       NUMBER,
      o_refremise   OUT      trav_treso.refremise%TYPE,
      o_libcompte   OUT      trav_treso.libcompte%TYPE
   );

--
-- Remboursement tiers ou solde comptable
--
   PROCEDURE p_sel_solde_tiers (i_numencaismt IN encaismt.numencaismt%TYPE);

--
-- Remboursement client ou solde comptable
--
   PROCEDURE p_sel_solde_client (i_idaffec IN rbtcptcli.idaffec%TYPE);

--
-- Remboursement client ou solde comptable ( decaissements )
--
   PROCEDURE p_sel_rbtcptcli (i_numaffec IN affectation.numaffec%TYPE);

--
-- Remboursement encaissement fournisseur
--
   PROCEDURE p_sel_rbtcpttiers (
      i_idmvt   IN   compte_tiers.idmvt%TYPE,
      i_cle     IN   compte_tiers.cle%TYPE
   );

--
-- Selection du compte_tiers
--
   PROCEDURE p_sel_compte_tiers (i_cle IN compte_tiers.cle%TYPE);

--
-- Selection des affectations
--
   PROCEDURE p_sel_affectation (i_numdecaismt IN affectation.numdecaismt%TYPE);

--
-- Selection des annulations d' affectations
--
   PROCEDURE p_sel_affectation_annul (
      i_numdecaismt   IN   affectation.numdecaismt%TYPE
   );

-- -- JBO : 27/11/2009 : Activation P_SEL_detail_annul
-- Necessite maj MPD annulations de decaissement
--
-- Traitement du detail annulation de decaissement
--
Procedure P_SEL_detail_annul (
                I_idpiece       IN      detail_annul.idpiece%Type
                );

--
-- Traitement des ecritures compte_client
--
   PROCEDURE p_sel_compte_client (
      i_numencaismt   IN   compte_client.numencaismt%TYPE
   );

--
-- Traitement des ecritures compte_client par compensation
--
   PROCEDURE p_sel_compensation (
      i_deb_codope   IN   compte_client.codope%TYPE,
      i_fin_codope   IN   compte_client.codope%TYPE,
      i_deb_numcli   IN   compte_client.numcli%TYPE,
      i_fin_numcli   IN   compte_client.numcli%TYPE
   );

--
-- Traitement des ecritures debit par compensation
--
   PROCEDURE p_sel_comp_debit (
      i_deb_codope   IN   compte_tiers.codope%TYPE,
      i_fin_codope   IN   compte_tiers.codope%TYPE,
      i_deb_numcli   IN   compte_tiers.numcli%TYPE,
      i_fin_numcli   IN   compte_tiers.numcli%TYPE,
      i_debut        IN   DATE,
      i_fin          IN   DATE
   );

--
-- Traitement des frais globaux emis
--
   PROCEDURE p_sel_emis_frais (i_numquit IN qttc_global.numquit%TYPE);

--
-- Traitement des emissions par garantie
--
   PROCEDURE p_sel_emis_gar (i_numquit IN qttc_global.numquit%TYPE);

--
-- Traitement des taxes emises
--
   PROCEDURE p_sel_emis_taxes (
      i_numquit   IN   qttc_global.numquit%TYPE,
      i_risque    IN   NUMBER
   );

--
-- Traitement des commissions sur garanties emises
--
   PROCEDURE p_sel_emis_comm (
      i_numquit   IN   qttc_global.numquit%TYPE,
      i_risque    IN   NUMBER
   );

--
-- Traitement des frais sur garanties emises
--
   PROCEDURE p_sel_emis_frais_gar (
      i_numquit   IN   qttc_global.numquit%TYPE,
      i_risque    IN   NUMBER
   );

--
-- Traitement des cotisations ( codope 4 )
--
   PROCEDURE p_sel_cotis (i_idaffec IN qttc_affec.idaffec%TYPE);

--
-- Traitement des commissions prelevees en une fois
--
   PROCEDURE p_sel_retro (
      i_numquit      IN   qttc_retro.numquit%TYPE,
      i_nat_risque   IN   NUMBER,
      i_signe        IN   NUMBER
   );

--
-- Traitement des commissions prelevees
--
   PROCEDURE p_sel_comm_prelev (
      i_idaffec      IN   qttc_affec_tfc.idaffec%TYPE,
      i_nat_risque   IN   NUMBER,
	  i_branche		 IN	  NUMBER
   );

--
-- Traitement des taxes sur cotisations
--
   PROCEDURE p_sel_taxes (
      i_idaffec      IN   qttc_affec_tfc.idaffec%TYPE,
      i_nat_risque   IN   NUMBER
   );

--
-- Traitement des frais sur garanties
--
   PROCEDURE p_sel_frais_gar (
      i_idaffec      IN   qttc_affec_tfc.idaffec%TYPE,
      i_nat_risque   IN   NUMBER
   );

--
-- Traitement des frais sur cotisations
--
   PROCEDURE p_sel_frais (i_idaffec IN qttc_affec_tfc.idaffec%TYPE);

--
-- Traitement des retrocessions ( codope 16 )
--
   PROCEDURE p_sel_retro (i_idrevers IN retrocession.idrevers%TYPE);

--
-- Traitement des retrocessions (ventilation par type)
--
   PROCEDURE p_sel_type_retro (i_idrevers IN retrocession.idrevers%TYPE);

--
-- Traitement des prestations sante ( codope 1 )
--
   PROCEDURE p_sel_sante (i_numdec IN decompte.numdec%TYPE);

--
-- Traitement des prestations sante annulation ( codope 9 )
--
   PROCEDURE p_sel_sante_annul (i_numdec IN decompte.numdec%TYPE);

--
-- Traitement des prestations prevoyance ( codope 2 )
--
   PROCEDURE p_sel_prev (i_numdec IN decompte_prev.numdec%TYPE);

--
-- Traitement des indus de prestations ( codope 1, 2 )
--
   PROCEDURE p_sel_indu (i_numencaismt IN encaismt.numencaismt%TYPE);

--
-- Retourne le libelle de la branche
--
   PROCEDURE p_sel_branche (
      i_branche   IN       NUMBER,
      o_libelle   OUT      libelle.libelle%TYPE
   );

--
-- Suppression de trav_treso
--
   PROCEDURE p_del_trav_treso;

--
-- Insertion dans trav_treso
--
   PROCEDURE p_ins_trav_treso;

--
-- Insertion dans journal_adm
--
   PROCEDURE p_ins_journal;

-- ----------------------------- Fin des declarations des procedures privees --
-- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
--
-- Extraction des emissions de cotisations
--
   PROCEDURE p_sel_emission (
      i_debut              IN   DATE,
      i_fin                IN   DATE,
      i_deb_eche           IN   DATE,
      i_fin_eche           IN   DATE,
      i_deb_type_contrat   IN   NUMBER,
      i_fin_type_contrat   IN   NUMBER,
      i_deb_risque         IN   NUMBER,
      i_fin_risque         IN   NUMBER,
      i_deb_numcli         IN   qttc_global.numquerable%TYPE,
      i_fin_numcli         IN   qttc_global.numquerable%TYPE,
      i_session            IN   NUMBER,
      i_flag_test          IN   NUMBER
   )
   IS
      CURSOR c_emis
      IS
         SELECT qttc_global.numquit, qttc_global.debut,
                TO_CHAR (qttc_global.debut, 'yyyy') exercice,
                qttc_global.numquerable, qttc_global.numgar,
                qttc_global.comptant, contrat.typgar, emission.datemis,
                emission.numrelance, facture.montant, facture.mregl
           FROM emission, facture, qttc_global, contrat
          WHERE emission.codope = 4
            AND emission.numfact = qttc_global.numquit
            AND emission.datemis BETWEEN i_debut AND NVL (i_fin,
                                                          emission.datemis
                                                         )
            AND emission.numrelance IN (0, 4, 99)
            AND facture.codope = 4
            AND facture.numfact = qttc_global.numquit
            AND contrat.numgar = qttc_global.numgar
            AND contrat.typgar BETWEEN NVL (i_deb_type_contrat,
                                            contrat.typgar)
                                   AND NVL (i_fin_type_contrat,
                                            NVL (i_deb_type_contrat,
                                                 contrat.typgar
                                                )
                                           )
            AND qttc_global.debut BETWEEN NVL (i_deb_eche, qttc_global.debut)
                                      AND NVL (i_fin_eche,
                                               NVL (i_deb_eche,
                                                    qttc_global.fin
                                                   )
                                              )
            AND qttc_global.numquerable BETWEEN NVL (i_deb_numcli,
                                                     qttc_global.numquerable
                                                    )
                                            AND NVL
                                                  (i_fin_numcli,
                                                   NVL
                                                      (i_deb_numcli,
                                                       qttc_global.numquerable
                                                      )
                                                  );

      rec_c_emis   c_emis%ROWTYPE;
   BEGIN
--
      g_proc := 'P_SEL_emission';
      g_session := i_session;
      g_flag_test := i_flag_test;
      g_niv_msg := 1;
      g_etendue := 3;

--
      IF (g_flag_test > 0)
      THEN
         g_msg_adm :=
               'Début du traitement Extraction emissions le '
            || TO_CHAR (SYSDATE, 'dd/mm/yyyy HH24:MI:SS');
         p_ins_journal;
         COMMIT;
      END IF;

--
      g_deb_risque := i_deb_risque;
      g_fin_risque := i_fin_risque;

--
      OPEN c_emis;

      LOOP
         FETCH c_emis
          INTO rec_c_emis;

         EXIT WHEN c_emis%NOTFOUND;
         --
         g_trav_codope := rec_c_emis.numrelance;

         IF (rec_c_emis.comptant = 'R')
         THEN
            g_trav_codope := 2;
         END IF;

         g_trav_idpiece := rec_c_emis.numquit;
         g_trav_date_piece := rec_c_emis.datemis;
         g_trav_date_affec := rec_c_emis.debut;
         g_trav_exercice := rec_c_emis.exercice;
         g_trav_mregl := rec_c_emis.mregl;
         g_trav_numtiers := rec_c_emis.numquerable;
         g_trav_type_contrat := rec_c_emis.typgar;
         g_trav_numgar := rec_c_emis.numgar;
         g_trav_mt_regl := NVL (rec_c_emis.montant, 0);
         g_trav_refpiece := TO_CHAR (rec_c_emis.numquit);
         g_trav_lib_piece :=
               'ECH N° '
            || TO_CHAR (rec_c_emis.numquit)
            || ' DU '
            || d2e (rec_c_emis.debut);

         --
         IF (g_flag_test > 0)
         THEN
            g_msg_adm :=
                  'Cotisation '
               || TO_CHAR (rec_c_emis.numquit)
               || ' Echeance '
               || d2e (rec_c_emis.debut);
            p_ins_journal;
         END IF;

         --
         p_sel_emis_frais (i_numquit => rec_c_emis.numquit);
         --
         p_sel_emis_gar (i_numquit => rec_c_emis.numquit);
      --
      END LOOP;

      CLOSE c_emis;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         g_msg_adm := g_proc || ' ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_niv_msg := 2;
         --
         -- Insertion dans journal_adm du message d'erreur
         --
         p_ins_journal;
         --
         COMMIT;
         --
         RAISE;
   END p_sel_emission;

--
-- Extraction des encaissements
--
   PROCEDURE p_sel_encaismt (
      i_deb_codope         IN   encaismt.codope%TYPE,
      i_fin_codope         IN   encaismt.codope%TYPE,
      i_deb_modpmt         IN   encaismt.modpmt%TYPE,
      i_fin_modpmt         IN   encaismt.modpmt%TYPE,
      i_deb_type_contrat   IN   NUMBER,
      i_fin_type_contrat   IN   NUMBER,
      i_deb_risque         IN   NUMBER,
      i_fin_risque         IN   NUMBER,
      i_debut              IN   DATE,
      i_fin                IN   DATE,
      i_deb_eche           IN   DATE,
      i_fin_eche           IN   DATE,
      i_deb_numcli         IN   encaismt.numcli%TYPE,
      i_fin_numcli         IN   encaismt.numcli%TYPE,
      i_numencaismt        IN   encaismt.numencaismt%TYPE,
      i_session            IN   NUMBER,
      i_flag_test          IN   NUMBER
   )
   IS
      CURSOR c_encais
      IS
         SELECT encaismt.codope, encaismt.numencaismt, encaismt.datpay,
                encaismt.modpmt, encaismt.refpmt, encaismt.numcli,
                encaismt.montant
           FROM encaismt
          WHERE codope BETWEEN NVL (i_deb_codope, codope)
                           AND NVL (i_fin_codope, NVL (i_deb_codope, codope))
            AND modpmt BETWEEN NVL (i_deb_modpmt, modpmt)
                           AND NVL (i_fin_modpmt, NVL (i_deb_modpmt, modpmt))
            AND numcli BETWEEN NVL (i_deb_numcli, numcli)
                           AND NVL (i_fin_numcli, NVL (i_deb_numcli, numcli))
            AND numencaismt = NVL (i_numencaismt, numencaismt);

--   CTT 24/04/07 :      and     numencaismt = decode( I_numencaismt, 0, numencaismt, I_numencaismt )        and     numencaismt = decode( I_numencaismt, 0, numencaismt, I_numencaismt )
      rec_c_encais   c_encais%ROWTYPE;
   BEGIN
--
      g_proc := 'P_SEL_encaismt';
      g_session := i_session;
      g_flag_test := i_flag_test;
      g_niv_msg := 1;
      g_etendue := 1;
--
      g_msg_adm :=
            'Début du traitement Extraction encaissements le '
         || TO_CHAR (SYSDATE, 'dd/mm/yyyy HH24:MI:SS');
      p_ins_journal;
      COMMIT;

--
      g_deb_type_contrat := i_deb_type_contrat;
      g_fin_type_contrat := i_fin_type_contrat;
      g_deb_risque := i_deb_risque;
      g_fin_risque := i_fin_risque;
      g_deb_eche := i_deb_eche;
      g_fin_eche := i_fin_eche;
      g_debut := i_debut;
      g_fin := i_fin;

--
      OPEN c_encais;

      LOOP
         FETCH c_encais
          INTO rec_c_encais;

         EXIT WHEN c_encais%NOTFOUND;
         --
         g_trav_codope := rec_c_encais.codope;
         g_trav_idpiece := rec_c_encais.numencaismt;
         g_trav_date_piece := rec_c_encais.datpay;
         g_trav_mregl := rec_c_encais.modpmt;
         g_trav_numtiers := rec_c_encais.numcli;
         g_trav_refpiece := rec_c_encais.refpmt;
         g_trav_mt_regl := rec_c_encais.montant;
         --
         p_sel_refremise (i_cle            => rec_c_encais.numencaismt,
                          i_modpmt         => rec_c_encais.modpmt,
                          i_numcpte        => NULL,
                          i_numchq         => NULL,
                          i_sens           => 1,
                          o_refremise      => g_trav_refremise,
                          o_libcompte      => g_trav_libcompte
                         );

         --
         IF (g_flag_test > 0)
         THEN
            g_msg_adm :=
                  'Encaissement '
               || TO_CHAR (rec_c_encais.numencaismt)
               || ' Date '
               || d2e (rec_c_encais.datpay);
            p_ins_journal;
         END IF;

         --
         p_sel_compte_client (i_numencaismt => rec_c_encais.numencaismt);

         IF (g_trav_codope = 10)
         THEN
            p_sel_solde_tiers (i_numencaismt => rec_c_encais.numencaismt);
            p_sel_indu (i_numencaismt => rec_c_encais.numencaismt);
         END IF;
      END LOOP;

      CLOSE c_encais;

--
-- If ( I_numencaismt != 0 ) then
      g_trav_refremise := NULL;
      p_sel_compensation (i_deb_codope      => i_deb_codope,
                          i_fin_codope      => i_fin_codope,
                          i_deb_numcli      => i_deb_numcli,
                          i_fin_numcli      => i_fin_numcli
                         );
-- End if;
--
      -- JBO : 26/11/2009 : Ajout du message de fin de l extraction des encaissements
      g_msg_adm :=
            'Fin du traitement Extraction encaissements le '
         || TO_CHAR (SYSDATE, 'dd/mm/yyyy HH24:MI:SS');
      p_ins_journal;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         g_msg_adm := g_proc || ' ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_niv_msg := 2;
         --
         -- Insertion dans journal_adm du message d'erreur
         --
         --P_INS_journal;
         --
         -- COMMIT;
         --
         RAISE;
   END p_sel_encaismt;

--
-- Extraction des decaissements
--
   PROCEDURE p_sel_decaismt (
      i_deb_codope         IN   decaismt.codope%TYPE,
      i_fin_codope         IN   decaismt.codope%TYPE,
      i_deb_modpmt         IN   decaismt.modpmt%TYPE,
      i_fin_modpmt         IN   decaismt.modpmt%TYPE,
      i_deb_type_contrat   IN   NUMBER,
      i_fin_type_contrat   IN   NUMBER,
      i_deb_risque         IN   NUMBER,
      i_fin_risque         IN   NUMBER,
      i_debut              IN   DATE,
      i_fin                IN   DATE,
      i_deb_numcli         IN   decaismt.numdest%TYPE,
      i_fin_numcli         IN   decaismt.numdest%TYPE,
      i_session            IN   NUMBER,
      i_flag_test          IN   NUMBER,
      i_flag_retro         IN   NUMBER
   )
   IS
      CURSOR c_decais
      IS
         SELECT decaismt.codope, decaismt.numdecaismt, decaismt.datpay,
                decaismt.modpmt, decaismt.refpmt, decaismt.numcpte,
                decaismt.numchq, decaismt.numdest, decaismt.montant, 1 signe
           FROM decaismt
          WHERE codope BETWEEN NVL (i_deb_codope, codope)
                           AND NVL (i_fin_codope, NVL (i_deb_codope, codope))
            AND modpmt BETWEEN NVL (i_deb_modpmt, modpmt)
                           AND NVL (i_fin_modpmt, NVL (i_deb_modpmt, modpmt))
            AND numdest BETWEEN NVL (i_deb_numcli, numdest)
                            AND NVL (i_fin_numcli,
                                     NVL (i_deb_numcli, numdest))
            AND flagpay = 1
            AND datpay BETWEEN i_debut AND i_fin
         UNION
         SELECT decaismt.codope, decaismt.numdecaismt, pnul.datannul,
                decaismt.modpmt, decaismt.refpmt, decaismt.numcpte,
                decaismt.numchq, decaismt.numdest, decaismt.montant, -1 signe
           FROM decaismt, pnul
          WHERE pnul.numdecaismt = decaismt.numdecaismt
            AND decaismt.codope BETWEEN NVL (i_deb_codope, decaismt.codope)
                                    AND NVL (i_fin_codope,
                                             NVL (i_deb_codope,
                                                  decaismt.codope
                                                 )
                                            )
            AND decaismt.modpmt BETWEEN NVL (i_deb_modpmt, decaismt.modpmt)
                                    AND NVL (i_fin_modpmt,
                                             NVL (i_deb_modpmt,
                                                  decaismt.modpmt
                                                 )
                                            )
            AND decaismt.numdest BETWEEN NVL (i_deb_numcli, decaismt.numdest)
                                     AND NVL (i_fin_numcli,
                                              NVL (i_deb_numcli,
                                                   decaismt.numdest
                                                  )
                                             )
            AND pnul.datannul BETWEEN i_debut AND i_fin;
-- PHA 20120307 plus d'actualité en V7 :            AND decaismt.codope + 0 = 9;

      rec_c_decais   c_decais%ROWTYPE;
   BEGIN
--
      g_proc := 'P_SEL_decaismt';
      g_session := i_session;
      g_flag_test := i_flag_test;
      g_niv_msg := 1;
      g_etendue := -1;
      g_flag_retro := FALSE;
      g_trav_type_retro := NULL;
--
      g_msg_adm :=
            'Début du traitement Extraction decaissements le '
         || TO_CHAR (SYSDATE, 'dd/mm/yyyy HH24:MI:SS');
      p_ins_journal;
--
      g_deb_type_contrat := i_deb_type_contrat;
      g_fin_type_contrat := i_fin_type_contrat;
      g_deb_risque := i_deb_risque;
      g_fin_risque := i_fin_risque;

      IF (i_flag_retro = 1)
      THEN
         g_flag_retro := TRUE;
      END IF;

--
      OPEN c_decais;

      LOOP
         FETCH c_decais
          INTO rec_c_decais;

         EXIT WHEN c_decais%NOTFOUND;
         --
         g_trav_codope := rec_c_decais.codope;
         g_trav_idpiece := rec_c_decais.numdecaismt;
         g_trav_date_piece := rec_c_decais.datpay;
         g_trav_mregl := rec_c_decais.modpmt;
         g_trav_numtiers := rec_c_decais.numdest;
         g_trav_refpiece := rec_c_decais.refpmt;
         g_trav_mt_regl := rec_c_decais.montant;
         g_trav_signe := rec_c_decais.signe;
         --
         p_sel_refremise (i_cle            => rec_c_decais.numdecaismt,
                          i_modpmt         => rec_c_decais.modpmt,
                          i_numcpte        => rec_c_decais.numcpte,
                          i_numchq         => rec_c_decais.numchq,
                          i_sens           => -1,
                          o_refremise      => g_trav_refremise,
                          o_libcompte      => g_trav_libcompte
                         );

         --
         IF (g_flag_test > 0)
         THEN
            g_msg_adm :=
                  'Decaissement '
               || TO_CHAR (rec_c_decais.numdecaismt)
               || ' Date '
               || d2e (rec_c_decais.datpay);
            p_ins_journal;
         END IF;

         --
         p_sel_affectation (i_numdecaismt => rec_c_decais.numdecaismt);

         IF (g_trav_signe = -1) -- (g_trav_codope = 9)
         THEN
            p_sel_affectation_annul
                                   (i_numdecaismt      => rec_c_decais.numdecaismt);
         END IF;

      --
      END LOOP;

      CLOSE c_decais;

--
      IF (g_flag_test > 0)
      THEN
         g_msg_adm := 'Appel a P_SEL_comp_debit';
         p_ins_journal;
         COMMIT;
      END IF;

      p_sel_comp_debit (i_deb_codope      => i_deb_codope,
                        i_fin_codope      => i_fin_codope,
                        i_deb_numcli      => i_deb_numcli,
                        i_fin_numcli      => i_fin_numcli,
                        i_debut           => i_debut,
                        i_fin             => i_fin
                       );
--
--
      g_niv_msg := 1;
      g_msg_adm :=
            'FIN Normale du traitement "Extraction decaissements" le '
         || TO_CHAR (SYSDATE, 'dd/mm/yyyy HH24:MI:SS');
      p_ins_journal;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         g_msg_adm := g_proc || ' ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_niv_msg := 2;
         --
         -- Insertion dans journal_adm du message d'erreur
         --
         p_ins_journal;
         --
         COMMIT;
         --
         RAISE;
   END p_sel_decaismt;

--
-- Exploitation de trav_treso
--
   PROCEDURE p_sel_trav_treso (i_etendue IN NUMBER, o_ligne OUT VARCHAR)
   IS
      rec_c_trav_treso   c_sel_trav_treso%ROWTYPE;
      l_lib_ope          libelle.libelle%TYPE;
      l_branche          libelle.libelle%TYPE;
      l_risque           libelle.libelle%TYPE;
      l_client           NUMBER;
   BEGIN
      g_proc := 'P_SEL_trav_treso';

      SELECT Client
             INTO l_client
             FROM PARAMETRES;

      IF NOT c_sel_trav_treso%ISOPEN
      THEN
         OPEN c_sel_trav_treso;
      END IF;

--
      FETCH c_sel_trav_treso
       INTO rec_c_trav_treso;

--
      IF (c_sel_trav_treso%NOTFOUND)
      THEN
         CLOSE c_sel_trav_treso;

         RAISE NO_DATA_FOUND;
      END IF;

--
      IF (i_etendue = 7)
      THEN
         IF (rec_c_trav_treso.codope = 0)
         THEN
            l_lib_ope := 'Emission de cotisation';
         ELSIF (rec_c_trav_treso.codope = 2)
         THEN
            l_lib_ope := 'Régularisation de cotisation';
         ELSIF (rec_c_trav_treso.codope = 4)
         THEN
            l_lib_ope := 'Résiliation de cotisation';
         ELSIF (rec_c_trav_treso.codope = 99)
         THEN
            l_lib_ope := 'Annulation de cotisation';
         END IF;
      ELSE
         l_lib_ope := pk_libelle.f_lib ('OPE', rec_c_trav_treso.codope)
                      || ';';
      END IF;

      o_ligne := l_lib_ope || ';';
      l_branche := pk_libelle.f_lib_groupe ('CMCR', rec_c_trav_treso.branche);
      o_ligne := pk_libelle.f_lib ('OPE', rec_c_trav_treso.codope) || ';';
      o_ligne := o_ligne || l_branche || ';';
      o_ligne :=
            o_ligne
         || pk_libelle.f_lib ('TYPG', rec_c_trav_treso.type_contrat)
         || ';';
      l_risque :=
         pk_libelle.f_nat_risque
                                (i_risque           => rec_c_trav_treso.risque,
                                 i_type_risque      => rec_c_trav_treso.type_risque
                                );
      o_ligne := o_ligne || l_risque || ';';
      o_ligne := o_ligne || TO_CHAR (rec_c_trav_treso.exercice) || ';';
      o_ligne := o_ligne || TO_CHAR (rec_c_trav_treso.idpiece) || ';';
      o_ligne := o_ligne || d2e (rec_c_trav_treso.date_piece) || ';';
      o_ligne := o_ligne || d2e (rec_c_trav_treso.date_affec) || ';';

      IF (i_etendue IN (2, 7))
      THEN
         IF (rec_c_trav_treso.mregl < 0)
         THEN
            IF (rec_c_trav_treso.mregl IN (-2, -14))
            THEN
               o_ligne := o_ligne || 'Compensation prestations' || ';';
            ELSIF (rec_c_trav_treso.mregl = -15)
            THEN
               o_ligne := o_ligne || 'Compensation fond de roulement' || ';';
            ELSIF (rec_c_trav_treso.mregl = -16)
            THEN
               o_ligne := o_ligne || 'Compensation commissions' || ';';
            END IF;
         ELSE
            o_ligne :=
                  o_ligne
               || pk_libelle.f_lib ('MREGL', rec_c_trav_treso.mregl)
               || ';';
         END IF;
      ELSE
         IF (rec_c_trav_treso.mregl < 0)
         THEN
            IF (rec_c_trav_treso.mregl = -4)
            THEN
               o_ligne := o_ligne || 'Compensation cotisations' || ';';
            END IF;
         ELSE
            o_ligne :=
                  o_ligne
               || pk_libelle.f_lib ('MOPM', rec_c_trav_treso.mregl)
               || ';';
         END IF;
      END IF;

      o_ligne := o_ligne || TO_CHAR (rec_c_trav_treso.numtiers) || ';';
      IF l_client != 5 THEN
        o_ligne :=
              o_ligne || TO_CHAR (rec_c_trav_treso.mt_regl, '99999999D90')
              || ';';
        o_ligne :=
             o_ligne || TO_CHAR (rec_c_trav_treso.mt_affec, '99999999D90')
             || ';';
      ELSE
        -- Cas particulier EPAI ...
        o_ligne :=
              o_ligne || REPLACE(TO_CHAR (rec_c_trav_treso.mt_regl, '99999999D90'),'.',',')
              || ';';
        o_ligne :=
             o_ligne || REPLACE(TO_CHAR (rec_c_trav_treso.mt_affec, '99999999D90'),'.',',')
             || ';';
      END IF;
      o_ligne := o_ligne || rec_c_trav_treso.refpiece || ';';
      o_ligne := o_ligne || rec_c_trav_treso.lib_piece || ';';
      o_ligne := o_ligne || rec_c_trav_treso.refremise;
-- If ( Rec_C_trav_treso.type_retro IS NOT Null ) then
      o_ligne :=
            o_ligne
         || ';'
         || pk_libelle.f_lib ('TYPRETRO', rec_c_trav_treso.type_retro);
-- End if;
      o_ligne := o_ligne || ';' || TO_CHAR (rec_c_trav_treso.numgar);
      o_ligne := o_ligne || ';' || rec_c_trav_treso.libcompte;
--
   END p_sel_trav_treso;

--
-- Extraction du compte d'attente
--
   PROCEDURE p_sel_compte_attente (
      i_deb_origine   IN       encaismt.codope%TYPE,
      i_fin_origine   IN       encaismt.codope%TYPE,
      i_deb_modpmt    IN       encaismt.modpmt%TYPE,
      i_fin_modpmt    IN       encaismt.modpmt%TYPE,
      i_deb_numcli    IN       encaismt.numcli%TYPE,
      i_fin_numcli    IN       encaismt.numcli%TYPE,
      i_datope        IN       encaismt.datpay%TYPE,
      i_numencaismt   IN       encaismt.numencaismt%TYPE,
      i_session       IN       NUMBER,
      i_flag_test     IN       NUMBER,
      o_ligne         OUT      VARCHAR
   )
   IS
      CURSOR c_annul (
         p_numencaismt   IN   annul_cptcli.numencaismt%TYPE,
         p_idaffec       IN   annul_cptcli.idaffec%TYPE
      )
      IS
         SELECT 1
           FROM annul_cptcli
          WHERE numencaismt = p_numencaismt AND idaffec = p_idaffec;

      rec_c_annul   c_annul%ROWTYPE;
      l_libelle     VARCHAR2 (60);
      l_mt_regl     NUMBER;
   BEGIN
      g_proc := 'P_SEL_compte_attente';
      g_numencaismt := NULL;
      g_deb_codope := i_deb_origine;
      g_fin_codope := i_fin_origine;
      g_deb_modpmt := i_deb_modpmt;
      g_fin_modpmt := i_fin_modpmt;
      g_deb_numcli := i_deb_numcli;
      g_fin_numcli := i_fin_numcli;
      g_debut := i_datope;

      IF (i_numencaismt = 0)
      THEN
         g_numencaismt := NULL;
      ELSE
         g_numencaismt := i_numencaismt;
      END IF;

      g_session := i_session;
      g_flag_test := i_flag_test;
--
      g_niv_msg := 1;

      --
      IF (g_flag_test > 0)
      THEN
         g_msg_adm :=
               'I_numencaismt '
            || TO_CHAR (i_numencaismt)
            || ' G_numencaismt '
            || TO_CHAR (g_numencaismt);
         p_ins_journal;
         COMMIT;
      END IF;

        --
--
      IF NOT c_sel_compte_attente%ISOPEN
      THEN
         OPEN c_sel_compte_attente;

         --
         IF (g_flag_test > 0)
         THEN
            g_msg_adm :=
                  'Début du traitement le '
               || TO_CHAR (SYSDATE, 'dd/mm/yyyy HH24:MI:SS');
            p_ins_journal;
         END IF;
      --
      END IF;

--
      FETCH c_sel_compte_attente
       INTO rec_c_attente;

--
      IF (c_sel_compte_attente%NOTFOUND)
      THEN
         CLOSE c_sel_compte_attente;

         RAISE NO_DATA_FOUND;
      END IF;

--
      IF (rec_c_attente.origine = 10)
      THEN
         l_libelle :=
                  'Encaissement fournisseur n° ' || rec_c_attente.numencaismt;
      ELSE
         IF (rec_c_attente.idaffec = 0)
         THEN
            l_libelle := 'Affecté hors période';
         ELSE
            l_libelle := f_lib_attente (rec_c_attente.idaffec);
         END IF;
      END IF;

--
      p_sel_refremise (i_cle            => rec_c_attente.numencaismt,
                       i_modpmt         => rec_c_attente.modpmt,
                       i_numcpte        => NULL,
                       i_numchq         => NULL,
                       i_sens           => 1,
                       o_refremise      => g_trav_refremise,
                       o_libcompte      => g_trav_libcompte
                      );

--
      OPEN c_annul (rec_c_attente.numencaismt, rec_c_attente.idaffec);

      FETCH c_annul
       INTO rec_c_annul;

      IF (c_annul%FOUND)
      THEN
         l_mt_regl := -rec_c_attente.montant;
      ELSE
         l_mt_regl := rec_c_attente.montant;
      END IF;

      o_ligne :=
            pk_libelle.f_lib ('OPE', rec_c_attente.origine)
         || ';'
         || TO_CHAR (rec_c_attente.numencaismt)
         || ';'
         || d2e (rec_c_attente.datpay)
         || ';'
         || pk_libelle.f_lib ('MREGL', rec_c_attente.modpmt)
         || ';'
         || rec_c_attente.refpmt
         || ';'
         || TO_CHAR (rec_c_attente.numcli)
         || ';'
         || pk_personne.f_nom (rec_c_attente.numcli)
         || ';'
         || l_libelle
         || ';'
         || TO_CHAR (l_mt_regl)
         || ';'
         || TO_CHAR (rec_c_attente.mt_attente)
         || ';'
         || g_trav_refremise
         || ';'
         || g_trav_libcompte;
--
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RAISE NO_DATA_FOUND;
      WHEN OTHERS
      THEN
         ROLLBACK;
         g_msg_adm := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_niv_msg := 2;
         --
         -- Insertion dans journal_adm du message d'erreur
         --
         p_ins_journal;
         --
         COMMIT;
         --
         RAISE;
   END p_sel_compte_attente;

--
-- Retourne le montant affecte pour un encaissement a une date
--
   FUNCTION f_totaffec (
      i_numencaismt   IN   encaismt.numencaismt%TYPE,
      i_datref        IN   DATE
   )
      RETURN NUMBER
   IS
      l_montant   NUMBER := 0;
      l_mt_remb   NUMBER := 0;
   BEGIN
      SELECT NVL (SUM (montant), 0)
        INTO l_montant
        FROM compte_client
       WHERE numencaismt = i_numencaismt
         AND codope + 0 != 8
         AND datope <= i_datref;

--
      SELECT NVL (SUM (montant), 0)
        INTO l_mt_remb
        FROM compte_client
       WHERE numencaismt = i_numencaismt
         AND codope + 0 = 8
         AND datope <= i_datref
         AND EXISTS (
                SELECT 1
                  FROM rbtcptcli, affectation
                 WHERE rbtcptcli.idaffec = compte_client.idaffec
                   AND affectation.numaffec = rbtcptcli.numaffec
                   AND affectation.codope = 8
                   AND affectation.dataffec <= i_datref);

--
      RETURN (l_montant + l_mt_remb);
--
   END f_totaffec;

--
-- Retourne le type de risque pour une garantie
--
   FUNCTION f_nat_risque (i_numfor IN gar_cntrt.numfor%TYPE)
      RETURN NUMBER
   IS
      CURSOR c_nat_risque
      IS
         SELECT NVL (nat_risq, -1) nat_risq
           FROM garanties
          WHERE numfor = i_numfor;

      l_nat_risque   NUMBER := -1;
   BEGIN
-- G_proc := 'F_nat_risque';
      OPEN c_nat_risque;

      FETCH c_nat_risque
       INTO l_nat_risque;

      IF (c_nat_risque%NOTFOUND)
      THEN
         l_nat_risque := 0;
      END IF;

      CLOSE c_nat_risque;

      RETURN (l_nat_risque);
   END f_nat_risque;

--
-- Retourne le type de contrat pour une garantie
--
   FUNCTION f_type_contrat (i_numfor IN gar_cntrt.numfor%TYPE)
      RETURN NUMBER
   IS
      CURSOR c_type_contrat
      IS
         SELECT NVL (contrat.typgar, 0) typgar
           FROM contrat, gar_cntrt
          WHERE gar_cntrt.numfor = i_numfor
            AND contrat.numgar = gar_cntrt.numgar;

      l_type_contrat   NUMBER := 0;
   BEGIN
-- G_proc := 'F_type_contrat';
      OPEN c_type_contrat;

      FETCH c_type_contrat
       INTO l_type_contrat;

      IF (c_type_contrat%NOTFOUND)
      THEN
         l_type_contrat := 0;
      END IF;

      CLOSE c_type_contrat;

      RETURN (l_type_contrat);
   END f_type_contrat;

--
-- Retourne la branche pour une garantie
--
   FUNCTION f_branche (i_numfor IN gar_cntrt.numfor%TYPE)
      RETURN NUMBER
   IS
      CURSOR c_typgar
      IS
         SELECT TYPE
           FROM gar_cntrt
          WHERE numfor = i_numfor;

      CURSOR c_sante
      IS
         SELECT code_cmcr
           FROM formule
          WHERE numfor = i_numfor;

      CURSOR c_prev
      IS
         SELECT code_cmcr
           FROM garanties
          WHERE numfor = i_numfor;

      CURSOR c_branche (p_code grp_libelle.code%TYPE)
      IS
         SELECT code_groupe
           FROM grp_libelle
          WHERE mnemo = 'CMCR' AND code = p_code;

      l_typgar      NUMBER;
      l_code_cmcr   garanties.code_cmcr%TYPE;
      l_branche     NUMBER;
   BEGIN
-- G_proc := 'F_branche';
      OPEN c_typgar;

      FETCH c_typgar
       INTO l_typgar;

      CLOSE c_typgar;

      IF (l_typgar = 1)
      THEN
         OPEN c_sante;

         FETCH c_sante
          INTO l_code_cmcr;

         CLOSE c_sante;
      ELSIF (l_typgar = 2)
      THEN
         OPEN c_prev;

         FETCH c_prev
          INTO l_code_cmcr;

         CLOSE c_prev;
      END IF;

      IF (l_code_cmcr IS NOT NULL)
      THEN
         OPEN c_branche (l_code_cmcr);

         FETCH c_branche
          INTO l_branche;

         CLOSE c_branche;
      END IF;

      IF (l_branche IS NULL)
      THEN
         l_branche := -1;
      END IF;

      RETURN (l_branche);
   END f_branche;

--
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--@corpriv
--
-- Retourne vrai si la comm a ete prelevee en une fois
--
   FUNCTION f_ctrl_one_shot (
      i_numquit   IN   one_shot.numquit%TYPE,
      i_idaffec   IN   one_shot.idaffec%TYPE
   )
      RETURN BOOLEAN
   IS
      CURSOR c_one_shot
      IS
         SELECT 1
           FROM one_shot
          WHERE numquit = i_numquit AND idaffec = i_idaffec;

      dummy      NUMBER;
      l_retour   BOOLEAN := FALSE;
   BEGIN
      OPEN c_one_shot;

      FETCH c_one_shot
       INTO dummy;

      IF (c_one_shot%FOUND)
      THEN
         l_retour := TRUE;
      ELSE
         l_retour := FALSE;
      END IF;

      CLOSE c_one_shot;

--
      RETURN l_retour;
--
   END f_ctrl_one_shot;

--
-- Retourne vrai si la comm a deja ete prelevee
--
   FUNCTION f_ctrl_prelev (
      i_numquit   IN   one_shot.numquit%TYPE,
      i_idaffec   IN   one_shot.idaffec%TYPE
   )
      RETURN BOOLEAN
   IS
      CURSOR c_one_shot
      IS
         SELECT 1
           FROM one_shot
          WHERE numquit = i_numquit AND idaffec != i_idaffec;

      dummy      NUMBER;
      l_retour   BOOLEAN := FALSE;
   BEGIN
      OPEN c_one_shot;

      FETCH c_one_shot
       INTO dummy;

      IF (c_one_shot%FOUND)
      THEN
         l_retour := TRUE;
      ELSE
         l_retour := FALSE;
      END IF;

      CLOSE c_one_shot;

--
      RETURN l_retour;
--
   END f_ctrl_prelev;

--
-- Retourne la reference remise
--
   PROCEDURE p_sel_refremise (
      i_cle         IN       NUMBER,
      i_modpmt      IN       NUMBER,
      i_numcpte     IN       NUMBER,
      i_numchq      IN       NUMBER,
      i_sens        IN       NUMBER,
      o_refremise   OUT      trav_treso.refremise%TYPE,
      o_libcompte   OUT      trav_treso.libcompte%TYPE
   )
   IS
      CURSOR c_prelev
      IS
         SELECT TO_CHAR (prelevement.numremise) numremise,
                TO_CHAR (remise_prelev.numcpte) numcpte, compte.libcompte
           FROM compte, prelevement, remise_prelev
          WHERE numencaismt = i_cle
            AND remise_prelev.numremise = prelevement.numremise
            AND compte.numcpte = remise_prelev.numcpte;

--
      CURSOR c_cheque
      IS
         SELECT TO_CHAR (remise_globale.numremise) numremise,
                TO_CHAR (remise_globale.numcpte) numcpte, compte.libcompte
           FROM compte, remise_globale, remise_banque
          WHERE remise_banque.numencaismt = i_cle
            AND remise_globale.numremise = remise_banque.numremise
            AND compte.numcpte = remise_globale.numcpte;

--
      CURSOR c_vire
      IS
         SELECT TO_CHAR (remise_vire.numremise) numremise,
                TO_CHAR (remise_vire.numcpte) numcpte, compte.libcompte
           FROM compte, remise_vire_detail, remise_vire
          WHERE numdecaismt = i_cle
            AND remise_vire.numremise = remise_vire_detail.numremise
            AND compte.numcpte = remise_vire.numcpte;

--
      rec_c_prelev   c_prelev%ROWTYPE;
      rec_c_cheque   c_cheque%ROWTYPE;
      rec_c_vire     c_vire%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_refremise';

--g_niv_msg := 3;
      IF (g_flag_test > 0)
      THEN
         g_msg_adm := 'P_SEL_refremise' || i_cle;
         p_ins_journal;
      END IF;

      IF (i_modpmt = 2)
      THEN
         IF (i_sens = 1)
         THEN
            OPEN c_prelev;

            FETCH c_prelev
             INTO rec_c_prelev;

            o_refremise := rec_c_prelev.numremise;
            o_libcompte :=
                      rec_c_prelev.numcpte || ' - ' || rec_c_prelev.libcompte;

            CLOSE c_prelev;
         ELSE
            OPEN c_vire;

            FETCH c_vire
             INTO rec_c_vire;

            o_refremise := rec_c_vire.numremise;
            o_libcompte :=
                          rec_c_vire.numcpte || ' - ' || rec_c_vire.libcompte;

            CLOSE c_vire;
         END IF;
      ELSIF (i_modpmt = 1 AND i_sens = -1)
      THEN
         o_refremise := TO_CHAR (i_numcpte) || ' - ' || TO_CHAR (i_numchq);
         o_libcompte :=
              TO_CHAR (i_numcpte) || ' - '
              || pk_devise.lib_compte (i_numcpte);
      ELSIF (i_modpmt != 2 AND i_sens = 1)
      THEN
         OPEN c_cheque;

         FETCH c_cheque
          INTO rec_c_cheque;

         o_refremise := rec_c_cheque.numremise;
         o_libcompte :=
                      rec_c_cheque.numcpte || ' - ' || rec_c_cheque.libcompte;

         CLOSE c_cheque;
      ELSE
         o_refremise := TO_CHAR (i_numcpte);
         o_libcompte :=
              TO_CHAR (i_numcpte) || ' - '
              || pk_devise.lib_compte (i_numcpte);
      END IF;
   END p_sel_refremise;

--
-- Remboursement tiers ou solde comptable
--
   PROCEDURE p_sel_solde_tiers (i_numencaismt IN encaismt.numencaismt%TYPE)
   IS
      CURSOR c_encais
      IS
         SELECT idmvt
           FROM compte_tiers
          WHERE codope = 10 AND cle = i_numencaismt AND sens = 1;

--
      CURSOR c_solde_tiers (p_idmvt IN compensation.idmvt%TYPE)
      IS
         SELECT decaismt.numbene, compte.TYPE, compte.cmpt_gene,
                compte_tiers.montant mt_affec,
                compte_tiers.datope date_affec,
                TO_CHAR (compte_tiers.datope, 'yyyy') exercice
           FROM compte, decaismt, affectation, compte_tiers, compensation
          WHERE compte.numcpte = decaismt.numcpte
            AND decaismt.numdecaismt = affectation.numdecaismt
            AND compte_tiers.datope BETWEEN g_debut AND g_fin
            AND affectation.codope = 10
            AND affectation.numaffec = compte_tiers.cle
            AND compte_tiers.codope = 10
            AND compte_tiers.idmvt = compensation.idcomp
            AND compensation.idmvt = p_idmvt;

--
      rec_c_encais        c_encais%ROWTYPE;
      rec_c_solde_tiers   c_solde_tiers%ROWTYPE;
--
   BEGIN
      g_proc := 'P_SEL_solde_tiers';

      OPEN c_encais;

      FETCH c_encais
       INTO rec_c_encais;

      CLOSE c_encais;

--
      OPEN c_solde_tiers (rec_c_encais.idmvt);

      LOOP
         FETCH c_solde_tiers
          INTO rec_c_solde_tiers;

         EXIT WHEN c_solde_tiers%NOTFOUND;
         --
         g_trav_branche := 99;
         g_trav_type_contrat := 0;
         g_trav_risque := -100;
         g_trav_exercice := rec_c_solde_tiers.exercice;
         g_trav_date_affec := rec_c_solde_tiers.date_affec;
         g_trav_mt_affec := rec_c_solde_tiers.mt_affec;
         g_trav_numgar := NULL;

         IF (rec_c_solde_tiers.TYPE = 1)
         THEN
            g_trav_lib_piece :=
                 'Remboursé au tiers ' || TO_CHAR (rec_c_solde_tiers.numbene);
         ELSE
            g_trav_lib_piece :=
                           'Soldé sur compte ' || rec_c_solde_tiers.cmpt_gene;
         END IF;

         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_solde_tiers;
   END p_sel_solde_tiers;

--
-- Remboursement encaissement fournisseur
--
   PROCEDURE p_sel_rbtcpttiers (
      i_idmvt   IN   compte_tiers.idmvt%TYPE,
      i_cle     IN   compte_tiers.cle%TYPE
   )
   IS
      CURSOR c_rbt
      IS
         SELECT montant
           FROM compte_tiers
          WHERE idmvt = i_idmvt;
   BEGIN
      g_proc := 'P_SEL_rbtcpttiers';
--
-- Open C_rbt;
-- Fetch C_rbt Into G_trav_mt_affec;
-- Close C_rbt;
--
      g_trav_branche := 99;
      g_trav_type_contrat := 0;
      g_trav_risque := -100;
      g_trav_exercice := TO_CHAR (g_trav_date_piece, 'yyyy');
      g_trav_date_affec := g_trav_date_piece;
      g_trav_lib_piece := 'Remb Encais ' || TO_CHAR (i_cle);
      g_trav_numgar := NULL;
--
      p_ins_trav_treso;
--
   END p_sel_rbtcpttiers;

--
-- Remboursement client ou solde comptable ( decaissements )
--
   PROCEDURE p_sel_rbtcptcli (i_numaffec IN affectation.numaffec%TYPE)
   IS
      CURSOR c_rbt
      IS
         SELECT decaismt.numbene, compte.TYPE, compte.cmpt_gene,
                compte_client.montant mt_affec, decaismt.datpay date_affec,
                TO_CHAR (decaismt.datpay, 'yyyy') exercice
           FROM compte, decaismt, affectation, rbtcptcli, compte_client
          WHERE compte.numcpte = decaismt.numcpte
            AND decaismt.numdecaismt = affectation.numdecaismt
            AND affectation.codope = 8
            AND affectation.numaffec = i_numaffec
            AND compte_client.idaffec = rbtcptcli.idaffec
            AND compte_client.codope + 0 = 8
            AND rbtcptcli.numaffec = i_numaffec;

      rec_c_rbt   c_rbt%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_rbtcptcli';

      OPEN c_rbt;

      LOOP
         FETCH c_rbt
          INTO rec_c_rbt;

         EXIT WHEN c_rbt%NOTFOUND;
         --
         g_trav_branche := 99;
         g_trav_type_contrat := 0;
         g_trav_risque := -100;
         g_trav_exercice := rec_c_rbt.exercice;
         g_trav_date_affec := rec_c_rbt.date_affec;
         g_trav_mt_affec := rec_c_rbt.mt_affec;
         g_trav_numgar := NULL;

         IF (rec_c_rbt.TYPE = 1)
         THEN
            g_trav_lib_piece :=
                        'Remboursé au client ' || TO_CHAR (rec_c_rbt.numbene);
         ELSE
            g_trav_lib_piece := 'Soldé sur compte ' || rec_c_rbt.cmpt_gene;
         END IF;

         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_rbt;
   END p_sel_rbtcptcli;

--
-- Remboursement client ou solde comptable
--
   PROCEDURE p_sel_solde_client (i_idaffec IN rbtcptcli.idaffec%TYPE)
   IS
      CURSOR c_solde
      IS
         SELECT decaismt.numbene, compte.TYPE, compte.cmpt_gene,
                compte_client.montant mt_affec,
                compte_client.datope date_affec,
                TO_CHAR (compte_client.datope, 'yyyy') exercice
           FROM compte, decaismt, affectation, rbtcptcli, compte_client
          WHERE compte.numcpte = decaismt.numcpte
            AND decaismt.numdecaismt = affectation.numdecaismt
            AND affectation.dataffec BETWEEN g_debut AND g_fin
            AND affectation.codope = 8
            AND affectation.numaffec = rbtcptcli.numaffec
            AND compte_client.codope + 0 = 8
            AND compte_client.idaffec = i_idaffec
            AND rbtcptcli.idaffec = i_idaffec;

      rec_c_solde   c_solde%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_solde_client';

      OPEN c_solde;

      LOOP
         FETCH c_solde
          INTO rec_c_solde;

         EXIT WHEN c_solde%NOTFOUND;
         --
         g_trav_branche := 99;
         g_trav_type_contrat := 0;
         g_trav_risque := -100;
         g_trav_exercice := rec_c_solde.exercice;
         g_trav_date_affec := rec_c_solde.date_affec;
         g_trav_mt_affec := rec_c_solde.mt_affec;
         g_trav_numgar := NULL;

         IF (rec_c_solde.TYPE = 1)
         THEN
            g_trav_lib_piece :=
                      'Remboursé au client ' || TO_CHAR (rec_c_solde.numbene);
         ELSE
            g_trav_lib_piece := 'Soldé sur compte ' || rec_c_solde.cmpt_gene;
         END IF;

         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_solde;
   END p_sel_solde_client;

--
-- Selection du compte_tiers
--
   PROCEDURE p_sel_compte_tiers (i_cle IN compte_tiers.cle%TYPE)
   IS
      CURSOR c_compte_tiers
      IS
         SELECT origine.codope, origine.idmvt, compte_tiers.montant,
                origine.cle
           FROM compte_tiers origine, compensation, compte_tiers
          WHERE origine.idmvt = compensation.idmvt
            AND compensation.idcomp = compte_tiers.idmvt
            AND compte_tiers.sens = -1
            AND compte_tiers.codope = 10
            AND compte_tiers.cle = i_cle;

      rec_c_compte_tiers   c_compte_tiers%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_compte_tiers';
      IF (g_flag_test > 0) THEN
        g_niv_msg := 3;
        g_msg_adm := 'P_SEL_compte_tiers' || i_cle;
        p_ins_journal;
      END IF;

      OPEN c_compte_tiers;

      LOOP
         FETCH c_compte_tiers
          INTO rec_c_compte_tiers;

         EXIT WHEN c_compte_tiers%NOTFOUND;

         IF (g_flag_test > 0)
         THEN
            g_msg_adm :=
                  'Compte tiers codope = '
               || rec_c_compte_tiers.codope
               || ' Cle '
               || rec_c_compte_tiers.cle;
            p_ins_journal;
         END IF;

         --
         g_trav_mt_affec := rec_c_compte_tiers.montant;
         g_affectation := rec_c_compte_tiers.montant;

         --
         IF (g_trav_signe = 1)
         THEN
            g_trav_codope := rec_c_compte_tiers.codope;
         END IF;

         --
         IF (g_flag_retro)
         THEN
            IF (rec_c_compte_tiers.codope = 16)
            THEN
               p_sel_type_retro (i_idrevers => rec_c_compte_tiers.cle);
            END IF;
         ELSE
            IF (rec_c_compte_tiers.codope = 14)
            THEN
               p_sel_sante (i_numdec => rec_c_compte_tiers.cle);
            ELSIF (rec_c_compte_tiers.codope = 16)
            THEN
               p_sel_retro (i_idrevers => rec_c_compte_tiers.cle);
            ELSIF (rec_c_compte_tiers.codope = 10)
            THEN
               p_sel_rbtcpttiers (i_idmvt      => rec_c_compte_tiers.idmvt,
                                  i_cle        => rec_c_compte_tiers.cle
                                 );
            ELSIF (rec_c_compte_tiers.codope = 2)
            THEN
               g_trav_codope := 17;
               p_sel_prev (i_numdec => rec_c_compte_tiers.cle);
            END IF;
         END IF;
      END LOOP;

      CLOSE c_compte_tiers;
   END p_sel_compte_tiers;

--
-- Selection des affectations
--
   PROCEDURE p_sel_affectation (i_numdecaismt IN affectation.numdecaismt%TYPE)
   IS
      CURSOR c_affec
      IS
         SELECT numaffec, codope, dataffec
           FROM affectation
          WHERE numdecaismt = i_numdecaismt;

      rec_c_affec   c_affec%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_affectation';

      OPEN c_affec;

      LOOP
         FETCH c_affec
          INTO rec_c_affec;

         EXIT WHEN c_affec%NOTFOUND;
         --
         g_trav_date_affec := rec_c_affec.dataffec;

         --
         IF (rec_c_affec.codope = 1)
         THEN
            p_sel_sante (i_numdec => rec_c_affec.numaffec);
         ELSIF (rec_c_affec.codope = 2)
         THEN
            p_sel_prev (i_numdec => rec_c_affec.numaffec);
         ELSIF (rec_c_affec.codope = 8)
         THEN
            p_sel_rbtcptcli (i_numaffec => rec_c_affec.numaffec);
         ELSIF (rec_c_affec.codope = 10)
         THEN
            p_sel_compte_tiers (i_cle => rec_c_affec.numaffec);
         END IF;
      END LOOP;

      CLOSE c_affec;
   END p_sel_affectation;

--
-- Selection des annulations d'affectations
--
   PROCEDURE p_sel_affectation_annul (
      i_numdecaismt   IN   affectation.numdecaismt%TYPE
   )
   IS
      CURSOR c_affec
      IS
         SELECT affectation_annul.numaffec, affectation_annul.codope,
                pnul.datannul dataffec
           FROM affectation_annul, pnul
          WHERE affectation_annul.numdecaismt = i_numdecaismt
            AND pnul.numdecaismt = i_numdecaismt;

      rec_c_affec   c_affec%ROWTYPE;
   BEGIN
--
      g_proc := 'P_SEL_affectation_annul';

--g_niv_msg := 3;
      IF (g_flag_test > 0)
      THEN
         g_msg_adm := 'P_SEL_affectation_annul ' || i_numdecaismt;
         p_ins_journal;
      END IF;

      OPEN c_affec;

      LOOP
         FETCH c_affec
          INTO rec_c_affec;

         EXIT WHEN c_affec%NOTFOUND;
         --
         g_trav_date_affec := g_trav_date_piece;

         IF (g_trav_signe = 1)
         THEN
            g_trav_codope := rec_c_affec.codope;
         END IF;

         --
         IF (rec_c_affec.codope = 1)
         THEN
            p_sel_sante_annul (i_numdec => rec_c_affec.numaffec);
         ELSIF (rec_c_affec.codope = 2)
         THEN
            p_sel_prev (i_numdec => rec_c_affec.numaffec);
         ELSIF (rec_c_affec.codope = 10)
         THEN
            p_sel_compte_tiers (i_cle => rec_c_affec.numaffec);
         END IF;
      END LOOP;

      CLOSE c_affec;
--
-- G_trav_signe := 1;
   END p_sel_affectation_annul;

/*
-- Necessite modification du MPD
--
-- Selection des pieces annulation de decaissement
--
Procedure P_SEL_affectation_annul (
                I_numdecaismt   IN      affectation.numdecaismt%Type
                )
IS
Cursor C_affec IS
        Select  affectation_annul.idpiece,
                affectation_annul.datannul              dataffec
        From    affectation_annul
        Where   affectation_annul.numdecaismt = I_numdecaismt;
Rec_C_affec     C_affec%Rowtype;
BEGIN
--
Open C_affec;
Loop
        Fetch C_affec Into Rec_C_affec;
        Exit When C_affec%NotFound;
        --
        G_trav_date_affec := Rec_C_affec.dataffec;
        --
        P_SEL_detail_annul (
                I_idpiece       => Rec_C_affec.idpiece
                );
End Loop;
Close C_affec;
--
-- G_trav_signe := 1;
END P_SEL_affectation_annul;
--
-- Traitement du detail annulation de decaissement
--@trav
Procedure P_SEL_detail_annul (
                I_idpiece       IN      detail_annul.idpiece%Type
                )
IS
Cursor C_piece IS
        Select  codope,
                cle
        From    detail_annul
        Where   idpiece = I_idpiece
        Group By
                codope,
                cle;
--
Cursor C_rbt (
        P_codope        IN detail_annul.codope%Type,
        P_cle           IN detail_annul.cle%Type
        )
IS
        Select  decaismt.numbene,
                compte.type,
                compte.cmpt_gene,
                detail_annul.montant                    mt_affec,
                detail_annul.exercice                   exercice
        From    compte,
                decaismt,
                affectation_annul,
                detail_annul
        Where   compte.numcpte = decaismt.numcpte
        and     decaismt.numdecaismt = affectation_annul.numdecaismt
        and     affectation_annul.idpiece = I_idpiece
        and     detail_annul.cle = P_cle
        and     detail_annul.codope = P_codope
        and     detail_annul.idpiece = I_idpiece;
--
Cursor C_detail (
        P_codope        IN detail_annul.codope%Type,
        P_cle           IN detail_annul.cle%Type
        )
IS
        Select  Sum( nvl(detail_annul.montant, 0) )             mt_affec,
                F_branche( detail_annul.numfor )                branche,
                F_type_contrat( detail_annul.numfor )           type_contrat,
                F_nat_risque( detail_annul.numfor )             risque,
                detail_annul.exercice
        From    detail_annul
        Where   detail_annul.idpiece = I_idpiece
        and     detail_annul.cle = P_cle
        and     detail_annul.codope = P_codope
        and     F_type_contrat( detail_annul.numfor ) between
                nvl( G_deb_type_contrat, F_type_contrat(detail_annul.numfor) )
                and
                nvl( G_fin_type_contrat,
                        nvl(G_deb_type_contrat,
                                F_type_contrat(detail_annul.numfor)) )
        and     F_nat_risque( detail_annul.numfor ) between
                nvl( G_deb_risque, F_nat_risque(detail_annul.numfor) )
                and
                nvl( G_fin_risque,
                        nvl(G_deb_risque,
                                F_nat_risque(detail_annul.numfor)) )
        Group By
                F_branche( detail_annul.numfor ),
                F_type_contrat( detail_annul.numfor ),
                F_nat_risque( detail_annul.numfor ),
                detail_annul.exercice
        ;
--
Rec_C_piece     C_piece%Rowtype;
Rec_C_rbt       C_rbt%Rowtype;
Rec_C_detail    C_detail%Rowtype;
BEGIN
G_proc := 'P_SEL_detail_annul';
--
Open C_piece;
Loop
        Fetch C_piece Into Rec_C_piece;
        Exit When C_piece%NotFound;
        --
        If ( Rec_C_piece.codope IN (8, 10, 15) ) then
                Open C_rbt (
                        Rec_C_piece.codope,
                        Rec_C_piece.cle
                        );
                Loop
                        Fetch C_rbt Into Rec_C_rbt;
                        Exit When C_rbt%NotFound;
                        --
                        G_trav_branche := 99;
                        G_trav_type_contrat := 0;
                        G_trav_risque := -100;
                        G_trav_exercice := Rec_C_rbt.exercice;
                        G_trav_mt_affec := Rec_C_rbt.mt_affec;
                        G_trav_numgar := Null;
                        If ( Rec_C_rbt.type = 1 ) then
                                G_trav_lib_piece := 'Remb. client ' ||
                                        to_char(Rec_C_rbt.numbene);
                        Else
                                G_trav_lib_piece := 'Operat? sur compte ' ||
                                        Rec_C_rbt.cmpt_gene;
                        End if;
                        --
                        P_INS_trav_treso;
                        --
                End Loop;
                Close C_rbt;
        Else
                Open C_detail (
                        Rec_C_piece.codope,
                        Rec_C_piece.cle
                        );
                Loop
                        Fetch C_detail Into Rec_C_detail;
                        Exit When C_detail%NotFound;
                        --
                        G_trav_branche := Rec_C_detail.branche;
                        G_trav_type_contrat := Rec_C_detail.type_contrat;
                        G_trav_risque := Rec_C_detail.risque;
                        G_trav_exercice := Rec_C_detail.exercice;
                        G_trav_mt_affec := Rec_C_detail.mt_affec;
                        If ( Rec_C_piece.codope IN (1, 14) ) then
                                G_trav_lib_piece := 'DCPTE SANTE N° ';
                        ElsIf ( Rec_C_piece.codope = 2 ) then
                                G_trav_lib_piece := 'DCPTE PREV N° ';
                        ElsIf ( Rec_C_piece.codope = 5 ) then
                                G_trav_lib_piece := 'REVERS COTIS N° ';
                        ElsIf ( Rec_C_piece.codope = 11 ) then
                                G_trav_lib_piece := 'REVERS URSSAF N° ';
                        ElsIf ( Rec_C_piece.codope = 16 ) then
                                G_trav_lib_piece := 'Bx RETRO N° ';
                        End if;
                        G_trav_lib_piece := G_trav_lib_piece ||
                                                Rec_C_piece.cle;
                        --
                        P_INS_trav_treso;
                        --
                End Loop;
        End if;
End Loop;
Close C_piece;
END P_SEL_detail_annul;
*/

-- JBO : 27/11/2009 *******************************************************************************************
-- Ajout de la procedure publique p_sel_affect_annul afin de permettre l'extraction des informations 
-- des decaissements cheques annules
Procedure p_sel_affect_annul (I_numdecaismt   IN      affectation.numdecaismt%Type)
IS
Cursor C_affec IS
        Select  affectation_annul.idpiece,
                affectation_annul.datannul              dataffec
        From    affectation_annul
        Where   affectation_annul.numdecaismt = I_numdecaismt;
Rec_C_affec     C_affec%Rowtype;
BEGIN
--
Open C_affec;
Loop
        Fetch C_affec Into Rec_C_affec;
        Exit When C_affec%NotFound;
        --
        G_trav_date_affec := Rec_C_affec.dataffec;
        --
        P_SEL_detail_annul (
                I_idpiece       => Rec_C_affec.idpiece
                );
End Loop;
Close C_affec;
--
-- G_trav_signe := 1;
END p_sel_affect_annul;
--
-- Traitement du detail annulation de decaissement
--@trav
Procedure P_SEL_detail_annul (
                I_idpiece       IN      detail_annul.idpiece%Type
                )
IS
Cursor C_piece IS
        Select  codope,
                cle
        From    detail_annul
        Where   idpiece = I_idpiece
        Group By
                codope,
                cle;
--
Cursor C_rbt (
        P_codope        IN detail_annul.codope%Type,
        P_cle           IN detail_annul.cle%Type
        )
IS
        Select  decaismt.numbene,
                compte.type,
                compte.cmpt_gene,
                detail_annul.montant                    mt_affec,
                detail_annul.exercice                   exercice,
                decaismt.refpmt                         refpmt,
                decaismt.numdest                        numdest,
                decaismt.numdecaismt                    numdecaismt
        From    compte,
                decaismt,
                affectation_annul,
                detail_annul
        Where   compte.numcpte = decaismt.numcpte
        and     decaismt.numdecaismt = affectation_annul.numdecaismt
        and     affectation_annul.idpiece = I_idpiece
        and     detail_annul.cle = P_cle
        and     detail_annul.codope = P_codope
        and     detail_annul.idpiece = I_idpiece;
--
Cursor C_detail (
        P_codope        IN detail_annul.codope%Type,
        P_cle           IN detail_annul.cle%Type
        )
IS
        Select  Sum( nvl(detail_annul.montant, 0) )             mt_affec,
                F_branche( detail_annul.numfor )                branche,
                F_type_contrat( detail_annul.numfor )           type_contrat,
                F_nat_risque( detail_annul.numfor )             risque,
                detail_annul.exercice,
                decaismt.refpmt                         refpmt,
                decaismt.numdest                        numdest,
                decaismt.numdecaismt                    numdecaismt
        From    detail_annul
              , decaismt                                          -- JBO : ajout table decaismt pour récuperer + d info
        Where   detail_annul.idpiece = I_idpiece
        and     detail_annul.idpiece = decaismt.numdecaismt       -- JBO ; ajout jointure
        and     detail_annul.cle = P_cle
        and     detail_annul.codope = P_codope
        and     F_type_contrat( detail_annul.numfor ) between
                nvl( G_deb_type_contrat, F_type_contrat(detail_annul.numfor) )
                and
                nvl( G_fin_type_contrat,
                        nvl(G_deb_type_contrat,
                                F_type_contrat(detail_annul.numfor)) )
        and     F_nat_risque( detail_annul.numfor ) between
                nvl( G_deb_risque, F_nat_risque(detail_annul.numfor) )
                and
                nvl( G_fin_risque,
                        nvl(G_deb_risque,
                                F_nat_risque(detail_annul.numfor)) )
        Group By
                F_branche( detail_annul.numfor ),
                F_type_contrat( detail_annul.numfor ),
                F_nat_risque( detail_annul.numfor ),
                detail_annul.exercice,
                refpmt,
                numdest,
                numdecaismt
        ;
--
Rec_C_piece     C_piece%Rowtype;
Rec_C_rbt       C_rbt%Rowtype;
Rec_C_detail    C_detail%Rowtype;
BEGIN
G_proc := 'P_SEL_detail_annul';
--
Open C_piece;
Loop
        Fetch C_piece Into Rec_C_piece;
        Exit When C_piece%NotFound;
        --
        If ( Rec_C_piece.codope IN (8, 10, 15) ) then
                Open C_rbt (
                        Rec_C_piece.codope,
                        Rec_C_piece.cle
                        );
                Loop
                        Fetch C_rbt Into Rec_C_rbt;
                        Exit When C_rbt%NotFound;
                        --
                        -- JBO : Recherche du libelle du compte
                        BEGIN
                         SELECT TO_CHAR (prelevement.numremise) numremise
                              , compte.libcompte
                           INTO g_trav_refremise
                              , g_trav_libcompte
                           FROM compte, prelevement, remise_prelev
                          WHERE numencaismt = I_idpiece
                            AND remise_prelev.numremise = prelevement.numremise
                            AND compte.numcpte = remise_prelev.numcpte;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                            g_trav_libcompte := NULL;
                            g_trav_refremise := NULL;
                          WHEN TOO_MANY_ROWS THEN
                            g_trav_libcompte := NULL;
                            g_trav_refremise := NULL;
                        END;
                        g_trav_numtiers:=Rec_C_rbt.numdest;
                        -- JBO : Recherche du numero de contrat
                        BEGIN
                         SELECT DISTINCT numgar
                           INTO g_trav_numgar
                           FROM contrat
                          WHERE numcli = g_trav_numtiers;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                            g_trav_numgar := NULL;
                          WHEN TOO_MANY_ROWS THEN
                           g_trav_numgar := NULL;
                        END;

                        g_trav_codope := Rec_C_piece.codope;
                        g_trav_idpiece := Rec_C_rbt.numdecaismt;
                        g_trav_date_piece := G_trav_date_affec;
                        g_trav_mregl := 1;
                        G_trav_branche := 99;
                        G_trav_type_contrat := 0;
                        G_trav_risque := -100;
                        G_trav_exercice := Rec_C_rbt.exercice;
                        g_trav_mt_regl := NVL(Rec_C_rbt.mt_affec,0);
                        G_trav_mt_affec := NVL(Rec_C_rbt.mt_affec,0);
                        g_trav_refpiece := Rec_C_rbt.refpmt;
                        g_trav_type_risque := 0;
                        g_trav_type_retro := NULL;                     -- A TROUVER!
                        g_trav_signe := -1;
                        If ( Rec_C_rbt.type = 1 ) then
                                G_trav_lib_piece := 'Remb. client ' ||
                                        to_char(Rec_C_rbt.numbene);
                        Else
                                G_trav_lib_piece := 'Operation sur compte ' ||
                                        Rec_C_rbt.cmpt_gene;
                        End if;
                        --
                        P_INS_trav_treso;
                        --
                End Loop;
                Close C_rbt;
        Else
                Open C_detail (
                        Rec_C_piece.codope,
                        Rec_C_piece.cle
                        );
                Loop
                        Fetch C_detail Into Rec_C_detail;
                        Exit When C_detail%NotFound;
                        --
                        -- JBO : Recherche du libelle du compte
                        BEGIN
                        SELECT TO_CHAR (prelevement.numremise) numremise
                              , compte.libcompte
                           INTO g_trav_refremise
                              , g_trav_libcompte
                           FROM compte, prelevement, remise_prelev
                          WHERE numencaismt = I_idpiece
                            AND remise_prelev.numremise = prelevement.numremise
                            AND compte.numcpte = remise_prelev.numcpte;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                            g_trav_libcompte := NULL;
                            g_trav_refremise := NULL;
                          WHEN TOO_MANY_ROWS THEN
                            g_trav_libcompte := NULL;
                            g_trav_refremise := NULL;
                        END;
                        g_trav_numtiers:=Rec_C_detail.numdest;
                        -- JBO : Recherche du numero de contrat
                        BEGIN
                         SELECT DISTINCT numgar
                           INTO g_trav_numgar
                           FROM contrat
                          WHERE numcli = g_trav_numtiers;
                        EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                            g_trav_numgar := NULL;
                          WHEN TOO_MANY_ROWS THEN
                           g_trav_numgar := NULL;
                        END;
                        g_trav_codope := Rec_C_piece.codope;
                        g_trav_idpiece := Rec_C_detail.numdecaismt;
                        g_trav_date_piece := G_trav_date_affec;
                        g_trav_mregl := 1;
                        G_trav_branche := Rec_C_detail.branche;
                        G_trav_type_contrat := Rec_C_detail.type_contrat;
                        G_trav_risque := Rec_C_detail.risque;
                        G_trav_exercice := Rec_C_detail.exercice;
                        g_trav_mt_regl := NVL(Rec_C_detail.mt_affec,0);
                        G_trav_mt_affec := NVL(Rec_C_detail.mt_affec,0);
                        g_trav_refpiece := Rec_C_detail.refpmt;
                        g_trav_type_risque := 0;
                        g_trav_type_retro := NULL;                     -- A TROUVER!
                        g_trav_signe := -1;
                        If ( Rec_C_piece.codope IN (1, 14) ) then
                                G_trav_lib_piece := 'DCPTE SANTE N° ';
                        ElsIf ( Rec_C_piece.codope = 2 ) then
                                G_trav_lib_piece := 'DCPTE PREV N° ';
                        ElsIf ( Rec_C_piece.codope = 5 ) then
                                G_trav_lib_piece := 'REVERS COTIS N° ';
                        ElsIf ( Rec_C_piece.codope = 11 ) then
                                G_trav_lib_piece := 'REVERS URSSAF N° ';
                        ElsIf ( Rec_C_piece.codope = 16 ) then
                                G_trav_lib_piece := 'Bx RETRO N° ';
                        End if;
                        G_trav_lib_piece := G_trav_lib_piece ||
                                                Rec_C_piece.cle;
                        --
                        P_INS_trav_treso;
                        --
                End Loop;
        End if;
End Loop;
Close C_piece;
END P_SEL_detail_annul;

-- Fin du nouveau MPD annulation decaissements
-- Fin JBO : 27/11/2009 *******************************************************************************************

--
-- Traitement des prestations sante ( codope 1 et 14 )
--
   PROCEDURE p_sel_sante (i_numdec IN decompte.numdec%TYPE)
   IS
      CURSOR c_sante
      IS
         SELECT   SUM (NVL (sinistre.mtreel, 0)) mt_affec,
                  f_branche (sinistre.numfor) branche,
                  f_type_contrat (sinistre.numfor) type_contrat,
                  f_nat_risque (sinistre.numfor) risque,
                  TO_CHAR (sinistre.datsin, 'yyyy') exercice,
                  sinistre.numdec
             FROM sinistre
            WHERE sinistre.numdec = i_numdec
              AND f_type_contrat (sinistre.numfor)
                     BETWEEN NVL (g_deb_type_contrat,
                                  f_type_contrat (sinistre.numfor)
                                 )
                         AND NVL (g_fin_type_contrat,
                                  NVL (g_deb_type_contrat,
                                       f_type_contrat (sinistre.numfor)
                                      )
                                 )
              AND f_nat_risque (sinistre.numfor)
                     BETWEEN NVL (g_deb_risque,
                                  f_nat_risque (sinistre.numfor))
                         AND NVL (g_fin_risque,
                                  NVL (g_deb_risque,
                                       f_nat_risque (sinistre.numfor)
                                      )
                                 )
         GROUP BY f_branche (sinistre.numfor),
                  f_type_contrat (sinistre.numfor),
                  f_nat_risque (sinistre.numfor),
                  TO_CHAR (sinistre.datsin, 'yyyy'),
                  sinistre.numdec;

      rec_c_sante   c_sante%ROWTYPE;
      l_prorata     NUMBER            := 1;
      l_tot_affec   NUMBER            := 0;
   BEGIN
      g_proc := 'P_SEL_sante';

--@)
      SELECT NVL (SUM (sinistre.mtreel), 0)
        INTO l_tot_affec
        FROM sinistre
       WHERE sinistre.numdec = i_numdec;

--
-- Si remboursement indu partiel on proratise
--
      IF (g_etendue = 1 AND l_tot_affec != 0)
      THEN
         l_prorata := LEAST (g_trav_mt_regl, l_tot_affec) / l_tot_affec;

         IF (l_prorata = 1)
         THEN
            l_prorata := -1;
         END IF;
      END IF;

--
      IF (g_flag_test > 0)
      THEN
         g_msg_adm :=
               'G_deb_type_contrat '
            || TO_CHAR (g_deb_type_contrat)
            || ' G_fin_type_contrat '
            || TO_CHAR (g_fin_type_contrat);
      END IF;

--
      OPEN c_sante;

      LOOP
         FETCH c_sante
          INTO rec_c_sante;

         EXIT WHEN c_sante%NOTFOUND;

         --
         IF (g_etendue = 1 AND g_affectation < ABS (l_tot_affec))
         THEN
            l_prorata := g_affectation / l_tot_affec;
         END IF;

         --
         BEGIN
            SELECT numgar
              INTO g_trav_numgar
              FROM decompte
             WHERE numdec = i_numdec;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               g_trav_numgar := NULL;
         END;

         --
         g_trav_branche := rec_c_sante.branche;
         g_trav_type_contrat := rec_c_sante.type_contrat;
         g_trav_risque := rec_c_sante.risque;
         g_trav_exercice := rec_c_sante.exercice;
         g_trav_mt_affec := l_prorata * rec_c_sante.mt_affec;
         g_trav_lib_piece := 'DCPTE N° ' || rec_c_sante.numdec;

         --
         IF (g_flag_test > 0)
         THEN
            g_msg_adm :=
                  g_msg_adm
               || ' G_trav_type_contrat '
               || TO_CHAR (g_trav_type_contrat);
            p_ins_journal;
            COMMIT;
         END IF;

         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_sante;
   END p_sel_sante;

--
-- Traitement des prestations sante annulation ( codope 9 )
--
   PROCEDURE p_sel_sante_annul (i_numdec IN decompte.numdec%TYPE)
   IS
      CURSOR c_sante_annul
      IS
         SELECT   SUM (NVL (sinistre_annul.mtreel, 0)) mt_affec,
                  f_branche (sinistre_annul.numfor) branche,
                  f_type_contrat (sinistre_annul.numfor) type_contrat,
                  f_nat_risque (sinistre_annul.numfor) risque,
                  TO_CHAR (sinistre_annul.datsin, 'yyyy') exercice,
                  sinistre_annul.numdec
             FROM sinistre_annul
            WHERE sinistre_annul.numdec = i_numdec
              AND f_type_contrat (sinistre_annul.numfor)
                     BETWEEN NVL (g_deb_type_contrat,
                                  f_type_contrat (sinistre_annul.numfor)
                                 )
                         AND NVL (g_fin_type_contrat,
                                  NVL (g_deb_type_contrat,
                                       f_type_contrat (sinistre_annul.numfor)
                                      )
                                 )
              AND f_nat_risque (sinistre_annul.numfor)
                     BETWEEN NVL (g_deb_risque,
                                  f_nat_risque (sinistre_annul.numfor)
                                 )
                         AND NVL (g_fin_risque,
                                  NVL (g_deb_risque,
                                       f_nat_risque (sinistre_annul.numfor)
                                      )
                                 )
         GROUP BY f_branche (sinistre_annul.numfor),
                  f_type_contrat (sinistre_annul.numfor),
                  f_nat_risque (sinistre_annul.numfor),
                  TO_CHAR (sinistre_annul.datsin, 'yyyy'),
                  sinistre_annul.numdec;

      rec_c_sante_annul   c_sante_annul%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_sante_annul';

      OPEN c_sante_annul;

      LOOP
         FETCH c_sante_annul
          INTO rec_c_sante_annul;

         EXIT WHEN c_sante_annul%NOTFOUND;
         --
         g_trav_branche := rec_c_sante_annul.branche;
         g_trav_type_contrat := rec_c_sante_annul.type_contrat;
         g_trav_risque := rec_c_sante_annul.risque;
         g_trav_exercice := rec_c_sante_annul.exercice;
         g_trav_mt_affec := rec_c_sante_annul.mt_affec;

         IF (g_trav_signe = 1)
         THEN
            g_trav_lib_piece := 'DCPTE N° ' || rec_c_sante_annul.numdec;
         ELSE
            g_trav_lib_piece := 'ANNUL DCPTE N° ' || rec_c_sante_annul.numdec;
         END IF;

         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_sante_annul;
   END p_sel_sante_annul;

--
-- Traitement des prestations prevoyance ( codope 2 )
--
   PROCEDURE p_sel_prev (i_numdec IN decompte_prev.numdec%TYPE)
   IS
      CURSOR c_prev
      IS
         SELECT   SUM (f_total_histo (histo_jours.idhisto, -2)) mt_affec,
                  f_branche (repartition.numfor) branche,
                  f_type_contrat (repartition.numfor) type_contrat,
                  f_nat_risque (repartition.numfor) risque,
                  TO_CHAR (sntr_prev.survenance, 'yyyy') exercice,
                  histo_calcul.numdec
             FROM histo_jours, histo_calcul, repartition, sntr_prev
            WHERE histo_jours.idcalcul = histo_calcul.idcalcul
              AND histo_calcul.numdec = i_numdec
              AND repartition.idrepartition = histo_calcul.idrepartition
              AND sntr_prev.nosin = repartition.nosin
              AND f_type_contrat (repartition.numfor)
                     BETWEEN NVL (g_deb_type_contrat,
                                  f_type_contrat (repartition.numfor)
                                 )
                         AND NVL (g_fin_type_contrat,
                                  NVL (g_deb_type_contrat,
                                       f_type_contrat (repartition.numfor)
                                      )
                                 )
              AND f_nat_risque (repartition.numfor)
                     BETWEEN NVL (g_deb_risque,
                                  f_nat_risque (repartition.numfor)
                                 )
                         AND NVL (g_fin_risque,
                                  NVL (g_deb_risque,
                                       f_nat_risque (repartition.numfor)
                                      )
                                 )
         GROUP BY f_branche (repartition.numfor),
                  f_type_contrat (repartition.numfor),
                  f_nat_risque (repartition.numfor),
                  TO_CHAR (sntr_prev.survenance, 'yyyy'),
                  histo_calcul.numdec;

      rec_c_prev    c_prev%ROWTYPE;
      l_prorata     NUMBER           := 1;
      l_tot_affec   NUMBER           := 0;
   BEGIN
      g_proc := 'P_SEL_prev';

--
-- Si remboursement indu partiel on proratise
--
      SELECT SUM (f_total_histo (histo_jours.idhisto, -2))
        INTO l_tot_affec
        FROM histo_jours, histo_calcul
       WHERE histo_jours.idcalcul = histo_calcul.idcalcul
         AND histo_calcul.numdec = i_numdec;

--
      IF (g_etendue = 1 AND l_tot_affec != 0)
      THEN
         l_prorata := LEAST (g_trav_mt_regl, l_tot_affec) / l_tot_affec;

         IF (l_prorata = 1)
         THEN
            l_prorata := -1;
         END IF;
      END IF;

--
      IF (g_flag_test > 0)
      THEN
         g_msg_adm :=
               'Etendue '
            || TO_CHAR (g_etendue)
            || ' Tot_affec '
            || TO_CHAR (l_tot_affec)
            || ' Prorata '
            || TO_CHAR (l_prorata);
         p_ins_journal;
         COMMIT;
      END IF;

--
      OPEN c_prev;

      LOOP
         FETCH c_prev
          INTO rec_c_prev;

         EXIT WHEN c_prev%NOTFOUND;

         --
         IF (g_etendue = 1 AND g_affectation < ABS (l_tot_affec))
         THEN
            l_prorata := g_affectation / l_tot_affec;
         END IF;

         --
         BEGIN
            SELECT adhe_cntrt.numgar
              INTO g_trav_numgar
              FROM adhe_cntrt, decompte_prev
             WHERE adhe_cntrt.idadhesion = decompte_prev.idadhesion
               AND decompte_prev.numdec = i_numdec;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               g_trav_numgar := NULL;
         END;

         --
         g_trav_branche := rec_c_prev.branche;
         g_trav_type_contrat := rec_c_prev.type_contrat;
         g_trav_risque := rec_c_prev.risque;
         g_trav_exercice := rec_c_prev.exercice;
         g_trav_mt_affec := l_prorata * rec_c_prev.mt_affec;
         g_trav_lib_piece := 'DCPTE N° ' || rec_c_prev.numdec;
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_prev;
   END p_sel_prev;

--
-- Selection des affectations compte client
--
   PROCEDURE p_sel_compte_client (
      i_numencaismt   IN   compte_client.numencaismt%TYPE
   )
   IS
      CURSOR c_cptcli
      IS
         SELECT idaffec, codope, numfact, montant, datope
           FROM compte_client
          WHERE numencaismt = i_numencaismt
            AND datope BETWEEN g_debut AND g_fin
            AND NVL
                   (pk_compte_tiers.f_codope
                                           (pk_compte_tiers.f_origine (codope,
                                                                       idaffec
                                                                      )
                                           ,compte_client.numcli
                                           ),
                    10
                   ) = 10
            AND NOT EXISTS (
                   SELECT 1
                     FROM annul_cptcli
                    WHERE annul_cptcli.numencaismt = i_numencaismt
                      AND annul_cptcli.idaffec = compte_client.idaffec);

--
      CURSOR c_annul
      IS
         SELECT compte_client.idaffec, compte_client.codope,
                compte_client.numfact, compte_client.datope,
                annul_encais.date_annul
           FROM compte_client, annul_cptcli, annul_encais
          WHERE compte_client.numencaismt = i_numencaismt
            AND annul_cptcli.numencaismt = compte_client.numencaismt
            AND annul_cptcli.idaffec = compte_client.idaffec
            AND annul_encais.numencaismt = compte_client.numencaismt
            AND compte_client.datope BETWEEN g_debut AND g_fin;

--
      rec_c_cptcli   c_cptcli%ROWTYPE;
      rec_c_annul    c_annul%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_compte_client';

      OPEN c_cptcli;

      LOOP
         FETCH c_cptcli
          INTO rec_c_cptcli;

         EXIT WHEN c_cptcli%NOTFOUND;
         --
         g_trav_date_affec := rec_c_cptcli.datope;
         g_affectation := rec_c_cptcli.montant;

         --
         IF (rec_c_cptcli.codope = 1)
         THEN
            p_sel_sante (i_numdec => rec_c_cptcli.numfact);
         ELSIF (rec_c_cptcli.codope = 2)
         THEN
            p_sel_prev (i_numdec => rec_c_cptcli.numfact);
         ELSIF (rec_c_cptcli.codope = 4)
         THEN
            p_sel_cotis (i_idaffec => rec_c_cptcli.idaffec);
         ELSIF (rec_c_cptcli.codope = 8)
         THEN
            p_sel_solde_client (i_idaffec => rec_c_cptcli.idaffec);
         END IF;
      END LOOP;

      CLOSE c_cptcli;

--
      OPEN c_annul;

      LOOP
         FETCH c_annul
          INTO rec_c_annul;

         EXIT WHEN c_annul%NOTFOUND;
         --
         g_flag_annul := TRUE;
         g_trav_mt_regl := -g_trav_mt_regl;

         g_trav_date_piece := rec_c_annul.date_annul;
         g_trav_date_affec := rec_c_annul.datope;

         --
         IF (rec_c_annul.codope = 1)
         THEN
            p_sel_sante (i_numdec => rec_c_annul.numfact);
         ELSIF (rec_c_annul.codope = 2)
         THEN
            p_sel_prev (i_numdec => rec_c_annul.numfact);
         ELSIF (rec_c_annul.codope = 4)
         THEN
            p_sel_cotis (i_idaffec => rec_c_annul.idaffec);
         ELSIF (rec_c_annul.codope = 8)
         THEN
            p_sel_solde_client (i_idaffec => rec_c_annul.idaffec);
         END IF;
      END LOOP;

      CLOSE c_annul;

      g_flag_annul := FALSE;
   END p_sel_compte_client;

--
-- Traitement des ecritures compte_client par compensation
--
   PROCEDURE p_sel_compensation (
      i_deb_codope   IN   compte_client.codope%TYPE,
      i_fin_codope   IN   compte_client.codope%TYPE,
      i_deb_numcli   IN   compte_client.numcli%TYPE,
      i_fin_numcli   IN   compte_client.numcli%TYPE
   )
   IS
      CURSOR c_client
      IS
         SELECT compte_client.codope, compte_client.datope,
                compte_client.numcli, compte_client.numfact,
                compte_client.idaffec, compte_client.montant,
                pk_compte_tiers.f_origine (compte_client.codope,
                                           compte_client.idaffec
                                          ) origine
           FROM compte_client
          WHERE compte_client.codope BETWEEN NVL (i_deb_codope, codope)
                                         AND NVL (i_fin_codope,
                                                  NVL (i_deb_codope, codope)
                                                 )
            AND compte_client.numcli BETWEEN NVL (i_deb_numcli, numcli)
                                         AND NVL (i_fin_numcli,
                                                  NVL (i_deb_numcli, numcli)
                                                 )
            AND compte_client.datope BETWEEN g_debut AND g_fin
            AND pk_compte_tiers.f_codope (pk_compte_tiers.f_origine (codope,
                                                                     idaffec
                                                                    )
                                          ,compte_client.numcli
                                         ) IN (2, 14, 15, 16);

--
      CURSOR c_origine (p_idmvt IN compte_tiers.idmvt%TYPE)
      IS
         SELECT codope, cle, datope, montant
           FROM compte_tiers
          WHERE idmvt = p_idmvt;

      rec_c_client    c_client%ROWTYPE;
      rec_c_origine   c_origine%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_compensation';

      OPEN c_client;

      LOOP
         FETCH c_client
          INTO rec_c_client;

         EXIT WHEN c_client%NOTFOUND;

         --
         OPEN c_origine (rec_c_client.origine);

         FETCH c_origine
          INTO rec_c_origine;

         CLOSE c_origine;

         --
         g_affectation := rec_c_client.montant;
         g_trav_codope := rec_c_client.codope;
         g_trav_idpiece := rec_c_origine.cle;
         g_trav_date_piece := rec_c_origine.datope;
         g_trav_mregl := -rec_c_origine.codope;
         g_trav_numtiers := rec_c_client.numcli;
         g_trav_refpiece := NULL;
         g_trav_mt_regl := rec_c_origine.montant;
         --
         g_trav_date_affec := rec_c_client.datope;

         --
         IF (rec_c_client.codope = 1)
         THEN
            p_sel_sante (i_numdec => rec_c_client.numfact);
         ELSIF (rec_c_client.codope = 2)
         THEN
            p_sel_prev (i_numdec => rec_c_client.numfact);
         ELSIF (rec_c_client.codope = 4)
         THEN
            p_sel_cotis (i_idaffec => rec_c_client.idaffec);
         END IF;
      END LOOP;

      CLOSE c_client;
   END p_sel_compensation;

--
-- Traitement des ecritures debit par compensation
--
   PROCEDURE p_sel_comp_debit (
      i_deb_codope   IN   compte_tiers.codope%TYPE,
      i_fin_codope   IN   compte_tiers.codope%TYPE,
      i_deb_numcli   IN   compte_tiers.numcli%TYPE,
      i_fin_numcli   IN   compte_tiers.numcli%TYPE,
      i_debut        IN   DATE,
      i_fin          IN   DATE
   )
   IS
      CURSOR c_tiers
      IS
         SELECT compte_tiers.codope, compte_tiers.idmvt, compte_tiers.datope,
                compte_tiers.numcli, compte_tiers.cle, compte_tiers.montant
           FROM compte_tiers
          WHERE compte_tiers.codope BETWEEN NVL (i_deb_codope, codope)
                                        AND NVL (i_fin_codope,
                                                 NVL (i_deb_codope, codope)
                                                )
            AND compte_tiers.numcli BETWEEN NVL (i_deb_numcli, numcli)
                                        AND NVL (i_fin_numcli,
                                                 NVL (i_deb_numcli, numcli)
                                                )
            -- and  compte_tiers.datope between I_debut and I_fin
            AND compte_tiers.codope IN (2, 14, 15, 16)
            AND compte_tiers.idmvt IN (SELECT idmvt
                                         FROM compensation)
            AND NOT EXISTS (SELECT 1
                              FROM compensation
                             WHERE compensation.idcomp = compte_tiers.idmvt);

--
      CURSOR c_debit (p_idmvt IN compte_tiers.idmvt%TYPE)
      IS
         SELECT codope, cle, datope, montant
           FROM compte_tiers
          WHERE idmvt IN (SELECT idcomp
                            FROM compensation
                           WHERE idmvt = p_idmvt)
            AND compte_tiers.datope BETWEEN i_debut AND i_fin
            AND codope != 10;

      rec_c_tiers   c_tiers%ROWTYPE;
      rec_c_debit   c_debit%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_comp_debit';

      OPEN c_tiers;

      LOOP
         FETCH c_tiers
          INTO rec_c_tiers;

         EXIT WHEN c_tiers%NOTFOUND;

         --
         IF (g_flag_test > 0)
         THEN
            g_msg_adm := 'Idmvt ' || TO_CHAR (rec_c_tiers.idmvt);
            p_ins_journal;
            COMMIT;
         END IF;

         --
         OPEN c_debit (rec_c_tiers.idmvt);

         LOOP
            FETCH c_debit
             INTO rec_c_debit;

            EXIT WHEN c_debit%NOTFOUND;

            --
            IF (g_flag_test > 0)
            THEN
               g_msg_adm := 'Debit ' || TO_CHAR (rec_c_debit.cle);
               p_ins_journal;
               COMMIT;
            END IF;

            --
            IF (rec_c_tiers.codope = 2)
            THEN
               g_trav_codope := 17;
            ELSE
               g_trav_codope := rec_c_tiers.codope;
            END IF;

            g_trav_idpiece := rec_c_tiers.cle;
            g_trav_date_piece := rec_c_tiers.datope;
            g_trav_mregl := -rec_c_debit.codope;
            g_trav_numtiers := rec_c_tiers.numcli;
            g_trav_refpiece := NULL;
            g_trav_mt_regl := rec_c_tiers.montant;
            g_affectation := rec_c_debit.montant;
            --
            g_trav_date_affec := rec_c_debit.datope;

            --
            IF (rec_c_debit.codope = 4)
            THEN
               p_sel_cotis (i_idaffec => rec_c_debit.cle);
            ELSIF (rec_c_tiers.codope = 2)
            THEN
               p_sel_prev (i_numdec => rec_c_tiers.cle);
            ELSIF (rec_c_tiers.codope = 16)
            THEN
               p_sel_retro (i_idrevers => rec_c_tiers.cle);
            END IF;
         END LOOP;

         CLOSE c_debit;
      END LOOP;

      CLOSE c_tiers;
   END p_sel_comp_debit;

--
-- Traitement des frais globaux emis
--
   PROCEDURE p_sel_emis_frais (i_numquit IN qttc_global.numquit%TYPE)
   IS
      CURSOR c_frais
      IS
         SELECT   SUM (NVL (qttc_frais.montant, 0)) mt_affec,
                  -type_frais risque
             FROM qttc_frais
            WHERE qttc_frais.numfor = 0 AND qttc_frais.numquit = i_numquit
         GROUP BY -type_frais;

      rec_c_frais   c_frais%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_emis_frais';

      OPEN c_frais;

      LOOP
         FETCH c_frais
          INTO rec_c_frais;

         EXIT WHEN c_frais%NOTFOUND;
         --
         g_trav_branche := -1;
         g_trav_type_risque := 4;
         g_trav_risque := rec_c_frais.risque;
         g_trav_mt_affec := rec_c_frais.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('TYPFRAIS', -rec_c_frais.risque),
                       1,
                       17
                      )
            || ' ECH '
            || TO_CHAR (i_numquit);
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_frais;
   END p_sel_emis_frais;

--
-- Traitement des emissions par garantie
--
   PROCEDURE p_sel_emis_gar (i_numquit IN qttc_global.numquit%TYPE)
   IS
      CURSOR c_gar
      IS
         SELECT   SUM (NVL (qttc_gar.mt_net, 0)) mt_affec,
                  f_branche (qttc_gar.numfor) branche,
                  f_nat_risque (qttc_gar.numfor) risque
             FROM qttc_gar
            WHERE qttc_gar.numquit = i_numquit
              AND f_nat_risque (qttc_gar.numfor)
                     BETWEEN NVL (g_deb_risque,
                                  f_nat_risque (qttc_gar.numfor))
                         AND NVL (g_fin_risque,
                                  NVL (g_deb_risque,
                                       f_nat_risque (qttc_gar.numfor)
                                      )
                                 )
         GROUP BY f_branche (qttc_gar.numfor), f_nat_risque (qttc_gar.numfor);

      rec_c_gar   c_gar%ROWTYPE;
   BEGIN
      OPEN c_gar;

      LOOP
         FETCH c_gar
          INTO rec_c_gar;

         EXIT WHEN c_gar%NOTFOUND;
         --
         g_trav_branche := rec_c_gar.branche;
         g_trav_risque := rec_c_gar.risque;
         g_trav_type_risque := 0;
         g_trav_mt_affec := rec_c_gar.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_nat_risque (rec_c_gar.risque, 0), 1, 17)
            || ' ECH '
            || TO_CHAR (i_numquit);
         --
         p_ins_trav_treso;
         --
         p_sel_emis_taxes (i_numquit      => i_numquit,
                           i_risque       => rec_c_gar.risque
                          );
         --
         p_sel_emis_frais_gar (i_numquit      => i_numquit,
                               i_risque       => rec_c_gar.risque
                              );
         --
         p_sel_emis_comm (i_numquit      => i_numquit,
                          i_risque       => rec_c_gar.risque);
      --
      END LOOP;

      CLOSE c_gar;
   END p_sel_emis_gar;

--
-- Traitement des taxes emises
--
   PROCEDURE p_sel_emis_taxes (
      i_numquit   IN   qttc_global.numquit%TYPE,
      i_risque    IN   NUMBER
   )
   IS
      CURSOR c_taxe
      IS
         SELECT   SUM (NVL (qttc_taxe.montant, 0)) mt_affec,
                  -type_taxe risque
             FROM qttc_taxe
            WHERE numquit = i_numquit
              AND f_nat_risque (qttc_taxe.numfor) = i_risque
         GROUP BY -type_taxe;

      rec_c_taxe   c_taxe%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_emis_taxe';

      OPEN c_taxe;

      LOOP
         FETCH c_taxe
          INTO rec_c_taxe;

         EXIT WHEN c_taxe%NOTFOUND;
         --
         g_trav_type_risque := 1;
         g_trav_risque := rec_c_taxe.risque;
         g_trav_mt_affec := rec_c_taxe.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('TYPTAX', -rec_c_taxe.risque), 1,
                       17)
            || ' ECH '
            || TO_CHAR (i_numquit);
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_taxe;
   END p_sel_emis_taxes;

--
-- Traitement des frais sur garanties emises
--
   PROCEDURE p_sel_emis_frais_gar (
      i_numquit   IN   qttc_global.numquit%TYPE,
      i_risque    IN   NUMBER
   )
   IS
      CURSOR c_frais
      IS
         SELECT   SUM (NVL (qttc_frais.montant, 0)) mt_affec,
                  -type_frais risque
             FROM qttc_frais
            WHERE numquit = i_numquit
              AND f_nat_risque (qttc_frais.numfor) = i_risque
              AND numfor != 0
         GROUP BY -type_frais;

      rec_c_frais   c_frais%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_emis_frais_gar';

      OPEN c_frais;

      LOOP
         FETCH c_frais
          INTO rec_c_frais;

         EXIT WHEN c_frais%NOTFOUND;
         --
         g_trav_type_risque := 3;
         g_trav_risque := rec_c_frais.risque;
         g_trav_mt_affec := rec_c_frais.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('FRAIS_GAR', -rec_c_frais.risque),
                       1,
                       17
                      )
            || ' ECH '
            || TO_CHAR (i_numquit);
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_frais;
   END p_sel_emis_frais_gar;

--
-- Traitement des commissions sur garanties emises
--
   PROCEDURE p_sel_emis_comm (
      i_numquit   IN   qttc_global.numquit%TYPE,
      i_risque    IN   NUMBER
   )
   IS
      CURSOR c_comm
      IS
         SELECT   SUM (NVL (qttc_comm.montant, 0)) mt_affec,
                  -type_comm risque
             FROM qttc_comm
            WHERE numquit = i_numquit
              AND f_nat_risque (qttc_comm.numfor) = i_risque
         GROUP BY -type_comm;

      rec_c_comm   c_comm%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_emis_comm';

      OPEN c_comm;

      LOOP
         FETCH c_comm
          INTO rec_c_comm;

         EXIT WHEN c_comm%NOTFOUND;
         --
         g_trav_type_risque := 2;
         g_trav_risque := rec_c_comm.risque;
         g_trav_mt_affec := rec_c_comm.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('TYPCOMM', -rec_c_comm.risque), 1,
                       17)
            || ' ECH '
            || TO_CHAR (i_numquit);
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_comm;
   END p_sel_emis_comm;

--
-- Traitement des cotisations ( codope 4 )
--
   PROCEDURE p_sel_cotis (i_idaffec IN qttc_affec.idaffec%TYPE)
   IS
      CURSOR c_cotis
      IS
         SELECT   SUM (NVL (qttc_affec.montant, 0)) mt_affec,
                  f_branche (qttc_affec.numfor) branche,
                  f_type_contrat (qttc_affec.numfor) type_contrat,
                  f_nat_risque (qttc_affec.numfor) risque,
                  TO_CHAR (qttc_global.debut, 'yyyy') exercice,
                  qttc_global.numquit, qttc_global.debut, qttc_global.numgar
             FROM qttc_global, qttc_affec
            WHERE qttc_global.debut BETWEEN NVL (g_deb_eche,
                                                 qttc_global.debut
                                                )
                                        AND NVL (g_fin_eche,
                                                 NVL (g_deb_eche,
                                                      qttc_global.debut
                                                     )
                                                )
              AND qttc_global.numquit = qttc_affec.numquit
              AND qttc_affec.idgar + 0 != 0
              AND qttc_affec.idaffec = i_idaffec
              AND f_type_contrat (qttc_affec.numfor)
                     BETWEEN NVL (g_deb_type_contrat,
                                  f_type_contrat (qttc_affec.numfor)
                                 )
                         AND NVL (g_fin_type_contrat,
                                  NVL (g_deb_type_contrat,
                                       f_type_contrat (qttc_affec.numfor)
                                      )
                                 )
              AND f_nat_risque (qttc_affec.numfor)
                     BETWEEN NVL (g_deb_risque,
                                  f_nat_risque (qttc_affec.numfor)
                                 )
                         AND NVL (g_fin_risque,
                                  NVL (g_deb_risque,
                                       f_nat_risque (qttc_affec.numfor)
                                      )
                                 )
         GROUP BY f_branche (qttc_affec.numfor),
                  f_type_contrat (qttc_affec.numfor),
                  f_nat_risque (qttc_affec.numfor),
                  TO_CHAR (qttc_global.debut, 'yyyy'),
                  qttc_global.numquit,
                  qttc_global.debut,
                  qttc_global.numgar;

      rec_c_cotis     c_cotis%ROWTYPE;
      l_der_numquit   NUMBER            := -1;
      l_signe         NUMBER            := 1;
      l_mt_taxe       NUMBER            := 0;
   BEGIN
      g_proc := 'P_SEL_cotis';

      OPEN c_cotis;

      LOOP
         FETCH c_cotis
          INTO rec_c_cotis;

         EXIT WHEN c_cotis%NOTFOUND;

         --
         -- Calcul des taxes
         BEGIN
            SELECT NVL (SUM (qttc_affec_tfc.montant), 0)
              INTO l_mt_taxe
              FROM qttc_affec_tfc
             WHERE tfc = 1
               AND idaffec = i_idaffec
               AND f_nat_risque (numfor) = rec_c_cotis.risque;
         END;

         --
         g_trav_branche := rec_c_cotis.branche;
         g_trav_type_contrat := rec_c_cotis.type_contrat;
         g_trav_risque := rec_c_cotis.risque;
         g_trav_type_risque := 0;
         g_trav_exercice := rec_c_cotis.exercice;
         g_trav_mt_affec := rec_c_cotis.mt_affec - l_mt_taxe;
         g_trav_numgar := rec_c_cotis.numgar;
         --
         l_signe := SIGN (rec_c_cotis.mt_affec);

         --
         IF (g_flag_annul)
         THEN
            g_trav_lib_piece :=
                  'REJET '
               || ' ECH '
               || d2e (rec_c_cotis.debut)
               || ' N° '
               || rec_c_cotis.numquit;
         ELSE
            g_trav_lib_piece :=
               SUBSTR (   'CT '
                       || TO_CHAR (rec_c_cotis.numgar)
                       || ' E. '
                       || d2e (rec_c_cotis.debut)
                       || ' N° '
                       || rec_c_cotis.numquit,
                       1,
                       32
                      );
         END IF;

         --
         p_ins_trav_treso;
         --
         p_sel_frais_gar (i_idaffec         => i_idaffec,
                          i_nat_risque      => rec_c_cotis.risque
                         );
         --
         p_sel_taxes (i_idaffec         => i_idaffec,
                      i_nat_risque      => rec_c_cotis.risque
                     );

         --
         IF (f_ctrl_one_shot (i_numquit      => rec_c_cotis.numquit,
                              i_idaffec      => i_idaffec
                             )
            )
         THEN
            p_sel_retro (i_numquit         => rec_c_cotis.numquit,
                         i_nat_risque      => rec_c_cotis.risque,
                         i_signe           => l_signe
                        );
         ELSE
            IF (   NOT f_ctrl_prelev (i_numquit      => rec_c_cotis.numquit,
                                      i_idaffec      => i_idaffec
                                     )
                OR l_signe = -1
               )
            THEN
               p_sel_comm_prelev (i_idaffec         => i_idaffec,
                                  i_nat_risque      => rec_c_cotis.risque,
								  i_branche		 	=> rec_c_cotis.branche
                                 );
            END IF;
         END IF;

         --
         p_sel_frais (i_idaffec => i_idaffec);
      --
      END LOOP;

      CLOSE c_cotis;
   END p_sel_cotis;

--
-- Traitement des commissions prelevees en une fois
--
   PROCEDURE p_sel_retro (
      i_numquit      IN   qttc_retro.numquit%TYPE,
      i_nat_risque   IN   NUMBER,
      i_signe        IN   NUMBER
   )
   IS
      CURSOR c_retro
      IS
         SELECT   SUM (-NVL (qttc_retro.montant, 0)) mt_affec,
                  i_nat_risque risque, type_comm type_retro, numquit
             FROM qttc_retro
            WHERE numquit = i_numquit
              AND prelev_revers = 1
              AND f_nat_risque (numfor) = i_nat_risque
         GROUP BY i_nat_risque, type_comm, numquit;

      rec_c_retro   c_retro%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_retro';

      OPEN c_retro;

      LOOP
         FETCH c_retro
          INTO rec_c_retro;

         EXIT WHEN c_retro%NOTFOUND;
         --
         g_trav_type_risque := 0;
         g_trav_risque := rec_c_retro.risque;
         g_trav_mt_affec := i_signe * rec_c_retro.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('TYPRETRO', rec_c_retro.type_retro),
                       1,
                       17
                      )
            || ' ECH '
            || TO_CHAR (rec_c_retro.numquit);
         g_trav_type_retro := rec_c_retro.type_retro;
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_retro;
   END p_sel_retro;

--
-- Traitement des commissions prelevees
--
   PROCEDURE p_sel_comm_prelev (
      i_idaffec      IN   qttc_affec_tfc.idaffec%TYPE,
      i_nat_risque   IN   NUMBER,
	  i_branche		 IN	  NUMBER
   )
   IS
      CURSOR c_comm
      IS
         SELECT   SUM (-NVL (qttc_affec_tfc.montant, 0)) mt_affec,
                  i_nat_risque risque, type_tfc type_retro, numquit
             FROM qttc_affec_tfc
            WHERE tfc = 5
              AND idaffec = i_idaffec
              AND prelev_revers = 1
              AND f_nat_risque (numfor) = i_nat_risque
			  AND f_branche (qttc_affec_tfc.numfor) = i_branche
         GROUP BY i_nat_risque, type_tfc, numquit;

      rec_c_comm   c_comm%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_comm_prelev';

      OPEN c_comm;

      LOOP
         FETCH c_comm
          INTO rec_c_comm;

         EXIT WHEN c_comm%NOTFOUND;
         --
         g_trav_type_risque := 0;
         g_trav_risque := rec_c_comm.risque;
         g_trav_mt_affec := rec_c_comm.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('TYPRETRO', rec_c_comm.type_retro),
                       1,
                       17
                      )
            || ' ECH '
            || TO_CHAR (rec_c_comm.numquit);
         g_trav_type_retro := rec_c_comm.type_retro;
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_comm;
   END p_sel_comm_prelev;

--
-- Traitement des frais sur garanties
--
   PROCEDURE p_sel_frais_gar (
      i_idaffec      IN   qttc_affec_tfc.idaffec%TYPE,
      i_nat_risque   IN   NUMBER
   )
   IS
      CURSOR c_frais
      IS
         SELECT   SUM (NVL (qttc_affec_tfc.montant, 0)) mt_affec,
                  -type_tfc risque, numquit
             FROM qttc_affec_tfc
            WHERE tfc = 3
              AND idaffec = i_idaffec
              AND f_nat_risque (numfor) = i_nat_risque
         GROUP BY -type_tfc, numquit;

      rec_c_frais   c_frais%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_frais_gar';

      OPEN c_frais;

      LOOP
         FETCH c_frais
          INTO rec_c_frais;

         EXIT WHEN c_frais%NOTFOUND;
         --
         g_trav_type_risque := 3;
         g_trav_risque := rec_c_frais.risque;
         g_trav_mt_affec := rec_c_frais.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('FRAIS_GAR', -rec_c_frais.risque),
                       1,
                       17
                      )
            || ' ECH '
            || TO_CHAR (rec_c_frais.numquit);
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_frais;
   END p_sel_frais_gar;

--
-- Traitement des taxes sur cotisations
--
   PROCEDURE p_sel_taxes (
      i_idaffec      IN   qttc_affec_tfc.idaffec%TYPE,
      i_nat_risque   IN   NUMBER
   )
   IS
      CURSOR c_taxe
      IS
         SELECT   SUM (NVL (qttc_affec_tfc.montant, 0)) mt_affec,
                  -type_tfc risque, numquit
             FROM qttc_affec_tfc
            WHERE tfc = 1
              AND idaffec = i_idaffec
              AND f_nat_risque (numfor) = i_nat_risque
         GROUP BY -type_tfc, numquit;

      rec_c_taxe   c_taxe%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_taxe';

      OPEN c_taxe;

      LOOP
         FETCH c_taxe
          INTO rec_c_taxe;

         EXIT WHEN c_taxe%NOTFOUND;
         --
         g_trav_type_risque := 1;
         g_trav_risque := rec_c_taxe.risque;
         g_trav_mt_affec := rec_c_taxe.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('TYPTAX', -rec_c_taxe.risque), 1,
                       17)
            || ' ECH '
            || TO_CHAR (rec_c_taxe.numquit);
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_taxe;
   END p_sel_taxes;

--
-- Traitement des frais sur cotisations
--
   PROCEDURE p_sel_frais (i_idaffec IN qttc_affec_tfc.idaffec%TYPE)
   IS
      CURSOR c_frais
      IS
         SELECT   SUM (NVL (qttc_affec_tfc.montant, 0)) mt_affec,
                  -type_tfc risque, numquit
             FROM qttc_affec_tfc
            WHERE qttc_affec_tfc.tfc = 4
              AND qttc_affec_tfc.idaffec = i_idaffec
         GROUP BY -type_tfc, numquit;

      rec_c_frais   c_frais%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_frais';

      OPEN c_frais;

      LOOP
         FETCH c_frais
          INTO rec_c_frais;

         EXIT WHEN c_frais%NOTFOUND;
         --
         g_trav_branche := -1;
         g_trav_type_risque := 4;
         g_trav_risque := rec_c_frais.risque;
         g_trav_mt_affec := rec_c_frais.mt_affec;
         g_trav_lib_piece :=
               SUBSTR (pk_libelle.f_lib ('TYPFRAIS', -rec_c_frais.risque),
                       1,
                       17
                      )
            || ' ECH '
            || TO_CHAR (rec_c_frais.numquit);
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_frais;
   END p_sel_frais;

--
-- Traitement des retrocessions ( codope 16 )
--@)
   PROCEDURE p_sel_retro (i_idrevers IN retrocession.idrevers%TYPE)
   IS
      CURSOR c_retro
      IS
         SELECT   SUM (NVL (qttc_affec_tfc.montant, 0)) mt_affec,
                  f_branche (qttc_affec_tfc.numfor) branche,
                  f_type_contrat (qttc_affec_tfc.numfor) type_contrat,
                  f_nat_risque (qttc_affec_tfc.numfor) risque,
                  TO_CHAR (qttc_global.debut, 'yyyy') exercice
             FROM qttc_global, qttc_affec_tfc
            WHERE qttc_global.numquit = qttc_affec_tfc.numquit
              AND qttc_affec_tfc.idrevers = i_idrevers
              AND qttc_affec_tfc.tfc = 5
              AND f_type_contrat (qttc_affec_tfc.numfor)
                     BETWEEN NVL (g_deb_type_contrat,
                                  f_type_contrat (qttc_affec_tfc.numfor)
                                 )
                         AND NVL (g_fin_type_contrat,
                                  NVL (g_deb_type_contrat,
                                       f_type_contrat (qttc_affec_tfc.numfor)
                                      )
                                 )
              AND f_nat_risque (qttc_affec_tfc.numfor)
                     BETWEEN NVL (g_deb_risque,
                                  f_nat_risque (qttc_affec_tfc.numfor)
                                 )
                         AND NVL (g_fin_risque,
                                  NVL (g_deb_risque,
                                       f_nat_risque (qttc_affec_tfc.numfor)
                                      )
                                 )
         GROUP BY f_branche (qttc_affec_tfc.numfor),
                  f_type_contrat (qttc_affec_tfc.numfor),
                  f_nat_risque (qttc_affec_tfc.numfor),
                  TO_CHAR (qttc_global.debut, 'yyyy');

      rec_c_retro   c_retro%ROWTYPE;
      l_prorata     NUMBER            := 1;
      l_tot_affec   NUMBER            := 0;
   BEGIN
      g_proc := 'P_SEL_retro';

--
-- Si remboursement indu partiel on proratise
--
      SELECT NVL (SUM (qttc_affec_tfc.montant), 0)
        INTO l_tot_affec
        FROM qttc_affec_tfc
       WHERE qttc_affec_tfc.idrevers = i_idrevers AND qttc_affec_tfc.tfc = 5;

--
      IF (g_etendue = 1 AND l_tot_affec != 0)
      THEN
         l_prorata := LEAST (g_trav_mt_regl, l_tot_affec) / l_tot_affec;

         IF (l_prorata = 1)
         THEN
            l_prorata := -1;
         END IF;
      END IF;

--
      IF (g_flag_test > 0)
      THEN
         g_msg_adm :=
               'Etendue '
            || TO_CHAR (g_etendue)
            || ' Tot_affec '
            || TO_CHAR (l_tot_affec)
            || ' Prorata '
            || TO_CHAR (l_prorata);
         p_ins_journal;
         COMMIT;
      END IF;

--
      OPEN c_retro;

      LOOP
         FETCH c_retro
          INTO rec_c_retro;

         EXIT WHEN c_retro%NOTFOUND;

         --
         IF (g_etendue = 1 AND g_affectation < ABS (l_tot_affec))
         THEN
            l_prorata := g_affectation / l_tot_affec;
         END IF;

         --
         g_trav_branche := rec_c_retro.branche;
         g_trav_type_contrat := rec_c_retro.type_contrat;
         g_trav_risque := rec_c_retro.risque;
         g_trav_exercice := rec_c_retro.exercice;
         g_trav_mt_affec := l_prorata * rec_c_retro.mt_affec;
         g_trav_lib_piece := 'Bx retrocession ' || TO_CHAR (i_idrevers);
         g_trav_numgar := NULL;
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_retro;
   END p_sel_retro;

--
-- Traitement des retrocessions (ventilation par type)
--
   PROCEDURE p_sel_type_retro (i_idrevers IN retrocession.idrevers%TYPE)
   IS
      CURSOR c_retro
      IS
         SELECT   SUM (NVL (qttc_affec_tfc.montant, 0)) mt_affec,
                  f_branche (qttc_affec_tfc.numfor) branche,
                  f_type_contrat (qttc_affec_tfc.numfor) type_contrat,
                  f_nat_risque (qttc_affec_tfc.numfor) risque,
                  TO_CHAR (qttc_global.debut, 'yyyy') exercice,
                  qttc_affec_tfc.type_tfc type_retro
             FROM qttc_global, qttc_affec_tfc
            WHERE qttc_global.numquit = qttc_affec_tfc.numquit
              AND qttc_affec_tfc.idrevers = i_idrevers
              AND qttc_affec_tfc.tfc + 0 = 5
              AND f_type_contrat (qttc_affec_tfc.numfor)
                     BETWEEN NVL (g_deb_type_contrat,
                                  f_type_contrat (qttc_affec_tfc.numfor)
                                 )
                         AND NVL (g_fin_type_contrat,
                                  NVL (g_deb_type_contrat,
                                       f_type_contrat (qttc_affec_tfc.numfor)
                                      )
                                 )
              AND f_nat_risque (qttc_affec_tfc.numfor)
                     BETWEEN NVL (g_deb_risque,
                                  f_nat_risque (qttc_affec_tfc.numfor)
                                 )
                         AND NVL (g_fin_risque,
                                  NVL (g_deb_risque,
                                       f_nat_risque (qttc_affec_tfc.numfor)
                                      )
                                 )
         GROUP BY f_branche (qttc_affec_tfc.numfor),
                  f_type_contrat (qttc_affec_tfc.numfor),
                  f_nat_risque (qttc_affec_tfc.numfor),
                  TO_CHAR (qttc_global.debut, 'yyyy'),
                  qttc_affec_tfc.type_tfc;

      rec_c_retro   c_retro%ROWTYPE;
      l_prorata     NUMBER            := 1;
      l_tot_affec   NUMBER            := 0;
   BEGIN
      g_proc := 'P_SEL_type_retro';

--
-- Si remboursement indu partiel on proratise
--
      SELECT NVL (SUM (qttc_affec_tfc.montant), 0)
        INTO l_tot_affec
        FROM qttc_affec_tfc
       WHERE qttc_affec_tfc.idrevers = i_idrevers AND qttc_affec_tfc.tfc = 5;

--
      IF (g_etendue = 1 AND l_tot_affec != 0)
      THEN
         l_prorata := LEAST (g_trav_mt_regl, l_tot_affec) / l_tot_affec;

         IF (l_prorata = 1)
         THEN
            l_prorata := -1;
         END IF;
      END IF;

--
      OPEN c_retro;

      LOOP
         FETCH c_retro
          INTO rec_c_retro;

         EXIT WHEN c_retro%NOTFOUND;

         --
         IF (g_etendue = 1 AND g_affectation < ABS (l_tot_affec))
         THEN
            l_prorata := g_affectation / l_tot_affec;
         END IF;

         --
         g_trav_branche := rec_c_retro.branche;
         g_trav_type_contrat := rec_c_retro.type_contrat;
         g_trav_risque := rec_c_retro.risque;
         g_trav_exercice := rec_c_retro.exercice;
         g_trav_mt_affec := l_prorata * rec_c_retro.mt_affec;
         g_trav_lib_piece := 'Bx retrocession ' || TO_CHAR (i_idrevers);
         g_trav_type_retro := rec_c_retro.type_retro;
         g_trav_numgar := NULL;
         --
         p_ins_trav_treso;
      --
      END LOOP;

      CLOSE c_retro;
   END p_sel_type_retro;

--
-- Traitement des indus compte_tiers
--
   PROCEDURE p_sel_indu (i_numencaismt IN encaismt.numencaismt%TYPE)
   IS
      CURSOR c_indu
      IS
         SELECT v_compte_client.codope, v_compte_client.datope,
                v_compte_client.montant, compte_tiers.cle
           FROM v_compte_client, compensation, compte_tiers
          WHERE v_compte_client.numencaismt = i_numencaismt
            AND v_compte_client.datope BETWEEN g_debut AND g_fin
            AND v_compte_client.codope + 0 IN (2, 14, 16)
            AND compte_tiers.idmvt = compensation.idmvt
            AND compensation.idcomp = v_compte_client.idaffec;

      rec_c_indu   c_indu%ROWTYPE;
   BEGIN
      g_proc := 'P_SEL_indu';

      OPEN c_indu;

      LOOP
         FETCH c_indu
          INTO rec_c_indu;

         EXIT WHEN c_indu%NOTFOUND;
         --
         g_trav_codope := rec_c_indu.codope;
         g_trav_date_affec := rec_c_indu.datope;
         g_affectation := rec_c_indu.montant;

         --
         IF (rec_c_indu.codope = 14)
         THEN
            p_sel_sante (i_numdec => rec_c_indu.cle);
         ELSIF (rec_c_indu.codope = 16)
         THEN
            p_sel_retro (i_idrevers => rec_c_indu.cle);
         ELSIF (rec_c_indu.codope = 2)
         THEN
            g_trav_codope := 17;
            p_sel_prev (i_numdec => rec_c_indu.cle);
         END IF;
      END LOOP;
   END p_sel_indu;

--
-- Retourne le libelle de la branche
--
   PROCEDURE p_sel_branche (
      i_branche   IN       NUMBER,
      o_libelle   OUT      libelle.libelle%TYPE
   )
   IS
      CURSOR c_branche
      IS
         SELECT libelle
           FROM def_grp_libelle
          WHERE mnemo = 'CMCR' AND code_groupe = i_branche;
   BEGIN
      g_proc := 'P_SEL_branche';

      OPEN c_branche;

      FETCH c_branche
       INTO o_libelle;

      IF (c_branche%NOTFOUND)
      THEN
         o_libelle := 'Indéterminée';
      END IF;

      CLOSE c_branche;
   END p_sel_branche;

--
-- Suppression de trav_treso
--
   PROCEDURE p_del_trav_treso
   IS
   BEGIN
      DELETE      trav_treso;
   END p_del_trav_treso;

--
-- Insertion dans trav_treso
--
   PROCEDURE p_ins_trav_treso
   IS
   BEGIN
      g_proc := 'P_INS_trav_treso';

--
      IF (g_flag_test > 0)
      THEN
         g_msg_adm :=
               'Codope '
            || g_trav_codope
            || ' Branche '
            || g_trav_branche
            || ' Contrat '
            || g_trav_type_contrat
            || ' Risque '
            || g_trav_risque
            || ' Exercice '
            || g_trav_exercice;
         p_ins_journal;
         COMMIT;
         g_msg_adm :=
               'Idpiece '
            || g_trav_idpiece
            || ' Dt_piece '
            || g_trav_date_piece
            || ' Dt_affec '
            || g_trav_date_affec
            || ' Mregl '
            || g_trav_mregl;
         p_ins_journal;
         COMMIT;
         g_msg_adm :=
               ' Tiers '
            || g_trav_numtiers
            || ' Mt_regl '
            || g_trav_mt_regl
            || ' Mt_affec '
            || g_trav_mt_affec
            || ' Compte '
            || SUBSTR (g_trav_libcompte, 1, 40)
            || ' numgar '
            || g_trav_numgar;
         p_ins_journal;
         COMMIT;
      END IF;

-- G_flag_test := 1;
--
      INSERT INTO trav_treso
                  (codope, branche, type_contrat,
                   risque, exercice, idpiece,
                   date_piece, date_affec, mregl,
                   numtiers, mt_regl,
                   mt_affec,
                   refpiece,
                   lib_piece,
                   type_risque,
                   refremise, type_retro,
                   numgar, libcompte
                  )
           VALUES (g_trav_codope, g_trav_branche, g_trav_type_contrat,
                   g_trav_risque, g_trav_exercice, g_trav_idpiece,
                   g_trav_date_piece, g_trav_date_affec, g_trav_mregl,
                   g_trav_numtiers, g_trav_signe * g_trav_mt_regl,
                   g_trav_signe * g_trav_mt_affec,
                   SUBSTR (g_trav_refpiece, 1, 7),
                   SUBSTR (g_trav_lib_piece, 1, 32),
                   NVL (g_trav_type_risque, 0),
                   SUBSTR (g_trav_refremise, 1, 10), g_trav_type_retro,
                   g_trav_numgar, SUBSTR (g_trav_libcompte, 1, 40)
                  );
--
      COMMIT;
-- JBO : 23/11/2009 : Ajout de la gestion d erreurs lors de l insertion dans TRAV_TRESO
   EXCEPTION
     WHEN OTHERS THEN
       g_niv_msg := 0;
       g_msg_adm := f_centre ('Erreur procedure PK_EXTRACTION, ' || g_proc || ' : ', 78);
       p_ins_journal;
       g_msg_adm :=TO_CHAR (SQLCODE) || '-'|| SUBSTR (SQLERRM (SQLCODE), 1, 128);
       p_ins_journal;
--
   END p_ins_trav_treso;

--
-- Insertion dans journal_adm
--
   PROCEDURE p_ins_journal
   IS
   BEGIN
      g_idligne := g_idligne + 1;
      pk_trace.p_ins_journal_adm (i_nom_traitement      => g_proc,
                                  i_session             => g_session,
                                  i_niv_msg             => g_niv_msg,
                                  i_msg_adm             => g_msg_adm,
                                  i_idligne             => g_idligne
                                 );
   END;
--                                                                              ------------------------------------ Fin des corps des procedures privees --
END;
/
