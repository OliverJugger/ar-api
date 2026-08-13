CREATE OR REPLACE PACKAGE ARTHUS.PK_DEV_PV03B
AS
  --
PROCEDURE p_dev_pv03b(
    i_deb_numsoc   IN vs_compte.numsoc%TYPE DEFAULT NULL,
    i_fin_numsoc   IN vs_compte.numsoc%TYPE DEFAULT NULL,
    i_deb_numcpte  IN vs_compte.numcpte%TYPE DEFAULT NULL,
    i_fin_numcpte  IN vs_compte.numcpte%TYPE DEFAULT NULL,
    i_deb_echeance IN facture.echeance%TYPE DEFAULT NULL,
    i_fin_echeance IN facture.echeance%TYPE DEFAULT NULL,
    i_jour_prelev  IN VARCHAR2 DEFAULT NULL,
    I_typeSEPA     IN NUMBER DEFAULT null,
    i_session      IN NUMBER DEFAULT 1,
    i_niv_msg      IN NUMBER DEFAULT 1,
    i_pause        IN NUMBER DEFAULT 0,
    o_found OUT NUMBER,
    o_erreur OUT VARCHAR2 );

PROCEDURE p_annul_pv03t(
    i_numremise IN prelevement.numremise%TYPE DEFAULT NULL);

