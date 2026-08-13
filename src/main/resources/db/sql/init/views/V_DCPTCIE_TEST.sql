CREATE FORCE VIEW ARTHUS.V_DCPTCIE_TEST AS
SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    ARTHUS.pk_personne.f_nom (f_numorg (contrat.numorg, 2), 30, 2) nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    ARTHUS.pk_personne.f_nom (contrat.numcli, 30, 0) nomcli,
    decaismt_prest.numdecaismt,
    decaismt_prest.refpmt,
    TO_CHAR (decaismt_prest.datpay, 'dd/mm/yyyy') edatpay,
    decaismt_prest.numbene,
    ARTHUS.pk_personne.f_nom (decaismt_prest.numbene, 30, 0) nombene,
    -1 typdedu,
    'Prestations' lib_type,
    sinistre.numdec idpmtint,
    sinistre.numdec nosin,
    TO_CHAR (sinistre.datsin, 'yyyy') exercice,
    '' datesurv,
    (sinistre.mtreel) montant,
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar
  FROM contrat,
    gar_cntrt,
    sinistre,
    affectation affectation_prest,
    decaismt decaismt_prest,
    dcptcie
  WHERE dcptcie.TYPE                 = 1
  AND dcptcie.numdcptcie             = sinistre.numdcptcie
  AND decaismt_prest.numdcptcie_sin != sinistre.numdcptcie
  AND sinistre.numdec                = affectation_prest.numaffec
  AND affectation_prest.codope       = 1
  AND decaismt_prest.codope          = 1
  AND decaismt_prest.numdecaismt     = affectation_prest.numdecaismt
  AND sinistre.numfor                = gar_cntrt.numfor
  AND sinistre.numgar                = contrat.numgar
  /* Décaissement ancien*/
  UNION ALL

  /*
  Décaissement nouveau suite maj annulation
  */
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    ARTHUS.pk_personne.f_nom (f_numorg (contrat.numorg, 2), 30, 2) nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    ARTHUS.pk_personne.f_nom (contrat.numcli, 30, 0) nomcli,
    decaismt_prest.numdecaismt,
    decaismt_prest.refpmt,
    TO_CHAR (decaismt_prest.datpay, 'dd/mm/yyyy') edatpay,
    decaismt_prest.numbene,
    ARTHUS.pk_personne.f_nom (decaismt_prest.numbene, 30, 0) nombene,
    -1 typdedu,
    'Prestations' lib_type,
    sinistre.numdec idpmtint,
    sinistre.numdec nosin,
    TO_CHAR (sinistre.datsin, 'yyyy') exercice,
    '' datesurv,
    (sinistre.mtreel) montant,
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar
  FROM contrat,
    gar_cntrt,
    sinistre,
    affectation affectation_prest,
    decaismt decaismt_prest,
    dcptcie
  WHERE dcptcie.TYPE            = 1
  AND decaismt_prest.numdcptcie = dcptcie.numdcptcie
    -- AND decaismt_prest.numdcptcie_sin = sinistre.numdcptcie
  AND dcptcie.numorg =
    (SELECT numorg FROM dcptcie WHERE numdcptcie = sinistre.numdcptcie
    ) -- AND sinistre.numdcptcie <= dcptcie.numdcptcie
  AND sinistre.numdec            = affectation_prest.numaffec
  AND affectation_prest.codope   = 1
  AND decaismt_prest.codope      = 1
  AND decaismt_prest.numdecaismt = affectation_prest.numdecaismt
  AND sinistre.numfor            = gar_cntrt.numfor
  AND sinistre.numgar            = contrat.numgar
  UNION ALL

  /*
  Décaissement annulé : pas de sinistre_annul généré
  */
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    ARTHUS.pk_personne.f_nom (f_numorg (contrat.numorg, 2), 30, 2) nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    ARTHUS.pk_personne.f_nom (contrat.numcli, 30, 0) nomcli,
    decaismt_prest.numdecaismt,
    decaismt_prest.refpmt,
    TO_CHAR (decaismt_prest.datpay, 'dd/mm/yyyy') edatpay,
    decaismt_prest.numbene,
    ARTHUS.pk_personne.f_nom (decaismt_prest.numbene, 30, 0) nombene,
    -1 typdedu,
    'Prestations' lib_type,
    sinistre.numdec idpmtint,
    sinistre.numdec nosin,
    TO_CHAR (sinistre.datsin, 'yyyy') exercice,
    '' datesurv,
    (sinistre.mtreel) montant,
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar
  FROM contrat,
    gar_cntrt,
    sinistre,
    affectation_annul affectation_prest,
    decaismt decaismt_prest,
    pnul,
    dcptcie
  WHERE dcptcie.TYPE             = 1
  AND pnul.numdcptcie            = dcptcie.numdcptcie
  AND pnul.numdecaismt           = decaismt_prest.numdecaismt
  AND pnul.numdcptcie_sin_init   = sinistre.numdcptcie
  AND decaismt_prest.numdcptcie  = pnul.numdcptcie
  AND sinistre.numdec            = affectation_prest.numaffec
  AND affectation_prest.codope   = 1
  AND decaismt_prest.codope      = 1
  AND decaismt_prest.numdecaismt = affectation_prest.numdecaismt
  AND sinistre.numfor            = gar_cntrt.numfor
  AND sinistre.numgar            = contrat.numgar
  AND NOT EXISTS
    (SELECT 1
    FROM sinistre_annul
    WHERE numsin = sinistre.numsin
    AND numdec   = sinistre.numdec
    )
  UNION ALL

  /*
  Prestations payées : pour les décomptes annulés
  */
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    ARTHUS.pk_personne.f_nom (f_numorg (contrat.numorg, 2), 30, 2) nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    ARTHUS.pk_personne.f_nom (contrat.numcli, 30, 0) nomcli,
    decaismt_prest.numdecaismt,
    decaismt_prest.refpmt,
    TO_CHAR (decaismt_prest.datpay, 'dd/mm/yyyy') edatpay,
    decompte_annul.numbene,
    ARTHUS.pk_personne.f_nom (decompte_annul.numbene, 30, 0) nombene,
    -1 typdedu,
    'Prestations' lib_type,
    sinistre.numdec idpmtint,
    sinistre.numdec nosin,
    TO_CHAR (sinistre.datsin, 'yyyy') exercice,
    '' datesurv,
    (sinistre.mtreel) montant,
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar
  FROM contrat,
    gar_cntrt,
    sinistre_annul sinistre,
    affectation_annul affectation_prest,
    decompte_annul,
    pnul decaismt_prest,
    dcptcie
  WHERE dcptcie.TYPE                 = 1
  AND decaismt_prest.numdcptcie_init = dcptcie.numdcptcie
    -- AND decaismt_prest.numdcptcie_sin_init = sinistre.numdcptcie
  AND sinistre.numdcptcie_init       <= dcptcie.numdcptcie
  AND sinistre.numdec            = affectation_prest.numaffec
  AND decompte_annul.numdec      = sinistre.numdec
  AND affectation_prest.codope   = 1
  AND decaismt_prest.codope      = 1
  AND decaismt_prest.numdecaismt = affectation_prest.numdecaismt
  AND sinistre.numfor            = gar_cntrt.numfor
  AND sinistre.numgar            = contrat.numgar
  UNION ALL

  /*
  Annulations : On prend les montants en négatif parce que l'annulation du décompte crée des lignes positives dans sinistre_annul
  ajout
  AND pnul.numdcptcie = sinistre.numdcptcie
  pour toutes les annulations PHA 17/11/2010
  */
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    ARTHUS.pk_personne.f_nom (f_numorg (contrat.numorg, 2), 30, 2) nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    ARTHUS.pk_personne.f_nom (contrat.numcli, 30, 0) nomcli,
    pnul.numdecaismt,
    pnul.refpmt,
    TO_CHAR (pnul.datannul, 'dd/mm/yyyy') edatpay,
    decompte_annul.numbene,
    ARTHUS.pk_personne.f_nom (decompte_annul.numbene, 30, 0) nombene,
    -1 typdedu,
    'Annnulations' lib_type,
    sinistre.numdec idpmtint,
    sinistre.numdec nosin,
    TO_CHAR (sinistre.datsin, 'yyyy') exercice,
    '' datesurv,
    - (sinistre.mtreel) montant,
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar
  FROM contrat,
    gar_cntrt,
    sinistre_annul sinistre,
    affectation_annul affectation_prest,
    -- decaismt decaismt_prest, decompte annulé, décaissement supprimé... 16/11/2010
    decompte_annul,
    pnul,
    dcptcie
  WHERE dcptcie.TYPE           = 1
  AND pnul.numdcptcie          = dcptcie.numdcptcie
  AND pnul.numdcptcie_sin      = sinistre.numdcptcie
  AND sinistre.numdec          = affectation_prest.numaffec
  AND decompte_annul.numdec    = sinistre.numdec
  AND affectation_prest.codope = 1
  AND pnul.numdecaismt         = affectation_prest.numdecaismt
  AND pnul.codope              = 1
    -- AND pnul.numdecaismt = decaismt_prest.numdecaismt
  AND sinistre.numfor = gar_cntrt.numfor
  AND sinistre.numgar = contrat.numgar
  UNION ALL

  /*
  Annulations : Ici Décaissement désaffecté
  */
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    ARTHUS.pk_personne.f_nom (f_numorg (contrat.numorg, 2), 30, 2) nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    ARTHUS.pk_personne.f_nom (contrat.numcli, 30, 0) nomcli,
    decaismt_prest.numdecaismt,
    decaismt_prest.refpmt,
    TO_CHAR (pnul.datannul, 'dd/mm/yyyy') edatpay,
    decaismt_prest.numbene,
    ARTHUS.pk_personne.f_nom (decaismt_prest.numbene, 30, 0) nombene,
    -1 typdedu,
    'Annnulations' lib_type,
    sinistre.numdec idpmtint,
    sinistre.numdec nosin,
    TO_CHAR (sinistre.datsin, 'yyyy') exercice,
    '' datesurv,
    - (sinistre.mtreel) montant,
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar
  FROM contrat,
    gar_cntrt,
    sinistre,
    affectation_annul affectation_prest,
    decaismt decaismt_prest,
    pnul,
    dcptcie
  WHERE dcptcie.TYPE           = 1
  AND pnul.numdcptcie          = dcptcie.numdcptcie
  AND pnul.numdcptcie_sin_init = sinistre.numdcptcie
  AND sinistre.numdec          = affectation_prest.numaffec
  AND affectation_prest.codope = 1
  AND pnul.numdecaismt         = affectation_prest.numdecaismt
  AND pnul.codope              = 1
  AND pnul.numdecaismt         = decaismt_prest.numdecaismt
  AND sinistre.numfor          = gar_cntrt.numfor
  AND sinistre.numgar          = contrat.numgar
  AND NOT EXISTS
    (SELECT 1
    FROM sinistre_annul
    WHERE numsin = sinistre.numsin
    AND numdec   = sinistre.numdec
    )
  UNION ALL

  /*
  Indus : On prend les montants tels quels parce que le sinistre annulé donnant lieu à indu est en négatif dans sinistre, en négatif dans décompte mais par contre, il est en positif dans compte_client
  */
  SELECT dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    ARTHUS.pk_personne.f_nom (f_numorg (contrat.numorg, 2), 30, 2) nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    ARTHUS.pk_personne.f_nom (contrat.numcli, 30, 0) nomcli,
    encaismt.numencaismt,
    encaismt.refpmt,
    TO_CHAR (encaismt.datpay, 'dd/mm/yyyy') edatpay,
    encaismt.numcli,
    ARTHUS.pk_personne.f_nom (encaismt.numcli, 30, 0) nombene,
    -1 typdedu,
    'Indus' lib_type,
    sinistre.numdec idpmtint,
    sinistre.numdec nosin,
    TO_CHAR (sinistre.datsin, 'yyyy') exercice,
    '' datesurv,
    sinistre.mtreel montant,
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar
  FROM contrat,
    gar_cntrt,
    sinistre sinistre,
    affectation affectation_prest,
    compte_client,
    encaismt,
    dcptcie
  WHERE dcptcie.TYPE             = 1
  AND dcptcie.numdcptcie         = sinistre.numdcptcie
  AND sinistre.numdec            = affectation_prest.numaffec
  AND affectation_prest.codope   = 1
  AND affectation_prest.numaffec = compte_client.numfact
  AND compte_client.codope       = 1
  AND compte_client.numencaismt  = encaismt.numencaismt
  AND sinistre.numfor            = gar_cntrt.numfor
  AND sinistre.numgar            = contrat.numgar
    /*
    GLB  le 20070722 mise en commentaire de la partie prévoyance pour optimisation vue chez gerep
    union all
    select   dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    orgns.nom nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.type,
    to_char(sin.datesurv,'yyyy') exercice,
    contrat.refcie_chapeau,
    decaismt_prest.numdecaismt,
    decaismt_prest.refpmt,
    to_char(decaismt_prest.datpay,'dd/mm/yyyy') edatpay,
    decaismt_prest.numbene,
    indvs_bene.nom||' '||indvs_bene.prenom nombene,
    contrat.refcie,
    contrat.numgar,
    to_char(sin.datesurv,'dd/mm/yy') datesurv,
    -1 typdedu,
    'Prestations' lib_type,
    decompte_prev.numdec,
    decompte_prev.numdec nosin,
    v_histo_calcul.montant_remb,
    contrat.numcli,
    indvs_cli.nom||' '||indvs_cli.prenom nomcli,
    decompte_prev.idadhesion idadhesion,
    gar_cntrt.nomgar,
    v_histo_calcul.numfor
    from  dcptcie,
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
    where dcptcie.numdcptcie = decompte_prev.numdcptcie
    and   dcptcie.type = 2
    and   affectation_prest.numaffec = decompte_prev.numdec
    and   decaismt_prest.numdecaismt = affectation_prest.numdecaismt
    and   decaismt_prest.codope = 2
    and   affectation_prest.codope = 2
    and   indvs_bene.numindiv   = decaismt_prest.numbene
    and   indvs_cli.numindiv=contrat.numcli
    and   contrat.numgar = adhe_cntrt.numgar
    and   contrat.numgar = gar_cntrt.numgar
    and   adhe_cntrt.idadhesion=decompte_prev.idadhesion
    and   v_histo_calcul.numfor=gar_cntrt.numfor
    and   v_histo_calcul.nosin = sin.nosin
    and   v_histo_calcul.numdec=decompte_prev.numdec
    and   orgns.numorg = dcptcie.numorg
    union all
    select   dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    orgns.nom nomorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.type,
    to_char(sin.datesurv,'yyyy') exercice,
    contrat.refcie_chapeau,
    encaismt_prest.numencaismt,
    encaismt_prest.refpmt,
    to_char(encaismt_prest.datpay,'dd/mm/yyyy') edatpay,
    encaismt_prest.numcli,
    indvs_bene.nom||' '||indvs_bene.prenom nombene,
    contrat.refcie,
    contrat.numgar,
    to_char(sin.datesurv,'dd/mm/yy') datesurv,
    -1 typdedu,
    'Indus de prestations' lib_type,
    decompte_prev.numdec,
    decompte_prev.numdec nosin,
    v_histo_calcul.montant_remb,
    contrat.numcli,
    indvs_cli.nom||' '||indvs_cli.prenom nomcli,
    decompte_prev.idadhesion idadhesion,
    gar_cntrt.nomgar,
    v_histo_calcul.numfor
    from  dcptcie,
    contrat,
    adhe_cntrt,
    gar_cntrt,
    encaismt encaismt_prest,
    compte_client,
    affectation affectation_prest,
    decompte_prev,
    v_histo_calcul,
    indvs indvs_bene,
    indvs indvs_cli,
    sin,
    orgns
    where dcptcie.numdcptcie = decompte_prev.numdcptcie
    and   dcptcie.type = 2
    and   affectation_prest.numaffec = decompte_prev.numdec
    and   compte_client.numfact = affectation_prest.numaffec
    and   encaismt_prest.numencaismt = compte_client.numencaismt
    and   affectation_prest.codope = 2
    and   compte_client.codope = 2
    and   indvs_bene.numindiv   = encaismt_prest.numcli
    and   indvs_cli.numindiv=contrat.numcli
    and   decompte_prev.idadhesion=adhe_cntrt.idadhesion
    and   contrat.numgar = adhe_cntrt.numgar
    and   contrat.numgar = gar_cntrt.numgar
    and   v_histo_calcul.numfor=gar_cntrt.numfor
    and   v_histo_calcul.nosin = sin.nosin
    and   v_histo_calcul.numdec=decompte_prev.numdec
    and   orgns.numorg = dcptcie.numorg
    */
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTCIE_TEST FOR ARTHUS.V_DCPTCIE_TEST
