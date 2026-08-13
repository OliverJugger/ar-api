CREATE TRIGGER ARTHUS.TRG_AF_UPD_INDIVIDU2
  AFTER UPDATE OF matorg, cless, caisse, regime
                  , matorg2, cless2, caisse2, regime2
                  ON INDIVIDU
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
     WHEN (
  ( NVL(NEW.matorg, '0')  != NVL(OLD.matorg, '0') )  OR
  ( NVL(NEW.cless, 0)     != NVL(OLD.cless, 0) )     OR
  ( NVL(NEW.caisse, '0')  != NVL(OLD.caisse, '0') )  OR
  ( NVL(NEW.regime, '0')  != NVL(OLD.regime, '0') )  OR
  ( NVL(NEW.matorg2, '0') != NVL(OLD.matorg2, '0') ) OR
  ( NVL(NEW.cless2, 0)    != NVL(OLD.cless2, 0) )    OR
  ( NVL(NEW.caisse2, '0') != NVL(OLD.caisse2, '0') ) OR
  ( NVL(NEW.regime2, '0') != NVL(OLD.regime2, '0') )
     ) DECLARE
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;

   CURSOR c_adhesion IS
    SELECT a.idadhesion, ad.numadhe
    FROM adhesion a, adhe_cntrt ad, contrat c
    WHERE NUMINDIV = :new.numindiv
    AND a.idadhesion = ad.idadhesion
	AND c.numgar = a.numgar
	AND c.gest_prest = 1  --prestations gérées
	AND a.typfor = 1 --couverture santé
  and f_etat_adhe(a.idadhesion, sysdate ) <>0
    AND (sysdate BETWEEN a.datapli AND NVL(add_months(a.datper,3),sysdate) OR a.datapli > sysdate)
    ORDER BY rang,datapli desc ;

  r_adhesion c_adhesion%rowtype;

BEGIN

 --   PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AF_UPD_INDIVIDU2',    I_session        => SID,     I_niv_msg        => 1,     I_msg_adm   => 'DEBUT TRG_AF_UPD_INDIVIDU2',  I_idligne        => 0);
  -- Règle de gestion pour permettre la modification du n°SS, du régime ou de la caisse(libelle_bis.mnemo='RG_MAIL', code='MRSS_AUTO')
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('MRSS',:new.NUMUTIL)   THEN

    OPEN C_adhesion;
    FETCH C_adhesion  INTO   r_adhesion;
    IF (C_adhesion%FOUND) THEN
      loc_envoi.CLEF := r_adhesion.idadhesion;
       -- on prend l'adresse mail de l'adhérent plutot que l'adresse de l'individu concerné
      loc_envoi.NUMINDIV_DEST :=r_adhesion.numadhe;--pas posssible f_numassu
      loc_envoi.NUMBENE := :NEW.NUMINDIV;
      loc_envoi.NUMUTIL := :new.NUMUTIL;
      loc_envoi.ETENDUE :=2;     -- ADHESION
	  IF :NEW.NUMINDIV = r_adhesion.numadhe THEN
	    loc_envoi.IDTEXTE := 13;--info perso adhérent
	  ELSE
        loc_envoi.IDTEXTE := 14;    -- infos perso béné
	  END IF;
      loc_envoi.TYPE_MAIL :=1;   -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;

	  IF  PK_MAIL.CHECK_DEMAT_INDIV(loc_envoi.NUMINDIV_DEST) = 1 THEN
		PK_MAIL.CREER_MAIL(loc_envoi);
	  END IF;

    END IF;
    CLOSE  C_adhesion;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AF_UPD_INDIVIDU2',
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  =>  SUBSTR(SQLERRM, 1, 100),
                                   I_idligne  => 6);
END;