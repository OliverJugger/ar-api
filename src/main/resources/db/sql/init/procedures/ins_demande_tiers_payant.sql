CREATE procedure ARTHUS.ins_demande_tiers_payant
		(a_numporte in number,a_idadhesion in number,
		a_numgar in number,a_numindiv in number,a_type in number,
		a_datapli in date,a_poch in varchar2 default null,
		a_etat in number default null)
Is
	loc_idporte	number;
	loc_type	number;
	loc_transmis	number;
	loc_etat	number;
	loc_fin		date;
	loc_period	number;
	loc_carnet	varchar2(2);
	loc_poch	varchar2(1);
	loc_anniv 	varchar2(5);
	loc_anniv_contrat varchar2(5);
	loc_date_temp	date;
BEGIN
	begin
	select nvl(max(idporte),0)+1
	into loc_idporte
	from porte_adhesion;
	end;

	Select to_char(a_datapli,'dd/mm')
	Into loc_anniv
	From dual
	;

	Select to_char(eche_anniv,'dd/mm')
	Into loc_anniv_contrat
	From contrat
	Where numgar = a_numgar
	--  and numgar_ref=pk_qttc.f_sel_numgar(a_numgar)
	;

	loc_period:=to_number(f_info_tiers_payant(a_numporte,a_numgar,9));

	If (loc_anniv=loc_anniv_contrat)
	Then

	Select add_months(a_datapli,loc_period)-1
	Into loc_fin
	From dual;

	Else

	Select add_months(trunc(a_datapli,decode(loc_period,1,'MM',
							3,'Q',
							6,'Y',
							12,'YYYY'
						)),loc_period)-1
	Into loc_fin
	From dual;

	End if;

	Select loc_fin - f_info_tiers_payant(a_numporte,a_numgar,19)
	Into loc_date_temp
	From dual
	;

	If (a_datapli>=loc_date_temp)
	then
	Select add_months(loc_fin,loc_period)
	Into loc_fin
	From dual;
	End if;

	loc_type:=f_ano_tiers_payant(a_numindiv,a_numporte,a_numgar,a_idadhesion);

	If (loc_type=-1)
	Then
		loc_type:=a_type;
		loc_transmis:=2;
	Else
		loc_transmis:=6;
	End if;

	begin
	insert into porte_adhesion(
			numporte, numindiv, debut, fin, mouvement, transmis,
			numremise, idadhesion, type, idporte)
	select	a_numporte,
		a_numindiv,
		a_datapli,
		loc_fin,
		'C',
		loc_transmis,
		0,
		a_idadhesion,
		loc_type,
		loc_idporte
	from	DUAL
	;

	loc_carnet:=f_info_tiers_payant(a_numporte,a_numgar,8);
	If (a_poch is null)
	Then
	loc_poch:=f_info_tiers_payant(a_numporte,a_numgar,18);
	Else
	loc_poch:=a_poch;
	End if;
	If (a_etat is null)
	Then
	loc_etat:=f_info_tiers_payant(a_numporte,a_numgar,17);
	Else
	loc_etat:=a_etat;
	end if;

	Insert into demande_tiers_payant(
		idporte,numremise, creation,etat,datedit,
		type,transmis,nb_carnet,type_poch)
	Select	loc_idporte,0,sysdate, loc_etat,'',
		loc_type,loc_transmis,loc_carnet,
		loc_poch
	From	dual
	;

	end;
END;
/
