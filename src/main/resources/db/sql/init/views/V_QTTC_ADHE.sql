CREATE FORCE VIEW ARTHUS.V_QTTC_ADHE AS
select		qttc_global.numgar,
		qttc_global.numquit,
		qttc_global.numquerable,
		qttc_global.numindiv,
		qttc_global.type_qttc,
		qttc_global.debut,
		qttc_global.fin,
		qttc_global.idadhesion,
		f_datemis(4, qttc_global.numquit, 1, 0) edatemis,
		to_char(qttc_global.debut,'dd/mm/yyyy') edebut,
		to_char(qttc_global.fin,'dd/mm/yyyy') efin,
		facture.mregl,
		libelle.libelle||' au '||to_char(facture.echeance, 'dd/mm/yy')
					libmregl,
		facture.echeance,
		to_char(facture.echeance, 'dd/mm/yyyy')	eecheance,
		grnts.refcie,
		grnts.numcli,
		querable.nom||' '||querable.prenom nomquerable,
		'L''adhérent '||to_char(qttc_global.numindiv)||' '
		||assu.nom||' '||assu.prenom
	       	       nomassu,
		facture.montant		 montant,
		qttc_global.mt_net,
		qttc_global.mt_affec mt_regl,
		decode(qttc_global.comptant,
			'R','Régularisée',
        nvl(to_char(qttc_global.mt_affec,'9999990.90'), 'Non réglé')) mt_affec,
		facture.montant_D		 montant_D,
		qttc_global.mt_net_D,
		qttc_global.mt_affec_D mt_regl_D,
		decode(qttc_global.comptant,
			'R','Régularisée',
        nvl(to_char(qttc_global.mt_affec_D,'9999990.90'), 'Non réglé')) mt_affec_D,
        qttc_global.monnaie,
		qttc_global.monnaie_D
from		libelle,
		indvs querable,
		indvs assu,
		grnts,
		facture,
		qttc_global
where		libelle.mnemo	= 	'MREGL'
and		libelle.code	=	facture.mregl
and		facture.codope	= 4
and		facture.numfact =	qttc_global.numquit
and		querable.numindiv	=	qttc_global.numquerable
and             qttc_global.comptant    !='R'
and		qttc_global.type_qttc	!= 3
and		assu.numindiv  = qttc_global.numindiv
and		grnts.numgar	=	qttc_global.numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_ADHE FOR ARTHUS.V_QTTC_ADHE
