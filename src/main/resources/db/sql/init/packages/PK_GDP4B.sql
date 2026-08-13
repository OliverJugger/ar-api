CREATE OR REPLACE PACKAGE ARTHUS.PK_GDP4B
AS
/*===========================================================================  */
/* Package      : PK_GDP4B.sql                                                 */
/* Domaine      : decompte                                                     */
/* Version      : V1.0                                                         */
/* Auteur       :                                                              */
/* Création     :                                                              */
/* Description  :                                                              */
/*              :                                                              */
/*              :                                                              */
/*===========================================================================  */
/* Evolution    :                                                              */
/* Auteur       :                                                              */
/* Date         :                                                              */
/* Commentaire  :                                                              */
/*===========================================================================  */
/* Correction   : trigramme / date / commentaire                               */
/* SDA mise en place CAPRA                                                     */
/* vue V_REPARTITION_HISTO_DEST                                                */
/* fonction pour tuteur au niveau du decode                                    */
/*===========================================================================  */
PROCEDURE p_gdp4b(
    i_nosin_deb  IN VARCHAR2 DEFAULT NULL,
    i_nosin_fin  IN VARCHAR2 DEFAULT NULL,
    i_typcal_deb IN NUMBER DEFAULT NULL,
    i_typcal_fin IN NUMBER DEFAULT NULL,
    i_session    IN NUMBER DEFAULT 1,
    i_niv_msg    IN NUMBER DEFAULT 1,
    i_pause      IN NUMBER DEFAULT 0,
    o_found OUT NUMBER,
    o_erreur OUT VARCHAR2);

PROCEDURE p_gdp4b_date(
    i_nosin_deb  IN VARCHAR2 DEFAULT NULL,
    i_nosin_fin  IN VARCHAR2 DEFAULT NULL,
    i_typcal_deb IN NUMBER DEFAULT NULL,
    i_typcal_fin IN NUMBER DEFAULT NULL,
    i_deb IN DATE DEFAULT NULL,
    i_fin IN DATE DEFAULT NULL,
    i_session    IN NUMBER DEFAULT 1,
    i_niv_msg    IN NUMBER DEFAULT 1,
    i_pause      IN NUMBER DEFAULT 0,
    o_found OUT NUMBER,
    o_erreur OUT VARCHAR2);

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_GDP4B
AS

