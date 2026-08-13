CREATE procedure ARTHUS.rech_rejet
Is
	loc_numporte pk_types.t_table;
	i 	number;
	loc_last_idporte	number;
	loc_type_porte	number;
	Cursor fetch_porte_adhesion is
	Select  porte_adhesion.numindiv,
		porte_adhesion.idadhesion,
		indvs.nom||' '||indvs.prenom nom
	From	indvs,porte_adhesion
	Where	porte_adhesion.transmis=7
	And	porte_adhesion.numporte=1
	And	porte_adhesion.numindiv=indvs.numindiv
	And	not exists(select 1 from porte_adhesion a
			   where a.numindiv=porte_adhesion.numindiv
			   and a.idadhesion=porte_adhesion.idadhesion
			   and a.transmis!=7
			   and a.numporte=1
			)
	;
loc_porte_adhesion fetch_porte_adhesion%Rowtype;
Begin
	For loc_porte_adhesion in fetch_porte_adhesion
	Loop
	If (f_etat_adhe(loc_porte_adhesion.idadhesion,sysdate)=1) then
	dbms_output.put_line('Assuré '||loc_porte_adhesion.numindiv||' '||loc_porte_adhesion.nom||' '||loc_porte_adhesion.idadhesion);
	End if;
End loop;
End;
/
