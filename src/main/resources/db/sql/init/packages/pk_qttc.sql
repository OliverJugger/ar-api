CREATE OR REPLACE PACKAGE ARTHUS.pk_qttc AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%

-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --

-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --

-- -- TYPES PUBLIQUES ---------------------------------------------------------
-- Aucun
-- ------------------------------------------------- Fin des types publiques --

-- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --

-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--@pub
--
-- Retourne la date d'affectation a appliquer selon parametres de cloture
--
Procedure P_SEL_dataffec (
		I_numencaismt	IN  encaismt.numencaismt%Type,
		O_dataffec	OUT Number
		);
--
Procedure P_INS_compte_tiers (
			I_idaffec	IN	compte_client.idaffec%Type,
			I_numfact	IN	compte_client.numfact%Type,
			I_numfact_regul	IN	compte_client.numfact%Type,
			I_numencaismt	IN	compte_client.numencaismt%Type,
			I_numcli	IN	compte_client.numcli%Type,
			I_montant	IN	compte_client.montant%Type,
			I_montant_d	IN	compte_client.montant_d%Type,
			I_monnaie	IN	compte_client.monnaie%Type,
			I_monnaie_d	IN	compte_client.monnaie_d%Type,
			I_datope	IN	Date Default Trunc(Sysdate),
			I_idaffec_regul	IN	compte_client.idaffec%Type
			);
Procedure P_INS_solde_regul (
			I_idaffec	IN	compte_client.idaffec%Type,
			I_numcli	IN	compte_client.numcli%Type,
			I_numfact	IN	compte_client.numfact%Type,
			I_numencaismt	IN	compte_client.numencaismt%Type,
			I_montant	IN	compte_client.montant%Type,
			I_montant_d	IN	compte_client.montant_d%Type,
			I_monnaie	IN	compte_client.monnaie%Type,
			I_monnaie_d	IN	compte_client.monnaie_d%Type,
			I_numquit	IN	qttc_global.numquit%Type,
			I_datope	IN	Date Default Trunc(Sysdate)
			);
Procedure P_DEL_variable_a_blanc (
			I_numquit	IN	qttc_global.numquit%Type,
			I_type_qttc	IN	qttc_global.type_qttc%Type,
			I_numgar	IN	qttc_global.numgar%Type,
			I_idadhesion	IN	qttc_global.idadhesion%Type,
			I_debut		IN	Date,
			I_fin		IN	Date
			);
--
PROCEDURE P_DEL_previsionnel ( I_etendue IN  qttc_global.etendue%TYPE,
                               I_cle     IN  qttc_global.numgar%TYPE);
--
PROCEDURE P_MAJ_echesuiv ( I_etendue    IN qttc_global.etendue%TYPE,
                           I_cle	IN qttc_global.numgar%TYPE);
