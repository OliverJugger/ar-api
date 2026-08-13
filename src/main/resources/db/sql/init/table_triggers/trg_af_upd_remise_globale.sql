CREATE TRIGGER ARTHUS.trg_af_upd_remise_globale
After Update of daterem, valide
on remise_globale
FOR EACH ROW
    WHEN ( new.valide = 'O' ) DECLARE
CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
Cursor C_encais IS
	Select	numencaismt,
		codope
	From	encaismt
	Where 	numencaismt IN (
		select	numencaismt
		from	remise_banque
		Where	remise_banque.numremise = :new.numremise
		);
--
Rec_C_encais	C_encais%Rowtype;
BEGIN
Open C_encais;
Loop
	Fetch C_encais Into Rec_C_encais;
	Exit When C_encais%NotFound;
	If ( Rec_C_encais.codope = 10 ) then
		Update	compte_tiers
		Set	datope = :new.daterem
		Where	codope = 10
		and 	cle = Rec_C_encais.numencaismt;
	Else
		Update	compte_client
		Set	datope = :new.daterem
		Where	codope + 0 = 8
		and	numfact IS Null
		and	numencaismt = Rec_C_encais.numencaismt;
	End if;
End Loop;
Close C_encais;
END;