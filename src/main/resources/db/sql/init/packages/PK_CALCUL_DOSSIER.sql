CREATE OR REPLACE PACKAGE ARTHUS."PK_CALCUL_DOSSIER"
AS
/*============================================================================*/
/* PACKAGE      : PK_CALCUL_DOSSIER.sql                                       */
/* Domaine      : SantÚ                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* CrÚation     : 10/08/2011                                                  */
/* Description  : package permettant de calculer prestation par prestation ou */
/*                toutes les prestation d'un dossier retourne les erreurs du  */
/*                moteur de calcul                                            */
/*============================================================================*/
/* Evolution    : Projet SP SANTE                                             */
/* Auteur       : JBO                                                         */
/* Date         : 19/07/2011                                                  */
/* Commentaire  : Mise en place du cartouche/ Externalisation de P_CPYL_PEC   */
/*                présent dans GS12.fmb                                       */
/*============================================================================*/
/* Correction   : JBO / 21/01/2013 / P_CALCUL_DOSSIER_SANTE, P_CALCUL_RAC     */
/*                Lors du calcul de la prestation,on doit passer le numassu   */
/*                (assuré principal) et non le numindiv                       */
/*============================================================================*/
/* Evolution    : MUR / 19/0103/2014 / P_GEST_CALCUL                          */
/*                ajout de O_mt_prest_sin                                     */
/*============================================================================*/
/* Evolution    : MUR / 19/09/2014 / P_GEST_CALCUL                            */
/*                modif exclusion sinistres annulés                           */
/*============================================================================*/
/* Evolution    : JBO / 09/02/2015 / P201412001_M00074_CCAM_Welcare           */
/*                1) Fusion de la V7 et V8                                    */
/*                2) Ajout de la base de remboursement pour le calcul         */
/*                   d'une prestation santé pour un acte donné (impact majeur)*/
/*                3) Ajout liquidation manuelle de pec                        */
/*============================================================================*/
/* Evolution    : ABO/ 16/09/2016/ 5010 dents du sourire                      */
/*============================================================================*/
/*============================================================================*/
/* Evolution    : CLI/ 13/09/2017 Ajout de la procédure de duplication de forms*/
/*============================================================================*/
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

-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------

PROCEDURE P_CALCUL_RAC(
  P_codfrais    IN sinistre_sante.codfrais%TYPE,
  P_datsin      IN VARCHAR2,
  P_taux        IN NUMBER,
  P_mtremb      IN NUMBER,
  P_baseremb    IN NUMBER default NULL,
  P_mtfrais     IN NUMBER,
  P_devise      IN NUMBER,
  P_quantite    IN NUMBER,
  P_coeff       IN NUMBER,
  P_numindiv    IN individu.numindiv%TYPE,
  P_numbene     IN individu.numindiv%TYPE,
  P_type_bene   IN NUMBER,
  P_ordre       IN NUMBER,
  P_type        IN VARCHAR2,
  O_mtprest     OUT NUMBER,
  O_erreur      OUT NUMBER,
  O_msg_erreur  OUT VARCHAR2,
  p_derog       IN VARCHAR2 DEFAULT NULL -- paramètre définissant la dérogation optique sur les WS -- valeurs possibles : OPTI (si derogation ) ou null (pas de derogation)
);
PROCEDURE P_CALCUL_DOSSIER_SANTE(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne    IN sinistre_sante.numligne%TYPE default NULL,
  P_type        IN VARCHAR2,
  P_tot_prest   IN NUMBER default -1,
  O_erreur      OUT NUMBER,
  O_msg_erreur  OUT VARCHAR2,
  p_derog       IN VARCHAR2 DEFAULT NULL --paramètre définissant la dérogation optique sur les WS -- valeurs possibles : OPTI (si derogation ) ou null (pas de derogation)
);
PROCEDURE P_GEST_CALCUL(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne    IN sinistre_sante.numligne%TYPE,
  P_type        IN VARCHAR2,
  O_erreur      OUT NUMBER,
  O_msg_erreur  OUT VARCHAR2,
  O_mt_prest    OUT sinistre_sante.mtprest_reel%TYPE,
  O_mt_prest_sin OUT sinistre.mtreel%TYPE
  );
PROCEDURE P_RETOUR_GS19XIT (
  P_dll IN VARCHAR2,
  P_num_dossier IN VARCHAR2,
  P_numligne IN NUMBER,
  P_sid IN NUMBER,
  O_mtreel OUT NUMBER,
  O_erreur OUT NUMBER
);

PROCEDURE P_Delete_travsn(P_sid  NUMBER default null );
PROCEDURE P_Calcul_Sinistre_dev(P_num_dossier IN dossier_sante.num_dossier%type);
PROCEDURE P_Ajust_Arrondi_dev(P_num_dossier IN dossier_sante.num_dossier%type);

PROCEDURE P_CPYL_PEC( P_num_dossier_Pec IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                    , P_num_dossier     IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE
                    , P_num_porte       IN  DOSSIER_SANTE.NUMPORTE%TYPE
                    , O_sens_porte      OUT NUMBER
                    , O_erreur          OUT NUMBER);

FUNCTION F_LIQUID_AUTO(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS        IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER      IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE)
RETURN NUMBER;

FUNCTION F_LIQUID_MAN(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS        IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER      IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE
                     , P_NUMPORTE        IN  DOSSIER_SANTE.NUMPORTE%TYPE)
RETURN NUMBER;

FUNCTION F_ENVOI_WS(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS        IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER      IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE)
RETURN NUMBER;

FUNCTION F_Num_Dossier (a_debut IN Date) RETURN VARCHAR2;

FUNCTION F_ANNUL_DOSSIER_LIQ(i_numremise IN porte_remise.numremise%TYPE,
                             i_num_dossier_PEC IN dossier_sante.num_dossier%TYPE)
RETURN NUMBER;
FUNCTION F_ANNUL_DOSSIER_FACT(i_numremise IN porte_remise.numremise%TYPE)
RETURN NUMBER;

FUNCTION F_ANNUL_BLOCAGE_FACT(i_numremise IN porte_remise.numremise%TYPE,
                               i_refcie    IN sinistre_porte.refcie%TYPE,
                               i_idfactpe IN sinistre_porte.idfactpe%TYPE)
RETURN NUMBER;

FUNCTION F_LIQ_DOSSIER( i_refcie     IN sinistre_porte.refcie%TYPE,
                        i_numremise  IN porte_remise.numremise%TYPE,
                        i_numfact    IN dossier_sante.num_fact_pec%TYPE,
                        i_datfact    IN dossier_sante.date_fact_pec%TYPE)
RETURN NUMBER;
FUNCTION F_MAJ_SNTRPRT( i_numremise  IN sinistre_porte.numremise%TYPE,
                        i_numporte   IN sinistre_porte.numporte%TYPE,
                        i_numsin     IN sinistre_porte.numsin%TYPE,
                        i_refcie     IN sinistre_porte.refcie%TYPE,
                        i_montant    IN sinistre_porte.mtprestarmedi%TYPE,
                        i_etat       IN sinistre_porte.etat%TYPE )
RETURN BOOLEAN;
PROCEDURE P_MAJ_SNTR_DOSSIER( i_numremise  IN sinistre_porte.numremise%TYPE,
                        i_numporte   IN sinistre_porte.numporte%TYPE  ,
                        i_numutil    IN utilisateurs.numutil%TYPE,
                        o_numano    OUT NUMBER) ;
PROCEDURE P_DUPLIQUE_DOSSIER_SANTE( i_num_dossier IN dossier_sante.num_dossier%type,
                                    i_num_dossier_out OUT dossier_sante.num_dossier%type);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_CALCUL_DOSSIER;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_CALCUL_DOSSIER"
As
/*============================================================================*/
/* PACKAGE      : PK_CALCUL_DOSSIER.sql                                       */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* CrÚation     : 10/08/2011                                                  */
/* Description  : package permettant de calculer prestation par prestation ou */
/*                toutes les prestation d'un dossier retourne les erreurs du  */
/*                moteur de calcul                                            */
/*============================================================================*/
/* Evolution    : Projet SP SANTE                                             */
/* Auteur       : JBO                                                         */
/* Date         : 19/07/2011                                                  */
/* Commentaire  : Mise en place du cartouche/ Externalisation de P_CPYL_PEC   */
/*                présent dans GS12.fmb                                       */
/*============================================================================*/
/* Correction   : JBO / 21/01/2013 / P_CALCUL_DOSSIER_SANTE, P_CALCUL_RAC     */
/*                Lors du calcul de la prestation,on doit passer le numassu   */
/*                (assuré principal) et non le numindiv                       */
/*============================================================================*/
/* Evolution    : MUR / 19/0103/2014 / P_GEST_CALCUL                          */
/*                ajout de O_mt_prest_sin                                     */
/*============================================================================*/
/* Evolution    : MUR / 19/09/2014 / P_GEST_CALCUL                            */
/*                modif exclusion sinistres annulÚs                           */
/*============================================================================*/
/* Evolution    : JBO / 09/02/2015 / P201412001_M00074_CCAM_Welcare           */
/*                1) Fusion de la V7 et V8                                    */
/*                2) Ajout de la base de remboursement pour le calcul         */
/*                   d'une prestation santÚ pour un acte donnÚ (impact majeur)*/
/*                3) Ajout liquidation manuelle de pec                        */

   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--
FUNCTION F_LIQUID_PEC(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS        IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_TYPE_REF         IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER      IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE)
RETURN NUMBER;
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

-- ------------------------------------------------- Fin des procedures privees --


-- Variables de P_INS_journal
G_nom_traitement  Constant journal_adm.nom_traitement%TYPE default 'PK_CALCUL_DOSSIER';
G_msg_adm    journal_adm.msg_adm%TYPE;
G_session    journal_adm.id_session%TYPE default 1;
G_niv_msg    journal_adm.niv_msg%TYPE := 1;
G_max_msg    journal_adm.niv_msg%TYPE := 1;
G_idligne    journal_adm.idligne%TYPE := 0;
G_erreur    journal_adm.msg_adm%TYPE;
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



