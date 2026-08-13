CREATE Function ARTHUS.F_ouverte (
		I_numporte	IN  parporte.numporte%Type,
		I_numreg	IN  parporte.numreg%Type,
		I_numsoc	IN  parporte.numsoc%Type,
		I_numorg	IN  parporte.numorg%Type,
		I_numcaisse	IN  parporte.numcaisse%Type,
		I_numindiv	IN  individu.numindiv%type
		)
-- Return Boolean
Return Number
IS
G_codpos	pers_adresse.codpos%Type;
Cursor C_porte IS
	Select	ouverte
	From	parporte
	Where	Numporte = I_numporte
	and	Numreg = I_numreg
	and	Numsoc = I_numsoc
	and	Numorg = I_numorg
	and	Numcaisse = I_numcaisse;
Cursor C_dpt IS
	Select	ouverte
	From	parporte
	Where	Numporte = I_numporte
	and	Numreg = I_numreg
	and	Numsoc = I_numsoc
	and	Numorg = I_numorg
	and	Numdpt= substr(G_codpos,1,length(numdpt));
L_ouverte	parporte.ouverte%Type;
L_retour	Number;
-- L_retour	Boolean := FALSE;
BEGIN
G_codpos := f_codpos(I_numindiv);
If ( I_numcaisse != 0 ) then
	Open C_porte;
	Fetch C_porte Into L_ouverte;
	If ( C_porte%Found ) then
		If ( L_ouverte = 1 ) then
			-- L_retour := TRUE;
		L_retour := L_ouverte;
		End if;
	End if;
	Close C_porte;
Else
	Open C_dpt;
	Fetch C_dpt Into L_ouverte;
	If ( C_dpt%Found ) then
		If ( L_ouverte = 1 ) then
			L_retour := L_ouverte;
		else
			L_retour :=2;
		End if;
	else
	L_retour := 3;
	End if;
	Close C_dpt;
End If;
--
Return ( L_retour );
END F_ouverte;
