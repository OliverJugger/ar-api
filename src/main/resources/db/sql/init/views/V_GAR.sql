CREATE FORCE VIEW ARTHUS.V_GAR AS
SELECT	2 etendue,
		grnts.numgar clef,
		grnts.refcie,
		gar_cntrt.nomgar nomgar,
		gar_cntrt.numfor numfor,
		gar_cntrt.libelle libgar,
		gar_cntrt.datapli datapli,
		gar_cntrt.datper  datper,
		gar_cntrt.valide  valide,
		gar_cntrt.type  typfor
	FROM	gar_cntrt,grnts
	WHERE	grnts.numgar  = gar_cntrt.numgar
UNION
SELECT	2 etendue,
		grnts.numgar clef,
		grnts.refcie,
		'' nomgar,
		 0 numfor,
		'Global contrat' libgar,
		grnts.dateff,
		grnts.dateff,
		'' valide,
		 0 typfor
	FROM	grnts
UNION
	SELECT	7,
		produit.numprod,
		produit.libelle,
		'',
		 0,
		'Global produit',
		deffet,
		deffet,
		'',
		 0
	FROM	produit
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
		1
	FROM	produit,frmls
	WHERE	frmls.numprod = produit.numprod
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
		2
	FROM	produit,gar
	WHERE	produit.numprod = gar.cle
	and	gar.etendue = 7
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR FOR ARTHUS.V_GAR
