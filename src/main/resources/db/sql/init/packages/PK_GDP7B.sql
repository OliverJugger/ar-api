CREATE OR REPLACE PACKAGE ARTHUS.PK_GDP7B
AS
  /*===========================================================================*/
  /* Vue          : PACKAGE PK_GDP7B                                           */
  /* Domaine      : Prestation Prévoyance                                      */
  /* Version      : V1.0                                                       */
  /* Auteur       : Arthus                                                     */
  /* Création     : DD/MM/AAAA                                                 */
  /* Description  : Génération bordereaux de Demandes remboursement prévoyance */
  /*===========================================================================*/
  /* Evolution    :                                                            */
  /* Auteur       :                                                            */
  /* Date         :                                                            */
  /* Commentaire  :                                                            */
  /*===========================================================================*/
  /* Correction   : PHA / 24/01/2011 / Prise en compte des indus (2ème union)  */
  /*              : dans le CURSOR c_sel_dcpt, les montants de v_histo_calcul  */
  /*              : sont déjà signés                                           */
  /*===========================================================================*/
  /* Correction   : JBO / 14/05/2013 / Mantis 4062 : Initialisation de la      */
  /*                globale :  g_init := FALSE; et mise en commentaire du 2eme */
  /*                appel de la procédure p_select_numdcptcie dans la          */
  /*                procédure p_pied_select_pmtint                             */
  /*===========================================================================*/
  /* Evolution    : FNI / 13/02/2014 / Projet Prestations prévoyance GEREP     */
  /*                p_insert_dcptcie : Insertion dans la table prévoyance :    */
  /*                DCPTCIE_PREV_DETAIL pour une meilleure gestion             */
  /*                  des décomptes et de leurs annulation                     */
  /*===========================================================================*/
  /* Correction   : SDA  08/01/2015 / Mantis 4753                              */
  /*                Doublon indusdans bordereau                                */
  /*===========================================================================*/
  /* Correction   : ABO / Mantis 4559 : Initialisation de la                   */
  /*                globale :  g_numdcptcie := NULL; et                        */
  /*                appel de la procédure p_select_numdcptcie dans la          */
  /*                procédure p_pied_select_pmtint  : regression M4062         */
  /*===========================================================================*/
  /* Correction   : PHA / Mantis 4822 : Gestion annulation                     */
  /*===========================================================================*/
  /* Correction   : PHA / Mantis 4574 : Gestion unicité numdcptcie             */
  /*                      Mantis 4987 : Anomalies Bdx fin mois en prévoyance   */
  /*===========================================================================*/

  PROCEDURE p_gdp7b(
      i_deb_numsoc IN vs_grnts.numinterm%TYPE DEFAULT NULL,
      i_fin_numsoc IN vs_grnts.numinterm%TYPE DEFAULT NULL,
      i_deb_numorg IN vs_grnts.numorg%TYPE DEFAULT NULL,
      i_fin_numorg IN vs_grnts.numorg%TYPE DEFAULT NULL,
      i_deb_refcie IN vs_grnts.refcie_chapeau%TYPE DEFAULT NULL,
      i_fin_refcie IN vs_grnts.refcie_chapeau%TYPE DEFAULT NULL,
      i_deb_numgar IN vs_grnts.numgar%TYPE DEFAULT NULL,
      i_fin_numgar IN vs_grnts.numgar%TYPE DEFAULT NULL,
      i_deb_datbut IN compte_client.datope%TYPE DEFAULT NULL,
      i_fin_datbut IN compte_client.datope%TYPE DEFAULT NULL,
      i_param1     IN NUMBER DEFAULT 0,
      i_session    IN NUMBER DEFAULT 1,
      i_niv_msg    IN NUMBER DEFAULT 1,
      i_pause      IN NUMBER DEFAULT 0,
      o_found OUT NUMBER,
      o_erreur OUT VARCHAR2 );
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

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_GDP7B"
AS
  /*===========================================================================*/
  /* Vue          : PACKAGE PK_GDP7B                                           */
  /* Domaine      : Prestation Prévoyance                                      */
  /* Version      : V1.0                                                       */
  /* Auteur       : Arthus                                                     */
  /* Création     : DD/MM/AAAA                                                 */
  /* Description  : Génération bordereaux de Demandes remboursement prévoyance */
  /*===========================================================================*/
  /* Evolution    :                                                            */
  /* Auteur       :                                                            */
  /* Date         :                                                            */
  /* Commentaire  :                                                            */
  /*===========================================================================*/
  /* Correction   : PHA / 24/01/2011 / Prise en compte des indus (2ème union)  */
  /*              : dans le CURSOR c_sel_dcpt, les montants de v_histo_calcul  */
  /*              : sont déjà signés                                           */
  /*===========================================================================*/
  /* Correction   : JBO / 14/05/2013 / Mantis 4062 : Initialisation de la      */
  /*                globale :  g_init := FALSE; et mise en commentaire du 2eme */
  /*                appel de la procédure p_select_numdcptcie dans la          */
  /*                procédure p_pied_select_pmtint                             */
  /*===========================================================================*/
  /* Evolution    : FNI / 13/02/2014 / Projet Prestations prévoyance GEREP     */
  /*                p_insert_dcptcie : Insertion dans la table prévoyance :    */
  /*                DCPTCIE_PREV_DETAIL pour une meilleure gestion             */
  /*                  des décomptes et de leurs annulation                     */
  /*===========================================================================*/
  /* Correction   : SDA / 08/01/2015 / Mantis 4753 : Initialisation de la      */
  /*                Doublon indus dans bordereau                               */
  /*===========================================================================*/
  /* Correction   : ABO / Mantis 4559 : Initialisation de la                   */
  /*                globale :  g_numdcptcie := NULL; et                        */
  /*                appel de la procédure p_select_numdcptcie dans la          */
  /*                procédure p_pied_select_pmtint  : regression M4062         */
  /*===========================================================================*/
  /* Correction   : PHA / Mantis 4822 : Gestion annulation                     */
  /*                pour décaissement annulé, voir par la suite pour récupérer */
  /*                les infos depuis DCPTCIE_PREV_DETAIL                       */
  /*===========================================================================*/
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
PROCEDURE p_corps_select_pmtint;
  --
