CREATE FORCE VIEW ARTHUS.V_PORTE_ASS AS
SELECT	porte_adhesion.numindiv,
		porte_adhesion.numporte,
		contrat.numgar,
		contrat.numinterm,
		contrat.numorg,
		translate(contrat.refcie,'.','@') refcie,
		libelle_bis.code dpt,
		translate(libelle_bis.libelle,'.','@') libelle_dpt,
		to_char(porte_adhesion.debut,'dd/mm/yyyy') debut,
		to_char(porte_adhesion.fin,'dd/mm/yyyy') fin,
		porte_adhesion.idadhesion
	FROM	libelle_bis,
		indvs,
		porte_adhesion,
		adhe_cntrt,
		contrat
	WHERE	libelle_bis.mnemo='DEPT'
	AND	libelle_bis.code>'0'
	AND	substr(indvs.codpos,1,2)=libelle_bis.code
	AND	adhe_cntrt.numgar=contrat.numgar
	AND	adhe_cntrt.idadhesion=porte_adhesion.idadhesion
	AND	indvs.numindiv=porte_adhesion.numindiv
	UNION all
	SELECT	indvs.numindiv,
		-1,
		contrat.numgar,
		contrat.numinterm,
		contrat.numorg,
		translate(contrat.refcie,'.','@') refcie,
		libelle_bis.code dpt,
		translate(libelle_bis.libelle,'.','@') libelle_dpt,
		'',
		'',
		adhe_cntrt.idadhesion
	FROM
		libelle_bis,
		indvs,
		adhe_cntrt_membre,
		adhe_cntrt,
		contrat
	WHERE	substr(indvs.codpos,1,2)=libelle_bis.code
	AND	libelle_bis.mnemo='DEPT'
	AND	libelle_bis.code>'0'
	AND	adhe_cntrt_membre.numindiv=indvs.numindiv
	AND	adhe_cntrt.idadhesion=adhe_cntrt_membre.idadhesion
	AND	adhe_cntrt.numgar=contrat.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PORTE_ASS FOR ARTHUS.V_PORTE_ASS
