CREATE TRIGGER ARTHUS.TRG_BI_PERS_HISTO_PHYS
Before Insert
on pers_histo_phys
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
DECLARE
   loc_couverture ADHESION%rowtype;
   loc_numgar     NUMBER;
BEGIN
  :new.creation := sysdate;
  IF :new.numutil IS NULL THEN
    :new.numutil := f_numutil;
  END IF;
  IF :new.idpershistphys IS NULL THEN
    SELECT  idpershistphys.nextval
          INTO  :new.idpershistphys
          FROM  Dual;
  END IF;

  PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(3, :new.idpershistphys, :new.numindiv);

    For loc_couverture in (SELECT * FROM ADHESION WHERE idadhesion IN (SELECT IDADHESION FROM ADHE_CNTRT WHERE NUMADHE = :new.numindiv OR NUMQUERABLE = :new.numindiv
                UNION
                SELECT IDADHESION FROM ADHE_CNTRT_MEMBRE WHERE NUMINDIV = :new.numindiv))
    Loop
      SELECT NUMGAR INTO loc_numgar FROM ADHE_CNTRT WHERE IDADHESION = loc_couverture.idadhesion;
      PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(60, loc_couverture.idcouverture, loc_couverture.numindiv,loc_couverture.idadhesion,loc_numgar);
    End Loop;

END;