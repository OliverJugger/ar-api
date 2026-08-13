CREATE TRIGGER ARTHUS.TRG_AI_ADHESION
  FOR INSERT  ON ADHESION
  COMPOUND TRIGGER
--  FOR EACH ROW
  --------------------------------------------------------------------------------------------
  -- Lors de la création d’une couverture sur un nouveau bénéficiaire, ce déclencheur sur la
  -- table ADHESION est appelé lors de l’ajout d’une couverture en vérifiant que l’assuré possède une adresse mail valide
  -- Le mail ne doit partir que pour une seule adhésion avec 1 seule couverture valide
  -- l assuré ne doit etre que NUMADHE dans ADHE_CNTRT
  --------------------------------------------------------------------------------------------


  TYPE ty_adhesion   IS TABLE OF adhesion%ROWTYPE;
  t_adhesion         ty_adhesion := ty_adhesion();

  TYPE ty_action     IS TABLE OF VARCHAR2(20);
  t_action           ty_action   := ty_action();

  i                  NUMBER;
  j                  NUMBER;

  p_entite       VARCHAR2(10) :='NASSU';  -- Règle de gestion pour permettre la création d'un nouvel assuré(libelle_bis.mnemo='RG_MAIL', code='NASSU_AUTO')
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  loc_envoi_init ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_is_adherent NUMBER:=0;
  loc_is_exist_before number :=0;

-- -- -- -- --
-- 1er
-- -- -- -- --
BEFORE STATEMENT IS BEGIN
    -- initialisation du tableau permettant de ne plus utiliser la vue materialisée
    t_adhesion  := ty_adhesion();
    t_action   := ty_action();
END BEFORE STATEMENT;

-- -- -- -- --
-- 2ème
-- -- -- -- --
BEFORE EACH ROW IS BEGIN

  -- incrémentation des tableau
  t_action.extend;
  t_adhesion.extend;

  -- alimentation tableau t_action pour traitement spécifique postérieur dans la section AFTER STATEMENT
  CASE
        WHEN INSERTING THEN
          t_action(t_action.last) := 'INSERTING';

    ELSE NULL;
  END CASE;

  -- alimentation tableau t_contact avec les nouvelles données de adhesion pour traitement spécifique postérieur dans la section AFTER STATEMENT
 t_adhesion(t_adhesion.last).NUMINDIV       := :new.NUMINDIV;
 t_adhesion(t_adhesion.last).NUMGAR         := :new.NUMGAR;
 t_adhesion(t_adhesion.last).NUMFOR         := :new.NUMFOR;
 t_adhesion(t_adhesion.last).DATAPLI        := :new.DATAPLI;
 t_adhesion(t_adhesion.last).DATPER         := :new.DATPER;
 t_adhesion(t_adhesion.last).RANG           := :new.RANG;
 t_adhesion(t_adhesion.last).ETAT           := :new.ETAT;
 t_adhesion(t_adhesion.last).UC             := :new.UC;
 t_adhesion(t_adhesion.last).FLAG_REGIME    := :new.FLAG_REGIME;
 t_adhesion(t_adhesion.last).REGIME         := :new.REGIME;
 t_adhesion(t_adhesion.last).TYPFOR         := :new.TYPFOR;
 t_adhesion(t_adhesion.last).NUMORG         := :new.NUMORG;
 t_adhesion(t_adhesion.last).DIS_CARENCE    := :new.DIS_CARENCE;
 t_adhesion(t_adhesion.last).DIS_FRANCHISE  := :new.DIS_FRANCHISE;
 t_adhesion(t_adhesion.last).IDADHESION     := :new.IDADHESION;
 t_adhesion(t_adhesion.last).NUMFOR_CARENCE := :new.NUMFOR_CARENCE;
 t_adhesion(t_adhesion.last).NUMUTIL        := :new.NUMUTIL;
 t_adhesion(t_adhesion.last).CREATION       := :new.CREATION;
 t_adhesion(t_adhesion.last).MAJ            := :new.MAJ;
 t_adhesion(t_adhesion.last).MOTIF          := :new.MOTIF;
 t_adhesion(t_adhesion.last).IDCOUVERTURE   := :new.IDCOUVERTURE;

END BEFORE EACH ROW;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AFTER STATEMENT IS

