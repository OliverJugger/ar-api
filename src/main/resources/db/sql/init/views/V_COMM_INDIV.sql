CREATE FORCE VIEW ARTHUS.V_COMM_INDIV AS
select	societe.numsoc						numsoc,
	societe.nom						nom_soc,
	nvl(grnts.refcie_chapeau,'N')				refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	indvs.numindiv						numadhe,
	indvs.nom || ' '|| indvs.prenom				nom_adhe,
	adhe_cntrt.ref_ext,
	qttc_global.idadhesion,
	qttc_global.numquit,
	emission.datemis,
	to_char(emission.datemis,'dd/mm/yyyy')			edatemis,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YYYY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YYYY')			qttc_efin,
	qttc_global.numindiv					numassu,
	Abs( sum(qttc_comm.montant) )				mt_ttc,
        qttc_comm.type_comm                                     type_tfc,
        libelle.libelle                                         libtfc
from	libelle,
	societe,
	grnts,
	indvs ,
	emission,
	adhe_cntrt,
	qttc_comm,
	qttc_global
Where	societe.numsoc		= grnts.numinterm
And	grnts.numgar		= adhe_cntrt.numgar
And	indvs.numindiv		= adhe_cntrt.numadhe
and	emission.numfact	= qttc_global.numquit
and	emission.codope		= 4
and	emission.numrelance	= 0
and	qttc_global.type_qttc	!= 3
and	qttc_global.comptant	!= 'R'
and	qttc_comm.montant	!= 0
and	qttc_comm.numquit 	= qttc_global.numquit
and     libelle.mnemo           = 'TYPCOMM'
and     libelle.code            = qttc_comm.type_comm
and	qttc_global.idadhesion	= adhe_cntrt.idadhesion
and	nvl(adhe_cntrt.date_fin_adhe,qttc_global.debut+1)>qttc_global.debut
Group by
	societe.numsoc,
	societe.nom,
	nvl(grnts.refcie_chapeau,'N'),
	grnts.numgar,
	grnts.refcie,
	indvs.numindiv,
	indvs.nom || ' '|| indvs.prenom,
	qttc_global.numgar,
	adhe_cntrt.ref_ext,
	qttc_global.idadhesion,
	qttc_global.numquit,
	emission.datemis,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numindiv,
        qttc_comm.type_comm,
        libelle.libelle
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMM_INDIV FOR ARTHUS.V_COMM_INDIV
