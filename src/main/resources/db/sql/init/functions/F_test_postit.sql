CREATE Function ARTHUS.F_test_postit(a_etendue in number,a_clef in number)
return number
is
--
  /* Test_bloc_note(etendue,clef,champ) */
--
     result number;

begin

   select distinct 1
   into result
   from post_it
   where etendue = a_etendue
   and   clef = a_clef;

   return 1;

   exception when no_data_found then
        return 0;

END F_test_postit;
