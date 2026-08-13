CREATE function ARTHUS.f_dcpt_idadhesion( a_numdec IN NUMBER )
	RETURN NUMBER
	as
	retour	NUMBER;
BEGIN
	select	distinct s.idadhesion
	into	retour
	from	sntr s
	where	s.numdec   = a_numdec
	;
	RETURN	retour;
END f_dcpt_idadhesion;
