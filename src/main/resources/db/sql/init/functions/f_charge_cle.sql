CREATE function ARTHUS.f_charge_cle (
				a_codapli 	in Varchar2,
				a_cle 		in Varchar2
				)
Return Varchar2
As
loc_retour	Varchar2(50);
Cursor fetch_objet is
	Select	Cle_externe.block,
		Cle_externe.champ
	From	cle_externe
	Where	cle_externe.codapli = Upper(a_codapli)
	and	cle_externe.cle_unique = a_cle;
loc_objet	fetch_objet%Rowtype;
BEGIN
For loc_objet in fetch_objet
Loop
	loc_retour := loc_objet.block ||'.'||loc_objet.champ;
End loop;
If ( loc_retour is Null ) then
	Raise No_data_found;
End if;
Return ( loc_retour );
END	f_charge_cle;
