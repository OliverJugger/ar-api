CREATE TRIGGER ARTHUS.TRG_AF_UPD_ADHE_CNTRT2
  AFTER UPDATE OF DATE_FIN_ADHE ON ADHE_CNTRT
  REFERENCING OLD AS OLD NEW AS NEW
  FOR EACH ROW
  --------------------------------------------------------------------------------------------
  -- Résiliation de l adhesion : Positionnement de la date de fin sur l'adhesion individuelle
  -- Le déclenchement ne porte pas sur les couvertures
  --------------------------------------------------------------------------------------------
DECLARE
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  loc_sante      NUMBER:=0; -- permet de verifier qu'il s'agit d'une adhésion santé

BEGIN

    /*PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AF_UPD_ADHE_CNTRT2',
                                 I_session        => SID,
                                 I_niv_msg        => 1,
                                 I_msg_adm        => 'TRG_AF_UPD_ADHE_CNTRT2',
                                 I_idligne        => 0);*/

  IF :NEW.DATE_FIN_ADHE IS NOT NULL AND :NEW.DATE_FIN_ADHE = :NEW.DATE_ADHE then
    DELETE envoi_mail WHERE numindiv_dest = :NEW.NUMADHE AND idtexte =5 AND etat = 0;
  ELSIF :NEW.DATE_FIN_ADHE IS NOT NULL -- la resiliation est actée uniquement si la date de fin n'est pas nulle
  AND PK_MAIL.CHECK_DROIT_ENVOI_MAIL('RESI',:new.NUMUTIL)  -- Règle de gestion pour permettre la résiliation d une adhésion(libelle_bis.mnemo='RG_MAIL', code='RESI_AUTO')
    AND PK_MAIL.CHECK_DEMAT_INDIV(:NEW.NUMADHE) = 1        -- vérification que l assuré possède un circuit à 28
    AND :NEW.DATE_FIN_ADHE <=TRUNC(SYSDATE) -- on ne génére pas de mail pour les adhésions résiliées dans le futur (jobs le fait quotidiennement)
  THEN
    SELECT count(idadhesion) INTO loc_sante
    FROM  contrat c,adhesion a
    WHERE c.numgar = :NEW.NUMGAR
  AND c.numgar = a.numgar
  AND a.idadhesion = :NEW.idadhesion
  AND c.gest_prest = 1  --prestations gérées
  AND a.typfor = 1; --couverture santé
  IF loc_sante>0 THEN

      loc_envoi.NUMINDIV_DEST:=:NEW.NUMADHE;
      loc_envoi.NUMBENE:=:NEW.NUMADHE;
      loc_envoi.NUMUTIL:= :new.NUMUTIL;
      loc_envoi.ETENDUE:=2;     -- ADHESION
      loc_envoi.CLEF:= :NEW.IDADHESION;
      loc_envoi.IDTEXTE:= 2;    -- Nous vous confirmons que votre adhésion est bien résiliée...(MAIL_TEXTE.ID_TEXTE =2)
      loc_envoi.TYPE_MAIL:=1;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
      PK_MAIL.CREER_MAIL(loc_envoi);
  END IF;

  END IF;


EXCEPTION
    WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AF_UPD_ADHE_CNTRT2',
                                   I_session        => SID,
                                   I_niv_msg        => 1,
                                   I_msg_adm        =>  SUBSTR(SQLERRM, 1, 100),
                                   I_idligne        => 2);
END;