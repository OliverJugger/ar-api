CREATE function ARTHUS.f_profil (
				a_numutil	In Number
				)
Return Varchar2
Is
loc_retour	Varchar2(5);
BEGIN
Begin
Select	profil
Into	loc_retour
From	utilisateurs
Where	numutil = a_numutil;
Exception When Others then loc_retour := 'ERR';
End;
Return ( loc_retour );
END	f_profil;
