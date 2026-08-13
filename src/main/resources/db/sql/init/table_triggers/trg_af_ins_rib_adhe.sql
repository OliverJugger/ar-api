CREATE TRIGGER ARTHUS.trg_af_ins_rib_adhe
   AFTER INSERT
   ON RIB_ADHE
   FOR EACH ROW






DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
BEGIN
Insert Into Histo_Rib_Adhe (
	Idadhesion,
	Idrib,
	Type,
	Creation,
	Createur)
Values (
	:new.idadhesion,
	:new.idrib,
	:new.type,
	Sysdate,
	f_numutil
	);
END;