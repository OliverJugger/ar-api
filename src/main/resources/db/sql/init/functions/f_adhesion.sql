CREATE function ARTHUS.f_adhesion(
			a_numindiv 	IN NUMBER,
			a_idadhesion	IN NUMBER,
			a_date		IN DATE,
			a_type 		IN NUMBER default 1)
	RETURN NUMBER
	AS
		loc_retour	 number default 0;
	cursor c1 is
		select	adhesion.etat,to_number(to_char(adhesion.datapli,'j')),
			to_number(to_char(adhesion.datper,'j'))
		from	adhesion
		where	idadhesion = a_idadhesion
		And	numindiv=a_numindiv
		and	etat in(select code from lble
				where mnemo='ETIN'
				and sens=0
				)
		and	a_date between adhesion.datapli
			and nvl(adhesion.datper,a_date)
		order by adhesion.datapli desc
		;

		loc_debut number;
		loc_fin number;
		loc_etat number;
BEGIN

   loc_retour := 0 ;
   begin

	open c1;
	fetch c1
		into
			loc_etat,
			loc_debut,
			loc_fin;
	if (c1%NOTFOUND) then
		loc_retour:=0;
	end if;
	close c1;
   end;

If (loc_retour=0) then return(loc_retour);
end if;
If (a_type=1)
Then
	loc_retour:=loc_etat;
Elsif (a_type=2) then
	loc_retour:=loc_debut;
Elsif (a_type=3) then
	loc_retour:=loc_fin;
End if;

   return loc_retour;

END f_adhesion;
