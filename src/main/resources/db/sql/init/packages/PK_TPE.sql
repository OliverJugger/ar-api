CREATE OR REPLACE PACKAGE ARTHUS.PK_TPE
AS
/*============================================================================*/
/* Package      : PK_TPE.sql                                                  */
/* Domaine      : TP Hospitalier                                              */
/* Version      : V1.0                                                        */
/* Auteur       : SDA                                                         */
/* Création     : 29/08/2014                                                  */
/* Description  : fonction et procédure insertion pour un import TPE          */
/*              :                                                             */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/* Correction   : PHA 05/07/2016 utilisation sequence seq_numremise           */
/*============================================================================*/


FUNCTION F_INS_PRTREM(
         i_porte_remise PORTE_REMISE%ROWTYPE)
RETURN VARCHAR2;

PROCEDURE P_UDT_PORTE_REMISE(i_porte_remise PORTE_REMISE%ROWTYPE);

FUNCTION F_INS_SNTRPRT (
         i_Sinistre_porte  IN SINISTRE_PORTE%ROWTYPE
) RETURN VARCHAR2;
FUNCTION F_UPD_SNTRPRT (i_Sinistre_porte  IN SINISTRE_PORTE%ROWTYPE)
RETURN VARCHAR2;

FUNCTION F_INS_SUIVIFACT(
         i_suivi_fact_tpe in suivi_fact_tpe%ROWTYPE
) RETURN VARCHAR2;
FUNCTION F_UPD_SUIVIFACT(i_Suivi_fact_tpe  IN SUIVI_FACT_TPE%ROWTYPE)
RETURN VARCHAR2;
FUNCTION F_INS_STOCKENT(
         i_stock_entite in stock_entite%ROWTYPE
) RETURN VARCHAR2;
PROCEDURE P_UPD_STOCKENT_REJET(i_stock_entite in stock_entite%ROWTYPE,i_type varchar2);

FUNCTION F_INS_STOCKENT_P(
         i_stock_entite_p in stock_entite_p%ROWTYPE
) RETURN VARCHAR2;
PROCEDURE P_UPD_STOCKENT_P_REJET(i_stock_entite in stock_entite_p%ROWTYPE,i_type varchar2);
PROCEDURE P_DELETE_INFOS_TPE(
         i_numremise    in porte_remise.numremise%TYPE,
         i_traitement   in    VARCHAR2,
         i_numporte     IN porte_remise.numporte%TYPE
);

FUNCTION F_VERIF_PORTE_REMISE(
         i_numporte     IN    porte_remise.numporte%TYPE,
         i_nature       IN    porte_remise.nature%TYPE,
         i_dateporte    IN    porte_remise.dateporte%TYPE,
         i_ref_ext      IN    porte_remise.ref_ext%TYPE
) RETURN NUMBER;

PROCEDURE P_MAJ_PORTE_ADHESION_NOMBRE( i_numremise    IN remise_externe.numremise%TYPE
                                     , i_numporte     IN remise_externe.numporte%TYPE
                                     , i_nombre       IN remise_externe.nombre%TYPE);

PROCEDURE P_MAJ_PORTE_ADHESION_REMISE( i_numremise    IN porte_remise.numremise%TYPE
                                     , i_numporte     IN porte_remise.numporte%TYPE
                                     , i_idporte      IN porte_adhesion.idporte%TYPE);

PROCEDURE P_MAJ_PORTE_ADHESION_TRANSMIS( i_numremise    IN porte_remise.numremise%TYPE);

PROCEDURE P_MAJ_REMISE_EXTERN_DATE_TRANS( i_numremise    IN porte_remise.numremise%TYPE);

PROCEDURE P_gestion_remise_externe( i_numporte        IN    remise_externe.numporte%TYPE
                                  , i_nat_porte       IN    remise_externe.nature%TYPE
                                  , o_numremise       OUT   remise_externe.numremise%TYPE
                                  , o_erreur          OUT   journal_adm.msg_adm%TYPE);