-- -------------------------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
-- -- CORPS DES PROCEDURES PUBLIQUES --------------------------------------
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CALCUL_RAC  / ABO 09/01/2012                            */
/* Type         :  Privee                                                    */
/* Description  :  Calcul le reste à charge d une prestation santé           */
/* Entree       :  Informations sur la prestation                            */
/* Retour       :  le code anomalie                                          */
/* Correction   :  JBO le 21/01/2013 :Lors du calcul de la prestation,on doit*/
/*                 passer le numassu (assuré principal) et non le numindiv   */
/*                 ==> Rajout de f_numassu(P_numindiv)                       */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CALCUL_RAC(
  P_codfrais    IN sinistre_sante.codfrais%TYPE,
  P_datsin      IN VARCHAR2,
  P_taux        IN NUMBER,
  P_mtremb      IN NUMBER,
  P_baseremb    IN NUMBER default NULL,
  P_mtfrais     IN NUMBER,
  P_devise      IN NUMBER,
  P_quantite    IN NUMBER,
  P_coeff       IN NUMBER,
  P_numindiv    IN individu.numindiv%TYPE,
  P_numbene     IN individu.numindiv%TYPE,
  P_type_bene   IN NUMBER,
  P_ordre       IN NUMBER,
  P_type        IN VARCHAR2,
  O_mtprest     OUT NUMBER,
  O_erreur      OUT NUMBER,
  O_msg_erreur  OUT VARCHAR2,
  p_derog       IN VARCHAR2 default NULL --paramètre définissant la dérogation optique sur les WS -- valeurs possibles : OPTI (si derogation ) ou null (pas de derogation)
)IS
  L_msg       VARCHAR2(512);
  retourF     integer:=0;
  Ltype_calcul   varchar2(30);
  l_sid NUMBER(8);
  l_mtprest NUMBER(11,2);
  l_trace varchar2(10);
  l_nom       varchar2(30);
  l_pwd       Varchar2(12);
BEGIN
  O_erreur :=0;
  Select  nom, password
    Into  l_nom, l_pwd
    From  Utilisateurs
    Where  numuid = uid;

  select to_char(sys_context('userenv', 'sid'))
    into l_sid from dual;
  l_trace := f_trace_usrxit;

 --   l_trace:='totale';
    BEGIN
      L_msg := gs19_xit(
            l_sid,
            P_ordre,
            P_codfrais,
            P_datsin,
            1,
            P_taux,
            P_mtremb,
            P_baseremb,--base de remboursement
            nvl(P_mtfrais,0),
            0, --autre rmb
            P_numindiv,
            P_devise,
            P_quantite,
            P_coeff,
            to_char(sysdate,'dd/mm/yyyy'),
            f_numassu(P_numindiv),
            P_numbene,
            P_type_bene,
            0,
            '',  --reference
            '0',--numdossier
            0,
            P_type,
            l_trace,
            l_nom,
            l_pwd,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            NULL, -- CAS
            p_derog --OPTI (si derogation ) ou null (si pas de derogation)
            );
    EXCEPTION
      When others THEN
        O_erreur:=5;
        O_msg_erreur :=SQLERRM;
        RETURN;
    END;
    P_RETOUR_GS19XIT(L_msg,'0',P_ordre,l_sid,l_mtprest,retourF );


    IF retourF= 1 THEN -- erreur bloguante du calcul de prestation
      l_mtprest := 0;
      O_erreur:=5;
    END IF;
    CASE retourF
                WHEN 1 THEN  O_erreur:=5; -- bloquant
                l_mtprest:= 0;
                WHEN 2 THEN  O_erreur:=6; -- carence
                WHEN 3 THEN  O_erreur:=7; -- plafond
                WHEN 4 THEN  O_erreur:=8; -- franchise
                ELSE NULL;
              END CASE;
    O_mtprest:=l_mtprest;
    commit;

    EXCEPTION
      When others THEN
        O_erreur:=5;
        O_msg_erreur :=SQLERRM;
