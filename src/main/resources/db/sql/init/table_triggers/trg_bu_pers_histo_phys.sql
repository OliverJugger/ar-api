CREATE TRIGGER ARTHUS.trg_bu_pers_histo_phys
Before Update
on pers_histo_phys
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
DECLARE
   loc_couverture ADHESION%rowtype;
   loc_numgar     NUMBER;
Begin
  IF :new.numutil IS NULL THEN
    :new.numutil := f_numutil;
  END IF;
  :new.maj := sysdate;
  PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(3, :new.idpershistphys, :new.numindiv);

  For loc_couverture in (SELECT * FROM ADHESION WHERE idadhesion IN (SELECT IDADHESION FROM ADHE_CNTRT WHERE NUMADHE = :new.numindiv OR NUMQUERABLE = :new.numindiv
              UNION
              SELECT IDADHESION FROM ADHE_CNTRT_MEMBRE WHERE NUMINDIV = :new.numindiv))
  Loop
    SELECT NUMGAR INTO loc_numgar FROM ADHE_CNTRT WHERE IDADHESION = loc_couverture.idadhesion;
    PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(60, loc_couverture.idcouverture, loc_couverture.numindiv,loc_couverture.idadhesion,loc_numgar);
  End Loop;

End;