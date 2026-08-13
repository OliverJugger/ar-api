CREATE function ARTHUS.F_trace_usrxit
RETURN VARCHAR2
IS
l_retour parametres.trace%type;

BEGIN
  select trace
  into l_retour
  from parametres;

  if (l_retour is null) then
  		l_retour := 'notest';
  end if;

  return l_retour;
END F_trace_usrxit;
