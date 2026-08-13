CREATE FUNCTION ARTHUS.F_QTTC_IMPAYE (I_numindiv IN INDIVIDU.NUMINDIV%TYPE,I_idadhesion IN adhe_cntrt.idadhesion%TYPE,I_type NUMBER)
RETURN NUMBER
AS
/*=========================================================================
Fonction     : F_QTTC_IMPAYE
Domaine      : Cotisaton
Version      : V1.0
Auteur       : ABO
Création     : 16/05/2018
Description  : fonction permettant de donner la plus ancienne cotisations 
            impayées
==========================================================================
Evolution    : 
Auteur       :
Date         :
Commentaire  :
==========================================================================
Correction   :
==========================================================================*/
  CURSOR C_Impaye  (P_idadhesion NUMBER , P_numindiv NUMBER)IS
  SELECT 
        qttc_global.numquit,
         qttc_global.debut         
  FROM facture,
       qttc_global,
       adhe_cntrt,
      compte_client cc
  WHERE  qttc_global.mt_ttc        IS NOT NULL
    AND  qttc_global.idadhesion    =  adhe_cntrt.idadhesion
    AND  adhe_cntrt.idadhesion = NVL(P_idadhesion,adhe_cntrt.idadhesion )
    AND  adhe_cntrt.numadhe = NVL(P_numindiv,adhe_cntrt.numadhe )
    AND  NOT EXISTS (SELECT 1 FROM facture_annul WHERE facture_annul.numfact = qttc_global.numquit) -- exclure les annulés
    AND  qttc_global.comptant      != 'R' -- exclure les résiliés
    AND  type_qttc                 != 3  -- exclure les précalculés 
    AND  qttc_global.numquit       =  facture.numfact
    AND  facture.codope            =  4
    AND	cc.codope		= facture.codope
	  AND	cc.numfact		= facture.numfact
	  AND	datope		<= sysdate
    --AND  (NVL(facture.montant_d,0) - NVL(f_totaffec_d(qttc_global.numquit,4,SYSDATE),0)) >  0
   GROUP BY  qttc_global.numquit,
         qttc_global.debut,facture.montant_d
  HAVING  NVL(facture.montant_d,0) -  sum(cc.montant_d)>0
  ORDER BY qttc_global.debut ;
  
  loc_ref VARCHAR2(50);
  loc_nb NUMBER :=0;

BEGIN
  

  IF I_type = 1 AND (I_idadhesion IS NOT NULL OR I_numindiv IS NOT NULL) THEN
    --l'assuré est-il concerné par une cotisation individuelle ?
    SELECT count(numquit) INTO loc_nb
    FROM qttc_global 
    WHERE numindiv <>0
    AND idadhesion = NVL(I_idadhesion,idadhesion)
    AND numquerable = NVL(I_numindiv,numquerable);
    
  ELSIF I_type =2 AND I_numindiv IS NOT NULL THEN
   --la société est-elle concernée par une cotisation collective ?
    SELECT count(numquit) INTO loc_nb
    FROM qttc_global    
    WHERE numquerable = I_numindiv;
  END IF;
  
  IF loc_nb <>0 THEN
    --on ne prend que la 1ère ligne remontée
    FOR R_Impaye IN C_Impaye(I_idadhesion,I_numindiv) LOOP
      --loc_ref:= R_Impaye.mode_paie ||' '|| to_char(R_Impaye.DEBUT_QUIT,'dd/mm/yyyy');
      loc_ref:=R_Impaye.numquit;
      EXIT;
    END LOOP;
    
  ELSE loc_ref := 0; --n'a jamais eu de cotisations
  END IF;
  
  RETURN loc_ref;

EXCEPTION 
  WHEN OTHERS THEN
    RETURN NULL;
END F_QTTC_IMPAYE;
