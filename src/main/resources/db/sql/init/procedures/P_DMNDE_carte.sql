CREATE procedure ARTHUS.P_DMNDE_carte(
			I_numporte IN param_tiers_payant.numporte%TYPE,
			I_numgar IN param_tiers_payant.numgar%TYPE
			)
IS
cursor C_adhesion IS
	select adhe_cntrt.idadhesion
	from adhe_cntrt
	where numgar = I_numgar
	and f_etat_adhe(adhe_cntrt.idadhesion, sysdate) != 0;
/*cursor C_adherent IS
	select adhesion.numindiv
	from adhesion
	where adhesion.idadhesion IN (select
	and exists (	select 1
			from porte_adhesion, param_tiers_payant
			where porte_adhesion.idadhesion = Rec_c_adhesion.idadhesion
			and porte_adhesion.numporte = I_numporte
			and porte_adhesion.numindiv = adhesion.numindiv
			and porte_adhesion.transmis = 1
			and sysdate >= (porte_adhesion.debut + param_tiers_payant.period)-param_tiers_payant.renouv
			);*/
/*Rec_c_adherent	C_adherent%RowType;*/
Rec_c_adhesion  C_adhesion%RowType;
BEGIN
Open C_adhesion;
Loop
	Fetch C_adhesion into Rec_c_adhesion;
	Exit When C_adhesion%NotFound;
	--
	/*Open C_adherent;*/
	for C_adherent in
		(
		select adhesion.numindiv
			from adhesion
			where adhesion.idadhesion = Rec_c_adhesion.idadhesion
			and exists (
				select 1
				from porte_adhesion, param_tiers_payant
				where porte_adhesion.idadhesion = Rec_c_adhesion.idadhesion
				and porte_adhesion.numporte = I_numporte
				and porte_adhesion.numindiv = adhesion.numindiv
				and porte_adhesion.transmis = 1
				and sysdate >= (porte_adhesion.debut + param_tiers_payant.period)-param_tiers_payant.renouv
					)
		)
	Loop
		/*Fetch C_adherent into Rec_c_adherent;
		Exit When C_adherent%NotFound;*/
		dbms_output.put_line('Numporte '|| I_numporte
				|| ' Idadhesion '||Rec_c_adhesion.idadhesion
				|| ' Numgar '||I_numgar
				|| ' Numindiv '||C_adherent.numindiv);
				/*|| ' Idebut '||I_debut);*/
	/*P_INS_demande_tp (
		I_numporte => Rec_c_adhesion.numporte,
		I_idadhesion => Rec_c_adhesion.idadhesion,
		I_numgar => Rec_c_adhesion.numgar,
		I_numindiv => Rec_c_adhesion.numindiv,
		I_debut => Rec_c_adhesion.date_fin_adhe + 1,
		I_type => 17
		);*/
	End Loop;
	/*Close C_adherent;*/
End Loop;
Close C_adhesion;
END P_DMNDE_carte;
/
