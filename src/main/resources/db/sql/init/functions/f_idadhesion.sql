CREATE function ARTHUS.f_idadhesion(  a_numgar   in NUMBER
					, a_numindiv in NUMBER
					, a_dtdcpt   IN DATE )
	RETURN NUMBER
	as
	retour	NUMBER;
BEGIN
	select	max(NVL(s.idadhesion,0))
 	  into	retour
	  from	sntr s, dcpt d
	 where	s.numgar   = a_numgar
	   and	s.numindiv = a_numindiv
  	   and  s.numdec   = d.numdec
           and  d.datpay   = a_dtdcpt
	;
	RETURN	retour;
END f_idadhesion;
