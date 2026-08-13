CREATE OR REPLACE PACKAGE ARTHUS.pk_santeclair AS
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
-- Traitement d'une adhesion et renvoi des lignes fichier
--
Procedure P_TRAITE_adhesion (
	I_deb_numgar	IN  contrat.numgar%Type,
	I_fin_numgar	IN  contrat.numgar%Type,
	I_refcie		IN  contrat.refcie%Type,
	I_session		IN	NUMBER	Default 1,
	I_niv_msg		IN	NUMBER	Default 1,
	O_attest		OUT Varchar2
	);
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_santeclair AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
Type T_adresse is table of varchar2(32) index by Binary_integer;
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--@global
G_deb_numgar	contrat.numgar%type;
G_fin_numgar	contrat.numgar%type;
G_refcie 	contrat.refcie%type;
G_numgar	contrat.numgar%type;
G_idadhesion 	adhesion.idadhesion%type;
G_numindiv 	individu.numindiv%type;
G_refcontrat 	contrat.refcie%type;
G_numsoc 	contrat.numinterm%type;
G_numorg	contrat.numorg%type;
G_numreg 	number;
G_numemetteur	parporte.numemetteur%type;
G_typgar	varchar2(2);
G_numadhe	adhe_cntrt.numadhe%type;
G_adresse	Varchar2(256);
G_numtel	individu.tel%type;
G_dateadhe	adhe_cntrt.date_adhe%type;
G_abrege	varchar2(10);
G_attestation	Varchar2(3500);
G_assure	Varchar2(3000);

--G_adresse	T_adresse;

G_adr_null	T_adresse;

-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%Type default 'pk_santeclair';
G_msg_adm		journal_adm.msg_adm%Type;
G_session		journal_adm.id_session%Type default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%Type;

-- -------------------------------------- Fin des variables globales privees --

-- -- DECLARATION DES CURSEURS PRIVES --------------------------------------
--@curs
Cursor C_adhesion IS
	Select 	adhe_cntrt.idadhesion,
		adhe_cntrt.numadhe,
		contrat.numgar,
		contrat.refcie,
		contrat.numinterm,
		contrat.numorg,
		individu.orgbase,
		adhe_cntrt.date_adhe
	from	contrat,
		individu,
		adhe_cntrt
	Where 	contrat.numgar = adhe_cntrt.numgar
	and	adhe_cntrt.numadhe = individu.numindiv
	and 	adhe_cntrt.numgar between G_deb_numgar
			and nvl(G_fin_numgar, G_deb_numgar)
	and	contrat.refcie like G_refcie || '%'
	and  	f_etat_adhe(idadhesion, sysdate, 1) = 1
	and	exists (select 1 from adhesion
			where adhesion.idadhesion=adhe_cntrt.idadhesion
			and adhesion.etat=1
			and adhesion.rang!=2
			and sysdate between datapli and nvl(datper,sysdate)
			)
	Order By
		  adhe_cntrt.numgar,adhe_cntrt.idadhesion;

-- ----------------------------- Fin des declarations des procedures privees --

-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--@priv
--
-- Complete une chaine avec un charactere
--
Function F_fill (
		I_chaine	IN  Varchar2,
		I_longueur	IN  Number,
		I_character	IN  Varchar2 Default ' ',
		I_alignement	IN  number Default 1 /* si 1, complete a droite */
		)
Return Varchar2;
--
-- Recherche du regime general de l'adherent
--
Procedure P_SEL_regime (
		I_numindiv	IN	Individu.numindiv%type
			);
--
-- Recherche de l'identifiant de la compagnie
--
Procedure P_SEL_identifiant (
		I_numsoc	IN	parporte.numsoc%type,
		I_numorg	IN	parporte.numorg%type,
		I_numreg	IN	parporte.numreg%type
			     );
--
-- Recherche du type de contrat (groupe ou groupe ouvert)
--
Procedure P_SEL_typcontrat (
		I_numgar	IN	Contrat.numgar%type
			    );
--
-- Construction de l'attestation
--
Procedure P_TRT_attestation;
--
-- Infos adresse de l'adherent
--
Procedure P_SEL_adresse (
		I_numindiv	IN pers_adresse.numindiv%Type
		);