PROCEDURE p_traitement_principal;
PROCEDURE p_sel_sens;
PROCEDURE p_entete_decompte;
PROCEDURE p_corps_histo;
PROCEDURE p_pied_decompte;
PROCEDURE p_retention;
PROCEDURE p_pas_retention;
PROCEDURE p_pas_decaismt;
PROCEDURE p_annul_decompte;
PROCEDURE p_annul_decompte_dedu;
PROCEDURE p_sel_compte;
PROCEDURE p_sel_idrib;
PROCEDURE p_sel_modpmt;
PROCEDURE p_ins_decompte_prev;
PROCEDURE p_select_numdecaismt;
PROCEDURE p_insert_decaismt;
PROCEDURE p_insert_affectation;
PROCEDURE p_insert_compte_tiers;
PROCEDURE p_upd_histo_calcul;
PROCEDURE p_select_numdec;
PROCEDURE p_rech_modpmt;
PROCEDURE p_debut_traitement;
PROCEDURE p_fin_traitement;
PROCEDURE p_ins_journal;

  g_trait_entete VARCHAR2 (1);
  g_client       NUMBER (3);
  g_nosin_deb repartition.nosin%TYPE DEFAULT NULL;
  g_nosin_fin repartition.nosin%TYPE DEFAULT NULL;
  g_typcal_deb repartition.type_calc%TYPE;
  g_typcal_fin repartition.type_calc%TYPE;
  g_deb date;
  g_fin Date;
  g_nblig    NUMBER (5);
  g_niv_rupt NUMBER (2);

  g_numdecaismt decaismt.numdecaismt%TYPE;
  g_numdec histo_calcul.numdec%TYPE;
  g_numgar contrat.numgar%TYPE;
  g_numgar_old contrat.numgar%TYPE;
  g_nosin repartition.nosin%TYPE;
  g_nosin_old repartition.nosin%TYPE;
  g_idadhesion adhe_cntrt.idadhesion%TYPE;
  g_idadhesion_old adhe_cntrt.idadhesion%TYPE;
  g_idrepartition repartition.idrepartition%TYPE;
  g_numfor gar_prev.numfor%TYPE;
  g_numbene repartition_bene.numbene%TYPE;
  g_numbene_old repartition_bene.numbene%TYPE;
  g_numdest decaismt.numdest%TYPE;
  g_numdest_old decaismt.numdest%TYPE;
  g_numcli contrat.numcli%TYPE;
  g_montant         NUMBER (11, 2);
  g_montant_d       NUMBER (11, 2);
  g_montant_total   NUMBER (11, 2);
  g_montant_total_d NUMBER (11, 2);
  g_numcpte decaismt.numcpte%TYPE;
  g_numcpte_old decaismt.numcpte%TYPE;
  g_type_bene bene_gar.type_bene%TYPE;
  g_type_bene_old bene_gar.type_bene%TYPE;
  g_nom VARCHAR2 (60);
  g_monnaie decaismt.monnaie%TYPE;
  g_monnaie_d decaismt.monnaie%TYPE;
  g_monnaie_old decaismt.monnaie%TYPE;
  g_monnaie_old_d decaismt.monnaie%TYPE;
  g_datsai DATE;
  g_min_datsai DATE;
  g_nbpag     NUMBER (3);
  g_nbpag_old NUMBER (3);
  g_modpmt decaismt.modpmt%TYPE;
  g_modpmt_old decaismt.modpmt%TYPE;
  g_idrib rib_adhe.idrib%TYPE;
  g_idrib_old rib_adhe.idrib%TYPE;
  g_idcalcul histo_jours.idcalcul%TYPE;
  g_lidcalcul NUMBER (9);
  g_type_calc repartition.type_calc%TYPE;
  g_type_calc_old repartition.type_calc%TYPE;
  g_type_dest repartition_bene.type_dest%TYPE;
  g_type_dest_old repartition_bene.type_dest%TYPE;
  g_sens_ope           NUMBER (3);
  g_idrib_trouve       VARCHAR2 (1);
  g_bene_modpmt_trouve VARCHAR2 (1);
  -- Flag de commit ou rollback a retourner a Forms
  g_commit      BOOLEAN := FALSE;
  g_rollback    BOOLEAN := FALSE;
  g_auto_valide BOOLEAN := FALSE;
  --
  g_flag_test NUMBER;
  g_proc      VARCHAR2 (80);
  -- Variables de P_INS_journal
  g_nom_traitement CONSTANT journal_adm.nom_traitement%TYPE DEFAULT 'pk_gdp4b';
  g_msg_adm journal_adm.msg_adm%TYPE;
  g_session journal_adm.id_session%TYPE DEFAULT 1;
  g_niv_msg journal_adm.niv_msg%TYPE := 1;
  g_max_msg journal_adm.niv_msg%TYPE := 1;
  g_idligne journal_adm.idligne%TYPE := 0;
  g_erreur journal_adm.msg_adm%TYPE;
  -- G_niv_msg prend les Valeurs :
  -- 0 --> Message d'erreurs (Erreur ORACLE)
  -- 1 --> Message informatif(tout se passe bien)
  -- 2 et + Niveau de detail
  -- -------------------- Fin des variables globales privees --
  -- --------------------------------------------------------------------------
  --
  -- DEFINITION DES CURSEURS PRIVES ------------------------------------------
  -- @curs
  --
  -- --------------------------------------------------------------------------
  CURSOR c_select_histo
  IS
    SELECT SUM (f_total_histo (histo_jours.idhisto, -2)) montant,
      SUM (f_total_histo_d (histo_jours.idhisto,    -2)) montant_d,
      repartition.idadhesion,
      repartition.idrepartition,
      repartition.numfor,
      --DECODE (repartition_bene.type_dest, 1, repartition_bene.numbene_dest, 2, contrat.numcli, 3, adhe_cntrt.numadhe, 4, repartition_bene.numbene_dest) numdest,
      DECODE (repartition_bene.type_dest, 1, repartition_bene.numbene_dest, 2, contrat.numcli, 3, adhe_cntrt.numadhe, 4, contrat.deleg_prest, repartition_bene.numbene_dest) numdest, --pk_prev.SEL_CORRES_BY_TYPE_DEST(repartition.nosin,15,repartition_bene.type_dest, NULL)) numdest,
      contrat.numgar,
      histo_calcul.numbene,
      TRANSLATE (indvs.nom
      || ' '
      || indvs.prenom, '.', '@') nom,
      histo_jours.monnaie monnaie,
      histo_jours.monnaie_d monnaie_d,
      histo_calcul.creation datsai,
      histo_calcul.idcalcul,
      gar_prev.type_calc,
      repartition.nosin,
      repartition_bene.type_dest
    FROM histo_jours,
      histo_calcul,
      repartition,
      V_REPARTITION_HISTO_DEST repartition_bene,
      gar_prev,
      contrat,
      adhe_cntrt,
      indvs
    WHERE gar_prev.type_calc IS NOT NULL
    AND repartition_bene.valide = 'O'
    AND histo_calcul.numdec       = 0
    AND repartition.nosin BETWEEN NVL(g_nosin_deb, repartition.nosin) AND NVL(g_nosin_fin, NVL(g_nosin_deb, repartition.nosin))
    AND gar_prev.type_calc BETWEEN NVL(g_typcal_deb, gar_prev.type_calc) AND NVL(g_typcal_fin, NVL(g_typcal_deb, gar_prev.type_calc))
    AND histo_calcul.debut BETWEEN NVL(g_deb, histo_calcul.debut) AND NVL(g_fin, NVL(g_deb, histo_calcul.debut))
    AND ( (histo_calcul.idrepartition = repartition.idrepartition)
    AND (histo_calcul.idcalcul        = histo_jours.idcalcul)
    AND (histo_calcul.numbene         = repartition_bene.numbene)
    AND (indvs.numindiv               = histo_calcul.numbene)
    AND (repartition.idrepartition    = repartition_bene.idrepartition)
    AND (gar_prev.numfor              = repartition.numfor)
    AND (adhe_cntrt.numgar            = contrat.numgar)
    AND (adhe_cntrt.idadhesion        = repartition.idadhesion)
    AND histo_calcul.debut BETWEEN repartition_bene.debut AND NVL(repartition_bene.fin, histo_calcul.debut)
	AND NVL(histo_calcul.numbene_dest,repartition_bene.numbene_dest) = repartition_bene.numbene_dest
    )
    GROUP BY repartition.idadhesion,
      repartition.idrepartition,
      repartition.numfor,

      DECODE (repartition_bene.type_dest, 1, repartition_bene.numbene_dest, 2, contrat.numcli, 3, adhe_cntrt.numadhe, 4, contrat.deleg_prest, repartition_bene.numbene_dest ) , -- pk_prev.SEL_CORRES_BY_TYPE_DEST(repartition.nosin,15,repartition_bene.type_dest, NULL)),
      contrat.numgar,
      histo_calcul.numbene,
      TRANSLATE (indvs.nom
      || ' '
      || indvs.prenom, '.', '@'),
      histo_jours.monnaie,
      histo_jours.monnaie_d,
      histo_calcul.creation,
      histo_calcul.idcalcul,
      gar_prev.type_calc,
      repartition.nosin,
      repartition_bene.type_dest
    ORDER BY histo_jours.monnaie,
      --DECODE (repartition_bene.type_dest, 1, repartition_bene.numbene_dest, 2, contrat.numcli, 3, adhe_cntrt.numadhe, 4, repartition_bene.numbene_dest),
      DECODE (repartition_bene.type_dest, 1, repartition_bene.numbene_dest, 2, contrat.numcli, 3, adhe_cntrt.numadhe, 4, contrat.deleg_prest, repartition_bene.numbene_dest ) , -- pk_prev.SEL_CORRES_BY_TYPE_DEST(repartition.nosin,15,repartition_bene.type_dest, NULL)),
      repartition.idadhesion,
      gar_prev.type_calc,
      histo_calcul.numbene,
      repartition.nosin;
  --
  --
  ------------------------------------------------------------------
  --
  -- Le corps des différentes procedures
  --
  ------------------------------------------------------------------
  --
  --