END P_CALCUL_RAC;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CALCUL_DOSSIER_SANTE  / ABO 09/01/2012                  */
/* Type         :  Privee                                                    */
/* Description  :  Calcul le dossier santé                                   */
/* Entree       :  Informations sur la prestation                            */
/* Retour       :  le code anomalie                                          */
/* Correction   :  JBO le 21/01/2013 :Lors du calcul de la prestation,on doit*/
/*                 passer le numassu (assuré principal) et non le numindiv   */
/*                 =>Rajout du numassu dans le curseur et dans l appel a GS19*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_CALCUL_DOSSIER_SANTE(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne    IN sinistre_sante.numligne%TYPE default NULL,
  P_type        IN VARCHAR2,
  P_tot_prest   IN NUMBER default -1,
  O_erreur      OUT NUMBER,
  O_msg_erreur  OUT VARCHAR2,
  p_derog       IN VARCHAR2 default NULL --paramètre définissant la dérogation optique sur les WS -- valeurs possibles : OPTI (si derogation ) ou null (pas de derogation)
)IS

-- Lance le calcul de toutes les ligne du dossier avec le statut A calculer
-- 13/07/2010 ABO si le dossier est de type 4 on rÚalise un devis dont les sinistres ne pourront pas
-- etre décopmptés car sinistre.sens = -1
  L_tab_prmt  prmt%ROWTYPE;
  L_tab_indvs indvs%ROWTYPE;
  L_trouve     BOOLEAN;
  L_MAJ_crrr     BOOLEAN DEFAULT FALSE; -- Si true alors MAJ crrr
  L_prest      Number;
  L_msg       VARCHAR2(512);
  retourF     integer:=0;
  Lmodif       integer;
  l_nom       varchar2(30):=NULL;
  l_pwd       Varchar2(12);
  Ltyp_doss     integer;
  Lnumbene     number(6);
  Ltype_bene     number(2);
  Ltype_calcul   varchar2(30);
  l_sid NUMBER(8);
  l_mtprest NUMBER(11,2);
--
  CURSOR C_SINISTRE_SANTE IS
     SELECT
        ss.NUM_DOSSIER,
            ss.NUMLIGNE,
            ss.NUMINDIV,
            ds.NUMASSU, -- JBO suite au retour CFE le 21/01/2013
            ss.DATSIN,
            ss.CODPAYS,
            ss.CODFRAIS,
            ss.QUANTITE,
            ss.COEFF,
            ss.DEVISE_IN,
            ss.DEVISE_OUT,
            ss.DEVISE_AUTRB,
            ss.MTFRAIS_IN,
            ss.MTFRAIS,
            ss.SITUATION,
            ss.AUTRB_DAUTRB,
            ss.AUTRB,
            ss.TAUX,
            ss.BASEREMB,
            ss.MTREMB,
            ss.MTREMB_REEL,
            ss.MTPREST,
            ss.MTPREST_REEL,
            ss.MT_BANQUE,
            ss.CREATION,
            ss.MAJ,
            ds.NUMUTIL,      -- anciennement ss.numutil : gestion du numutil en fonction du dossier
            ss.FRCG,
            ss.FRCG1,
            ss.FRCG2,
            ss.FRCG3,
            ss.FRCG4,
            ss.FRCG5,
            ss.FRCG6,
            ss.FRCG7,
            ss.FRCG8,
            ss.FRCG9,
            ss.FRCG10,
            ss.NUMSIN_SNTRPRT,
            ss.NUMFACT
       FROM SINISTRE_SANTE ss
          , DOSSIER_SANTE ds
      WHERE ss.NUM_DOSSIER = P_num_dossier
        AND ds.NUM_DOSSIER=ss.NUM_DOSSIER
        AND ss.NUMLIGNE = NVL(P_numligne,ss.NUMLIGNE)
        AND ss.SITUATION = 1;
--
  REC_LigneDossier C_SINISTRE_SANTE%ROWTYPE;
  nb_ligne integer := 0;
  l_tot_RC NUMBER(11,2) := 0;
  L_nbacte Number(5);
  l_trace varchar2(10);
  Lnumporte porte_remise.numporte%TYPE;
  Lnumremise porte_remise.numremise%TYPE;
  loc_user       utilisateurs.numutil%TYPE;
  l_numordre   sinistre_forcage.numordre%TYPE;
  l_numzone    sinistre_forcage.numzone%TYPE;


BEGIN
  --l_trace:='totale';
  O_erreur:=0;
/*  SELECT NOM, PASSWORD
    INTO l_nom, l_pwd
    FROM Utilisateurs
   WHERE  numuid = uid;     */

   select TYPE_DOSS, NUMBENE, TYPBENE,NUMPORTE
    into Ltyp_doss, Lnumbene, Ltype_bene,Lnumporte
    from dossier_sante
    where num_dossier=P_num_dossier;

  select to_char(sys_context('userenv', 'sid'))
    into l_sid from dual;

  FOR REC_LigneDossier IN  C_SINISTRE_SANTE LOOP

   -- IF TRIM(l_nom) IS NULL THEN
      SELECT NOM, PASSWORD
        INTO l_nom, l_pwd
        FROM Utilisateurs
      --  WHERE  numuid = uid
       WHERE NUMUTIL = REC_LigneDossier.NUMUTIL
        ;
      loc_user:=REC_LigneDossier.NUMUTIL;
 --   END IF;


      nb_ligne:= nb_ligne+1;
      L_msg :='';

      IF REC_LigneDossier.codfrais IS NOT NULL THEN
        IF REC_LigneDossier.coeff IS NULL THEN
          REC_LigneDossier.coeff := 1;
        END IF;

        L_nbacte := nvl(REC_LigneDossier.coeff,1) * nvl(REC_LigneDossier.quantite,1);

        IF L_nbacte >= 1000    THEN O_erreur:=4; --nombre d'acte trop important
        ELSE Lmodif := 1;
        END IF;
      END IF;
  --
       IF REC_LigneDossier.datsin is not null   AND
      REC_LigneDossier.codfrais is not null   AND
      L_nbacte is not null AND
      Lmodif = 1 THEN

              REC_LigneDossier.maj := Sysdate;
              l_trace := f_trace_usrxit;
                L_msg := gs19_xit(
                      l_sid,
                      REC_LigneDossier.numligne,
                      REC_LigneDossier.codfrais,
                      to_char(REC_LigneDossier.datsin,'dd/mm/yyyy'),
                      REC_LigneDossier.codpays,
                      REC_LigneDossier.taux,
                      REC_LigneDossier.mtremb,
                      REC_LigneDossier.baseremb,
                      REC_LigneDossier.mtfrais,
                      REC_LigneDossier.autrb,
                      REC_LigneDossier.numindiv,
                      pk_devise.devise_ref,
                      REC_LigneDossier.quantite,
                      REC_LigneDossier.coeff,
                      to_char(REC_LigneDossier.maj,'dd/mm/yyyy'),
                      REC_LigneDossier.numassu, -- JBO suite au retour CFE le 21/01/2013
                      Lnumbene,
                      Ltype_bene,
                      0,
                      '',  --reference
                      REC_LigneDossier.NUM_DOSSIER,
                      REC_LigneDossier.NUMLIGNE,
                      P_type,
                      l_trace,
                      l_nom,
                      l_pwd,
                      REC_LigneDossier.FRCG,
                      REC_LigneDossier.FRCG1,
                      REC_LigneDossier.FRCG2,
                      REC_LigneDossier.FRCG3,
                      REC_LigneDossier.FRCG4,
                      REC_LigneDossier.FRCG5,
                      REC_LigneDossier.FRCG6,
                      REC_LigneDossier.FRCG7,
                      REC_LigneDossier.FRCG8,
                      REC_LigneDossier.FRCG9,
                      REC_LigneDossier.FRCG10,
                      1,
                      0,
                      0,
                      NULL, --CAS
                      p_derog --OPTI (si derogation ) ou null (si pas de derogation)
                      );
              --dbms_output.put_line('fin gs19 : '||L_msg);
              P_RETOUR_GS19XIT(L_msg,REC_LigneDossier.NUM_DOSSIER,REC_LigneDossier.numligne,0,l_mtprest,retourF );
              CASE retourF
                WHEN 1 THEN  O_erreur:=5; -- bloquant
                l_mtprest := 0;
                Lmodif := Null;
                WHEN 2 THEN  O_erreur:=6; -- carence
                WHEN 3 THEN  O_erreur:=7; -- plafond
                WHEN 4 THEN  O_erreur:=8; -- franchise
                ELSE NULL;
              END CASE;

              --somme des montants complémentaires remboursés
              l_tot_RC := l_tot_RC + l_mtprest;

              -- etat calculé de la prestation
              UPDATE SINISTRE_SANTE SET SITUATION= 2
              WHERE NUM_DOSSIER=REC_LigneDossier.NUM_DOSSIER
              AND NUMLIGNE=REC_LigneDossier.NUMLIGNE;
             --
              INSERT INTO HISTO_SINISTRE_SANTE
                        ( HISTO_SNTR_SANTE,
                          num_dossier,
                          numligne,
                          etat,
                          motif,
                          datetat,
                          numutil)
                       VALUES (
                          HISTO_SNTR_SANTE.nextval,
                          REC_LigneDossier.NUM_DOSSIER,
                          REC_LigneDossier.NUMLIGNE,
                          2,
                          0,
                          SYSDATE,
                          loc_user); -- f_numutil);
             --
              --dbms_output.put_line('fin ligne :'||O_erreur);

              IF l_mtprest>0 AND p_derog ='OPTI' THEN   --tracer le forcage
                  --recherche du sinistre
                BEGIN
                  SELECT nvl(max(numordre),0)+1
                  INTO l_numordre
                  FROM sinistre_forcage
                  WHERE numsin in (select numsin_sntr from sntr_dossier where num_dossier= REC_LigneDossier.NUM_DOSSIER and numligne= REC_LigneDossier.NUMLIGNE);

                  l_numzone := f_column_id('sinistre', 'mtreel');
                EXCEPTION
                  WHEN OTHERS THEN P_INS_journal(1,'Anomalie au niveau de l_numzone '||l_numzone);
                END;
                 --Traçage du montant forcé suite à la derogation
                INSERT INTO sinistre_forcage(numsin,
                                           numordre,
                                           numzone,
                                           datfrcg,
                                           numutil,
                                           valeur,
                                           type_dero)  --Traçage du montant forcé
                                           select  numsin_sntr,
                                           l_numordre,
                                           l_numzone,
                                           trunc(sysdate),
                                           f_numutil,
                                           0,
                                           p_derog
                                           from sntr_dossier where num_dossier= REC_LigneDossier.NUM_DOSSIER and numligne= REC_LigneDossier.NUMLIGNE;


              END IF; --tracer le forcage

      END IF;   -- Fin datsin IS Null


  END LOOP;

  --si aucune prestation est enregistrée dans le dossier alors on s'arrete
  IF nb_ligne = 0 THEN
    O_msg_erreur:= 'Aucune prestation Ó calculer';
    O_erreur := 9;
    RETURN;
  END IF;

  IF P_type = 'devis'  AND Lmodif=1 THEN
    -- Validation des lignes traitÚes- passage dans Sinistre------------
    BEGIN
    --dbms_output.put_line('PK_sinistre : '||l_sid);
    PK_sinistre.P_EXE_gs14_usrxit (I_username_id => loc_user, -- F_numutil,
                    I_ref         => 'Dossier',
                    I_sid         => to_number(l_sid));
    EXCEPTION
      WHEN OTHERS THEN O_erreur:=1; --enregistrement des sinistres
      -- return et tout supprimer
    END;
  END IF;
  --dbms_output.put_line('sinistre'||O_erreur ||'P_type'||P_type||Lmodif);

  --suspression des données de la table travsn de travail en fonction du username P_exec_gs15 modifié en fonction du sid;
  P_Delete_travsn(P_sid=>l_sid);

  IF P_type = 'devis'  THEN
      BEGIN
        P_Calcul_Sinistre_dev(P_num_dossier);
        P_Ajust_Arrondi_dev(P_num_dossier);
        EXCEPTION WHEN OTHERS THEN
      dbms_output.put_line('arrondi excep'||O_erreur);
      END;
  END IF;
  --montant total de remboursement du dossier

  IF /*O_erreur =0 AND */ l_tot_RC = 0 THEN
    O_msg_erreur:= 'Montant RC = 0';
    O_erreur := 10;
  ELSIF O_erreur = 0 AND P_tot_prest >= 0 AND  l_tot_RC != P_tot_prest THEN
    O_msg_erreur:= 'Montant RC different';
    O_erreur := 11;
  END IF;

Exception
   When others then
        O_msg_erreur:= 'Ligne '||REC_LigneDossier.numligne||' .Calcul impossible, consultez le fichier log.'; -- 'Variable(s) et Symbole(s) Devise(s)',
       O_erreur := 2;
    CLOSE C_SINISTRE_SANTE;
    delete  sntr_dossier where NUM_DOSSIER= REC_LigneDossier.NUM_DOSSIER and numligne= REC_LigneDossier.numligne;


END P_CALCUL_DOSSIER_SANTE;

PROCEDURE P_GEST_CALCUL(
  P_num_dossier IN sinistre_sante.num_dossier%TYPE,
  P_numligne    IN sinistre_sante.numligne%TYPE,
  P_type        IN VARCHAR2,
  O_erreur      OUT NUMBER,
  O_msg_erreur  OUT VARCHAR2,
  O_mt_prest    OUT sinistre_sante.mtprest_reel%TYPE,
  O_mt_prest_sin OUT sinistre.mtreel%TYPE)
IS
  loc_erreur NUMBER(3);
    loc_msg_erreur VARCHAR2(500);
BEGIN
  O_erreur :=0;
  O_msg_erreur:='';
  O_mt_prest:=0;


  PK_CALCUL_DOSSIER.P_CALCUL_DOSSIER_SANTE( P_num_dossier => P_num_dossier,
                                            P_numligne    => P_numligne,
                                            P_type        => P_type,
                                            O_erreur      => O_erreur,
                                            O_msg_erreur  => O_msg_erreur);


  BEGIN
    SELECT MTPREST_REEL INTO O_mt_prest
    FROM SINISTRE_SANTE
    WHERE num_dossier = P_num_dossier
    AND numligne = P_numligne;

    UPDATE SINISTRE_SANTE
    SET MTREMB_REEL = MTREMB
    WHERE num_dossier = P_num_dossier
    AND numligne = P_numligne;

    -- M0004105 : ajout MUR dur 19/03/2014
    select nvl(sum(mtreel),0) into O_mt_prest_sin
    from sinistre , sntr_dossier  , sinistre_sante
    where sinistre.numsin = sntr_dossier.numsin_sntr
    and sinistre_sante.num_dossier = sntr_dossier.num_dossier and sinistre_sante.numligne = sntr_dossier.numligne
    and sinistre_sante.num_dossier= P_num_dossier
    and sinistre_sante.numligne =  P_numligne
    and f_assureur(sinistre.numfor)=(select numcli
                                     from facture
                                    where codope = 12 and numfact = sinistre_sante.numfact)
    --MUR le 19/09/2014 : ne plus exclure les decomptes annulÚs
    --and sinistre.numsin not in (select numsin from sinistre_annul)-- exclusion des sinistres annulÚs
    and sinistre.numsin not in (select numsin from sinistre_annul
                                where not exists (select 1 from decompte_annul where sinistre_annul.numdec = decompte_annul.numdec)
                               )
    ;

  EXCEPTION
    WHEN OTHERS THEN
      O_mt_prest:=NULL;
      O_mt_prest_sin:=NULL;
  END;
  --enregistrement des sinsitres et des mises Ó jour externes
  COMMIT;
  --suppression des sinistres
  P_Delete_travsn();


END P_GEST_CALCUL;

