CREATE TRIGGER ARTHUS.Trg_af_upd_adhesion2
   AFTER UPDATE OF Datper ON Adhesion
   FOR EACH ROW






BEGIN
update	control_adhesion
set	datper = :new.datper
where 	idadhesion = :old.idadhesion
and 	numfor = :old.numfor
and	numgar = :old.numgar
and 	numindiv = :old.numindiv;
/*
update 	porte_adhesion
set	fin = :new.datper
where   idporte = (select max(idporte)
		 from demande_tp
		 where numindiv = :old.numindiv
		 and idparam_tp = (select idparam_tp
   				   from gar_param_tp
				   where numfor = :old.numfor)
                 );
*/
END;