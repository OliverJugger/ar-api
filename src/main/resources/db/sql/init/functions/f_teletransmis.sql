CREATE FUNCTION ARTHUS.f_teletransmis(
			a_idadhesion in number,
			a_numindiv in number,
			a_codfrais in varchar2,
			a_datsin in date,
			a_regime in number)
RETURN 	number
AS
	loc_transmis	number default 0;
	loc_retour	number := 0;
	loc_porte	porte_param%ROWTYPE;
	loc_trans	porte_adhesion%ROWTYPE;
BEGIN
For loc_porte in (
	Select	numporte
	From	porte_param
	Where	subst = 'O'
	and	f_type_porte(numporte) =1)
Loop
	For loc_trans in (
		Select	numremise
		from	porte_adhesion
		where	transmis = 1
		and	mouvement != 'A'
		and	a_datsin between debut
				 and nvl(fin, a_datsin)
		and	idadhesion = a_idadhesion
		and	numindiv = a_numindiv
		and	numporte = loc_porte.numporte
		and not	exists (
			select	1
			from	porte_adhesion
			where	transmis = 1
			and	mouvement = 'A'
			and	a_datsin between debut
				 and nvl(fin, a_datsin)
			and	idadhesion = a_idadhesion
			and	numindiv = a_numindiv
			and	numporte = loc_porte.numporte
			)
		and exists (
			select	1
			from	natfrais,
				porte_natfrais
			where	natfrais.codfrais = porte_natfrais.codfrais
			and	porte_natfrais.action != 2
			and	porte_natfrais.regime = a_regime
			and	porte_natfrais.codfrais = a_codfrais
			and	porte_natfrais.numporte = loc_porte.numporte
			)
	Order by idporte)
	Loop
	If ( loc_trans.numremise != 0 ) then
		Begin
		Select	1
		Into	loc_retour
		From	remise_externe
		Where	numremise = loc_trans.numremise
		and	nvl( date_trans, a_datsin+1 ) <= a_datsin;
		Exception When No_data_found then loc_retour := 0;
		End;
		If ( loc_retour = 1 ) then
			Exit;
		End if;
	End if;
	End loop;
If ( loc_retour = 1 ) then
	Exit;
End if;
End loop;
return(loc_retour);
END;