--
-- Recherche du numero de telephone de l'adherent
--
Procedure P_SEL_numtel (
		I_numindiv	IN pers_adresse.numindiv%Type
		);
--
-- Code du bureau de gestion = abrege de la societe de gestion du contrat
--
Procedure P_SEL_abrege (
		I_numsoc	IN parporte.numsoc%type
			);
--
-- Recherche infos de chaque assure sur le contrat
--
Procedure P_SEL_assure (
		I_idadhesion	IN	adhesion.idadhesion%type
  			);
--
-- Civilite de l'affilie
--
Procedure P_SEL_civilite (
	I_numindiv	IN	Individu.numindiv%type,
        O_civilite	OUT	varchar2
			  );
--
-- Parente avec l'assure principal
--
Procedure P_SEL_parente (
	I_numindiv IN individu.numindiv%type,
	O_parente  OUT Varchar2
		);
--
-- Comptage des garanties pour obligatoire et facultatif
--
Procedure P_SEL_nbr_gar (
	I_idadhesion	IN	adhesion.idadhesion%type,
	I_numindiv 	IN 	individu.numindiv%type,
	O_nbr_gar	OUT 	number
		);

--
PROCEDURE P_INS_journal;
--

-- ----------------------------- Fin des declarations des procedures privees --

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
--
-- Traitement d'une remise et renvoi des lignes fichier
--
Procedure P_TRAITE_adhesion (
	I_deb_numgar	IN  contrat.numgar%Type,
	I_fin_numgar	IN  contrat.numgar%Type,
	I_refcie		IN  contrat.refcie%Type,
	I_session		IN	NUMBER	Default 1,
	I_niv_msg		IN	NUMBER	Default 1,
	O_attest		OUT Varchar2
	)
IS
Rec_C_adhesion	C_adhesion%Rowtype;
BEGIN
--
G_deb_numgar 	:= I_deb_numgar;
G_fin_numgar 	:= I_fin_numgar;
G_refcie 		:= I_refcie;
G_session		:= I_session;
G_max_msg		:= I_niv_msg;

--
If Not C_adhesion%ISOPEN then
	Open C_adhesion;
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Début traitement - ouverture du curseur'  ;
		P_INS_journal;
End if;
--
Fetch C_adhesion Into Rec_C_adhesion;
--
If  C_adhesion%NotFound  then
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Fin de traitement - fermeture du curseur'  ;
		P_INS_journal;
	Close C_adhesion;
	Raise No_data_found;
End if;
--
-- If ( Rec_C_adhesion.idadhesion != nvl(G_idadhesion, -1) ) then

	G_idadhesion := Rec_C_adhesion.idadhesion;
	G_numgar := Rec_C_adhesion.numgar;
	G_refcontrat := Rec_C_adhesion.refcie;
	G_numsoc := Rec_C_adhesion.numinterm;
	G_numorg := Rec_C_adhesion.numorg;
--	G_regime := Rec_C_adhesion.regime;
	G_numadhe := Rec_C_adhesion.numadhe;
	G_dateadhe := Rec_C_adhesion.date_adhe;

		G_niv_msg	:= 3;
		G_msg_adm	:= 'IdAdhesion='||G_idadhesion||' - Numadhe='|| G_numadhe  ;
		P_INS_journal;


	P_SEL_regime (
		I_numindiv => G_numadhe
		     );
--	Dbms_output.put_line( 'regime '||G_numreg);
	Dbms_output.put_line( 'societe '||G_numsoc);
	Dbms_output.put_line( 'organisme '||G_numorg);
	Dbms_output.put_line( 'individu '||G_numadhe);
	Dbms_output.put_line( 'adhesion'||G_idadhesion);

		G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_sel_régime';
		P_INS_journal;

	P_SEL_identifiant (
		I_numsoc => G_numsoc,
		I_numorg => G_numorg,
		I_numreg => G_numreg
			  );
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_SEL_identifiant';
		P_INS_journal;

	Dbms_output.put_line( 'identifiant '||G_numemetteur);

	P_SEL_typcontrat (
		I_numgar => G_numgar
			 );
	Dbms_output.put_line( 'type de contrat  '||G_typgar);

     	G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_SEL_typcontrat';
		P_INS_journal;


	P_SEL_adresse (
		I_numindiv => G_numadhe
	              );
