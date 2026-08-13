CREATE function ARTHUS.f_super_user
Return number
as
loc_retour	number;
loc_super_user  number;
BEGIN
Begin
Select super_user
Into   loc_super_user
From utilisateurs
Where nom = user;
End;
Begin
Select	1
Into	loc_retour
From	dual
Where	loc_super_user = 1;
Exception When No_Data_Found then loc_retour := 0;
End;
Return ( loc_retour );
END	f_super_user;
