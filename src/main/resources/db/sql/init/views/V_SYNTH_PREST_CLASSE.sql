CREATE FORCE VIEW ARTHUS.V_SYNTH_PREST_CLASSE AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numinterm numsoc,
	f_assureur(v_histo_calcul.numfor) numorg,
	nvl(grnts.refcie_chapeau,'N') refcie_chapeau,
	grnts.numcli numcli,
	to_char(sin.datesurv,'yyyy') exercice,
	sin.datesurv,
	gar_cntrt.nomgar,
	' * '||rpad(gar_cntrt.nomgar,8, ' ') ||' - '||
	translate(gar_cntrt.libelle,'.','@') libgar,
	v_histo_calcul.numfor,
	v_histo_calcul.montant_remb montant,
	decompte_prev.numdcptcie numero,
	v_branche.branche
from	grnts,
	adhe_cntrt,
	gar_cntrt,
	sin,
	v_branche,
	v_histo_calcul,
	decompte_prev
Where	grnts.numgar 		= 	adhe_cntrt.numgar
and	adhe_cntrt.idadhesion	= 	decompte_prev.idadhesion
And	decompte_prev.numdcptcie!=	0
and	v_branche.numfor	=	v_histo_calcul.numfor
and	gar_cntrt.numfor	= 	v_histo_calcul.numfor
and	v_histo_calcul.nosin	= 	sin.nosin
and	v_histo_calcul.numdec	= 	decompte_prev.numdec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SYNTH_PREST_CLASSE FOR ARTHUS.V_SYNTH_PREST_CLASSE