PROCEDURE p_gdp4b(
    i_nosin_deb  IN VARCHAR2 DEFAULT NULL,
    i_nosin_fin  IN VARCHAR2 DEFAULT NULL,
    i_typcal_deb IN NUMBER DEFAULT NULL,
    i_typcal_fin IN NUMBER DEFAULT NULL,
    i_session    IN NUMBER DEFAULT 1,
    i_niv_msg    IN NUMBER DEFAULT 1,
    i_pause      IN NUMBER DEFAULT 0,
    o_found OUT NUMBER,
    o_erreur OUT VARCHAR2)
IS
  r_select_histo c_select_histo%ROWTYPE;
  iderr VARCHAR2 (2);
BEGIN
  --
  o_found  := 1;
  g_erreur := NULL;
  --
  g_nosin_deb  := i_nosin_deb;
  g_nosin_fin  := i_nosin_fin;
  g_typcal_deb := i_typcal_deb;
  g_typcal_fin := i_typcal_fin;
  --
  g_max_msg := i_niv_msg;
  g_session := i_session;
  --G_idligne := F_max_idligne(I_session => G_session);
  ---------
  g_niv_msg := 3;
  g_msg_adm := 'Acces p_gdp4b';
  p_ins_journal;
  ---------
  -- OUVERTURE du Curseur
  --
  IF NOT c_select_histo%ISOPEN THEN
    ---------
    g_niv_msg := 3;
    g_msg_adm := 'P_deb_trt_1';
    p_ins_journal;
    ---------
    p_debut_traitement;
    ---------
    g_niv_msg := 3;
    g_msg_adm := 'P_deb_trt_2';
    p_ins_journal;
    ---------
  END IF;
  --
  -- LECTURE D'1 Ligne dans la table principale
  --
  ---------
  g_niv_msg := 3;
  g_msg_adm := 'Avant fetch';
  p_ins_journal;
  ---------
  FETCH c_select_histo INTO r_select_histo;
  --
  IF c_select_histo%NOTFOUND THEN
    ---------
    g_niv_msg := 3;
    g_msg_adm := 'Jalon 0';
    p_ins_journal;
    ---------
    o_found := 0;
    p_fin_traitement;
  ELSE
    ---------
    g_niv_msg := 3;
    g_msg_adm := 'Jalon 1';
    p_ins_journal;
    ---------
    o_found := 1;
    --
    iderr           := '00';
    g_montant       := r_select_histo.montant;
    iderr           := '01';
    g_montant_d     := r_select_histo.montant_d;
    iderr           := '02';
    g_idadhesion    := r_select_histo.idadhesion;
    iderr           := '03';
    g_idrepartition := r_select_histo.idrepartition;
    iderr           := '04';
    g_numfor        := r_select_histo.numfor;
    iderr           := '05';
    g_numdest       := r_select_histo.numdest;
    iderr           := '06';
    g_numgar        := r_select_histo.numgar;
    iderr           := '07';
    g_numbene       := r_select_histo.numbene;
    iderr           := '08';
    g_nom           := r_select_histo.nom;
    iderr           := '09';
    g_monnaie       := r_select_histo.monnaie;
    iderr           := '10';
    g_monnaie_d     := r_select_histo.monnaie_d;
    iderr           := '11';
    g_datsai        := r_select_histo.datsai;
    iderr           := '12';
    g_idcalcul      := r_select_histo.idcalcul;
    iderr           := '13';
    g_type_calc     := r_select_histo.type_calc;
    iderr           := '14';
    g_nosin         := r_select_histo.nosin;
    iderr           := '15';
    g_type_dest     := r_select_histo.type_dest;
    iderr           := '16';
    --
    p_traitement_principal;
  END IF;
  --
  o_erreur := g_erreur;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := 'PK_GDP4B - ' || iderr || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  o_erreur  := SUBSTR (SQLERRM (SQLCODE), 1, 128);
  p_ins_journal;
  -- FERMETURE du Curseur
  CLOSE c_select_histo;
