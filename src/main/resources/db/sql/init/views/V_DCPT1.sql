CREATE FORCE VIEW ARTHUS.V_DCPT1 AS
select	distinct dcpt.numdec,
	dcpt.numgar,
	dcpt.datpay			odatedec,
	to_char(dcpt.datpay,'dd/mm/yy') datedec,
	grnts.refcie,
	dcpt.numindiv,
	assure.nom		nom_assu,
	assure.prenom		prenom_assu,
	assure.nom||' '||assure.prenom nomassu,
	assure.matorg,
	dcpt.typbene,
	dcpt.numbene,
	decode(dcpt.typbene, 1, 'L''assure', 2, 'L''organisme T.P.', 3, 'Le fournisseur', 4,'L''établissement','Autre organisme') lib_bene,
	bene.nom			nom_bene,
	bene.prenom			prenom_bene,
	bene.nom||' '||bene.prenom nombene,
	to_char(decaismt.datpay,'dd/mm/yy') datpay,
	decaismt.datpay				odatpay,
	f_lble('MOPM',decaismt.modpmt) libmodpmt,
	affectation.codope,
	decaismt.refpmt,
	affectation.numdecaismt,
	affectation.montant,
	affectation.monnaie,
	affectation.montant_d,
	affectation.monnaie_d,
	decaismt.modpmt,
	decaismt.numcpte,
	decaismt.numchq,
	dcpt.numutil,
	util.pseudo,
	decaismt.datedit,
	decaismt.numedit
from	dcpt,
	grnts,
	indvs assure,
	indvs bene,
	affectation,
	decaismt,
	util
where	dcpt.numgar	= grnts.numgar
and	dcpt.numindiv	= assure.numindiv
and	dcpt.numbene	= bene.numindiv
and	dcpt.numdec	= affectation.numaffec
and	affectation.codope	= 1
and	decaismt.numdecaismt(+) = affectation.numdecaismt
and	util.numutil	= dcpt.numutil
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPT1 FOR ARTHUS.V_DCPT1
