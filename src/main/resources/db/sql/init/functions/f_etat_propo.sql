CREATE function ARTHUS.f_etat_propo(
			a_idpropo	IN NUMBER,
			a_date		IN DATE default sysdate,
			a_type in number default 1)
	RETURN NUMBER
	AS
		loc_etat	 number default 0;
	cursor c1 is
		select	histo_proposition.etat
		from	histo_proposition
		where	idpropo = a_idpropo
		and	debut <= a_date
		order by debut desc , datsai desc
		;
	cursor c2 is
		select	histo_proposition.motif
		from	histo_proposition
		where	idpropo = a_idpropo
		and	debut <= a_date
		order by debut desc , datsai desc
		;
	cursor c3 is
		select	d2j(histo_proposition.debut)
		from	histo_proposition
		where	idpropo = a_idpropo
		and	debut <= a_date
		order by debut desc , datsai desc
		;
	cursor c4 is
		select	d2j(histo_proposition.debut)
		from	histo_proposition
		where	idpropo = a_idpropo
		and	debut <= a_date
		order by debut
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
Elsif(a_type=4)
Then
	open c4;
	fetch c4 into loc_etat;
	if (c4%NOTFOUND) then
	loc_etat:=1;
	end if;
	close c4;
End if;
   end;
   return loc_etat;
END f_etat_propo;
