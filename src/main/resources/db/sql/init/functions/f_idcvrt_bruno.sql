CREATE FUNCTION ARTHUS.f_idcvrt_bruno(
			a_numindiv in number,
			a_codfrais in varchar2,
			a_datsin in date,
			a_action in number)
RETURN 	varchar2
AS
	loc_idcvrt	varchar2(30);
	loc_numfor	number default 0;
	Cursor fetch_adhesion is
		Select	rowidtochar(adhesion.rowid) idcvrt,
			adhesion.numfor,
			adhesion.rang
		From	adhesion
		Where	adhesion.numindiv = a_numindiv
		and	a_datsin between adhesion.datapli
				 and     nvl(adhesion.datper, a_datsin)
		and	adhesion.datapli != nvl(adhesion.datper, adhesion.datapli + 1)
		and	adhesion.typfor = 1
		Union
		Select	rowidtochar(adhesion.rowid),
			grp_gar_def.numfor,
			rang
		From	grp_gar_def,
			adhesion
		Where	grp_gar_def.numgrpgar = adhesion.numfor
		and	adhesion.numindiv = a_numindiv
		and	a_datsin between adhesion.datapli
				 and     nvl(adhesion.datper, a_datsin)
		and	adhesion.datapli != nvl(adhesion.datper, adhesion.datapli + 1)
		and	adhesion.typfor = 3
		and	grp_gar_def.typfor = 1
		Order by 	2
		;
	loc_adhesion	fetch_adhesion%ROWTYPE;
BEGIN
If (a_codfrais is not null and a_action = 1) then
for loc_adhesion in fetch_adhesion
loop
	Begin
	Select	numfor
	Into	loc_numfor
	From	calcul
	Where	calcul.numfor = loc_adhesion.numfor
	and	calcul.codfrais = a_codfrais
	and	a_datsin between calcul.datapli
			 and     nvl(calcul.datper, a_datsin)
	and	calcul.datapli != nvl(calcul.datper, calcul.datapli + 1)
	;
	Exception When No_data_found then loc_numfor := 0;
	End;
	if loc_numfor != 0 then
		loc_idcvrt := loc_adhesion.idcvrt;
		exit;
	end if;
end loop;
Else
	loc_idcvrt := 0;
End If;
-- Exception When No_data_found then return('');
return(loc_idcvrt);
END;
