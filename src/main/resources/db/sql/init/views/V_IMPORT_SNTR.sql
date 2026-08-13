CREATE FORCE VIEW ARTHUS.V_IMPORT_SNTR AS
SELECT	sntrprt.numindiv,
		sntrprt.numremise numremise_externe,
		sntrprt.numsin,
		sntrprt.refdec,
		contrat.numinterm,
		contrat.numorg,
		contrat.numgar,
		translate(contrat.refcie,'.','@') refcie,
	 	trpnt.caisse,
		substr(translate(trpnt.nom,'.','@'),1,45) nom_caisse,
		porte_remise.numporte,
		porte_remise.dateremise
	FROM	contrat,
		adhe_cntrt,
		trpnt,
		sntrprt,
		porte_remise
	WHERE	contrat.numgar = adhe_cntrt.numgar
	AND	adhe_cntrt.idadhesion = ARTHUS.pk_noemie.f_idadhesion(
						porte_remise.dateremise,
						sntrprt.numindiv )
	AND	trpnt.type_tiers = 1
	AND	trpnt.caisse = ARTHUS.pk_noemie.f_caisse( porte_remise.dateremise,
						   sntrprt.numindiv)
	AND	sntrprt.numremise = porte_remise.numremise
	Union
	SELECT	sntrprt.numindiv,
		0,
		sntrprt.numsin,
		sntrprt.refdec,
		0,
		0,
		-1,
		'Sans rattachement',
	 	'0',
		'caisse inconnue',
		sntrprt.numporte,
		porte_remise.dateremise
	FROM	sntrprt,
		porte_remise
	WHERE	sntrprt.numremise=porte_remise.numremise
	AND	sntrprt.numporte=porte_remise.numporte
	AND	ARTHUS.pk_noemie.f_caisse( porte_remise.dateremise,
				    sntrprt.numindiv) IS Null
GO
CREATE OR REPLACE PUBLIC SYNONYM V_IMPORT_SNTR FOR ARTHUS.V_IMPORT_SNTR
