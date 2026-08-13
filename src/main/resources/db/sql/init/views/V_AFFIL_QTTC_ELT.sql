CREATE FORCE VIEW ARTHUS.V_AFFIL_QTTC_ELT AS
SELECT SUM(mt_elt) MT_ELT
      , elt.type_elt
	  , NVL(f_lble('BASE_COT',elt.type_elt), elt.type_elt || ' : inconnu') LIB_TYPE_ELT
	  , adh.code_pop
	  , adh.code_opt
	  --, aq.REF_EXT_CNTRT
	  , TRUNC(af.datefic,'Q') DATEFIC_Q
	  ,to_char(aq.deb_base,'YYYY')|| ' T'||to_char(aq.deb_base,'Q') PERIODE
	  , af.numcli
	  , adh.numgar
	  , elt.id_variable
	  , elt.statut
	  , af.numporte
	  , aq.numquit
FROM AFFIL_PORTE_QTTC aq , AFFIL_PORTE_QTTC_ELT elt , affil_porte_adh adh, affil_fichier af,affil_porte ap
WHERE   aq.numremise = elt.numremise
AND   aq.numporte = elt.numporte
AND   aq.numligne = elt.numligne
AND   aq.num_qttc = elt.num_qttc
AND   aq.REF_EXT_ADH = elt.REF_EXT_ADH
AND   aq.REF_EXT_ADH = adh.REF_EXT_ADH
AND   adh.REF_EXT_CNTRT = aq.REF_EXT_CNTRT
AND   adh.numremise =ap.numremise
AND   adh.numporte = ap.numporte
AND   adh.numligne = ap.numligne
AND   aq.numremise =ap.numremise
AND   aq.numporte = ap.numporte
AND   aq.numligne = ap.numligne
AND   af.numremise =ap.numremise
AND   af.numporte = ap.numporte
AND   ap.ENTREPRISE = af.ENTREPRISE
AND   ap.etabli = af.etabli
AND   ap.num_ordre = af.num_ordre
AND   ap.etat <>4
AND af.num_annulante IS NULL
group by elt.type_elt,adh.code_opt,adh.code_pop, to_char(aq.deb_base,'YYYY'),to_char(aq.deb_base,'Q'), af.numcli,adh.numgar, trunc(af.datefic,'Q'), elt.id_variable,  elt.statut,af.numporte , aq.numquit
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFIL_QTTC_ELT FOR ARTHUS.V_AFFIL_QTTC_ELT