PROCEDURE p_entete_select_pmtint;
  --
PROCEDURE p_pied_select_pmtint;
PROCEDURE p_suite1;
PROCEDURE p_suite2;
  --
PROCEDURE p_select_numdcptcie;
  --
PROCEDURE p_insert_dcptcie;
  --
PROCEDURE p_update_pmtint;
  --
PROCEDURE p_ins_journal;
  --
PROCEDURE p_fin_traitement;
  --
  -- ----------------------------- Fin des declarations des procedures privees --
  -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
  -- Aucune
  -- ---------------------------------- Fin des corps des procedures publiques --
  --
  -- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
  -- Aucune
  -- ------------------------------------ Fin des corps des procedures privees --
  -- Variables globales privées
  --
  g_numdcptcie  NUMBER := 1;
  g_codope_cie  NUMBER := 12;
  g_codope_mala NUMBER := 1;
  g_codope_prev NUMBER := 2;
  --
  -- parametres du traitement
  g_numsoc_deb vs_grnts.numinterm%TYPE;
  g_numsoc_fin vs_grnts.numinterm%TYPE;
  g_numorg_deb vs_grnts.numorg%TYPE;
  g_numorg_fin vs_grnts.numorg%TYPE;
  g_refcie_deb vs_grnts.refcie_chapeau%TYPE;
  g_refcie_fin vs_grnts.refcie_chapeau%TYPE;
  g_numgar_deb vs_grnts.numgar%TYPE;
  g_numgar_fin vs_grnts.numgar%TYPE;
  g_datbut_deb compte_client.datope%TYPE;
  g_datbut_fin compte_client.datope%TYPE;
  g_param1 NUMBER;
  -- variables traitement
  g_init BOOLEAN := FALSE;
  g_numsoc vs_grnts.numinterm%TYPE;
  g_numorg vs_grnts.numorg%TYPE;
  g_monnaie dcpt.monnaie%TYPE;
  g_montant_d dcpt.montant_d%TYPE;
  g_monnaie_d dcpt.monnaie_d%TYPE;
  g_montant dcpt.montant%TYPE;
  g_montant_total dcpt.montant%TYPE;
  g_mnt_tot_d dcpt.montant%TYPE;
  g_idpmtint dcpt.numdec%TYPE;
  g_idpmt    decaismt.numdecaismt%TYPE;
  g_pre_mal_prev NUMBER;
  g_pre_numsoc vs_grnts.numinterm%TYPE;
  g_pre_numorg vs_grnts.numorg%TYPE;
  g_pre_idpmtint dcpt.numdec%TYPE;
  --
  -- Flag de commit ou rollback a retourner a Forms
  g_commit      BOOLEAN := FALSE;
  g_rollback    BOOLEAN := FALSE;
  g_auto_valide BOOLEAN := FALSE;
  --
  g_flag_test NUMBER;
  g_proc      VARCHAR2 (80);
  -- Variables de P_INS_journal
  g_nom_traitement CONSTANT journal_adm.nom_traitement%TYPE DEFAULT 'pk_gdp7b';
  g_msg_adm journal_adm.msg_adm%TYPE;
  g_session journal_adm.id_session%TYPE DEFAULT 1;
  g_niv_msg journal_adm.niv_msg%TYPE := 1;
  g_max_msg journal_adm.niv_msg%TYPE := 1;
  g_idligne journal_adm.idligne%TYPE := 0;
  g_erreur journal_adm.msg_adm%TYPE;
  g_rowcount NUMBER                   := 0;
  g_numutil utilisateurs.numutil%TYPE := f_numutil;
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
  -- CTT 31/03/2005
  CURSOR c_sel_dcpt
  IS
  -- prestation
    SELECT DISTINCT vs_grnts.numinterm,
      f_numorg (gar.numass) numorg,
      SUM (v_histo_calcul.montant_remb) montant,
      SUM (v_histo_calcul.montant_remb_d) montant_d,
      v_histo_calcul.monnaie,
      v_histo_calcul.monnaie_d,
      decompte_prev.numdec,
      0 numdecaismt
    FROM gar,
      v_histo_calcul,
      vs_grnts,
      adhe_cntrt,
      decaismt decaismt_prest,
      affectation affectation_prest,
      decompte_prev
    WHERE vs_grnts.numinterm BETWEEN NVL (g_numsoc_deb, vs_grnts.numinterm ) AND NVL (g_numsoc_fin, NVL (g_numsoc_deb, vs_grnts.numinterm ) )
    AND f_numorg (gar.numass) BETWEEN NVL (g_numorg_deb, f_numorg (gar.numass) ) AND NVL (g_numorg_fin, NVL (g_numorg_deb, f_numorg(gar.numass) ) )
    AND vs_grnts.refcie_chapeau
      || '-' BETWEEN NVL (g_refcie_deb, vs_grnts.refcie_chapeau
      || '-' )
    AND NVL (g_refcie_fin, NVL (g_refcie_deb, vs_grnts.refcie_chapeau
      || '-' ) )
    AND vs_grnts.numgar BETWEEN NVL (g_numgar_deb, vs_grnts.numgar ) AND NVL (g_numgar_fin, NVL (g_numgar_deb, vs_grnts.numgar ) )
    AND gar.numfor                 = v_histo_calcul.numfor
    AND v_histo_calcul.numdec      = decompte_prev.numdec
    AND vs_grnts.numgar            = adhe_cntrt.numgar
    AND adhe_cntrt.idadhesion      = decompte_prev.idadhesion
    AND decaismt_prest.flagpay + 0 = 1
    AND decaismt_prest.datpay     <= g_datbut_deb
    AND decaismt_prest.numdecaismt = affectation_prest.numdecaismt
    AND affectation_prest.codope   = g_codope_prev
    AND affectation_prest.numaffec = decompte_prev.numdec
    AND decompte_prev.numdcptcie   = 0
    GROUP BY vs_grnts.numinterm,
      f_numorg (gar.numass),
      v_histo_calcul.monnaie,
      v_histo_calcul.monnaie_d,
      decompte_prev.numdec
  UNION ALL
  -- indu
  SELECT DISTINCT vs_grnts.numinterm,
    f_numorg (gar.numass) numorg,
    SUM (v_histo_calcul.montant_remb) montant,
    SUM (v_histo_calcul.montant_remb_d) montant_d,
    v_histo_calcul.monnaie,
    v_histo_calcul.monnaie_d,
    decompte_prev.numdec,
    0 numdecaismt
  FROM decompte_prev,
    compte_client,
    encaismt,
    affectation affectation_prest,
    v_histo_calcul,
    gar,
    adhe_cntrt,
    vs_grnts
  WHERE decompte_prev.numdcptcie = 0
  AND adhe_cntrt.numgar          = vs_grnts.numgar
  AND adhe_cntrt.idadhesion      = decompte_prev.idadhesion
  AND decompte_prev.numdec       = affectation_prest.numaffec
  AND compte_client.numfact      = affectation_prest.numaffec
  AND encaismt.numencaismt       = compte_client.numencaismt
  AND v_histo_calcul.numdec      = decompte_prev.numdec
  AND v_histo_calcul.numfor      = gar.numfor
  AND compte_client.codope       = g_codope_prev
  AND affectation_prest.codope   = g_codope_prev
  AND encaismt.codope            = g_codope_prev
  AND vs_grnts.numinterm BETWEEN NVL (g_numsoc_deb, vs_grnts.numinterm ) AND NVL (g_numsoc_fin, NVL (g_numsoc_deb, vs_grnts.numinterm ) )
  AND f_numorg (gar.numass) BETWEEN NVL (g_numorg_deb, f_numorg (gar.numass) ) AND NVL (g_numorg_fin, NVL (g_numorg_deb, f_numorg (gar.numass) ) )
  AND vs_grnts.refcie_chapeau
    || '-' BETWEEN NVL (g_refcie_deb, vs_grnts.refcie_chapeau
    || '-' )
  AND NVL (g_refcie_fin, NVL (g_refcie_deb, vs_grnts.refcie_chapeau
    || '-' ) )
  AND vs_grnts.numgar BETWEEN NVL (g_numgar_deb, vs_grnts.numgar ) AND NVL (g_numgar_fin, NVL (g_numgar_deb, vs_grnts.numgar ) )
  AND TRUNC (compte_client.datope) <= g_datbut_deb
    --SDA Mantis 4753
  AND compte_client.idaffec =
    (SELECT MAX(cpt.idaffec)
    FROM compte_client cpt
    WHERE cpt.numfact       = affectation_prest.numaffec
    AND cpt.codope          = g_codope_prev
    AND TRUNC (cpt.datope) <= g_datbut_deb
    )
  GROUP BY vs_grnts.numinterm,
    f_numorg (gar.numass),
    v_histo_calcul.monnaie,
    v_histo_calcul.monnaie_d,
    decompte_prev.numdec
  UNION ALL
  -- annulation après intégration dans un précédent bdx
  SELECT vs_grnts.numinterm,
    DCPTCIE_PREV_DETAIL.numorg,
    - (DCPTCIE_PREV_DETAIL.montant_remb) montant,
    - (DCPTCIE_PREV_DETAIL.montant_remb_d) montant_d,
    decaismt.monnaie,
    decaismt.monnaie_d,
    0 numdec,
    - pnul.numdecaismt
  FROM decaismt,
    pnul,
    affectation_annul,
    DCPTCIE_PREV_DETAIL,
    adhe_cntrt,
    vs_grnts
  WHERE NVL(pnul.numdcptcie,0) = 0
    AND DCPTCIE_PREV_DETAIL.numdec      = affectation_annul.numaffec
    AND adhe_cntrt.numgar               = vs_grnts.numgar
    AND adhe_cntrt.idadhesion           = DCPTCIE_PREV_DETAIL.idadhesion
    AND affectation_annul.numdecaismt   = pnul.numdecaismt
    AND DCPTCIE_PREV_DETAIL.numdecaismt = pnul.numdecaismt
    AND affectation_annul.codope        = pnul.codope
    AND pnul.codope                     = g_codope_prev
    AND pnul.numdecaismt                = decaismt.numdecaismt
    AND vs_grnts.numinterm BETWEEN NVL (g_numsoc_deb, vs_grnts.numinterm ) AND NVL (g_numsoc_fin, NVL (g_numsoc_deb, vs_grnts.numinterm ) )
    AND DCPTCIE_PREV_DETAIL.numorg BETWEEN NVL (g_numorg_deb, DCPTCIE_PREV_DETAIL.numorg ) AND NVL (g_numorg_fin, NVL (g_numorg_deb, DCPTCIE_PREV_DETAIL.numorg ) )
    AND vs_grnts.refcie_chapeau
      || '-' BETWEEN NVL (g_refcie_deb, vs_grnts.refcie_chapeau
      || '-' )
    AND NVL (g_refcie_fin, NVL (g_refcie_deb, vs_grnts.refcie_chapeau
      || '-' ) )
    AND vs_grnts.numgar BETWEEN NVL (g_numgar_deb, vs_grnts.numgar ) AND NVL (g_numgar_fin, NVL (g_numgar_deb, vs_grnts.numgar ) )
    AND TRUNC(pnul.DATANNUL)  <= g_datbut_deb
    AND decaismt.flagpay + 0 = 1

  ORDER BY 1,
    2;
  --
  ------------------------------------------------------------------
  --
  -- Le corps des différentes procedures
  --
  ------------------------------------------------------------------
  --
  --
