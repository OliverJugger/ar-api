CREATE OR REPLACE PACKAGE ARTHUS."PK_CP_ACTE_REG"
AS
--
-- Chaine de reconnaissance SCCS
-- %W%   %E%

   -- -- CONSTANTES PUBLIQUE -----------------------------------------------------

  erreur                VARCHAR2(200);
  flag_erreur           BINARY_INTEGER ;
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
PROCEDURE cp_acte_reg	(
      pRegime 	In number default null,
      pRegimeOb  In number default null,
			pPrg      In Varchar2 default null,
      pPorte    in number default 1,
      I_session	IN	NUMBER				Default 1,
      I_niv_msg	IN	NUMBER				Default 1,
      O_found	OUT	NUMBER,
      O_erreur	OUT	VARCHAR2
      );

PROCEDURE insertActeReg	(
			pRegime 	In Number,
      pRegimeOb	In Number,
      O_erreur	OUT	VARCHAR2
			);
PROCEDURE insertZoneTrf	(
			pRegime 	In Number,
      pRegimeOb	In Number,
      O_erreur	OUT	VARCHAR2
			);
PROCEDURE insertPorteNatFrais	(
			pRegime 	In Number,
      pRegimeOb	In Number,
      pPorte in Number,
      O_erreur	OUT	VARCHAR2
			);
END PK_CP_ACTE_REG;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_CP_ACTE_REG"
As
Procedure P_INS_journal;
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_cp_acte_reg';
G_msg_adm		journal_adm.msg_adm%TYPE;
G_session		journal_adm.id_session%TYPE default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%TYPE;
-- Chaine de reconnaissance SCCS
-- %W%  %E%
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
----------------------------------------------------------------------------
-- -- CORPS DES PROCEDURES PUBLIQUES --------------------------------------

PROCEDURE cp_acte_reg	(
			pRegime 	In number default null,
      pRegimeOb  In number default null,
			pPrg      In Varchar2 default null,
      pPorte    in number default 1,
      I_session	IN	NUMBER				Default 1,
      I_niv_msg	IN	NUMBER				Default 1,
      O_found	OUT	NUMBER,
      O_erreur	OUT	VARCHAR2
			) IS


BEGIN
  O_found         := 1;

	G_max_msg       := I_niv_msg;
	G_session       := I_session;
  --
	G_niv_msg	:= 1;
	G_msg_adm	:= 'PK_CP_ACTE_REG Debut de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
  IF pRegime != 1 THEN
    Case pPrg
      When 'PE16' THEN insertZoneTrf (pRegime,pRegimeOb,O_erreur);
      When 'PE13' THEN insertActeReg (pRegime,pRegimeOb,O_erreur);
      When 'PE23' THEN insertPOrteNatFrais(pRegime,pRegimeOb,pPorte,O_erreur);
      ELSE
           O_erreur:= 'paramétrage incomplet' ;
    END CASE;
    O_found	:= 0;
  ELSE
    O_erreur:='Copie des données du régime général pour le régime général non autorisée';
  END IF;
  G_msg_adm	:= 'PK_CP_ACTE_REG Fin de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
END;

PROCEDURE insertActeReg(
      pRegime IN Number,
      pRegimeOb	In Number,
      O_erreur	OUT	VARCHAR2) IS
    Cursor C_acte IS
  	Select	*
  	From	ACTE_REG
  	Where	acte_reg.regime=pRegimeOb;

    Rec_C_acte C_acte%Rowtype;
