CREATE procedure ARTHUS.maj_echesuiv
AS
C_contrat	contrat%Rowtype;
Begin
For C_contrat IN (
	Select	numgar
	From	contrat
	Where	typequit = 1)
Loop
pk_qttc.P_maj_echesuiv(
	I_etendue	=> 2,
	I_cle		=> C_contrat.numgar);
End Loop;
End;
/
