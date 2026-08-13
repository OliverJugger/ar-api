CREATE function ARTHUS.f_dcptcie_remb_d (a_numdec in number)
return number
is
loc_montant number;
BEGIN
select

		sum( f_total_histo_d(histo_jours.idhisto, -1) )+
 		sum( f_total_histo_d(histo_jours.idhisto, 0) )
into 	loc_montant
from	histo_jours,
	histo_calcul
where	histo_jours.idcalcul = histo_calcul.idcalcul
and	histo_calcul.numdec=a_numdec
;
Return(nvl(loc_montant,0));
END;
