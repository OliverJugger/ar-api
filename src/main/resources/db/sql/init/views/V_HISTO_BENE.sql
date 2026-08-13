CREATE FORCE VIEW ARTHUS.V_HISTO_BENE AS
Select	histo_calcul.idcalcul,
	histo_calcul.numdec,
	histo_calcul.numbene,
 	sum( f_total_histo(histo_jours.idhisto, -2) )	montant,
 	sum( f_total_histo_d(histo_jours.idhisto, -2) )	montant_d
From	histo_jours,
	histo_calcul
Where	histo_jours.idcalcul = histo_calcul.idcalcul
group by
	histo_calcul.idcalcul,
	histo_calcul.numdec,
	histo_calcul.numbene
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HISTO_BENE FOR ARTHUS.V_HISTO_BENE
