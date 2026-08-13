CREATE OR REPLACE PACKAGE ARTHUS.pk_arthusora AS
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
--
--
Function F_mt_annuel (
	I_numindiv		IN	histo_calcul.numbene%type,
	I_idrepartition		IN	histo_calcul.idrepartition%type,
	I_debut			IN	date,
	I_fin			IN	date)
Return Number;
--Pragma Restrict_References (F_mt_annuel, WNDS);
--
Function F_mt_revalo_annuel (
	I_numindiv		IN	histo_calcul.numbene%type,
	I_idrepartition		IN	histo_calcul.idrepartition%type,
	I_debut			IN	date,
	I_fin			IN	date)
Return Number;
--Pragma Restrict_References (F_mt_revalo_annuel, WNDS);
--			  );
Function F_dernier_paiement (
	I_numindiv		IN	histo_calcul.numbene%type,
	I_idrepartition		IN	histo_calcul.idrepartition%type,
	I_debut			IN	date,
	I_fin			IN	date)
Return varchar2;
--Pragma Restrict_References (F_dernier_paiement, WNDS);
--
Function F_situ_famille (
	I_numassu		IN	pers_histo_phys.numindiv%type,
	I_survenance		IN	pers_histo_phys.debut%type)
Return Varchar2;
--Pragma Restrict_References (F_situ_famille, WNDS);

Function F_traitement_annuel (
	I_nosin			IN	val_variable.clef%type,
	I_survenance		IN	val_variable.debut%type)
Return Varchar2;
--Pragma Restrict_References (F_traitement_annuel, WNDS);
--
Function F_adresse (
	I_numindiv		IN	individu.numindiv%type )
Return varchar2;
--Pragma Restrict_References (F_adresse, WNDS);
--
Function f_idadresse (
			a_numindiv 	in Number,
			a_codope 	in Number 	Default 0,
			a_debut 	in Date		Default sysdate,
			a_defaut 	in varchar2	Default 'O',
			a_numgar 	in Number	Default 0,
                        a_type_adr      in Number	Default -1
			)
Return number;
--Pragma Restrict_References(f_idadresse, WNDS, WNPS);

-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_arthusora AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%

-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------

-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- --------------------------------------- Fin des variables globales privees --

-- -------------------------------------- Fin des variables globales privees --

-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
-- Aucune
-- ----------------------------- Fin des declarations des procedures privees --

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
-- Recherche du montant annuel pour requête Détail préstations de prévoyance CARCO
--
Function F_mt_annuel (
	I_numindiv		IN	histo_calcul.numbene%type,
	I_idrepartition		IN	histo_calcul.idrepartition%type,
	I_debut			IN	date,
	I_fin			IN	date)
Return Number
IS
L_mt_annuel	Number;

Begin
SELECT	max(round(nvl(histo_jours.montant,0)*prmt.prorata_jours,2))
INTO	L_mt_annuel
FROM	prmt,
	gar_prev,
	repartition,
	histo_jours,
	histo_reval,
	histo_calcul,
	affectation,
	decaismt
Where	histo_jours.idcalcul=histo_calcul.idcalcul
And	histo_reval.idhisto(+)=histo_jours.idhisto
And	histo_calcul.numdec=affectation.numaffec
And	histo_calcul.idrepartition=repartition.idrepartition
And	repartition.numfor=gar_prev.numfor
And	gar_prev.type_calc!=3
And	affectation.numdecaismt=decaismt.numdecaismt
And	decaismt.datpay between	nvl(e2d(I_debut),decaismt.datpay) and nvl(e2d(I_fin),nvl(e2d(I_debut),decaismt.datpay))
And	histo_calcul.numbene=I_numindiv
And	histo_calcul.idrepartition=I_idrepartition;

return L_mt_annuel;

EXCEPTION

When NO_DATA_FOUND then
L_mt_annuel := null;
return L_mt_annuel;

END  F_mt_annuel;

--
-- Recherche du montant annuel revalorisé pour requête Détail préstations de prévoyance CARCO
--

