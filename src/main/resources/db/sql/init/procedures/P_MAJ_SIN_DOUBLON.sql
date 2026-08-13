CREATE PROCEDURE ARTHUS.P_MAJ_SIN_DOUBLON
IS
loc_numutil   NUMBER;
next_numsin   NUMBER(9);

CURSOR c_doublon
IS
  SELECT numsin FROM SIN_DOUBLON ORDER BY numsin;

rec_c_doublon    SIN_DOUBLON%ROWTYPE;
loc_mt_reel     NUMBER(11,2);
BEGIN

  loc_numutil := f_numutil;


  OPEN c_doublon;
  
    LOOP
      FETCH c_doublon
        INTO rec_c_doublon;
    
        EXIT WHEN c_doublon%NOTFOUND;
      
        SELECT numsin.NEXTVAL
        INTO  next_numsin
        FROM DUAL;

        BEGIN
          Begin
          INSERT INTO SINISTRE 
                  (CODFRAIS, NUMGAR, NUMINDIV, DATSIN,
                  MTPREST, MTREMB, MTFRAIS, DATSAI,
                  NBACTE, AUTRB, MTFRAN, SENS, MTMAX,
                  MTREEL, NUMDEC, NUMASSU, NUMBENE,
                  NUMSIN, NUMANNUL, USERNAME, FLAGAM,
                  TYPBENE, NUMPOPU, NUMFOR, NUM_FACT,
                  NUMMATH, NUMPC, X, IDADHESION, PDSQLS,
                  SPE_EXE, FRA_DEP, RACMON, DATEDIT_RC,
                  EDTDCPT, MONNAIE, NUMASSU_RC, NUMDCPTCIE,
                  NUMDEC_RC, FLAG_REGIME)
          SELECT CODFRAIS, NUMGAR, NUMINDIV, DATSIN,
                  MTPREST*-1, MTREMB*-1, MTFRAIS*-1, trunc(sysdate),
                  NBACTE*-1, AUTRB*-1, MTFRAN*-1, SENS, MTMAX*-1,
                  MTREEL*-1, 0, NUMASSU, NUMBENE,
                  next_numsin, numsin, loc_numutil, 'a',
                  TYPBENE, NUMPOPU, NUMFOR, NUM_FACT,
                  NUMMATH, NUMPC, X, IDADHESION, PDSQLS,
                  SPE_EXE, FRA_DEP, RACMON, DATEDIT_RC,
                  EDTDCPT, MONNAIE, NUMASSU_RC, 0,
                  NUMDEC_RC, FLAG_REGIME
              FROM SINISTRE WHERE numsin = rec_c_doublon.numsin;
          Exception When No_data_found then null;
                    WHEN Others THEN DBMS_OUTPUT.PUT_LINE( 'Numsin :'||rec_c_doublon.numsin||' Erreur = '||SUBSTR(SQLERRM(SQLCODE),1,128)  );
          END;
  
          -- On ne fait plus la demande de remboursement si MT_REEL <= 75 euros
          BEGIN
            SELECT SUM(MTREEL)
              INTO loc_mt_reel
                FROM SINISTRE WHERE NUMASSU = (SELECT NUMASSU FROM SINISTRE WHERE NUMSIN = rec_c_doublon.numsin) AND numsin IN (SELECT numsin FROM SIN_DOUBLON) ;
          
            IF loc_mt_reel > 75 THEN
              Begin
                INSERT INTO sntr_remb
                       (numsin, numannul, creation, numutil)
                SELECT next_numsin,
                       rec_c_doublon.numsin,
                       sysdate,
                       loc_numutil
                FROM   DUAL;
              Exception When No_data_found then null;
                        WHEN Others THEN DBMS_OUTPUT.PUT_LINE( 'Numsin :'||rec_c_doublon.numsin||' Erreur = '||SUBSTR(SQLERRM(SQLCODE),1,128)  );
              END;
            END IF;
          
          Exception When No_data_found then null;
          END;

          Begin
          insert into sinistre_dev (NUMSIN,DEV_CT,DEV_IN,DEV_OUT,MTFRAIS_CT,MTFRAIS_IN,
																					MTFRAIS_OUT,MTPREST_CT,MTPREST_IN,MTPREST_OUT,MTREMB_CT,
																					MTREMB_IN,MTREMB_OUT,MTREEL_CT,MTREEL_IN,MTREEL_OUT,
																					AUTRB_CT,AUTRB_IN,AUTRB_OUT,NUMDEC,NUMINDIV) 
  				   		       select next_numsin,
  				   		       				DEV_CT,
  				   		       				DEV_IN,
  				   		       				DEV_OUT,
  				   		       				MTFRAIS_CT*-1,
  				   		       				MTFRAIS_IN*-1,
															MTFRAIS_OUT*-1,
															MTPREST_CT*-1,
															MTPREST_IN*-1,
															MTPREST_OUT*-1,
															MTREMB_CT*-1,
															MTREMB_IN*-1,
															MTREMB_OUT*-1,
															MTREEL_CT*-1,
															MTREEL_IN*-1,
															MTREEL_OUT*-1,
															AUTRB_CT*-1,
															AUTRB_IN*-1,
															AUTRB_OUT*-1,
															0,
															NUMINDIV
											 from sinistre_dev   
											 where numsin = rec_c_doublon.numsin;
          Exception When No_data_found then null;
                    WHEN Others THEN DBMS_OUTPUT.PUT_LINE( 'Numsin :'||rec_c_doublon.numsin||' Erreur = '||SUBSTR(SQLERRM(SQLCODE),1,128)  );
          END;

          Begin
          Insert into sntr_ref
                    (numsin, ref, numremise, numsin_porte)
             Select next_numsin, ref, numremise, numsin_porte
             from   sntr_ref
             where  numsin = rec_c_doublon.numsin;
          Exception When No_data_found then null;
                    WHEN Others THEN DBMS_OUTPUT.PUT_LINE( 'Numsin :'||rec_c_doublon.numsin||' Erreur = '||SUBSTR(SQLERRM(SQLCODE),1,128)  );
          END;

          EXCEPTION WHEN Others THEN 
            DBMS_OUTPUT.PUT_LINE( 'Numsin :'||rec_c_doublon.numsin||' Erreur = '||SUBSTR(SQLERRM(SQLCODE),1,128)  );
            
        END;
        
    END LOOP;

  CLOSE c_doublon;
  
  --
  COMMIT;
   
  EXCEPTION WHEN Others THEN 
    DBMS_OUTPUT.PUT_LINE( 'Erreur = '||SUBSTR(SQLERRM(SQLCODE),1,128)  );
END;
/
