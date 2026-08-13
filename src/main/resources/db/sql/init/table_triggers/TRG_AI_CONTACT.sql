CREATE TRIGGER ARTHUS.TRG_AI_CONTACT
FOR INSERT OR UPDATE ON CONTACT
COMPOUND TRIGGER
  --------------------------------------------------------------------------------------------
  -- Lors de la création d’une adresse mail sur un nouveau bénéficiaire, ce déclencheur sur la
  -- table CONTACT est appelé lors de l’ajout d’un email en vérifiant que l’assuré possède une couverture valide
  --------------------------------------------------------------------------------------------

  TYPE ty_contact   IS TABLE OF contact%ROWTYPE;

  t_contact         ty_contact := ty_contact();
  t_contact_old         ty_contact := ty_contact();
  TYPE ty_action     IS TABLE OF VARCHAR2(20);
  t_action           ty_action   := ty_action();
  TYPE ty_isExisteOneBefore   IS TABLE OF NUMBER;  -- verifier s'il n'y avait pas de mail existant
  t_isExisteOneBefore ty_isExisteOneBefore;
  i                  NUMBER;
  j                  NUMBER;
  loc_doublon        envoi_mail.clef%TYPE;


  loc_envoi      ENVOI_MAIL%ROWTYPE;
  loc_envoi_init ENVOI_MAIL%ROWTYPE;
   -- curseur de recupération de la derniere adhesion de l'individu.
   CURSOR c_adhesion (p_numindiv number) IS
   	SELECT adhesion.idadhesion, adhe_cntrt.numadhe, adhesion.creation ,adhesion.datapli
	FROM adhesion , adhe_cntrt, contrat
	WHERE adhesion.NUMINDIV = p_numindiv
    AND adhesion.idadhesion = adhe_cntrt.idadhesion
	AND contrat.numgar = adhe_cntrt.numgar
	AND contrat.gest_prest = 1  --prestations gérées
	AND adhesion.typfor = 1 --couverture santé
    --AND ( p_texte =19 OR NOT EXISTS (SELECT clef FROM envoi_mail WHERE numbene = p_numindiv and etendue = 2  and idtexte in (20,5) ))--toutes adhésions confondues
    AND (sysdate BETWEEN adhesion.datapli AND NVL(add_months(adhesion.datper,3),sysdate) OR adhesion.datapli > sysdate)
    ORDER BY rang,datapli desc;

	r_adhesion c_adhesion%rowtype;
-- -- -- -- --
-- 1er
-- -- -- -- --
BEFORE STATEMENT IS BEGIN
    -- initialisation du tableau permettant de ne plus utiliser la vue materialisée
    t_contact  := ty_contact();
    t_contact_old  := ty_contact();
    t_isExisteOneBefore := ty_isExisteOneBefore();
    t_action   := ty_action();
END BEFORE STATEMENT;

-- -- -- -- --
-- 2ème
-- -- -- -- --
BEFORE EACH ROW IS BEGIN

  -- incrémentation des tableau
  t_action.extend;
  t_contact.extend;
  t_contact_old.extend;
  t_isExisteOneBefore.extend;


  -- alimentation tableau t_action pour traitement spécifique postérieur dans la section AFTER STATEMENT
  CASE
        WHEN INSERTING THEN
          t_action(t_action.last) := 'INSERTING';
        WHEN UPDATING THEN
          t_action(t_action.last) := 'UPDATING';
          t_contact_old(t_contact_old.last).MAJ            := :old.maj;
          t_contact_old(t_contact_old.last).NUMUTIL        := :old.numutil;
          t_contact_old(t_contact_old.last).numindiv       := :old.numindiv;
          t_contact_old(t_contact_old.last).NATURE         := :old.NATURE;
          t_contact_old(t_contact_old.last).TYPE           := :old.TYPE;
          t_contact_old(t_contact_old.last).COORDONNEE     := :old.COORDONNEE;
          t_contact_old(t_contact_old.last).FLAG           := :old.FLAG;
          t_contact_old(t_contact_old.last).creation       := :old.creation;
          t_contact_old(t_contact_old.last).IDCONTACT      := :old.IDCONTACT;
    ELSE NULL;
  END CASE;

  -- alimentation tableau t_contact avec les nouvelles données de contact pour traitement spécifique postérieur dans la section AFTER STATEMENT
  t_contact(t_contact.last).MAJ            := :new.maj;
  t_contact(t_contact.last).NUMUTIL        := :new.numutil;
  t_contact(t_contact.last).numindiv       := :new.numindiv;
  t_contact(t_contact.last).NATURE         := :new.NATURE;
  t_contact(t_contact.last).TYPE           := :new.TYPE;
  t_contact(t_contact.last).COORDONNEE     := :new.COORDONNEE;
  t_contact(t_contact.last).FLAG           := :new.FLAG;
  t_contact(t_contact.last).creation       := :new.creation;
  t_contact(t_contact.last).IDCONTACT      := :new.IDCONTACT;
  -- verification de l'existance d'un mail en les comptant
  BEGIN
    SELECT COUNT(*) INTO  t_isExisteOneBefore(t_contact.last)
    FROM contact
    WHERE numindiv = :NEW.numindiv
    AND nature  = :NEW.nature;
  EXCEPTION
  WHEN
    OTHERS THEN
    t_isExisteOneBefore(t_contact.last) := 0;
  END;