PROCEDURE P_MAJ_MT_SUIVI_FACT_TPE( i_numremise        IN porte_remise.numremise%TYPE ,
                                   i_idfactpe         IN suivi_fact_tpe.idfactpe%TYPE,
                                   i_montant          IN suivi_fact_tpe.montant%TYPE );
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_TPE AS

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_PORTE_REMISE                                        */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans PORTE_REMISE                   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_PRTREM(i_porte_remise PORTE_REMISE%ROWTYPE)
RETURN VARCHAR2
IS
BEGIN
  INSERT INTO PORTE_REMISE VALUES i_porte_remise;
  RETURN 'OK';
EXCEPTION
  WHEN OTHERS THEN
    RETURN substr('others:' || SQLERRM,1,132);
END F_INS_PRTREM;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_UDT_PORTE_REMISE                                   */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de porte_remise*/
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_UDT_PORTE_REMISE(i_porte_remise PORTE_REMISE%ROWTYPE)

IS
BEGIN
    UPDATE porte_remise SET destinataire = i_porte_remise.destinataire ,
                            norme = i_porte_remise.norme
                        WHERE numremise = i_porte_remise.numremise;
END P_UDT_PORTE_REMISE;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_SNTRPRT                                             */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SINISTRE_PORTE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_SNTRPRT (i_Sinistre_porte  IN SINISTRE_PORTE%ROWTYPE)
RETURN VARCHAR2
IS
BEGIN

  INSERT INTO SINISTRE_PORTE VALUES i_Sinistre_porte;
  RETURN 'OK';

EXCEPTION
  WHEN OTHERS THEN
    RETURN substr('Sin :'|| i_Sinistre_porte.numsin ||' Err:'|| SQLERRM,1,132);
END F_INS_SNTRPRT;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_UPD_SNTRPRT                                             */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SINISTRE_PORTE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_UPD_SNTRPRT (i_Sinistre_porte  IN SINISTRE_PORTE%ROWTYPE)
RETURN VARCHAR2
IS
BEGIN

 /* UPDATE SINISTRE_PORTE SET ROW =i_Sinistre_porte
  WHERE numsin = i_Sinistre_porte.numsin
  AND numremise = i_Sinistre_porte.numremise;*/

  --obliger de préciser les colonnes à cause du trigger BF_INS
  UPDATE SINISTRE_PORTE SET
  noe_premtt = i_Sinistre_porte.noe_premtt,
  datpresc = i_Sinistre_porte.datpresc ,
  speprescrip = i_Sinistre_porte.speprescrip,
  numprescrip = i_Sinistre_porte.numprescrip,
  racmon =i_Sinistre_porte.racmon,
  noe_prvtop =i_Sinistre_porte.noe_prvtop,
  noe_prvqlf = i_Sinistre_porte.noe_prvqlf,
  locdent1 =i_Sinistre_porte.locdent1,
  locdent2 = i_Sinistre_porte.locdent2,
  locdent3 = i_Sinistre_porte.locdent3 ,
  locdent4 = i_Sinistre_porte.locdent4,
  locdent5 = i_Sinistre_porte.locdent5,
  locdent6 = i_Sinistre_porte.locdent6,
  locdent7 = i_Sinistre_porte.locdent7,
  locdent8 = i_Sinistre_porte.locdent8,
  locdent9 = i_Sinistre_porte.locdent9,
  locdent10 = i_Sinistre_porte.locdent10,
  locdent11 = i_Sinistre_porte.locdent11,
  locdent12 = i_Sinistre_porte.locdent12,
  locdent13 = i_Sinistre_porte.locdent13,
  locdent14 = i_Sinistre_porte.locdent14,
  locdent15 = i_Sinistre_porte.locdent15,
  locdent16 = i_Sinistre_porte.locdent16,
  codmodif1 = i_Sinistre_porte.codmodif1,
  codmodif2  = i_Sinistre_porte.codmodif2,
  codmodif3 = i_Sinistre_porte.codmodif3,
  codmodif4 =  i_Sinistre_porte.codmodif4,
  codelpp   =  i_Sinistre_porte.codelpp,
  codeucd   = i_Sinistre_porte.codeucd,
  codeccam  = i_Sinistre_porte.codeccam,
  codeactiv = i_Sinistre_porte.codeactiv,
  coderemb  = i_Sinistre_porte.coderemb,
  INDICATSUBSTIT = i_Sinistre_porte.INDICATSUBSTIT,
  TRANSPORTHOSPI = i_Sinistre_porte.TRANSPORTHOSPI,
  LONGDISTANCE   = i_Sinistre_porte.LONGDISTANCE,
  FORFAIT        = i_Sinistre_porte.FORFAIT,
  noe_crdopt     =i_Sinistre_porte.noe_crdopt
  WHERE numsin = i_Sinistre_porte.numsin
  AND numremise = i_Sinistre_porte.numremise;



  RETURN 'OK';

