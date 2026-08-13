CREATE function ARTHUS.f_etat_adhe_a(
			a_idadhesion	IN NUMBER,
			a_date		IN DATE,
			a_type in number default 1)
	RETURN NUMBER
	AS
		loc_etat	 number default 0;
	cursor c1 is
		select	histo_adhesion.etat
		from	histo_adhesion
		where	idadhesion = a_idadhesion
		and	debut <= a_date
		order by trunc(debut) desc , datsai desc
		;
	cursor c2 is
		select	histo_adhesion.motif
		from	histo_adhesion
		where	idadhesion = a_idadhesion
		and	debut <= a_date
		order by trunc(debut) desc , datsai desc
		;
	cursor c3 is
		select	d2j(histo_adhesion.debut)
		from	histo_adhesion
		where	idadhesion = a_idadhesion
		and	debut <= a_date
		order by trunc(debut) desc , datsai desc
		;
BEGIN
   loc_etat := 0 ;
   begin
If (a_type=1)
Then
	open c1;
	fetch c1 into loc_etat;
	if (c1%NOTFOUND) then
	loc_etat:=0;
	end if;
	close c1;
Elsif(a_type=2)
Then
	open c2;
	fetch c2 into loc_etat;
	if (c2%NOTFOUND) then
	loc_etat:=0;
	end if;
	close c2;
Elsif(a_type=3)
Then
	open c3;
	fetch c3 into loc_etat;
	if (c3%NOTFOUND) then
	loc_etat:=1;
	end if;
	close c3;
End if;
   end;
   return loc_etat;
END f_etat_adhe_a;