PROCEDURE P_RETOUR_GS19XIT (
  P_dll IN VARCHAR2,
  P_num_dossier IN VARCHAR2,
  P_numligne IN NUMBER,
  P_sid IN NUMBER,
  O_mtreel OUT NUMBER,
  O_erreur OUT NUMBER
) IS

  nbarg integer;
  i integer;
  typeChamps varchar2(1);
  champs     varchar2(50);
  typeValeur varchar2(1);
  Valeur     varchar2(150);

  test varchar2(30);

  valNum  number;
  valDate date;
  valEntier integer;
  v_mtreel NUMBER(11,2):=0;
  v_mtprest NUMBER(11,2):=0;
  v_totmtreel NUMBER(11,2):=0;
  v_totmtprest NUMBER(11,2):=0;
BEGIN
  i:=1;
  -- Recherche du nombre d'arguments dans la chaine. 4 zones par argument
  LOOP
    IF instr(P_dll,';',1,i)>0 then
      nbarg :=i;
      i:=i+1;
     else
        exit;
    end if;
  END LOOP;
  nbarg:= (i-2)/4;
  O_erreur:= 0;

  -- Boucle pour chaque argument
  FOR i IN 1..nbarg LOOP
    if i=1 then
      typeChamps :=substr(P_dll,1,1);
      champs     :=substr(P_dll,3,instr(P_dll,';',1,2)-instr(P_dll,';',1,1)-1);
      typeValeur :=substr(P_dll,instr(P_dll,';',1,2)+1,instr(P_dll,';',1,3)-instr(P_dll,';',1,2)-1);
      Valeur     :=substr(P_dll,instr(P_dll,';',1,3)+1,instr(P_dll,';',1,4)-instr(P_dll,';',1,3)-1);
    else
      typeChamps :=substr(P_dll,instr(P_dll,';',1,((i-1)*4))+1,1);
      champs     :=substr(P_dll,instr(P_dll,';',1,((i-1)*4)+1)+1,instr(P_dll,';',1,((i-1)*4)+2)-instr(P_dll,';',1,((i-1)*4)+1)-1);
      typeValeur :=substr(P_dll,instr(P_dll,';',1,((i-1)*4)+2)+1,instr(P_dll,';',1,((i-1)*4)+3)-instr(P_dll,';',1,((i-1)*4)+2)-1);
      Valeur     :=substr(P_dll,instr(P_dll,';',1,((i-1)*4)+3)+1,instr(P_dll,';',1,((i-1)*4)+4)-instr(P_dll,';',1,((i-1)*4)+3)-1);
    end if;
    -- Test du type d'argument  C= champs, I = Message informatif, B = message bloquant
    IF typeChamps='C' then
      -- test du type de champs : C=chaine de caractÞres, N=NumÚrique, D=Date et J=Date julien
        IF typeValeur='N' THEN
           valnum:=to_number(valeur,'99999999999.99');
           --résultat du calcul de prestation pour une ligne de sinistre sante
           -- on stocke le montant réel prenant en compte les plafonds dans mtprese_reel

            -- numÚro du sinistre associé
            IF  champs = 'sntr.numsin' THEN
              --rÚcupÚration du montant rÚeel Ó partir de la table travsn
              BEGIN
                SELECT mtreel,mtprest into v_mtreel ,v_mtprest
                FROM travsn
                WHERE numsin = valnum;
              EXCEPTION
                WHEN others then
                  v_mtreel:=0;
                  v_mtprest:=0;
              END;
              -- gestion du cas double garantie
              v_totmtprest := v_totmtprest + v_mtprest;
              v_totmtreel := v_totmtreel + v_mtreel;

              IF P_num_dossier!='0' THEN
                INSERT INTO sntr_dossier values (P_num_dossier, P_numligne, valnum);
              /*ELSE
                O_mtreel:=v_mtreel; -- montant avec prise en compte des plafonds */
              END IF;
            END IF;
        END IF;
        ELSE null;
    END IF;
    IF   typeChamps='I' THEN
      O_erreur:=1;
      -- détection des erreurs dans le retour de dll en analysant le libellé du msg de sortie ...
      IF INSTR(valeur, 'Carence')<>0 then O_erreur := 2;
      ELSIF INSTR(valeur, 'plafond')<>0 then O_erreur := 3;
      ELSIF INSTR(valeur, 'franchise')<>0 then O_erreur := 4;
      END IF;
      --EXIT;
    END IF;
    /*bloquant*/
    IF   typeChamps='B' THEN
      O_erreur:=1;
      v_totmtprest:=0;
      v_totmtreel:=0;
      EXIT;
    END IF;

  END LOOP;

  -- Finalise en mettant à jour le sinistre_sante si c'est un dossier
  IF P_num_dossier!='0'THEN
    UPDATE SINISTRE_SANTE set
      mtprest=v_totmtprest,
      mtprest_reel= NVL(v_totmtreel,0)
    WHERE NUM_DOSSIER=P_num_dossier and NUMLIGNE=P_numligne;
  END IF;
  -- on renvoit le montant réel si on exécute juste une simulation de prestation
  O_mtreel :=  v_totmtreel;

END P_RETOUR_GS19XIT;

PROCEDURE P_Delete_travsn(P_sid IN NUMBER default null) IS
   l_sid number;
   BEGIN
    IF P_sid IS NULL THEN
       select to_char(sys_context('userenv', 'sid'))
       into l_sid from dual;
    ELSE l_sid :=P_sid;
    END IF;

    DELETE FROM trav_saisie
     /* WHERE numsin IN (
        SELECT numsin FROM TRAVSN */
            WHERE sid = l_sid--)
            ;

    DELETE FROM trav_plafond
      WHERE numsin IN (
        SELECT numsin FROM TRAVSN
            WHERE sid = l_sid);
    DELETE
    FROM    travsn
    WHERE   sid = l_sid;
   EXCEPTION
    WHEN OTHERS THEN null; -- erreur de delete sur travsn
END;

-- Lance le calcul en devise de toutes les ligne sinistre du dossier
PROCEDURE P_Calcul_Sinistre_dev(P_num_dossier IN dossier_sante.num_dossier%type) IS

 CURSOR SNTR_DOSSIER IS
        SELECT  NUM_DOSSIER, NUMLIGNE, NUMSIN_SNTR
        FROM    SNTR_DOSSIER
        WHERE   NUM_DOSSIER = P_num_dossier;
--
  REC_SNTRDossier SNTR_DOSSIER%ROWTYPE;

  s_devise_ct sinistre.monnaie%TYPE;
  s_datsin date;

  ld_devise_in NUMBER(3);
  ld_devise_out NUMBER(3);
  dev_ref number(3);

  loc_mtfrais sinistre.mtfrais%TYPE;
  loc_mtfrais_IN sinistre_sante.mtfrais_IN%TYPE;
  loc_mtprest sinistre.mtprest%TYPE;
  loc_mtremb  sinistre.mtremb%TYPE;
  loc_mtreel  sinistre.mtreel%TYPE;
  loc_autrb   sinistre.autrb%TYPE;

BEGIN
  OPEN  SNTR_DOSSIER;
  LOOP
  FETCH SNTR_DOSSIER INTO REC_SNTRDossier;
  EXIT WHEN SNTR_DOSSIER%NOTFOUND;

      select pk_devise.devise_ct(numgar)
      into s_devise_ct
      from sinistre
      where numsin= REC_SNTRDossier.NUMSIN_SNTR;

      select mtfrais,mtprest,mtremb,mtreel,autrb,monnaie, datsin
      into loc_mtfrais,loc_mtprest,loc_mtremb,loc_mtreel,loc_autrb,dev_ref, s_datsin
      from sinistre
      where numsin= REC_SNTRDossier.NUMSIN_SNTR;

      select devise_in,devise_out,mtfrais_IN
      into ld_devise_in,ld_devise_out,loc_mtfrais_IN
      from sinistre_sante
      where num_dossier=REC_SNTRDossier.NUM_DOSSIER and numligne=REC_SNTRDossier.NUMLIGNE;

               UPDATE sinistre_dev SET   DEV_CT=s_devise_ct,
                                         DEV_IN=ld_devise_in,
                                         DEV_OUT=ld_devise_out,
                                         MTFRAIS_CT =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtfrais,s_datsin),
                                         MTFRAIS_IN =loc_mtfrais_IN,
                                         MTFRAIS_OUT=decode(ld_devise_out,ld_devise_in,loc_mtfrais_IN,pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtfrais,s_datsin)),
                                        MTPREST_CT =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtprest,s_datsin),
                                        MTPREST_IN =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_mtprest,s_datsin),
                                        MTPREST_OUT=pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtprest,s_datsin),
                                        MTREMB_CT  =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtremb ,s_datsin),
                                        MTREMB_IN  =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_mtremb ,s_datsin),
                                        MTREMB_OUT =pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtremb ,s_datsin),
                                        MTREEL_CT  =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtreel ,s_datsin),
                                        MTREEL_IN  =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_mtreel ,s_datsin),
                                        MTREEL_OUT =pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtreel ,s_datsin),
                                        AUTRB_CT   =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_autrb  ,s_datsin),
                                        AUTRB_IN   =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_autrb  ,s_datsin),
                                        AUTRB_OUT  =pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_autrb  ,s_datsin)
            WHERE NUMSIN = REC_SNTRDossier.numsin_sntr;

            update sinistre set numassu_rc = (select sinistre_sante.numassu_rc
                 from sinistre_sante, sntr_dossier
                 where sinistre_sante.num_dossier=sntr_dossier.num_dossier
                   and sinistre_sante.NUMLIGNE = sntr_dossier.numligne
                   and sntr_dossier.NUMSIN_SNTR = sinistre.numsin)
              where numsin= REC_SNTRDossier.numsin_sntr;
  END LOOP;
  CLOSE SNTR_DOSSIER;
END;

PROCEDURE P_Ajust_Arrondi_dev(P_num_dossier IN dossier_sante.num_dossier%type) IS


 -- Ajustement des montants OUT

 CURSOR AJ_SNTR_DOSSIER IS
        Select  num_dossier,numligne,max(numsin) mxnumsin,sum(mtreel) mtreeltot,sum(decode(F_type_couv(sntr_dossier.NUMSIN_SNTR, sntr_dossier.NUM_dossier,sntr_dossier.NUMligne), 3,0,4,0,sinistre.mtfrais)) mtfraisTot
        From  sinistre, sntr_dossier
        where  sinistre.numsin=sntr_dossier.NUMSIN_SNTR
        and num_dossier=P_num_dossier
        and numdec=0
        group by  num_dossier,numligne;

