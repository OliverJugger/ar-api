CREATE FORCE VIEW ARTHUS.V_DCPTDELEG AS
select	distinct dcpt.numdec,
	dcpt.datpay				datedec,
	dcpt.numindiv,
	dcpt.typbene,
	dcpt.numbene,
	decode(dcpt.typbene, 5, 'Le délégataire','Autre organisme') lib_bene,
	dcpt.numutil,
	dcpt.numdcptcie,
	indvs.nom				nom_bene,
	indvs.prenom				prenom_bene,
	indvs.nom||' '||indvs.prenom		nombene,
	affectation.codope,
	affectation.numdecaismt,
	affectation.montant,
	affectation.monnaie,
        monnaie.symbole,
        decaismt.flagpay,
	decaismt.refpmt,
	decaismt.datpay,
	decaismt.modpmt,
        libelle.libelle   			libmodpmt,
	decaismt.numcpte,
	decaismt.numchq,
	decaismt.datedit,
	decaismt.numedit,
	util.pseudo
from	dcpt,
	indvs,
	monnaie,
	libelle,
	affectation,
	decaismt,
	util
where	dcpt.numbene	= indvs.numindiv
and	dcpt.numdec	= affectation.numaffec
and     monnaie.codmon  = affectation.monnaie
and     libelle.mnemo(+)= 'MOPM'
and     libelle.code(+) = decaismt.modpmt
and	affectation.codope	= 14
and	decaismt.numdecaismt(+) = affectation.numdecaismt
and	util.numutil	= dcpt.numutil
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTDELEG FOR ARTHUS.V_DCPTDELEG
