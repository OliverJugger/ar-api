CREATE procedure ARTHUS.maj_groupe(a_numindiv in number,
					a_numindiv1 in number) is
Cursor fetch_indvs is
	Select indvs.numindiv,
		indvs.refcie
	From indvs
	Where numindiv between a_numindiv and a_numindiv1
	;
loc_indvs fetch_indvs%Rowtype;
BEGIN
For loc_indvs in fetch_indvs
Loop
	Update indvs
	Set numassu=loc_indvs.numindiv
	Where numindiv=loc_indvs.numindiv;
	Update indvs
	Set numassu=loc_indvs.numindiv
	Where substr(refcie,2,30)=loc_indvs.refcie
	And substr(refcie,1,1)='C'
	And typassu=2
	;
End loop;
END;
/
