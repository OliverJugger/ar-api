CREATE PROCEDURE ARTHUS.P_Val_ZReg IS

/* Curseur principal (Tous les enregesitriments à valoriser ) */
CURSOR C_CPTA IS
	SELECT * FROM COMPTA WHERE ZREG_VAL IS NULL FOR UPDATE;

	R_CPTA C_CPTA%ROWTYPE;


BEGIN
  OPEN C_CPTA;
  LOOP
  	FETCH C_CPTA INTO R_CPTA;
  	EXIT WHEN C_CPTA%NOTFOUND;
 		UPDATE COMPTA
  			 SET COMPTA.ZREG_VAL =
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(
						Replace(COMPTA.ZREG ,'#REG01',  R_CPTA.JOURNAL)
									 ,'#REG02', R_CPTA.COMPTE)
									 ,'#REG03', R_CPTA.SENS)
									 ,'#REG04', 'MONNAIE_D')
									 ,'#REG05', 'MONTANT_D')
									 ,'#REG06', R_CPTA.MONTANT)
									 ,'#REG07', R_CPTA.LIBELLE)
									 ,'#REG08', R_CPTA.DAT_PIECE)
									 ,'#REG09', R_CPTA.REFPIECE)
									 ,'#REG10', R_CPTA.DAT_PIECE)
									 ,'#REG11', R_CPTA.NATURE)
									 ,'#REG12', R_CPTA.AXANA1)
									 ,'#REG13', R_CPTA.AXANA2)
									 ,'#REG14', R_CPTA.AXANA3)
									 ,'#REG15', R_CPTA.AXANA4)
									 ,'#REG16', R_CPTA.AXANA5)
									 ,'#REG17', R_CPTA.ZONEX1)
									 ,'#REG18', R_CPTA.ZONEX2)
									 ,'#REG19', R_CPTA.ZONEX3)
									 ,'#REG20', R_CPTA.ZONEX4)
								 	 ,'#REG21', R_CPTA.ZONEX5)
									 ,'#REG22', 'ZONEX6')
									 ,'#REG23', 'ZONEX7')
								 	 ,'#REG24', 'ZONEX8')
									 ,'#REG25', 'ZONEX9')
									 ,'#REG26', 'ZONEX10')
									 ,'#REG27', 'ZONEX11')
									 ,'#REG28', 'ZONEX12')
									 ,'#REG29', 'ZONEX13')
									 ,'#REG30', R_CPTA.ZSERV1)
									 ,'#REG31', R_CPTA.ZSERV2)
									 ,'#REG32', R_CPTA.ZSERV3)
									 ,'#REG33', R_CPTA.ZSERV4)
									 ,'#REG34', R_CPTA.ZSERV5)
					WHERE CURRENT OF C_CPTA;
  END LOOP;
  CLOSE C_CPTA;
  COMMIT;
  EXCEPTION
  	WHEN OTHERS THEN NULL;
END;
/
