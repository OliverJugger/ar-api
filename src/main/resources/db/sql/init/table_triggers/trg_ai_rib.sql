CREATE TRIGGER ARTHUS.trg_ai_rib
After Insert or Update
On rib
REFERENCING NEW AS NEW OLD AS OLD FOR EACH ROW
DECLARE
   loc_couverture ADHESION%rowtype;
   loc_numgar     NUMBER;
   LOC_ENTITE_60EXISTS NUMBER :=0;
   loc_envoi  envoi_mail%ROWTYPE;

   -- curseur de recupération de la derniere adhesion de l'individu.
  CURSOR c_adhesion IS
    SELECT adhesion.idadhesion, adhe_cntrt.numadhe,adhesion.rang,adhesion.datapli
    FROM adhesion , adhe_cntrt, contrat c
    WHERE adhesion.NUMINDIV = :new.numindiv
    AND adhesion.idadhesion = adhe_cntrt.idadhesion
    AND c.numgar = adhe_cntrt.numgar
    AND c.gest_prest = 1  --prestations gérées
    AND adhesion.typfor = 1 --couverture santé
    AND (sysdate BETWEEN adhesion.datapli AND NVL(add_months(adhesion.datper,6),sysdate) )   -- prend les adhésions en vigeur a plus 6 mois
    AND NOT EXISTS (select numindiv_dest FROM envoi_mail WHERE numindiv_dest = adhe_cntrt.numadhe and idtexte =5 and trunc(date_creation)>trunc(sysdate)-3)
    ORDER BY adhesion.rang,adhesion.datapli desc ;

   r_adhesion c_adhesion%rowtype;
Begin
  PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(4, :new.idrib, :new.numindiv);

---------------- Déclenchement Automatique de mail-----------------------------

    BEGIN
/*  IF UPDATING THEN
        PK_trace.P_INS_journal_adm (        I_nom_traitement => 'MA02T',    I_session  => 99999,    I_niv_msg  => 1   I_msg_adm  =>  'Maj D''un rib : old date fin ['||:old.fin||'] new date fin['||:new.fin||']', I_idligne  => 5);
    END IF;*/
    IF UPDATING AND (((:old.fin is null and :new.fin is not null)  OR (:old.fin is not null and :new.fin is null) OR :old.fin <> :new.fin )
                 OR ( :new.type = 2 AND :old.nature =1 AND :new.nature = 2 ))    --si en chéque et passage en rib pour l'encaissement
    THEN
        NULL;  --ne pas prendre en compte lorsque l'on met une date de fin sur un rib.
    ELSE
      IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('MRIB',F_NUMUTIL) and :new.nature not in (1)  THEN    -- on bloque les cheques

        OPEN C_adhesion;
        FETCH C_adhesion INTO r_adhesion;
        IF (C_adhesion%FOUND) THEN
          loc_envoi.CLEF := r_adhesion.idadhesion;
              loc_envoi.NUMBENE:=:new.numindiv;
          loc_envoi.NUMUTIL:= F_NUMUTIL;
          loc_envoi.ETENDUE:=2;
          IF :new.numindiv = r_adhesion.numadhe THEN
            loc_envoi.IDTEXTE:= 4;
          ELSE
            loc_envoi.IDTEXTE:= 15;
          END IF;
          loc_envoi.TYPE_MAIL:=1;
          loc_envoi.DATE_CREATION:=sysdate;
          -- on prend l'adresse mail de l'adhérent plutot que l'adresse de l'individu concerné
          loc_envoi.NUMINDIV_DEST := f_numassu(:NEW.NUMINDIV);

          IF  PK_MAIL.CHECK_DEMAT_INDIV(loc_envoi.NUMINDIV_DEST) = 1 THEN
            PK_MAIL.CREER_MAIL(loc_envoi);
          END IF;
        END IF;
        CLOSE  C_adhesion;
      END IF;
    END IF;
    EXCEPTION WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm (
        I_nom_traitement => 'MA02T',
        I_session  => 99999,
        I_niv_msg  => 1,
        I_msg_adm  =>  SUBSTR(SQLERRM, 1, 100),
        I_idligne  => 5);
    END;

--------------------Fin Déclenchement Automatique de mail


    BEGIN -- application des lignes suivantes uniquement si l'entité 60 est paramétrées sur Arthus (Cas de la MCD)
        SELECT distinct 1 into LOC_ENTITE_60EXISTS from libelle where mnemo = 'ENT_PHYS' and code =60;
    EXCEPTION WHEN OTHERS THEN
        LOC_ENTITE_60EXISTS := 0;
    END;
        IF LOC_ENTITE_60EXISTS = 1 THEN
            For loc_couverture in (SELECT * FROM ADHESION WHERE idadhesion IN (SELECT IDADHESION FROM ADHE_CNTRT WHERE NUMADHE = :new.numindiv OR NUMQUERABLE = :new.numindiv
                                    UNION
                                    SELECT IDADHESION FROM ADHE_CNTRT_MEMBRE WHERE NUMINDIV = :new.numindiv))
            Loop
                SELECT NUMGAR INTO loc_numgar FROM ADHE_CNTRT WHERE IDADHESION = loc_couverture.idadhesion;
                PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(60, loc_couverture.idcouverture, loc_couverture.numindiv,loc_couverture.idadhesion,loc_numgar);
            End Loop;
    END IF;
End;