--	for i in 1..5 loop
		Dbms_output.put_line( 'adresse  '||G_adresse);
  --       end loop;
     	G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_SEL_adresse';
		P_INS_journal;

	P_SEL_numtel (
     		I_numindiv => G_numadhe
	             );

	Dbms_output.put_line( 'telephone '||G_numtel);

        G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_SEL_numtel';
		P_INS_journal;


	P_SEL_abrege (
		I_numsoc => G_numsoc
		     );

	Dbms_output.put_line( 'abrege '||G_abrege);

        G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_SEL_abrege';
		P_INS_journal;

	P_SEL_assure (
		I_idadhesion => G_idadhesion
		     );

--       	Dbms_output.put_line( 'assure '||G_assure);

-- End if;
--
Dbms_output.put_line( 'contrat' ||G_numgar);
Dbms_output.put_line('refcontrat ' || G_refcontrat);
Dbms_output.put_line('dateadhe ' || G_dateadhe);

        G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_SEL_assure';
		P_INS_journal;


P_TRT_attestation;

-- Dbms_output.put_line( 'Ligne '||G_attestation);
O_attest := G_attestation;
--
        G_niv_msg	:= 3;
		G_msg_adm	:= 'Apres P_TRT_attestation';
		P_INS_journal;


G_attestation := Null;

-- Fetch C_adhesion Into Rec_C_adhesion;

END P_TRAITE_adhesion;

-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--@cpriv
--
-- Complete une chaine avec un caractere
--
Function F_fill (
		I_chaine	IN  Varchar2,
		I_longueur	IN  Number,
		I_character	IN  Varchar2 Default ' ',
		I_alignement	IN  number Default 1
		)
Return Varchar2
IS
L_chaine	Varchar2(250) := I_chaine;
BEGIN
Loop
	Exit When ( Length(L_chaine) >= I_longueur );
	if (I_alignement =1) then
         L_chaine := L_chaine || I_character;
    	else
	  L_chaine := I_character ||  L_chaine;
	end if;
End Loop;
--
Return ( L_chaine );
END F_fill;
--
-- Recherche du regime de l'adherent
--
Procedure P_SEL_regime (
		I_numindiv	IN	Individu.numindiv%type
			)
IS
L_regime	number;
BEGIN
Select	to_number(orgbase)
into 	L_regime
from	individu
where 	numindiv = I_numindiv;

G_numreg := L_regime;

EXCEPTION
 When no_data_found then
 G_numreg := '00';
End P_SEL_regime;


--
-- Recherche de l'identifiant de la compagnie
--
Procedure P_SEL_identifiant (
		I_numsoc	IN	parporte.numsoc%type,
		I_numorg	IN	parporte.numorg%type,
		I_numreg	IN	parporte.numreg%type
			     )
IS
Cursor C_parporte IS
	select	numemetteur
	from 	parporte
	where	numsoc = I_numsoc
	and	numorg = I_numorg
	and 	numreg = '01'
	and 	numporte = 1;
L_numemetteur	parporte.numemetteur%type;
BEGIN
Open C_parporte;
Loop
	Fetch C_parporte Into L_numemetteur;
	Exit When (C_parporte%NotFound OR L_numemetteur Is Not Null);
End Loop;
G_numemetteur := substr (L_numemetteur,1,8);
Close C_parporte;
END P_SEL_identifiant;
--
-- Recherche du type de contrat (groupe ou groupe ouvert)
--
Procedure P_SEL_typcontrat (
		I_numgar	IN	Contrat.numgar%type
			    )
IS
L_typgar	contrat.typgar%type;
BEGIN
	Select 	typgar
	into	L_typgar
	from 	contrat
	where 	numgar = I_numgar;
	If (L_typgar = 1) then
	  G_typgar := '02';
	elsif (L_typgar = 2) then
	  G_typgar := '01';
	else
	  G_typgar := null;
	end if;
EXCEPTION
 when no_data_found then
 G_typgar := null;
END P_SEL_typcontrat;
--
-- Construction de l'attestation
--
Procedure P_TRT_attestation
IS
--L_traite 	Number := I_traite;
i	Binary_integer;
BEGIN

