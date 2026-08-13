CREATE Function ARTHUS.F_crrr_acte_ro(I_numdec     In number,
                                       I_numsin     In number
		                       )
Return Varchar2
Is
L_crrr_acte  varchar2(150);
L_comm       varchar2(150);
L_ligne      varchar2(500);

Cursor C_crrr_oblg IS
       SELECT	Replace(crrr.text,'-',' ')
       FROM   crrr
       WHERE  numdec=I_numdec
       AND    crrr.numsin =I_numsin
       AND    crrr.text is not null
       ORDER BY crrr.type,crrr.seq;

BEGIN
     Open C_crrr_oblg;
      Loop
         Fetch C_crrr_oblg Into L_crrr_acte;
         EXIT WHEN C_crrr_oblg%NotFound;
         L_comm:= L_crrr_acte;
  	 L_ligne:=L_ligne||' '||L_comm;
      End Loop;
     Close C_crrr_oblg;
    Return(L_ligne);
END;