END;



PROCEDURE p_gdp4b_date(
    i_nosin_deb  IN VARCHAR2 DEFAULT NULL,
    i_nosin_fin  IN VARCHAR2 DEFAULT NULL,
    i_typcal_deb IN NUMBER DEFAULT NULL,
    i_typcal_fin IN NUMBER DEFAULT NULL,
    i_deb IN DATE DEFAULT NULL,
    i_fin IN DATE DEFAULT NULL,
    i_session    IN NUMBER DEFAULT 1,
    i_niv_msg    IN NUMBER DEFAULT 1,
    i_pause      IN NUMBER DEFAULT 0,
    o_found OUT NUMBER,
    o_erreur OUT VARCHAR2)
IS
  r_select_histo c_select_histo%ROWTYPE;
  iderr VARCHAR2 (2);
BEGIN
  --
  o_found  := 1;
  g_erreur := NULL;

  g_min_datsai      := NULL;
    g_monnaie_old     := NULL;
    g_monnaie_old_d   := NULL;
    g_numcpte     := NULL;
    g_numcpte_old     := NULL;
    g_modpmt      := NULL;
    g_modpmt_old      := NULL;
    g_numbene     := NULL;
    g_numbene_old     := NULL;
    g_numdest_old     := NULL;
    g_numgar      := NULL;
    g_numgar_old      := NULL;
    g_idadhesion  := NULL;
    g_idadhesion_old  := NULL;
    g_type_calc_old   := NULL;
    g_type_bene   := NULL;
    g_type_bene_old   := NULL;
    g_nbpag_old       := NULL;
    g_lidcalcul       := NULL;
    g_nosin_old       := NULL;
    g_type_dest   := NULL;
    g_type_dest_old   := NULL;
    g_nbpag           := 0;
    g_montant_total   := 0;
    g_montant_total_d := 0;
  --
  g_nosin_deb  := i_nosin_deb;
  g_nosin_fin  := i_nosin_fin;
  g_typcal_deb := i_typcal_deb;
  g_typcal_fin := i_typcal_fin;
  g_deb := i_deb;
  g_fin := i_fin;
  --
  g_max_msg := i_niv_msg;
  g_session := i_session;
  --G_idligne := F_max_idligne(I_session => G_session);
  ---------
  g_niv_msg := 3;
  g_msg_adm := 'Acces p_gdp4b_date '||'g_deb: '||g_deb||'g_fin: '||g_fin||'g_nosin_deb:'||g_nosin_deb||'g_nosin_fin:'||g_nosin_fin||'g_typcal_deb:'||g_typcal_deb||'g_typcal_fin:'||g_typcal_fin;
  p_ins_journal;
  ---------
  -- OUVERTURE du Curseur
  --
  IF NOT c_select_histo%ISOPEN THEN
    ---------
    g_niv_msg := 3;
    g_msg_adm := 'P_deb_trt_1';
    p_ins_journal;
    ---------
    p_debut_traitement;
    ---------
    g_niv_msg := 3;
    g_msg_adm := 'P_deb_trt_2';
    p_ins_journal;
    ---------
  END IF;
  --
  -- LECTURE D'1 Ligne dans la table principale
  --
  ---------
  g_niv_msg := 3;
  g_msg_adm := 'Avant fetch';
  p_ins_journal;


  ---------

   o_found := 0;
  FOR R_select_histo IN c_select_histo LOOP
  /*
  FETCH c_select_histo INTO r_select_histo;

  --
  IF c_select_histo%NOTFOUND THEN
    ---------

    g_niv_msg := 3;
    g_msg_adm := 'Jalon 0';
    p_ins_journal;
    ---------
    o_found := 0;
    p_fin_traitement;
  ELSE*/
    ---------
    g_niv_msg := 3;
    g_msg_adm := 'Jalon 1';
    p_ins_journal;
    ---------
    o_found := 1;
    --
    iderr           := '00';
    g_montant       := r_select_histo.montant;
    iderr           := '01';
    g_montant_d     := r_select_histo.montant_d;
    iderr           := '02';
    g_idadhesion    := r_select_histo.idadhesion;
    iderr           := '03';
    g_idrepartition := r_select_histo.idrepartition;
    iderr           := '04';
    g_numfor        := r_select_histo.numfor;
    iderr           := '05';
    g_numdest       := r_select_histo.numdest;
    iderr           := '06';
    g_numgar        := r_select_histo.numgar;
    iderr           := '07';
    g_numbene       := r_select_histo.numbene;
    iderr           := '08';
    g_nom           := r_select_histo.nom;
    iderr           := '09';
    g_monnaie       := r_select_histo.monnaie;
    iderr           := '10';
    g_monnaie_d     := r_select_histo.monnaie_d;
    iderr           := '11';
    g_datsai        := r_select_histo.datsai;
    iderr           := '12';
    g_idcalcul      := r_select_histo.idcalcul;
    iderr           := '13';
    g_type_calc     := r_select_histo.type_calc;
    iderr           := '14';
    g_nosin         := r_select_histo.nosin;
    iderr           := '15';
    g_type_dest     := r_select_histo.type_dest;
    iderr           := '16';
    --
    p_traitement_principal;
  --END IF;
  END LOOP;
  IF o_found=0 THEN
    g_niv_msg := 3;
    g_msg_adm := 'Jalon 0';
    p_ins_journal;
  END IF;
    ---------

    p_fin_traitement;
  --
  o_erreur := g_erreur;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := 'PK_GDP4B - ' || iderr || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  o_erreur  := SUBSTR (SQLERRM (SQLCODE), 1, 128);
  p_ins_journal;
  -- FERMETURE du Curseur
  CLOSE c_select_histo;
