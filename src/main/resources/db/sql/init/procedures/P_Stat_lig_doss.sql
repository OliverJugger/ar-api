CREATE PROCEDURE ARTHUS.P_Stat_lig_doss (I_Num_Dossier IN SINISTRE_SANTE.NUM_DOSSIER%TYPE,
							I_Nunligne   IN SINISTRE_SANTE.NUMLIGNE%TYPE DEFAULT 1,
							O_Stat_Lig   OUT VARCHAR2)
        IS
--
 CURSOR C_STATUS IS
	SELECT ALL *
		FROM V_STATUTS_LIG_DOSS
		WHERE (V_STATUTS_LIG_DOSS.NUM_DOSSIER = I_Num_Dossier
	 		AND V_STATUTS_LIG_DOSS.NUMLIGNE = I_Nunligne);
	 	-- ORDER BY STDATE DESC;	Le numéro d'ordre définit le dernier statut de la ligne
	 R_STATUS C_STATUS%ROWTYPE;
	 FLAG_ENTETE NUMBER(1) :=0;
--
BEGIN
	O_Stat_Lig := '? ';
	OPEN C_STATUS;
	LOOP
		FETCH C_STATUS INTO R_STATUS;
		EXIT WHEN C_STATUS%NOTFOUND;
		/* Traitement de substitution des entêtes (LIQUIDATION, CFE, ASSUREUR COMPLEMENTAIRE, BANQUE) */
		/* Flag entete = 1 -> Entete substitué                                                                                                                             */
		IF R_STATUS.ORDRE IN (100, 200, 300, 400)	 THEN
			FLAG_ENTETE := 1;
			IF R_STATUS.ORDRE = 100		THEN
				O_Stat_Lig := LTRIM(R_STATUS.LIB, ' ')||' : ';
			ELSE
				O_Stat_Lig := O_Stat_Lig ||' - '||LTRIM(R_STATUS.LIB, ' ')||' : ';
			END IF;
--
		ELSE
		/* Récupération du premier Statut retrouvé, Passer ensuite à la substitution de l'entête suivante */
			IF FLAG_ENTETE = 1 		THEN
				FLAG_ENTETE := 0;
				O_Stat_Lig := O_Stat_Lig ||R_STATUS.LIB;
				IF R_STATUS.STDATE IS NOT NULL		THEN
					O_Stat_Lig := O_Stat_Lig ||' le '|| TO_CHAR(R_STATUS.STDATE, 'DD/MM/YYYY');
				END IF;
			END IF;
		END IF;
	END LOOP;
END;
/
