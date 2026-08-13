CREATE TRIGGER ARTHUS.trg_au_qttc_global
after update of datemis, prelev, mt_affec
on qttc_global
for each row






begin
	if (:new.datemis != :old.datemis) then
		update	facture
		set	datfact = :new.datemis
		where	facture.codope = 4
		and	facture.numfact = :new.numquit
		;
	end if;
	If ( nvl(:new.mt_affec, 0) != nvl(:old.mt_affec, 0) ) then
		If ( :new.idadhesion != 0 ) then
			Ins_histo_export( 37, :new.idadhesion );
		End if;
	End if;
Exception When No_data_found then null;
end;