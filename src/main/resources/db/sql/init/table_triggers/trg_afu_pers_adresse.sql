CREATE TRIGGER ARTHUS.trg_afu_pers_adresse
  AFTER UPDATE OR INSERT ON pers_adresse
  REFERENCING OLD AS old NEW AS new
  FOR EACH ROW
DECLARE
   loc_envoi      ENVOI_MAIL%ROWTYPE;
   CURSOR c_adhesion IS
    SELECT a.idadhesion, ad.numadhe
    FROM adhesion a, adhe_cntrt ad, contrat c
    WHERE NUMINDIV = :new.numindiv
    AND a.idadhesion = ad.idadhesion
	AND c.numgar = a.numgar
	AND c.gest_prest = 1  --prestations gérées
	AND a.typfor = 1 --couverture santé
    AND (sysdate BETWEEN a.datapli AND NVL(add_months(a.datper,3),sysdate) OR a.datapli > sysdate)
    ORDER BY rang,datapli desc ;

    r_adhesion c_adhesion%rowtype;
BEGIN
    IF UPDATING AND (:new.defaut <> :old.defaut) THEN
        null;  --ne pas prendre en compte lorsque l'on décoche une adresse.
    ELSE
      IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('ADDR',:new.NUMUTIL)   THEN
        --PK_trace.P_INS_journal_adm (        I_nom_traitement => 'MA02T',        I_session  => 99999,        I_niv_msg  => 1,        I_msg_adm  => ' [triger]dans check droit',        I_idligne  => 2);

        OPEN C_adhesion;
        FETCH C_adhesion INTO r_adhesion;
        IF(C_adhesion%FOUND) then
          loc_envoi.clef := r_adhesion.idadhesion;
          -- on prend l'adresse mail de l'adhérent plutot que l'adresse de l'individu concerné
          loc_envoi.NUMINDIV_DEST :=f_numassu(:NEW.NUMINDIV);
          loc_envoi.IDTEXTE:= 1;
          loc_envoi.TYPE_MAIL:=1;
          loc_envoi.DATE_CREATION:=sysdate;
          loc_envoi.NUMBENE:=:new.numindiv;
          loc_envoi.NUMUTIL:= :new.NUMUTIL;
          loc_envoi.etendue:=2;
          IF  PK_MAIL.CHECK_DEMAT_INDIV(loc_envoi.NUMINDIV_DEST) = 1 THEN
		    PK_MAIL.CREER_MAIL(loc_envoi);
		  END IF;
        END IF;
        CLOSE  C_adhesion;

      END IF;
    END IF;


EXCEPTION
    WHEN OTHERS THEN  PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'trg_afu_pers_adresse',
        I_session  => 99999,
        I_niv_msg  => 1,
        I_msg_adm  =>  SUBSTR(SQLERRM, 1, 100),
        I_idligne  => 5);
END;