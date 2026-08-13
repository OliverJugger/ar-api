CREATE FORCE VIEW ARTHUS.V_DCPT AS
select	distinct dcpt.numdec,
	dcpt.numgar,
	to_char(dcpt.datpay,'dd/mm/yy') datedec,
	grnts.refcie,
	dcpt.numindiv,
	assure.nom||' '||assure.prenom nomassu,
	assure.matorg,
	dcpt.typbene,
	dcpt.numbene,
	decode(dcpt.typbene, 1, 'L''assure', 2, 'L''organisme T.P.', 3, 'Le fournisseur', 4,'L''établissement','Autre organisme') lib_bene,
	bene.nom||' '||bene.prenom nombene,
	to_char(decaismt.datpay,'dd/mm/yy') datpay,
	libelle.libelle libmodpmt,
	affectation.codope,
	decaismt.refpmt,
	affectation.numdecaismt,
	affectation.montant,
	monnaie.symbole,
	decaismt.numcpte,
	decaismt.numchq
from	dcpt, grnts, indvs assure, indvs bene, monnaie, libelle, affectation, decaismt
where	dcpt.numgar	= grnts.numgar
and	dcpt.numindiv	= assure.numindiv
and	dcpt.numbene	= bene.numindiv
and	dcpt.numdec	= affectation.numaffec
and	monnaie.codmon	= affectation.monnaie
and	libelle.mnemo(+)= 'MOPM'
and	libelle.code(+)	= decaismt.modpmt
and	affectation.codope	= 1
and	decaismt.numdecaismt(+) = affectation.numdecaismt
union
select	distinct decompte_prev.numdec,
	contrat.numgar,
	to_char(decompte_prev.datpay,'dd/mm/yy') datedec,
	contrat.refcie,
	f_numindiv_sin(decompte_prev.numdec),
	assure.nom||' '||assure.prenom nomassu,
	assure.matorg,
	decaismt.typbene,
	decaismt.numbene,
	decode(decaismt.typbene, 1, 'L''assure lui-même', 2, 'Bénéficiaires désignés', 'Autre') lib_bene,
	bene.nom||' '||bene.prenom nombene,
	to_char(decaismt.datpay,'dd/mm/yy') datpay,
	libelle.libelle libmodpmt,
	affectation.codope,
	decaismt.refpmt,
	affectation.numdecaismt,
	affectation.montant,
	monnaie.symbole,
	decaismt.numcpte,
	decaismt.numchq
from	decompte_prev,
	contrat,
	adhe_cntrt,
	indvs assure,
	indvs bene,
	monnaie,
	libelle,
	affectation,
	decaismt
where	decompte_prev.idadhesion = adhe_cntrt.idadhesion
and	adhe_cntrt.numgar=contrat.numgar
and	assure.numindiv=f_numindiv_sin(decompte_prev.numdec)
and	decaismt.numbene = bene.numindiv
and	decompte_prev.numdec	= affectation.numaffec
and	monnaie.codmon	= affectation.monnaie
and	libelle.mnemo(+)= 'MOPM'
and	libelle.code(+)	= decaismt.modpmt
and	affectation.codope	= 2
and	decaismt.numdecaismt(+) = affectation.numdecaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPT FOR ARTHUS.V_DCPT
