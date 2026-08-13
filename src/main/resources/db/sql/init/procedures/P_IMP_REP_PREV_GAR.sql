CREATE PROCEDURE ARTHUS.P_IMP_REP_PREV_GAR(I_numprod IN produit.numprod%TYPE
                           , I_numfor_ref IN garanties.numfor%TYPE
                           , I_numgarChaine IN VARCHAR2
                           , I_debut IN  DATE DEFAULT NULL)
  IS

  i                     NUMBER:=0;
  nb                   NUMBER:=0;
  v_chaine varchar2(50);
BEGIN

  dbms_output.put_line('P_IMP_REP_PREV_GAR');


 nb:= ( (LENGTH(I_numgarChaine) - LENGTH(REPLACE(I_numgarChaine,',',NULL)) ) / NVL(LENGTH(','),1) ) ;

   LOOP
     exit when i>nb;
     i:=i+1;
     v_chaine:= PK_FICHIER.F_SPLIT(I_numgarChaine,i,',');
     P_REP_PREV_GAR(I_numfor_ref, I_numprod, v_chaine,NULL) ;
     dbms_output.put_line('v_chaine:'||v_chaine);

  END LOOP;

  dbms_output.put_line('P_IMP_REP_PREV_GAR OK');

EXCEPTION
  WHEN OTHERS THEN
      dbms_output.put_line('P_IMP_REP_PREV_GAR KO');
END P_IMP_REP_PREV_GAR;
/
