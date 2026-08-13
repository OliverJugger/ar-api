CREATE PROCEDURE ARTHUS.Maj_crrr
IS
-- Variable de reconnaissance SCCS
-- %W%    %E%
--
-- -- CONSTANTES  ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes  --
-- -- Curseur  ------------------------------------------------------
Cursor C_pc IS
	Select	idtexte,
		numero
	From	param_texte
	Where	code = 9;
-- ---------------------------------------------- Fin des exceptions  --
-- -- TYPE -------------------------------------------------------------
Rec_C_pc 	C_pc%Rowtype;
Rec_C_texte texte%Rowtype;
-- --------------------------------------------------- Fin des types  --
-- -- VARIABLES  -------------------------------------------------------
L_texte	texte.texte%Type;
-- ----------------------------------------------- Fin des variables  --
BEGIN
Open C_pc;
Loop
	Fetch C_pc Into Rec_C_pc;
	Exit When C_pc%NotFound;
	For Rec_C_texte IN (
		Select	texte,
			numligne
		From	texte
		Where idtexte = Rec_C_pc.idtexte)
	Loop
		L_texte := Rec_C_texte.texte;
		If ( Instr(L_texte, '#ASSU(1)') > 0 ) then
			Update	texte
			Set	texte = Replace(texte, '#ASSU(1)xx -',
							'#ASSU(1)xxxxx_')
			Where	idtexte = Rec_C_pc.idtexte
			and	numligne = Rec_C_texte.numligne;
		Elsif (Instr(L_texte, '#TIERS(7)') > 0 ) then
			Update	texte
			Set	texte = Replace(texte,
				'#TIERS(7)xxxxxxxxxxxxxxxxxxxxx',
				'#TIERS(6)xxxxxxxxxxxxxxxxxxxxx')
			Where	idtexte = Rec_C_pc.idtexte
			and	numligne = Rec_C_texte.numligne;
		Elsif (Instr(L_texte, '#TIERS(9)xxxxxxxxxxxxxxxxxxxxx') > 0 ) then
			Update	texte
			Set	texte = Replace(texte,
				'#TIERS(9)xxxxxxxxxxxxxxxxxxxxx',
				'#TIERS(8)xxxxxxxxxxxxxxxxxxxxx')
			Where	idtexte = Rec_C_pc.idtexte
			and	numligne = Rec_C_texte.numligne;
		Elsif (Instr(L_texte, '#TIERS(10)xxxxxxxxxxxxxxxxxxxx') > 0 ) then
			Update	texte
			Set	texte = Replace(texte,
				'#TIERS(10)xxxxxxxxxxxxxxxxxxxx',
				'#TIERS(9)xxxxxxxxxxxxxxxxxxxxx')
			Where	idtexte = Rec_C_pc.idtexte
			and	numligne = Rec_C_texte.numligne;
		Elsif (Instr(L_texte, '#TIERS(11)') > 0 ) then
			Update	texte
			Set	texte = Replace(texte,
				'#TIERS(11)',
				'#TIERS(10)xxxxxxxxxxxxxxxxxxxxxx')
			Where	idtexte = Rec_C_pc.idtexte
			and	numligne = Rec_C_texte.numligne;
		Elsif (Instr(L_texte, '#TIERS(12)') > 0 ) then
			Update	texte
			Set	texte = Replace(texte,
				'#TIERS(12)xxxxxxxxxxxxxxxxxxxx',
				'____________________________________#TIERS(11)xxxxxxxxxxxxxxxxxxxxxx')
			Where	idtexte = Rec_C_pc.idtexte
			and	numligne = Rec_C_texte.numligne;
		End if;
	End Loop;
End Loop;
Close C_pc;
END;
/