-- G_attestation := null;
-- identification compagnie
G_attestation := F_fill (G_numemetteur,8,'0');
Dbms_output.put_line( 'Identifiant '||G_attestation);
-- identifiant suplementaire
G_attestation := G_attestation || F_fill('',2,'0');
Dbms_output.put_line( 'Identifiant supplementaire '||G_attestation);
-- Message retour
G_attestation := G_attestation || '01';
Dbms_output.put_line( 'Message retour '||G_attestation);
-- Numero de contrat = 1
-- G_attestation := G_attestation || F_fill ('', 16, '1');
G_attestation := G_attestation || F_fill (substr(Upper(G_refcontrat),1,16),16,' ');
-- Complement au numero de contrat
G_attestation := G_attestation || F_fill('' ,16, ' ');
Dbms_output.put_line( 'Complement au numero de contrat '||G_attestation);
-- Etat contrat = 01
G_attestation := G_attestation || '01';
-- Etat prime
G_attestation := G_attestation || '01';
-- Codage statistique
G_attestation := G_attestation || F_fill (G_typgar, 20, ' ');
-- Nom du contrat souscrit
G_attestation := G_attestation || F_fill (Upper(G_refcontrat),30,' ');
Dbms_output.put_line( 'Numero de contrat '||G_attestation);
-- Adresse
-- For i IN 1 .. 5 Loop
--  G_attestation := G_attestation || G_adresse(i);
-- End Loop;
G_attestation := G_attestation || G_adresse;
Dbms_output.put_line( 'Adresse '||substr(G_attestation, 255, 512) );
-- Code commune => rien
G_attestation := G_attestation || F_fill('', 5, ' ');
-- Numero de telephone
G_attestation := G_attestation || F_fill(G_numtel, 10, '0', 2);
-- Numero (code) de l'intermediaire
G_attestation := G_attestation || F_fill('', 6,' ');
-- Type intermediaire = 02
G_attestation := G_attestation || '02';
-- Date d effet du contrat
G_attestation := G_attestation || to_char(G_dateadhe,'ddmmyyyy');
-- Code bureau de gestion
G_attestation := G_attestation || F_fill (G_abrege,10,' ');
-- Filler
G_attestation := G_attestation || F_fill('', 70, ' ');
-- Infos sur les assures (15 maxi)
G_attestation := G_attestation || Rpad (G_assure, 3000, ' ');
-- Filler
-- G_attestation := G_attestation || F_fill('', 37, ' ');
Dbms_output.put_line('Longueur ligne '||length(G_attestation) );
END P_TRT_attestation;
--
-- Infos adresse de l'adherent
--
/*
Procedure P_SEL_adresse (
		I_numindiv	IN pers_adresse.numindiv%Type
		)
IS
i	Binary_integer;
BEGIN
G_adresse := G_adr_null;
For i IN 1 .. 5 Loop
	G_adresse(i) := pk_personne.f_adresse(
				pk_personne.f_idadresse(I_numindiv), i );
		if (G_adresse(i) is null) then
			G_adresse(i) := F_fill(' ', 32);
		else
			G_adresse(i) := F_fill( Upper(f_desaccentue(G_adresse(i))), 32 );
		end if;
End Loop;
END P_SEL_adresse;
*/

Procedure P_SEL_adresse (
		I_numindiv	IN pers_adresse.numindiv%Type
		)
IS
L_idadresse	pers_adresse.idadresse%Type;
L_adresse1	varchar2(45);
L_adresse2	varchar2(45);
L_adresse3	varchar2(45);
L_adresse4	varchar2(45);
L_adresse5	varchar2(45);
L_codpos	varchar2(5);
L_ville		varchar2(30);
/*
L_adresse1	pers_adresse.NO_VOIE%type;
L_adresse2	pers_adresse.BIS%type;
L_adresse3	pers_adresse.TYPE_VOIE%type;
L_adresse4	pers_adresse.NOM_VOIE%type;
L_adresse5	pers_adresse.ADRESSE_2%type;
L_codpos	pers_adresse.codpos%type;
L_ville		pers_adresse.ville%type;
*/

BEGIN
L_idadresse := pk_personne.f_idadresse(I_numindiv);
select 	pk_personne.f_nom (I_numindiv,30,0),
	COMP_ADRESSE ,
       	to_char (NO_VOIE) || ' ' || BIS || ' ' || TYPE_VOIE || ' ' || NOM_VOIE,
	ADRESSE_2,
	CODPOS,
	VILLE
