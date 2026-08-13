CREATE TRIGGER ARTHUS.trg_bi_pers_adresse
BEFORE INSERT ON pers_adresse
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
DECLARE
  --
   CST_SCCS   CONSTANT VARCHAR2(120) := '@(#)trg_bi_pers_adresse.sql	1.0    14/12/04';
  --
   loc_couverture ADHESION%rowtype;
   loc_numgar     NUMBER;
BEGIN
  -- Forcage des zones NOT NULL
  :new.numutil  := NVL(:new.numutil,f_numutil);
  :new.creation := NVL(:new.creation,sysdate);
  PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(2, :new.idadresse, :new.numindiv);
  For loc_couverture in (SELECT * FROM ADHESION WHERE idadhesion IN (SELECT IDADHESION FROM ADHE_CNTRT WHERE NUMADHE = :new.numindiv OR NUMQUERABLE = :new.numindiv
              UNION
              SELECT IDADHESION FROM ADHE_CNTRT_MEMBRE WHERE NUMINDIV = :new.numindiv))
  Loop
    SELECT NUMGAR INTO loc_numgar FROM ADHE_CNTRT WHERE IDADHESION = loc_couverture.idadhesion;
    PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(60, loc_couverture.idcouverture, loc_couverture.numindiv,loc_couverture.idadhesion,loc_numgar);
  End Loop;

END;