PROCEDURE P_ANNUL_CONSTIT_MANDAT(
    i_numremise_prec     IN prelevement.numremise%TYPE DEFAULT NULL,
    i_idhistomandat      IN prelevement.idhistomandat%TYPE,
    i_idhistomandat_updt IN prelevement.idhistomandat%TYPE,
    i_MVT                IN prelevement.MVT%TYPE,
    i_MAJ                IN prelevement.MAJ%TYPE
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
  -- modif le 22/03/2010 PH : AND g_numcpte = f_param_compte (contrat.numgar, 4, 2)
  -- => remplacé par          AND g_numcpte = f_param_compte (contrat.numgar_ref, 4, 2)
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_DEV_PV03B
AS
  -- CONSTANTES PRIVEES
  -- Aucune
  -- Fin des constantes privees
  -- EXCEPTIONS PRIVEES
  -- Aucune
  -- Fin des exceptions privees
  -- TYPES PRIVEES
  -- Aucun
  -- Fin des types privees
  -- VARIABLES GLOBALES PRIVEES
  -- Aucune
  -- Fin des variables globales privees
  -- DECLARATION DES PROCEDURES PRIVEES
  --
PROCEDURE p_sel_trav_ano;
  --
PROCEDURE p_fin_traitement;
  --
PROCEDURE p_corps_sel_numcpte;
  --
PROCEDURE p_select_facture;
  --
PROCEDURE p_verif_trav_prelevement;
  --
PROCEDURE p_sel_trav_prelevement;
  --
PROCEDURE p_ins_journal;
  --
PROCEDURE p_mandat_constit;
  --
  FUNCTION f_max_idligne(
      i_session IN journal_adm.id_session%TYPE)
    RETURN NUMBER;
    --
    -- Fin des declarations des procedures privees
    -- CORPS DES PROCEDURES PUBLIQUES
    -- Aucune
    -- Fin des corps des procedures publiques
    -- CORPS DES PROCEDURES PRIVEES
    -- Aucune
    -- Fin des corps des procedures privees
    --
    -- Variables de sortie
    --

    g_lib_ano           VARCHAR2 (132);
    g_contrat_numgar    NUMBER (10);
    g_contrat_numgar_pret    NUMBER (10);
    g_facture_codope    NUMBER (3);
    g_facture_numfact   NUMBER (10);
    g_facture_numcli    NUMBER (10);
    g_facture_numcli_pret    NUMBER (10);
    g_facture_montant_d NUMBER (11, 2);
    g_facture_monnaie_d NUMBER (3);
    g_facture_montant   NUMBER (11, 2);
    g_facture_monnaie   NUMBER (3);
    g_codbque           VARCHAR2 (5);
    g_guichet           VARCHAR2 (5);
    g_compte            VARCHAR2 (11);
    g_clerib            VARCHAR2 (2);
    g_intitule          VARCHAR2 (30);
    g_idrib             NUMBER (9);
    g_idrib_pret            NUMBER (9);
    g_idadhesion        NUMBER (10);
    g_idadhesion_pret        NUMBER (10);
    g_jour_prelev       VARCHAR2 (2);
    g_mois_prelev       VARCHAR2 (2);
    g_bban              VARCHAR2(30);
    g_clef_iban         VARCHAR2(4);
    g_bic               VARCHAR2(11);
    --
    -- Variables globales privees
    --
    g_numremise prelevement.numremise%TYPE;
    g_numprelev prelevement.numprelev%TYPE;
    g_numsoc vs_compte.numsoc%TYPE;
    g_numcpte vs_compte.numcpte%TYPE;
    g_idaffec compte_client.idaffec%TYPE;
    g_codope compte_client.codope%TYPE;
    g_numcli compte_client.numcli%TYPE;
    g_numencaismt compte_client.numencaismt%TYPE;
    g_monnaie compte_client.monnaie%TYPE;
    g_monnaie_d compte_client.monnaie_d%TYPE;
    g_datope compte_client.datope%TYPE;
    g_montant compte_client.montant%TYPE;
    g_montant_d compte_client.montant_d%TYPE;
    g_numfact compte_client.numfact%TYPE;
    g_idcompta compte_client.idcompta%TYPE;
    g_datrem remise_prelev.datrem%TYPE;
    g_nombre remise_prelev.nombre%TYPE;
    g_valide remise_prelev.valide%TYPE;
    g_numremise_deb prelevement.numremise%TYPE := 0;
    g_numremise_fin prelevement.numremise%TYPE;
    g_typeSEPA NUMBER :=NULL ;
    --
    -- parametres du traitement
    --
    g_numsoc_deb vs_compte.numsoc%TYPE;
    g_numsoc_fin vs_compte.numsoc%TYPE;
    g_numcpte_deb vs_compte.numcpte%TYPE;
    g_numcpte_fin vs_compte.numcpte%TYPE;
    g_echeance_deb facture.echeance%TYPE;
    g_echeance_fin facture.echeance%TYPE;
    g_eche_prelev prelevement.eche_prelev%TYPE;
    g_eche_collect DATE;

    -- Flag de commit ou rollback a retourner a Forms
    --
    g_commit      BOOLEAN := FALSE;
    g_rollback    BOOLEAN := FALSE;
    g_auto_valide BOOLEAN := FALSE;
    --
    g_flag_test NUMBER;
    g_proc      VARCHAR2 (80);
    --
    -- Variables de P_INS_journal
    --
    g_nom_traitement CONSTANT journal_adm.nom_traitement%TYPE DEFAULT 'pk_dev_pv03b';
    g_msg_adm journal_adm.msg_adm%TYPE;
    g_session journal_adm.id_session%TYPE DEFAULT 1;
    g_niv_msg journal_adm.niv_msg%TYPE := 1;
    g_max_msg journal_adm.niv_msg%TYPE := 1;
    g_idligne journal_adm.idligne%TYPE := 0;
    g_erreur journal_adm.msg_adm%TYPE;
    --    G_niv_msg prend les Valeurs :
    -- 0 --> Message d'erreurs (Erreur ORACLE)
    -- 1 --> Message informatif(tout se passe bien)
    -- 2 et + Niveau de detail

    EXC_MANDAT_MAITRE exception ; -- MUR le 01/07/2014

    ---------------------- Fin des variables globales privees --
    ----------------------------------------------------------------------------
    --
    -- DEFINITION DES CURSEURS PRIVES ------------------------------------------
    --@curs
    --
    CURSOR c_sel_numcpte
    IS
      SELECT vs_compte.numsoc,
        vs_compte.numcpte,
        vs_compte.ics,vs_compte.clef_iban,vs_compte.bban,vs_compte.bic --ajout SEPA prelevement
      FROM vs_compte
      WHERE vs_compte.numsoc BETWEEN NVL (g_numsoc_deb, vs_compte.numsoc) AND NVL (g_numsoc_fin, NVL (g_numsoc_deb, vs_compte.numsoc) )
      AND vs_compte.numcpte BETWEEN NVL (g_numcpte_deb, vs_compte.numcpte) AND NVL (g_numcpte_fin, NVL (g_numcpte_deb, vs_compte.numcpte ) );
    --ABO 24/03/2020 ajout du périmètre de prélèvement B2B sur les échéanciers de niveau contrat
    --RG : les prélèvements B2B ne nécessitent pas l'émission de la cotisation
    --RG : les prélèvements B2B doivent faire l'objet d'une validation de quittance
    --RG on prend comme date de collecte le max entre echéance et le jour prélev passé en paramètre entrant
    CURSOR c_select_facture (p_eche_collect IN DATE)
    IS
      SELECT facture.numfact,
        facture.montant_d,
        facture.monnaie_d,
        facture.montant,
        facture.monnaie,
        facture.codope,
        facture.numcli,
        greatest(facture.echeance,p_eche_collect) date_collect,
        facture.echeance echeance,
        contrat.numgar,
        qttc_global.idadhesion
      FROM contrat,
        qttc_global,
        facture
      WHERE NOT EXISTS
        (SELECT 1
        FROM prelevement_detail,
          prelevement
        WHERE prelevement_detail.codope = facture.codope
        AND prelevement_detail.numfact  = facture.numfact
        AND prelevement.numprelev       = prelevement_detail.numprelev
        AND NOT EXISTS
          (SELECT 1
          FROM annul_encais
          WHERE annul_encais.numencaismt = prelevement.numencaismt
          )
        )
      AND g_numcpte                                                                   = f_param_compte (contrat.numgar_ref, 4, 2)
      AND contrat.numgar                                                              = qttc_global.numgar
      AND qttc_global.comptant                                                       != 'R'
      AND qttc_global.numquit                                                         = facture.numfact
      AND facture.codope                                                              = 4
      AND facture.mregl                                                               = 2
      AND facture.echeance                                                           <= NVL (g_echeance_deb, facture.echeance)
      AND facture.echeance >= add_months(g_echeance_deb,-1) --factures ancienneté  limitées à 1 mois
      AND ((qttc_global.nat_calc=2 AND contrat.typequit<>1 AND g_typeSEPA=1) OR (contrat.typequit=1 AND g_typeSEPA=2))
      AND ( facture.montant  - NVL (f_totaffec (facture.numfact, facture.codope), 0) ) > 0
      AND ((g_typeSEPA = 2 AND qttc_global.valid='O')
        OR (g_typeSEPA = 1 AND facture.numfact  IN
        (SELECT emission.numfact
        FROM emission
        WHERE emission.codope   = facture.codope
        AND emission.type_doc   = 1
        AND emission.numrelance = 0
        AND NOT EXISTS
          (SELECT 1
          FROM emission
          WHERE emission.codope    = facture.codope
          AND emission.numfact     = facture.numfact
          AND emission.type_doc    = 1
          AND emission.numrelance IN (4, 99)
          )
        )))
      ORDER BY 8,
        10 DESC,
        9 DESC; -- MUR le 12/03/2015 : ajout tri sur mois d'echeance;
      --
      CURSOR c_sel_trav_prelevement
      IS
        SELECT DISTINCT trav_prelevement.codbque,
          trav_prelevement.guichet,
          trav_prelevement.compte,
          trav_prelevement.clerib,
          trav_prelevement.intitule,
          trav_prelevement.numremise,
          trav_prelevement.eche_prelev
        , trav_prelevement.bban
        , trav_prelevement.clef_iban
        , trav_prelevement.bic
        -- SEPA mantis 4291 debut ajout
        , trav_prelevement.NUMQUERABLE
        , trav_prelevement.IDHISTOMANDAT
        , trav_prelevement.MANDAT
        , trav_prelevement.CREATE_MANDAT
        , trav_prelevement.MVT
        , trav_prelevement.MAJ
        , trav_prelevement.STATUT
        , trav_prelevement.amdt_ics
        , trav_prelevement.amdt_mndt
        , trav_prelevement.amdt_acct
        , trav_prelevement.amdt_smnda
        , trav_prelevement.amdt_creancier
        , trav_prelevement.numremise_prec
        , trav_prelevement.idadhesion
        , trav_prelevement.numgar
        , trav_prelevement.fribvalide
        -- SEPA mantis 4291 fin ajout
        FROM trav_prelevement
        WHERE ( trav_prelevement.numremise BETWEEN g_numremise_deb AND NVL (g_numremise_fin, g_numremise_deb )
        AND trav_prelevement.valide = 'O' );
      --
      CURSOR c_sel_trav_ano
      IS
        SELECT DISTINCT 'Facture : '
          || numfact
          || ' --> '
          || 'Les references bancaires de '
          || indvs.numindiv
          || '-'
          || indvs.nom
          || ' '
          || indvs.prenom
          || ' sont indeterminees.' lib_ano
        FROM trav_prelevement,
          indvs
        WHERE trav_prelevement.valide = 'N'
        AND indvs.numindiv            = TO_NUMBER (trav_prelevement.compte);
      ------------------------------------------------------------------
      --
      -- Le corps des differentes procedures
      --
      ------------------------------------------------------------------
      --
    PROCEDURE p_dev_pv03b(
        i_deb_numsoc   IN vs_compte.numsoc%TYPE DEFAULT NULL,
        i_fin_numsoc   IN vs_compte.numsoc%TYPE DEFAULT NULL,
        i_deb_numcpte  IN vs_compte.numcpte%TYPE DEFAULT NULL,
        i_fin_numcpte  IN vs_compte.numcpte%TYPE DEFAULT NULL,
        i_deb_echeance IN facture.echeance%TYPE DEFAULT NULL,
        i_fin_echeance IN facture.echeance%TYPE DEFAULT NULL,
        i_jour_prelev  IN VARCHAR2 DEFAULT NULL,
        i_typeSEPA     IN NUMBER DEFAULT null ,
        i_session      IN NUMBER DEFAULT 1,
        i_niv_msg      IN NUMBER DEFAULT 1,
        i_pause        IN NUMBER DEFAULT 0,
        o_found OUT NUMBER,
        o_erreur OUT VARCHAR2 )
  IS
     r_sel_numcpte c_sel_numcpte%ROWTYPE;
    BEGIN

      g_idrib := 0 ;
      o_found  := 1;
      g_erreur := NULL;
      --
      g_numsoc_deb   := i_deb_numsoc;
      g_numsoc_fin   := i_fin_numsoc;
      g_numcpte_deb  := i_deb_numcpte;
      g_numcpte_fin  := i_fin_numcpte;
      g_echeance_deb := i_deb_echeance;
      g_echeance_fin := i_fin_echeance;
      g_jour_prelev  := SUBSTR (i_jour_prelev, 1, 2);
      g_mois_prelev  := SUBSTR (i_jour_prelev, 3, 2);
      --
      g_max_msg := i_niv_msg;
      g_session := i_session;
      g_idligne := f_max_idligne (i_session => g_session);
      g_typeSEPA := I_typeSEPA ;
      --
      -- OUVERTURE du Curseur
      --
      IF NOT c_sel_numcpte%ISOPEN THEN
        g_niv_msg := 1;
        IF g_typeSEPA IN  (1,2) THEN g_msg_adm :=' SEPA';
        END IF;
        g_msg_adm := 'Debut de traitement'||g_msg_adm||' le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
        p_ins_journal;
        --
        DELETE trav_prelevement;
        --
        OPEN c_sel_numcpte;
        --
        SELECT NVL (MAX (numremise), 0) INTO g_numremise FROM remise_prelev;
      END IF;
      --
      -- Lecture d'une Ligne dans la table principale
      --
      FETCH c_sel_numcpte
      INTO r_sel_numcpte;
      --
      IF c_sel_numcpte%NOTFOUND THEN
        o_found := 0;
        p_fin_traitement;
      ELSE
        -- ajout SEPA prelevements : si ics non renseigné  ou format sepa du rib non respecté alors message
        if r_sel_numcpte.ics is null and g_typeSEPA IN (1,2) then
          g_niv_msg := 1;
          g_msg_adm := 'Constit. impossible : ICS non renseigné pour le compte '||TO_CHAR (r_sel_numcpte.numcpte);
          p_ins_journal;
        elsif (r_sel_numcpte.clef_iban is null or r_sel_numcpte.bban is null ) and g_typeSEPA IN  (1,2) then
          -- or r_sel_numcpte.bic is null
          g_niv_msg := 1;
          g_msg_adm := 'Constit. impossible : Format non SEPA pour le compte '||TO_CHAR (r_sel_numcpte.numcpte) ;
          p_ins_journal;
        else
          o_found   := 1;
          g_numsoc  := r_sel_numcpte.numsoc;
          g_numcpte := r_sel_numcpte.numcpte;
          --
          g_niv_msg := 3;
          g_msg_adm := 'societe n° ' || TO_CHAR (g_numsoc) || ' - ' || 'compte n° ' || TO_CHAR (g_numcpte);
          p_ins_journal;
          --
          p_corps_sel_numcpte;
          --
          p_sel_trav_ano;
          --
          SELECT NVL (MAX (numremise), 0) INTO g_numremise FROM remise_prelev;
        end if ;
      END IF;
      --
      o_erreur := g_erreur;
      --
    EXCEPTION
    when EXC_MANDAT_MAITRE then -- MUR le 01/07/2014
      rollback ;
      g_niv_msg := 0;
      g_msg_adm := 'Problème recherche mandat maitre:adhesion:'||g_idadhesion||'-querable:'||g_facture_numcli||'-idrib:'||g_idrib;
      o_erreur  := SUBSTR (SQLERRM (SQLCODE), 1, 128);
      p_ins_journal;
    WHEN OTHERS THEN
      g_niv_msg := 0;
      g_msg_adm := 'pk_dev_pv03b - ' || SUBSTR (SQLERRM (SQLCODE), 1, 116);
      o_erreur  := SUBSTR (SQLERRM (SQLCODE), 1, 128);
      p_ins_journal;
      --
      CLOSE c_sel_numcpte;
      --
    END;
    --
  PROCEDURE p_verif_trav_prelevement
  IS
    cursor c_verif_trav_prel IS
  	  select
  	    trav_prelevement.idhistomandat , trav_prelevement.mandat , trav_prelevement.numquerable , histo_mandat.idrib ,
        PK_SEPA.F_MANDAT_VALIDE(HISTO_MANDAT.idhistomandat) test_caduque, pk_sepa.f_rib_iban(histo_mandat.idrib) test_format_sepa ,
        decode(trav_prelevement.idadhesion
              ,0,trav_prelevement.numquerable||'-Cnt/Adh Coll:'||trav_prelevement.numgar
              ,  trav_prelevement.numquerable||'-Adh Ind:'     ||trav_prelevement.idadhesion) libelle,
        trav_prelevement.fribvalide
      from trav_prelevement
      inner join histo_mandat on (trav_prelevement.idhistomandat = histo_mandat.idhistomandat) ;
    r_verif_trav_prel c_verif_trav_prel%rowtype ;
  BEGIN
    FOR r_verif_trav_prel in c_verif_trav_prel LOOP
      IF g_typeSEPA IN  (1,2) THEN
        IF r_verif_trav_prel.test_caduque <> 2 then
          delete from trav_prelevement where trav_prelevement.idhistomandat = r_verif_trav_prel.idhistomandat ;
          g_proc := 'P_verif_trav_prelevement';
          g_niv_msg := 1;
          g_msg_adm := 'Constit. impossible : Caducité 36 mois-Quérable:'||r_verif_trav_prel.libelle;
          p_ins_journal;
        ELSIF r_verif_trav_prel.test_format_sepa <> 1 then
          delete from trav_prelevement where trav_prelevement.idhistomandat = r_verif_trav_prel.idhistomandat ;
          g_proc := 'P_verif_trav_prelevement';
          g_niv_msg := 1;
          g_msg_adm := 'Constit. impossible : Format non SEPA-Quérable:'||r_verif_trav_prel.libelle;
          p_ins_journal;
        END IF;
      END IF ;
    END LOOP ;

  EXCEPTION
    WHEN OTHERS THEN
      g_proc := 'P_verif_trav_prelevement';
      g_niv_msg := 0;
      g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
      p_ins_journal;
      g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 125);
      g_erreur  := g_msg_adm;
      p_ins_journal;
  END p_verif_trav_prelevement;



  PROCEDURE p_sel_trav_ano
  IS
    r_sel_trav_ano c_sel_trav_ano%ROWTYPE;
  BEGIN
    --
    g_proc := 'P_sel_trav_ano';
    --
    OPEN c_sel_trav_ano;
    LOOP
      FETCH c_sel_trav_ano INTO r_sel_trav_ano;
      EXIT
    WHEN c_sel_trav_ano%NOTFOUND;
      g_lib_ano := SUBSTR (r_sel_trav_ano.lib_ano, 1, 132);
      g_niv_msg := 1;
      g_msg_adm := g_lib_ano;
      p_ins_journal;
    END LOOP;
    CLOSE c_sel_trav_ano;
    --
  EXCEPTION
  WHEN OTHERS THEN
    g_niv_msg := 0;
    g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
    p_ins_journal;
    --
    g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 125);
    g_erreur  := g_msg_adm;
    p_ins_journal;
    --
  END;
  --
