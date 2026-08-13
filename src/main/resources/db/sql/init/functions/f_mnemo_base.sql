CREATE function ARTHUS.f_mnemo_base (
				a_sens in number,
				a_mnemo_base in varchar2,
				a_mnemo in varchar2,
				a_mnemo_lble in varchar2,
				a_code in varchar2
				)
Return varchar2
AS
loc_mnemo	varchar2(15);
BEGIN
	select code
	Into loc_mnemo
	from libelle_bis
	where sens in (select sens from lble
		    where mnemo=a_mnemo_lble
		    and code in
				(select sens from libelle_bis
				 where mnemo=a_mnemo
				 and code=a_code)
			)
	and mnemo=a_mnemo;
	Return(loc_mnemo);
	Exception
		When no_data_found then loc_mnemo:='0';
		Return(loc_mnemo);
END;
