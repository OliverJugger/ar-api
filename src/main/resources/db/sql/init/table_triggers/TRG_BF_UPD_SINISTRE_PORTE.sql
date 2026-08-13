CREATE TRIGGER ARTHUS.TRG_BF_UPD_SINISTRE_PORTE BEFORE UPDATE OF NOE_QUALIF ON SINISTRE_PORTE
FOR EACH ROW




DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '@(#)trg_bf_upd_sinistre_porte.sql	1.2    01/02/16';
begin
if ((:old.noe_qualif != :new.noe_qualif) or :old.noe_qualif is null) then
/* Noemie : Honoraires globalises	*/
if (:new.noe_qualif = 'SD') then
	pk_noemie.P_INS_sinistre_ano(
		I_numporte	=> :new.numporte,
		I_numano	=> 59,
		I_numsin	=> :new.numsin,
		I_datano	=> Trunc(sysdate),
		I_etatano	=> 1,
		I_numremise	=> :new.numremise);
	if :old.etat != 4 then :new.etat := 3 ;
	end if;
elsif (:new.noe_qualif = 'SN') then
	pk_noemie.P_INS_sinistre_ano(
		I_numporte	=> :new.numporte,
		I_numano	=> 60,
		I_numsin	=> :new.numsin,
		I_datano	=> Trunc(sysdate),
		I_etatano	=> 1,
		I_numremise	=> :new.numremise);
	if :old.etat != 4 then
		/* Retablissement des frais reels */
		:new.mtfrais := :new.baseremb;
		/* Si pas d'autre anomalie on remet a calculer */
		Begin
		Select	2
		Into	:new.etat
		From	Dual
		Where Not Exists (
			select	1
			from	sinistre_ano
			where	numremise = :new.numremise
			and	numsin = :new.numsin
			and	numano not in (56, 60) );
		Exception When No_data_found then Null;
		End;
	end if;
end if;
end if;
end;