PROCEDURE p_gdp7b(
    i_deb_numsoc IN vs_grnts.numinterm%TYPE DEFAULT NULL,
    i_fin_numsoc IN vs_grnts.numinterm%TYPE DEFAULT NULL,
    i_deb_numorg IN vs_grnts.numorg%TYPE DEFAULT NULL,
    i_fin_numorg IN vs_grnts.numorg%TYPE DEFAULT NULL,
    i_deb_refcie IN vs_grnts.refcie_chapeau%TYPE DEFAULT NULL,
    i_fin_refcie IN vs_grnts.refcie_chapeau%TYPE DEFAULT NULL,
    i_deb_numgar IN vs_grnts.numgar%TYPE DEFAULT NULL,
    i_fin_numgar IN vs_grnts.numgar%TYPE DEFAULT NULL,
    i_deb_datbut IN compte_client.datope%TYPE DEFAULT NULL,
    i_fin_datbut IN compte_client.datope%TYPE DEFAULT NULL,
    i_param1     IN NUMBER DEFAULT 0,
    i_session    IN NUMBER DEFAULT 1,
    i_niv_msg    IN NUMBER DEFAULT 1,
    i_pause      IN NUMBER DEFAULT 0,
    o_found OUT NUMBER,
    o_erreur OUT VARCHAR2 )
