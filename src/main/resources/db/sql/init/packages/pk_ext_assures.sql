CREATE OR REPLACE PACKAGE ARTHUS.pk_ext_assures AS
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
	I_refcie	IN  contrat.refcie%Type,
	O_attest	OUT Varchar2
	);
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_ext_assures AS
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
G_numadhe	adhe_cntrt.numadhe%type;
G_adresse	Varchar2(256);
G_numtel	individu.tel%type;
G_dateadhe	adhe_cntrt.date_adhe%type;
G_abrege	varchar2(10);
G_attestation	Varchar2(3500);
G_assure	Varchar2(3000);
G_adr_null	T_adresse;

-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%Type default 'pk_ext_assures';
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
		  adhe_cntrt.numgar,adhe_cntrt.idadhesion,individu.typadr;

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
-- Numero de la garantie couvrant l'assure
--
Procedure P_SEL_numfor (
	I_idadhesion	IN	adhesion.idadhesion%type,
	I_numindiv 	IN 	individu.numindiv%type,
	O_numfor	OUT 	number
		);
--
-- Rang de l'assure sur la garantie
--
Procedure P_SEL_rang (
	I_idadhesion	IN	adhesion.idadhesion%type,
	I_numindiv 	IN 	individu.numindiv%type,
	O_rang		OUT 	number
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
	I_refcie	IN  contrat.refcie%Type,
	O_attest	OUT Varchar2
	)
IS
Rec_C_adhesion	C_adhesion%Rowtype;
BEGIN
--
G_deb_numgar := I_deb_numgar;
G_fin_numgar := I_fin_numgar;
G_refcie := I_refcie;
--
If Not C_adhesion%ISOPEN then
	Open C_adhesion;
		G_niv_msg	:= 1;
		G_msg_adm	:= 'Début traitement - ouverture du curseur'  ;
		P_INS_journal;

End if;
--
Fetch C_adhesion Into Rec_C_adhesion;
--
If ( C_adhesion%NotFound ) then
	Close C_adhesion;
	Raise No_data_found;
End if;
--

	G_idadhesion := Rec_C_adhesion.idadhesion;
	G_numgar := Rec_C_adhesion.numgar;
	G_refcontrat := Rec_C_adhesion.refcie;
	G_numsoc := Rec_C_adhesion.numinterm;
	G_numorg := Rec_C_adhesion.numorg;
	G_numadhe := Rec_C_adhesion.numadhe;
	G_dateadhe := Rec_C_adhesion.date_adhe;

		G_niv_msg	:= 1;
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

		G_niv_msg	:= 1;
		G_msg_adm	:= 'Apres P_sel_régime';
		P_INS_journal;


	P_SEL_adresse (
		I_numindiv => G_numadhe
	              );
		Dbms_output.put_line( 'adresse  '||G_adresse);
     	G_niv_msg	:= 1;
		G_msg_adm	:= 'Apres P_SEL_adresse';
		P_INS_journal;

	P_SEL_numtel (
     		I_numindiv => G_numadhe
	             );

	Dbms_output.put_line( 'telephone '||G_numtel);

        G_niv_msg	:= 1;
		G_msg_adm	:= 'Apres P_SEL_numtel';
		P_INS_journal;


	P_SEL_abrege (
		I_numsoc => G_numsoc
		     );

	Dbms_output.put_line( 'abrege '||G_abrege);

        G_niv_msg	:= 1;
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

        G_niv_msg	:= 1;
		G_msg_adm	:= 'Apres P_SEL_assure';
		P_INS_journal;


P_TRT_attestation;

-- Dbms_output.put_line( 'Ligne '||G_attestation);
O_attest := G_attestation;
--
        G_niv_msg	:= 1;
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
-- Construction de l'enregistrement
--
Procedure P_TRT_attestation
IS
i	Binary_integer;
BEGIN

-- Numero du contrat
G_attestation := G_numgar ||';';
Dbms_output.put_line( 'Identifiant '||G_attestation);

-- Reference externe du contrat
G_attestation := G_attestation || substr(Upper(G_refcontrat),1,16) ||';';
Dbms_output.put_line( 'Numero de contrat '||G_attestation);

-- Numero de l'assure principal
G_attestation := G_attestation || G_numadhe ||';';

-- Nom, prenom et adresse de l'assure principal
G_attestation := G_attestation || G_adresse;
Dbms_output.put_line( 'Adresse '||substr(G_attestation, 255, 512) );

-- Numero de telephone
G_attestation := G_attestation || F_fill (G_numtel,10,'0',2) ||';';

-- Date d effet de l'adhesion
G_attestation := G_attestation || to_char(G_dateadhe,'dd/mm/yyyy') ||';';

