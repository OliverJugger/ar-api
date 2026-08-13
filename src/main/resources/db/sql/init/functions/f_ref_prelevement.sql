CREATE function ARTHUS.f_ref_prelevement(a_numprelev in number)
Return Varchar2
As
	loc_ref Varchar2(18);
Begin
	Begin
	Select distinct 'ECHE '||to_char(qttc_global.debut,'dd/mm/yyyy')
	Into loc_ref
	From qttc_global,prelevement_detail
	Where prelevement_detail.numprelev=a_numprelev
	And prelevement_detail.numfact=qttc_global.numquit;
	Return(loc_ref);
	Exception
	When no_data_found then loc_ref:='';
	When too_many_rows then loc_ref:='ECHE MULTIPLES';
	End;
Return(loc_ref);
End;
