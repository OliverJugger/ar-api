CREATE Function ARTHUS.f_numrelance_2  	(
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
Exception When others then L_numrelance:= I_numgar;
End;
Return( L_numrelance);
END;
