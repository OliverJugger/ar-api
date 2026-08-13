-- Recompilation des objets INVALID du schema ARTHUS.
-- A executer en dernier : les vues creees en CREATE FORCE et les package bodies
-- dont les dependances n'existaient pas encore sont INVALID a ce stade.
BEGIN
  UTL_RECOMP.recomp_serial('ARTHUS');
END;
/
