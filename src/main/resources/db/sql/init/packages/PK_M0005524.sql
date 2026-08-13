CREATE OR REPLACE package ARTHUS.PK_M0005524 as

    FUNCTION GET_FIRST_NOT_CHILD( i_beneficiaires  IN EXTR_TAB_BENEFICIAIRE, i_numassu NUMBER, i_numindiv NUMBER ) RETURN NUMBER ;
	
	FUNCTION IS_RIB_DIFFERENT (i_id_rib IN rib.idrib%type, i_BIC IN RIB.BIC%TYPE, i_BBAN IN rib.bban%type, i_clerib  IN RIB.CLERIB%TYPE) RETURN NUMBER;
	
	PROCEDURE SET_RAPPEL_ERREUR( i_idrappel IN RAPPEL.idrappel%TYPE,i_code_err  IN RAPPEL.code_err%TYPE, i_etat IN RAPPEL.etat%TYPE );  
	
	FUNCTION IS_RIB_AFTER_CURRENT (i_id_rib IN rib.idrib%type, i_dateeffet IN DATE) RETURN NUMBER;
	

END PK_M0005524 ;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_M0005524 as

  FUNCTION GET_FIRST_NOT_CHILD( i_beneficiaires  IN EXTR_TAB_BENEFICIAIRE, i_numassu NUMBER, i_numindiv NUMBER) 
  RETURN NUMBER  IS
  i NUMBER :=1;
  l_numindiv NUMBER;
 
  CURSOR c_parents IS 
  SELECT NUMINDIV FROM ADHE_CNTRT_MEMBRE
  WHERE NUMINDIV IN (SELECT numindiv FROM TABLE (i_beneficiaires))
  AND TYPADR NOT IN (0,2)-- on ne prend pas l'assuré pincipale ni les enfants
  AND IDADHESION IN(  
    SELECT MIN(a1.IDADHESION) 
    FROM adhe_cntrt a1 ,ADHE_CNTRT_MEMBRE a2 
    WHERE a1.idadhesion = a2.idadhesion
    AND a1.numadhe = i_numassu 
    AND (sysdate between a1.date_adhe and nvl (a1.date_fin_adhe, sysdate) OR a1.date_adhe > SYSDATE) 
    AND a2.NUMINDIV = i_numassu 
    AND a2.TYPADR =0
    )--  adhésion pour laqquelle l'assuré est l'assuré principale 
    ORDER BY TYPADR ASC
  ;
  rec_parent c_parents%ROWTYPE;
 
  BEGIN
    IF i_numassu = i_numindiv THEN   -- l'assuré est automatiquement le porteur du rib si numindiv = numassu. 
      RETURN i_numassu;
    ELSIF i_numindiv=0 THEN l_numindiv:=NULL;
    END IF;
    
    OPEN c_parents;
    FETCH C_parents INTO Rec_parent;
    
    IF C_parents%NOTFOUND THEN
      CLOSE c_parents;
      RETURN nvl(l_numindiv,i_beneficiaires(1).numindiv);      -- si le numero d'individu est null on prend le premier de la liste pour qu'il soit le proteur du rib
    ELSE 
      CLOSE c_parents;
      RETURN Rec_parent.numindiv;
    END IF;
    RETURN nvl(l_numindiv,i_beneficiaires(1).numindiv);  -- si il n'y a que des enfants on retourne null, un nvl doit e^tre fait au retour de la fonction pour prendre le numindiv par defaut

  EXCEPTION
    WHEN OTHERS THEN RETURN nvl(l_numindiv,i_beneficiaires(1).numindiv);
  END GET_FIRST_NOT_CHILD;    
  
  
   FUNCTION IS_RIB_DIFFERENT (i_id_rib IN rib.idrib%type, 
                            i_BIC IN RIB.BIC%TYPE, 
                            i_BBAN IN rib.bban%type, 
                            i_clerib  IN rib.CLERIB%TYPE) 
 RETURN NUMBER
 IS 
  loc_code_erreur rappel.code_err%type;
  BEGIN   
    SELECT distinct 2197
      INTO  loc_code_erreur                    
      FROM  RIB r
      WHERE r.IDRIB = i_id_rib
        AND nvl(r.bban,1) = nvl(i_bban,1)
        AND nvl(r.clerib,1) = nvl(i_clerib,1)
        AND nvl(r.bic,1) = nvl(i_bic,1)  ;
    return loc_code_erreur; 
    
  EXCEPTION
      WHEN OTHERS THEN  -- si on a rien trouvé on continu
            return 0;
 END IS_RIB_DIFFERENT;  
 
 
 PROCEDURE SET_RAPPEL_ERREUR( i_idrappel IN RAPPEL.idrappel%TYPE, i_code_err  IN RAPPEL.code_err%TYPE, i_etat IN RAPPEL.etat%TYPE)
IS 
BEGIN
UPDATE RAPPEL 
  SET ETAT = i_etat,
  CODE_ERR = i_code_err 
  WHERE idrappel = i_idrappel;

END SET_RAPPEL_ERREUR;

 FUNCTION IS_RIB_AFTER_CURRENT (i_id_rib IN rib.idrib%type, i_dateeffet IN  DATE ) RETURN NUMBER
 IS 
 loc_code_erreur rappel.code_err%type;
 BEGIN  
    SELECT distinct 2196 
      INTO  loc_code_erreur                    
      FROM  RIB r
      WHERE r.IDRIB = i_id_rib
        AND r.debut >= i_dateEffet;
   return loc_code_erreur;
  EXCEPTION
      WHEN OTHERS THEN  -- si on a rien trouvé on continu
            return 0;
 END IS_RIB_AFTER_CURRENT;



END PK_M0005524;
/
