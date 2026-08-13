CREATE procedure ARTHUS.P_MAJ_type_interm
IS
Cursor C_apport IS
	Select	apporteur.numindiv,
		apporteur.cle,
		apporteur.debut,
		apporteur.fin,
		contrat.mode_gestion,
		contrat.gest_cotis,
		contrat.gest_prest,
		contrat.delegataire,
		contrat.deleg_prest
	From	apporteur,
		contrat
	Where	apporteur.etendue = 2
	and	contrat.numgar = apporteur.cle
	and	contrat.mode_gestion IN (2, 3)
	and	trunc(sysdate) between apporteur.debut
			and nvl(apporteur.fin + 1, apporteur.debut)
	and	trunc(apporteur.debut) !=
			trunc( nvl(apporteur.fin, apporteur.debut + 1) )
	;
Rec_C_apport	C_apport%Rowtype;
BEGIN
Open C_apport;
Loop
	Fetch C_apport Into Rec_C_apport;
	Exit When C_apport%NotFound;
End Loop;
Close C_apport;
END;
/
