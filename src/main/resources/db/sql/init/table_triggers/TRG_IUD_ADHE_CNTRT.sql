CREATE TRIGGER ARTHUS.TRG_IUD_ADHE_CNTRT
FOR INSERT OR UPDATE OR DELETE ON ADHE_CNTRT
COMPOUND TRIGGER



  TYPE ty_adhe_cntrt   IS TABLE OF adhe_cntrt%ROWTYPE;
  t_adhe_cntrt         ty_adhe_cntrt := ty_adhe_cntrt();

  TYPE ty_action       IS TABLE OF VARCHAR2(20);
  t_action             ty_action     := ty_action();

  j                    NUMBER;
  loc_couverture       ADHESION%rowtype;


-- -- -- -- --
-- 1er
-- -- -- -- --
BEFORE STATEMENT IS BEGIN
    -- initialisation du tableau permettant de ne plus utiliser la vue materialisée
    t_adhe_cntrt := ty_adhe_cntrt();
    t_action   := ty_action();
END BEFORE STATEMENT;

-- -- -- -- --
-- 2ème
-- -- -- -- --
BEFORE EACH ROW IS BEGIN

  -- incrémentation des tableau
  t_action.extend;
  t_adhe_cntrt.extend;

  -- alimentation tableau t_action pour traitement spécifique postérieur dans la section AFTER STATEMENT
  CASE WHEN DELETING THEN
        -- en remplacement de TTRG_BF_DEL_ADHE_CNTRT
        t_action(t_action.last) := 'DELETING';
        -- alimentation tableau t_adhe_cntrt avec les nouvelles données d'adhesion pour traitement spécifique postérieur dans la section AFTER STATEMENT
        t_adhe_cntrt(t_adhe_cntrt.last).IDADHESION     := :old.IDADHESION;
        t_adhe_cntrt(t_adhe_cntrt.last).REF_EXT        := :old.REF_EXT;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMGAR         := :old.NUMGAR;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMADHE        := :old.NUMADHE;
        t_adhe_cntrt(t_adhe_cntrt.last).DATE_ADHE      := :old.DATE_ADHE;
        t_adhe_cntrt(t_adhe_cntrt.last).MEME_GAR       := :old.MEME_GAR;
        t_adhe_cntrt(t_adhe_cntrt.last).DATE_FIN_ADHE  := :old.DATE_FIN_ADHE;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMQUERABLE    := :old.NUMQUERABLE;
        t_adhe_cntrt(t_adhe_cntrt.last).FRACT          := :old.FRACT;
        t_adhe_cntrt(t_adhe_cntrt.last).ECHESUIV       := :old.ECHESUIV;
        t_adhe_cntrt(t_adhe_cntrt.last).DERECHE        := :old.DERECHE;
        t_adhe_cntrt(t_adhe_cntrt.last).MREGL          := :old.MREGL;
        t_adhe_cntrt(t_adhe_cntrt.last).DELAI          := :old.DELAI;
        t_adhe_cntrt(t_adhe_cntrt.last).DSOUS          := :old.DSOUS;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMUTIL        := :old.NUMUTIL;
        t_adhe_cntrt(t_adhe_cntrt.last).ECHE_ANNIV     := :old.ECHE_ANNIV;
       ELSE
        -- en remplacement de TRG_AF_INS_ADHE_CNTRT
        t_action(t_action.last) := 'INSERTUPDATE';
        -- alimentation tableau t_adhe_cntrt avec les nouvelles données d'adhesion pour traitement spécifique postérieur dans la section AFTER STATEMENT
        t_adhe_cntrt(t_adhe_cntrt.last).IDADHESION     := :new.IDADHESION;
        t_adhe_cntrt(t_adhe_cntrt.last).REF_EXT        := :new.REF_EXT;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMGAR         := :new.NUMGAR;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMADHE        := :new.NUMADHE;
        t_adhe_cntrt(t_adhe_cntrt.last).DATE_ADHE      := :new.DATE_ADHE;
        t_adhe_cntrt(t_adhe_cntrt.last).MEME_GAR       := :new.MEME_GAR;
        t_adhe_cntrt(t_adhe_cntrt.last).DATE_FIN_ADHE  := :new.DATE_FIN_ADHE;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMQUERABLE    := :new.NUMQUERABLE;
        t_adhe_cntrt(t_adhe_cntrt.last).FRACT          := :new.FRACT;
        t_adhe_cntrt(t_adhe_cntrt.last).ECHESUIV       := :new.ECHESUIV;
        t_adhe_cntrt(t_adhe_cntrt.last).DERECHE        := :new.DERECHE;
        t_adhe_cntrt(t_adhe_cntrt.last).MREGL          := :new.MREGL;
        t_adhe_cntrt(t_adhe_cntrt.last).DELAI          := :new.DELAI;
        t_adhe_cntrt(t_adhe_cntrt.last).DSOUS          := :new.DSOUS;
        t_adhe_cntrt(t_adhe_cntrt.last).NUMUTIL        := :new.NUMUTIL;
        t_adhe_cntrt(t_adhe_cntrt.last).ECHE_ANNIV     := :new.ECHE_ANNIV;
  END CASE;

END BEFORE EACH ROW;

-- -- -- -- --
-- 3ème traitement
-- -- -- -- --
AFTER STATEMENT IS
BEGIN

-- boucle sur tous les enregistrements déclencheurs
FOR j IN 1 .. t_adhe_cntrt.COUNT
  LOOP

    IF t_action(j) = 'INSERTUPDATE' THEN
      PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(31, t_adhe_cntrt(j).idadhesion, t_adhe_cntrt(j).numadhe,t_adhe_cntrt(j).idadhesion,t_adhe_cntrt(j).numgar);
      PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(31, t_adhe_cntrt(j).idadhesion, t_adhe_cntrt(j).numquerable,t_adhe_cntrt(j).idadhesion,t_adhe_cntrt(j).numgar);

      For loc_couverture in (SELECT * FROM ADHESION WHERE idadhesion = t_adhe_cntrt(j).idadhesion)
      Loop
          PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(60, loc_couverture.idcouverture, loc_couverture.numindiv,t_adhe_cntrt(j).idadhesion,t_adhe_cntrt(j).numgar);
      End Loop;
    END IF;

    IF t_action(j) = 'DELETING' THEN
       PK_INS_HISTO_EXPORT.DEL_HISTO_EXPORT (31, t_adhe_cntrt(j).idadhesion);
    END IF;

  END LOOP;

END AFTER STATEMENT;

END;