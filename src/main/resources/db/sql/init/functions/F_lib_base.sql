CREATE Function ARTHUS.F_lib_base(I_numquit     In number
		                      )
Return Varchar2
Is
L_lib_base  varchar2(40);
L_base       varchar2(40);
L_ligne      varchar2(500);

Cursor C_lib_base IS
       Select distinct def_variable.lib_variable
       From qttc_variable,def_variable
       Where def_variable.idvariable=qttc_variable.idbase
       And numquit=I_numquit;

BEGIN
    Open C_lib_base;
     Loop
	Fetch C_lib_base Into L_lib_base;
        EXIT WHEN  C_lib_base%NotFound;
        L_base:= L_lib_base;
  	L_ligne:=L_ligne||' '||L_base;
     End Loop;
    Close C_lib_base;
    Return(L_ligne);
END;