IS
  r_sel_dcpt c_sel_dcpt%ROWTYPE;
BEGIN
  g_init := FALSE;
  --
  o_found  := 1;
  g_erreur := NULL;
  --
  g_numsoc_deb := i_deb_numsoc;
  g_numsoc_fin := i_fin_numsoc;
  g_numorg_deb := i_deb_numorg;
  g_numorg_fin := i_fin_numorg;
  g_refcie_deb := i_deb_refcie;
  g_refcie_fin := i_fin_refcie;
  g_numgar_deb := i_deb_numgar;
  g_numgar_fin := i_fin_numgar;
  g_datbut_deb := NVL(i_deb_datbut, SYSDATE);
  g_datbut_fin := NVL(i_fin_datbut, g_datbut_deb);
  g_param1     := i_param1;
  g_numdcptcie :=NULL; --M4559 régression du à la mantis 4062
  --
  g_max_msg := i_niv_msg;
  g_session := i_session;
  --G_idligne     := F_max_idligne(I_session => G_session);
  --
  --
  -- OUVERTURE du Curseur
  --
  -- IF NOT c_sel_dcpt%ISOPEN THEN
  --
  g_niv_msg := 1;
  g_msg_adm := 'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
  p_ins_journal;
  g_msg_adm := 'Paramètres <' || TO_CHAR (g_numsoc_deb) || '> <' || TO_CHAR (g_numsoc_fin) || '> <' || TO_CHAR (g_numorg_deb) || '> <' || TO_CHAR (g_numorg_fin) || '> <' || TO_CHAR (g_refcie_deb) || '> <' || TO_CHAR (g_refcie_fin) || '> <' || TO_CHAR (g_numgar_deb) || '> <' || TO_CHAR (g_numgar_fin) || '> <' || TO_CHAR (i_deb_datbut) || '> <' || TO_CHAR (i_fin_datbut) || '>';
  p_ins_journal;
  -- Fin ecriture dans le Journal
  --   OPEN c_sel_dcpt;
  --
  --      END IF;
  /*
  --
  -- LECTURE D'1 Ligne dans la table principale
  --
  FETCH c_sel_dcpt
  INTO r_sel_dcpt;
  */
  FOR r_sel_dcpt IN c_sel_dcpt
  LOOP
    --
    g_rowcount  := c_sel_dcpt%ROWCOUNT;
    o_found     := 1;
    g_numsoc    := r_sel_dcpt.numinterm;
    g_numorg    := r_sel_dcpt.numorg;
    g_idpmtint  := r_sel_dcpt.numdec;
    g_idpmt     := r_sel_dcpt.numdecaismt;
    g_montant   := r_sel_dcpt.montant;
    g_monnaie   := r_sel_dcpt.monnaie;
    g_montant_d := r_sel_dcpt.montant_d;
    g_monnaie_d := r_sel_dcpt.monnaie_d;
    IF g_init    = FALSE THEN
      g_init    := TRUE;
      p_entete_select_pmtint;
    END IF;
    --
    -- Détail du traitement
    p_corps_select_pmtint;
    g_montant_total := NVL(g_montant_total,0) + NVL(g_montant,0);
    g_mnt_tot_d     := NVL(g_mnt_tot_d,0)     + NVL(g_montant_d,0);
    --
  END LOOP;
  --
  -- FERMETURE du Curseur
  p_fin_traitement;
  o_erreur := g_erreur;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := 'pk_gdp7b - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  o_erreur  := SUBSTR (SQLERRM (SQLCODE), 1, 128);
  p_ins_journal;
  IF c_sel_dcpt%ISOPEN THEN
    CLOSE c_sel_dcpt;
  END IF;
