CREATE TRIGGER ARTHUS.trg_bf_del_result_reass
Before Delete
On result_reass
FOR EACH ROW






DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '@(#)trg_bf_del_result_reass.sql	1.2    01/07/03';
BEGIN
pk_reassurance.P_DEL_result_reass (
		I_idglob	=> :old.idglob,
		I_debut		=> :old.dtdebut,
		I_fin		=> :old.dtfin
		);
--
Delete	result_reass_detail
Where	idglob = :old.idglob;
--
END;