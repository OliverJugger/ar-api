CREATE function ARTHUS.f_piece_detail(
				a_codope	in number,
				a_numpiece	in number)
return	varchar2
is
	loc_libelle	varchar2(70);
begin
	if (a_codope = 1 )
	then
		select	contrat.refcie
		into	loc_libelle
		from	decompte,
			contrat
		where 	contrat.numgar	= decompte.numgar
		and	decompte.numdec	= a_numpiece
		;
	elsif (a_codope = 2)
	then
		select	contrat.refcie
		into	loc_libelle
		from	decompte_prev,
			adhe_cntrt,
			contrat
		where 	contrat.numgar	= adhe_cntrt.numgar
		and	adhe_cntrt.idadhesion=decompte_prev.idadhesion
		and	decompte_prev.numdec	= a_numpiece
		;
	elsif (a_codope = 5)
	then
		select	'Reversement de cotisations Bx N°'||
				reversement.idrevers||' '||
				orgns.nom
		into	loc_libelle
		from	orgns,
			reversement
		where	orgns.numorg		= reversement.numorg
		and	reversement.idrevers	= a_numpiece
		;
	elsif (a_codope = 6)
	then
		select	'Frais sur cotisations Bx N°'||
			reversement.idrevers||' '||
			orgns.nom
		into	loc_libelle
		from	orgns,
			reversement
		where	orgns.numorg		= reversement.numorg
		and	reversement.idrevers	= a_numpiece
		;
	elsif (a_codope = 8)
	then
		select	substr('Remb. compte client '||
			affectation.numcli || ' ' ||
			indvs.nom || ' ' || indvs.prenom, 1, 70)
		into	loc_libelle
		from	affectation,
			indvs
		where	affectation.codope	= 8
		and	affectation.numaffec	= a_numpiece
		and	indvs.numindiv		= affectation.numcli
		;
	elsif (a_codope = 9)
	then
		select	to_char(pnul.datannul,'dd/mm/yy')||
			' '||
			libelle.libelle
		into	loc_libelle
		from	pnul,
			libelle
		where	pnul.codope	= 9
		and	pnul.numaffec	= a_numpiece
		and 	libelle.mnemo	= 'PNUL'
		and 	libelle.code	= pnul.motif
		;
	elsif (a_codope = 11)
	then
		select	'Bx reversement taxes N° '||dcptdedu.numdec
		into	loc_libelle
		from	dcptdedu
		where	dcptdedu.numdec	= a_numpiece
		;
	end if;
return(loc_libelle);
end f_piece_detail;
