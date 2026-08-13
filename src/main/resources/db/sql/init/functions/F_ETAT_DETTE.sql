CREATE FUNCTION ARTHUS."F_ETAT_DETTE" (
				a_iddette	In Number,
				a_codope	In Number,
				a_numcli	In Number,
				a_retour	In Number Default 1
				)
Return Number
Is
 -- Variable de reconnaissance SCCS
 -- %W%    %E%
loc_retour	Number := 0;
loc_numdecaismt	Number;
loc_numaffec	Number;
loc_objet	Binary_integer;
L_idmvt		compte_tiers.idmvt%Type;
L_montant	compte_tiers.montant%Type;
Cursor C_regle IS
	Select	affectation.numdecaismt,
		affectation.numaffec
	From	affectation,
		compte_tiers	debit,
		compensation,
		compte_tiers,
		decompte
	Where	affectation.codope = 10
	and	affectation.numaffec = debit.cle
	and	debit.codope = 10
	and	debit.idmvt = compensation.idcomp
	and	compensation.idmvt = compte_tiers.idmvt
	and	compte_tiers.codope = a_codope
	and	compte_tiers.cle = decompte.numdec
	and	decompte.numdcptcie = a_iddette
	and	decompte.montant > 0;
--
Cursor C_compens IS
	Select	Sum( f_contrepartie(compte_tiers.idmvt) ) 	contrepartie,
		Sum( compte_tiers.montant )			montant
	From	compte_tiers,
		decompte
	Where	compte_tiers.codope = a_codope
	and	compte_tiers.cle = decompte.numdec
	and	decompte.numdcptcie = a_iddette
	and	decompte.montant > 0
	and EXISTS (
		Select	1
		from	compensation
		where	compensation.idmvt = compte_tiers.idmvt
		);
--
Cursor C_valide IS
	Select	3
	From	compte_tiers,
		decompte
	Where	compte_tiers.codope = a_codope
	and	compte_tiers.cle = decompte.numdec
	and	decompte.numdcptcie = a_iddette
	and	decompte.montant > 0;
--	and NOT EXISTS (
	--	Select	1
	--	from	compensation
	--	where	compensation.idmvt = compte_tiers.idmvt
	--	);
--
-- Cas en09 - Remboursement des Presta.(gestion des bdx)
Cursor C_en09_SS IS
	SELECT ALL FACTURE.ECHEANCE
		FROM SINISTRE_SANTE, FACTURE
		WHERE (SINISTRE_SANTE.NUMFACT = a_iddette
		 AND FACTURE.CODOPE = 12)
		 AND (SINISTRE_SANTE.NUMFACT = FACTURE.NUMFACT);
--


Cursor C_regle_prev IS
	Select affectation.numdecaismt,
         affectation.numaffec
	From affectation,
       compte_tiers	debit,
       compensation,
       compte_tiers,
       decompte_prev
	Where	affectation.codope = 10
	and	affectation.numaffec = debit.cle
	and	debit.codope = 10
	and	debit.idmvt = compensation.idcomp
	and	compensation.idmvt = compte_tiers.idmvt
	and	compte_tiers.codope = a_codope
	and	compte_tiers.cle = decompte_prev.numdec
	and	decompte_prev.numdcptcie = a_iddette
	and	decompte_prev.montant > 0;
--
Cursor c_dette_prev IS
  Select etat
  From dette_prev
  Where iddette = a_iddette;

Rec_C_en09_SS	C_en09_ss%Rowtype;
--
Rec_C_valide	C_valide%Rowtype;
Rec_C_compens	C_compens%Rowtype;
Rec_C_regle		C_regle%Rowtype;
--
Rec_C_regle_prev   C_regle_prev%Rowtype;
Rec_C_dette_prev   C_dette_prev%Rowtype;
--
BEGIN

