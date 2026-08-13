CREATE Function ARTHUS.f_numrelance  	(
                 I_role   In Number,
                 I_modpmt In Number,
                 I_numgar In Number
		)
Return Number
Is
L_numrelance	Number;
BEGIN
Begin
Select 	distinct numrelance
Into   	L_numrelance
From   	valide_texte
Where  	courr_dest=I_role
And     mod_pmt=I_modpmt
And     numero=I_numgar;
Exception When No_data_found then L_numrelance:= -1;
End;
Return( L_numrelance);
END;
