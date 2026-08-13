CREATE function ARTHUS.f_adhesion_indiv(
			a_numindiv	IN NUMBER
					)
	RETURN NUMBER
	AS
		loc_etat	 number default 0;
	cursor c1 is
		select	distinct idadhesion
		from adhesion
		where numindiv=a_numindiv
		and sysdate between datapli and nvl(datper,sysdate)
		and exists(select max(debut) from histo_adhesion where
				histo_adhesion.idadhesion=adhesion.idadhesion
				and etat!=3
			  ) ;
BEGIN
   loc_etat := 0 ;
   begin
	open c1;
	fetch c1 into loc_etat;
	if (c1%NOTFOUND) then
		raise no_data_found;
	end if;
	close c1;
   end;
   return loc_etat;
END f_adhesion_indiv;
