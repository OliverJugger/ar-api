CREATE FUNCTION ARTHUS.is_a_fonction(
			a_chaine in varchar2 ,
			a_type in integer
			)
RETURN 	integer
AS
loc_nbarg	integer := -1;
BEGIN
Select	min(nbarg)
Into	loc_nbarg
From	v_rep_fonction
Where	nom_fonction = a_chaine
and	type = a_type
;
if ( loc_nbarg is null ) then
	return( -1 );
else
	Return( loc_nbarg );
end if;
END;
