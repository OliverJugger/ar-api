CREATE procedure ARTHUS.p_error_flux IS

  CURSOR C_flux IS
  select f.id_type,f.id_flux , to_char(dat_maj,'dd/mm/yyyy  hh24:mi:ss') , t.num_porte, T.Lib_Service,
  trunc((mod(trunc( (sysdate-dat_maj) *60*60*24),86400))/60) ecart,
  to_char( to_date(mod(trunc( (sysdate-dat_maj) *60*60*24),86400) ,'sssss'),'hh24"h" mi"min" ') ecart_hh
  from flux f , type_flux t
  where t.id_type = f.id_type
  and t.num_porte=25
  AND dat_maj > sysdate-1
  order by 2 desc;


   loc_envoi envoi_mail%ROWTYPE;
  l_ERROR   VARCHAR2(200);
  text  CLOB;
  list_email varchar(4000) :='';
  list_email_unit varchar(1000) :='';
  l_nom_machine  param_machine.nom_machine%type;
  loc_bdd varchar2(20);
  i number :=1;
  loc_heure number;
  loc_min   number;
begin
  SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
  SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;

  FOR REC_flux IN C_flux LOOP
    IF (REC_flux.ecart > 15 AND loc_heure>=8 AND loc_heure<=19 )
       OR ( REC_flux.ecart > 60 AND loc_min <15 AND ((loc_heure>19 AND loc_heure<=23) OR (loc_heure>=0 AND  loc_heure<=4))) THEN

      SELECT 1, 1, compte_mail
      INTO loc_envoi.NUMINDIV_DEST, loc_envoi.NUMBENE, loc_envoi.destinataire
      FROM param_machine
      WHERE id_machine= 'SERVEUR_MAIL';

      SELECT nom_machine into l_nom_machine
      FROM param_machine
      WHERE ID_MACHINE = 'SERVEUR_BDD';

      SELECT instance INTO loc_bdd
      FROM parametres;


      loc_envoi.sujet :='[URGENT '||loc_bdd||'] Aucune demande depuis = '||REC_flux.ecart_hh ||', le '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') ;
      loc_envoi.corps := null;

      GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
      PK_MAIL.transcode_template( template_mail=>text,
                                  corps_msg =>loc_envoi.corps,
                                  numindiv=>'',
                                  numbene=>'',
                                  sujet_msg =>loc_envoi.sujet);
      pk_mail.SEND_EMAIL(
      P_RECIPIENT     =>'Support@arthus-progiciels.com',
      P_CC            => null,
      P_BCC           => null,
      P_SUBJECT       => loc_envoi.sujet,
      P_BODY          =>text,
      P_NUMUTIL       =>8,
      P_SENDER        => 'nepasrepondre@gerep.fr',      
      P_numindiv_dest => 1,
      P_ERROR        => l_ERROR);

    END IF;
    EXIT;
  END LOOP;

  exception
  when others then Dbms_Output.Put_Line(SQLERRM);

END p_error_flux;
/