PROCEDURE p_fin_traitement
IS
BEGIN
  --
  g_proc := 'P_fin_traitement';
  --
  g_niv_msg := 1;
  g_msg_adm := 'Fin Normale du traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
  p_ins_journal;
  --
  CLOSE c_sel_numcpte;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  --
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 125);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END;
--
PROCEDURE p_corps_sel_numcpte
IS
BEGIN
  --
  g_proc := 'P_CORPS_sel_numcpte';
  --
  DELETE trav_prelevement;

  BEGIN
    IF g_jour_prelev IS NULL THEN
      --si le paramètre n'est pas valorisé, il est initié à la du jour
      --il est ensuite surchargé dans le curseur à date réelle d'échéance
      --un prélèvement ne pouvant se demander à date passée
      g_eche_collect := sysdate;
    ELSE
      g_eche_collect := e2d(g_jour_prelev||'/'||g_mois_prelev||'/'||to_char(sysdate,'YYYY'));
      g_niv_msg := 0;
      g_msg_adm := 'Date de collecte du prélèvement au '|| g_eche_collect;
      p_ins_journal;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      g_eche_collect := sysdate;
      g_niv_msg := 0;
      g_msg_adm := 'Forçage de la date de collecte du prélèvement au '|| g_eche_collect;
      p_ins_journal;
  END;
  g_eche_prelev       :='00';
  g_numremise         := g_numremise + 1;
  g_numremise_deb     := g_numremise;
  --
  p_select_facture;
  p_verif_trav_prelevement; -- ajout SEPA prelevements
  p_sel_trav_prelevement;
  --
  g_proc := 'P_CORPS_sel_numcpte';
  g_proc := g_proc || ' - Ins remise_prelev';
  --

  INSERT
  INTO remise_prelev
    (
      numremise,
      numcpte,
      datrem,
      nombre,
      montant,
      monnaie,
      montant_d,
      monnaie_d,
      valide,
      eche_prelev,
      eche_prelev_sepa,
      typesepa -- SEPA : ajout du 03/11/2013 : pour identifier remise SEPA ou non
    )
  SELECT numremise,
    numcpte,
    TRUNC (SYSDATE),
    COUNT (DISTINCT numprelev),
    SUM (montant),
    monnaie,
    SUM (montant_d),
    monnaie_d,
    'N',
    substr(eche_prelev,1,4),
    eche_prelev , -- SEPA : TLE, 07/01/2014 : ajout de la date d echeance sur 8 caractères
    g_typeSEPA -- SEPA : ajout du 03/11/2013 : pour identifier remise SEPA ou non
  FROM trav_prelevement
  WHERE trav_prelevement.numremise BETWEEN g_numremise_deb AND NVL (g_numremise_fin, g_numremise_deb )
  AND valide    = 'O'
  AND montant   > 0
  AND montant_d > 0
  GROUP BY numremise,
    numcpte,
    monnaie,
    monnaie_d,
    eche_prelev;
  --
  g_proc := 'P_CORPS_sel_numcpte';
  g_proc := g_proc || ' - Ins prelevement';
  --

  INSERT
  INTO prelevement
    (
      numremise,
      numprelev,
      montant,
      monnaie,
      montant_d,
      monnaie_d,
      codbque,
      guichet,
      compte,
      clerib,
      intitule,
      eche_prelev
    , bban
    , clef_iban
    , bic
    , NUMQUERABLE
    , IDHISTOMANDAT
    , MANDAT
    , CREATE_MANDAT
    , MVT
    , MAJ
    , STATUT
    , amdt_ics
    , amdt_mndt
    , amdt_acct
    , amdt_smnda
    , amdt_creancier
    , numremise_prec -- MUR ajout constitution
    )
  SELECT numremise,
    numprelev,
    SUM (montant),
    monnaie,
    SUM (montant_d),
    monnaie_d,
    codbque,
    guichet,
    compte,
    clerib,
    intitule,
    eche_prelev
  , bban
  , clef_iban
  , bic
  , NUMQUERABLE
  , IDHISTOMANDAT
  , MANDAT
  , MIN(CREATE_MANDAT)
  , MVT
  , MAJ
  , STATUT
  , amdt_ics
  , amdt_mndt
  , amdt_acct
  , amdt_smnda
  , amdt_creancier
  , numremise_prec -- MUR ajout constitution
  FROM trav_prelevement
  WHERE trav_prelevement.numremise BETWEEN g_numremise_deb AND NVL (g_numremise_fin, g_numremise_deb )
  AND valide                     = 'O'
  AND montant                    > 0
  AND trav_prelevement.montant_d > 0
  GROUP BY trav_prelevement.numremise,
    trav_prelevement.numprelev,
    trav_prelevement.monnaie,
    trav_prelevement.monnaie_d,
    trav_prelevement.codbque,
    trav_prelevement.guichet,
    trav_prelevement.compte,
    trav_prelevement.clerib,
    trav_prelevement.intitule,
    trav_prelevement.eche_prelev
  , trav_prelevement.bban
  , trav_prelevement.clef_iban
  , trav_prelevement.bic
  , trav_prelevement.NUMQUERABLE
  , trav_prelevement.IDHISTOMANDAT
  , trav_prelevement.MANDAT
  --, trav_prelevement.CREATE_MANDAT
  , trav_prelevement.MVT
  , trav_prelevement.MAJ
  , trav_prelevement.STATUT
  , trav_prelevement.amdt_ics
  , trav_prelevement.amdt_mndt
  , trav_prelevement.amdt_acct
  , trav_prelevement.amdt_smnda
  , trav_prelevement.amdt_creancier
  , trav_prelevement.numremise_prec  ; -- MUR ajout constitution
  --
  g_proc := 'P_CORPS_sel_numcpte';
  g_proc := g_proc || ' - Ins prelevement_detail';
  --

  INSERT
  INTO prelevement_detail
    (
      numprelev,
      codope,
      numfact,
      idaffec,
      montant,
      monnaie,
      montant_d,
      monnaie_d,
      valide
    )
  SELECT DISTINCT numprelev,
    codope,
    numfact,
    idaffec,
    montant,
    monnaie,
    montant_d,
    monnaie_d,
    valide
  FROM trav_prelevement
  WHERE trav_prelevement.numremise BETWEEN g_numremise_deb AND NVL (g_numremise_fin, g_numremise_deb )
  AND valide = 'O';
  --
  g_proc := 'P_CORPS_sel_numcpte';
  g_proc := g_proc || ' - Ins compte_client';
  --

  INSERT
  INTO compte_client
    (
      idaffec,
      codope,
      numcli,
      numencaismt,
      monnaie,
      monnaie_d,
      datope,
      montant,
      montant_d,
      numfact,
      idcompta
    )
  SELECT prelevement_detail.idaffec,
    prelevement_detail.codope,
    facture.numcli,
    0,
    prelevement_detail.monnaie,
    prelevement_detail.monnaie_d,
    TRUNC (SYSDATE),
    prelevement_detail.montant,
    prelevement_detail.montant_d,
    prelevement_detail.numfact,
    -1
  FROM prelevement_detail,
    prelevement,
    facture
  WHERE prelevement.numremise BETWEEN g_numremise_deb AND NVL (g_numremise_fin, g_numremise_deb )
  AND prelevement.numprelev = prelevement_detail.numprelev
  AND facture.codope        = prelevement_detail.codope
  AND facture.numfact       = prelevement_detail.numfact;
  --
  -- MUR ajout constitution : appel nouvelle procedure
  if g_typeSEPA IN  (1,2) then
    p_mandat_constit;
  end if;

EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  --
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 125);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END;
--
PROCEDURE p_sel_trav_prelevement
IS
  r_sel_trav_prelevement c_sel_trav_prelevement%ROWTYPE;
  --
  loc_numremise trav_prelevement.numremise%TYPE;
  loc_eche_prelev prelevement.eche_prelev%TYPE;
BEGIN
  --

  g_proc := 'P_sel_trav_prelevement';
  --
  OPEN c_sel_trav_prelevement;
  LOOP
    FETCH c_sel_trav_prelevement INTO r_sel_trav_prelevement;
    EXIT
  WHEN c_sel_trav_prelevement%NOTFOUND;
    g_codbque       :=r_sel_trav_prelevement.codbque;
    g_guichet       :=r_sel_trav_prelevement.guichet;
    g_compte        :=r_sel_trav_prelevement.compte;
    g_clerib        :=r_sel_trav_prelevement.clerib;
    g_intitule      :=r_sel_trav_prelevement.intitule;
    loc_numremise   :=r_sel_trav_prelevement.numremise;
    loc_eche_prelev :=r_sel_trav_prelevement.eche_prelev;
    g_bban          :=r_sel_trav_prelevement.bban;
    g_clef_iban     :=r_sel_trav_prelevement.clef_iban;
    g_bic           :=r_sel_trav_prelevement.bic;

    SELECT numprelev.NEXTVAL INTO g_numprelev FROM DUAL;
    --

    UPDATE trav_prelevement
    SET trav_prelevement.numprelev                              = g_numprelev
    WHERE trav_prelevement.numremise                            = loc_numremise
    AND trav_prelevement.codbque                                = g_codbque
    AND trav_prelevement.guichet                                = g_guichet
    AND trav_prelevement.compte                                 = g_compte
    AND trav_prelevement.clerib                                 = g_clerib
    AND trav_prelevement.intitule                               = g_intitule
    AND trav_prelevement.eche_prelev                            = loc_eche_prelev
    AND DECODE(trav_prelevement.bban        , g_bban        , 1, 0) = 1
    AND DECODE(trav_prelevement.clef_iban   , g_clef_iban   , 1, 0) = 1
    AND DECODE(NVL(trav_prelevement.bic,'0'), NVL(g_bic,'0'), 1, 0) = 1
    AND valide                                                  = 'O'
    -- SEPA mantis 4291 debut ajout
    and trav_prelevement.NUMQUERABLE    =   r_sel_trav_prelevement.NUMQUERABLE
    and ((trav_prelevement.IDHISTOMANDAT  =   r_sel_trav_prelevement.IDHISTOMANDAT)
         or (trav_prelevement.IDHISTOMANDAT is null and r_sel_trav_prelevement.IDHISTOMANDAT is null))
    -- SEPA mantis 4291 fin ajout

    ;
    --
    g_niv_msg := 3;
    g_msg_adm := 'upd trav_prelev n° ' || TO_CHAR (g_numprelev) || ' - ' || 'remise n° ' || TO_CHAR (loc_numremise);
    p_ins_journal;
    --
  END LOOP;
  CLOSE c_sel_trav_prelevement;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 125);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END;
