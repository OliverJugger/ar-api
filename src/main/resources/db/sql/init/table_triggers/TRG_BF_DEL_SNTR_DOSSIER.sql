CREATE TRIGGER ARTHUS."TRG_BF_DEL_SNTR_DOSSIER"
   BEFORE DELETE ON SNTR_DOSSIER
   REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW

BEGIN
  INSERT INTO SNTR_DOSSIER_ANNUL (NUM_DOSSIER_SIN  ,
                                  NUMLIGNE     ,
                                  NUMSIN_SNTR  ,
                                  DATANNUL     ,
                                  NUMUTIL_ANNUL)
  VALUES (:old.NUM_DOSSIER ,
          :old.NUMLIGNE    ,
          :old.NUMSIN_SNTR ,
          sysdate          ,
          F_NUMUTIL)       ;
END ;