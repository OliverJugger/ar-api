CREATE FUNCTION ARTHUS.F_frmls_compl (I_NUMGAR Number,I_NUMFOR Number )
    RETURN NUMBER
IS
--
 CURSOR C_frmls IS
	SELECT decode(frmls.flag_regime,'C',1,0) FRMLS_COMPL
	FROM   FRMLS
	WHERE  pk_qttc.f_sel_numfor(I_NUMGAR, I_NUMFOR)=frmls.numfor;

 R_frmls C_frmls%ROWTYPE;

 O_compl number(1):=0;
--
BEGIN


	    OPEN C_frmls;
	    FETCH C_frmls INTO R_frmls;
	    IF C_frmls%FOUND THEN
			O_compl :=R_frmls.FRMLS_COMPL;
	    end if;

	    CLOSE C_frmls;

	    RETURN(O_compl);

END;
