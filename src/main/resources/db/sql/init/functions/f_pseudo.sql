CREATE function ARTHUS.f_pseudo( a_type 	In Number Default 0 )
Return Varchar2
as
loc_retour	Varchar2(32);
loc_nom		Varchar2(32);
loc_pseudo	Varchar2(32);
BEGIN
Begin
Select	nom,
	pseudo
Into	loc_nom,
	loc_pseudo
From	Utilisateurs
Where	numutil = f_numutil;
If ( a_type = 0 ) then
	loc_retour := loc_pseudo;
Else
	loc_retour := loc_nom;
End if;
Exception
	When No_data_found then loc_retour := 'Non identifié';
	When Too_many_rows then loc_retour := 'Erreur paramétrage';
End;
Return ( loc_retour );
END	f_pseudo;