END;
--
PROCEDURE p_corps_select_pmtint
IS
BEGIN
  IF g_numsoc = g_pre_numsoc THEN
    p_suite1;
  ELSE
    p_pied_select_pmtint;
    p_suite2;
  END IF;
END p_corps_select_pmtint;
--
PROCEDURE p_suite1
IS
BEGIN
  IF g_numorg <> g_pre_numorg THEN
    p_pied_select_pmtint;
  END IF;
  --
  p_suite2;
  --
END p_suite1;
--
PROCEDURE p_suite2
IS
BEGIN
  --
  p_update_pmtint;
END p_suite2;
--
PROCEDURE p_fin_traitement
IS
BEGIN
  p_pied_select_pmtint;
  --
  g_proc := 'P_fin_traitement';
  --
  g_niv_msg := 1;
  g_msg_adm := 'Nombre de lignes : <' || TO_CHAR (g_rowcount) || '>';
  p_ins_journal;
  g_msg_adm := 'Fin du traitement : ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
  p_ins_journal;
  -- Fin ecriture dans le Journal
  IF c_sel_dcpt%ISOPEN THEN
    CLOSE c_sel_dcpt;
  END IF;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END p_fin_traitement;
--
-------------------------------------------------------------------------------------------------------
--
PROCEDURE p_entete_select_pmtint
IS
BEGIN
  --
  g_pre_numsoc := g_numsoc;
  g_pre_numorg := g_numorg;
  p_select_numdcptcie;
