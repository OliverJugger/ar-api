CREATE procedure ARTHUS.prch_numero(a_numpc in number,a_numentree in number,
					a_numfact in varchar2) is
Begin
	Update prch
	Set 	numentree=a_numentree,
		numfact=a_numfact
	Where numpc=a_numpc;
End;
/