EXCEPTION
  WHEN OTHERS THEN
    RETURN substr('others:' || SQLERRM,1,132);
END F_UPD_SNTRPRT;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_UPD_SUIVIFACT                                           */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SUIVI_FACT_TPE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_UPD_SUIVIFACT (i_Suivi_fact_tpe  IN SUIVI_FACT_TPE%ROWTYPE)
RETURN VARCHAR2
IS
BEGIN

  UPDATE SUIVI_FACT_TPE SET ROW =i_Suivi_fact_tpe
  WHERE idfactpe = i_Suivi_fact_tpe.idfactpe
  AND numremise_import = i_Suivi_fact_tpe.numremise_import
  AND codevefac = i_Suivi_fact_tpe.codevefac ;

  IF i_Suivi_fact_tpe.codevefac = 10 THEN
    UPDATE SUIVI_FACT_TPE SET montant = i_Suivi_fact_tpe.montant
    WHERE idfactpe = i_Suivi_fact_tpe.idfactpe
    AND numremise_import = i_Suivi_fact_tpe.numremise_import
    AND codevefac = 30 ;
  END IF;

  RETURN 'OK';

EXCEPTION
  WHEN OTHERS THEN
    RETURN substr('others:' || SQLERRM,1,132);
END F_UPD_SUIVIFACT;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_SUIVIFACT                                           */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans SUIVI_FACT_TPE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_SUIVIFACT(
         i_suivi_fact_tpe in suivi_fact_tpe%ROWTYPE
) RETURN VARCHAR2
IS
BEGIN

  INSERT INTO SUIVI_FACT_TPE VALUES i_suivi_fact_tpe;
  RETURN 'OK';

EXCEPTION
  WHEN OTHERS THEN
    RETURN substr('others:' || SQLERRM,1,132);
END F_INS_SUIVIFACT;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_STOCKENT                                            */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans STOCK_ENTITE                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_STOCKENT(
         i_stock_entite in stock_entite%ROWTYPE
) RETURN VARCHAR2
IS
BEGIN

  INSERT INTO STOCK_ENTITE VALUES i_stock_entite;
  RETURN 'OK';

EXCEPTION
  WHEN OTHERS THEN
    RETURN substr('others:' || SQLERRM,1,132);
END F_INS_STOCKENT;


