CREATE function ARTHUS.f_mnemo_donnee (
				a_cle_base	in	number
				)
Return Varchar2
AS
loc_mnemo	varchar2(12);
BEGIN
	Select	don_base.code
	Into	loc_mnemo
	From	libelle_bis	don_base
	Where	don_base.mnemo = 'DON_BASE'
	and	don_base.sens = (
			select	sens
			from	libelle cle_base
			where	cle_base.mnemo = 'CLE_BASE'
			and	cle_base.code =  a_cle_base
			and	cle_base.tableau=0)
	Union
	Select	don_base.code
	From	libelle_bis	don_base
	Where	don_base.mnemo = 'DON_BASE'
	and	don_base.sens = (
			select	codapli
			from	libelle cle_base
			where	cle_base.mnemo = 'CLE_BASE'
			and	cle_base.code =  a_cle_base
			and	cle_base.tableau>0)
	;
Return ( loc_mnemo );
END;