Function F_mt_revalo_annuel (
	I_numindiv		IN	histo_calcul.numbene%type,
	I_idrepartition		IN	histo_calcul.idrepartition%type,
	I_debut			IN	date,
	I_fin			IN	date)
Return	Number
IS
L_mt_revalo_annuel	Number;

BEGIN
SELECT	max(round(nvl(histo_reval.montant,0)*prmt.prorata_jours,2))
INTO	L_mt_revalo_annuel
FROM	prmt,
	gar_prev,
	repartition,
	histo_jours,
	histo_reval,
	histo_calcul,
	affectation,
	decaismt
Where	histo_jours.idcalcul=histo_calcul.idcalcul
And	histo_reval.idhisto(+)=histo_jours.idhisto
And	histo_calcul.numdec=affectation.numaffec
And	histo_calcul.idrepartition=repartition.idrepartition
And	repartition.numfor=gar_prev.numfor
And	gar_prev.type_calc!=3
And	affectation.numdecaismt=decaismt.numdecaismt
And	decaismt.datpay between	nvl(e2d(I_debut),decaismt.datpay) and nvl(e2d(I_fin),nvl(e2d(I_debut),decaismt.datpay))
And	histo_calcul.numbene=I_numindiv
And	histo_calcul.idrepartition=I_idrepartition;

Return L_mt_revalo_annuel;

EXCEPTION
When NO_DATA_FOUND then
	L_mt_revalo_annuel := null;
	Return L_mt_revalo_annuel;

END  F_mt_revalo_annuel;

--
-- Recherche de la date du dernier paiement pour requête Détail préstations de prévoyance CARCO
--

Function F_dernier_paiement (
	I_numindiv		IN	histo_calcul.numbene%type,
	I_idrepartition		IN	histo_calcul.idrepartition%type,
	I_debut			IN	date,
	I_fin			IN	date)
Return	varchar2

IS
L_dernier_paiement	Varchar2(15);

BEGIN
SELECT 	max(to_char(decaismt.datpay,'dd/mm/yyyy'))
INTO	L_dernier_paiement
FROM	histo_calcul,affectation,decaismt
WHERE	histo_calcul.numbene=I_numindiv
AND	histo_calcul.idrepartition=I_idrepartition
AND	affectation.numaffec=histo_calcul.numdec
AND	decaismt.numdecaismt=affectation.numdecaismt
AND	decaismt.datpay between	nvl(e2d(I_debut),decaismt.datpay) and nvl(e2d(I_fin),nvl(e2d(I_debut),decaismt.datpay));

Return  L_dernier_paiement;

EXCEPTION
When NO_DATA_FOUND then
	L_dernier_paiement := null;
	Return  L_dernier_paiement;

END  F_dernier_paiement;

--
-- Recherche de la situation de famille pour la requête Détail préstations de prévoyance CARCO
--

Function F_situ_famille (
	I_numassu		IN	pers_histo_phys.numindiv%type,
	I_survenance		IN	pers_histo_phys.debut%type)
Return	varchar2

IS
L_situ_famille 		varchar2(45);
Cursor C_situ IS
SELECT 	libelle.libelle
FROM	libelle,pers_histo_phys
WHERE	libelle.mnemo='SITU_FAM'
AND	code=pers_histo_phys.situ_fam
AND	pers_histo_phys.numindiv= I_numassu
AND	pers_histo_phys.debut < I_survenance
order By pers_histo_phys.debut;

BEGIN
Open C_situ;
fetch C_situ into L_situ_famille;
If (C_situ%FOUND) then
   Return L_situ_famille;
else
   L_situ_famille := null;
   Return L_situ_famille;
end if;
close C_situ;
END  F_situ_famille;

--
-- Recherche du traitement annuel brut pour la requête Détail préstations de prévoyance CARCO
--
Function F_traitement_annuel (
	I_nosin			IN	val_variable.clef%type,
	I_survenance		IN	val_variable.debut%type)
Return	varchar2

IS
L_traitement_annuel	varchar2(15);

BEGIN
SELECT	val_variable.valeur
INTO	L_traitement_annuel
FROM 	val_variable
WHERE	val_variable.idvariable=1
AND	val_variable.clef=I_nosin
HAVING	max(val_variable.debut)<I_survenance
GROUP BY val_variable.valeur;

