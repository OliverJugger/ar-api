CREATE TRIGGER ARTHUS.t_af_diu_porte_contrat
  AFTER DELETE OR INSERT OR UPDATE ON porte_contrat
  REFERENCING OLD AS old NEW AS new
  FOR EACH ROW
DECLARE
      l_action       VARCHAR2(1);
      l_pwd          VARCHAR2(200);
      l_porte_extranet NUMBER;
BEGIN
-- DELETE OR UPDATE (old values)
IF DELETING OR UPDATING THEN
   IF DELETING THEN
      l_action := 'D';
   END IF;
   IF UPDATING THEN
      l_action := 'U';
   END IF;
   INSERT INTO histo_porte_contrat (NUMGAR, NUMPORTE, NUMUTIL, CREATION, NUMUTIL_MAJ, MAJ,
      ACTION_HISTO,
      NUMUTIL_HISTO,
      DATE_HISTO)
   VALUES (:old.NUMGAR, :old.NUMPORTE, :old.NUMUTIL, :old.CREATION, :old.NUMUTIL_MAJ, :old.MAJ,
      L_ACTION,
      F_NUMUTIL,
      SYSDATE);
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_porte_contrat (NUMGAR, NUMPORTE, NUMUTIL, CREATION, NUMUTIL_MAJ, MAJ,
      action_histo,
      numutil_histo,
      date_histo)
   VALUES (:new.NUMGAR, :new.NUMPORTE, :new.NUMUTIL, :new.CREATION, :new.NUMUTIL_MAJ, :new.MAJ,
      'I',
      f_numutil,
      SYSDATE);

     -- Projet BIA ajout d'un mot de passe sur lecontrat lorsque qu'on ouvre la porte extranet sur le contrat CLI 20/08/2018
     BEGIN
        SELECT code
        INTO l_porte_extranet
        FROM libelle
        WHERE mnemo = 'PORTE'
        AND libelle ='ESPACE ASSURE';
    EXCEPTION WHEN OTHERS THEN NULL;
    END ;

     IF :new.NUMPORTE in (l_porte_extranet) THEN  -- porte 25 pour gerep
      PK_HISTO_CONTRAT.P_UPDATE_MDP_CNTRT(:new.NUMGAR, l_pwd);
    END IF;

END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;