END;
--
-- -----------------------------
--
PROCEDURE p_traitement_principal
IS
BEGIN
  IF g_trait_entete IS NULL THEN
    --
    p_entete_decompte;
    --
    g_trait_entete := '1';
    --
  END IF;
  p_corps_histo;
  --
END p_traitement_principal;
--
-- ------------------------
--
PROCEDURE p_sel_sens
IS
BEGIN
  SELECT sens
  INTO g_sens_ope
  FROM lble
  WHERE mnemo = 'MOPM'
  AND code    = g_modpmt;
END p_sel_sens;
--
-- ----------------------
--
PROCEDURE p_entete_decompte
IS
BEGIN
  --
  g_proc := 'P_ENTETE_decompte';
  --
  -- Attribution prochain numero de decompte
  p_select_numdec;
  --
  g_niv_msg := 3;
  g_msg_adm := 'P_ENTETE_decompte, numdec=' || g_numdec;
  p_ins_journal;
  --
  SELECT client INTO g_client FROM parametres;
  --
  p_rech_modpmt;
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
END p_entete_decompte;
--
-- -------------------
--
PROCEDURE p_corps_histo
IS
  iderrl VARCHAR2 (2);
BEGIN
  --
  g_proc    := 'P_corps_histo';
  g_niv_msg := 3;
  g_msg_adm := 'Traitement ligne - NOSIN=' || g_nosin;
  p_ins_journal;
  --
  -- Rupture sur devise
  IF g_monnaie_old != g_monnaie THEN
    g_niv_rupt     := 1;
    p_pied_decompte;
    p_entete_decompte;
    -- Rupture sur numero de compte
  ELSIF g_numcpte_old != g_numcpte THEN
    g_niv_rupt        := 2;
    p_pied_decompte;
    p_entete_decompte;
    -- Rupture sur numero de destinataire
  ELSIF g_numdest_old != g_numdest THEN
    g_niv_rupt        := 3;
    p_pied_decompte;
    p_entete_decompte;
    -- Rupture sur numero d'adhesion
  ELSIF g_idadhesion_old != g_idadhesion THEN
    g_niv_rupt           := 4;
    p_pied_decompte;
    p_entete_decompte;
    -- Rupture sur type de calcul
  ELSIF g_type_calc_old != g_type_calc THEN
    g_niv_rupt          := 5;
    p_pied_decompte;
    p_entete_decompte;
    -- Rupture sur numbene --> CARCO
  ELSIF (g_numbene_old != g_numbene AND g_client = 8) THEN
    g_niv_rupt         := 6;
    p_pied_decompte;
    p_entete_decompte;
    -- Rupture sur nosin
  ELSIF (g_nosin_old != g_nosin) THEN
    -- AND g_client = 10)
    g_niv_rupt := 7;
    p_pied_decompte;
    p_entete_decompte;
  END IF;
  g_niv_msg := 3;
  g_msg_adm := 'Traitement ligne Av MAJ MT = '||g_montant_total_d;
  p_ins_journal;
  g_montant_total := g_montant_total + g_montant;
  iderrl          := '01';
  --
  g_montant_total_d := g_montant_total_d + g_montant_d;
  iderrl            := '02';
  g_niv_msg := 3;
  g_msg_adm := 'Traitement ligne ap MAJ MT = '||g_montant_total_d;
  p_ins_journal;
  p_upd_histo_calcul;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := iderrl || '-' || TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END p_corps_histo;
