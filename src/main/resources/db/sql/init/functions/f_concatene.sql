CREATE function ARTHUS.f_concatene (
				a_gauche 	in varchar2,
				a_droite 	in varchar2,
				a_separateur 	in varchar2 default ' '
				)
Return varchar2
As
loc_separateur	Varchar2(10) := a_separateur;
BEGIN
If ( a_gauche is Not Null ) then
	loc_separateur := a_separateur;
Else
	loc_separateur := Null;
End if;
Return ( a_gauche || loc_separateur || a_droite );
END	f_concatene;