into 	L_adresse1,
	L_adresse2,
	L_adresse3,
	L_adresse4,
	L_codpos,
	L_ville
from 	pers_adresse
where 	idadresse = L_idadresse;

L_adresse1 := F_fill ( Upper(f_desaccentue(substr(L_adresse1,1,32))),32);
L_adresse2 := F_fill ( Upper(f_desaccentue(substr(L_adresse2,1,32))),32);
L_adresse3 := F_fill ( Upper(f_desaccentue(substr(L_adresse3,1,32))),32);
L_adresse4 := F_fill ( Upper(f_desaccentue(substr(L_adresse4,1,32))),32);
L_codpos := F_fill (substr(L_codpos,1,5),5);
L_ville := F_fill ( Upper(f_desaccentue(substr (L_ville, 1, 26))),26);
G_adresse := L_adresse1 || L_adresse2 || L_adresse3 || L_adresse4 || F_fill (' ',32) ||  L_codpos || L_ville;
EXCEPTION
 When no_data_found then
 G_adresse := F_fill (' ', 191);
END P_SEL_adresse;

--
-- Recherche du numero de telephone de l'adherent
--
Procedure P_SEL_numtel (
		I_numindiv	IN pers_adresse.numindiv%Type
		)
IS
L_numtel	individu.tel%type;
BEGIN
Select	tel
into	L_numtel
from 	individu
where	numindiv = I_numindiv;

G_numtel := substr(Replace(L_numtel, '.', ''), 1, 10);
G_numtel := substr(Replace(L_numtel, ' ', ''), 1, 10);
G_numtel := substr(Replace(L_numtel, '-', ''), 1, 10);

EXCEPTION
 When no_data_found then
 G_numtel := null;

End P_SEL_numtel;
--
-- Code du bureau de gestion = abrege de la societe de gestion du contrat
--
Procedure P_SEL_abrege (
		I_numsoc	IN parporte.numsoc%type
			)
IS
L_abrege	pers_morale.abrege%type;
BEGIN
Select 	Upper( f_desaccentue(pers_morale.abrege))  abrege
into	L_abrege
From	pers_morale,
	pers_societe
Where	pers_morale.numindiv = pers_societe.numindiv
and 	pers_societe.numsoc = I_numsoc;

G_abrege := substr (L_abrege,1,10);

EXCEPTION
 When no_data_found then
 G_abrege := null;

End P_SEL_abrege;
--
-- Recherche infos de chaque assure sur le contrat
--
Procedure P_SEL_assure (
		I_idadhesion	IN	adhesion.idadhesion%type
			)
IS

L_nom		individu.nom%type;
L_prenom	individu.prenom%type;
L_numindiv	individu.numindiv%type;
L_datnais	date;
L_regime	individu.orgbase%type;
L_civilite	varchar2(3);
L_parente	Varchar2(2);
L_nbr_gar	number;

Cursor C_assu
is
select	individu.nom,
	individu.prenom,
	individu.numindiv,
	individu.datnais,
	individu.orgbase
from	individu
where numindiv in (select numindiv
		  from adhesion
		  where idadhesion = I_idadhesion
		  and	adhesion.etat =1
		  and	adhesion.rang!=2
		  and	sysdate between datapli and nvl(datper, Sysdate)
		  );

Rec_C_assu	C_assu%rowtype;
Nb_adr	Number := 0;
BEGIN
G_assure := null;
Open C_assu;
loop
  	Fetch C_assu into Rec_C_assu;
  	Exit when (C_assu%NOTFOUND);
  	Nb_adr := Nb_adr + 1;
  	If (Nb_adr > 15 ) then
		Exit;
	End If;

  L_nom := Rec_C_assu.nom;
  L_prenom := Rec_C_assu.prenom;
  L_numindiv := Rec_C_assu.numindiv;
  L_datnais := Rec_C_assu.datnais;
  L_datnais := nvl(L_datnais, '01-jan-9999');
  L_regime := Rec_C_assu.orgbase;

 P_SEL_civilite ( I_numindiv => L_numindiv,
		  O_civilite => L_civilite
		);
 P_SEL_parente ( I_numindiv => L_numindiv,
		  O_parente => L_parente
		);
 P_SEL_nbr_gar (  I_numindiv => L_numindiv,
 		  I_idadhesion => G_idadhesion,
		  O_nbr_gar => L_nbr_gar
		);


