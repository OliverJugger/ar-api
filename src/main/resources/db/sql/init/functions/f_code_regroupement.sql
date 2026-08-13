CREATE Function ARTHUS.f_code_regroupement(
						A_Clef1		IN NUMBER,
						A_Clef2		IN NUMBER,
						A_Niveau 	IN NUMBER 	DEFAULT 1,
						A_Type 		IN NUMBER 	DEFAULT 1,
						A_Date		IN DATE 	DEFAULT SYSDATE )
	RETURN VARCHAR2
	AS
	CURSOR C_INTERMED
			(CUR_ETENDUE NUMBER, CUR_CLEF NUMBER, CUR_TYPE_APPORT NUMBER, CUR_DEBUT DATE)
			IS
		SELECT APPORTEUR.REF_EXTERNE
			FROM APPORTEUR
			WHERE APPORTEUR.ETENDUE = CUR_ETENDUE
			  AND APPORTEUR.CLE     = CUR_CLEF
			  AND APPORTEUR.TYPE_APPORT = CUR_TYPE_APPORT
			  AND APPORTEUR.DEBUT   <= CUR_DEBUT;
		R_INTERMED	C_INTERMED%ROWTYPE;

		LOC_Retour 			VARCHAR2 (45)  DEFAULT NULL;
		Var_Refcie_Chapeau	VARCHAR2 (45)  DEFAULT NULL;
		Var_Numindiv_Apporteur	NUMBER (9) default 0;
		Var_Typgar	 		NUMBER (2) default 0;
		Var_TypeNumgar      NUMBER (2) default 2;

BEGIN
	LOC_Retour := NULL;
	-- Recherche S/typgar (2=Adhésion individuelle (IDADHESION), 3=Adhésion collective (Numgar_Ref), 1= Contrat)
	-- Recherche par la même lecture de la référence. Elle est chargé en cas niveau 1, en cas de contrat et dans le cas d'intermédiation inexistante
	--

	BEGIN

		select 2
		into   Var_TypeNumgar
		from   contrat_ref
		where  numgar= A_Clef1;

	EXCEPTION WHEN NO_DATA_FOUND THEN Var_TypeNumgar := 24;
	END;

	IF A_Niveau = 1	THEN

		BEGIN
				OPEN C_INTERMED (2, A_Clef1, A_Type, A_Date);
				FETCH C_INTERMED INTO R_INTERMED;

				LOC_Retour := R_INTERMED.REF_EXTERNE;

				IF 	C_INTERMED%NOTFOUND THEN
					BEGIN
						SELECT CONTRAT.TYPGAR, CONTRAT.REFCIE_CHAPEAU
						INTO   Var_Typgar, Var_Refcie_Chapeau
						FROM CONTRAT
						WHERE CONTRAT.NUMGAR = A_Clef1;


						IF 	Var_Refcie_Chapeau IS NULL THEN
						    LOC_Retour := 'N1_T'||A_Type||'_E'|| Var_TypeNumgar||'_'||A_Clef1||'_1';
						ELSE
						    LOC_Retour := Var_Refcie_Chapeau;
						END IF;

					EXCEPTION
						WHEN OTHERS THEN LOC_Retour := 'N1_T'||A_Type||'_E'|| Var_TypeNumgar||'_'||A_Clef1||'_0';
					END;

				ELSE

						IF 	LOC_Retour IS NULL  THEN
								LOC_Retour := 'N1_T'||A_Type||'_EA'|| Var_TypeNumgar||'_'||A_Clef1||'_1';
						END IF;

				END IF;

				CLOSE C_INTERMED;

		EXCEPTION
				WHEN OTHERS THEN LOC_Retour := 'N1_T'||A_Type||'_EA'|| Var_TypeNumgar||'_'||A_Clef1||'_X0';
				CLOSE C_INTERMED;
		END;

	ELSE -- A_Niveau = 2

			BEGIN
				OPEN C_INTERMED (4, A_Clef2, A_Type, A_Date);
				FETCH C_INTERMED INTO R_INTERMED;

				LOC_Retour := R_INTERMED.REF_EXTERNE;

				IF 	C_INTERMED%NOTFOUND THEN
						BEGIN
							CLOSE C_INTERMED;

							OPEN C_INTERMED (2, A_Clef1, A_Type, A_Date);
							FETCH C_INTERMED INTO R_INTERMED;

							LOC_Retour := R_INTERMED.REF_EXTERNE;

							IF 	C_INTERMED%NOTFOUND THEN
								BEGIN
									SELECT CONTRAT.TYPGAR, CONTRAT.REFCIE_CHAPEAU
									INTO   Var_Typgar, Var_Refcie_Chapeau
									FROM CONTRAT
									WHERE CONTRAT.NUMGAR = A_Clef1;

									IF 	Var_Refcie_Chapeau IS NULL THEN
										LOC_Retour := 'N2_T'||A_Type||'_E'|| Var_TypeNumgar||'_'||A_Clef1||'_1';
									ELSE
										LOC_Retour := Var_Refcie_Chapeau;
									END IF;

								EXCEPTION
									WHEN OTHERS THEN LOC_Retour := 'N2_T'||A_Type||'_E'|| Var_TypeNumgar||'_'||A_Clef1||'_0';
								END;

							ELSE

								IF 	LOC_Retour IS NULL  THEN
									LOC_Retour := 'N2_T'||A_Type||'_EA'|| Var_TypeNumgar||'_'||A_Clef1||'_1';
								END IF;

							END IF;
							CLOSE C_INTERMED;

						EXCEPTION
							WHEN OTHERS THEN LOC_Retour := 'N2_T'||A_Type||'_EA'|| Var_TypeNumgar||'_'||A_Clef1||'_X0';
							CLOSE C_INTERMED;
						END;
				ELSE

					CLOSE C_INTERMED;

					IF 	LOC_Retour IS NULL  THEN
						LOC_Retour := 'N2_T'||A_Type||'_EA4_'||A_Clef2||'_1';
					END IF;

				END IF;



			EXCEPTION
					WHEN OTHERS THEN LOC_Retour := 'N2_T'||A_Type||'_EA4_'||A_Clef2||'_X0';
					CLOSE C_INTERMED;
			END;

	END IF;

	RETURN (LOC_Retour);

END f_code_regroupement;
