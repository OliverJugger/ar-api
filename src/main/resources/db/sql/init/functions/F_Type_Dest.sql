CREATE FUNCTION ARTHUS.F_Type_Dest (I_Origine IN Number,
                   I_Numero	  IN Number,
                   I_Code_Crrr  IN Number,
                   I_Idtexte	  IN Number)
    RETURN NUMBER
IS
--
 CURSOR C_Cntrt IS
	SELECT ALL VALIDE_TEXTE.TYPE_DEST
	  FROM CONTRAT_REF, PARAM_TEXTE, VALIDE_TEXTE
       WHERE (CONTRAT_REF.NUMGAR = I_Numero
         AND PARAM_TEXTE.CODE = I_Code_Crrr
         AND PARAM_TEXTE.IDTEXTE = I_Idtexte)
         AND ((PARAM_TEXTE.IDTEXTE = VALIDE_TEXTE.IDTEXTE)
         AND (CONTRAT_REF.NUMGAR = VALIDE_TEXTE.NUMERO));
--
 CURSOR C_Prd IS
	SELECT ALL VALIDE_TEXTE.TYPE_DEST
	  FROM PRODUIT, PARAM_TEXTE, VALIDE_TEXTE
	 WHERE (PRODUIT.NUMPROD = I_Numero
 	   AND PARAM_TEXTE.CODE = I_Code_Crrr
         AND PARAM_TEXTE.IDTEXTE = I_Idtexte)
         AND ((PARAM_TEXTE.IDTEXTE = VALIDE_TEXTE.IDTEXTE)
         AND (PRODUIT.NUMPROD = VALIDE_TEXTE.NUMERO));
--
 R_CNT C_Cntrt%ROWTYPE;
 R_PRD C_Prd%ROWTYPE;
 O_Type_Dest number(3) := 0;
--
BEGIN
	BEGIN
	/* Cas d'un Contrat */
	IF I_Origine = 1
	   THEN
	    OPEN C_Cntrt;
	    LOOP
	      FETCH C_Cntrt INTO R_CNT;
		EXIT WHEN C_Cntrt%NOTFOUND OR O_Type_Dest > 0;
            O_Type_Dest := R_CNT.TYPE_DEST;
          END LOOP;
	    CLOSE C_Cntrt;
	END IF;
	/* Cas d'un produit */
	IF I_Origine = 2
    	  THEN
	    OPEN C_Prd;
          LOOP
		FETCH C_Prd INTO R_PRD;
  	      EXIT WHEN C_Prd%NOTFOUND OR O_Type_Dest > 0;
            O_Type_Dest := R_PRD.TYPE_DEST;
          END LOOP;
	    CLOSE C_Prd;
	END IF;
	/* Autres Cas */
	IF I_Origine NOT IN (1, 2)
		THEN
		O_Type_Dest := 777;
	END IF;
	/* Cas d'un Curseur invalide */
	EXCEPTION
		WHEN OTHERS THEN O_Type_Dest := 999;
	END;

	--
	RETURN(O_Type_Dest);
END;