-- Civilite
 G_assure := G_assure || F_fill (L_civilite,3);
-- Nom
 G_assure := G_assure || F_fill (substr(L_nom,1,32),32);
-- Prenom
 G_assure := G_assure || F_fill (substr(L_prenom,1,32),32);
-- Date de naissance
 G_assure := G_assure || F_fill (to_char(L_datnais, 'ddmmyyyy'), 8);
-- Type de garantie
G_assure := G_assure || '01';
-- Regime social
G_assure := G_assure || F_fill (substr(L_regime,1,2),2,'0',2);
-- Parente avec l'assure principal
G_assure := G_assure || F_fill (substr(L_parente,1,2),2);
-- Situation administrative
G_assure := G_assure || '01';
-- Formule souscrite 1
G_assure := G_assure || F_fill (substr(to_char(G_numgar) || '-' || L_nbr_gar,1,15),15);
-- Formule souscrite 2
 G_assure := G_assure || F_fill (' ',15);
-- Zone tecnhnique utile au calcul
 G_assure := G_assure || F_fill (' ',50);
-- Filler
 G_assure := G_assure || F_fill (' ',37);


end loop;
close C_assu;
G_assure := substr (G_assure,1,3000);
End P_SEL_assure;
--
-- Civilite de l'affilie
--
Procedure P_SEL_civilite (
	I_numindiv	IN	Individu.numindiv%type,
        O_civilite	OUT	varchar2
			  )
IS
L_civilite	libelle.libelle%type;
BEGIN
 select	libelle
 into 	L_civilite
 from 	libelle
 where 	mnemo = 'CODC1'
 and	code = (select codcourrier1
		from individu
		where numindiv = I_numindiv);
 O_civilite := substr(L_civilite,1,3);
EXCEPTION
 when no_data_found then
 O_civilite := null;
End P_SEL_civilite;
--
-- Parente avec l'assure principal
--
Procedure P_SEL_parente (
	I_numindiv 	IN 	individu.numindiv%type,
	O_parente	OUT 	Varchar2
		)
IS
L_parente libelle_bis.libelle%type;
BEGIN
 select	libelle
 into 	L_parente
 from 	libelle_bis
 where 	mnemo ='PARENTE'
 and 	code = (select typadr
		from individu
		where numindiv = I_numindiv);
 O_parente := substr (L_parente,1,2);
EXCEPTION
 When no_data_found then
 O_parente := null;
End P_SEL_parente;

--
-- Comptage des garanties pour obligatoire et facultatif
--
Procedure P_SEL_nbr_gar (
	I_idadhesion	IN	adhesion.idadhesion%type,
	I_numindiv 	IN 	individu.numindiv%type,
	O_nbr_gar	OUT 	number
		)
IS
L_nbr_gar	number;
BEGIN
select count(*)
into L_nbr_gar
from adhesion
where 	adhesion.idadhesion = I_idadhesion
and	adhesion.numindiv = I_numindiv
and	adhesion.etat =1
and	sysdate between adhesion.datapli and nvl(adhesion.datper, Sysdate);
O_nbr_gar := L_nbr_gar;
EXCEPTION
When no_data_found then
O_nbr_gar := 0;
End P_SEL_nbr_gar;

-- Insertion dans journal_adm
Procedure P_INS_journal
IS
L_idligne	Number;
BEGIN
If ( G_niv_msg <= G_max_msg ) then
	G_idligne := G_idligne + 1;
	If ( G_niv_msg = 0 ) then
		L_idligne := -1 * G_idligne;
	Else
		L_idligne := G_idligne;
	End If;
	PK_trace.P_INS_journal_adm (
		I_nom_traitement => G_nom_traitement,
		I_session	 => G_session,
		I_niv_msg	 => G_niv_msg,
		I_msg_adm	 => G_msg_adm,
		I_idligne	 => L_idligne);
	commit;
End If;
END P_INS_journal;

-- ------------------------------------ Fin des corps des procedures privees --
END;
/
