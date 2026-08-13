CREATE PROCEDURE ARTHUS."P_ENVOI_MAIL_BATCH" (io_sujet IN OUT VARCHAR2, io_corps IN OUT CLOB,io_sender IN OUT VARCHAR2, io_journal IN OUT journal_adm%ROWTYPE, o_erreur OUT VARCHAR2 )  IS
-- $Rev:: 839                                    $:  Revision du dernier commit
-- $Author:: b.cortial                           $:  Auteur du dernier commit
-- $Date: 2023-09-20 17:02:14 +0200 (mer., 20 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PROCEDURES/P_ENVOI_MAIL_BATCH.sql $:  Chemin


  loc_contenu         CLOB;
  l_nom_machine       param_machine.nom_machine%type;
  l_destinataire      CLOB;
  flag_mail_vide      BOOLEAN;

  CURSOR c_mails IS
  SELECT *
  from auto_flux
  where nomtrt = io_journal.nom_traitement
  and envoi_mail = 0
  and trunc(dattrt) = trunc(sysdate)
  AND idsession =io_journal.id_session
  order by id_auto_flux   -- ajout ordre de tri sur séquence
  FOR UPDATE OF envoi_mail;

  CURSOR C_mailBatch IS
  SELECT MAIL
  FROM TYP_BATCH_MAIL
  WHERE numbatch = io_journal.nom_traitement;

  BEGIN
      -- Init
      o_erreur := NULL;
      -- recherche des destinataires dans la nouvelle table typ_batch_mail
      FOR R_mailBatch IN C_mailBatch LOOP
        l_destinataire   := l_destinataire||', <'||R_mailBatch.mail||'>';
        --l_destinataire7 := '<c.vayres@gerep.fr>';
        --l_destinataire4||', '||l_destinataire5||', '||l_destinataire6||', '||l_destinataire7
      END LOOP;
      l_destinataire := substr(l_destinataire,3);--to revoir la 1ère virgule ?

      IF l_destinataire IS NULL THEN
        o_erreur:='Erreur technique d''envoi mail : destinataire inconnu';
        RETURN;
      ELSIF io_sender IS NULL THEN
       SELECT NVL(f_coordonne_contact(interlocuteur,4,2),f_coordonne_contact(interlocuteur,4,1))
        INTO io_sender
        FROM interlocuteur where NUMINDIV=1
        AND OPE_CRRR = 0;
      END IF;

      IF io_sender IS NULL THEN
        o_erreur:='Erreur technique d''envoi mail : mail de l''expéditeur inconnu';
        RETURN;
      END IF;

      SELECT instance INTO l_nom_machine
      FROM parametres;
      io_sujet:= replace(io_sujet,'#INSTANCE',l_nom_machine);

      --concaténation du contenu du mail
      flag_mail_vide := TRUE;
      FOR rec_mails IN c_mails LOOP
        flag_mail_vide := FALSE;
        io_corps :=  io_corps ||'-- '||rec_mails.message||CHR(10)||CHR(13) ;
        UPDATE auto_flux set envoi_mail = 1 WHERE CURRENT OF c_mails;
      END LOOP;

      -- Pas d'envoi de mail si le contenu est vide
      IF flag_mail_vide THEN
        RETURN;
      END IF;

      GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', loc_contenu);
      PK_MAIL.transcode_template( template_mail=> loc_contenu,
                                  corps_msg => io_corps,
                                  numindiv=>'',
                                  numbene=>'',
                                  sujet_msg =>io_sujet);
      pk_mail.SEND_EMAIL(
      P_RECIPIENT     => l_destinataire ,
      P_CC            => null,
      P_BCC           => null,
      P_SUBJECT       => io_sujet,
      P_BODY          => loc_contenu,
      P_NUMUTIL       => f_numutil,
      P_SENDER        => io_sender,
      P_numindiv_dest=> null,
      P_ERROR        => o_erreur);

      IF o_erreur IS NULL THEN
        UPDATE auto_flux set envoi_mail = 1
        WHERE nomtrt = io_journal.nom_traitement
        AND envoi_mail = 0
        AND idsession =io_journal.id_session;
      END IF;

  EXCEPTION
      WHEN  OTHERS THEN
       o_erreur:='Erreur technique d''envoi mail : '||SQLERRM;
  END P_ENVOI_MAIL_BATCH;
/
