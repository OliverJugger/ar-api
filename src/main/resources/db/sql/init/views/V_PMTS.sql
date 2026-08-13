CREATE FORCE VIEW ARTHUS.V_PMTS AS
SELECT affectation.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , affectation.numaffec
    , affectation.numdecaismt
    , TRANSLATE ( 'Decpte maladie No ' || affectation.numaffec || ' Police No ' || grnts.refcie, '.', '@' ) lib_affec
    , decaismt.numbene
      -- TLE : DEBUT MODIF M3612
      --TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
     ,(indvs.nom || ' ' || indvs.prenom) nombene
     -- TLE : FIN MODIF M3612
    , decaismt.refpmt
    , affectation.montant
    , affectation.montant_d
    , TRUNC (decaismt.datpay) datpay
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    --, TRANSLATE (vs_compte.libcompte || ' ' || vs_compte.compte, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
    -- TLE : FIN MODIF M3612
   FROM affectation
    , dcpt
    , contrat grnts
    , decaismt
    , indvs
    , compte vs_compte
   WHERE dcpt.numdec        = affectation.numaffec
   AND grnts.numgar         = dcpt.numgar
   AND decaismt.numdecaismt = affectation.numdecaismt
   AND indvs.numindiv       = decaismt.numbene
   AND decaismt.numcpte     = vs_compte.numcpte
   AND decaismt.codope      = 1
   AND decaismt.flagpay     = 1
   UNION
   SELECT affectation.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , affectation.numaffec
    , affectation.numdecaismt
    , TRANSLATE ( 'Decpte prevoyance No ' || affectation.numaffec || ' Police No ' || grnts.refcie, '.', '@' ) lib_affec
    , decaismt.numbene
      -- TLE : DEBUT MODIF M3612
      -- TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
      ,(indvs.nom || ' ' || indvs.prenom) nombene
      -- TLE : FIN MODIF M3612
    , decaismt.refpmt
    , affectation.montant
    , affectation.montant_d
    , TRUNC (decaismt.datpay)
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    --, TRANSLATE ( vs_compte.libcompte || ' ' || vs_compte.domicil || ' ' || vs_compte.compte || ' ' || vs_compte.clerib || ' ' || vs_compte.rais_soc, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
    -- TLE : FIN MODIF M3612
   FROM affectation
    , decompte_prev
    , contrat grnts
    , adhe_cntrt
    , decaismt
    , indvs
    , compte vs_compte
   WHERE decompte_prev.numdec = affectation.numaffec
   AND grnts.numgar           = adhe_cntrt.numgar
   AND adhe_cntrt.idadhesion  = decompte_prev.idadhesion
   AND decaismt.numdecaismt   = affectation.numdecaismt
   AND indvs.numindiv         = decaismt.numbene
   AND decaismt.numcpte       = vs_compte.numcpte
   AND decaismt.codope        = 2
   AND decaismt.flagpay       = 1
   /*UNION  -- Mantis 5008  Pas besoin d'éditer les décaissements se trouvant dans Pnul
   -- ajout mantis M0003650
   SELECT decaismt.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , decaismt.numdecaismt
    , decaismt.numdecaismt
    , TRANSLATE ('Decaissement annulé N° ' || decaismt.numdecaismt, '.', '@' ) lib_affec
    , decaismt.numbene
      -- TLE : DEBUT MODIF M3612
      --TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
     ,(indvs.nom || ' ' || indvs.prenom) nombene
      -- TLE : FIN MODIF M3612
    , decaismt.refpmt
    , decaismt.montant
    , decaismt.montant_d
    , TRUNC (decaismt.datpay)
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    -- , TRANSLATE ( vs_compte.libcompte || ' ' || vs_compte.domicil || ' ' || vs_compte.compte || ' ' || vs_compte.clerib || ' ' || vs_compte.rais_soc, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
	-- TLE : FIN MODIF M3612
   FROM decaismt
    , indvs
    , compte vs_compte
   WHERE decaismt.codope = 2
   AND indvs.numindiv    = decaismt.numbene
   AND decaismt.numcpte  = vs_compte.numcpte
   AND decaismt.flagpay  = 1
      -- selection deciassement annulés
   AND EXISTS
      (SELECT 1
      FROM pnul
      WHERE pnul.numdecaismt = decaismt.numdecaismt
      )
	  */
   UNION
   -- fin ajout mantis 3650
   SELECT affectation.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , affectation.numaffec
    , affectation.numdecaismt
    , TRANSLATE ( affectation.numaffec || '-' || f_piece_detail (affectation.codope, affectation.numaffec ), '.', '@' ) lib_affec
    , decaismt.numbene
      -- TLE : DEBUT MODIF M3612
      --TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
     , (indvs.nom || ' ' || indvs.prenom) nombene
      -- TLE : FIN MODIF M3612
    , decaismt.refpmt
    , affectation.montant
    , affectation.montant_d
    , TRUNC (decaismt.datpay)
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    --, TRANSLATE ( vs_compte.libcompte || ' ' || vs_compte.domicil || ' ' || vs_compte.compte || ' ' || vs_compte.clerib || ' ' || vs_compte.rais_soc, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
	 -- TLE : FIN MODIF M3612
   FROM affectation
    , dcptdedu
    , decaismt
    , indvs
    , compte vs_compte
   WHERE dcptdedu.numdec    = affectation.numaffec
   AND decaismt.numdecaismt = affectation.numdecaismt
   AND indvs.numindiv       = decaismt.numbene
   AND decaismt.numcpte     = vs_compte.numcpte
   AND decaismt.codope      = 11
   AND decaismt.flagpay     = 1
   UNION
   SELECT affectation.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , affectation.numaffec
    , affectation.numdecaismt
    , TRANSLATE ( 'Reversement de cotisations Bx. N°' || affectation.numaffec, '.', '@' ) lib_affec
    , decaismt.numbene
      -- TLE : DEBUT MODIF M3612
      --TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
     , (indvs.nom || ' ' || indvs.prenom) nombene
      -- TLE : FIN MODIF M3612
    , decaismt.refpmt
    , affectation.montant
    , affectation.montant_d
    , TRUNC (decaismt.datpay)
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    --, TRANSLATE ( vs_compte.libcompte || ' ' || vs_compte.domicil || ' ' || vs_compte.compte || ' ' || vs_compte.clerib || ' ' || vs_compte.rais_soc, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
	-- TLE : FIN MODIF M3612
	FROM affectation
    , reversement
    , decaismt
    , indvs
    , compte vs_compte
   WHERE reversement.idrevers = affectation.numaffec
   AND decaismt.numdecaismt   = affectation.numdecaismt
   AND indvs.numindiv         = decaismt.numbene
   AND decaismt.numcpte       = vs_compte.numcpte
   AND decaismt.codope        = 5
   AND decaismt.flagpay       = 1
   UNION
   SELECT affectation.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , affectation.numaffec
    , affectation.numdecaismt
    , TRANSLATE ('Frais sur cotisations Bx. N° ' || affectation.numaffec, '.', '@' ) lib_affec
    , decaismt.numbene
    ,
      -- TLE : DEBUT MODIF M3612
      --TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
      (indvs.nom || ' ' || indvs.prenom) nombene
    ,
      -- TLE : FIN MODIF M3612
      decaismt.refpmt
    , affectation.montant
    , affectation.montant_d
    , TRUNC (decaismt.datpay)
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    --, TRANSLATE ( vs_compte.libcompte || ' ' || vs_compte.domicil || ' ' || vs_compte.compte || ' ' || vs_compte.clerib || ' ' || vs_compte.rais_soc, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
	-- TLE : DEBUT MODIF M3612
   FROM affectation
    , reversement
    , decaismt
    , indvs
    , vs_compte
   WHERE affectation.codope = 6
   AND reversement.idrevers = affectation.numaffec
   AND decaismt.numdecaismt = affectation.numdecaismt
   AND decaismt.refpmt     IS NOT NULL
   AND indvs.numindiv       = decaismt.numbene
   AND decaismt.numcpte     = vs_compte.numcpte
   UNION
   SELECT decaismt.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , decaismt.numdecaismt
    , decaismt.numdecaismt
    , TRANSLATE ('Remboursement compte client N° ' || decaismt.numdecaismt, '.', '@' ) lib_affec
    , decaismt.numbene
    ,
      -- TLE : DEBUT MODIF M3612
      --TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
      (indvs.nom || ' ' || indvs.prenom) nombene
    ,
      -- TLE : FIN MODIF M3612
      decaismt.refpmt
    , decaismt.montant
    , decaismt.montant_d
    , TRUNC (decaismt.datpay)
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    --, TRANSLATE ( vs_compte.libcompte || ' ' || vs_compte.domicil || ' ' || vs_compte.compte || ' ' || vs_compte.clerib || ' ' || vs_compte.rais_soc, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
	-- TLE : FIN MODIF M3612
   FROM decaismt
    , indvs
    , compte vs_compte
   WHERE decaismt.codope = 8
   AND indvs.numindiv    = decaismt.numbene
   AND decaismt.numcpte  = vs_compte.numcpte
   AND decaismt.flagpay  = 1
   UNION
   SELECT decaismt.codope
    , decaismt.numcpte
    , decaismt.monnaie
    , decaismt.monnaie_d
    , decaismt.modpmt
    , decaismt.numdecaismt
    , decaismt.numdecaismt
    , TRANSLATE ('Règlement fournisseur N° ' || decaismt.numdecaismt, '.', '@' ) lib_affec
    , decaismt.numbene
    ,
      -- TLE : DEBUT MODIF M3612
      --TRANSLATE (indvs.nom || ' ' || indvs.prenom, '.', '@') nombene,
      (indvs.nom || ' ' || indvs.prenom) nombene
    ,
      -- TLE : FIN MODIF M3612
      decaismt.refpmt
    , decaismt.montant
    , decaismt.montant_d
    , TRUNC (decaismt.datpay)
    , decaismt.numutil
    , vs_compte.numsoc
	-- TLE : DEBUT MODIF M3612
    --, TRANSLATE ( vs_compte.libcompte || ' ' || vs_compte.domicil || ' ' || vs_compte.compte || ' ' || vs_compte.clerib || ' ' || vs_compte.rais_soc, '.', '@' ) lib_banq
	, TRANSLATE (vs_compte.libcompte, '.', '@' ) lib_banq
	-- TLE : FIN MODIF M3612
   FROM decaismt
    , indvs
    , compte vs_compte
   WHERE decaismt.codope = 10
   AND indvs.numindiv    = decaismt.numbene
   AND decaismt.numcpte  = vs_compte.numcpte
   AND decaismt.flagpay  = 1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PMTS FOR ARTHUS.V_PMTS
