CREATE FORCE VIEW ARTHUS.V_COTIS_GROUPE AS
select	grnts.numinterm						numsoc,
	societe.nom						nom_soc,
	grnts.numorg						numorg,
	orgns.nom						nom_org,
	grnts.numcli						numcli,
	indvs.nom || ' '|| indvs.prenom				nom_cli,
	nvl(grnts.refcie_chapeau,'N')				refcie_chapeau,
	grnts.numgar,
	grnts.refcie,
	qttc_global.numquit,
	decode(qttc_global.comptant,'C','Comptant','N','Terme','A','Terme',
		qttc_global.comptant)					type,
	qttc_global.debut,
	qttc_global.fin,
	to_char(qttc_global.debut,'DD/MM/YYYY')			qttc_edebut,
	to_char(qttc_global.fin  ,'DD/MM/YYYY')			qttc_efin,
	nvl(qttc_global.mt_ttc,0) 				mt_ttc,
	qttc_global.datemis,
	to_char(qttc_global.datemis,'dd/mm/yyyy')		edatemis,
	facture.mregl,
	mregl.libelle,
	qttc_global.comptant					type_appel
from	libelle mregl,
	societe,
	orgns,
	indvs,
	grnts,
	facture,
	qttc_global
where	mregl.mnemo		= 'MREGL'
and	mregl.code		= facture.mregl
and	societe.numsoc		= grnts.numinterm
and	indvs.numindiv  	= grnts.numcli
and	orgns.numorg		= grnts.numorg
and	grnts.numgar 		= qttc_global.numgar
and	grnts.typequit 		= 1
and	facture.codope		= 4
and	facture.numfact		= qttc_global.numquit
and	qttc_global.comptant	!= 'R'
and	qttc_global.type_qttc	!= 3
and	ARTHUS.pk_histo_contrat.f_sel_etat(grnts.numgar,qttc_global.debut)=1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COTIS_GROUPE FOR ARTHUS.V_COTIS_GROUPE
