CREATE PROCEDURE ARTHUS.p_remise_plafond
IS
BEGIN
  -- remise en place des plafond optiques à effectuer à 8h30 du lundi au vendredi
  update maxact set nbactes = 1
  where nbactes=2
  and codfrais in (
  select codfrais from ntfrs_detail where monture=1 )
  and nummath_c IN (1200,1201)
  and sysdate between datapli AND NVL(datper,sysdate)
  ;

  update maxact set nbactes = 2
  where nbactes=4
  and codfrais in (
  select codfrais from ntfrs_detail where verre=1 )
  and nummath_c IN (1200,1201)
  and sysdate between datapli AND NVL(datper,sysdate)
  ;
  commit;
END p_remise_plafond;
/
