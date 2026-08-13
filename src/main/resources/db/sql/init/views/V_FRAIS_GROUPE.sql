CREATE FORCE VIEW ARTHUS.V_FRAIS_GROUPE AS
select	societe.numsoc						numsoc,
	societe.nom						nom_soc,
	nvl(grnts.refcie_chapeau,'N')				refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	grnts.numcli						numcli,
	indvs.nom || ' '|| indvs.prenom				nom_cli,
	qttc_global.numquit,
	emission.datemis,
	to_char(emission.datemis,'dd/mm/yyyy')			edatemis,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YYYY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YYYY')			qttc_efin,
	qttc_global.numindiv					numassu,
	Abs( sum(qttc_frais.montant) )				mt_ttc,
        qttc_frais.type_frais                                     type_tfc,
        libelle.libelle                                         libtfc
from	libelle,
	societe,
	grnts,
	indvs ,
	emission,
	qttc_frais,
	qttc_global
Where	societe.numsoc		= grnts.numinterm
And	grnts.numgar		= qttc_global.numgar
And	grnts.typequit		= 1
And	indvs.numindiv		= grnts.numcli
and	emission.numfact	= qttc_global.numquit
and	emission.codope		= 4
and	emission.numrelance	= 0
and	qttc_global.type_qttc	!= 3
and	qttc_global.comptant	!= 'R'
and	qttc_frais.montant	!= 0
and	qttc_frais.numquit 	= qttc_global.numquit
and     libelle.mnemo           = decode(qttc_frais.numfor,
					0, 'TYPFRAIS',
					'FRAIS_GAR')
and     libelle.code            = qttc_frais.type_frais
and	ARTHUS.pk_histo_contrat.f_sel_etat(grnts.numgar,qttc_global.debut)=1
Group by
	societe.numsoc,
	societe.nom,
	nvl(grnts.refcie_chapeau,'N'),
	grnts.numgar,
	grnts.refcie,
	grnts.numcli,
	indvs.nom || ' '|| indvs.prenom,
	qttc_global.numquit,
	emission.datemis,
	qttc_global.debut,
	qttc_global.fin,
	qttc_global.numindiv,
        qttc_frais.type_frais,
        libelle.libelle
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FRAIS_GROUPE FOR ARTHUS.V_FRAIS_GROUPE