--
-- ----------------------
--
-- Gestion du decompte
--
PROCEDURE p_pied_decompte
IS
BEGIN
  --
  g_proc := 'P_PIED_decompte';
  --
  g_niv_msg := 3;
  g_msg_adm := 'P_PIED_Decompte- rupture sur num ' || g_niv_rupt;
  p_ins_journal;
  --
  -- Gestion des indus
  IF g_montant_total < 0 THEN
    p_pas_retention;
    g_niv_msg := 3;
    g_msg_adm := 'G_montant_total < 0 >> Vers P_pas_retention';
    p_ins_journal;
  ELSE
    IF f_param_ope_valide (g_numgar_old, 2, g_modpmt_old, 1, g_montant_total, g_min_datsai) = 0 THEN
      p_retention;
      g_niv_msg := 3;
      g_msg_adm := 'f_param_ope_valide=0 >> Vers P_retention';
      p_ins_journal;
    ELSE
      p_pas_retention;
      g_niv_msg := 3;
      g_msg_adm := 'Vers P_pas_retention';
      p_ins_journal;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END p_pied_decompte;
--
-- ----------------------
--
PROCEDURE p_retention
IS
BEGIN
  --
  g_proc := 'P_retention';
  --
  g_niv_msg := 3;
  g_msg_adm := 'P_retention';
  p_ins_journal;
  --
  p_annul_decompte;
  p_annul_decompte_dedu;
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
END p_retention;
--
-- ----------------------
--
PROCEDURE p_pas_retention
IS
BEGIN
  --
  g_proc := 'P_pas_retention';
  --
  g_niv_msg := 3;
  g_msg_adm := 'P_pas_retention';
  p_ins_journal;
  --
  IF (g_montant_total < 0 AND pk_prev.f_sel_flag_remb (g_numdec) = 'N') THEN
    p_retention;
    g_niv_msg := 3;
    g_msg_adm := 'G_montant_total < 0 AND f_sel_flag_remb=N >> Vers P_retention';
    p_ins_journal;
  ELSE
    IF g_type_dest_old = 4 THEN
      p_ins_decompte_prev;
      p_insert_compte_tiers;
    ELSE
      p_ins_decompte_prev;
      IF g_montant_total < 0 or g_type_calc_old = 4 THEN -- Mantis n°3158
        p_pas_decaismt;
      ELSE
        p_select_numdecaismt;
        p_insert_decaismt;
        p_insert_affectation;
      END IF;
    END IF;
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
END p_pas_retention;
--
-- ----------------------
--
PROCEDURE p_pas_decaismt
IS
BEGIN
  --
  g_proc := 'P_Pas_decaismt';
  --
  g_niv_msg := 3;
  g_msg_adm := 'P_Pas_decaismt';
  p_ins_journal;
  --
  g_numdecaismt := NULL;
  p_insert_affectation;
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
END p_pas_decaismt;
--
-- ----------------------
--
PROCEDURE p_annul_decompte
IS
BEGIN
  UPDATE histo_calcul SET numdec = 0 WHERE numdec = g_numdec;
  --
END p_annul_decompte;
--
-- ----------------------
--
PROCEDURE p_annul_decompte_dedu
IS
BEGIN
  UPDATE histo_dedu SET numdec = 0 WHERE numdec = g_numdec;
  --
END p_annul_decompte_dedu;
--
-- ----------------------
--
PROCEDURE p_sel_compte
IS
BEGIN
  SELECT f_param_compte (g_numgar, 2, g_modpmt) INTO g_numcpte FROM DUAL;
  --
