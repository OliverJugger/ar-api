CREATE function ARTHUS.F_Taux_Tarif(
			a_Numorg	IN NUMBER,
			a_Typtar	IN NUMBER,
			a_Codfrais	IN VARCHAR2,
			a_date		IN DATE DEFAULT SYSDATE)
	RETURN NUMBER
	AS
		CURSOR C1 IS
			SELECT TARIF.TAUX
				FROM TARIF
					WHERE (TARIF.NUMORG = a_Numorg
						AND TARIF.TYPTAR = a_Typtar
						AND TARIF.CODFRAIS = a_Codfrais
						AND (TARIF.DATAPLI) <= a_date
						AND NVL(TARIF.DATPER, a_date) >= a_date) ;
		R1 	C1%ROWTYPE;
		Loc_Taux	NUMBER default 0;
BEGIN
	OPEN C1;
	FETCH C1 INTO R1;
	IF C1%FOUND THEN
		LOC_Taux := R1.TAUX;
	ELSE
		LOC_Taux := 0;
	END IF;
	CLOSE C1;
	RETURN (LOC_Taux);
EXCEPTION
		WHEN OTHERS THEN LOC_Taux := 0;
		RETURN (LOC_Taux);
END;