END p_entete_select_pmtint;
--
PROCEDURE p_pied_select_pmtint
IS
BEGIN
  IF NVL(g_montant_total,0) > 0 THEN
    p_insert_dcptcie;
    p_select_numdcptcie;
  ELSE
    -- remettre à 0 numdcptcie pour prochain BDX
    UPDATE decompte_prev SET numdcptcie = 0 WHERE numdcptcie = g_numdcptcie;
    --
    UPDATE pnul SET numdcptcie = 0 WHERE numdcptcie = g_numdcptcie AND codope = 2;
    --
    g_montant_total := 0;
    g_mnt_tot_d     := 0;
  END IF;
  --
  g_pre_numsoc := g_numsoc;
  g_pre_numorg := g_numorg;
END p_pied_select_pmtint;
--
PROCEDURE p_select_numdcptcie
IS
BEGIN
  g_proc := 'select_numdcptcie';
  -- M0004574 PHA 08/10/2015
  SELECT NUMDCPTCIE.nextval INTO G_numdcptcie FROM dual;
  -- SELECT MAX (NVL (numdcptcie, 0)) + 1 INTO g_numdcptcie FROM dcptcie;
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  g_erreur  := g_msg_adm;
  p_ins_journal;
END p_select_numdcptcie;
--
/*===========================================================================*/
/* Evolution    : FNI / 13/02/2014 / Projet Prestations prévoyance GEREP     */
/*                p_insert_dcptcie : Insertion dans la table prévoyance :    */
/*                DCPTCIE_PREV_DETAIL pour une meilleure gestion             */
/*                  des décomptes et de leur annulation.                     */
/*                  Champs correspondants à la vue V_DCPTCIE                 */
/*                  A l'annulation, l'état est passé à 2 (Annulé)            */
/*===========================================================================*/
PROCEDURE p_insert_dcptcie
IS
BEGIN
  g_proc := 'insert_dcptcie';
  INSERT
  INTO dcptcie
    (
      numdcptcie,
      datcreat,
      datedeb,
      datefin,
      numsoc,
      numorg,
      TYPE,
      montant,
      monnaie,
      valide,
      numutil,
      montant_d,
      monnaie_d
    )
  SELECT NVL (g_numdcptcie, 1),
    TRUNC (SYSDATE),
    g_datbut_deb,
    NVL (g_datbut_fin, g_datbut_deb),
    g_pre_numsoc,
    g_pre_numorg,
    2,
    g_montant_total,
    g_monnaie,
    'N',
    g_numutil,
    g_mnt_tot_d,
    g_monnaie_d
  FROM DUAL;
  -- Insertion dans la table de bordereaux spécials prévoyance. La requête est presque identique à celle utilisée pour la vue V_DCPTCIE.
  -- Cette table permet une historisation des bordereaux de demande de remboursement des prestations prévoyance.
  INSERT
  INTO DCPTCIE_PREV_DETAIL
    (
      NUMDCPTCIE,
      NUMSOC,
      NUMORG,
      NOMORG,
      DATEDEB,
      DATEFIN,
      TYPE,
      EXERCICE,
      REFCIE_CHAPEAU,
      NUMDECAISMT,
      REFPMT,
      EDATPAY,
      NUMBENE,
      NOMBENE,
      REFCIE,
      NUMGAR,
      DATESURV,
      TYPDEDU,
      LIB_TYPE,
      NUMDEC,
      NOSIN,
      MONTANT_REMB,
      NUMCLI,
      NOMCLI,
      IDADHESION,
      NOMGAR,
      NUMFOR,
      ETAT,
      MONNAIE,
      MONNAIE_D,
      MONTANT_REMB_D
    )
    -- prestation
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    orgns.nom nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.type,
    TO_CHAR(sin.datesurv,'yyyy') exercice,
    contrat.refcie_chapeau,
    decaismt_prest.numdecaismt,
    decaismt_prest.refpmt,
    TO_CHAR(decaismt_prest.datpay,'dd/mm/yyyy') edatpay,
    decaismt_prest.numbene,
    indvs_bene.nom
    ||' '
    ||indvs_bene.prenom nombene,
    contrat.refcie,
    contrat.numgar,
    TO_CHAR(sin.datesurv,'dd/mm/yy') datesurv,
    -1 typdedu,
    'Prestations' lib_type,
    decompte_prev.numdec,
    sin.nosin nosin,
    v_histo_calcul.montant_remb,
    contrat.numcli,
    indvs_cli.nom
    ||' '
    ||indvs_cli.prenom nomcli,
    decompte_prev.idadhesion idadhesion,
    gar_cntrt.nomgar,
    v_histo_calcul.numfor,
    1,
    v_histo_calcul.monnaie,
    v_histo_calcul.monnaie_d,
    v_histo_calcul.montant_remb_d
  FROM dcptcie,
    contrat,
    adhe_cntrt,
    gar_cntrt,
    decaismt decaismt_prest,
    affectation affectation_prest,
    decompte_prev,
    v_histo_calcul,
    indvs indvs_bene,
    indvs indvs_cli,
    sin,
    orgns
  WHERE dcptcie.numdcptcie         = NVL (g_numdcptcie, 1)
    AND dcptcie.numdcptcie         = decompte_prev.numdcptcie
    AND dcptcie.type               = 2
    AND affectation_prest.numaffec = decompte_prev.numdec
    AND decaismt_prest.numdecaismt = affectation_prest.numdecaismt
    AND decaismt_prest.codope      = 2
    AND affectation_prest.codope   = 2
    AND indvs_bene.numindiv        = decaismt_prest.numbene
    AND indvs_cli.numindiv         = contrat.numcli
    AND contrat.numgar             = adhe_cntrt.numgar
    AND contrat.numgar             = gar_cntrt.numgar
    AND adhe_cntrt.idadhesion      = decompte_prev.idadhesion
    AND v_histo_calcul.numfor      = gar_cntrt.numfor
    AND v_histo_calcul.nosin       = sin.nosin
    AND v_histo_calcul.numdec      = decompte_prev.numdec
    AND orgns.numorg               = dcptcie.numorg
  UNION ALL
  -- indu - ABO 09/11/2021 on peut avoir plusieurs histo_calcul pour un même décompte => impact sum(compte_client)
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    orgns.nom nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.type,
    TO_CHAR(sntr_prev.survenance,'yyyy') exercice,
    contrat.refcie_chapeau,
    encaismt_prest.numencaismt,
    encaismt_prest.refpmt,
    TO_CHAR(encaismt_prest.datpay,'dd/mm/yyyy') edatpay,
    encaismt_prest.numcli,
    indvs_bene.nom
    ||' '
    ||indvs_bene.prenom nombene,
    contrat.refcie,
    contrat.numgar,
    TO_CHAR(sntr_prev.survenance,'dd/mm/yy') datesurv,
    -1 typdedu,
    'Indus de prestations' lib_type,
    affectation_prest.numaffec,
    sntr_prev.nosin nosin,
    - SUM(compte_client.montant) montant_remb,
    contrat.numcli,
    indvs_cli.nom
    ||' '
    ||indvs_cli.prenom nomcli,
    adhe_cntrt.idadhesion idadhesion,
    gar_cntrt.nomgar,
    DCPT_SIN.numfor,
    1,
    compte_client.monnaie,
    compte_client.monnaie_d,
    - SUM(compte_client.montant_d ) montant_remb_d
  FROM dcptcie,
    orgns,
    encaismt encaismt_prest,
    compte_client,
    affectation affectation_prest,
    gar_cntrt,
    contrat,
    adhe_cntrt,
    indvs indvs_bene,
    indvs indvs_cli,
    sntr_prev,
    ( SELECT MAX(v_histo_calcul.numfor) numfor,
              decompte_prev.idadhesion,
              decompte_prev.numdec,
              v_histo_calcul.nosin
    FROM  v_histo_calcul,  decompte_prev
    WHERE v_histo_calcul.numdec    = decompte_prev.numdec
    AND decompte_prev.numdcptcie   = NVL (g_numdcptcie, 1)
    GROUP BY decompte_prev.numdec,decompte_prev.idadhesion,v_histo_calcul.nosin
    ) DCPT_SIN
  WHERE dcptcie.numdcptcie         = NVL (g_numdcptcie, 1)
   AND dcptcie.type               = 2
    AND orgns.numorg               = dcptcie.numorg
    AND affectation_prest.numaffec = DCPT_SIN.numdec
    AND compte_client.numfact      = affectation_prest.numaffec
    AND encaismt_prest.numencaismt = compte_client.numencaismt
    AND affectation_prest.codope   = 2
    AND compte_client.codope       = 2
    AND encaismt_prest.codope      = 2
    AND DCPT_SIN.nosin             = sntr_prev.nosin
    AND DCPT_SIN.numfor            = gar_cntrt.numfor
    AND contrat.numgar            = gar_cntrt.numgar
    AND indvs_bene.numindiv        = encaismt_prest.numcli
    AND indvs_cli.numindiv         = contrat.numcli
    AND DCPT_SIN.idadhesion        = adhe_cntrt.idadhesion
    AND contrat.numgar             = adhe_cntrt.numgar
    GROUP BY
        dcptcie.numdcptcie,
        dcptcie.numsoc,
        dcptcie.numorg,
        orgns.nom,
        dcptcie.datedeb,
        dcptcie.datefin,
        dcptcie.type,
        sntr_prev.survenance,
        contrat.refcie_chapeau,
        encaismt_prest.numencaismt,
        encaismt_prest.refpmt,
        encaismt_prest.datpay,
        encaismt_prest.numcli,
        indvs_bene.nom,
        indvs_bene.prenom,
        contrat.refcie,
        contrat.numgar,
        affectation_prest.numaffec,
        sntr_prev.nosin,
        contrat.numcli,
        indvs_cli.nom,
        indvs_cli.prenom,
        adhe_cntrt.idadhesion,
        gar_cntrt.nomgar,
        DCPT_SIN.numfor,
        compte_client.monnaie,
        compte_client.monnaie_d
  UNION ALL
  -- annulation décompte/décaissement après intégration dans un précédent bdx
    SELECT
      dcptcie.numdcptcie,
      dcptcie.numsoc,
      dcptcie.numorg,
      DCPTCIE_PREV_DETAIL.nomorg nomorg,
      dcptcie.datedeb,
      dcptcie.datefin,
      DCPTCIE_PREV_DETAIL.TYPE,
      DCPTCIE_PREV_DETAIL.EXERCICE,
      DCPTCIE_PREV_DETAIL.REFCIE_CHAPEAU,
      DCPTCIE_PREV_DETAIL.NUMDECAISMT,
      DCPTCIE_PREV_DETAIL.REFPMT,
      TO_CHAR(pnul.datannul,'dd/mm/yyyy') EDATPAY,
      DCPTCIE_PREV_DETAIL.NUMBENE,
      DCPTCIE_PREV_DETAIL.NOMBENE,
      DCPTCIE_PREV_DETAIL.REFCIE,
      DCPTCIE_PREV_DETAIL.NUMGAR,
      DCPTCIE_PREV_DETAIL.DATESURV,
      DCPTCIE_PREV_DETAIL.TYPDEDU,
      'Annulation de prestation' LIB_TYPE,
      DCPTCIE_PREV_DETAIL.NUMDEC,
      DCPTCIE_PREV_DETAIL.NOSIN,
      - DCPTCIE_PREV_DETAIL.MONTANT_REMB,
      DCPTCIE_PREV_DETAIL.NUMCLI,
      DCPTCIE_PREV_DETAIL.NOMCLI,
      DCPTCIE_PREV_DETAIL.IDADHESION,
      DCPTCIE_PREV_DETAIL.NOMGAR,
      DCPTCIE_PREV_DETAIL.NUMFOR,
      DCPTCIE_PREV_DETAIL.ETAT,
      DCPTCIE_PREV_DETAIL.MONNAIE,
      DCPTCIE_PREV_DETAIL.MONNAIE_D,
      - DCPTCIE_PREV_DETAIL.MONTANT_REMB_D
      FROM DCPTCIE_PREV_DETAIL,
           pnul,
           affectation_annul,
           decaismt,
           dcptcie
      WHERE NVL(pnul.numdcptcie,0)        = NVL (g_numdcptcie, 1)
        AND DCPTCIE_PREV_DETAIL.numdec    = affectation_annul.numaffec
        AND affectation_annul.numdecaismt = pnul.numdecaismt
        AND DCPTCIE_PREV_DETAIL.numdecaismt = pnul.numdecaismt
        AND affectation_annul.codope      = pnul.codope
        AND pnul.codope                   = g_codope_prev
        AND pnul.numdecaismt              = decaismt.numdecaismt
        AND dcptcie.numdcptcie            = pnul.numdcptcie

      ;

  g_montant_total := 0;
  g_mnt_tot_d     := 0;
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  g_erreur  := g_msg_adm;
  p_ins_journal;
