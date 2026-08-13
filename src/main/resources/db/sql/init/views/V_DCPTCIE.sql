CREATE FORCE VIEW ARTHUS.V_DCPTCIE AS
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
    dcptcie,
    v_assur_delegat
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
  AND v_assur_delegat.numass     = dcptcie.numorg
  AND sinistre.numfor            = v_assur_delegat.numfor
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
    dcptcie,
    v_assur_delegat
  WHERE dcptcie.TYPE                 = 1
  AND decaismt_prest.numdcptcie_init = dcptcie.numdcptcie
    -- AND decaismt_prest.numdcptcie_sin_init = sinistre.numdcptcie
  AND sinistre.numdcptcie       <= dcptcie.numdcptcie
  AND sinistre.numdec            = affectation_prest.numaffec
  AND decompte_annul.numdec      = sinistre.numdec
  AND affectation_prest.codope   = 1
  AND decaismt_prest.codope      = 1
  AND decaismt_prest.numdecaismt = affectation_prest.numdecaismt
  AND sinistre.numfor            = gar_cntrt.numfor
  AND sinistre.numgar            = contrat.numgar  
  AND v_assur_delegat.numass     = dcptcie.numorg
  AND sinistre.numfor            = v_assur_delegat.numfor
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
    dcptcie,
    v_assur_delegat
  WHERE dcptcie.TYPE           = 1
  AND ((pnul.numdcptcie          = dcptcie.numdcptcie
      AND pnul.numdcptcie_sin      = sinistre.numdcptcie)
   OR (dcptcie.numdcptcie = sinistre.numdcptcie))
  AND sinistre.numdec          = affectation_prest.numaffec
  AND decompte_annul.numdec    = sinistre.numdec
  AND affectation_prest.codope = 1
  AND pnul.numdecaismt         = affectation_prest.numdecaismt
  AND pnul.codope              = 1
    -- AND pnul.numdecaismt = decaismt_prest.numdecaismt
  AND sinistre.numfor = gar_cntrt.numfor
  AND sinistre.numgar = contrat.numgar       
  AND v_assur_delegat.numass     = dcptcie.numorg
  AND sinistre.numfor            = v_assur_delegat.numfor
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
    dcptcie,
    v_assur_delegat
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
  AND v_assur_delegat.numass     = dcptcie.numorg
  AND sinistre.numfor            = v_assur_delegat.numfor
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
    CASE
       WHEN SUM(compte_client.montant) > 0 THEN ROUND(sinistre.mtreel*(SUM(compte_client.montant)/affectation_prest.montant),2)
       ELSE ROUND(-sinistre.mtreel*(SUM(compte_client.montant)/affectation_prest.montant),2)
    END   montant,
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
  GROUP BY
    dcptcie.numdcptcie,
    dcptcie.numsoc,
    dcptcie.numorg,
    contrat.numorg,
    dcptcie.datedeb,
    dcptcie.datefin,
    dcptcie.TYPE,
    contrat.numgar,
    contrat.refcie,
    contrat.refcie_chapeau,
    contrat.numcli,
    encaismt.numencaismt,
    encaismt.refpmt,
    TO_CHAR (encaismt.datpay, 'dd/mm/yyyy') ,
    encaismt.numcli,
    sinistre.numdec ,
    sinistre.numdec ,
    TO_CHAR (sinistre.datsin, 'yyyy'),
    sinistre.idadhesion,
    sinistre.numfor,
    gar_cntrt.nomgar,
    sinistre.mtreel,
    affectation_prest.montant
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTCIE FOR ARTHUS.V_DCPTCIE
