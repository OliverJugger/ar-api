CREATE function ARTHUS.f_cpta_en (
				I_numencaismt    In Number)
Return Number
Is
loc_retour		Number;
BEGIN
	begin	
		Select	2
		Into	loc_retour
		From	dual
		Where	I_numencaismt in (select  numencaismt
								from remise_banque
								where numencaismt=I_numencaismt
								union
								select  numencaismt
								from Prelevement
								where numencaismt=I_numencaismt);
		
	Exception When No_data_found then loc_retour := 1;
	end; 
	
RETURN ( loc_retour );

END	f_cpta_en;