--
PROCEDURE p_select_facture
IS
  r_select_facture c_select_facture%ROWTYPE;
  loc_temp number ;
  --
BEGIN
  --
  g_proc := 'P_select_facture';
  --

  OPEN c_select_facture (g_eche_collect) ;
  LOOP
    FETCH c_select_facture INTO r_select_facture;
    EXIT
  WHEN c_select_facture%NOTFOUND;
    g_facture_codope         := r_select_facture.codope;
    g_facture_numfact        := r_select_facture.numfact;
    g_facture_numcli         := r_select_facture.numcli;
    g_contrat_numgar         := r_select_facture.numgar;
    g_idadhesion             := r_select_facture.idadhesion;
    g_facture_montant        := r_select_facture.montant - NVL (f_totaffec (r_select_facture.numfact, r_select_facture.codope ), 0 );
    g_facture_monnaie        := r_select_facture.monnaie;
    g_facture_montant_d      := r_select_facture.montant_d - NVL (f_totaffec_d (r_select_facture.numfact, r_select_facture.codope ), 0 );
    g_facture_monnaie_d      := r_select_facture.monnaie_d;

    IF g_eche_prelev <> to_char(r_select_facture.date_collect,'DDMMYYYY')THEN
      IF g_eche_prelev <> '00' THEN
        g_numremise          := g_numremise + 1;
      END IF;
      g_eche_prelev:=to_char(r_select_facture.date_collect,'DDMMYYYY');
    END IF;
    --
    SELECT idaffec.NEXTVAL INTO g_idaffec FROM DUAL;
    --
    --jbn 24/03/11 ajout de la devise

    g_idrib := pk_treso.f_idrib (g_facture_numcli, 2, g_facture_codope, g_contrat_numgar, SYSDATE, g_idadhesion, g_facture_monnaie_d);

    -- ajout MUR 30/01/2014 : pour prise en compte du spécifique EPAI pour regroupement adhesion/pret
    -- solution : à partir de idrib trouvé ci-dessus, le but est de recuperer l'idrib correspondant au mandat maitre
    BEGIN
      g_idrib_pret := 0 ;
      g_contrat_numgar_pret := 0 ;
      g_idadhesion_pret := 0 ;
      g_facture_numcli_pret := 0 ;


      select HM2.idrib , HQ2.numgar , HQ2.idadhesion , hq2.numquerable
             into g_idrib_pret , g_contrat_numgar_pret , g_idadhesion_pret , g_facture_numcli_pret
      from HISTO_MANDAT
      INNER JOIN HISTO_QUERABLE ON (HISTO_QUERABLE.MANDAT = HISTO_MANDAT.MANDAT
                                AND HISTO_QUERABLE.NUMGAR = g_contrat_numgar
                                AND HISTO_QUERABLE.IDADHESION = g_idadhesion
                                AND HISTO_QUERABLE.NUMQUERABLE = g_facture_numcli
                                AND HISTO_QUERABLE.ETAT <> 0
                                AND HISTO_QUERABLE.MANDAT != HISTO_QUERABLE.MANDAT_MAITRE )
      INNER JOIN HISTO_MANDAT HM2 on (HISTO_QUERABLE.MANDAT_MAITRE = HM2.MANDAT
                                  and HM2.statut <> 0 )
      INNER JOIN HISTO_QUERABLE HQ2 on (HISTO_QUERABLE.MANDAT_MAITRE = HQ2.MANDAT)
      where
          HISTO_MANDAT.idrib = g_idrib
      AND HISTO_MANDAT.idhistomandat = (SELECT MAX(idhistomandat) FROM HISTO_MANDAT a  WHERE a.mandat = HISTO_MANDAT.MANDAT)
      AND HISTO_MANDAT.statut <> 0
      ;

      g_idrib := g_idrib_pret ;
      g_contrat_numgar := g_contrat_numgar_pret ;
      g_idadhesion := g_idadhesion_pret ;
      g_facture_numcli := g_facture_numcli_pret ;
    EXCEPTION
      when no_data_found then null;
      when others then raise EXC_MANDAT_MAITRE ; -- MUR le 01/07/2014
    END ;
    -- fin ajout MUR


