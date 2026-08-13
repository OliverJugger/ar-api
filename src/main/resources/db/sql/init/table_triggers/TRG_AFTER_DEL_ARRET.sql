CREATE TRIGGER ARTHUS.TRG_AFTER_DEL_ARRET
AFTER DELETE ON ARRET FOR EACH ROW
BEGIN
 -- suppression du lien avec une declaration prestij
update prest_ij
set idarret = null
where idarret = :old.idarret;

END;