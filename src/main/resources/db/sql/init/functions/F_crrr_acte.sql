CREATE Function ARTHUS.F_crrr_acte
	(I_numdec     In number,
 	 I_numsin     In number,
	 I_regime     In number
	)
Return Varchar2
Is
Loc_Texte  				 varchar2(128);
Loc_Ligne_Extraite       varchar2(128);
Loc_Lignes_Concat      varchar2(512);

Cursor C_crrr_compl IS
    SELECT	Replace(crrr.text,'-',' ')
       FROM   crrr
       WHERE  numdec=I_numdec
       AND    crrr.numsin =I_numsin
       AND    crrr.text is not null
       ORDER BY crrr.type,crrr.seq;

Cursor C_crrr_oblg IS
    SELECT	Replace(crrr.text,'-',' ')
       FROM   crrr
       WHERE  numdec=I_numdec
       AND    crrr.numsin =I_regime
       AND    crrr.text is not null
       ORDER BY crrr.type,crrr.seq;

BEGIN
	-- Traitement du régime Complémentaire
	BEGIN
		Open C_crrr_compl;
		Loop
			Fetch C_crrr_compl Into Loc_Texte;
			Exit when C_crrr_compl%NOTFOUND;
			Loc_Ligne_Extraite	:= Loc_Texte;
				--Loc_Lignes_Concat :=Loc_Lignes_Concat || rpad(Loc_Ligne_Extraite,128,' ');
			Loc_Lignes_Concat :=substr(Loc_Lignes_Concat || chr(10)||trim(Loc_Ligne_Extraite),1,512);
		End Loop;
		Close C_crrr_compl;
	EXCEPTION
		WHEN OTHERS THEN NULL;
	END;
	-- Traitement du régime Obligatoire
	BEGIN
        Open C_crrr_oblg;
		Loop
            Fetch C_crrr_oblg Into Loc_Texte;
            EXIT WHEN C_crrr_oblg%NotFound;
            Loc_Ligne_Extraite	:= Loc_Texte;
			--Loc_Lignes_Concat := Loc_Lignes_Concat || rpad(Loc_Ligne_Extraite,128,' ');
			Loc_Lignes_Concat :=substr(Loc_Lignes_Concat || chr(10)||trim(Loc_Ligne_Extraite),1,512);
	    End Loop;
        Close C_crrr_oblg;
    EXCEPTION
		WHEN OTHERS THEN NULL;
	END;

	--Loc_Lignes_Concat :=substr(Loc_Lignes_Concat,1,length(Loc_Lignes_Concat)-1);
	Loc_Lignes_Concat :=substr(Loc_Lignes_Concat,2,512);
	Return(Loc_Lignes_Concat);
END;
