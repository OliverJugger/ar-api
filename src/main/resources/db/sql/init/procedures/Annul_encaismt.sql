CREATE procedure ARTHUS.Annul_encaismt (
				a_numencaismt 	in Number
				)
Is
	dummy			number;
Cursor fetch_objet is
	select	idaffec,
		codope
	from	compte_client
	where	compte_client.numencaismt = a_numencaismt;
loc_objet	fetch_objet%Rowtype;
BEGIN
For loc_objet in fetch_objet
Loop
Delete 	qttc_affec
	where	idaffec = loc_objet.idaffec;
Delete	qttc_affec_tfc
	where	idaffec = loc_objet.idaffec;
Delete	compte_client
	where	idaffec = loc_objet.idaffec;
End Loop;
Delete	 encaismt
	 where	numencaismt = a_numencaismt;
Delete	remise_banque
	where	numencaismt = a_numencaismt;
END;
/
