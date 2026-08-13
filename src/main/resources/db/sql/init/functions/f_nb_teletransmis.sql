CREATE function ARTHUS.f_nb_teletransmis(a_numporte in number,a_numinterm
in number,a_numorg in number default null,a_numgar in number default null,
a_date in date default sysdate)
Return number
as
	loc_nombre number default 0;
	Cursor fetch_porte_adhesion is
	Select 	porte_adhesion.numporte,
		porte_adhesion.numindiv,
		porte_adhesion.idadhesion
	From	porte_adhesion
	Where	porte_adhesion.numporte=a_numporte
	And	porte_adhesion.mouvement='C'
	And	porte_adhesion.transmis=1
	And	a_date between porte_adhesion.debut and
		nvl(porte_adhesion.fin,a_date)
	And	Exists(select 1 from adhe_cntrt,contrat
			where adhe_cntrt.numgar=contrat.numgar
			and contrat.numgar=nvl(a_numgar,contrat.numgar)
			and contrat.numinterm=a_numinterm
			and contrat.numorg=nvl(a_numorg,contrat.numorg)
			and adhe_cntrt.idadhesion=porte_adhesion.idadhesion
			)
	;
loc_porte_adhesion fetch_porte_adhesion%Rowtype;
Begin
	For loc_porte_adhesion in fetch_porte_adhesion
	Loop
		loc_nombre:=loc_nombre+1;
	End loop;
Return(loc_nombre);
End;
