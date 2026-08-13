CREATE procedure ARTHUS.reouvre_noemie
Is
	i 	number;
	loc_last_idporte	number;
	loc_type_porte	number;
	Cursor fetch_adhesion is
	Select adhesion.numindiv,
		porte_contrat.numgar,
		indvs.caisse,
		indvs.nom||' '||indvs.prenom nom,
		adhesion.idadhesion,
		adhesion.datapli,
		adhesion.datper
	From	indvs,contrat,adhe_cntrt,adhesion,parporte,porte_contrat
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
	and	parporte.numporte=porte_contrat.numporte
	and	parporte.numsoc=contrat.numinterm
	and	parporte.numreg=indvs.regime
	and	parporte.numorg=contrat.numorg
	and	parporte.numcaisse=indvs.caisse
	and	parporte.ouverte=1
	And	porte_contrat.numporte=1
	And	not exists(select 1 from porte_adhesion
			   where porte_adhesion.idadhesion=adhe_cntrt.idadhesion
			and porte_adhesion.numporte=1
			and porte_adhesion.numindiv=indvs.numindiv)
	group by
		adhesion.idadhesion,
		adhesion.numgar,
		adhesion.numindiv
	;
loc_adhesion fetch_adhesion%Rowtype;
Begin
	For loc_adhesion in fetch_adhesion
	Loop
	/* loc_last_idporte := f_last_idporte(1, loc_adhesion.numindiv,
				loc_adhesion.idadhesion); */
		ins_noemie(
			 1,loc_adhesion.numindiv,
			loc_adhesion.idadhesion, loc_adhesion.numgar,
			loc_adhesion.datapli, '',
			'C', 6
			)
	;
dbms_output.put_line('Assuré'||loc_adhesion.numindiv||' '||loc_adhesion.nom||' '||loc_adhesion.idadhesion);
	End loop;
End;
/
