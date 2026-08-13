CREATE function ARTHUS.f_role (
				a_numindiv	 in number,
				a_role	 	in number
				)
Return number
as
 CURSOR C_role IS
        SELECT  1
        FROM    v_new_role
	Where	numde =   a_numindiv
        And     role  =   a_role;
 loc_retour Number;
BEGIN
If ( a_role = 0 ) then
	Return ( 1 );
Else
  BEGIN
      OPEN C_role;
      FETCH C_role into loc_retour;
      IF C_role%FOUND THEN
        loc_retour :=1;
      ELSE
        loc_retour := 0;
      END IF;
      CLOSE C_role;
  END;
End if;
Return ( loc_retour );
END	f_role;
