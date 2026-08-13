CREATE FORCE VIEW ARTHUS.V_COTIS_EXO_GROUPE AS
select
	grnts.numcli						numcli,
	indvs.nom || ' '|| indvs.prenom				nom_cli,
	grnts.numgar,
	qttc_global.numindiv,
	to_char(qttc_global.debut,'yyyy')				exercice
from
	indvs,
	grnts,
	qttc_global
Where	indvs.numindiv  	= grnts.numcli
and	grnts.numgar 		= qttc_global.numgar
and	grnts.typequit		= 1
and	qttc_global.comptant	!= 'R'
and	qttc_global.type_qttc	!= 3
and	ARTHUS.pk_histo_contrat.f_sel_etat(grnts.numgar,qttc_global.debut)=1
Group by
	grnts.numcli,
	indvs.nom || ' '|| indvs.prenom,
	grnts.numgar,
	qttc_global.numindiv,
	to_char(qttc_global.debut,'yyyy')
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COTIS_EXO_GROUPE FOR ARTHUS.V_COTIS_EXO_GROUPE
