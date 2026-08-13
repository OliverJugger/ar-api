CREATE FORCE VIEW ARTHUS.V_EXPORT_ASS AS
SELECT 	noemie.numindiv,
		noemie.mouvement,
		decode(noemie.mouvement,'C',1,'M',2,'A',3) type_mouvement,
		decode(noemie.mouvement,'C','Nombre de Créations','M',
			'Nombre de Modifications',
			'A','Nombre d''Annulations') lib_mouvement,
		contrat.numinterm,
		contrat.numorg,
		contrat.numgar,
		translate(contrat.refcie,'.','@') refcie,
	 	trpnt.caisse,
		substr(translate(trpnt.nom,'.','@'),1,45) nom_caisse,
		noemie.numporte,
		remise_externe.date_remise
	FROM 	trpnt,
		contrat,
		adhe_cntrt,
		noemie,
		remise_externe
	WHERE	noemie.caisse=trpnt.caisse
	AND	contrat.numgar=adhe_cntrt.numgar
	AND	trpnt.type_tiers=1
	AND	noemie.idadhesion=adhe_cntrt.idadhesion
	AND	noemie.numremise=remise_externe.numremise
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EXPORT_ASS FOR ARTHUS.V_EXPORT_ASS