--
Function F_SEL_numfor (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number;

Function F_SEL_numfor2 (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number;

Function F_SEL_grpnumfor (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number;

-- renvoie le numgar de reference - contrat -
Function F_SEL_numgar (
		I_numgar	IN contrat_ref.numgar%Type
		)
Return Number;

Function F_SEL_natcalc (
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number;
-- Retourne le nonbre de virgules a utilisée pour le round appliqué à F_prorata dabs le calul des cotis
-- 1, 2, ... ou 99 pour pas de round.
Function F_sel_arrondi_prorata (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number;

PROCEDURE P_MAJ_DEV (I_numquit	IN	qttc_global.numquit%Type);
PROCEDURE P_MAJ_DEV_full;


-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_qttc AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%

-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --

-- -- Declaration des procedures privees ---------------------------------------
--@priv
--
-- Retourne la date de reference d'un encaissement
--
Procedure P_SEL_datencaismt (
		I_numencaismt	IN  encaismt.numencaismt%Type,
		O_datencaismt	OUT Date,
		O_numsoc	OUT compte.numsoc%Type
		);
--
-- Retourne le montant calcule d'une cotisation
--
Function F_montant_global (
		I_numquit	IN qttc_global.numquit%Type
		)
Return Number;
--
-- Test s'il y a eu commission prelevee sur la cotisation
-- Si I_numbene = 0 -> pas du tout de comm
-- Si I_numbene != 0 -> comm prelevee sur autre tiers
--
Function F_EXIST_retro (
		I_numquit	IN qttc_retro.numquit%Type,
		I_numbene	IN qttc_retro.numbene%Type
		)
Return Boolean;
--
-- -- CORPS DES PROCEDURES PRIVEES ---------------------------------------------
--@corpriv
-- Retourne la nature d'appel sur une garantie (NAT_CALC) Si null, renvoie 1 a blanc
Function F_SEL_natcalc (
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number
IS
Cursor C_formule IS
	Select	nat_calc
	From	formule
	Where	numfor = I_numfor;
Cursor C_garanties IS
	Select	nat_calc
	From	garanties
	Where	numfor = I_numfor;

Dummy		Number;
L_natcalc	Number := 1;

BEGIN

Open	C_formule;
Fetch C_formule into Dummy;
If (C_formule%found) then
	L_natcalc := Dummy;
Else
	Open C_garanties;
	Fetch C_garanties Into L_natcalc;
	If (C_garanties%NotFound) then
		L_natcalc := 1;
	    Close C_garanties;
	End if;
End if;
Close C_formule;
--
Return(L_natcalc);

END F_SEL_natcalc;



Function F_SEL_numfor (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number
IS
Cursor C_contrat_ref IS
	Select	1
	From	contrat_ref
	Where	numgar = I_numgar;
Cursor C_collective IS
	Select	adhe_coll_gar.numfor_ref
	From	adhe_collective,
		adhe_coll_gar
	Where	adhe_collective.numgar = adhe_coll_gar.numgar
	and	adhe_coll_gar.numfor = I_numfor;
Dummy		Number;
L_numfor	Number;
BEGIN
Open	C_contrat_ref;
Fetch C_contrat_ref into Dummy;
If (C_contrat_ref%found) then
	L_numfor := I_numfor;
Else
	Open C_collective;
	Fetch C_collective Into L_numfor;
	If (C_collective%NotFound) then
		L_numfor := 0;
	Close C_collective;
	End if;
End if;
Close C_contrat_ref;
--
Return(L_numfor);
END F_SEL_numfor;


Function F_SEL_numfor2 (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number
IS
Cursor C_gar_cntrt IS
	Select	decode ( numgar, numgar_ref , I_numfor, numfor_ref)
	From	gar_cntrt
	Where	numfor = I_numfor;

L_numfor	Number;
R_numfor	Number;

BEGIN
Open	C_gar_cntrt;
Fetch C_gar_cntrt into L_numfor;
If (C_gar_cntrt%found) then
	R_numfor := L_numfor;
Else
	R_numfor := I_numfor;
End if;

    Close C_gar_cntrt;
	return (r_numfor) ;

END F_SEL_numfor2;

Function F_SEL_grpnumfor (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number
IS

Dummy		Number;
L_numfor	Number;

L_numfor_ref Number;
L_numgar_ref Number;

Cursor C_contrat_ref IS
	Select	1
	From	contrat_ref
	Where	numgar = I_numgar;


/*Cursor C_collective IS
	select numfor_ref , numgar_ref
	from   adhe_coll_gar, grp_gar, grp_gar_def
	where  grp_gar.numgrpgar = I_numfor
	and    grp_gar.numgrpgar  = grp_gar_def.NUMGRPGAR
	and    grp_gar_def.NUMFOR = adhe_coll_gar.NUMFOR
	and    adhe_coll_gar.numgar=I_numgar;
	-- rajout dernière ligne 14/11/2005 JPF*/ --V2

/*Cursor C_collective IS
	select numfor_ref , numgar_ref
	from   adhe_coll_gar, grp_gar, grp_gar_def
	where  grp_gar.numgrpgar = I_numfor
	and    grp_gar.clef      =I_numgar
	and    grp_gar.numgrpgar  = grp_gar_def.NUMGRPGAR
	and    grp_gar_def.NUMFOR = adhe_coll_gar.NUMFOR
	and    adhe_coll_gar.numgar=I_numgar;
	--  JPF 14/11/2005--V3*/

Cursor C_collective IS
	select numfor_ref , numgar_ref
	from   adhe_coll_gar, grp_gar_def
	where  grp_gar_def.numgrpgar  = I_NUMFOR
	and    grp_gar_def.NUMFOR = adhe_coll_gar.NUMFOR
	and    adhe_coll_gar.numgar= I_numgar;
	--  JPF 14/11/2005--V4

Cursor C_grpgar IS
	select grp_gar.numgrpgar
	from   grp_gar, grp_gar_def
	where  grp_gar.CLEF = L_numgar_ref
	and    grp_gar.numgrpgar  = grp_gar_def.NUMGRPGAR
	and    grp_gar_def.NUMFOR = L_numfor_ref;



BEGIN
Open	C_contrat_ref;
Fetch C_contrat_ref into Dummy;
If (C_contrat_ref%found) then
	L_numfor := I_numfor;
Else
	Open C_collective;
	Fetch C_collective Into L_numfor_ref, L_numgar_ref;
	If (C_collective%NotFound) then
		L_numfor := 0;
		Close C_collective;
	Else
		Close C_collective;
		Open C_grpgar;
	    Fetch C_grpgar Into L_numfor;
		If (C_grpgar%NotFound) then
			L_numfor := 0;
			Close C_grpgar;
		Else
			Close C_grpgar;
		End if;

	End if;

End if;

Close C_contrat_ref;
--
Return(L_numfor);

END F_SEL_grpnumfor;


Function F_SEL_numgar (
		I_numgar	IN contrat_ref.numgar%Type
		)
Return Number
IS
Cursor C_contrat IS
	Select	numgar_ref
	From	contrat
	Where	numgar = I_numgar;


Dummy		Number;
L_numgar_ref	Number;

BEGIN
Open	C_contrat;
Fetch C_contrat into Dummy;
If (C_contrat%found) then
	L_numgar_ref := Dummy;
Else
	L_numgar_ref := 0;
End if;

Close C_contrat;
--
Return(L_numgar_ref);

END F_SEL_numgar;


-- Retourne le nonbre de virgules a utilisée pour le round appliqué à F_prorata dabs le calul des cotis
-- 1, 2, ... ou 99 pour pas de round.
Function F_sel_arrondi_prorata (
		I_numgar	IN contrat_ref.numgar%Type,
		I_numfor	IN gar_cntrt_ref.numfor%Type
		)
Return Number
IS

ArrPro		Number;
L_numfor    Number;

Cursor C_Arr_pro IS
	Select	ARRONDI_PRORATA
	From	formule
	Where	numfor = L_numfor
UNION ALL
    Select	ARRONDI_PRORATA
	From	garanties
	Where	numfor = L_numfor;


BEGIN

Select pk_qttc.f_sel_numfor(I_numgar, I_numfor)
Into   L_numfor
from dual;

Open	C_Arr_pro;
Fetch C_Arr_pro into ArrPro;
If (C_Arr_pro%found) then
	If ArrPro is null then
		ArrPro:=99;
	end if;
Else
    ArrPro:=99;
End if;

Close C_Arr_pro;
--
Return(ArrPro);
END F_sel_arrondi_prorata;

--
-- Retourne la date de reference d'un encaissement
--
Procedure P_SEL_datencaismt (
		I_numencaismt	IN  encaismt.numencaismt%Type,
		O_datencaismt	OUT Date,
		O_numsoc	OUT compte.numsoc%Type
		)
IS
Cursor C_encais IS
	Select	datpay,
		numcpte
	From	encaismt
	Where	numencaismt = I_numencaismt;
Rec_C_encais	C_encais%Rowtype;
L_remise	Number;
BEGIN
Open C_encais;
Fetch C_encais Into Rec_C_encais;
Close C_encais;
--
O_numsoc := pk_treso.F_numsoc( Rec_C_encais.numcpte );
--
pk_treso.P_SEL_datencaismt (
		I_numencaismt	=> I_numencaismt,
		I_datpay	=> Rec_C_encais.datpay,
		O_datencaismt	=> O_datencaismt,
		O_remise	=> L_remise
		);
--
END P_SEL_datencaismt;
--
-- Test s'il y a eu commission prelevee sur la cotisation
--
Function F_EXIST_retro (
		I_numquit	IN qttc_retro.numquit%Type,
		I_numbene	IN qttc_retro.numbene%Type
		)
Return Boolean
IS
Cursor C_retro IS
	Select	1
	From	qttc_retro
	Where	numquit = I_numquit
	and	numbene = I_numbene;
L_retour	Boolean := TRUE;
Dummy		Number;
BEGIN
Open C_retro;
Fetch C_retro Into Dummy;
If ( C_retro%NotFound ) then
	L_retour := FALSE;
End if;
Close C_retro;
--
Return( L_retour );
END F_EXIST_retro;
--
-- Test s'il y a eu commission prelevee affectée sur la cotisation
--
Function F_EXIST_retro_affec (
		I_numquit	IN qttc_affec_tfc.numquit%Type,
		I_numbene	IN qttc_affec_tfc.numbene%Type,
		I_idaffec 	IN qttc_affec_tfc.idaffec%Type
		)
Return Boolean
IS
Cursor C_retro_affec IS
	Select	1
	From   qttc_affec_tfc
	Where  idaffec = I_idaffec
	and numquit = I_numquit
	and	numbene = I_numbene
	and tfc = 5
	and prelev_revers = 1;
L_retour	Boolean := TRUE;
Dummy		Number;
BEGIN
Open C_retro_affec;
Fetch C_retro_affec Into Dummy;
If ( C_retro_affec%NotFound ) then
	L_retour := FALSE;
End if;
Close C_retro_affec;
--
Return( L_retour );
END F_EXIST_retro_affec;
--
-- Retourne le montant calcule d'une cotisation
--
Function F_montant_global (
		I_numquit	IN qttc_global.numquit%Type
		)
Return Number
IS
L_montant	Number := 0;
BEGIN
Begin
Select	mt_ttc
Into	L_montant
From	qttc_global
Where	numquit = I_numquit;
Exception When No_data_found then L_montant := 0;
End;
--
Return( L_montant );
--
END F_montant_global;
--
-- Recherche l'origine d'une compensation compte_tiers
--
Function F_origine (
		I_numencaismt	IN 	compte_client.numencaismt%Type
		)
Return Number
IS
Cursor C_origine IS
	Select	idmvt
	From	compte_tiers
	Where	codope != 4
	and	sens = 1
	and 	cle = I_numencaismt;
L_idmvt	compte_tiers.idmvt%Type;
BEGIN
Open C_origine;
Fetch C_origine Into L_idmvt;
Close C_origine;
Return ( L_idmvt );
END F_origine;
--
/* Insertion d'un mouvement en compte d'attente client */
Procedure P_INS_compte_attente (
			I_idaffec	IN	compte_client.idaffec%Type,
			I_numcli	IN	compte_client.numcli%Type,
			I_numfact	IN	compte_client.numfact%Type,
			I_numencaismt	IN	compte_client.numencaismt%Type,
			I_montant	IN	compte_client.montant%Type,
			I_montant_d IN  compte_client.montant_d%Type,
		    I_monnaie   IN  compte_client.monnaie%Type,
		    I_monnaie_d IN  compte_client.monnaie_d%Type,
			I_datope	IN	Date Default Trunc(Sysdate)
			)
IS
--L_devise 	Number := pk_devise.devise_ref; JPF

BEGIN


Insert Into compte_client (
	idaffec,
	codope,
	numcli,
	numfact,
	numencaismt,
	monnaie,
	monnaie_d,
	montant,
	montant_d,
	idcompta,
	datope )
Values (
	I_idaffec,
	8,
	I_numcli,
	I_numfact,
	I_numencaismt,
	I_monnaie,
	I_monnaie_d,
	I_montant,
	I_montant_d,
	-1,
	I_datope
	);
Insert Into idaffec_regul (
	idaffec,
	idaffec_regul,
	datope )
Values 	(
	I_idaffec,
	I_idaffec,
	trunc( Sysdate )
	);
END P_INS_compte_attente;

Function F_retro_prelev (
		I_numquit	IN	qttc_retro.numquit%Type,
		I_numbene	IN	qttc_retro.numbene%Type)
Return Number
IS
L_montant	Number;
BEGIN
Select	nvl( sum(montant), 0 )
Into	L_montant
From	qttc_retro
Where	numquit = I_numquit
and	numbene = I_numbene
and	prelev_revers = 1;

Return( L_montant );
END F_retro_prelev;

Function F_retro_prelev_d (
		I_numquit	IN	qttc_retro.numquit%Type,
		I_numbene	IN	qttc_retro.numbene%Type)
Return Number
IS
L_montant	Number;
BEGIN
Select	nvl( sum(montant_d), 0 )
Into	L_montant
From	qttc_retro
Where	numquit = I_numquit
and	numbene = I_numbene
and	prelev_revers = 1;

Return( L_montant );
END F_retro_prelev_d;

Function F_retro_prelev_affec (
		I_numquit	IN	qttc_affec_tfc.numquit%Type,
		I_numbene	IN	qttc_affec_tfc.numbene%Type,
		I_idaffec 	IN  qttc_affec_tfc.idaffec%Type)
Return Number
IS
L_montant	Number;
BEGIN
Select Nvl(Abs(Sum(montant)), 0)
Into	L_montant
From   qttc_affec_tfc
Where  idaffec = I_idaffec
and numquit = I_numquit
and	numbene = I_numbene
and    tfc = 5
and    prelev_revers = 1;

Return( L_montant );
END F_retro_prelev_affec;

Function F_retro_prelev_affec_d (
		I_numquit	IN	qttc_affec_tfc.numquit%Type,
		I_numbene	IN	qttc_affec_tfc.numbene%Type,
		I_idaffec 	IN  qttc_affec_tfc.idaffec%Type)
Return Number
IS
L_montant	Number;
BEGIN
Select Nvl(Abs(Sum(montant_d)), 0)
Into	L_montant
From   qttc_affec_tfc
Where  idaffec = I_idaffec
and numquit = I_numquit
and	numbene = I_numbene
and    tfc = 5
and    prelev_revers = 1;

Return( L_montant );
END F_retro_prelev_affec_d;
-- ----------------------------- Fin des declarations des procedures privees --

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
--
-- Retourne la date d'affectation a appliquer selon parametres de cloture
--
Procedure P_SEL_dataffec (
		I_numencaismt	IN  encaismt.numencaismt%Type,
		O_dataffec	OUT Number
		)
IS
L_datencaismt	Date;
L_debut		Date;
L_fin		Date;
L_cloture	Date;
L_numsoc	compte.numsoc%Type;
L_found		Boolean;
BEGIN
--
O_dataffec := d2j(Trunc(Sysdate));
--
P_SEL_datencaismt (
	I_numencaismt	=> I_numencaismt,
	O_datencaismt	=> L_datencaismt,
	O_numsoc	=> L_numsoc
	);
--
pk_treso.P_SEL_param_cloture (
		I_numsoc	=> L_numsoc,
		O_debut		=> L_debut,
		O_fin		=> L_fin,
		O_cloture	=> L_cloture,
		O_found		=> L_found,
		I_cloture	=> 'O',
		I_datref	=> Trunc(Sysdate)
		);
--
If ( L_found ) then
	If ( L_datencaismt <= L_fin ) then
		O_dataffec := d2j(L_fin);
	End if;
End if;
--
END P_SEL_dataffec;
--
--
-- Gestion des regularisations compte tiers
--
Procedure P_INS_compte_tiers (
			I_idaffec	IN	compte_client.idaffec%Type,
			I_numfact	IN	compte_client.numfact%Type,
			I_numfact_regul	IN	compte_client.numfact%Type,
			I_numencaismt	IN	compte_client.numencaismt%Type,
			I_numcli	IN	compte_client.numcli%Type,
			I_montant	IN	compte_client.montant%Type,
			I_montant_d IN	compte_client.montant_d%Type,
			I_monnaie	IN	compte_client.monnaie%Type,
			I_monnaie_d IN	compte_client.monnaie_d%Type,
			I_datope	IN	Date Default Trunc(Sysdate),
			I_idaffec_regul	IN	compte_client.idaffec%Type
			)
IS
Cursor C_desaffecte( P_idmvt IN compensation.idmvt%Type ) IS
	Select	Sum(compte_tiers.montant)	montant,
			Sum(compte_tiers.montant_d)	montant_d
	From	compensation,
		compte_tiers,
		compte_client
	Where	compensation.idcomp = compte_tiers.idmvt
	and	compensation.idmvt = P_idmvt
	and	compte_tiers.codope = 4
	and	compte_tiers.cle = compte_client.idaffec
	and	compte_tiers.sens = -1
	and	compte_client.codope = 4
	and	compte_client.numfact = I_numfact
	;
L_montant	Number;
L_montant_d	Number;
L_retro_prelev	Number;
L_retro_prelev_d	Number;
L_idcomp	Number;
L_idmvt		Number;
L_sens		Number := Sign(I_montant);
BEGIN
--
If ( L_sens = -1 ) then
	--
	-- Desaffectation
	-- On remet le montant affecte au credit du compte tiers
	--
	L_idmvt := F_origine( I_numencaismt );
	--
	Open C_desaffecte( L_idmvt );
	Fetch C_desaffecte Into
		L_montant, L_montant_d;
	If ( L_montant is Not Null and L_idmvt is Not Null ) then
		--
		Select	idmvt.nextval
		Into	L_idcomp
		From	Dual;
		--
		Insert Into compte_tiers (
			Idmvt,
			Numcli,
			Codope,
			Cle,
			Datope,
			Sens,
			Montant,
			Montant_d,
			Monnaie,
			Monnaie_d )
		Values (
			L_idcomp,
			I_numcli,
			4,
			I_idaffec,
			I_datope,
			1,
			L_montant,
			L_montant_d,
			I_monnaie,
			I_monnaie_d );
		--
		Insert Into compensation (
			Idmvt,
			Idcomp )
		Values (
			L_idmvt,
			L_idcomp );
		--
		End if;
	Close C_desaffecte;
Elsif ( L_sens = 1 ) then
	--
	-- Reaffectation a la nouvelle quittance
	-- On insere un mouvement au debit du compte tiers
	-- du montant reaffecte moins la comm prelevee calculee
	--@trav
	-- Si le nouveau montant est > a l'ancien
	-- on doit prendre la comm calculee anciennement
	-- sinon la nouvelle
	If ( F_montant_global(I_numfact) > F_montant_global(I_numfact_regul) )
	then
		If ( F_EXIST_retro (
			I_numquit	=>	I_numfact_regul,
			I_numbene	=>	I_numcli )
			AND
			F_EXIST_retro_affec (
			I_numquit	=>	I_numfact_regul,
			I_numbene	=>	I_numcli,
			I_idaffec 	=>  I_idaffec_regul)
			) then
			L_retro_prelev := F_retro_prelev_affec (
					I_numquit	=>	I_numfact_regul,
					I_numbene	=>	I_numcli,
					I_idaffec	=>  I_idaffec_regul);
			L_retro_prelev_d := F_retro_prelev_affec_d(
					I_numquit	=>	I_numfact_regul,
					I_numbene	=>	I_numcli,
					I_idaffec	=>  I_idaffec_regul);
		Else
		-- Prelevee sur autre tiers, ou pas de comm precedente
		-- on prend la nouvelle comm
			L_retro_prelev := F_retro_prelev_affec (
					I_numquit	=>	I_numfact,
					I_numbene	=>	I_numcli,
					I_idaffec	=>  I_idaffec);
			L_retro_prelev_d := F_retro_prelev_affec_d (
					I_numquit	=>	I_numfact,
					I_numbene	=>	I_numcli,
					I_idaffec	=>  I_idaffec);
		End if;
	Else
		L_retro_prelev := F_retro_prelev_affec (
				I_numquit	=>	I_numfact,
				I_numbene	=>	I_numcli,
				I_idaffec	=>  I_idaffec);
		L_retro_prelev_d := F_retro_prelev_affec_d (
				I_numquit	=>	I_numfact,
				I_numbene	=>	I_numcli,
				I_idaffec	=>  I_idaffec);
	End if;
	--
	L_montant   := I_montant - L_retro_prelev;
	L_montant_d := I_montant_d - L_retro_prelev_d;
	L_idmvt := F_origine( I_numencaismt );
	--
	If ( L_idmvt is Not Null ) then
		Select	idmvt.nextval
		Into	L_idcomp
		From	Dual;
		--
		Insert Into compte_tiers (
			Idmvt,
			Numcli,
			Codope,
			Cle,
			Datope,
			Sens,
			Montant,
			Montant_d,
			Monnaie,
			Monnaie_d )
		Values (
			L_idcomp,
			I_numcli,
			4,
			I_idaffec,
			I_datope,
			-1,
			L_montant,
			L_montant_d,
			I_monnaie,
			I_monnaie_d );
		--
		Insert Into compensation (
			Idmvt,
			Idcomp )
		Values (
			L_idmvt,
			L_idcomp );
		--
	End if;
End if;
--
END P_INS_compte_tiers;
--
-- Gestion du solde de regularisation.
--  Passage au compte client ou au compte tiers selon l'origine du mouvement
Procedure P_INS_solde_regul (
			I_idaffec	IN	compte_client.idaffec%Type,
			I_numcli	IN	compte_client.numcli%Type,
			I_numfact	IN	compte_client.numfact%Type,
			I_numencaismt	IN	compte_client.numencaismt%Type,
			I_montant	IN	compte_client.montant%Type,
			I_montant_d IN  compte_client.montant_d%Type,
	    	I_monnaie   IN  compte_client.monnaie%Type,
		    I_monnaie_d IN  compte_client.monnaie_d%Type,
			I_numquit	IN	qttc_global.numquit%Type,
			I_datope	IN	Date Default Trunc(Sysdate)
			)
IS
Cursor C_compte_client IS
	Select	idaffec
	From	compte_client
	Where	codope = 4
	and	numfact = I_numfact
	and	numencaismt = I_numencaismt
	and	montant > 0
	Order by
		idaffec;
Cursor C_compte_tiers ( P_idaffec compte_client.idaffec%Type ) IS
	Select	idmvt,
		montant
	From	compte_tiers
	Where	compte_tiers.codope = 4
	and	compte_tiers.cle = P_idaffec
	and	sens = -1;
Rec_C_compte_client	C_compte_client%Rowtype;
Rec_C_compte_tiers	C_compte_tiers%Rowtype;
BEGIN
-- On recherche le premier idaffec regularise
Open C_compte_client;
Fetch C_compte_client Into Rec_C_compte_client;
Close C_compte_client;

-- Afin de retrouver l'eventuel mouvement de compte_tiers
Open C_compte_tiers( Rec_C_compte_client.idaffec );
Fetch C_compte_tiers Into Rec_C_compte_tiers;
If C_compte_tiers%NotFound then
	-- Il s'agit d'un mouvement client
	-- retour au compte d'attente
	P_INS_compte_attente (
		I_idaffec	=>	I_idaffec,
		I_numcli	=>	I_numcli,
		I_numfact	=>	I_numfact,
		I_numencaismt	=>	I_numencaismt,
		I_montant	=>	I_montant,
		I_montant_d =>  I_montant_d,
		I_monnaie   =>  I_monnaie,
		I_monnaie_d =>  I_monnaie_d,
		I_datope	=>	I_datope
		);
	Close C_compte_tiers;
End if;
END P_INS_solde_regul;

Procedure P_DEL_variable_a_blanc (
			I_numquit	IN	qttc_global.numquit%Type,
			I_type_qttc	IN	qttc_global.type_qttc%Type,
			I_numgar	IN	qttc_global.numgar%Type,
			I_idadhesion	IN	qttc_global.idadhesion%Type,
			I_debut		IN	Date,
			I_fin		IN	Date
			)
IS
Cursor C_qttc_variable IS
	Select	idbase,
		idtaux
	From	qttc_variable
	Where	numquit = I_numquit
	Group By
		idbase,
		idtaux;
Rec_C_qttc_variable	C_qttc_variable%Rowtype;
BEGIN
Open C_qttc_variable;
Loop
	Fetch C_qttc_variable Into Rec_C_qttc_variable;
	Exit When C_qttc_variable%NotFound;
	If ( I_type_qttc = 1 ) then
		Begin
		Delete	val_variable
		Where	etendue = 2
		and	clef = I_numgar
		and	idvariable + 0 = Rec_C_qttc_variable.idbase
		and	statique = 'N'
		and	debut = I_debut
		and	fin = I_fin;
		Delete	val_variable
		Where	etendue = 2
		and	clef = I_numgar
		and	idvariable + 0 = Rec_C_qttc_variable.idtaux
		and	statique = 'N'
		and	debut = I_debut
		and	fin = I_fin;

		-- Rajouté par JPF 09/09/2004

		Delete	val_variable
		Where	etendue = 13
		and	numgar = I_numgar
		and	idvariable + 0 = Rec_C_qttc_variable.idbase
		and	statique = 'N'
		and	debut >= I_debut
		and	fin <= I_fin;

		Delete	val_variable
		Where	etendue = 13
		and	numgar = I_numgar
		and	idvariable + 0 = Rec_C_qttc_variable.idtaux
		and	statique = 'N'
		and	debut >= I_debut
		and	fin <= I_fin;

		Delete	val_variable
		Where	etendue = 12
		and	numgar = I_numgar
		and	idvariable + 0 = Rec_C_qttc_variable.idbase
		and	statique = 'N'
		and	debut >= I_debut
		and	fin <= I_fin;

		Delete	val_variable
		Where	etendue = 12
		and	numgar = I_numgar
		and	idvariable + 0 = Rec_C_qttc_variable.idtaux
		and	statique = 'N'
		and	debut >= I_debut
		and	fin <= I_fin;

	End;
	End if;
End Loop;
Close C_qttc_variable;
END P_DEL_variable_a_blanc;
--
--
PROCEDURE P_DEL_previsionnel ( I_etendue IN  qttc_global.etendue%TYPE,
                               I_cle     IN  qttc_global.numgar%TYPE)   IS
BEGIN
  IF I_etendue = 2 THEN  	-- Concerne les Contrats
    Delete
    from   Qttc_global
    Where  etendue = I_etendue
    And    numgar  = I_cle
    And  Not Exists
               ( Select 'X'
                 From   facture
                 where  codope  = 4
                 And    facture.numfact = qttc_global.numquit
               );

  ELSIF I_etendue = 13 THEN	-- Concerne les adhesions
    Delete
    from   Qttc_global
    Where  etendue    = I_etendue
    And    idadhesion = I_cle
    And  Not Exists
               ( Select 'X'
                 From   facture
                 where  codope  = 4
                 And    facture.numfact = qttc_global.numquit
               );
  END IF;
END;
--
PROCEDURE P_MAJ_echesuiv ( I_etendue    IN qttc_global.etendue%TYPE,
                           I_cle	IN qttc_global.numgar%TYPE)     IS
CURSOR C_qttc_contrat IS
         Select  debut,fin
         From    Qttc_global
         Where   type_qttc <> 3
         And     comptant  <> 'R'
         And     numgar    = I_cle;
--
CURSOR C_qttc_adhesion IS
         Select  debut,fin
         From    Qttc_global
         Where   type_qttc <> 3
         And     comptant  <> 'R'
         And     idadhesion = I_cle;
--
Rec_c_qttc_contrat  C_qttc_contrat%ROWTYPE;
Rec_c_qttc_adhesion C_qttc_adhesion%ROWTYPE;
--
W_debut		Date;
W_fin		Date;
--
BEGIN
  IF I_etendue = 2 THEN		-- Concerne le Contrat
    OPEN   C_qttc_contrat;
    FETCH  C_qttc_contrat INTO Rec_c_qttc_contrat;
    IF C_qttc_contrat%FOUND THEN
      W_debut := Rec_c_qttc_contrat.debut;
      W_fin   := Rec_c_qttc_contrat.fin;
      LOOP
         FETCH  C_qttc_contrat INTO Rec_c_qttc_contrat;
         EXIT WHEN C_qttc_contrat%NOTFOUND;
         --
         IF Rec_c_qttc_contrat.debut > w_debut THEN
           W_debut := Rec_c_qttc_contrat.debut;
           W_fin   := Rec_c_qttc_contrat.fin;
         END IF;
      END LOOP;
      --
      W_fin := W_fin + 1;
    ELSE
      W_fin   := Null;
      W_debut := Null;
    END IF;
    --
    -- Mise a jour contrat
    Update  Contrat_ref
    Set     echesuiv = W_fin,
            dereche  = W_debut
    Where   numgar   = I_cle;
    --

  ELSIF I_etendue = 24 THEN		-- Concerne l'adhésion collective
    OPEN   C_qttc_contrat;
    FETCH  C_qttc_contrat INTO Rec_c_qttc_contrat;
    IF C_qttc_contrat%FOUND THEN
      W_debut := Rec_c_qttc_contrat.debut;
      W_fin   := Rec_c_qttc_contrat.fin;
      LOOP
         FETCH  C_qttc_contrat INTO Rec_c_qttc_contrat;
         EXIT WHEN C_qttc_contrat%NOTFOUND;
         --
         IF Rec_c_qttc_contrat.debut > w_debut THEN
           W_debut := Rec_c_qttc_contrat.debut;
           W_fin   := Rec_c_qttc_contrat.fin;
         END IF;
      END LOOP;
      --
      W_fin := W_fin + 1;
    ELSE
      W_fin   := Null;
      W_debut := Null;
    END IF;
    --
    -- Mise a jour de l'adhésion collective
    Update  ADHE_COLLECTIVE
    Set     echesuiv = W_fin,
            dereche  = W_debut
    Where   numgar   = I_cle;
    --

  ELSIF I_etendue = 13 THEN  -- Concerne les adhesions
    OPEN   C_qttc_adhesion;
    FETCH  C_qttc_adhesion INTO Rec_c_qttc_adhesion;
    IF C_qttc_adhesion%FOUND THEN
      W_debut := Rec_c_qttc_adhesion.debut;
      W_fin   := Rec_c_qttc_adhesion.fin;
      LOOP
         FETCH  C_qttc_adhesion INTO Rec_c_qttc_adhesion;
         EXIT WHEN C_qttc_adhesion%NOTFOUND;
         --
         IF Rec_c_qttc_adhesion.debut > w_debut THEN
           W_debut := Rec_c_qttc_adhesion.debut;
           W_fin   := Rec_c_qttc_adhesion.fin;
         END IF;
      END LOOP;
      --
      W_fin := W_fin + 1;
    ELSE
      W_fin   := Null;
      W_debut := Null;
    END IF;
    --
    Update  adhe_cntrt
    Set     echesuiv = W_fin,
            dereche  = W_debut
    Where   idadhesion= I_cle;
    --
  END IF;
END;

PROCEDURE P_MAJ_DEV (I_numquit	IN	qttc_global.numquit%Type)
IS
DateConv date;
DEVCT   number;
DEVREF  number;
IdNumgar number;


BEGIN

Select pk_devise.devise_ref
into   DEVREF
from dual;


Select numgar, debut, pk_devise.devise_ct(numgar)
into   IdNumgar, DateConv, DEVCT
from   Qttc_global
Where  numquit=I_numquit;

Select max(datcours)
into   DateConv
from   change
Where  datcours<=dateconv and codmon=DEVCT and codmon_ref=DEVREF;


UPDATE qttc_global set
			MT_NET_d   = MT_NET,
			MT_TTC_d   = MT_TTC,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MT_NET     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_NET,DateConv),
			MT_TTC     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_TTC,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE qttc_gar set
			MT_NET_d   = MT_NET,
			MT_TTC_d   = MT_TTC,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MT_NET     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_NET,DateConv),
			MT_TTC     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_TTC,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE qttc_variable set
			BASE_d     = BASE,
			MONNAIE_d  = DEVCT,
            BASE       = pk_devise.F_CONV_MT(DEVCT,DEVREF,BASE,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE qttc_affec set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

--QTTC_ANNUELLE ??

UPDATE qttc_frais set
			MONTANT_d   = MONTANT,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MONTANT     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE qttc_comm set
			MONTANT_d   = MONTANT,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MONTANT     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE qttc_retro set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE qttc_taxe set
			MONTANT_d   = MONTANT,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MONTANT     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE qttc_affec_tfc set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = I_numquit;

UPDATE facture set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numfact = I_numquit;

END P_MAJ_DEV;


PROCEDURE P_MAJ_DEV_full
IS
DateConv date;
DEVCT   number;
DEVREF  number;
IdNumgar number;


Cursor C_Numquit IS
	Select	numquit
	From	qttc_global
	Where	monnaie_d is null;

Rec_C_numquit	C_Numquit%Rowtype;


BEGIN

Select pk_devise.devise_ref
into   DEVREF
from dual;

OPEN C_Numquit;

LOOP
    FETCH  C_Numquit INTO Rec_c_Numquit;
    EXIT WHEN C_Numquit%NOTFOUND;

Select numgar, DEBUT , pk_devise.devise_ct(numgar)
into   IdNumgar, DateConv, DEVCT
from   Qttc_global
Where  numquit=Rec_c_Numquit.numquit;

Select max(datcours)
into   DateConv
from   change
Where  datcours<=dateconv and codmon=DEVCT and codmon_ref=DEVREF;


UPDATE qttc_global set
			MT_NET_d   = MT_NET,
			MT_TTC_d   = MT_TTC,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MT_NET     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_NET,DateConv),
			MT_TTC     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_TTC,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE qttc_gar set
			MT_NET_d   = MT_NET,
			MT_TTC_d   = MT_TTC,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MT_NET     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_NET,DateConv),
			MT_TTC     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_TTC,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE qttc_variable set
			BASE_d     = BASE,
			MONNAIE_d  = DEVCT,
            BASE       = pk_devise.F_CONV_MT(DEVCT,DEVREF,BASE,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE qttc_affec set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

--QTTC_ANNUELLE ??

UPDATE qttc_frais set
			MONTANT_d   = MONTANT,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MONTANT     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE qttc_comm set
			MONTANT_d   = MONTANT,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MONTANT     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE qttc_retro set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE qttc_taxe set
			MONTANT_d   = MONTANT,
			MT_AFFEC_d = MT_AFFEC,
			MONNAIE_d  = DEVCT,
            MONTANT     = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MT_AFFEC   = pk_devise.F_CONV_MT(DEVCT,DEVREF,MT_AFFEC,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE qttc_affec_tfc set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numquit = Rec_c_Numquit.numquit;

UPDATE facture set
			MONTANT_d  = MONTANT,
			MONNAIE_d  = DEVCT,
            MONTANT    = pk_devise.F_CONV_MT(DEVCT,DEVREF,MONTANT,DateConv),
			MONNAIE    = DEVREF
WHERE numfact = Rec_c_Numquit.numquit;




END LOOP;

CLOSE C_numquit;


END P_MAJ_DEV_full;
-- ---------------------------------- Fin des corps des procedures publiques --
--
END;
/
