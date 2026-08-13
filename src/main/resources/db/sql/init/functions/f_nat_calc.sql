CREATE function ARTHUS.f_nat_calc (A_Numgar IN NUMBER)
		RETURN NUMBER
	AS
--
	Loc_Nat_Calc NUMBER;
--
-- Recherche des NAT_CALC des garanties SANTE et Prévoyance
--
	CURSOR C_Sante (Loc_Numfor NUMBER) is
		SELECT ALL 	FORMULE.NUMFOR,
						FORMULE.NAT_CALC
		FROM FORMULE
	  WHERE NUMFOR = Loc_Numfor;
--
	CURSOR C_Prev (Loc_Numfor NUMBER) is
		SELECT ALL 	GARANTIES.NUMFOR,
						GARANTIES.NAT_CALC
		FROM GARANTIES
	  WHERE NUMFOR = Loc_Numfor;
--
--  Curseur de Recherche des NAT_CALC
--
	CURSOR C_Gar IS
		SELECT NUMFOR FROM GAR_CNTRT_REF
		WHERE NUMGAR = PK_QTTC.F_Sel_Numgar (A_Numgar)
		   OR NUMGAR = A_Numgar;
--
	R_Sante C_Sante%ROWTYPE;
	R_Prev C_Prev%ROWTYPE;
    R_Gar C_GAR%ROWTYPE;
--
BEGIN
	Loc_Nat_Calc := 0;
	OPEN C_GAR;
	LOOP
		FETCH C_GAR INTO R_Gar;
		EXIT WHEN C_GAR%NOTFOUND OR Loc_Nat_Calc IN (3, 9);
		OPEN C_Sante (R_Gar.NUMFOR);
		FETCH C_Sante INTO R_Sante;
		-- Garantie Contrat Sante
		IF C_Sante%FOUND THEN
			 -- Premier passage
			IF Loc_Nat_Calc = 0 THEN
				 Loc_Nat_Calc := R_Sante.Nat_Calc;
			END IF;
			 -- Autres passages
			IF Loc_Nat_Calc != R_Sante.Nat_Calc THEN
				Loc_Nat_Calc := 3;
			END IF;
		END IF;
		-- Garantie Contrat Prévoyance
		IF C_Sante%NOTFOUND	THEN
			OPEN C_Prev (R_Gar.NUMFOR);
			FETCH C_Prev INTO R_PREV;
			-- Garantie non trouvé
			IF C_Prev%NOTFOUND THEN
				Loc_Nat_Calc := 9;
			END IF;
			--
			IF C_Prev%FOUND THEN
				-- Premier passage
				IF Loc_Nat_Calc = 0 THEN
					Loc_Nat_Calc := R_Prev.Nat_Calc;
				END IF;
			 -- Autres passages
				IF Loc_Nat_Calc != R_Prev.Nat_Calc THEN
					Loc_Nat_Calc := 3;
				END IF;
			END IF;
			CLOSE C_Prev;
		END IF;
		CLOSE C_Sante;
	END LOOP;
	CLOSE C_GAR;
	RETURN ( Loc_Nat_Calc );
	EXCEPTION
		WHEN OTHERS THEN RETURN ( 9 );
END;
