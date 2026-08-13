CREATE FORCE VIEW ARTHUS.V_SP AS
select	grnts.refcie,
	grnts.numgar,
	grnts.numinterm numsoc,
	substr(replace(societe.nom,'.','@'),1,20) nomsoc,
	grnts.numorg,
	substr(replace(orgns.nom,'.','@'),1,20) nomorg,
	grnts.numcli,
	substr(replace(indvs.nom,'.','@'),1,20) nomcli,
	grnts.numprod,
	substr(replace(produit.libelle,'.','@'),1,20) libprod,
	grnts.numquerable,
	grnts.dateff,
	qttc_gar.debut,
	qttc_gar.fin,
 	round(months_between(fin+1,debut),2) nb_mois,
	qttc_gar.mt_net montant,
	gar_cntrt.numfor_ref,
	substr(replace(gar_cntrt.libelle,'.','@'),1,35) libelle
from	grnts,
	gar_cntrt,
	qttc_gar,
	indvs,
	societe,
	produit,
	orgns
where	grnts.numgar=gar_cntrt.numgar
and	qttc_gar.numfor=gar_cntrt.numfor
and not exists (select qttc_global.numquit from qttc_global
		where comptant='R'
		and qttc_global.numquit=qttc_gar.numquit
	       )
and indvs.numindiv=grnts.numcli
and societe.numsoc=grnts.numinterm
and produit.numprod=grnts.numprod
and orgns.numorg=grnts.numorg
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SP FOR ARTHUS.V_SP
