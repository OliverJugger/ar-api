CREATE procedure ARTHUS.init_parametres (
				a_numedit in number,
				o_valdeb7 out varchar2,
				o_valfin7 out varchar2)
is
BEGIN
Begin
Select	param_dmnde.valdeb7,
	param_dmnde.valfin7
Into	o_valdeb7,
	o_valfin7
From	param_dmnde,
	file_edition
Where	param_dmnde.numdmnde = file_edition.numdmnde
And	file_edition.numdmnde = a_numedit;
End;
END;
/
