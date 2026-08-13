CREATE Function ARTHUS.F_typtaux(I_numgar In number )

Return Number
Is
L_typtaux      qttc_variable.typtaux%type;

BEGIN
    Begin
     SELECT	distinct qttc_variable.typtaux
        INTO    L_typtaux
	FROM	grp_gar,grp_gar_def,gar_cntrt,qttc_variable
        Where   grp_gar.numgrpgar=grp_gar_def.numgrpgar
        And     grp_gar_def.numfor=gar_cntrt.numfor
        And     qttc_variable.numfor=gar_cntrt.numfor
        And     grp_gar_def.numfor=qttc_variable.numfor
	And	grp_gar.etendue = 2
        And	grp_gar.valide = 'O'
        and grp_gar.clef =I_numgar
        union
	SELECT	distinct qttc_variable.typtaux
      	FROM	gar_cntrt,qttc_variable
	WHERE	gar_cntrt.numfor=qttc_variable.numfor
        AND     gar_cntrt.valide = 'O'
        and     gar_cntrt.numgar=I_numgar
        AND     not exists ( SELECT	1
				FROM	grp_gar_def
				where grp_gar_def.numfor=gar_cntrt.numfor);
       Exception
         When No_data_found then
            L_typtaux:=Null;
         When Too_many_rows then
            L_typtaux:=Null;
       End;
       Return(L_typtaux);
END;
