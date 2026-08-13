CREATE function ARTHUS.f_prch_idadhesion (
				a_numpc in number
				)
Return number
as
loc_retour	number;
BEGIN
	Select	nvl( max(adhesion.idadhesion), 0 )
	Into	loc_retour
	From	adhesion,
		pricharge
	Where	pricharge.datehospi between adhesion.datapli
				    and nvl(adhesion.datper, pricharge.datehospi)
	and	adhesion.numindiv = pricharge.numindiv
	and	adhesion.numfor = pricharge.numfor
	and	adhesion.numgar = pricharge.numgar
	and	pricharge.numpc = a_numpc
	;
Return ( loc_retour );
END	f_prch_idadhesion;
