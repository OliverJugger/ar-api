CREATE function ARTHUS.f_get_instance return varchar2 is

o_instance parametres.instance%type;

begin
   select instance
   into o_instance
   from parametres;
   return o_instance;

end f_get_instance ;
