CREATE function ARTHUS.f_suivi_factpe (
				a_idfactpe		In suivi_fact_tpe.idfactpe%TYPE,
				a_hors_rejet	In number default 1
				)
Return Number
Is
loc_retour		Number;
BEGIN
	begin
		if a_hors_rejet = 1 then
			SELECT 	max(codevefac)
			INTO	loc_retour
			FROM	suivi_fact_tpe
			WHERE	idfactpe	= a_idfactpe
			AND	codevefac	is not null
			AND	codevefac 	< 70;
		else
			SELECT 	max(codevefac)
			INTO	loc_retour
			FROM	suivi_fact_tpe
			WHERE	idfactpe	= a_idfactpe
			AND	codevefac	is not null;
		end if;

		Exception When No_data_found then loc_retour := 0;
	end;
	RETURN ( loc_retour );
END	f_suivi_factpe;
