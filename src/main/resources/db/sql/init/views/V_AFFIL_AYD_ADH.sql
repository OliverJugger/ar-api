CREATE FORCE VIEW ARTHUS.V_AFFIL_AYD_ADH AS
SELECT adh.NUMREMISE
        , adh.NUMPORTE
        , adh.NUMLIGNE
        , adh.NUMADH
        , adh.NUMAYD
        , adh.REF_EXT_CNTRT
        , adh.REF_EXT_ADH
        , adh.CODE_OPT
        , adh.CODE_POP
        , adh.NB_ENF_CHARGE
        , adh.NB_AYD_ADULTE
        , adh.NB_AYD
        , adh.NB_AYD_AUTRE
        , adh.NB_AYD_ENF
        , adh.CONTRAT_SAL
        , adh.NUMINDIV
        , adh.NUMGAR
        , adh.IDADHESION
        , adh.REFGARANTIE
        , adh.RANG
        , adh.DEBUT
        , adh.FIN
        , ayd.TYPEAD
        , ayd.DATNAIS
        , ayd.NOM
        , ayd.NUMSSA
        , ayd.NUMSSOD
        , ayd.PRENOM
        , ayd.ORGN
        , ayd.DATEFINOD
        , ayd.NOMUSAGE
        , ayd.LIEUNAIS
        , ayd.NATUREAYD
        , ayd.SEXE
        , ayd.GROUPEAYD
        , ayd.REGIME
        , ayd.CAISSE
        , ayd.CENTRE
        , ayd.EDI
        , cntrt.REF_ORGN_CNTRT
     FROM AFFIL_PORTE_ADH adh
        , AFFIL_PORTE_AYD ayd
		, AFFIL_PORTE  ap
        , AFFIL_PORTE_CNTRT cntrt
    WHERE ayd.NUMREMISE = adh.NUMREMISE
      AND ayd.NUMPORTE = adh.NUMPORTE
      AND ayd.NUMLIGNE = adh.NUMLIGNE
	  AND ayd.NUMLIGNE = ap.NUMLIGNE
      AND ayd.NUMAYD = adh.NUMAYD
      AND cntrt.NUMREMISE = adh.NUMREMISE
      AND cntrt.NUMPORTE = adh.NUMPORTE
	  AND cntrt.NUMREMISE = ap.NUMREMISE
      AND cntrt.NUMPORTE = ap.NUMPORTE
	  AND cntrt.ENTREPRISE =ap.ENTREPRISE
	  AND cntrt.ETABLI = ap.ETABLI
	  AND cntrt.NUM_ORDRE =ap.NUM_ORDRE
      AND cntrt.ref_ext_cntrt = adh.ref_ext_cntrt
ORDER BY adh.NUMREMISE, adh.NUMPORTE, adh.NUMLIGNE, adh.NUMADH, adh.NUMAYD
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFIL_AYD_ADH FOR ARTHUS.V_AFFIL_AYD_ADH
