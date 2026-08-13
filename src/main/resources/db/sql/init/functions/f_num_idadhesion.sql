CREATE function ARTHUS.f_num_idadhesion
Return number
as
loc_retour	number;
BEGIN
	Select	nvl( max(idadhesion), 0 )+1
	Into	loc_retour
	From	adhe_cntrt;

Return ( loc_retour );
END	f_num_idadhesion;
