CREATE function ARTHUS.f_idvar (a_etendue in number,
				    a_clef in number,
				    a_numgar in number)
		return pk_types.t_table
as
	idvariable		pk_types.t_table;
	retour 			number;
	i		binary_integer := 0 ;
BEGIN
i:=1;
while (retour>0) loop
	begin
	SELECT val_variable.idvariable
	INTO retour
	FROM val_variable
	WHERE etendue=a_etendue
	AND clef=a_clef
	AND numgar=a_numgar
	AND nvl(fin,sysdate)>=sysdate;
	EXCEPTION
	when no_data_found then retour:=0;
	end;
	idvariable(i):=retour;
	i:=i+1;
end loop;
idvariable(i+1):=0;
RETURN idvariable;
END;
