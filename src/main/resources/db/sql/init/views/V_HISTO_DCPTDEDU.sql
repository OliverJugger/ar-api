CREATE FORCE VIEW ARTHUS.V_HISTO_DCPTDEDU AS
select	histo_calcul.idcalcul,
	histo_calcul.idrepartition,
	repartition.nosin,
	repartition.numfor,
	histo_calcul.debut,
	histo_calcul.fin,
	histo_calcul.numbene,
	histo_dedu.typdedu	typdedu,
 	sum( f_total_histo(histo_dedu.idhisto, histo_dedu.typdedu) )	montant,
 	sum( f_total_histo_d(histo_dedu.idhisto, histo_dedu.typdedu) )	montant_d,
	histo_dedu.numdec,
	histo_calcul.numdec numdec_calc
from	histo_jours,
	histo_calcul,
	histo_dedu,
	repartition
where	histo_jours.idcalcul = histo_calcul.idcalcul
And	repartition.idrepartition = histo_calcul.idrepartition
And	histo_jours.idhisto=histo_dedu.idhisto
group by
	histo_calcul.idcalcul,
	histo_calcul.idrepartition,
	histo_calcul.numdec,
	repartition.nosin,
	repartition.numfor,
	histo_calcul.debut,
	histo_calcul.fin,
	histo_calcul.numbene,
	histo_dedu.typdedu,
	histo_dedu.numdec,
	histo_calcul.numdec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_DCPTDEDU FOR ARTHUS.V_HISTO_DCPTDEDU