--
  REC_AJ_SNTRDossier AJ_SNTR_DOSSIER%ROWTYPE;

  --s_devise_ct sinistre.monnaie%TYPE;
  --s_datsin date;

  AJ_devise_in  NUMBER(3);
  AJ_devise_out NUMBER(3);
  AJ_type_couv  NUMBER(1);
  --dev_ref number(3);

  --loc_mtfrais sinistre.mtfrais%TYPE;
  AJ_mtfrais_IN sinistre_sante.mtfrais_IN%TYPE;
  --loc_mtprest sinistre.mtprest%TYPE;
  --loc_mtremb  sinistre.mtremb%TYPE;
  AJ_Remb_Total  sinistre.mtreel%TYPE;
    --loc_autrb   sinistre.autrb%TYPE;


BEGIN

  OPEN  AJ_SNTR_DOSSIER;

  LOOP
    FETCH AJ_SNTR_DOSSIER INTO REC_AJ_SNTRDossier;

      IF AJ_SNTR_DOSSIER%FOUND THEN

          if REC_AJ_SNTRDossier.mtreeltot=REC_AJ_SNTRDossier.mtfraistot then

              select devise_in,devise_out,mtfrais_IN
              into AJ_devise_in,AJ_devise_out,AJ_mtfrais_IN
              from sinistre_sante
              where num_dossier=REC_AJ_SNTRDossier.NUM_DOSSIER and numligne=REC_AJ_SNTRDossier.NUMLIGNE;

              if AJ_devise_in=AJ_devise_out then

                select F_dcpt_RembTotal(REC_AJ_SNTRDossier.NUM_DOSSIER,REC_AJ_SNTRDossier.NUMLIGNE),
                       f_type_couv(REC_AJ_SNTRDossier.mxnumsin,REC_AJ_SNTRDossier.NUM_DOSSIER,REC_AJ_SNTRDossier.NUMLIGNE)
                into AJ_Remb_Total, AJ_type_couv
                from dual;


                UPDATE sinistre_dev SET
                  MTREEL_OUT =MTREEL_OUT +(mtfrais_IN  - AJ_Remb_Total),
                  MTREEL_IN  =MTREEL_OUT +(mtfrais_IN  - AJ_Remb_Total),
                  MTPREST_OUT =decode(AJ_type_couv,1,mtfrais_IN ,2, mtfrais_IN ,MTPREST_OUT),
                  MTPREST_IN  =decode(AJ_type_couv,1,mtfrais_IN ,2, mtfrais_IN ,MTPREST_IN),
                  MTREMB_OUT  =decode(AJ_type_couv,1,mtfrais_IN,MTREMB_OUT),
                  MTREMB_IN   =decode(AJ_type_couv,1,mtfrais_IN,MTREMB_IN)
                WHERE NUMSIN = REC_AJ_SNTRDossier.mxnumsin;

              end if;

          end if;
      ELSE
           CLOSE AJ_SNTR_DOSSIER;
           exit;
      END IF;

  END LOOP;
END;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CPYL_PEC  / JBO 19/07/2011                              */
/* Type         :  Privee                                                    */
/* Description  :  Recopier les lignes de prestation du Dossier de Prise     */
/*                 en Charge sur le Dossier de Prestation traitant la prise  */
/*                 en charge en les passant en Situation , Motif = 0. La Mise*/
/*                 à Jour n'est pas affectée car la création des lignes      */
/*                 sinistres bloque                                          */
/* Entree       :  P_num_dossier_Pec : Numero de dossier de prise en charge  */
/*                 P_num_dossier : Numéro de dossier                         */
/*                 P_num_porte : Numéro de porte                             */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CPYL_PEC( P_num_dossier_Pec IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                    , P_num_dossier     IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE
                    , P_num_porte       IN  DOSSIER_SANTE.NUMPORTE%TYPE
                    , O_sens_porte      OUT NUMBER
                    , O_erreur          OUT NUMBER)
IS

  CURSOR C_PEC IS
    SELECT * FROM SINISTRE_SANTE SS
    WHERE SS.NUM_DOSSIER = P_num_dossier_Pec; --:DOSSIER_SANTE.NUM_DOSSIER_PEC;
  R_PEC C_PEC%ROWTYPE;

  CURSOR C_SIN IS
    SELECT * FROM SNTR_DOSSIER SD
    WHERE SD.NUM_DOSSIER = P_num_dossier; --:DOSSIER_SANTE.NUM_DOSSIER;
  R_SIN C_SIN%ROWTYPE;

  loc_ligne      NUMBER:=1;
  loc_numligne_origine sinistre_sante.numligne%type ;   -- M0006135


/*
 Recopier les lignes de prestation du Dossier de Prise en Charge sur le Dossier
  de Prestation traitant la prise en charge en les passant en Situation , Motif = 0;
  La Mise à Jour n'est pas affectée car la crÚation des lignes sinistres bloque
  la MAJ au niveau de la saisie du dossier
  -->ABO erreur oracle 2291 corrigée, problème uniquement sur insertion du à la clef ÚtrangÞre FK_SINISTRE_SANTE
  L'appel de la procÚdure en post_insert a résolu le souci
*/
BEGIN

  OPEN C_PEC;
  LOOP
    FETCH C_PEC INTO R_PEC;
    EXIT WHEN C_PEC%NOTFOUND;
    --
    BEGIN
     -- MUR le 12/06/2014 : M0004105 : prise en compte sinistre_sante_annul
     SELECT NVL(MAX(NumLigne),0) +1
       INTO loc_ligne
       FROM (select NumLigne from SINISTRE_SANTE where NUM_DOSSIER = P_num_dossier
                 union all
                 select NumLigne from SINISTRE_SANTE_annul where NUM_DOSSIER_sin = P_num_dossier
            );

       Exception
          WHEN VALUE_ERROR OR NO_DATA_FOUND
                THEN loc_ligne := 1;
    END;
    -- nouvelle Méthode = On recopie tout le sinistre en ne modifiant que les données concnernées. (diminution du nombre de ligne, maintenabilité accrue et adaptation automatique du code aux nouvelles structure de table)
    -- mise a null des données non concernées
    R_PEC.NUMASSU_RC     := null;
    R_PEC.NUMANNUL       := null;
    R_PEC.NUMORIGINE     := null;
    R_PEC.DATE_MODIF     := null;
    R_PEC.NUMUTIL_MODIF  := null;
    R_PEC.NUMSIN_SNTRPRT := null;
    -- valorisation spécifique au nouveau sinistre
    R_PEC.NUM_DOSSIER    := P_num_dossier;
    loc_numligne_origine := R_PEC.NUMLIGNE; -- M0006135 on recupere la valeur d'origine de sinistre_sante.numligne afin de traiter les cas d'incrémentation non linéaire
    R_PEC.NUMLIGNE       := loc_ligne;
    R_PEC.CREATION       := SYSDATE;
    R_PEC.MAJ            := SYSDATE;
    R_PEC.NUMUTIL        := F_NUMUTIL;


    INSERT INTO SINISTRE_SANTE VALUES R_PEC;

    -- abandon de l'ancienne methode trop statique et sujette au modifications de structure
    /*
    INSERT INTO SINISTRE_SANTE
    (  NUM_DOSSIER,  NUMLIGNE,  NUMINDIV,  DATSIN, CODPAYS,  CODFRAIS,  COD_ICD9,
     QUANTITE,  COEFF,  DEVISE_IN,  DEVISE_OUT,  DEVISE_AUTRB,  MTFRAIS_IN,
      MTFRAIS,  SITUATION,  MOTIF,  AUTRB_DAUTRB,  AUTRB,  TAUX,  MTREMB,  BASEREMB,  MTREMB_REEL,
       MTPREST,  MTPREST_REEL,  MT_BANQUE,  CREATION,  MAJ,  NUMUTIL,  REFERENCE,  D_ED_FL,  DATSIN_FIN,
        TYP_ELT,  ELT_CORP,  EXCLUSION,  BLOCAGE,  NUMORG,  NUM_BORD,  NUMENVOI,  NUMFACT,  FRCG,
         FRCG1,  FRCG2,  FRCG3,  FRCG4,  FRCG5,  FRCG6,  FRCG7,  FRCG8,  FRCG9,  FRCG10,
         LOCDENT1, LOCDENT2, LOCDENT3, LOCDENT4, LOCDENT5, LOCDENT6, LOCDENT7, LOCDENT8,
         LOCDENT9, LOCDENT10, LOCDENT11, LOCDENT12, LOCDENT13, LOCDENT14, LOCDENT15, LOCDENT16
         )
         VALUES ( P_num_dossier,
                  loc_ligne,
                  R_PEC.NUMINDIV,
                  R_PEC.DATSIN,
                  R_PEC.CODPAYS,
                  R_PEC.CODFRAIS,
                  R_PEC.COD_ICD9,
                  R_PEC.QUANTITE,
                  R_PEC.COEFF,
                  R_PEC.DEVISE_IN,
                  R_PEC.DEVISE_OUT,
                  R_PEC.DEVISE_AUTRB,
                  R_PEC.MTFRAIS_IN,
                  R_PEC.MTFRAIS,
                  R_PEC.SITUATION,
                  R_PEC.MOTIF,
                  R_PEC.AUTRB_DAUTRB,
                  R_PEC.AUTRB,
                  R_PEC.TAUX,
                  R_PEC.MTREMB,
                  R_PEC.BASEREMB,
                  R_PEC.MTREMB_REEL,
                  R_PEC.MTPREST,
                  R_PEC.MTPREST_REEL,
                  R_PEC.MT_BANQUE,
                  SYSDATE,
                  SYSDATE,
                  F_NUMUTIL,
                  R_PEC.REFERENCE,
                  R_PEC.D_ED_FL,
                  R_PEC.DATSIN_FIN,
                  R_PEC.TYP_ELT,
                  R_PEC.ELT_CORP,
                  R_PEC.EXCLUSION,
                  R_PEC.BLOCAGE,
                  R_PEC.NUMORG,
                  R_PEC.NUM_BORD,
                  R_PEC.NUMENVOI,
                  R_PEC.NUMFACT,
                  R_PEC.FRCG,
                  R_PEC.FRCG1,
                  R_PEC.FRCG2,
                  R_PEC.FRCG3,
                  R_PEC.FRCG4,
                  R_PEC.FRCG5,
                  R_PEC.FRCG6,
                  R_PEC.FRCG7,
                  R_PEC.FRCG8,
                  R_PEC.FRCG9,
                  R_PEC.FRCG10,
                  R_PEC.LOCDENT1,
                  R_PEC.LOCDENT2,
                  R_PEC.LOCDENT3,
                  R_PEC.LOCDENT4,
                  R_PEC.LOCDENT5,
                  R_PEC.LOCDENT6,
                  R_PEC.LOCDENT7,
                  R_PEC.LOCDENT8,
                  R_PEC.LOCDENT9,
                  R_PEC.LOCDENT10,
                  R_PEC.LOCDENT11,
                  R_PEC.LOCDENT12,
                  R_PEC.LOCDENT13,
                  R_PEC.LOCDENT14,
                  R_PEC.LOCDENT15,
                  R_PEC.LOCDENT16
                  );
                  */
    /*MAJ de sntr_dossier pour le décrochement des sinistres (sens -1 donc non dÚcomptable)*/
    UPDATE SNTR_DOSSIER SD
    SET SD.NUM_DOSSIER = P_num_dossier,
        SD.NUMLIGNE = loc_ligne
    WHERE SD.NUM_DOSSIER = P_num_dossier_Pec
    -- AND SD.NUMLIGNE = R_PEC.NUMLIGNE;
    AND SD.NUMLIGNE = loc_numligne_origine ; -- M0006135

  END LOOP;
  CLOSE C_PEC;

  OPEN C_SIN;
  LOOP
    FETCH C_SIN INTO R_SIN;
    EXIT WHEN C_SIN%NOTFOUND;
    --
    BEGIN
      /*MAJ des sinistres -> ils pourront être décomptés*/
      UPDATE SINISTRE S
        SET S.SENS=1
        WHERE S.NUMSIN = R_SIN.NUMSIN_SNTR;
    END;
    END LOOP;
  CLOSE C_SIN;

  /* MAJ du Dossier PEC de type 4*/
    UPDATE DOSSIER_SANTE DS
       SET DS.NUM_DOSSIER_PEC = P_num_dossier,
           PEC = 1
     WHERE DS.NUM_DOSSIER = P_num_dossier_Pec;



   /* Message d'information que le traitement est bien effectuÚ */
   O_erreur:=1373;

  -- Cas envoi Sévéane
  BEGIN
    SELECT sens INTO O_sens_porte
    FROM lble
    Where MNEMO = 'PORTE'
    AND CODE = P_num_porte;
    EXCEPTION
       WHEN OTHERS THEN NULL;
  END;

  IF F_TYPE_PORTE(P_num_porte) =3 THEN --circuit web service
    PK_CTRL_TP.P_INS_HISTO_DOSSIER(P_num_dossier_Pec,0,4,sysdate);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        O_erreur:=639;
        ROLLBACK;
