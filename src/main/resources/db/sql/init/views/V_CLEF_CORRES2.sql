CREATE FORCE VIEW ARTHUS.V_CLEF_CORRES2 AS
SELECT	3 etendue,
	client.numgar numgar,
	client.numindiv clef,
	to_char(client.numindiv) clef_deux
FROM	client
union
SELECT	distinct
	0,
	adhesion.numgar,
	adhesion.numindiv,
	to_char(adhesion.numindiv)
FROM	adhesion
union
SELECT	distinct
	4,
	adhesion.numgar,
	adhesion.numindiv,
	to_char(adhesion.numindiv)
FROM	adhesion
union
SELECT	libelle.code,
	grnts.numgar,
	decode(libelle.code,
		2,grnts.numgar,
		5,grnts.numorg,
		7,grnts.numprod,
		9,grnts.numinterm),
	decode(libelle.code,
		2,grnts.refcie,
		5,to_char(orgns.numorg),
		7,to_char(grnts.numprod),
		9,societe.refsoc)
FROM	grnts,orgns,societe,libelle
WHERE	grnts.numinterm   = societe.numsoc
AND	grnts.numorg   = orgns.numorg
AND	libelle.mnemo='CONTE'
AND	libelle.code in (2,5,7,9)
union
SELECT	0,
	grnts.numgar,
	decode(libelle.code,
		3,grnts.numcli,
		5,orgns.numorg,
		9,grnts.numinterm),
	decode(libelle.code,
		3,to_char(grnts.numcli),
		5,to_char(orgns.numorg),
		9,societe.refsoc)
FROM	grnts,orgns,societe,libelle
WHERE	grnts.numinterm   = societe.numsoc
AND	grnts.numorg   = orgns.numorg
AND	libelle.mnemo='CONTE'
AND	libelle.code in (3,5,9)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CLEF_CORRES2 FOR ARTHUS.V_CLEF_CORRES2
