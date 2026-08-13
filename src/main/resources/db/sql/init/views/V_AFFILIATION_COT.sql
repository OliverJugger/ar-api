CREATE FORCE VIEW ARTHUS.V_AFFILIATION_COT AS
SELECT ap.numporte
	,ap.numremise
	,ap.numligne
	,ap.entreprise
	,ap.etabli
	,af.numcli
	,ap.num_ordre 
	,ap.numindiv
	,adh.numgar
	,aq.numquit
	,af.datefic
	,aq.deb_base
	,aq.fin_base
	,ind.mt_base
	,elt.type_elt
	,f_lble('BASE_COT',elt.type_elt) lib_elt
	,elt.id_variable
    ,elt.mt_elt
	,elt.valeur
	,elt.statut
FROM AFFIL_PORTE_CNTRT ac, AFFIL_FICHIER af, AFFIL_PORTE ap,AFFIL_PORTE_ADH adh, 
AFFIL_PORTE_QTTC_INDIV ind, AFFIL_PORTE_QTTC aq , AFFIL_PORTE_QTTC_ELT elt
WHERE ac.numremise = af.numremise
AND ac.numporte = af.numporte
AND ac.ENTREPRISE = af.ENTREPRISE
AND ac.etabli = af.etabli
AND ac.num_ordre = af.num_ordre   
AND ac.numremise = ap.numremise
AND ac.numporte = ap.numporte
AND ac.ENTREPRISE = ap.ENTREPRISE
AND ac.etabli = ap.etabli
AND ac.num_ordre = ap.num_ordre    
AND adh.numremise = ac.numremise
AND ac.numremise = aq.numremise
AND adh.REF_EXT_CNTRT = ac.REF_EXT_CNTRT
AND adh.REF_EXT_CNTRT = aq.REF_EXT_CNTRT
AND adh.REF_EXT_ADH = aq.REF_EXT_ADH
AND adh.numligne = aq.numligne
AND adh.numligne = ap.numligne
AND   aq.num_qttc = ind.num_qttc
AND   aq.numligne = ind.numligne
AND   aq.numporte = ind.numporte
AND   aq.numremise = ind.numremise
AND   aq.numremise = elt.numremise
AND   aq.numporte = elt.numporte
AND   aq.numligne = elt.numligne
AND   aq.num_qttc = elt.num_qttc
AND   aq.REF_EXT_ADH = elt.REF_EXT_ADH
AND   af.num_annulante is NULL
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFILIATION_COT FOR ARTHUS.V_AFFILIATION_COT
