CREATE TRIGGER ARTHUS.trg_bu_remise_externe
Before 	update of date_trans
On 	remise_externe
For 	each row
   WHEN ( (old.date_trans is not null) and (new.date_trans is null) ) BEGIN
Begin
Update 	porte_adhesion
Set	transmis = 2
Where	transmis = 1
and	numremise = :old.numremise;

Update 	demande_tiers_payant
Set 	transmis=2,datedit=''
where	numremise = :old.numremise;

Exception when No_data_found then null;
End;
END;