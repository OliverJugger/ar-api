CREATE procedure ARTHUS.fetch_variable (
				comm_numfor 	in 	number,
				comm_debut	in 	date,
				loc_idvariable 	out	number,
				data_found	out 	number
				)
is
Cursor Fetch_idvariable is
	Select	distinct frml_prime.base
	From	frml_prime
	Where	frml_prime.valide = 'O'
        and    	comm_debut between frml_prime.debut
			   and nvl(frml_prime.fin, comm_debut)
	Union
	Select	distinct to_number(frml_prime.taux)
	From	frml_prime
	Where	to_number(frml_prime.taux) != 0
	and	frml_prime.valide = 'O'
        and    	comm_debut between frml_prime.debut
			   and nvl(frml_prime.fin, comm_debut)
	and	frml_prime.numfor = comm_numfor
	Union
	Select	distinct idvariable
	From	frmlvar_detail,
		frml_tfc
	Where	frmlvar_detail.idformule = frml_tfc.idformule
	and	frml_tfc.valide = 'O'
	and	frml_tfc.tfc = 4
        and    	comm_debut between frml_tfc.debut
			   and nvl(frml_tfc.fin, comm_debut)
	and	frml_tfc.numfor = (
			select	numgar
			from	gar_cntrt
			where	gar_cntrt.numfor = comm_numfor)
	Union
	Select	distinct idvariable
	From	frmlvar_detail,
		frml_tfc
	Where	frmlvar_detail.idformule = frml_tfc.idformule
	and	frml_tfc.valide='O'
	and	frml_tfc.tfc != 4
        and    	comm_debut between frml_tfc.debut
			   and nvl(frml_tfc.fin, comm_debut)
	and	frml_tfc.numfor = comm_numfor
	Union
        Select 	distinct frmlvar_detail.idvariable
        From   	frmlvar_detail,
		frml_prest
	Where	frmlvar_detail.idformule = frml_prest.idformule
        and  	frml_prest.valide = 'O'
        and    	comm_debut between frml_prest.debut
			   and nvl(frml_prest.fin, comm_debut)
        and    	frml_prest.numfor = comm_numfor
        Union
        Select 	distinct frmlvar_detail.idvariable
        From   	frmlvar_detail,
		frml_reval
	Where	frmlvar_detail.idformule = frml_reval.idformule
        and  	frml_reval.valide = 'O'
        and    	comm_debut between frml_reval.debut
			   and nvl(frml_reval.fin, comm_debut)
        and    	frml_reval.numfor = comm_numfor
        Union
        Select 	distinct frmlvar_detail.idvariable
        From   	frmlvar_detail,
		frml_dedu
	Where	frmlvar_detail.idformule = frml_dedu.idformule
        and  	frml_dedu.valide = 'O'
        and    	comm_debut between frml_dedu.debut
			   and nvl(frml_dedu.fin, comm_debut)
        and    	frml_dedu.numfor = comm_numfor
	Union
	Select	distinct frmlvar_detail.idvariable
	From	frmlvar_detail,
		carence
	Where	frmlvar_detail.idformule = carence.nummath
	and	carence.numfor = comm_numfor
	;
BEGIN
If Not Fetch_idvariable%Isopen then
	Open Fetch_idvariable;
End if;
Fetch Fetch_idvariable into
	loc_idvariable;
If Fetch_idvariable%NotFound then
	Close Fetch_idvariable;
	Data_found := 0;
End if;
END;
/
