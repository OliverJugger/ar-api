CREATE procedure ARTHUS.charge_histo_ss
is
CURSOR C_SS IS
	select num_dossier, numligne, situation, motif, creation, numutil
		from sinistre_sante;
	R_SS C_SS%ROWTYPE;
BEGIN
	OPEN C_SS;
	LOOP
		FETCH C_SS INTO R_SS;
		EXIT WHEN C_SS%NOTFOUND;
		INSERT INTO HISTO_SINISTRE_SANTE
				( num_dossier,
				  numligne,
				  etat,
				  motif,
				  datetat,
				  numutil)
			 VALUES (R_SS.NUM_DOSSIER,
					R_SS.NUMLIGNE,
					R_SS.SITUATION,
					R_SS.MOTIF,
					R_SS.CREATION,
					R_SS.NUMUTIL);
	END LOOP;
	CLOSE C_SS;
END;
/