/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                 */
/* Nom          :  F_UPD_STOCKENT                                            */
/* Type         :  Public                                                    */
/* Description  :  fonction de maj de        stock_entite                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_UPD_STOCKENT_REJET(i_stock_entite in stock_entite%ROWTYPE,i_type varchar2)
IS

BEGIN

  UPDATE STOCK_ENTITE SET group_rejet = i_stock_entite.group_rejet
  WHERE group_rejet IS NULL
  AND numremise = i_stock_entite.numremise
  AND numsin = i_stock_entite.numsin
  AND cod_entite like i_type||'%';

EXCEPTION
  WHEN OTHERS THEN  NULL;
    --RETURN 'numreimse:'||i_stock_entite.numremise||'numsin'||i_stock_entite.numsin||'ordre'||i_stock_entite.ordre ;
    --substr('others:' || SQLERRM,1,132);
END P_UPD_STOCKENT_REJET;
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_STOCKENT_P                                          */
/* Type         :  Public                                                    */
/* Description  :  fonction d insertion dans STOCK_ENTITE_P                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_STOCKENT_P(
         i_stock_entite_p in stock_entite_p%ROWTYPE
) RETURN VARCHAR2
IS
BEGIN

  INSERT INTO STOCK_ENTITE_P VALUES i_stock_entite_p;
  RETURN 'OK';

EXCEPTION
  WHEN OTHERS THEN
    RETURN substr('others:' || SQLERRM,1,132);
END F_INS_STOCKENT_P;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_UPD_STOCKENT_P                                          */
/* Type         :  Public                                                    */
/* Description  :  fonction de maj de        stock_entite                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_UPD_STOCKENT_P_REJET(i_stock_entite in stock_entite_p%ROWTYPE,i_type varchar2)
IS
BEGIN

  UPDATE STOCK_ENTITE_P SET group_rejet = i_stock_entite.group_rejet
  WHERE group_rejet IS NULL
  AND numremise = i_stock_entite.numremise
  AND numsin = i_stock_entite.numsin
  AND cod_entite like i_type||'%';

EXCEPTION
  WHEN OTHERS THEN NULL;
END P_UPD_STOCKENT_P_REJET;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_DELETE_INFOS_TPE                                        */
/* Type         :  Public                                                    */
/* Description  :  fonction de delete des infos TPE                          */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_DELETE_INFOS_TPE(
         i_numremise    IN porte_remise.numremise%TYPE,
         i_traitement   IN VARCHAR2,
         i_numporte     IN porte_remise.numporte%TYPE
)
IS
BEGIN

  IF i_traitement = 'NO33T' THEN
     DELETE FROM stock_entite WHERE numremise = i_numremise;
  ELSIF i_traitement = 'NO34T' THEN
     DELETE FROM stock_entite_p WHERE numremise = i_numremise;
  ELSE
   NULL;
  END IF;

  DELETE FROM sinistre_porte WHERE numremise = i_numremise;

  DELETE FROM suivi_fact_tpe WHERE numremise_import = i_numremise;

  DELETE from porte_remise WHERE numremise = i_numremise AND numporte=i_numporte;

END P_DELETE_INFOS_TPE;


