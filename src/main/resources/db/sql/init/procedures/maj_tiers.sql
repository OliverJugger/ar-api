CREATE PROCEDURE ARTHUS.maj_tiers
IS
-- Variable de reconnaissance SCCS
-- %W%    %E%
--
C_tiers 	indvs%Rowtype;
L_numindiv	Number;
BEGIN
For C_tiers IN (
	Select	numindiv
	From	indvs
	Where	numindiv between 100 and 999)
Loop
	Begin
	Select 	numero + 1
	Into	L_numindiv
	From	numero
	Where 	mnemo = 'INDVS';
	Update	numero
	Set	numero = L_numindiv
	Where 	mnemo = 'INDVS';
	Update	pers_tiers
	Set	numindiv = L_numindiv
	Where	numindiv = C_tiers.numindiv;
	Update	indvs
	Set	numindiv = L_numindiv
	Where	numindiv = C_tiers.numindiv;
	End;
End Loop;
END;
/
