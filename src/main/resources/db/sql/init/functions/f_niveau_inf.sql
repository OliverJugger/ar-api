CREATE function ARTHUS.f_niveau_inf (
				a_sens in number,
				a_mnemo_base in varchar2,
				a_mnemo in varchar2,
				a_mnemo_lble in varchar2,
				a_code in varchar2
				)
Return number
AS
loc_niveau	number;
BEGIN
	select  count(*)
	Into loc_niveau
	from v_libelle_bis
	where mnemo=a_mnemo_base
	and sens=a_sens
	and code in(	select code from libelle_bis
			where mnemo=a_mnemo
			and sens in(
					select code
					from lble
					where mnemo=a_mnemo_lble
					and sens in (
							select sens
							from libelle_bis
							where mnemo=a_mnemo
							and code=a_code
						     )
				    )
		    );
	Return(loc_niveau);
END;