/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_VERIF_PORTE_REMISE                                      */
/* Type         :  Public                                                    */
/* Description  :  fonction qui verifie si un import de fichier a déjà été   */
/*                 effectué                                                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_VERIF_PORTE_REMISE(
         i_numporte     IN    porte_remise.numporte%TYPE,
         i_nature       IN    porte_remise.nature%TYPE,
         i_dateporte    IN    porte_remise.dateporte%TYPE,
         i_ref_ext      IN    porte_remise.ref_ext%TYPE
) RETURN NUMBER
IS
 v_numremise porte_remise.numremise%TYPE := null;
BEGIN
      SELECT    numremise
      INTO    v_numremise
      FROM    porte_remise
      WHERE    numporte = i_numporte
      AND   nature   = i_nature
      AND      dateporte = i_dateporte
      AND   ref_ext = i_ref_ext;

      IF v_numremise is not null THEN
         RETURN v_numremise;
      END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 1;
  WHEN OTHERS THEN
    RETURN 2;
END F_VERIF_PORTE_REMISE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_PORTE_ADHESION_NOMBRE                               */
/* Type         :  Public                                                    */
/* Description  :  Mise à jour du nombre de remise du borederau TP Hospi     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_PORTE_ADHESION_NOMBRE( i_numremise    IN remise_externe.numremise%TYPE
                                     , i_numporte     IN remise_externe.numporte%TYPE
                                     , i_nombre       IN remise_externe.nombre%TYPE)
IS
BEGIN

  UPDATE remise_externe
     SET nombre=i_nombre
   WHERE numremise = i_numremise
     AND numporte = i_numporte ;

END P_MAJ_PORTE_ADHESION_NOMBRE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_PORTE_ADHESION_REMISE                               */
/* Type         :  Public                                                    */
/* Description  :  Mise à jour du numéro de remise du borederau TP Hospi     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_PORTE_ADHESION_REMISE( i_numremise    IN porte_remise.numremise%TYPE
                                     , i_numporte     IN porte_remise.numporte%TYPE
                                     , i_idporte      IN porte_adhesion.idporte%TYPE)
IS
BEGIN

  UPDATE porte_adhesion
     SET numremise = i_numremise
   WHERE i_numporte = i_numporte
     AND idporte=i_idporte;

END P_MAJ_PORTE_ADHESION_REMISE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_PORTE_ADHESION_TRANSMIS                             */
/* Type         :  Public                                                    */
/* Description  :  Mise à jour de la transmission du mouvement TP Hospi      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_PORTE_ADHESION_TRANSMIS( i_numremise    IN porte_remise.numremise%TYPE)
IS
BEGIN

  UPDATE porte_adhesion
     SET transmis = 1
   WHERE numremise = i_numremise;

END P_MAJ_PORTE_ADHESION_TRANSMIS;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_REMISE_EXTERN_DATE_TRANS                            */
/* Type         :  Public                                                    */
/* Description  :  Mise à jour de la date de transmission de la remise Hospi */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_REMISE_EXTERN_DATE_TRANS( i_numremise    IN porte_remise.numremise%TYPE)
IS
BEGIN

  UPDATE remise_externe
     SET date_trans = TRUNC (SYSDATE)
   WHERE numremise = i_numremise;

END P_MAJ_REMISE_EXTERN_DATE_TRANS;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_gestion_remise_externe                                  */
/* Type         :  Public                                                    */
/* Description  :  procedure de Selection et insertion de la remise_esterne  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_gestion_remise_externe( i_numporte        IN    remise_externe.numporte%TYPE
                                  , i_nat_porte       IN    remise_externe.nature%TYPE
                                  , o_numremise       OUT   remise_externe.numremise%TYPE
                                  , o_erreur          OUT   journal_adm.msg_adm%TYPE)
IS
BEGIN

  -- Selection d'un nouveau de numéro de remise pour le bordereau à traiter
  /* SELECT NVL (MAX (numremise), 0) + 1
    INTO o_numremise
    FROM remise_externe; */

  SELECT seq_numremise.nextval into o_numremise from dual;

 -- P_INS_journal(1,'Numéro de bordereau en cours de traitement <'||o_numremise||'> ');

  IF NVL(o_numremise,0)=0 THEN
    o_erreur:='Impossible de récupérer un nouveau numéro de remise';
  ELSE
    -- insertion de la remise
    INSERT INTO remise_externe
                  (numremise, date_remise, numporte, nombre, batch, valide,
                   numutil, datedit, datvalide, date_trans, nature)
    VALUES(o_numremise, TRUNC (SYSDATE), i_numporte,0, '', 'N'
         , '', '', '', '', i_nat_porte);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_erreur:='Impossible d inserer dans remise_externe';
    o_numremise:=0;
END P_gestion_remise_externe;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_MT_SUIVI_FACT_TPE                                   */
/* Type         :  Public                                                    */
/* Description  :  Mise à jour du montant d'une facture                      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_MT_SUIVI_FACT_TPE( i_numremise    IN porte_remise.numremise%TYPE ,
                                i_idfactpe suivi_fact_tpe.idfactpe%TYPE,
                                i_montant suivi_fact_tpe.montant%TYPE )
IS
BEGIN
    UPDATE suivi_fact_tpe
    SET   montant = NVL(i_montant,0)
    WHERE idfactpe = i_idfactpe
    AND numremise_import = i_numremise;

END P_MAJ_MT_SUIVI_FACT_TPE;
END PK_TPE;
/
