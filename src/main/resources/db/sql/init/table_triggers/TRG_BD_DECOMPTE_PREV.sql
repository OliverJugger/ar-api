CREATE TRIGGER ARTHUS.TRG_BD_DECOMPTE_PREV
BEFORE DELETE
ON DECOMPTE_PREV
FOR EACH ROW
DECLARE
  l_idpiece    NUMBER(9);
BEGIN

  -- Récupération du nextval de la séquence idpiece de affectation_annul
  SELECT IDPIECE.nextval INTO l_idpiece FROM dual;

  -- Insertion d'une ligne négative pour prise en compte lors d'une constitution de demande de remboursement
  -- NUMDCPTCIE = -1 si 0 pour ignorer dans la génération des bdx ces cas qui s'annulent.
  INSERT INTO dcpt_prev_annul (NUMDEC,IDADHESION,NUMDCPTCIE,DATANNUL,MONTANT,MONNAIE,MONNAIE_D,MONTANT_D,NUMUTIL,IDCOMPTA,DATPAY,NUMDCPTCIE_ANNUL,NUMUTIL_ANNUL,IDCOMPTA_ANNUL)
  VALUES (
  :old.numdec,
  :old.idadhesion,
  :old.numdcptcie,
  SYSDATE,
  :old.montant,
  :old.monnaie,
  :old.monnaie_d,
  :old.montant_d,
  :old.numutil,
  :old.idcompta,
  :old.datpay,
  DECODE(:old.numdcptcie,0,0,-1),
  F_NUMUTIL,
  0
  );


 	INSERT INTO pnul (NUMCPTE, NUMCHQ ,NUMDECAISMT,NUMAFFEC,MODPMT,DATPAY,DATANNUL,
 	MOTIF,USERID,REFPMT,CODOPE,NUMDCPTCIE,IDCOMPTA,REMB,NUMDCPTCIE_INIT,IDCOMPTA_INIT,NUMDCPTCIE_SIN,NUMDCPTCIE_SIN_INIT)
 	SELECT
   	NVL(decaismt.NUMCPTE,0),
   	NVL(decaismt.NUMCHQ,0),
   	decaismt.NUMDECAISMT,
   	affectation.numaffec,
   	NVL(decaismt.MODPMT,0),
   	NVL(decaismt.DATPAY,SYSDATE),
   	SYSDATE,
   	1, --MOTIF
   	decaismt.NUMUTIL,
   	NVL(decaismt.REFPMT,0),
   	decaismt.CODOPE,
    0,
   	-1,
   	null,null,null,null,null
   	FROM decaismt, affectation
    WHERE affectation.numaffec = :OLD.numdec
      AND affectation.codope   = 2
      AND affectation.numdecaismt IS NOT NULL
      AND decaismt.numdecaismt = affectation.numdecaismt ;


  INSERT INTO affectation_annul
   (IDPIECE,CODOPE,NUMAFFEC,NUMDECAISMT,MONTANT,DATAFFEC,NUMCLI,DATANNUL,MONTANT_D,MONNAIE,MONNAIE_D,
     NBFEUILLE,MONTANT_EC,TYPE_EC,SENS_EC,DEVISE_EC,MONTANT_CT,DEVISE_CT,IDCOMPTA_INIT,IDCOMPTA)
    SELECT l_idpiece
     ,CODOPE
     ,NUMAFFEC
     ,NUMDECAISMT
     ,MONTANT
     ,DATAFFEC
     ,NUMCLI
     , SYSDATE
     ,MONTANT_D
     ,MONNAIE
     ,MONNAIE_D
     ,NBFEUILLE
     ,MONTANT_EC
     ,TYPE_EC
     ,SENS_EC
     ,DEVISE_EC
     ,MONTANT_CT
     ,DEVISE_CT
     ,NULL
     ,IDCOMPTA
    FROM affectation
    WHERE affectation.numaffec = :old.numdec
      AND affectation.codope   = 2
      AND affectation.numdecaismt IS NOT NULL ;


  DELETE affectation
    WHERE affectation.numaffec = :old.numdec
       AND affectation.codope  = 2;

  INSERT INTO HISTO_CALCUL_ANNUL
              ( IDCALCUL,IDREPARTITION,NUMDEC,NOSIN,NUMFOR,DEBUT,FIN,MONTANT,REVAL,DEDU,MONTANT_REMB,MT_BASE,
                MONTANT_D,REVAL_D,DEDU_D,MONTANT_REMB_D,MT_BASE_D,IDADHESION,MONNAIE,MONNAIE_D,DATANNUL,NUMUTIL_ANNUL)
           SELECT
            IDCALCUL,
            IDREPARTITION,
            NUMDEC,
            NOSIN,
            NUMFOR,
            DEBUT,
            FIN,
            MONTANT,
            REVAL,
            DEDU,
            MONTANT_REMB,
            MT_BASE,
            MONTANT_D,
            REVAL_D,
            DEDU_D,
            MONTANT_REMB_D,
            MT_BASE_D,
            IDADHESION,
            MONNAIE,
            MONNAIE_D,
            SYSDATE,
            F_NUMUTIL
              FROM v_histo_calcul
              WHERE numdec = :old.numdec;

  UPDATE histo_calcul
      SET numdec = 0
    WHERE histo_calcul.numdec = :old.numdec;

END;