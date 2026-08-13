CREATE TRIGGER ARTHUS.trg_bd_compte_client
before delete
on compte_client
for each row
     WHEN ( old.codope = 4 ) Declare	C_compte_tiers compte_tiers%Rowtype;
	mutating	exception;
	pragma exception_init(mutating, -4091);
Begin
	Begin
	Delete	qttc_affec
	Where	idaffec = :old.idaffec;
	Delete	qttc_affec_tfc
	Where	idaffec = :old.idaffec;
	Delete	idaffec_regul
	Where	idaffec = :old.idaffec;
	Delete	idaffec_attente
	Where	idaffec = :old.idaffec;
	End;
/*
	Begin
	Update	qttc_global
	Set	mt_affec = mt_affec - :old.montant
	Where	numquit = :old.numfact;
	Exception When Mutating then Null;
	End;
*/
	For C_compte_tiers IN (
		Select	idmvt
		From	compte_tiers
		Where	compte_tiers.codope = 4
		and	compte_tiers.cle = :old.idaffec )
	Loop
		Delete 	compensation
		Where	idcomp = C_compte_tiers.idmvt;
		Delete 	compensation
		Where	idmvt = C_compte_tiers.idmvt;
		Delete 	compte_tiers
		Where	idmvt = C_compte_tiers.idmvt;
	End Loop;
End;