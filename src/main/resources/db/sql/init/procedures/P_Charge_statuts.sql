CREATE PROCEDURE ARTHUS.P_Charge_statuts
					IS
--
CURSOR C_DECOMPTEE (DOSSIER VARCHAR2, LIGNE NUMBER)
	IS
		SELECT ALL DCPT.DATPAY
			FROM DCPT, SINISTRE, SNTR_DOSSIER
			WHERE (SNTR_DOSSIER.NUM_DOSSIER = DOSSIER
			 AND SNTR_DOSSIER.NUMLIGNE = LIGNE)
			 AND ((SINISTRE.NUMSIN = SNTR_DOSSIER.NUMSIN_SNTR)
			 AND (SINISTRE.NUMDEC = DCPT.NUMDEC));
	R_DECOMPTEE	C_DECOMPTEE%ROWTYPE;

CURSOR C_SS IS
	SELECT ALL SINISTRE_SANTE.NUM_DOSSIER,
						 SINISTRE_SANTE.NUMLIGNE,
						 SINISTRE_SANTE.CREATION,
						 SINISTRE_SANTE.NUMUTIL
				FROM SINISTRE_SANTE;
	R_SS C_SS%ROWTYPE;
--
BEGIN
	OPEN C_SS;
	LOOP
		FETCH C_SS INTO R_SS;
		EXIT WHEN C_SS%NOTFOUND;
		/* Insertion sur tous les lignes sans exception */
		BEGIN
			INSERT INTO HISTO_SINISTRE_SANTE
							( HISTO_SNTR_SANTE,
							num_dossier,
							numligne,
							etat,
						  	motif,
						  	datetat,
						  	numutil)
			 VALUES ( HISTO_SNTR_SANTE.nextval,
					 		R_SS.NUM_DOSSIER,
							R_SS.NUMLIGNE,
							1,
							0,
							R_SS.CREATION,
							R_SS.numutil);
		EXCEPTION
			WHEN OTHERS THEN NULL;
		END;
		/* Fin de l'insertion */
		OPEN C_DECOMPTEE (R_SS.NUM_DOSSIER, R_SS.NUMLIGNE);
		FETCH C_DECOMPTEE INTO R_DECOMPTEE;
		IF C_DECOMPTEE%FOUND
			THEN
			/* CAS d'une ligne décomptée */
				BEGIN
					INSERT INTO HISTO_SINISTRE_SANTE
									( HISTO_SNTR_SANTE,
									num_dossier,
									numligne,
									etat,
								  	motif,
								  	datetat,
								  	numutil)
					 VALUES ( HISTO_SNTR_SANTE.nextval,
							 		R_SS.NUM_DOSSIER,
									R_SS.NUMLIGNE,
									2,
									0,
									R_DECOMPTEE.DATPAY,
									R_SS.numutil);
				EXCEPTION
					WHEN OTHERS THEN NULL;
				END;
		ELSE
			/* CAS d'une ligne non décomptée */
				BEGIN
					INSERT INTO HISTO_SINISTRE_SANTE
									( HISTO_SNTR_SANTE,
									num_dossier,
									numligne,
									etat,
								  	motif,
								  	datetat,
								  	numutil)
					 VALUES ( HISTO_SNTR_SANTE.nextval,
							 		R_SS.NUM_DOSSIER,
									R_SS.NUMLIGNE,
									2,
									0,
									R_SS.CREATION,
									R_SS.numutil);
				EXCEPTION
					WHEN OTHERS THEN NULL;
				END;
		END IF;
		--
		CLOSE C_DECOMPTEE;
	END LOOP;
	CLOSE C_SS;
END;
/
