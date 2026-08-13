CREATE TRIGGER ARTHUS.trg_af_diu_ADHESION AFTER
  DELETE OR
  INSERT OR
  UPDATE ON ADHESION REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW DECLARE l_action VARCHAR2(1);
  BEGIN

    if inserting then
      l_action := 'I';
      INSERT INTO ADHESION_AUDIT(
      NUMINDIV, NUMGAR, NUMFOR, DATAPLI,	DATPER,	RANG,	ETAT,	UC,	FLAG_REGIME, REGIME, TYPFOR, NUMORG,
      DIS_CARENCE, DIS_FRANCHISE, IDADHESION,	NUMFOR_CARENCE,	NUMUTIL, CREATION,	MAJ,	MOTIF,	IDCOUVERTURE,
      action_audit, numutil_audit, date_audit
      )
      VALUES(
      :new.NUMINDIV, :new.NUMGAR, :new.NUMFOR,:new.DATAPLI,	:new.DATPER, :new.RANG, :new.ETAT, :new.UC,
      :new.FLAG_REGIME, :new.REGIME, :new.TYPFOR, :new.NUMORG, :new.DIS_CARENCE, :new.DIS_FRANCHISE,
      :new.IDADHESION, :new.NUMFOR_CARENCE, :new.NUMUTIL, :new.CREATION, :new.MAJ, :new.MOTIF, :new.IDCOUVERTURE,
       l_action,f_numutil,SYSDATE
       );
    else
      if updating then
        l_action := 'U';
      else -- deleting
        l_action := 'D';
      end if ;

      INSERT INTO ADHESION_AUDIT(
      NUMINDIV, NUMGAR, NUMFOR, DATAPLI,	DATPER,	RANG,	ETAT,	UC,	FLAG_REGIME, REGIME, TYPFOR, NUMORG,
      DIS_CARENCE, DIS_FRANCHISE, IDADHESION,	NUMFOR_CARENCE,	NUMUTIL, CREATION,	MAJ,	MOTIF,	IDCOUVERTURE,
      action_audit, numutil_audit, date_audit
      )
      VALUES(
      :old.NUMINDIV, :old.NUMGAR, :old.NUMFOR, :old.DATAPLI,	:old.DATPER, :old.RANG, :old.ETAT, :old.UC,
      :old.FLAG_REGIME, :old.REGIME, :old.TYPFOR, :old.NUMORG, :old.DIS_CARENCE, :old.DIS_FRANCHISE,
      :old.IDADHESION, :old.NUMFOR_CARENCE, :old.NUMUTIL, :old.CREATION, :old.MAJ, :old.MOTIF, :old.IDCOUVERTURE,
      l_action,f_numutil,SYSDATE
      );

    end if ;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END ;