END P_CPYL_PEC;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_LIQUID_AUTO  / JBO 16/11/2011                           */
/* Type         :  Publique                                                  */
/* Description  :  renvoie 1 si la liquidation est autorisee pour le dossier */
/*                 courant, 0 sinon                                          */
/* Entree       :                                                            */
/* Retour       : 1 ou 0                                                     */
/*============================================================================*/
/* Evolution    : Projet SP SANTE                                             */
/* Auteur       : ABO                                                         */
/* Date         : 23/01/2012                                                  */
/* Commentaire  : Prise en compte du paramÚtrage des portes                   */
/*                prÚsent dans GS12.fmb                                       */
/*----------------------------------------------------------------------------*/

FUNCTION F_LIQUID_AUTO(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS        IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER      IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE)
RETURN NUMBER IS

  l_liquid_doss porte_param.liquid_doss%TYPE;

BEGIN
  -- Fonction qui renvoie 1 si la liquidation est autorisee pour le dossier courant, 0 sinon

  IF F_LIQUID_PEC(P_NUM_DOSSIER_PEC,P_TYPE_DOSS,4,P_NUM_DOSSIER)=0 THEN RETURN 0;
  END IF;
  --paramétrage de la porte
  BEGIN
    SELECT LIQUID_DOSS
    INTO l_liquid_doss
    FROM PORTE_PARAM p , DOSSIER_SANTE d
    WHERE p.numporte= d.numporte
    AND d.num_dossier = P_NUM_DOSSIER;

    IF NVL(l_liquid_doss,'N') ='N' THEN RETURN 0;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RETURN 0;
  END;

  RETURN 1;
END F_LIQUID_AUTO;



/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_LIQUID_MAN                                              */
/* Type         :  Publique                                                  */
/* Description  :  renvoie 1 si la liquidation est autorisee pour le dossier */
/*                 courant, 0 sinon                                          */
/* Entree       :                                                            */
/* Retour       : 1 ou 0                                                     */
/*============================================================================*/
/* Evolution    : Projet CCAM                                                 */
/* Auteur       : ABO                                                         */
/* Date         : 26/02/2015                                                  */
/* Commentaire  : liquidation de dossier pec manuelle sans porte              */
/*----------------------------------------------------------------------------*/
FUNCTION F_LIQUID_MAN(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS       IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER     IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE
                     , P_NUMPORTE        IN  DOSSIER_SANTE.NUMPORTE%TYPE)
RETURN NUMBER IS

BEGIN
  IF F_LIQUID_PEC(P_NUM_DOSSIER_PEC,P_TYPE_DOSS,4,P_NUM_DOSSIER)=0 THEN RETURN 0;
  ELSIF P_NUMPORTE IS NOT NULL THEN RETURN 0;
  ELSE RETURN 1;
  END IF;
END F_LIQUID_MAN;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_LIQUID_PEC                                              */
/* Type         :  Privée                                                    */
/* Description  :  renvoie 1 si le dossier est liquidable                    */
/*                 courant, 0 sinon                                          */
/* Entree       :                                                            */
/* Retour       : 1 ou 0                                                     */
/*============================================================================*/
/* Evolution    : Projet CCAM                                                 */
/* Auteur       : ABO                                                         */
/* Date         : 26/02/2015                                                  */
/* Commentaire  :                                                             */
/*----------------------------------------------------------------------------*/
FUNCTION F_LIQUID_PEC(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS        IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_TYPE_REF         IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER      IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE)
RETURN NUMBER IS

BEGIN
  -- Fonction qui renvoie 1 si la liquidation est autorisee pour le dossier courant, 0 sinon

  IF P_TYPE_REF = 1 AND P_NUM_DOSSIER_PEC IS NULL THEN
    RETURN 0;
  ELSIF P_TYPE_REF = 4 AND P_NUM_DOSSIER_PEC IS NOT NULL THEN
    RETURN 0;
  END IF;

  IF NVL(P_TYPE_DOSS,0) <> P_TYPE_REF THEN
    RETURN 0;
  END IF;

  --dossier fermé
  IF F_ETAT_DOSSIER_SANTE(P_NUM_DOSSIER,sysdate,1) =1 THEN
    RETURN 0;
  END IF;

  RETURN 1;
END F_LIQUID_PEC;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_ENVOI_WS  / ABO 23/01/2012                              */
/* Type         :  Publique                                                  */
/* Description  :  renvoie 1 si la liquidation est autorisee pour le dossier */
/*                 courant, 0 sinon                                          */
/* Entree       :                                                            */
/* Retour       : 1 ou 0    prÚsent dans GS12.fmb                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_ENVOI_WS(P_NUM_DOSSIER_PEC  IN  DOSSIER_SANTE.NUM_DOSSIER_PEC%TYPE
                     , P_TYPE_DOSS        IN  DOSSIER_SANTE.TYPE_DOSS%TYPE
                     , P_NUM_DOSSIER      IN  DOSSIER_SANTE.NUM_DOSSIER%TYPE)
RETURN NUMBER IS

  l_liquid_doss porte_param.liquid_doss%TYPE;

BEGIN
  -- Fonction qui renvoie 1 si la liquidation est autorisee pour le dossier courant, 0 sinon
  IF F_LIQUID_PEC(P_NUM_DOSSIER_PEC,P_TYPE_DOSS,1,P_NUM_DOSSIER)=0 THEN RETURN 0;
  END IF;
  --paramétrage de la porte
  BEGIN
    SELECT LIQUID_DOSS
    INTO l_liquid_doss
    FROM PORTE_PARAM p , DOSSIER_SANTE d
    WHERE p.numporte= d.numporte
    AND d.num_dossier = P_NUM_DOSSIER;

    IF NVL(l_liquid_doss,'N') ='N' THEN RETURN 0;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN RETURN 0;
  END;

  RETURN 1;
END F_ENVOI_WS;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_Num_Dossier  / ABO 26/06/2010                           */
/* Type         :  Publique                                                 */
/* Description  :   appelée par gs12 , sévéane et spsante. Fonction d'incré- */
/*                  mentation du numéro de dossier sante                     */
/* Entree       :                                                            */
/* Retour       : numÚro de dossier unique                                   */
/*---------------------------------------------------------------------------*/
FUNCTION F_Num_Dossier (a_debut IN Date) RETURN VARCHAR2

    IS
    LOC_Retour    VarChar2 (15);
    LOC_NoDossier Number; --Numéro du Dossier Ouvert dans la journÚe
    LOC_Annee     Varchar2 (2);
    LOC_NoJour    VarChar2 (3);--Numéro du jour dans l'Année
BEGIN

  LOC_Annee     := To_Char(SysDate, 'YY');

  SELECT to_char(sysdate,'ddd') INTO LOC_NoJour FROM dual;

  SELECT id_num_dossier.nextval INTO  LOC_NoDossier FROM  DUAL;


  LOC_Retour   := LOC_Annee || LOC_NoJour || SubStr(To_Char(LOC_NoDossier, '09999'), 2, 5);

