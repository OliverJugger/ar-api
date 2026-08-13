CREATE function ARTHUS.f_j_conso(
			comm_numindiv	IN NUMBER,
			comm_numfor	IN NUMBER,
			comm_nosin	IN NUMBER,
			comm_numbene	IN NUMBER,
			a_debut		IN DATE,
			a_fin		IN DATE,
			a_flag_sin	IN NUMBER default 0,
			a_flag_bene	IN NUMBER default 0)
	RETURN NUMBER
	AS
		loc_nbj		NUMBER := 0;
Cursor fetch_histo is
	Select	histo_calcul.idrepartition,
		histo_calcul.numbene,
		histo_jours.debut,
		histo_jours.fin,
		sin_prev.nosin
	From	histo_calcul,
		histo_jours,
		repartition,
		sin_prev
	Where	histo_calcul.idrepartition = repartition.idrepartition
	and	histo_calcul.numbene = decode(a_flag_bene,
					  	0, histo_calcul.numbene,
						comm_numbene)
	and	histo_jours.idcalcul = histo_calcul.idcalcul
	and	repartition.numfor = comm_numfor
	and	repartition.nosin = sin_prev.nosin
	and	sin_prev.numindiv = comm_numindiv;
Histo	fetch_histo%Rowtype;
loc_debut	Date;
loc_fin		Date;
BEGIN
For histo in fetch_histo
Loop
if ( (a_flag_sin != 0) and (histo.nosin != comm_nosin) ) then
	exit;
end if;
if ( (histo.debut between a_debut and a_fin)
 	or
     (histo.fin between a_debut and a_fin) )
then
	loc_debut := greatest(a_debut, histo.debut);
	loc_fin := least(a_fin, histo.fin);
	loc_nbj := loc_nbj + (loc_fin - loc_debut) + 1;
end if;
End loop;
RETURN loc_nbj;
END f_j_conso;