-- TLE : SEPA : AJOUT DES COLONNES LIEES AU MANDAT DANS LA TABLE trav_prelevement
INSERT
    INTO trav_prelevement
      (trav_prelevement.numremise,
        trav_prelevement.numcpte,
        trav_prelevement.numprelev,
        trav_prelevement.codope,
        trav_prelevement.numfact,
        trav_prelevement.idaffec,
        trav_prelevement.montant,
        trav_prelevement.monnaie,
        trav_prelevement.montant_d,
        trav_prelevement.monnaie_d,
        trav_prelevement.codbque,
        trav_prelevement.guichet,
        trav_prelevement.compte,
        trav_prelevement.clerib,
        trav_prelevement.intitule,
        trav_prelevement.valide,
        trav_prelevement.eche_prelev
      , trav_prelevement.bban
      , trav_prelevement.clef_iban
      , trav_prelevement.bic
      , trav_prelevement.NUMQUERABLE
      , trav_prelevement.IDHISTOMANDAT
      , trav_prelevement.MANDAT
      , trav_prelevement.CREATE_MANDAT
      , trav_prelevement.MVT
      , trav_prelevement.MAJ
      , trav_prelevement.STATUT
      , trav_prelevement.amdt_ics
      , trav_prelevement.amdt_mndt
      , trav_prelevement.amdt_acct
      , trav_prelevement.amdt_smnda
      , trav_prelevement.amdt_creancier
      , trav_prelevement.numremise_prec -- MUR ajout constitution
      , trav_prelevement.idadhesion
      , trav_prelevement.numgar
      , trav_prelevement.fribvalide
      )
    SELECT g_numremise,
      g_numcpte,
      0,
      g_facture_codope,
      g_facture_numfact,
      g_idaffec,
      g_facture_montant,
      g_facture_monnaie,
      g_facture_montant_d,
      g_facture_monnaie_d,
      NVL (rib.codbque, '0000'),
      NVL (rib.guichet, '0000'),
      NVL (rib.compte, '0000'),
      NVL (rib.clerib, '00'),
      NVL (rib.intitule, '0000'),
      DECODE (rib.ROWID, NULL, 'N', 'O'),
      g_eche_prelev
    , rib.bban
    , rib.clef_iban
    , rib.bic
    , HISTO_QUERABLE.NUMQUERABLE
    , HISTO_MANDAT.IDHISTOMANDAT
    , HISTO_QUERABLE.MANDAT
    , HISTO_QUERABLE.CREATION
    , HISTO_MANDAT.MVT
    , HISTO_MANDAT.MAJ
    , HISTO_MANDAT.STATUT
    , HISTO_MANDAT.amdt_ics
    , HISTO_MANDAT.amdt_mndt
    , HISTO_MANDAT.amdt_acct
    , HISTO_MANDAT.amdt_smnda
    , HISTO_MANDAT.amdt_creancier
    , HISTO_MANDAT.numremise -- MUR ajout constitution
    , HISTO_QUERABLE.idadhesion
    , HISTO_QUERABLE.numgar
    , f_rib_valide (g_idrib)
    FROM rib
    INNER JOIN HISTO_MANDAT ON  (HISTO_MANDAT.idrib = rib.idrib )
    INNER JOIN HISTO_QUERABLE ON (HISTO_QUERABLE.MANDAT = HISTO_MANDAT.MANDAT
                                  AND HISTO_QUERABLE.NUMGAR = g_contrat_numgar
                                  AND HISTO_QUERABLE.IDADHESION = g_idadhesion
                                  AND HISTO_QUERABLE.NUMQUERABLE = g_facture_numcli
                                  AND HISTO_QUERABLE.ETAT = 1 ) -- MUR ajout V6 14/01/2014 : ne pas prendre les mandats inactifs ou résiliés
    WHERE rib.idrib = g_idrib
    AND rib.modpmt             = 2
    AND f_rib_valide (g_idrib) IN (1,2)
    -- ajout selection idhistomandat max  + exclusion mandat inactifs
    AND HISTO_MANDAT.idhistomandat = (SELECT MAX(idhistomandat) FROM HISTO_MANDAT a  WHERE a.mandat = HISTO_MANDAT.MANDAT)
    AND HISTO_MANDAT.statut <> 0
    UNION
    SELECT g_numremise,
      g_numcpte,
      0,
      g_facture_codope,
      g_facture_numfact,
      g_idaffec,
      g_facture_montant,
      g_facture_monnaie,
      g_facture_montant_d,
      g_facture_monnaie_d,
      '0000',
      '0000',
      TO_CHAR (g_facture_numcli),
      '00',
      '0000',
      'N',
      g_eche_prelev
    , NULL
    , NULL
    , NULL
    , null , null, null, null, null, null, null, null, null, null, null,null,null,null,null
    , f_rib_valide (g_idrib)
    FROM rib
    WHERE rib.idrib              = g_idrib
    AND ( f_rib_valide (g_idrib) = 0
         OR (rib.modpmt <> 2 AND f_rib_valide (g_idrib) IN (1,2))
         );

    -- MUR le 24/04/2014
    -- affichage des anomalies de mandat (mandat non trouvé) => facture non prise en compte dans le bordereau
    BEGIN
      SELECT 1 into loc_temp
      from trav_prelevement
      where trav_prelevement.numfact = g_facture_numfact
      ;
    EXCEPTION
      when no_data_found then
        g_niv_msg := 1;
        g_msg_adm := 'Mandat non trouvé : numgar ' || g_contrat_numgar || '-idadhesion ' || g_idadhesion || '-numquerable ' || g_facture_numcli || '-facture ' || g_facture_numfact ;
        p_ins_journal;
		when too_many_rows then
		        g_niv_msg := 1;
		        g_msg_adm := 'PLusieurs Mandats trouvés : numgar ' || g_contrat_numgar || '-idadhesion ' || g_idadhesion || '-numquerable ' || g_facture_numcli || '-facture ' || g_facture_numfact ;
		        p_ins_journal;
		      when others then
		        g_niv_msg := 1;
		        g_msg_adm := 'Anomalie sur mandat : numgar ' || g_contrat_numgar || '-idadhesion ' || g_idadhesion || '-numquerable ' || g_facture_numcli || '-facture ' || g_facture_numfact ;
		        p_ins_journal;
    	END ;



 --
  END LOOP;
  --
  g_numremise_fin := g_numremise;
  --
  CLOSE c_select_facture;
  --
