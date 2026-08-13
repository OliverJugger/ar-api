CREATE procedure ARTHUS.liste_pharma
Is
	i 	number;
	loc_last_idporte	number;
	loc_numporte pk_types.t_table;
	loc_type_porte	number;
	Cursor fetch_adhesion is
	Select 	adhesion.numindiv,
		porte_contrat.numgar,
		indvs.caisse,
		indvs.nom||' '||indvs.prenom nom,
		adhesion.idadhesion,
		adhesion.datapli,
		adhesion.datper
	From	indvs,contrat,adhe_cntrt,adhesion,porte_contrat
	Where	adhesion.numindiv=indvs.numindiv
	and	adhe_cntrt.idadhesion=adhesion.idadhesion
	and	nvl(adhe_cntrt.date_fin_adhe,sysdate)>=sysdate
	and	nvl(adhesion.datper,sysdate)>=sysdate
	And	nvl(adhesion.datper,adhesion.datapli+1)!=adhesion.datapli
	And	adhesion.etat in(Select code from lble where mnemo='ETIN'
				 and sens=0)
	and	contrat.numgar=porte_contrat.numgar
	and	adhe_cntrt.numgar=contrat.numgar
	and	adhesion.rang=1
	and	indvs.typassu=1
	And	porte_contrat.numporte=3
	And	not exists(select 1 from porte_adhesion
			   where porte_adhesion.idadhesion=adhe_cntrt.idadhesion
			and porte_adhesion.numporte=3
			and porte_adhesion.numindiv=indvs.numindiv)
	;
loc_adhesion fetch_adhesion%Rowtype;
Begin
loc_numporte := f_adhesion_externe(loc_adhesion.numgar, loc_adhesion.numindiv);
i := 1;
While ( loc_numporte(i) > 0 ) LOOP
	For loc_adhesion in fetch_adhesion
	Loop
	loc_last_idporte := f_last_idporte(loc_numporte(i),
						loc_adhesion.numindiv,
						loc_adhesion.idadhesion);
	IF (loc_last_idporte = -1) then		/* Jamais dans porte_adhesion */
dbms_output.put_line('Assuré '||loc_adhesion.numindiv||' '||loc_adhesion.nom||' '||loc_adhesion.idadhesion);
	END IF;
	End loop;
END LOOP;
End;
/
