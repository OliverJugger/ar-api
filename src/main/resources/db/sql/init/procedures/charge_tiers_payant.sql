CREATE procedure ARTHUS.charge_tiers_payant(
					a_numporte in number,a_numgar in number,
					a_etat in number,a_poch in varchar2,
					a_date in date default null
					)
IS
-- Variable de reconnaissance SCCS
-- %W%    %E%
Cursor fetch_tiers_payant is
	Select 	porte_adhesion.numindiv,
		porte_adhesion.idadhesion,
		max(porte_adhesion.fin) fin,
		1 test
	From	adhe_cntrt,
		porte_adhesion
	Where	adhe_cntrt.numgar=a_numgar
	And	adhe_cntrt.idadhesion=porte_adhesion.idadhesion
	and	porte_adhesion.numporte=a_numporte
	And	a_date is null
	Group by
		porte_adhesion.numindiv,
		porte_adhesion.idadhesion
	having	max(porte_adhesion.fin)-
			(f_info_tiers_payant(a_numporte,a_numgar,19))
						<=sysdate
	Union
	Select	adhesion.numindiv,
		adhesion.idadhesion,
		greatest(min(adhesion.datapli),a_date) fin,
		2 test
	From	indvs,
		adhesion,
		adhe_cntrt_membre,
		porte_contrat
	Where	porte_contrat.numporte = a_numporte
	and	adhesion.numgar = a_numgar
	and 	porte_contrat.numgar=adhesion.numgar
	and 	adhesion.etat in	(
			select code from lble
			where mnemo='ETIN'
			and sens=0
		    	)
	and 	nvl(datper, sysdate) >= sysdate
	and	datapli != nvl(datper, datapli+1)
	and	adhesion.rang = 1
	and	indvs.numindiv = adhesion.numindiv
	And	adhe_cntrt_membre.idadhesion=adhesion.idadhesion
	And	adhe_cntrt_membre.numindiv=indvs.numindiv
	and	adhe_cntrt_membre.typadr=0
	And 	f_last_idporte(a_numporte,adhesion.numindiv,
				adhesion.idadhesion,0)=-1
	And	a_date is not null
	group by
		adhesion.idadhesion,
		adhesion.numindiv
	;
Cursor C_indiv ( P_numindiv IN indvs.numindiv%Type ) IS
	Select	regime,
		caisse
	From	indvs
	Where 	numindiv = P_numindiv;
--
Cursor C_contrat IS
	Select	numinterm	numsoc,
		numorg
	From	contrat
	Where	numgar = a_numgar;
--
Rec_C_indiv	C_indiv%Rowtype;
Rec_C_contrat	C_contrat%Rowtype;
Rec_C_tp fetch_tiers_payant%Rowtype;
loc_idporte number;
loc_type_porte number;
loc_period  number;
loc_debut date;
loc_numporte pk_types.t_table;
i 	number;
BEGIN
For Rec_C_tp in fetch_tiers_payant
Loop
loc_type_porte := f_type_porte(a_numporte);
If (loc_type_porte=2) Then
	if (f_etat_adhe(Rec_C_tp.idadhesion,
			Rec_C_tp.fin+1)=1
			)
	then
		Select nvl(max(porte_adhesion.idporte),0)+1
		Into loc_idporte
		From porte_adhesion;
		loc_period:=f_info_tiers_payant(a_numporte,a_numgar,9);
		If (Rec_C_tp.test=1) then
		Select (Rec_C_tp.fin)+1
		Into loc_debut
		From dual
		;
		Else
		loc_debut:=Rec_C_tp.fin;
		End if;
		--
		Open C_indiv( Rec_C_tp.numindiv );
		Fetch C_indiv Into Rec_C_indiv;
		Close C_indiv;
		--
		Open C_contrat;
		Fetch C_contrat Into Rec_C_contrat;
		Close C_contrat;
		--
		If ( pk_porte.F_ouverte (
			I_numporte	=>  a_numporte,
			I_numreg	=>  Rec_C_indiv.regime,
			I_numsoc	=>  Rec_C_contrat.numsoc,
			I_numorg	=>  Rec_C_contrat.numorg,
			I_numcaisse	=>  Rec_C_indiv.caisse
			)
		) Then
			ins_demande_tiers_payant
			(a_numporte,Rec_C_tp.idadhesion,
			a_numgar,Rec_C_tp.numindiv,7,loc_debut,a_poch,
			a_etat)
			;
		End if;
	commit;
	end if;
End if;
End loop;
END;
/
