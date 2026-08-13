CREATE function ARTHUS.f_idadhesion_prev
				(a_nosin in number)
Return number
Is
	Cursor fetch_repartition is
	Select
		repartition.idadhesion
	From	repartition
	Where	repartition.nosin=a_nosin
	And	repartition.valide='O'
	;
l_idadhesion repartition.idadhesion%Type;
Begin
  OPEN  fetch_repartition;
  FETCH fetch_repartition INTO l_idadhesion;
  CLOSE fetch_repartition;
  RETURN l_idadhesion;
End f_idadhesion_prev;
