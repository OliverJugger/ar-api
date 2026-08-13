CREATE function ARTHUS.f_suivi_factpe_prec (
				a_idfactpe		In suivi_fact_tpe.idfactpe%TYPE,
				a_numremise		In suivi_fact_tpe.numremise_import%TYPE
				)
Return Number
Is
loc_retour		Number;
BEGIN
	begin
		SELECT 	max(codevefac)
		INTO	loc_retour
		FROM	suivi_fact_tpe
		WHERE	idfactpe	 = a_idfactpe
		AND	numremise_import <> a_numremise
		AND	codevefac	 is not null
		AND	codevefac 	 < 70;

		Exception When No_data_found then loc_retour := 0;
	end;
	RETURN ( loc_retour );
END	f_suivi_factpe_prec;