END p_sel_compte;
--
-- ----------------------
--
PROCEDURE p_sel_idrib
IS
BEGIN
  SELECT f_bene_rib (g_numdest, 2, g_numgar, 1) INTO g_idrib FROM DUAL;
  --
END p_sel_idrib;
--
-- ----------------------
--
PROCEDURE p_sel_modpmt
IS
BEGIN
  SELECT modpmt INTO g_modpmt FROM rib WHERE idrib = g_idrib;
  --
END p_sel_modpmt;
--
-- ----------------------
--
PROCEDURE p_ins_decompte_prev
IS
BEGIN
  INSERT
  INTO decompte_prev
    (
      numdec,
      idadhesion,
      numdcptcie,
      datpay,
      montant,
      monnaie,
      monnaie_d,
      montant_d
   )
  SELECT g_numdec,
    g_idadhesion_old,
    0,
    TRUNC (SYSDATE),
    g_montant_total,
    g_monnaie_old,
    g_monnaie_old_d,
    g_montant_total_d
  FROM DUAL;
  --
END p_ins_decompte_prev;
--
-- ----------------------
--
PROCEDURE p_select_numdecaismt
IS
BEGIN
  SELECT numdecaismt.NEXTVAL INTO g_numdecaismt FROM DUAL;
  --
END p_select_numdecaismt;
--
-- ----------------------
--
PROCEDURE p_insert_decaismt
IS
BEGIN
  INSERT
  INTO decaismt
    (
      numdecaismt,
      codope,
      numcpte,
      modpmt,
      montant,
      montant_d,
      monnaie,
      monnaie_d,
      debit,
      numbene,
      typbene,
      numdest,
      numedit,
      numutil
   )
  SELECT g_numdecaismt,
    2,
    g_numcpte_old,
    g_modpmt_old,
    g_montant_total,
    g_montant_total_d,
    g_monnaie_old,
    g_monnaie_old_d,
    0,
    g_numbene_old,
    g_type_bene_old,
    g_numdest_old,
    0,
    DECODE (f_valid (2, g_numcpte_old, g_montant_total), 0, 0, -1)
  FROM DUAL;
  --
END p_insert_decaismt;
--
-- ----------------------
--
PROCEDURE p_insert_affectation
IS
BEGIN
  INSERT
  INTO affectation
    (
      numdecaismt,
      codope,
      numaffec,
      montant,
      montant_d,
      monnaie,
      monnaie_d,
      dataffec,
      numcli
   )
  SELECT g_numdecaismt,
    2,
    NVL (g_numdec, 1),
    g_montant_total,
    g_montant_total_d,
    g_monnaie_old,
    g_monnaie_old_d,
    TRUNC (SYSDATE),
    g_numdest_old
  FROM DUAL;
  --
END p_insert_affectation;
--
-- ----------------------
--
PROCEDURE p_insert_compte_tiers
IS
BEGIN
  INSERT
  INTO compte_tiers
    (
      numcli,
      codope,
      cle,
      datope,
      sens,
      montant,
      montant_d,
      monnaie,
      monnaie_d
   )
  SELECT g_numdest_old,
    2,
    NVL (g_numdec, 1),
    SYSDATE,
    SIGN (g_montant_total) * 1,
    ABS (g_montant_total),
    ABS (g_montant_total_d),
    g_monnaie_old,
    g_monnaie_old_d
  FROM DUAL;
  --
END p_insert_compte_tiers;
--
-- ----------------------
--
PROCEDURE p_upd_histo_calcul
IS
BEGIN
  UPDATE histo_calcul
  SET numdec          = g_numdec
  WHERE idrepartition = g_idrepartition
  AND numbene         = g_numbene
  AND idcalcul        = g_idcalcul
  AND numdec          = 0;
END p_upd_histo_calcul;
--
-- ----------------------
--
PROCEDURE p_select_numdec
IS
BEGIN
  SELECT NVL (MAX (numdec), 0) + 1 INTO g_numdec FROM decompte_prev;
