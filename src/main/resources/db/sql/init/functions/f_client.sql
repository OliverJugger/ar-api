CREATE function ARTHUS.f_client
Return Number
Is
loc_retour	Number(6);
BEGIN
Begin
Select	client
Into	loc_retour
From	parametres
;
Exception When Others then loc_retour := 0;
End;
Return ( loc_retour );
END	f_client;
