CREATE FUNCTION ARTHUS.F_Dcpt_Dest (I_NUMSIN IN Number)
    RETURN NUMBER
IS
--
 CURSOR C_Sntr IS
	SELECT  nvl(COURR_DEST.NUMINDIV, SINISTRE.NUMBENE) NUMINDIV_DEST
	FROM SINISTRE, SNTR_DOSSIER, COURR_DEST
	WHERE SINISTRE.NUMSIN=I_NUMSIN
	AND SINISTRE.NUMSIN=SNTR_DOSSIER.NUMSIN_SNTR(+)
	AND SNTR_DOSSIER.NUM_DOSSIER=COURR_DEST.ID(+)
	AND COURR_DEST.CODE(+)=28
	AND COURR_DEST.VALIDE(+)=1;

 R_sntr C_Sntr%ROWTYPE;

 O_Numindiv_Dest number(6);
--
BEGIN


	    OPEN C_Sntr;
	    FETCH C_Sntr INTO R_sntr;
	    IF C_Sntr%FOUND THEN
			O_Numindiv_Dest:=R_sntr.NUMINDIV_DEST;
	    Else
	    	select numbene
	    	into O_Numindiv_Dest
	    	from sinistre
	    	where numsin=I_NUMSIN;
	    end if;

	    CLOSE C_Sntr;

	    RETURN(O_Numindiv_Dest);

END;