BEGIN
j := 0;
FOR j IN 1 .. t_adhesion.COUNT
  LOOP
  loc_envoi:=loc_envoi_init;
  loc_mail_exist:=0;
  loc_is_exist_before :=0; -- permet de verifier que l'individu n'a jamais été ajouté auparavant
  --on génère des mails uniquement s'il s'agit de nouvelle couverture santé non surco
  IF f_etat_adhe(t_adhesion(j).idadhesion, sysdate)<> 0 and  t_adhesion(j).typfor = 1 AND t_adhesion(j).rang=1 AND t_adhesion(j).datapli <= trunc(sysdate) THEN
  BEGIN
     -- verifie que l'assuré est vraiment un nouvel assuré en comptant les couvertures existantes
    SELECT count(idadhesion) INTO loc_is_exist_before
      FROM ADHESION  a, CONTRAT c
      WHERE numindiv = t_adhesion(j).numindiv
      --AND IDCOUVERTURE <>  t_adhesion(j).IDCOUVERTURE==> null
    AND c.numgar = a.numgar
    AND c.gest_prest = 1  --prestations gérées
    AND a.typfor = 1 --couverture santé
    AND a.rang=1 --non surco
    AND (sysdate BETWEEN a.datapli AND NVL(a.datper,sysdate) --couverture en cours
        OR (a.datper IS NOT NULL AND add_months(a.datper,6) > sysdate)  --couverture datant de moins de 6 mois
    --  OR (a.datapli> sysdate) --couverture dans le futur
      OR (a.datper is not null and a.maj > sysdate-7 )) ;--cloture de la garantie précedente datant de moins de 7 jours

  EXCEPTION WHEN NO_DATA_FOUND THEN
    loc_is_exist_before := 0;
  END;
  
  --ajout d'un bénéficiaire (11) ou ajout d'un adhérent(5)
  IF loc_is_exist_before <2 AND PK_MAIL.CHECK_DROIT_ENVOI_MAIL('BENE',t_adhesion(j).numutil) THEN

    BEGIN
      SELECT DISTINCT 1 INTO loc_is_adherent
      FROM ADHE_CNTRT
      WHERE   numadhe = t_adhesion(j).numindiv
      AND   idadhesion = t_adhesion(j).idadhesion ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      loc_envoi.IDTEXTE := 11;
    END;


   -- Recherche d'une couverture valide
    BEGIN
      SELECT  distinct adc.numadhe
      INTO  loc_envoi.NUMINDIV_DEST
      FROM ADHESION ad , adhe_cntrt adc, contrat c
      WHERE ad.idadhesion = t_adhesion(j).idadhesion
      AND adc.idadhesion = ad.idadhesion
      AND NOT EXISTS (SELECT clef FROM envoi_mail em WHERE em.numbene = t_adhesion(j).numindiv  and em.etendue = 2  and em.idtexte in (5,11)) --mail pas déjà envoyé
      AND ad.numindiv =  t_adhesion(j).numindiv
      AND c.numgar = adc.numgar
      AND c.gest_prest = 1  --prestations gérées
      AND ad.typfor = 1 --couverture santé
      AND ad.rang=1 --non surco
      AND (sysdate BETWEEN ad.datapli AND NVL(add_months(ad.datper,3),sysdate) OR ad.datapli > sysdate)
	  AND NOT EXISTS (select numindiv_dest FROM envoi_mail WHERE numindiv_dest = adc.numadhe and idtexte =5 and trunc(date_creation)>trunc(sysdate)-3);   --mail de Bienvenu
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      loc_envoi.NUMINDIV_DEST:=NULL;
  END;

  IF loc_envoi.NUMINDIV_DEST IS NOT NULL AND loc_envoi.IDTEXTE = 1  THEN -- cli le 10/01/2019 uniquement en cas d'ajout de bénéficiaire
      loc_envoi.CLEF := t_adhesion(j).idadhesion;
      loc_envoi.TYPE_MAIL :=1;          -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;
      loc_envoi.NUMBENE := t_adhesion(j).NUMINDIV;
      loc_envoi.NUMUTIL := t_adhesion(j).numutil;
      loc_envoi.ETENDUE := 2;           -- ADHESION
      loc_envoi.IDTEXTE := 11; 
      IF (PK_MAIL.CHECK_DROIT_ENVOI_MAIL('BENE',t_adhesion(j).numutil) AND PK_MAIL.CHECK_DEMAT_INDIV(loc_envoi.NUMINDIV_DEST) = 1) THEN
        PK_MAIL.CREER_MAIL(loc_envoi);
      END IF;
  END IF;

  END IF;
  END IF;
 END LOOP;
EXCEPTION
    WHEN OTHERS THEN
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'TRG_AI_ADHESION',
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  => 'WHEN OTHERS THEN : '|| SUBSTR(SQLERRM, 1, 100),
                                   I_idligne  => 2);






 END AFTER STATEMENT;
END;