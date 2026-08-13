CREATE PROCEDURE ARTHUS.P_Nb_Numgar
	(I_Type_Contrat		IN Number,
         I_Nature_Contrat	IN Number,
         I_NumIndiv		IN Number,
         I_DatEff		IN Date default Sysdate,
         O_Numgar 	OUT Number,
         O_Many_Rows 	OUT Number)
IS
  CURSOR C_Cntrt IS
    SELECT ALL GAR_CNTRT.NUMGAR_REF
      FROM ADHESION, GAR_CNTRT
     WHERE (I_DatEff BETWEEN ADHESION.DATAPLI
             AND NVL(ADHESION.DATPER, SYSDATE))
       AND GAR_CNTRT.TYPE = I_Type_Contrat
       AND ADHESION.NUMINDIV = I_NumIndiv
       AND GAR_CNTRT.NUMGAR = ADHESION.NUMGAR
  GROUP BY GAR_CNTRT.NUMGAR_REF
  ORDER BY GAR_CNTRT.NUMGAR_REF DESC ;

R_Cntrt C_Cntrt%ROWTYPE;
--
 CURSOR C_Adhe IS
	SELECT ALL GAR_CNTRT.NUMGAR_REF
	  FROM ADHESION, GAR_CNTRT
         WHERE (I_DatEff BETWEEN ADHESION.DATAPLI AND NVL(ADHESION.DATPER, SYSDATE))
           AND GAR_CNTRT.TYPE = I_Type_Contrat
 	   AND ADHESION.NUMINDIV = I_NumIndiv
 	   AND (GAR_CNTRT.NUMGAR = ADHESION.NUMGAR)
       GROUP BY GAR_CNTRT.NUMGAR_REF
    	 ORDER BY GAR_CNTRT.NUMGAR_REF DESC;

	R_Adhe C_Adhe%ROWTYPE;
--
 CURSOR C_Adhe_Coll IS
    	SELECT ALL ADHE_COLLECTIVE.NUMGAR_REF
      	  FROM ADHE_COLLECTIVE, GAR_CNTRT
	 WHERE (I_DatEff BETWEEN GAR_CNTRT.DATAPLI AND NVL(GAR_CNTRT.DATPER, SYSDATE))
 	   AND GAR_CNTRT.TYPE = I_Type_Contrat
 	   AND ADHE_COLLECTIVE.NUMCLI = I_NumIndiv
           AND (GAR_CNTRT.NUMGAR = ADHE_COLLECTIVE.NUMGAR_REF)
       GROUP BY ADHE_COLLECTIVE.NUMGAR_REF
    	 ORDER BY ADHE_COLLECTIVE.NUMGAR_REF DESC;

  	R_Adhe_Coll C_Adhe_Coll%ROWTYPE;
--
BEGIN
  O_Many_Rows := 0;
/* Cas d'un Contrat */
  IF I_Nature_Contrat = 1
     THEN
	OPEN C_Cntrt;
	LOOP
	  FETCH C_Cntrt INTO R_Cntrt;
 	  EXIT WHEN C_Cntrt%NOTFOUND;
	  O_Numgar    := R_Cntrt.Numgar_ref;
	  O_Many_Rows := O_Many_Rows + 1;
	END LOOP;
	CLOSE C_Cntrt;
  END IF;
/* Cas d'une Adhesion */
  IF I_Nature_Contrat = 2
     THEN
	OPEN C_Adhe;
	LOOP
	  FETCH C_Adhe INTO R_Adhe;
	  EXIT WHEN C_Adhe%NOTFOUND;
	  O_Numgar    := R_Adhe.Numgar_ref;
	  O_Many_Rows := O_Many_Rows + 1;
	END LOOP;
	CLOSE C_Adhe;
  END IF;
/* Cas d'une Adhesion Collective */
  IF I_Nature_Contrat = 3
     THEN
	OPEN C_Adhe_Coll;
	LOOP
	  FETCH C_Adhe_Coll INTO R_Adhe_Coll;
	  EXIT WHEN C_Adhe_Coll%NOTFOUND;
	  O_Numgar    := R_Adhe_Coll.Numgar_ref;
	  O_Many_Rows := O_Many_Rows + 1;
	END LOOP;
	CLOSE C_Adhe_Coll;
  END IF;
/* Autres cas */
  IF I_Nature_Contrat NOT IN (1, 2, 3)
     THEN
     O_Many_Rows := 0;
     O_Numgar := 0;
  END IF;
	--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
		O_Many_Rows := 0;
		O_Numgar := 0;
  WHEN OTHERS THEN
		O_Many_Rows := 0;
		O_Numgar := 0;
END;
/
