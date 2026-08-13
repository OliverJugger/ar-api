CREATE FORCE VIEW ARTHUS.V_HISTO_CALCUL AS
select	histo_calcul.idcalcul,
	histo_calcul.idrepartition,
	histo_calcul.numdec,
	repartition.nosin,
	repartition.numfor,
	histo_calcul.debut,
	histo_calcul.fin,
 	sum( f_total_histo(histo_jours.idhisto, -2) )	montant	,
 	sum( f_total_histo(histo_jours.idhisto, 0) )	reval,
 	sum( f_total_histo(histo_jours.idhisto, -3) )	dedu	,
 	(
		sum( f_total_histo(histo_jours.idhisto, -1) )+
 		sum( f_total_histo(histo_jours.idhisto, 0) )
	) montant_remb,
 	sum( f_total_histo(histo_jours.idhisto, -1) )	mt_base	,
 	sum( f_total_histo_d(histo_jours.idhisto, -2) )	montant_d,
 	sum( f_total_histo_d(histo_jours.idhisto, 0) )	reval_d,
 	sum( f_total_histo_d(histo_jours.idhisto, -3) )	dedu_d,
 	(
		sum( f_total_histo_d(histo_jours.idhisto, -1) )+
 		sum( f_total_histo_d(histo_jours.idhisto, 0) )
	) montant_remb_d,
 	sum( f_total_histo_d(histo_jours.idhisto, -1) )	mt_base_d,
	repartition.idadhesion,
	histo_jours.monnaie,
	histo_jours.monnaie_d
from	histo_jours,
	histo_calcul,
	repartition
where	histo_jours.idcalcul = histo_calcul.idcalcul
And	repartition.idrepartition = histo_calcul.idrepartition
group by
	histo_calcul.idcalcul,
	histo_calcul.idrepartition,
	histo_calcul.numdec,
	repartition.nosin,
	repartition.numfor,
	histo_calcul.debut,
	histo_calcul.fin,
	repartition.idadhesion,
	histo_jours.monnaie,
	histo_jours.monnaie_d
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_CALCUL FOR ARTHUS.V_HISTO_CALCUL
