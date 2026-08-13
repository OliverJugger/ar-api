CREATE FORCE VIEW ARTHUS.V_QTTC_SOUS AS
select		qttc_global.numgar,
		qttc_global.numquit,
		querable.numindiv numquerable,
		qttc_global.numindiv,
		qttc_global.type_qttc,
		qttc_global.debut,
		qttc_global.fin,
		qttc_global.idadhesion,
		Decode(
		f_datemis(4, qttc_global.numquit, 1, 0),'Non émis',
				decode(
				f_datemis(4,qttc_global.numquit,1,99),
					'Non annulé',
				f_datemis(4,qttc_global.numquit,1,0),
				f_datemis(4,qttc_global.numquit,1,99)
				  ),
			f_datemis(4,qttc_global.numquit,1,0)
		      )
								edatemis,
		to_char(qttc_global.debut,'dd/mm/yyyy') edebut,
		to_char(qttc_global.fin,'dd/mm/yyyy') efin,
		facture.mregl,
		facture.echeance,
		to_char(facture.echeance, 'dd/mm/yyyy')	eecheance,
		grnts.refcie,
		grnts.numcli,
		querable.nom||' '||querable.prenom nomquerable,
		sousc.nom||' '||sousc.prenom nomsousc,
		'Le contrat '||grnts.refcie nomassu,
		facture.montant		 montant,
		facture.montant_D montant_D,
		qttc_global.mt_net,
		qttc_global.mt_net_D,
		qttc_global.mt_affec mt_regl,
		qttc_global.mt_affec_D mt_regl_D,
		decode(qttc_global.comptant,
			'R','Régularisée',
			decode(
			f_datemis(4,qttc_global.numquit,1,99),'Non annulé',
                nvl(to_char(qttc_global.mt_affec,'9999990.90'), 'Non réglé'),'Annulé')
				) mt_affec,
		    decode(qttc_global.comptant,
			'R','Régularisée',
			decode(
			f_datemis(4,qttc_global.numquit,1,99),'Non annulé',
                nvl(to_char(qttc_global.mt_affec_D,'9999990.90'), 'Non réglé'),'Annulé')
				) mt_affec_D,
		qttc_global.monnaie,
		qttc_global.monnaie_D
from
		indvs querable,
		indvs sousc,
		grnts,
		qttc_global,
		facture
where		querable.numindiv	=	qttc_global.numquerable
and		facture.codope	= 4
and		facture.numfact =	qttc_global.numquit+0
and		sousc.numindiv		=	grnts.numcli
and		qttc_global.type_qttc	!= 3
and		qttc_global.comptant	!= 'R'
and		grnts.numgar	=	qttc_global.numgar
and		grnts.typequit=1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_SOUS FOR ARTHUS.V_QTTC_SOUS
