CREATE function ARTHUS.f_nom (
				a_numindiv in number,
				a_longueur in number default 32
				)
Return Varchar2
As
loc_nom	Varchar2(63);
BEGIN
Begin
Select	Substr( Upper(indvs.nom) ||' '|| Initcap(indvs.prenom), 1, a_longueur )
Into	loc_nom
From	indvs
Where	numindiv = a_numindiv;
Exception
When No_data_found then
	loc_nom := 'Individu inexistant ...';
When Others then
	loc_nom := Substr(sqlerrm, 1, a_longueur);
End;
Return ( loc_nom );
END	f_nom;
