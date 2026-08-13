CREATE function ARTHUS.f_idadhesion_contrat (
				a_numgar in number,
				a_numindiv in number,
				a_debut in date
				
				)
Return number
as
loc_retour	number;
BEGIN
	Select	nvl( max(v_cvrt.idadhesion), 0 )
	Into	loc_retour
	From	v_cvrt
	Where	a_debut between v_cvrt.datapli
				    and nvl(v_cvrt.datper, a_debut)
	and	v_cvrt.numindiv = a_numindiv
	and	v_cvrt.numgar = a_numgar
	and	v_cvrt.datapli!=nvl(v_cvrt.datper,v_cvrt.datapli+1)
	;
Return ( loc_retour );
END	f_idadhesion_contrat;