Return L_traitement_annuel;

EXCEPTION
When NO_DATA_FOUND then
	L_traitement_annuel := null;
	Return L_traitement_annuel;

END  F_traitement_annuel;
--
Function F_adresse (
	I_numindiv		IN	individu.numindiv%type )
Return varchar2
IS

L_ad		varchar2(35);
L_adr1		varchar2(35);
L_adr2		varchar2(35);
L_codpos	varchar2(35);
L_ville		varchar2(35);
L_cedex		varchar2(35);
L_pays		varchar2(35);
L_adresse	varchar2(250);
BEGIN
Select 	pers_adresse.comp_adresse,
pk_personne.f_recompose(pers_adresse.no_voie,pers_adresse.bis,pers_adresse.type_voie,pers_adresse.nom_voie,32),
	pers_adresse.adresse_2,
	pers_adresse.codpos,
	pers_adresse.ville,
	pers_adresse.no_cedex,
	decode(pers_adresse.codpays,prmt.dfpays,'',f_pays(pers_adresse.codpays))
Into	L_ad,
	L_adr1,
	L_adr2,
	L_codpos,
	L_ville,
	L_cedex,
	L_pays
From 	pers_adresse,prmt
Where	idadresse = (select f_idadresse(I_numindiv,0,sysdate,'O',0)
			from dual);

L_adresse := 	L_ad || ' ' || L_adr1 || ' ' || L_adr2 || ' ' ||
		L_codpos || ' ' || L_ville || ' ' || L_cedex || ' ' || L_pays;

Return L_adresse;

EXCEPTION
When NO_DATA_FOUND then
	L_adresse := null;
	Return L_adresse;

END  F_adresse;
--
Function f_idadresse (
			a_numindiv 	in Number,
			a_codope 	in Number 	Default 0,
			a_debut 	in Date		Default sysdate,
			a_defaut 	in varchar2	Default 'O',
			a_numgar 	in Number	Default 0,
                        a_type_adr      in Number	Default -1
			)
Return number
Is
loc_idadresse	Number := 0;
loc_numindiv	Binary_integer := a_numindiv;
loc_codope	Binary_integer := a_codope;
loc_numgar	Binary_integer := a_numgar;
loc_defaut	Varchar2(1) := a_defaut;
loc_debut	Date := a_debut;
Cursor Fetch_adresse Is
	Select	idadresse
	From	pers_adresse
	Where	numindiv = loc_numindiv
	and	codope = loc_codope
	and	numgar = loc_numgar
        and     type   = decode(a_type_adr,-1,type,a_type_adr)
	and	defaut = nvl(loc_defaut, defaut)
	and	debut <= nvl(loc_debut, debut)
	Order by debut desc;
c_adresse	Fetch_adresse%Rowtype;
Begin
<<Recommence>>
For c_adresse In Fetch_adresse Loop
	loc_idadresse := c_adresse.idadresse;
	Exit when Fetch_adresse%Found;
End Loop;
If ( loc_idadresse = 0 ) then
	If ( loc_numgar != 0 ) then
		loc_numgar := 0;
		Goto Recommence;
	Elsif ( loc_codope != 0 ) then
		loc_codope := 0;
		Goto Recommence;
	Elsif ( loc_debut Is Not Null ) then
		loc_debut := Null;
		Goto Recommence;
	Elsif ( loc_defaut = 'O' ) then
		loc_defaut := 'N';
		Goto Recommence;
	Elsif ( loc_defaut = 'N' ) then
		loc_defaut := Null;
		Goto Recommence;
	End if;
	If ( loc_numindiv != f_numassu(a_numindiv) ) then
		loc_numindiv := f_numassu(a_numindiv);
		loc_codope	:= a_codope;
		loc_numgar	:= a_numgar;
		loc_defaut	:= a_defaut;
		loc_debut	:= a_debut;
		Goto Recommence;
 	End if;
End if;

Return( loc_idadresse );

End f_idadresse;
-- ------------------------------------ Fin des corps des procedures publiques --
END;
/
