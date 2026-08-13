CREATE OR REPLACE PACKAGE ARTHUS.PK_PARTENARIAT AS
/*===========================================================================*/
/* Package      : PK_PARTENARIAT.sql                                         */
/* Domaine      : PERSONNES COMMISSIONNEMENT                                 */
/* Version      : V1.0                                                       */
/* Auteur       : JPB                                                        */
/* Création     : 09/05/2011                                                 */
/* Description  : Package des fonctions spécifiques au projet Commissionnement */
/*              : unique, permet de récupérer la situation du partenariat    */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_SEL_PARTENAIRE                                          */
/* Type         :  Privé                                                     */
/* Description  :  détermine la situation d'un partenariat sa date et        */
/*                 son motif à partir de la table HISTO_PARTENARIAT          */
/* Entree       :  I_numindiv, Numéro d'individu                             */
/*                 I_type_apport, Type d'apporteur                           */
/* Entree/Sortie:  IO_debut, date de début                                   */
/* Retour       :  O_motif, Motif                                            */
/*                 O_etat, Etat de la situation                              */
/*              :  O_datsai, date de saisie                                  */
/*---------------------------------------------------------------------------*/


PROCEDURE P_SEL_PARTENAIRE
                ( I_numindiv  IN  histo_partenariat.numindiv%TYPE,
                  I_type_apport IN  histo_partenariat.type_apport%TYPE,
                  IO_debut  IN OUT histo_partenariat.debut%TYPE ,
                  O_datsai  OUT histo_partenariat.datsai%TYPE,
                  O_etat    OUT histo_partenariat.etat%TYPE,
                  O_motif   OUT histo_partenariat.motif%TYPE);
/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_EXIST_PARTENARIAT                                       */
/* Type         :  Privé                                                     */
/* Description  :  Teste si le paramètre partenariat =1                      */
/* Entree       :                                                            */
/*                                                                           */
/* Entree/Sortie:                                                            */
/* Retour       :  1 si partenariat=1                                        */
/*                 O pour les autres cas                                     */
/*              : -1  en cas d'exception                                     */
/*---------------------------------------------------------------------------*/
FUNCTION F_EXIST_PARTENARIAT RETURN NUMBER;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_ETAT_PARTENARIAT                                        */
/* Type         :  Public                                                    */
/* Description  :  Retourne l'état du partenariat                            */
/* Entree       :                                                            */
/*                                                                           */
/* Entree/Sortie:                                                            */
/* Retour       :  1 si partenariat=1                                        */
/*                 O pour les autres cas                                     */
/*              : -1  si le partenariat est incomplet                        */
/*                -2 si la fiche partenaire n'existe pas                     */
/*---------------------------------------------------------------------------*/
FUNCTION F_ETAT_PARTENARIAT(i_numgar contrat.numgar%type,
                            i_idadhesion qttc_global.idadhesion%type,
                            i_type_tfc qttc_affec_tfc.type_tfc%type,
                            i_numindiv qttc_affec_tfc.numbene%type,
                            i_debut_echeance qttc_global.debut%type)
        RETURN NUMBER;
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_PARTENARIAT AS

PROCEDURE P_SEL_PARTENAIRE
              ( I_numindiv    IN  histo_partenariat.numindiv%TYPE,
                I_type_apport IN  histo_partenariat.type_apport%TYPE,
                IO_debut      IN OUT histo_partenariat.debut%TYPE ,
                O_datsai      OUT histo_partenariat.datsai%TYPE,
                O_etat        OUT histo_partenariat.etat%TYPE,
                O_motif       OUT histo_partenariat.motif%TYPE)

AS

  CURSOR C_histo_partenariat IS
       SELECT type_apport,
              debut,
              datsai,
              etat,
              motif
       FROM   histo_partenariat
       WHERE  numindiv = I_numindiv
       AND type_apport = I_type_apport
       AND    debut <= NVL(IO_debut,SYSDATE)
       ORDER BY debut DESC,datsai DESC;

  Rec_c_histo_partenariat C_histo_partenariat%ROWTYPE;

BEGIN
  OPEN  C_histo_partenariat;
       FETCH C_histo_partenariat INTO Rec_c_histo_partenariat;
  CLOSE C_histo_partenariat;

  IO_debut := Rec_c_histo_partenariat.debut;
  O_etat  :=Rec_c_histo_partenariat.etat;
  O_motif := Rec_c_histo_partenariat.motif;
  O_datsai := Rec_c_histo_partenariat.datsai;

END;

FUNCTION F_EXIST_PARTENARIAT RETURN NUMBER AS
  l_val NUMBER;
  CURSOR c_param IS
    SELECT partenariat
    FROM parametres;

  rec_c_param c_param%rowtype;
BEGIN
  OPEN c_param;
      FETCH c_param INTO rec_c_param;
  CLOSE c_param;

  IF rec_c_param.partenariat = 1 THEN
    l_val:= 1;
  ELSE
    l_val:=0;
  END IF;

  RETURN l_val;

EXCEPTION WHEN OTHERS THEN
  l_val := -1;
  RETURN (l_val);
END F_EXIST_PARTENARIAT;


FUNCTION f_etat_partenariat (i_numgar contrat.numgar%TYPE,
                             i_idadhesion qttc_global.idadhesion%TYPE,
                             i_type_tfc qttc_affec_tfc.type_tfc%TYPE,
                             i_numindiv qttc_affec_tfc.numbene%TYPE,
                             i_debut_echeance qttc_global.debut%TYPE)
RETURN NUMBER AS

  l_etat                       NUMBER;
  l_etendue                    NUMBER;
  l_type_apport                apporteur.type_apport%TYPE;
  l_echeance                   histo_partenariat.debut%TYPE;
  l_date_sai                   histo_partenariat.datsai%TYPE;
  l_motif                      histo_partenariat.motif%TYPE;
  l_blocage                    qttc_affec_tfc.blocage%TYPE;

BEGIN
  IF pk_partenariat.f_exist_partenariat = 1 THEN

    IF i_type_tfc IN (1,2) THEN
      BEGIN

        SELECT DISTINCT app.type_apport INTO l_type_apport
                  FROM apporteur app
                  WHERE app.type_apport = i_type_tfc
                  AND app.etendue = 0
                  AND app.numindiv = i_numindiv
                  AND app.cle = 0;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_etat := -2;
        RETURN l_etat;
      END;

       l_echeance := i_debut_echeance;

       pk_partenariat.p_sel_partenaire(
                      I_numindiv =>    i_numindiv,
                      I_type_apport => l_type_apport,
                      IO_debut =>      l_echeance,
                      O_datsai =>      l_date_sai ,
                      O_etat =>        l_etat,
                      O_motif =>       l_motif);

       IF l_etat IS NULL THEN
           l_etat :=-1;
       END IF;
    ELSE
      l_etat :=0;
    END IF;
  ELSE
    l_etat := 0;
  END IF;
  RETURN (l_etat);
EXCEPTION WHEN OTHERS THEN
  l_etat := -10;
RETURN (l_etat);
END f_etat_partenariat;


END PK_PARTENARIAT;
/