END p_insert_dcptcie;
--
--
PROCEDURE p_update_pmtint
IS
BEGIN
  g_proc := 'update_pmtint';
  IF g_idpmtint > 0 THEN
    UPDATE decompte_prev
    SET numdcptcie                 = NVL (g_numdcptcie, 1)
    WHERE decompte_prev.numdec     = g_idpmtint
      AND decompte_prev.numdcptcie = 0;
  ELSE
    UPDATE dcpt_prev_annul
    SET numdcptcie_annul             = NVL (g_numdcptcie, 1)
    WHERE dcpt_prev_annul.numdec     = -g_idpmtint
      AND dcpt_prev_annul.numdcptcie_annul = 0;
  END IF;
  IF g_idpmt < 0 THEN
    UPDATE pnul
    SET numdcptcie         = NVL (g_numdcptcie, 1)
    WHERE pnul.numdecaismt = -g_idpmt
      AND NVL(pnul.numdcptcie,0)  = 0
      AND pnul.codope = g_codope_prev;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  g_erreur  := g_msg_adm;
  p_ins_journal;
END p_update_pmtint;
-- FIN A MIGRER
-------------------------------------------------------------------------------------------------------
----------------------- Fin des procedures publiques ------------------
-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
PROCEDURE p_ins_journal
IS
  l_idligne NUMBER;
BEGIN
  IF (g_niv_msg  <= g_max_msg) THEN
    g_idligne    := g_idligne + 1;
    IF (g_niv_msg = 0) THEN
      l_idligne  := -1 * g_idligne;
    ELSE
      l_idligne := g_idligne;
    END IF;
    pk_trace.p_ins_journal_adm (i_nom_traitement => g_nom_traitement, i_session => g_session, i_niv_msg => g_niv_msg, i_msg_adm => g_msg_adm, i_idligne => l_idligne );
  END IF;
END p_ins_journal;
--
---------------- Fin des corps des procedures privees --
--
END;
/