END BEFORE EACH ROW;


-- -- -- -- --
-- 3ème traitement
-- -- -- -- --
AFTER STATEMENT IS
BEGIN

j := 0;

-- boucle sur tous les enregistrements déclencheurs
FOR j IN 1 .. t_contact.COUNT  LOOP
  loc_envoi:=loc_envoi_init;
  -- action déclenchée lors de la création d'un mail ou lors de la mise à jour d'un mail existant par forcage du défaut
  IF t_contact(j).NATURE = 4 AND t_contact(j).TYPE = 2  AND (t_action(j) = 'INSERTING' OR (t_action(j) = 'UPDATING' AND  t_contact_old(j).FLAG = 'N' AND t_contact(j).FLAG = 'O' ))    THEN
    --lors d'ajout de mail on change le circuit info pour dématérialisé
    UPDATE COURRIER_INFO SET moyen_info=2 WHERE numindiv = t_contact(j).NUMINDIV AND type_crrr=28 AND moyen_info=1
    -- MUR M0005551
    and exists(select numindiv from individu where numindiv = t_contact(j).NUMINDIV and type=1)
    ;

  --PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AI_CONTACT',     I_session        => SID,    I_niv_msg        => 1,    I_msg_adm        => 'DEBUT TRG_AI_CONTACT',    I_idligne        => 2);
    --modification de l'email
    IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('NASSU',NVL(t_contact(j).numutil,F_NUMUTIL) )THEN


	--  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AI_CONTACT',  I_session        => SID,      I_niv_msg        => 1,       I_msg_adm        => 'Assuré '||t_contact(j).NUMINDIV||' texte:'||loc_envoi.IDTEXTE,     I_idligne        => 3);
	  -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AI_CONTACT',  I_session        => SID,      I_niv_msg        => 1,       I_msg_adm        => 'Assuré '||t_contact(j).NUMINDIV||' '||trunc(r_adhesion.creation)||' '||trunc(sysdate),     I_idligne        => 3);
      OPEN C_adhesion(t_contact(j).NUMINDIV);
      FETCH C_adhesion into r_adhesion;
      IF (C_adhesion%FOUND) THEN
        loc_envoi.CLEF := r_adhesion.idadhesion;
        -- on prend l'adresse mail de l'adhérent plutot que l'adresse de l'individu concerné
        loc_envoi.NUMINDIV_DEST := NVL(f_numassu(t_contact(j).NUMINDIV),R_adhesion.numadhe);
      END IF;
      CLOSE  C_adhesion;


      IF loc_envoi.NUMINDIV_DEST IS NOT NULL THEN
        loc_envoi.DESTINATAIRE := NVL(f_coordonne_contact(loc_envoi.numindiv_dest,4,2),f_coordonne_contact(loc_envoi.numindiv_dest,4,1));
        loc_envoi.NUMBENE:=t_contact(j).NUMINDIV;
        loc_envoi.NUMUTIL:= t_contact(j).numutil;
        loc_envoi.ETENDUE:=2;     -- ADHESION
        IF   t_isExisteOneBefore(j) > 0 then
         loc_envoi.IDTEXTE:= 19;    -- modification du mail
        ELSIF trunc(r_adhesion.creation)=trunc(sysdate) and r_adhesion.datapli > trunc(sysdate) THEN
		  loc_envoi.IDTEXTE:= 5; --nouvelle adhésion
	    ELSE
          loc_envoi.IDTEXTE:= 20; --adhésion existante mais assuré non démat.
        END IF;

		loc_doublon:=NULL;
		IF loc_envoi.IDTEXTE in( 5,20) THEN
		  BEGIN
		  SELECT clef INTO loc_doublon
		  FROM envoi_mail WHERE numbene = t_contact(j).NUMINDIV and etendue = 2  and idtexte in (20,5);
		  EXCEPTION
		    WHEN no_data_found THEN loc_doublon:=NULL;
			WHEN OTHERS THEN loc_doublon:=2;
		  END;
		END IF;

        loc_envoi.TYPE_MAIL:=1;   -- Automatique
        loc_envoi.DATE_CREATION:=SYSDATE;


        IF  PK_MAIL.CHECK_DEMAT_INDIV(loc_envoi.NUMINDIV_DEST) = 1 AND loc_doublon IS NULL THEN
		  PK_MAIL.CREER_MAIL(loc_envoi);
		END IF;

      END IF;

    END IF;

   -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AI_CONTACT',   I_session        => SID,I_niv_msg        => 1,       I_msg_adm        => 'FIN TRG_AI_CONTACT',    I_idligne        => 4);

    END IF;
  END LOOP;
EXCEPTION
    WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AI_CONTACT',
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  => 'WHEN OTHERS THEN : '|| SUBSTR(SQLERRM, 1, 100),
                                   I_idligne  => 5);
END AFTER STATEMENT;

END;