CREATE FORCE VIEW ARTHUS.V_PORTE_SNTR AS
SELECT	sntr.numsin,
		1 trait,
		-1 numporte,
		contrat.numgar,
		contrat.numinterm,
		contrat.numorg,
		translate(contrat.refcie,'.','@') refcie,
		sntr.username numutil,
		translate(util.nom,'.','@') util,
		sntr.datsai
	FROM
		util,
		indvs,
		sntr,
		contrat
	WHERE	sntr.username=util.numutil
	AND	sntr.numindiv=indvs.numindiv
	AND	sntr.flagam='a'
	AND	contrat.numgar=sntr.numgar
	UNION
	SELECT	sntr.numsin,
		2,
		sntrprt.numporte,
		contrat.numgar,
		contrat.numinterm,
		contrat.numorg,
		translate(contrat.refcie,'.','@') refcie,
		sntrprt.username_forcage,
		translate(util.nom,'.','@') util,
		sntr.datsai
	FROM	util,
		indvs,
		porte_param,
		sntr_ref,
		sntrprt,
		sntr,
		contrat
	WHERE	sntrprt.username_forcage=porte_param.numutil
	AND	porte_param.numutil=util.numutil
	AND	sntr.numindiv=indvs.numindiv
	AND	sntrprt.numporte=porte_param.numporte
	AND	sntr.numsin=sntr_ref.numsin
	AND	sntr_ref.numremise=sntrprt.numremise
	AND	sntr_ref.numsin_porte=sntrprt.numsin
	AND	sntr.flagam='p'
	AND	contrat.numgar=sntr.numgar
	UNION
	SELECT	sntr.numsin,
		3,
		sntrprt.numporte,
		contrat.numgar,
		contrat.numinterm,
		contrat.numorg,
		translate(contrat.refcie,'.','@') refcie,
		sntrprt.username_forcage,
		translate(util.nom,'.','@') util,
		sntr.datsai
	FROM	util,
		indvs,
		porte_param,
		sntr_ref,
		sntrprt,
		sntr,
		contrat
	WHERE	sntrprt.username_forcage=util.numutil
	AND	porte_param.numutil!=util.numutil
	AND	sntr.numindiv=indvs.numindiv
	AND	sntrprt.numporte=porte_param.numporte
	AND	sntr.numsin=sntr_ref.numsin
	AND	sntr_ref.numremise=sntrprt.numremise
	AND	sntr_ref.numsin_porte=sntrprt.numsin
	AND	sntr.flagam='p'
	AND	contrat.numgar=sntr.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PORTE_SNTR FOR ARTHUS.V_PORTE_SNTR
