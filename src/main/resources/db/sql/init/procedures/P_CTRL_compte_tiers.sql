CREATE procedure ARTHUS.P_CTRL_compte_tiers (
	I_numencaismt	IN  encaismt.numencaismt%Type Default Null
	)
IS
Cursor C_encais IS
	Select	encaismt.numencaismt,
		encaismt.datpay,
		encaismt.montant,
		encaismt.numcli,
		compte_tiers.idmvt
	From	compte_tiers,
		encaismt
	Where	compte_tiers.codope = 10
	and	compte_tiers.cle = encaismt.numencaismt
	and	encaismt.codope = 10
	and	encaismt.numencaismt = nvl(I_numencaismt, encaismt.numencaismt)
	;
Cursor C_tiers ( P_idmvt IN compte_tiers.idmvt%Type ) IS
	Select	compte_tiers.codope,
		compte_tiers.cle,
		compte_tiers.idmvt,
		compte_tiers.sens,
		compte_tiers.datope,
		compte_tiers.montant
	From	compte_tiers,
		compensation
	Where	compte_tiers.idmvt = compensation.idcomp
	and	compensation.idmvt = P_idmvt
	and	codope + 0 = 4;
Cursor C_cotis ( P_idaffec IN compte_client.idaffec%Type ) IS
	Select	compte_client.numfact,
		compte_client.codope,
		compte_client.montant
	From	compte_client
	Where	compte_client.idaffec = P_idaffec
	and Not Exists (
		Select	1
		From	one_shot
		Where	one_shot.numquit = compte_client.numfact
		);
Cursor C_comm ( P_idaffec IN compte_client.idaffec%Type ) IS
	Select	Sum(nvl(montant,0))	montant,
		numbene
	From	qttc_affec_tfc
	Where	idaffec = P_idaffec
	and	tfc = 5
	and	prelev_revers = 1
	Group By
		numbene;
Cursor C_retro (
	P_numquit IN qttc_retro.numquit%Type,
	P_numbene IN qttc_retro.numbene%Type
	)
	IS
	Select	Sum(montant)	montant
	From	qttc_retro
	Where	numquit = P_numquit
	and	numbene = P_numbene
	and	prelev_revers = 1;
Rec_C_encais	C_encais%Rowtype;
Rec_C_tiers	C_tiers%Rowtype;
Rec_C_cotis	C_cotis%Rowtype;
Rec_C_comm	C_comm%Rowtype;
L_tot_retro	Number;
L_mt_comm	Number;
L_mt_retro	Number;
Flag_init	Boolean := TRUE;
Flag_one_shot	Boolean := FALSE;
BEGIN
--
Delete one_shot;
Delete ano_compte_tiers;
--
Open C_encais;
Loop
	Fetch C_encais Into Rec_C_encais;
	Exit When C_encais%NotFound;
	Open C_tiers( Rec_C_encais.idmvt );
	Loop
		Fetch C_tiers Into Rec_C_tiers;
		Exit When C_tiers%NotFound;
		-- Dbms_output.put_line( 'Idaffec ' || Rec_C_tiers.cle);
		Flag_one_shot := TRUE;
		Open C_cotis( Rec_C_tiers.cle );
		Fetch C_cotis Into Rec_C_cotis;
		If ( C_cotis%NotFound ) then
			Flag_one_shot := FALSE;
			/*
			Dbms_output.put_line( 'Compte client non trouve pour '
			|| Rec_C_tiers.cle || ' codope '
			|| Rec_C_tiers.codope );
			*/
		Else
			Rec_C_comm.montant := 0;
			Open C_comm( Rec_C_tiers.cle );
			Fetch C_comm Into Rec_C_comm;
			Close C_comm;
		End if;
		Close C_cotis;
		--
		If ( Flag_init ) then
			L_mt_retro := 0;
			Open C_retro(Rec_C_cotis.numfact, Rec_C_encais.numcli);
			Fetch C_retro Into L_mt_retro;
			Close C_retro;
			--
			If ( Abs(Rec_C_cotis.montant - L_mt_retro
				- Rec_C_tiers.montant) between 0 and .02 ) then
				Insert Into one_shot values (
					Rec_C_cotis.numfact,
					Rec_C_tiers.cle);
			End if;
		End if;
		--
		L_tot_retro := (-Rec_C_tiers.sens*Rec_C_tiers.montant) + L_mt_retro;
		L_mt_comm := (-Rec_C_tiers.sens*Rec_C_tiers.montant) + nvl(Rec_C_comm.montant, 0);
		If ( L_mt_comm != Rec_C_cotis.montant and Rec_C_tiers.codope = 4) then
		If ( Rec_C_encais.numcli = Rec_C_comm.numbene and Flag_one_shot ) then
		If ( Abs(L_mt_comm - Rec_C_cotis.montant) > .02 ) then
			Insert Into ano_compte_tiers (
				Numencaismt,
				Numcli,
				Numquit,
				Mt_Affec,
				Mt_Comm,
				Mt_Tiers
				)
			Values (
				Rec_C_encais.numencaismt,
				Rec_C_encais.numcli,
				Rec_C_cotis.numfact,
				Rec_C_cotis.montant,
				Nvl(Rec_C_comm.montant, 0),
				-Rec_C_tiers.sens*Rec_C_tiers.montant
				);
		--
		Dbms_output.put_line( '-----------------------------------------------------------------------------' );
		Dbms_output.put_line( 'Encaissement '
			|| Rec_C_encais.numencaismt
			|| ' du ' || d2e(Rec_C_encais.datpay)
			|| ' Tiers ' || Rec_C_encais.numcli
			|| ' Montant ' || Rec_C_encais.montant);
		--
			Dbms_output.put_line( 'Mouvement ' || Rec_C_tiers.idmvt
			|| ' du ' || Rec_C_tiers.datope
			|| ' montant ' || -Rec_C_tiers.sens*Rec_C_tiers.montant
			|| ' comm ' || Nvl(Rec_C_comm.montant, 0)
			|| ' Mt + comm ' || L_mt_comm
			|| ' affectation ' || Rec_C_cotis.montant
			|| ' idaffec ' || Rec_C_tiers.cle
			|| ' numquit ' || Rec_C_cotis.numfact
			|| ' Mt + retro ' || L_tot_retro);
		End if;
		End if;
		End if;
		--
	End Loop;
	Close C_tiers;
End Loop;
Close C_encais;
END;
/
