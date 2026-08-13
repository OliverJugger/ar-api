CREATE FORCE VIEW ARTHUS.V_HISTO_DEDU AS
Select	histo_jours.idcalcul,
	0	typdedu,
 	sum( f_total_histo(histo_jours.idhisto, 0) )	montant,
 	sum( f_total_histo_d(histo_jours.idhisto, 0) )	montant_d
From	histo_jours
Having	sum( f_total_histo(histo_jours.idhisto, 0) ) != 0
Group by
	histo_jours.idcalcul
Union
Select	histo_jours.idcalcul,
	histo_dedu.typdedu	typdedu,
 	sum( f_total_histo(histo_dedu.idhisto, histo_dedu.typdedu) )	montant,
 	sum( f_total_histo_d(histo_dedu.idhisto, histo_dedu.typdedu) )	montant_d
From	histo_jours,
	histo_dedu
Where	histo_dedu.idhisto = histo_jours.idhisto
Group by
	histo_jours.idcalcul,
	histo_dedu.typdedu
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_DEDU FOR ARTHUS.V_HISTO_DEDU