RETURN LOC_Retour;
END F_Num_Dossier;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_ANNUL_DOSSIER_LIQ  / ABO 06/12/2011                     */
/* Type         :  Privee                                                    */
/* Description  :  renvoie le nb de dossier liquidé ,0 si aucun dossier      */
/*                             -1 si anomalie                                */
/* Entree       :                                                            */
/* Retour       :  le nombre de dossier                                      */
/*---------------------------------------------------------------------------*/

FUNCTION F_ANNUL_DOSSIER_LIQ(i_numremise IN porte_remise.numremise%TYPE,
                             i_num_dossier_PEC IN dossier_sante.num_dossier%TYPE)
RETURN NUMBER IS
  l_num_dossier_liq  dossier_sante.num_dossier%TYPE;
  l_num_dossier_pec  dossier_sante.num_dossier%TYPE;
  loc_nbsin          NUMBER(6); --compteur de sinistre décompté

  v_cpt_dossier NUMBER(6);
  CURSOR C_dossier_sante (p_numremise porte_remise.numremise%TYPE,p_num_dossier_PEC dossier_sante.num_dossier%TYPE) IS
   SELECT num_dossier,num_dossier_pec,ref_dossier
   FROM dossier_sante
   WHERE numremise_sntrprt = NVL(p_numremise,numremise_sntrprt)
   AND num_dossier_pec = NVL(p_num_dossier_PEC,num_dossier_pec)
   AND type_doss = 1;

  CURSOR C_sntr_dossier (p_num_dossier dossier_sante.num_dossier%TYPE) IS
    SELECT sd.numsin_sntr
    FROM sntr_dossier sd,sinistre s
    WHERE sd.num_dossier=p_num_dossier
    AND sd.numsin_sntr = s.numsin
    AND s.numdec=0;

  Rec_C_dossier_sante C_dossier_sante%ROWTYPE;
  Rec_C_sntr_dossier  C_sntr_dossier%ROWTYPE;
BEGIN
  v_cpt_dossier :=0;
dbms_output.put_line('i_numremise'||i_numremise);
   --recherche du dossier de liquidation
  FOR Rec_C_dossier_sante IN C_dossier_sante(i_numremise,i_num_dossier_PEC) LOOP
    v_cpt_dossier :=v_cpt_dossier+1;
    IF   F_ETAT_DOSSIER_SANTE(Rec_C_dossier_sante.num_dossier,sysdate,1) =0 /*TO DO à revoir*/
    AND  F_ETAT_DOSSIER_SANTE(Rec_C_dossier_sante.num_dossier,sysdate,2) =7 THEN --fichier des dossiers facturés envoyés
      RETURN -1;
    END IF;

    SELECT count(sd.numsin_sntr)
    INTO loc_nbsin
    FROM sntr_dossier sd,sinistre s
    WHERE sd.num_dossier=Rec_C_dossier_sante.num_dossier
    AND sd.numsin_sntr = s.numsin
    AND s.numdec<>0;

    IF loc_nbsin >0 THEN RETURN -2;
    END IF;

    FOR Rec_C_sntr_dossier IN C_sntr_dossier(Rec_C_dossier_sante.num_dossier) LOOP
      --sinsitre non decomptable
      UPDATE sinistre SET sens = -1
      WHERE numsin = Rec_C_sntr_dossier.numsin_sntr;

      DELETE sntr_ref
      WHERE numsin = Rec_C_sntr_dossier.numsin_sntr
      AND numremise = i_numremise ;
    END LOOP;

    dbms_output.put_line(' UPDATE sinistre'||Rec_C_dossier_sante.num_dossier);
    --déplacement des sinistres
    UPDATE sntr_dossier SET num_dossier = Rec_C_dossier_sante.num_dossier_pec
    WHERE num_dossier = Rec_C_dossier_sante.num_dossier;
    dbms_output.put_line(' UPDATE sntr_dossier'||SQLERRM);

    --mise à jour de la référence pec sur le dossier de pec
    UPDATE dossier_sante
    SET num_dossier_pec = NULL
    WHERE num_dossier = Rec_C_dossier_sante.num_dossier_pec;

    --suppression du dossier de liquidation
    DELETE histo_dossier
    WHERE num_dossier = Rec_C_dossier_sante.num_dossier;
    DELETE sinistre_sante
    WHERE num_dossier = Rec_C_dossier_sante.num_dossier;
    DELETE histo_sinistre_sante
    WHERE num_dossier = Rec_C_dossier_sante.num_dossier;
    DELETE dossier_sante
    WHERE  type_doss=1
    AND (num_dossier = Rec_C_dossier_sante.num_dossier
    OR ref_dossier =Rec_C_dossier_sante.ref_dossier );
    dbms_output.put_line(' DELETE histo_dossier'||Rec_C_dossier_sante.num_dossier);
    --mise à jour de l'état du dossier de PEC
    DELETE histo_dossier
    WHERE num_dossier = Rec_C_dossier_sante.num_dossier_pec
    AND etat=0
    AND motif = 4;
    dbms_output.put_line(' DELETE histo_dossier'||Rec_C_dossier_sante.num_dossier_pec);

  END LOOP;
  RETURN v_cpt_dossier;
 EXCEPTION
   WHEN OTHERS THEN
   dbms_output.put_line('erreur'||SQLERRM);
   RETURN -1; --anomalie
   --pas de dossier dans cette remise

END F_ANNUL_DOSSIER_LIQ;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_ANNUL_DOSSIER_FACT  / ABO 09/01/2012                    */
/* Type         :  Privee                                                    */
/* Description  :  Retourne le nb de dossier de liquidation facturé annulé   */
/* Entree       :                                                            */
/* Retour       :  le nombre de dossier                                      */
/*---------------------------------------------------------------------------*/
FUNCTION F_ANNUL_DOSSIER_FACT(i_numremise IN porte_remise.numremise%TYPE)
RETURN NUMBER IS
  l_nb_dossier NUMBER :=0;
  CURSOR C_dossier(p_remise IN porte_remise.numremise%TYPE) IS
    SELECT num_dossier,numremise_sntrprt
    FROM dossier_sante
    WHERE numremise_sntrprt = p_remise
    AND type_doss = 4 ;

  Rec_C_dossier C_dossier%ROWTYPE;
BEGIN
  --ABO 07/12/2011 mise à jour de l'état du dossier de PEC
  FOR Rec_C_Dossier IN C_Dossier(i_numremise) LOOP
    l_nb_dossier :=l_nb_dossier+1;
    DELETE histo_dossier
    WHERE num_dossier = Rec_C_Dossier.num_dossier
    AND etat=0
    AND motif = 6;--etat en cours de facturation

    UPDATE SINISTRE_SANTE SET numsin_sntrprt =null
    WHERE num_dossier =Rec_C_Dossier.num_dossier;

    UPDATE DOSSIER_SANTE SET numremise_sntrprt =null
    WHERE num_dossier =Rec_C_Dossier.num_dossier;
    -- Rec_C_Dossier.numremise_sntrprt:=NULL;

  END LOOP;
  RETURN l_nb_dossier;
END F_ANNUL_DOSSIER_FACT;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_ANNUL_BLOCAGE_FACT  / ABO 09/01/2012                    */
/* Type         :  Privee                                                    */
/* Description  :  */
/* Entree       :                                                            */
/* Retour       :  le nombre de sinistre débloqué                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_ANNUL_BLOCAGE_FACT(i_numremise IN porte_remise.numremise%TYPE,
                               i_refcie    IN sinistre_porte.refcie%TYPE,
                               i_idfactpe IN sinistre_porte.idfactpe%TYPE)
RETURN NUMBER IS
l_nb number:=0;
BEGIN
  --on réalise la mise à jour uniquement si la facture n'est pas fait l'objet d'une remise d'export (codevefac =35)
  UPDATE sinistre_porte
    SET etat = 7,
    codevefac = 10
  WHERE refcie  = i_refcie
  AND idfactpe  = i_idfactpe
  AND numremise = i_numremise
  AND codevefac = 30;

  l_nb:=SQL%ROWCOUNT;
  --vérifier que l'on a qu'un idfactpe par dossier et pas un par sinistre.... sinon prendre le numfact
  DELETE suivi_fact_tpe
  WHERE numremise_export = i_numremise
  AND codevefac =30
  AND idfactpe = i_idfactpe;

  RETURN l_nb;
END F_ANNUL_BLOCAGE_FACT;
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_LIQ_DOSSIER  / ABO 09/01/2012                           */
/* Type         :  Privee                                                    */
/* Description  :  Retourne le dossier de liquidation créé                   */
/*                  0 si dossier PEC inconnu          -1 si anomalie         */
/* Entree       :                                                            */
/* Retour       :  le numéro de dossier                                      */
/*---------------------------------------------------------------------------*/


FUNCTION F_LIQ_DOSSIER( i_refcie     IN sinistre_porte.refcie%TYPE,
                        i_numremise  IN porte_remise.numremise%TYPE,
                        i_numfact    IN dossier_sante.num_fact_pec%TYPE,
                        i_datfact    IN dossier_sante.date_fact_pec%TYPE)
RETURN NUMBER IS

  CURSOR C_dossier_sante (i_refcie sinistre_porte.refcie%TYPE) IS
  SELECT num_dossier, num_dossier_pec, ref_dossier,numindiv,numprescrip,
  numbene,numassu,numporte,nat_doss,num_dossier_porte,numremise_sntrprt
  FROM dossier_sante
  WHERE ref_dossier = trim(i_refcie)
  AND type_doss = 4;

  REc_C_dossier_sante C_dossier_sante%ROWTYPE;

  loc_numfact         suivi_fact_tpe.numfact%TYPE;
  loc_datfact         suivi_fact_tpe.datfact%TYPE;
  loc_num_dossier_liq dossier_sante.num_dossier%TYPE;
  loc_sens_porte      libelle.sens%TYPE;
  loc_numano          NUMBER;
  loc_libelle         VARCHAR2(300);

  exc_dossier_inconnu EXCEPTION;
  exc_rej_technique   EXCEPTION;

