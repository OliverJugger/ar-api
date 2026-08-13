CREATE FORCE VIEW ARTHUS.V_CLEF_CORRES AS
select	1					etendue,
	gar_cntrt.numgar			numgar,
	gar_cntrt.numfor			clef,
	to_char(gar_cntrt.numfor)		clef_deux
from	gar_cntrt
union
SELECT	3,
	client.numgar,
	client.numindiv,
	to_char(client.numindiv)
FROM	client
union
SELECT	distinct
	4,
	adhesion.numgar,
	adhesion.numindiv,
	to_char(adhesion.numindiv)
FROM	adhesion,
	indvs
WHERE	indvs.numindiv = adhesion.numindiv
AND	indvs.typassu = 1
union
SELECT	distinct
	12,
	adhesion.numgar,
	adhesion.numindiv,
	to_char(adhesion.numindiv)
FROM	adhesion
union
SELECT	distinct
	13,
	adhe_cntrt.numgar,
	adhe_cntrt.idadhesion,
	to_char(adhe_cntrt.idadhesion)
FROM	adhe_cntrt
union
SELECT	libelle.code,
	grnts.numgar,
	decode(libelle.code,
		2,grnts.numgar,
		5,grnts.numorg,
		7,grnts.numprod,
		8,grnts.numinterm,
		9,grnts.numinterm),
	decode(libelle.code,
		2,grnts.refcie,
		5,to_char(orgns.numorg),
		7,to_char(grnts.numprod),
		8,to_char(interm.numinterm),
		9,societe.refsoc)
FROM	contrat grnts,orgns,interm,societe,libelle
WHERE	grnts.numinterm   = societe.numsoc
AND	grnts.numorg   = orgns.numorg
AND	grnts.numinterm   = interm.numsoc
AND	libelle.mnemo='CONTE'
AND	libelle.code in (2,5,7,8,9)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CLEF_CORRES FOR ARTHUS.V_CLEF_CORRES
