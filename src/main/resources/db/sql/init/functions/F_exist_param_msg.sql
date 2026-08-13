CREATE Function ARTHUS.F_exist_param_msg (a_id_msg in message_entete.id_msg%type,
                           a_numgar in message_param.id_contexte_msg%type,
a_contexte in message_param.contexte_msg%type)
  return boolean
 is
  L_retour boolean := true;
  nb_enreg number := 0;
  BEGIN
    select count (*) into nb_enreg
    from message_param
    where id_msg = a_id_msg
    and id_contexte_msg = a_numgar
    and contexte_msg = 2;
  if (nb_enreg >0) then
  L_retour := true;
  else
  L_retour := false;
  end if;
  return (L_retour);
  END;