BEGIN

  OPEN C_dossier_sante(i_refcie);
  FETCH C_dossier_sante INTO Rec_C_dossier_sante;

  IF C_dossier_sante%NOTFOUND THEN
    RAISE exc_dossier_inconnu;
  END IF;

  PK_CTRL_TP.P_INS_DOSSIER_SANTE(P_ref      => Rec_C_dossier_sante.ref_dossier,
                                P_numindiv => Rec_C_dossier_sante.numindiv,
                                P_PS       => Rec_C_dossier_sante.numprescrip,
                                P_numassu  =>Rec_C_dossier_sante.numassu,
                                P_numporte =>Rec_C_dossier_sante.numporte,
                                P_natdoss  =>Rec_C_dossier_sante.nat_doss,
                                P_typedoss => 1,
                                P_num_dossier_porte =>'',--à vérifier si bon
                                O_num_dossier => loc_num_dossier_liq);

  IF loc_num_dossier_liq=0 THEN
    loc_libelle :='Impossible de créer le dossier de liquidation';
    RAISE exc_rej_technique;
  END IF;

  P_INS_journal(1,'Dossier de liquidation créé :'||loc_num_dossier_liq);

  PK_CTRL_TP.P_INS_HISTO_DOSSIER(loc_num_dossier_liq,0,0,sysdate);



   --déplacement des sinistres et création du lien entre les 2 dossiers
  PK_CALCUL_DOSSIER.P_CPYL_PEC( P_num_dossier_Pec => Rec_C_dossier_sante.num_dossier,
                                P_num_dossier     => loc_num_dossier_liq,
                                P_num_porte       => Rec_C_dossier_sante.numporte,
                                O_sens_porte      => loc_sens_porte,
                                O_erreur          => loc_numano);
                                 --TO DO vérifié que le numsin_sntrprt est bien alimenté lors de la copie
  IF loc_numano = 1373 THEN loc_numano:=NULL;
  ELSE
    --copie des sinistres plantées
    loc_libelle :='Impossible de copier les sinistres dans le dossier';
    RAISE exc_rej_technique; --rejet technique-> plantage à identifier
  END IF;

  --mise à jour du dossier de liquidation
  UPDATE dossier_sante
  SET numremise_sntrprt = i_numremise,
      num_dossier_pec=Rec_C_dossier_sante.num_dossier,
      pec = 1,
      num_fact_pec = i_numfact,
      date_fact_pec = i_datfact
  WHERE num_dossier = loc_num_dossier_liq;


  RETURN loc_num_dossier_liq;

  EXCEPTION
    WHEN exc_rej_technique THEN
      P_INS_journal(1,'Création dossier impossible :',loc_libelle);
      RETURN -1;
    WHEN exc_dossier_inconnu THEN
       RETURN 0;

END F_LIQ_DOSSIER;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  P_DUPLIQUE_DOSSIER_SANTE  / CLI 13/09/2017                */
/* Type         :  Privee                                                    */
/* Description  :  Retourne l'identifiant du dossier dupliqué                */
/*                  null si impossible de dupliquer le dossier               */
/* Entree       :                                                            */
/* Retour       :  le numéro du nouveau dossier                              */
/*---------------------------------------------------------------------------*/
PROCEDURE P_DUPLIQUE_DOSSIER_SANTE( i_num_dossier IN dossier_sante.num_dossier%type, i_num_dossier_out OUT dossier_sante.num_dossier%type)
IS
l_dossier DOSSIER_SANTE%ROWTYPE;
BEGIN

	SELECT * INTO l_dossier
	FROM dossier_sante
	WHERE num_dossier = i_num_dossier;
	-- récuperation de l'identifiant du nouveau dossier
	SELECT PK_CALCUL_DOSSIER.f_num_dossier(sysdate)
	INTO l_dossier.num_dossier
	FROM dual;
	-- modification des information du dossier dupliqué
	SELECT l_dossier.ref_dossier||'-'||(count(*)+1) INTO l_dossier.ref_dossier
		FROM dependance
		WHERE TYPE = 27
		AND numenvers = i_num_dossier;

	l_dossier.numutil := f_numutil();
	l_dossier.creation := sysdate;
	l_dossier.dateouv := sysdate;


	INSERT INTO dossier_sante VALUES l_dossier;

	INSERT INTO dependance(numde, role, numenvers, datapli, datper, type)
			VALUES ( l_dossier.num_dossier, 3,i_num_dossier , sysdate, null, 27);

	COMMIT;
	i_num_dossier_out:= l_dossier.num_dossier;

EXCEPTION
WHEN OTHERS THEN
 i_num_dossier_out :=null;

END P_DUPLIQUE_DOSSIER_SANTE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_MAJ_SNTRPRT  / ABO 27/06/2012                           */
/* Type         :  Publique                                                  */
/* Description  :  Retourne vrai si une mise Ó jour  de sinistre_porte a     */
/*                ÚtÚ effectuÚe                                              */
/* Entree       :                                                            */
/* Retour       : booleen                                                    */
/*---------------------------------------------------------------------------*/


FUNCTION F_MAJ_SNTRPRT( i_numremise  IN sinistre_porte.numremise%TYPE,
                        i_numporte   IN sinistre_porte.numporte%TYPE,
                        i_numsin     IN sinistre_porte.numsin%TYPE,
                        i_refcie     IN sinistre_porte.refcie%TYPE,
                        i_montant    IN sinistre_porte.mtprestarmedi%TYPE,
                        i_etat       IN sinistre_porte.etat%TYPE )
RETURN BOOLEAN IS
BEGIN
  UPDATE SINISTRE_PORTE
  SET mtprestarmedi = NVL(i_montant,mtprestarmedi),
      --mtprestarmedi_d = NVL(i_montant,mtprestarmedi_d),
      etat = NVL(i_etat,etat),
      refcie = NVL (i_refcie,refcie)
  WHERE numremise = i_numremise
  AND numsin = i_numsin
  AND numporte = i_numporte;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN RETURN FALSE;
END F_MAJ_SNTRPRT;
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_MAJ_SNTR_DOSSIER  / ABO 18/09/2019                      */
/* Type         :  Publique                                                  */
/* Description  :                           */
/* Entree       :                                                            */
/* Retour       : Erreur number                                               */
/*---------------------------------------------------------------------------*/


PROCEDURE P_MAJ_SNTR_DOSSIER( i_numremise  IN sinistre_porte.numremise%TYPE,
                        i_numporte   IN sinistre_porte.numporte%TYPE  ,
                        i_numutil    IN utilisateurs.numutil%TYPE,
                        o_numano    OUT NUMBER)  IS

  CURSOR C_sntr_remise(p_numremise IN porte_remise.numremise%TYPE) IS
    SELECT s.mtreel, sd.numligne , sd.num_dossier
    FROM SNTR_REF sr,SINISTRE s, SNTR_DOSSIER sd,sinistre_porte sp, sinistre_sante ss
    WHERE sr.numremise = p_numremise
    AND sr.numsin = s.numsin
    AND sd.numsin_sntr = s.numsin
    AND sp.etat =1
    AND sp.numsin = sr.numsin_porte
    AND sp.numremise = sr.numremise
    AND ss.SITUATION <>2
    AND ss.numligne =sd.numligne
    AND ss.num_dossier = sd.num_dossier
    ;

BEGIN
  --Objectif : suite calcul PROC rapprochement entre les sinistres externes calculés et les dossier santé

  --Création en masse des sntr_dossier reliant sinistre_sante et sinistres
  INSERT INTO SNTR_DOSSIER (NUM_DOSSIER, NUMLIGNE,NUMSIN_SNTR)
    SELECT ds.num_dossier,ss.numligne, sr.numsin
    FROM DOSSIER_SANTE ds, SINISTRE_SANTE ss , SNTR_REF sr
    WHERE ds.num_dossier =ss.num_dossier
    AND ds.numporte = i_numporte
    AND ds.numremise_sntrprt = i_numremise
    AND ds.numremise_sntrprt = sr.numremise
    AND ss.numsin_sntrprt = sr.numsin_porte
    AND NOT EXISTS (SELECT NUMSIN FROM SNTR_DOSSIER WHERE NUMSIN_SNTR=sr.numsin);

  --pas de MAJ possible si sntr_dossier vide
  FOR R_sntr_remise IN C_sntr_remise(i_numremise) LOOP
    UPDATE SINISTRE_SANTE
    SET mtprest = R_sntr_remise.mtreel,
        mtprest_reel = R_sntr_remise.mtreel,
        SITUATION = 2 ,
        numutil_modif =i_numutil,
        date_modif = sysdate
    WHERE numligne = R_sntr_remise.NUMLIGNE
    AND num_dossier = R_sntr_remise.NUM_DOSSIER
    AND situation = 1;

    IF SQL%ROWCOUNT >0 THEN
      INSERT INTO HISTO_SINISTRE_SANTE
								( HISTO_SNTR_SANTE,
									num_dossier,
								  numligne,
								  etat,
								  motif,
								  datetat,
								  numutil)
							 VALUES (
							 		HISTO_SNTR_SANTE.nextval,
							 		R_sntr_remise.NUM_DOSSIER,
									R_sntr_remise.NUMLIGNE,
									2,
									0,
									SYSDATE,
									i_numutil);

    END IF;
  END LOOP;
  o_numano:=0;


EXCEPTION
  WHEN OTHERS THEN
   P_INS_journal(1,'Report dossier impossible :',SQLERRM);
  o_numano:= 126;
END P_MAJ_SNTR_DOSSIER;
-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv

-- Insertion dans journal_adm
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF G_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
       INTO G_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = G_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
            G_niv_msg := 1;
    END;
  END IF;
  IF G_niv_msg >= P_niv THEN
     G_IDLIGNE := G_IDLIGNE +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => G_nom_traitement,
        I_session  => SID,
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

---------------- Fin des corps des procedures privees --

END PK_CALCUL_DOSSIER;
/
