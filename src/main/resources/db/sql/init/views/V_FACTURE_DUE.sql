CREATE FORCE VIEW ARTHUS.V_FACTURE_DUE AS
select
	facture.codope,
	facture.numfact,
	facture.numcli,
	facture.montant,
	facture.monnaie,
	facture.datfact,
	to_char(facture.datfact,'dd/mm/yy') edatfact,
	nvl(f_totaffec(numfact, codope),0) mt_affec,
	nvl(facture.montant,0) - nvl(f_totaffec(numfact, codope),0) solde,
	libelle.libelle libope,
	facture.numcli||' -  '||indvs.nom||' '||indvs.prenom nomcli,
	facture.echeance
from	libelle,
	indvs,
	facture
where	libelle.mnemo = 'OPE'
and	libelle.code = facture.codope
and	indvs.numindiv = facture.numcli
and not exists 	(select 1
		 from 	qttc_global
		 where	facture.codope = 4
		 and	qttc_global.numquit = facture.numfact
		 and	qttc_global.comptant = 'R')
and not exists 	(select 1
		from	emission
		where	emission.codope = facture.codope
		and	emission.numfact = facture.numfact
		and	emission.numrelance in (4, 99) )
and not exists 	(select 1
		from	dcptcie
		where 	dcptcie.numdcptcie = facture.numfact
		and	facture.codope =12
		and	dcptcie.valide = 'N'
		)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACTURE_DUE FOR ARTHUS.V_FACTURE_DUE