END p_select_numdec;
--
-- ----------------------
--
PROCEDURE p_rech_modpmt
IS
BEGIN
  ---------
  g_niv_msg := 3;
  g_msg_adm := 'Jalon 4';
  p_ins_journal;
  ---------
  --
  g_proc := 'P_rech_modpmt';
  --
  g_niv_msg := 3;
  g_msg_adm := 'P_rech_modpmt';
  p_ins_journal;
  BEGIN
    g_idrib_trouve := 'O';
    p_sel_idrib;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    g_idrib              := NULL;
    g_idrib_trouve       := 'N';
    g_bene_modpmt_trouve := 'N';
  END;
  --
  IF g_idrib_trouve = 'O' THEN
    BEGIN
      g_bene_modpmt_trouve := 'O';
      p_sel_modpmt;
      ---
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      g_bene_modpmt_trouve := 'N';
      g_modpmt             := NULL;
    END;
    ---
    -- La fonction f_rib_valide gere l'exception no_data_found (retour =0) !
    ---
  -- SEPA modif MUR : prendre en compte 1 et 2 en retour de f_rib_valide
	IF (f_rib_valide (g_idrib) in (1,2) OR g_modpmt != 2) THEN
      p_sel_compte;
      p_sel_sens;
      --
      g_min_datsai      := g_datsai;
      g_monnaie_old     := g_monnaie;
      g_monnaie_old_d   := g_monnaie_d;
      g_numcpte_old     := g_numcpte;
      g_modpmt_old      := g_modpmt;
      g_numbene_old     := g_numbene;
      g_numdest_old     := g_numdest;
      g_numgar_old      := g_numgar;
      g_idadhesion_old  := g_idadhesion;
      g_type_calc_old   := g_type_calc;
      g_type_bene_old   := g_type_bene;
      g_nbpag_old       := g_nbpag;
      g_lidcalcul       := g_idcalcul;
      g_nosin_old       := g_nosin;
      g_type_dest_old   := g_type_dest;
      g_nbpag           := 0;
      g_montant_total   := 0;
      g_montant_total_d := 0;
        -- SEPA ajout MUR : si f_rib_valide = 2 alors message bic non alimenté
  		IF f_rib_valide (g_idrib) = 2 THEN
  			g_niv_msg := 1;
              g_msg_adm := 'Le bic pour le bénéficiaire N° '
  						|| g_numbene
  						|| ' n''est pas renseigné.';
              p_ins_journal;
      END IF;

    ELSE
      g_bene_modpmt_trouve := 'N';
    END IF;
  END IF;
  --
  IF g_bene_modpmt_trouve = 'N' THEN
    g_modpmt             := 1;
    g_niv_msg            := 2;
    g_msg_adm            := 'Le mode de paiement du bénéficiaire N° ' || g_numbene || ', ' || g_nom || ' n''est pas valide.';
    p_ins_journal;
    -- Fin ecriture dans le Journal
    g_niv_msg := 2;
    g_msg_adm := 'Le décompte N° ' || g_numdec || ' sera donc réglé par lettre chèque.';
    p_ins_journal;
    -- Fin ecriture dans le Journal
    -- JPF 07/01/2005 rajout par JPF
    p_sel_compte;
    p_sel_sens;
    g_min_datsai      := g_datsai;
    g_monnaie_old     := g_monnaie;
    g_monnaie_old_d   := g_monnaie_d;
    g_numcpte_old     := g_numcpte;
    g_modpmt_old      := g_modpmt;
    g_numbene_old     := g_numbene;
    g_numdest_old     := g_numdest;
    g_numgar_old      := g_numgar;
    g_idadhesion_old  := g_idadhesion;
    g_type_calc_old   := g_type_calc;
    g_type_bene_old   := g_type_bene;
    g_nbpag_old       := g_nbpag;
    g_lidcalcul       := g_idcalcul;
    g_nosin_old       := g_nosin;
    g_type_dest_old   := g_type_dest;
    g_nbpag           := 0;
    g_montant_total   := 0;
    g_montant_total_d := 0;
  END IF;
  --
  g_niv_msg := 3;
  g_msg_adm := 'P_rech_modpmt : Numbene=' || g_numbene || ', Idrib=' || g_idrib || ', Mopmt=' || g_modpmt;
  p_ins_journal;
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END p_rech_modpmt;
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
  g_msg_adm := 'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
  p_ins_journal;
  -- Fin ecriture dans le Journal
  OPEN c_select_histo;
  g_trait_entete := NULL;
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
END p_debut_traitement;
--
-- -----------------------
--
PROCEDURE p_fin_traitement
IS
BEGIN
  --
  g_proc := 'P_fin_traitement';
  --
  IF g_trait_entete IS NOT NULL THEN
    p_pied_decompte;
  END IF;
  --
  -- FERMETURE du Curseur
  --
  CLOSE c_select_histo;
  --
  g_niv_msg := 1;
  g_msg_adm := 'Fin Normale du traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
  p_ins_journal;
  -- Fin ecriture dans le Journal
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
----------------------- Fin des procedures publiques ------------------
--
-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
PROCEDURE p_ins_journal
IS
  l_idligne NUMBER;
BEGIN
  --
  IF (g_niv_msg  <= g_max_msg) THEN
    g_idligne    := g_idligne + 1;
    IF (g_niv_msg = 0) THEN
      l_idligne  := -1 * g_idligne;
    ELSE
      l_idligne := g_idligne;
    END IF;
    pk_trace.p_ins_journal_adm (i_nom_traitement => g_nom_traitement, i_session => g_session, i_niv_msg => g_niv_msg, i_msg_adm => g_msg_adm, i_idligne => l_idligne);
  END IF;
  --
END p_ins_journal;
---------------- Fin des corps des procedures privees --
END;
/
