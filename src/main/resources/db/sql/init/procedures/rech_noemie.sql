CREATE procedure ARTHUS.rech_noemie
Is
	loc_numporte pk_types.t_table;
	i 	number;
	loc_last_idporte	number;
	loc_type_porte	number;
	Cursor fetch_adhesion is
	Select distinct adhesion.numindiv,
		porte_contrat.numgar,
		f_caisse(adhesion.numindiv),
		indvs.caisse,
		indvs.nom||' '||indvs.prenom nom,
		adhesion.idadhesion
	From	porte_contrat,adhesion,indvs
	Where	adhesion.numgar=porte_contrat.numgar
	And	porte_contrat.numporte=1
	And	nvl(adhesion.datper,adhesion.datapli+1)!=adhesion.datapli
	And	adhesion.etat in(Select code from lble where mnemo='ETIN'
				 and sens=0)
	And	adhesion.numindiv=indvs.numindiv
	;
loc_adhesion fetch_adhesion%Rowtype;
Begin
	For loc_adhesion in fetch_adhesion
	Loop
	If (f_etat_adhe(loc_adhesion.idadhesion,sysdate)=1) then
loc_numporte := f_adhesion_externe(loc_adhesion.numgar,loc_adhesion.numindiv);
/* Verifions si il y a deja des donnees dans porte_adhesion */
loc_last_idporte := f_last_idporte(loc_numporte(1), loc_adhesion.numindiv,
				loc_adhesion.idadhesion);
IF (loc_last_idporte = -1) then		/* Rien dans porte_adhesion */
	dbms_output.put_line('Assuré '||loc_adhesion.numindiv||' '||loc_adhesion.nom||' '||loc_adhesion.idadhesion);
End if;
End if;
End loop;
End;
/