-- Infos sur les assures (15 maxi)
G_attestation := G_attestation || G_assure ||';';
--G_attestation := G_attestation || Rpad (G_assure, 3000, ' ') ||';';
Dbms_output.put_line('Longueur ligne '||length(G_attestation) );

END P_TRT_attestation;
--
-- Infos adresse de l'adherent
--

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

L_adresse1 := L_adresse1;
L_adresse2 := L_adresse2;
L_adresse3 := L_adresse3;
L_adresse4 := L_adresse4;
L_codpos := F_fill (L_codpos,5,'0',2);
L_ville := L_ville;
G_adresse := 	L_adresse1 || ';'
		|| L_adresse2 || ';'
		|| L_adresse3 || ';'
		|| L_adresse4 || ';'
		|| L_codpos || ';'
		|| L_ville || ';';
EXCEPTION
 When no_data_found then
 G_adresse := 	F_fill (' ', 32) || ';'
 		|| F_fill (' ', 32) || ';'
 		|| F_fill (' ', 32) || ';'
 		|| F_fill (' ', 32) || ';';
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
 G_numtel := '0000000000';

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
L_matorg	individu.matorg%type;
L_cless		individu.cless%type;
L_civilite	varchar2(3);
L_parente	Varchar2(2);
L_nbr_gar	number;
L_numfor	number;
L_rang		number;

Cursor C_assu
is
select	individu.nom,
	individu.prenom,
	individu.numindiv,
	individu.datnais,
	individu.orgbase,
	individu.matorg,
	individu.cless
from	individu
where numindiv in (select numindiv
		  from adhesion
		  where idadhesion = I_idadhesion
		  and	adhesion.etat =1
		  and adhesion.rang!=2
		  and	sysdate between datapli and nvl(datper, Sysdate)
		  )
Order By
	  individu.typadr;

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
  L_matorg := Rec_C_assu.matorg;
  L_cless := Rec_C_assu.cless;

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
 P_SEL_numfor (  I_numindiv => L_numindiv,
 		  I_idadhesion => G_idadhesion,
		  O_numfor => L_numfor
		);
 P_SEL_rang	(  I_numindiv => L_numindiv,
 		  I_idadhesion => G_idadhesion,
		  O_rang => L_rang
		);


-- Numero d'assure
 G_assure := G_assure || L_numindiv ||';';
-- Civilite
 G_assure := G_assure || L_civilite ||';';
-- Nom
 G_assure := G_assure || L_nom ||';';
-- Prenom
 G_assure := G_assure || L_prenom ||';';
-- Date de naissance
 G_assure := G_assure || to_char(L_datnais, 'dd/mm/yyyy') ||';';
-- Regime social
G_assure := G_assure || F_fill (L_regime,13,'0',2) ||';';
-- Numero SS
G_assure := G_assure || L_matorg || F_fill (L_cless,2,'0',2) ||';';
-- Parente avec l'assure principal
G_assure := G_assure || L_parente ||';';
-- Nombre de garanties
G_assure := G_assure || F_fill (L_nbr_gar,2,'0',2) ||';';
-- Numero de la garantie
G_assure := G_assure || L_numfor ||';';
-- Libelle de la garantie
G_assure := G_assure || f_libgar(L_numfor) ||';';
-- Rang de l'assure sur la garantie
G_assure := G_assure || L_rang ||';';

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
select 	count(*)
into 	L_nbr_gar
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

--
-- Numero de la garantie couvrant l'assure
--
Procedure P_SEL_numfor (
	I_idadhesion	IN	adhesion.idadhesion%type,
	I_numindiv 	IN 	individu.numindiv%type,
	O_numfor	OUT 	number
		)
IS
L_numfor	number;
BEGIN
select 	numfor
into 	L_numfor
from adhesion
where 	adhesion.idadhesion = I_idadhesion
and	adhesion.numindiv = I_numindiv
and	adhesion.etat =1
and	sysdate between adhesion.datapli and nvl(adhesion.datper, Sysdate);
O_numfor := L_numfor;
EXCEPTION
When no_data_found then
O_numfor := 0;
When too_many_rows then
O_numfor := 0;
End P_SEL_numfor;

--
-- Recherche du rang de l'assure sur la garantie
--
Procedure P_SEL_rang (
	I_idadhesion	IN	adhesion.idadhesion%type,
	I_numindiv 	IN 	individu.numindiv%type,
	O_rang		OUT 	number
		)
IS
L_rang	number;
BEGIN
select 	adhesion.rang
into 	L_rang
from adhesion
where 	adhesion.idadhesion = I_idadhesion
and	adhesion.numindiv = I_numindiv
and	adhesion.etat =1
and	sysdate between adhesion.datapli and nvl(adhesion.datper, Sysdate);
O_rang := L_rang;
EXCEPTION
When no_data_found then
O_rang := 0;
When too_many_rows then
O_rang := 0;
End P_SEL_rang;

--

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
