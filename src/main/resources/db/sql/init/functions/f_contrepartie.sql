CREATE Function ARTHUS.f_contrepartie 	(
		I_idmvt		In	Number
		)
Return Number
Is
L_retour	Number;
BEGIN
Begin
Select 	nvl(sum(montant * sens), 0)
Into   	L_retour
From   	compte_tiers
Where  	idmvt in (
	select idcomp
	from   compensation
	where  idmvt = I_idmvt);
Exception When No_data_found then L_retour := 0;
End;
Return( L_retour );
END;
