CREATE TRIGGER ARTHUS.Trg_af_del_adhesion
   AFTER DELETE ON Adhesion
   FOR EACH ROW
DECLARE
   --
	CST_SCCS     CONSTANT VARCHAR2(120) := '@(#)trg_af_del_adhesion.sql	1.4    03/11/20';

BEGIN

	Delete	beneficiaire
	Where	idadhesion 	= :old.idadhesion
	and		numfor 		= :old.numfor
	and		numindiv 	= :old.numindiv;

	Delete	control_adhesion
	Where	idadhesion 	= :old.idadhesion
	and		numfor 		= :old.numfor
	and		numindiv 	= :old.numindiv;
END;