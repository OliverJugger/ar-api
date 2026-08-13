CREATE FORCE VIEW ARTHUS.V_RUBRIQUE AS
SELECT	2 etendue,
		grnts.numgar clef,
		grnts.refcie,
		gar_cntrt.nomgar nomgar,
		gar_cntrt.numfor numfor,
		gar_cntrt.libelle libgar,
		gar_cntrt.datapli datapli,
		gar_cntrt.datper  datper,
		gar_cntrt.valide  valide,
		gar_cntrt.type  typfor,
		ntfrs.codfrais rubrique,
		ntfrs.libelle lib_rubrique
	FROM	gar_cntrt,grnts,ntfrs
	WHERE	grnts.numgar  = gar_cntrt.numgar
	And	ntfrs.type=1
UNION
SELECT	2 etendue,
		grnts.numgar clef,
		grnts.refcie,
		'' nomgar,
		 0 numfor,
		'Toutes Garanties' libgar,
		sysdate,
		sysdate,
		'' valide,
		 0 typfor,
		ntfrs.codfrais,
		ntfrs.libelle
	FROM	grnts,ntfrs
	Where	ntfrs.type=1
UNION
	SELECT	7,
		produit.numprod,
		produit.libelle,
		'',
		 0,
		'Toutes Garanties',
		sysdate,
		sysdate,
		'',
		 0,
		ntfrs.codfrais,
		ntfrs.libelle
	FROM	produit,ntfrs
	Where	ntfrs.type=1
UNION
	SELECT	7,
		produit.numprod,
		produit.libelle,
		frmls.nomgar,
		frmls.numfor,
		frmls.libelle,
		nvl(frmls.debut,produit.deffet),
		frmls.fin,
		frmls.valide,
		1,
		ntfrs.codfrais,
		ntfrs.libelle
	FROM	produit,frmls,ntfrs
	WHERE	frmls.numprod = produit.numprod
	And	ntfrs.type=1
UNION
	SELECT	7,
		produit.numprod,
		produit.libelle,
		gar.nomgar,
		gar.numfor,
		gar.libelle,
		gar.debut,
		gar.fin,
		gar.valide,
		2,
		'',
		''
	FROM	produit,gar
	WHERE	produit.numprod = gar.cle
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RUBRIQUE FOR ARTHUS.V_RUBRIQUE