If ( a_codope = 17 ) then
  -- XHU le 13/01/2011 : Ajout gestion de l'opétation 17
  If a_retour in (2,3) then
     Open C_regle_prev;
     Fetch C_regle_prev Into Rec_C_regle_prev;
     Close C_regle_prev;
     If a_retour = 2 then
        Return(Rec_C_regle_prev.numaffec);
     ElsIf a_retour = 3 then
        Return(Rec_C_regle_prev.numdecaismt);
     End if;
  End if;

  Open C_dette_prev;
  Fetch C_dette_prev Into Rec_C_dette_prev;
  Close C_dette_prev;
  loc_retour := Rec_C_dette_prev.etat;

Elsif ( a_codope = 14 ) then
	Open C_regle;
	Fetch C_regle Into Rec_C_regle;
	If ( C_regle%Found ) then
		Close C_regle;
		If ( a_retour = 2 ) then
			Return( Rec_C_regle.numaffec );
		ElsIf ( a_retour = 3 ) then
			Return( Rec_C_regle.numdecaismt );
		End if;
		--
		If ( Rec_C_regle.numdecaismt is not null ) then
			loc_retour := 5;
		Else
			loc_retour := 4;
		End if;
	Else
		Close C_regle;
		--
		Open C_compens;
		Fetch C_compens Into Rec_C_compens;
		Close C_compens;
		--
		If ( Abs(Rec_C_compens.contrepartie) =
			Abs(Rec_C_compens.montant) ) then
			loc_retour := 5;
		Else
			Open C_valide;
			Fetch C_valide Into Rec_C_valide;
			If ( C_valide%Found ) then
				Close C_valide;
				loc_retour := 3;
			Else
				Close C_valide;
				--
				Begin
				Select	2
				Into	loc_retour
				From	Dual
				Where Exists (
					Select	1
					From	sinistre
					Where	numdec 		= -1
					and	numindiv + 0 	= a_numcli
					and	num_fact	= a_iddette);
				Exception When No_data_found then
					loc_retour := 1;
				End;
			End if;
		End If;
	End If;
ElsIf ( a_codope = 15 ) then
	Begin
	Select	affectation.numdecaismt,
		affectation.numaffec
	Into	loc_numdecaismt,
		loc_numaffec
	From	affectation,
		compensation,
		compte_tiers,
		compte_tiers	debit
	Where	affectation.codope = 10
	and	affectation.numaffec = debit.cle
	and	debit.codope = 10
	and	debit.idmvt = compensation.idcomp
	and	compensation.idmvt = compte_tiers.idmvt
	and	compte_tiers.codope = a_codope
	and	compte_tiers.cle = a_iddette;
	If ( a_retour = 2 ) then
		Return( loc_numaffec );
	ElsIf ( a_retour = 3 ) then
		Return( loc_numdecaismt );
	End if;
	If ( loc_numdecaismt is not null ) then
		loc_retour := 5;
	Else
		loc_retour := 4;
	End if;
	Exception
	When Too_many_rows then Return( 0 );
	When No_data_found then
		Begin
		Select	3
		Into	loc_retour
		From	compte_tiers
		Where	codope = a_codope
		and	cle = a_iddette;
		Exception When No_data_found then
			loc_retour := 1;
		End;
	End;
-- Cas en09 - Remboursement des Presta.(gestion des bdx)
ElsIf ( a_codope = 12 ) then
	BEGIN
		Open C_en09_SS;
		Fetch C_en09_SS INTO REC_C_en09_SS;
		IF C_en09_SS%FOUND THEN
			Close C_en09_SS;
			IF REC_C_en09_SS.ECHEANCE IS NULL
			THEN
				Loc_Retour := 2; -- (En cours)
			ELSE
				Loc_Retour := 3; -- (Validée)
			END IF;
		ELSE
			Close C_en09_SS;
			Loc_Retour := 1; --(Aucun numfact trouvé - Non Traité)
		END IF;
	EXCEPTION
		When others then Loc_Retour := 1; --(Aucun numfact trouvé - Non Traité)
	END;
End if;
Return ( loc_retour );
END	f_etat_dette;
