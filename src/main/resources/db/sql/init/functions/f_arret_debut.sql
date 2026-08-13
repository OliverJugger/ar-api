CREATE function ARTHUS.f_arret_debut (
				a_nosin in number,
				a_debut in date,
				a_continu in varchar2,
				a_type in number
				)
Return date
as
loc_nbjour	integer := 0;
loc_debut	date:=a_debut;
loc_continu	varchar2(1) := a_continu;
loc_arret	arret%Rowtype;
BEGIN
For loc_arret in (
	Select	debut,
		fin,
		continu
	From	arret
	Where	fin < a_debut
	and	nosin = a_nosin
	and 	type  = a_type
	Order by
		debut desc
	)
Loop
if ( (loc_continu = 'O') ) then
	loc_nbjour := loc_nbjour + ((loc_arret.fin - loc_arret.debut) + 1);
	loc_debut := loc_arret.debut; loc_continu := loc_arret.continu;
end if;
End loop;
Return ( loc_debut );
END	f_arret_debut;
