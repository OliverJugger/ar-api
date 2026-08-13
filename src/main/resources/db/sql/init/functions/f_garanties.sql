CREATE function ARTHUS.f_garanties
		(a_numfor in number, a_etendue in number) Return number
IS
  CURSOR C_sinistre IS
	SELECT 'X'
	FROM   sinistre
	WHERE  numfor = a_numfor;
	--
  L_test VARCHAR2(1);
  Loc_test number:=0;
Begin

If (a_etendue=2) Then
	Begin
	--
	OPEN  C_sinistre;
	FETCH C_sinistre INTO L_test;
	IF C_sinistre%FOUND THEN
	   Close C_sinistre;
	   Loc_test := 1;
	   Return(Loc_test);
	END IF;
	Close C_sinistre;
	--
	Select 1
	Into loc_test
	From dual
	Where exists(select 1 from qttc_gar
		     where numfor=a_numfor
		    )
	;

	Return(loc_test);

	Exception
	When no_data_found then
			Begin
			Select 1
 			Into loc_test
			From dual
			Where exists(
					select 1 from adhesion
				        where (
						(adhesion.numfor=a_numfor)
					or
						(adhesion.numfor in
						(select numgrpgar
						from grp_gar_def
						where numfor=a_numfor
						)
						)
					      )
				    );
			Return(loc_test);
			Exception when no_data_found then
				loc_test:=0;
				Return(loc_test);
			end;
	End;
	--
Elsif (a_etendue=7) Then

	Begin
		Select 1
		Into loc_test
		From dual
		Where exists
			(select 1 from gar_cntrt
			where numfor_ref=a_numfor
			)
		;

		Return(loc_test);

		Exception
		When no_data_found then
			loc_test:=0;
			Return(loc_test);

	End;
End if;
End;
