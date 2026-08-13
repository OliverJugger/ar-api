CREATE PROCEDURE ARTHUS.p_levee_plafond_2019
IS
BEGIN
  -- levée des plafond optiques à effectuer à 8h30 du lundi au vendredi
  update maxact set nbactes=2 where nbactes=1 and codfrais in('OPD4','MONT') ;
  update maxact set nbactes=4 where nbactes=2 and codfrais in('H1','H2','H3','H4','H5','H7','H8','VER1') ;
  commit;
END p_levee_plafond_2019;
/
