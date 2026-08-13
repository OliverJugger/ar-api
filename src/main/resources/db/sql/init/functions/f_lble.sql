CREATE function ARTHUS.f_lble(
			a_mnemo	IN VARCHAR2,
			a_code  IN NUMBER)
	RETURN VARCHAR2
	AS
		loc_libelle	 varchar2(70);
BEGIN
   begin
	select	libelle
	into	loc_libelle
	from	libelle
	where	mnemo= a_mnemo
	and	code = a_code;
   end;
   return loc_libelle;
END f_lble;