BEGIN
  G_msg_adm	:= 'insertActeReg Debut de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
  P_INS_journal;
  OPEN C_acte;

  LOOP
    Fetch C_acte Into Rec_C_acte;
    EXIT WHEN C_acte%NOTFOUND;

    Insert into ACTE_REG(codfrais_reg,libelle,regime,type_acte) values
    (Rec_C_acte.codfrais_reg,Rec_C_acte.libelle,pRegime,Rec_C_acte.type_acte);
  END LOOP;
  Close C_acte;

  COMMIT;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    flag_erreur := 1;
    G_niv_msg	:= 0;
    O_erreur := SUBSTR('insertActeReg : '||SQLERRM, 1, 180);
    DBMS_OUTPUT.PUT_LINE(O_erreur);
    G_msg_adm	:= SUBSTR('PK_CP_ACTE_REG - insertActeReg - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
END;


PROCEDURE insertZoneTrf(
      pRegime IN Number,
      pRegimeOb	In Number,
      O_erreur	OUT	VARCHAR2) IS
  Cursor C_trf IS
  	Select	*
  	From	ZONE_TRF
  	Where	zone_trf.regime=pRegimeOb;
     Rec_C_trf C_trf%Rowtype;
BEGIN
  G_msg_adm	:= 'insertZoneTrf Debut de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
  P_INS_journal;
  OPEN C_trf;

  LOOP
    Fetch C_trf Into Rec_C_trf;
    EXIT WHEN C_trf%NOTFOUND;

    Insert into ZONE_TRF(regime,code_tarif,code_zone,code_secteur,code_isd,code_depass) values
    (pRegime,Rec_C_trf.code_tarif,Rec_C_trf.code_zone,Rec_C_trf.code_secteur,Rec_C_trf.code_isd,Rec_C_trf.code_depass);
  END LOOP;
  Close C_trf;

  COMMIT;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    flag_erreur := 1;
    G_niv_msg	:= 0;
    erreur := SUBSTR('insertZoneTrf : '||SQLERRM, 1, 180);
    DBMS_OUTPUT.PUT_LINE(erreur);
    G_msg_adm	:= SUBSTR('PK_CP_ACTE_REG - insertZoneTrf - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
END;


PROCEDURE insertPorteNatFrais(
      pRegime IN Number,
      pRegimeOB	In Number,
      pPorte in Number,
      O_erreur	OUT	VARCHAR2) IS
  Cursor C_natfrais IS
  	Select	*
  	From	PORTE_NATFRAIS
  	Where	porte_natfrais.regime=pRegimeOb
    and porte_natfrais.numporte=pPorte ;

  Rec_C_natfrais C_natfrais%Rowtype;
BEGIN
  G_msg_adm	:= 'insertPorteNatFrais Debut de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
  P_INS_journal;
  OPEN C_natfrais;

  LOOP
    Fetch C_natfrais Into Rec_C_natfrais;
    EXIT WHEN C_natfrais%NOTFOUND;

    Insert into PORTE_NATFRAIS(numporte, codfrais_porte, codfrais,regime,code_spec,
                                codfrais_porte_nc, action,motif, codfrais_porte_c,code_zone,
                                creation,numutil,champ,operateur,valeur,champ2,operateur2,valeur2) values
    (pPorte, Rec_C_natfrais.codfrais_porte, Rec_C_natfrais.codfrais,pRegime,Rec_C_natfrais.code_spec,
                                Rec_C_natfrais.codfrais_porte_nc, Rec_C_natfrais.action,Rec_C_natfrais.motif, Rec_C_natfrais.codfrais_porte_c,Rec_C_natfrais.code_zone,
                                sysdate,Rec_C_natfrais.numutil,Rec_C_natfrais.champ,Rec_C_natfrais.operateur,Rec_C_natfrais.valeur,Rec_C_natfrais.champ2,Rec_C_natfrais.operateur2,Rec_C_natfrais.valeur2);
  END LOOP;
  Close C_natfrais;

  COMMIT;

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    flag_erreur := 1;
    G_niv_msg	:= 0;
    erreur := SUBSTR('insertPorteNatFrais : '||SQLERRM, 1, 180);
    DBMS_OUTPUT.PUT_LINE(erreur);
    G_msg_adm	:= SUBSTR('PK_CP_ACTE_REG - insertPorteNatFrais - '||SUBSTR(SQLERRM(SQLCODE),1,128),1,132);
    P_INS_journal;
END;
-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv

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
  End If;
END P_INS_journal;
---------------- Fin des corps des procedures privees --
END PK_CP_ACTE_REG;
/