EXCEPTION
WHEN OTHERS THEN
  g_niv_msg := 0;
  g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
  p_ins_journal;
  --
  g_niv_msg := 1;
  g_msg_adm := 'Anomalie sur mandat : numgar ' || g_contrat_numgar || '-idadhesion ' || g_idadhesion || '-numquerable ' || g_facture_numcli || '-facture ' || g_facture_numfact ;
  p_ins_journal;
  g_msg_adm := TO_CHAR (SQLCODE) || '-' || SUBSTR (SQLERRM (SQLCODE), 1, 125);
  g_erreur  := g_msg_adm;
  p_ins_journal;
  --
END;
--
-- Fin des procedures publiques

/*
PROCEDURE P_ANNUL_PV03T (i_numremise IN prelevement.numremise%TYPE DEFAULT NULL)
IS
    cursor c_annul_constit is
        select a.mandat , a.IDHISTOMANDAT , a.NUMREMISE_PREC , a.MVT , a.MAJ ,  b.IDHISTOMANDAT as IDHISTOMANDAT_UPDT
        from prelevement a
        inner join histo_mandat b on (a.mandat = b.mandat and b.numremise=i_numremise )
        where a.numremise = i_numremise ;
    r_annul_constit c_annul_constit%rowtype ;
    loc_typesepa number;
BEGIN
    Delete compte_client
    Where (codope,numfact,numencaismt) in
        (Select codope,numfact,0
        From prelevement_detail
        Where prelevement_detail.numprelev in
            (select numprelev
            from prelevement
            where prelevement.numremise=i_numremise));

    Delete prelevement_detail
    Where prelevement_detail.numprelev in
        (select numprelev
        from prelevement
        where prelevement.numremise=i_numremise
        );

    --annulation p_mandat_constit si typesepa = 1 (modif du 03/12/2013)
    select typesepa into loc_typesepa from remise_prelev where numremise = i_numremise ;
    if loc_typesepa = 1 then
      begin
          for r_annul_constit in c_annul_constit loop
              if r_annul_constit.idhistomandat <> r_annul_constit.idhistomandat_updt then
                  delete from histo_mandat where idhistomandat =  r_annul_constit.idhistomandat_updt ;
              else
                  update histo_mandat set MVT = r_annul_constit.MVT , MAJ = r_annul_constit.MAJ , NUMREMISE = r_annul_constit.numremise_prec
                  where idhistomandat =  r_annul_constit.idhistomandat ;
              end if ;
          end loop ;
      end ;
    end if ;


    Delete prelevement
    Where prelevement.numremise=i_numremise;

    Delete remise_prelev
    Where remise_prelev.numremise=i_numremise;

END P_ANNUL_PV03T;
*/



-- =================================================================================================
-- PROCEDURE P_ANNUL_CONSTIT_MANDAT
-- Annuler les modifications liées au mandat lors de sa constitution
-- TLE - 03/12/13 - PRELEVEMENT SEPA
-- =================================================================================================
PROCEDURE P_ANNUL_CONSTIT_MANDAT(
    i_numremise_prec     IN prelevement.numremise%TYPE DEFAULT NULL,
    i_idhistomandat      IN prelevement.idhistomandat%TYPE,
    i_idhistomandat_updt IN prelevement.idhistomandat%TYPE,
    i_MVT                IN prelevement.MVT%TYPE,
    i_MAJ                IN prelevement.MAJ%TYPE
    )
IS
BEGIN
  IF i_idhistomandat <> i_idhistomandat_updt THEN
    DELETE FROM histo_mandat
    WHERE idhistomandat = i_idhistomandat_updt;
  ELSE
    UPDATE
      histo_mandat
    SET
       MVT       = i_MVT,
       MAJ       = i_MAJ,
       NUMREMISE = i_numremise_prec
    WHERE
      idhistomandat = i_idhistomandat;
  END IF ;
END P_ANNUL_CONSTIT_MANDAT;




-- =================================================================================================
-- PROCEDURE P_ANNUL_PV03T
--
-- mur - 03/12/13 - PRELEVEMENT SEPA
-- =================================================================================================
PROCEDURE P_ANNUL_PV03T (i_numremise IN prelevement.numremise%TYPE DEFAULT NULL)
IS
    cursor c_annul_constit is
        select a.mandat , a.IDHISTOMANDAT , a.NUMREMISE_PREC , a.MVT , a.MAJ ,  b.IDHISTOMANDAT as IDHISTOMANDAT_UPDT
        from prelevement a
        inner join histo_mandat b on (a.mandat = b.mandat and b.numremise=i_numremise )
        where a.numremise = i_numremise ;
    r_annul_constit c_annul_constit%rowtype ;
    loc_typesepa number;
BEGIN
    Delete compte_client
    Where (codope,numfact,numencaismt) in
        (Select codope,numfact,0
        From prelevement_detail
        Where prelevement_detail.numprelev in
            (select numprelev
            from prelevement
            where prelevement.numremise=i_numremise));

    Delete prelevement_detail
    Where prelevement_detail.numprelev in
        (select numprelev
        from prelevement
        where prelevement.numremise=i_numremise
        );

    --annulation p_mandat_constit si typesepa = 1 (modif du 03/12/2013)
    select typesepa into loc_typesepa from remise_prelev where numremise = i_numremise ;
    if loc_typesepa = 1 then
      begin
          for r_annul_constit in c_annul_constit loop
              P_ANNUL_CONSTIT_MANDAT( r_annul_constit.numremise_prec,
                                      r_annul_constit.idhistomandat,
                                      r_annul_constit.idhistomandat_updt,
                                      r_annul_constit.MVT,
                                      r_annul_constit.MAJ);
          end loop ;
      end ;
    end if ;


    Delete prelevement
    Where prelevement.numremise=i_numremise;

    Delete remise_prelev
    Where remise_prelev.numremise=i_numremise;

END P_ANNUL_PV03T;



--
-- CORPS DES PROCEDURES ET FONCTIONS PRIVEES
--

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_mandat_constit                                          */
/* Type         :  Privee                                                    */
/* Description  :  Constitution de l'entete de la reponse du flux XML        */
/* Entree       :  P_emet, donnée emise                                      */
/*                 P_emet_sup, donnée emise supplémentaire                   */
/*                 P_dest, donnée Destinataire                               */
/*                 P_dest_sup, donnée Destinataire supplémentaire            */
/*                 P_flux, Flux XML d entrée                                 */
/*                 P_code                                                    */
/*---------------------------------------------------------------------------*/
PROCEDURE p_mandat_constit
IS
  CURSOR c_sel_idhistomandat
  IS select distinct NUMREMISE , IDHISTOMANDAT , MVT , STATUT , MAJ , NUMREMISE_PREC
      from PRELEVEMENT
      where PRELEVEMENT.NUMREMISE BETWEEN g_numremise_deb AND NVL (g_numremise_fin, g_numremise_deb ) ;
  r_sel_idhistomandat c_sel_idhistomandat%ROWTYPE ;
BEGIN
  FOR r_sel_idhistomandat in c_sel_idhistomandat loop
    IF r_sel_idhistomandat.STATUT = 1 then -- update pour les mandats non amendés
      update HISTO_MANDAT set MVT = 'RCUR' , MAJ = trunc(sysdate) , NUMREMISE = r_sel_idhistomandat.numremise
      where IDHISTOMANDAT = r_sel_idhistomandat.idhistomandat;
    ELSIF r_sel_idhistomandat.STATUT = 2 then -- insert pour les mandats amendés
      --  mur le 26/06/2014 : on force le statut à actif + mvt à RCUR et amndt à null
      insert into HISTO_MANDAT (IDHISTOMANDAT
                                ,MANDAT
                                ,MAJ
                                ,STATUT
                                ,IDRIB
                                ,MVT
                                ,NUMREMISE
                                ,AMDT_ICS
                                ,AMDT_MNDT
                                ,AMDT_ACCT
                                ,AMDT_SMNDA
                                ,AMDT_CREANCIER
                                ,CREATION) -- MUR ajout le 09/07/2014
      select IDHISTOMANDAT.NEXTVAL
            ,MANDAT
            ,trunc(sysdate)
            ,1
            ,IDRIB
            ,'RCUR' --MVT
            ,r_sel_idhistomandat.numremise
            ,null --AMDT_ICS
            ,null --AMDT_MNDT
            ,null --AMDT_ACCT
            ,null --AMDT_SMNDA
            ,null --AMDT_CREANCIER
            ,sysdate -- MUR ajout le 09/07/2014
      FROM HISTO_MANDAT
      where IDHISTOMANDAT = r_sel_idhistomandat.idhistomandat ;
    END IF;
  END LOOP ;
END p_mandat_constit;

-- Recherche du prochain idligne
--
FUNCTION f_max_idligne(
    i_session IN journal_adm.id_session%TYPE)
  RETURN NUMBER
IS
  l_idligne NUMBER;
BEGIN
  SELECT NVL (MAX (idligne), 0)
  INTO l_idligne
  FROM journal_adm
  WHERE id_session = i_session;
  --
  RETURN (l_idligne);
  --
END f_max_idligne;
--
-- Insertion dans journal_adm
--
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
-- Fin des corps des procedures privees --
END;
/
