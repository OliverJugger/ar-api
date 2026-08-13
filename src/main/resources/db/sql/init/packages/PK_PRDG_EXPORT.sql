CREATE OR REPLACE PACKAGE ARTHUS."PK_PRDG_EXPORT"
AS


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

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EX31T                                                   */
/* Type         :  Publique                                                  */
/* Description  :  Génére un flux dasn un fichier donnée                     */
/*                                                                           */
/* Entree       :  I_datedeb, date de début demandée en paramètre            */
/*                 I_datefin, date de fin demandée en paramètre              */
/*                 I_DG, identifiant du DG                                   */
/*                 I_PRdeb, identifiant du PR debut d'interval               */
/*                 I_PRfin, identifiant du PR fin d'interval                 */
/*                 I_typeflux, type de flux PRDG                             */
/*                 I_risque, idendifiant du risque santé ou prévyance        */
/*                 I_fonction, fonction du message                           */
/*                 I_idmsg, identifiant prdg du message                      */
/*                 I_session, numéro de la session                           */
/*                 I_niv_msg, niveau de trace du traitement                  */
/*                 I_repertoire, répertoire oracle d'expotation              */
/*                 I_fichier, modèle du nom de fichier                       */
/* Entree/Sortie:                                                            */
/* Retour       :  O_erreur, libellé de l'erreur                             */
/*                 O_found, erreur de Génération du fichier                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_EX31T (
  I_datedeb      IN DATE,
  I_datefin      IN DATE,
  I_DG           IN NUMBER,
  I_PRdeb        IN NUMBER,
  I_PRfin        IN NUMBER,
  I_typeflux     IN prdgflux.idprdgflux%TYPE,
  I_risque       IN NUMBER,
  I_fonction     IN NUMBER,
  I_idmsg        IN prdgechange.idmsg%TYPE,
  I_session      IN NUMBER DEFAULT 1,
  I_niv_msg      IN NUMBER DEFAULT 1,
  I_repertoire   IN VARCHAR2 DEFAULT NULL,
  I_fichier      IN VARCHAR2 DEFAULT NULL,
  O_found        OUT NUMBER,
  O_erreur       OUT VARCHAR2);
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  GENERE_FLUX                                               */
/* Type         :  Publique                                                  */
/* Description  :  Génére un flux dans un fichier donné                      */
/*                                                                           */
/* Entree       :  p_idFlux, type de tflux PRDG                              */
/*                 p_DG, identifiant du DG                                   */
/*                 p_PR, identifiant du PR                                   */
/*                 p_fonct, fonction du message                              */
/*                 p_ordreFx, rdre du flux dans le message                   */
/*                 p_idmsg, identifiant unique du message                    */
/*                 p_datedeb, date de début demandée en paramètre            */
/*                 p_datefin, date de fin demandée en paramètre              */
/*                 p_nbdup, numéro de duplicata                              */
/* Entree/Sortie:  p_prdg_flux, donnée à évaluer                             */
/* Retour       :  p_msgErreur, libellé de l'erreur                          */
/*                 p_erreur, erreur de Génération du fichier                 */
/*---------------------------------------------------------------------------*/
PROCEDURE GENERE_FLUX(
  p_prdg_flux IN OUT UTL_FILE.file_type,
  p_idFlux    IN prdgfxsg.idprdgflux%TYPE,
  p_DG        IN NUMBER,
  p_PR        IN NUMBER,
  p_fonct     IN VARCHAR2,
  p_ordreFx   IN NUMBER,
  p_idmsg     IN NUMBER,
  p_risque    IN VARCHAR2,
  p_datedeb   IN DATE,
  p_datefin   IN DATE,
  p_nbdup     IN NUMBER,
  p_msgErreur OUT VARCHAR2,
  p_erreur    OUT NUMBER
  );

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EDIT_PRDGECHANGE                                        */
/* Type         :  Publique                                                  */
/* Description  :  Insère dans une table temporaire un flux sauvegaré à      */
/*                 afficher                                                  */
/* Entree       :  P_idflux, identifiant unique du flux sauvegardé           */
/*                 P_typeFlux, type de flux                                  */
/* Entree/Sortie:                                                            */
/* Retour       :  O_found, numéro de l'erreur                               */
/*                 O_erreur, libellé de l'erreur                             */
/*---------------------------------------------------------------------------*/
PROCEDURE P_EDIT_PRDGECHANGE(P_idflux    IN prdgechange.idflux%TYPE,
                             P_typeFlux  IN prdgechange.idprdgflux%TYPE,
                             O_found     OUT NUMBER,
                             O_erreur    OUT VARCHAR2);



/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_REGEN_FILE                                              */
/* Type         :  Publique                                                  */
/* Description  :  Recréé à partir d'un flux sauvegardé un fichier physique  */
/*                 orginal ou dupliqué                                       */
/* Entree       :  P_idflux, identifiant unique du flux sauvegardé           */
/*                 p_fonction, fonction du flux si null original             */
/* Entree/Sortie:                                                            */
/* Retour       :  O_found, numéro de l'erreur                               */
/*                 O_erreur, libellé de l'erreur                             */
/*                 O_fichier, nom du fichier généré                          */
/*---------------------------------------------------------------------------*/
PROCEDURE P_REGEN_FILE(I_traitement IN 	typ_batch.BATCHID%TYPE,
                       P_idflux     IN prdgechange.idflux%TYPE,
                       p_fonction   IN NUMBER,
                       O_fichier    OUT VARCHAR2,
                       O_found      OUT NUMBER,
                       O_erreur     OUT VARCHAR2);
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_DONNEE_VALUE                                            */
/* Type         :  Publique                                                  */
/* Description  :     retourne la valeur de la donnée dans le segement       */
/*                                                                           */
/* Entree       :  P_idflux, identifiant unique du flux sauvegardé           */
/*                 P_idsegment, identifiant du segement                      */
/*                 P_iddonnee, identifiant de la donnée                      */
/* Entree/Sortie:                                                            */
/* Retour       :   valeur du champ                                          */
/*                                                                           */
/*                                                                           */
/*---------------------------------------------------------------------------*/
FUNCTION F_DONNEE_VALUE ( P_iddonnee  IN prdgdonnee.iddonnee%TYPE,
                          P_idsegment IN prdgsegment.idsegment%TYPE,
                          P_idflux    IN prdgechange.idflux%TYPE)
RETURN VARCHAR2;
-- ------------------------------------------------- Fin des procedures publiques --
END PK_PRDG_EXPORT;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_PRDG_EXPORT"
AS
/*===========================================================================*/
/* Package      : PK_PRDG_EXPORT.sql                                         */
/* Domaine      : Statistiques et pilotage                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ABO                                                        */
/* Création     : 29/11/2010                                                 */
/* Description  : Process de génération des flux PRDG, utilise le paramétrage*/
/*              : pour définir la strucure du fichier plat à générer         */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   :                                                            */
/*===========================================================================*/

-- -- CURSEUR, VARIABLES... PRIVEES ------------------------------------------

  TYPE TAB_Flux IS TABLE OF VARCHAR2(2004) index by binary_integer ;
  TYPE T_Sgt IS RECORD (Idsegment PRDGFXSG.Idsegment%TYPE,
                        numordre PRDGFXSG.numordre%TYPE,
                        nbmin PRDGFXSG.nbmin%TYPE,
                        nbmax PRDGFXSG.nbmax%TYPE,
                        taille  PRDGSEGMENT.taille%TYPE,
                        nom  PRDGSEGMENT.nomsegment%TYPE,
                        niveau   PRDGFXSG.niveau%TYPE);
  TYPE TAB_T_Sgt IS TABLE OF T_Sgt index by binary_integer ;
  TYPE TAB_Cpt   IS TABLE OF NUMBER index by binary_integer ;

  loc_Tab_Sgt TAB_T_Sgt ;
  loc_Tab_Cpt TAB_Cpt;


-- Variables d'écriture de fichier
   prdg_flux                   UTL_FILE.file_type;
   g_repertoire                typ_batch.repertoire%TYPE :='EXPORT';
   g_fichier                   VARCHAR2 (200) :='PRDG_#FX_#PR_#DT_#HR.txt';
   g_nomflux                   PRDGFLUX.nomflux%TYPE;
--
   ligne_f                     VARCHAR2 (32767);

-- Parametres de la demande
 /*  g_numremise                 remise_externe.numremise%TYPE;
   g_lnumremise                remise_externe.numremise%TYPE;
   g_fr_cpfixe                 VARCHAR2 (2)                         := '';*/

-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE      DEFAULT 'EX31T';
   --g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE          DEFAULT 1;
   --g_niv_msg                   journal_adm.niv_msg%TYPE             := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE             := 2;
   g_idligne                   journal_adm.idligne%TYPE             := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;

-- variable de format nombre
   g_fmt_nb_2d        CONSTANT VARCHAR2(30) :='99999999999999V90';
   g_fmt_nb_4d        CONSTANT VARCHAR2(30) :='99999999999999V9990';
   g_fmt_nb_ent       CONSTANT VARCHAR2(30) :='99999999999999';

-- exception
  data_error EXCEPTION;
-- -- FIN  ------------------------------------------------------------------

-- -- PROCEDURES PRIVEES ----------------------------------------------------

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_NOM_FICHIER                                             */
/* Type         :  Privé                                                     */
/* Description  :  Renvoit le nom du fichier à générer en focntion du modele */
/*                 séparateur                                                */
/* Entree       :  p_nom, modèle du nom paramétré du fichier à générer       */
/*                 p_PR, identifiant du preneur de risque                    */
/*                 p_nomflux, nom du flux                                    */
/* Entree/Sortie:                                                            */
/* Retour       :  chaine                                                    */
/*---------------------------------------------------------------------------*/
FUNCTION F_NOM_FICHIER(p_nom IN VARCHAR2,
                       p_PR IN individu.numindiv%TYPE,
                       p_nomflux prdgflux.nomflux%TYPE)
RETURN VARCHAR2;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  P_FICHIER_PARAM                                           */
/* Type         :  Privé                                                     */
/* Description  :  Renvoit nom de fichier paramétré pour un traitement v7    */
/*                 séparateur                                                */
/* Entree       :  I_traitement,nom du traitement                            */
/* Entree/Sortie:                                                            */
/* Retour       :  O_nom_fichier, modele du nom de fichier                   */
/*                 O_repertoire, répertoire oracle de destination            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_FICHIER_PARAM (	I_traitement 	 	IN 	typ_batch.BATCHID%TYPE,
														O_nom_fichier		OUT typ_batch.RESSOURCE%TYPE,
														O_repertoire		OUT typ_batch.REPERTOIRE%TYPE );

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_SPLIT                                                   */
/* Type         :  Privé                                                     */
/* Description  :  Renvoit la nième valeur d'une liste en fonction d'un      */
/*                 séparateur                                                */
/* Entree       :  p_list, liste de valeurs                                  */
/*                 p_pos, position dans la liste                             */
/*                 p_sep, séparateur                                         */
/* Entree/Sortie:                                                            */
/* Retour       :  chaine                                                    */
/*---------------------------------------------------------------------------*/
FUNCTION F_SPLIT(p_list VARCHAR2,p_pos NUMBER, p_sep IN VARCHAR2)
RETURN VARCHAR2;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_NBR_OCCURENCE                                           */
/* Type         :  Privé                                                     */
/* Description  :  Renvoit le nombre d'occurence d'un caractère dans une     */
/*                 chaine                                                    */
/* Entree       :  p_chaine, chaine à évaluer                                */
/*                 p_carac, caractère à calculer                             */
/* Entree/Sortie:                                                            */
/* Retour       :  nombre                                                    */
/*---------------------------------------------------------------------------*/
FUNCTION F_NBR_OCCURENCE (p_chaine VARCHAR2, p_carac VARCHAR2) RETURN NUMBER;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_EVAL_CONDITION                                          */
/* Type         :  Privé                                                     */
/* Description  :  Evalue une condition paramétrée                           */
/* Entree       :  p_chaine, chaine à évaluer                                  */
/*                 p_condition, condition à interpréter                      */
/* Entree/Sortie:                                                            */
/* Retour       :  boolean                                                   */
/*---------------------------------------------------------------------------*/
FUNCTION F_EVAL_CONDITION(p_chaine VARCHAR2,p_condition prdgsgdo.condition%TYPE)
RETURN VARCHAR2;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EVAL_PARAM                                              */
/* Type         :  Privé                                                     */
/* Description  :  Remplace une donnée par défaut paramètrée sous forme      */
/*                 de la balise par la valeur d'un paramètre passé à la proc */
/* Entree       :  p_nbsgt, nombre de segment                                */
/*                 p_DG, identifiant du DG                                   */
/*                 p_PR, identifiant du PR                                   */
/*                 p_fonct, fonction du flux                                 */
/*                 p_seqsgt, répétition du segment                           */
/*                 p_idmsg, identifiant unique du message                    */
/*                 p_risque, nature du risque du document                    */
/*                 p_ordrefx, ordre du flux dans le message                  */
/*                 p_datedeb, date de début demandée en paramètre            */
/*                 p_datefin, date de fin demandée en paramètre              */
/*                 p_nbdup, numéro de duplicata                              */
/*                 p_totreg, total des règlements                            */
/* Sortie       :  p_date, donnée évaluée est une date                       */
/* Entree/Sortie:  p_donnee, donnée à évaluer                                */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

PROCEDURE P_EVAL_PARAM(
  p_donnee      IN OUT VARCHAR2,
  p_taille      IN NUMBER,
  p_nbsgt       IN NUMBER,
  p_DG          IN individu.numindiv%TYPE,
  p_PR          IN individu.numindiv%TYPE,
  p_fonct       IN VARCHAR2,
  p_seqsgt      IN NUMBER,
  p_idmsg       IN NUMBER,
  p_risque      IN VARCHAR2,
  p_ordrefx     IN NUMBER,
  p_datedeb     IN DATE,
  p_datefin     IN DATE,
  p_nbdup       IN NUMBER,
  p_totreg      IN NUMBER,
  p_date        OUT DATE
  );

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_ins_journal                                             */
/* Type         :  Privé                                                     */
/* Description  :  Appel la procedure de trace de pk_trace                   */
/*                                                                           */
/* Entree       :  p_msg, message à enregistr                                */
/* Sortie       :                                                            */
/* Entree/Sortie:                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE p_ins_journal(p_msg IN journal_adm.msg_adm%TYPE,p_niv journal_adm.niv_msg%TYPE);

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INSERT_PRDG_ECHANGE                                     */
/* Type         :  Privé                                                     */
/* Description  :  Sauvegarde du flux généré pour constitué un historique    */
/*                 renvoit vrai si cles identiques et niveau max non atteint */
/* Entree       :  p_emet, emeteur du flux                                   */
/*                 p_dest, destinataire du flux                              */
/*                 p_idmsg, identifiant du message                           */
/*                 p_datedeb, date de début du flux                          */
/*                 p_datefin, date de fin du flux                            */
/*                 p_risque, risque du flux                                  */
/*                 p_typeflux, type de flux                                  */
/*                 p_fonction, fonction du flux (duplicata, original...)     */
/*                 p_nbdup, numéro de duplicata                              */
/*                 p_msg, flus à sauvegarder                                 */
/*                 p_etat, état du flux                                      */
/*                 p_fichier, nom du fichier généré                          */
/* Entree/Sortie:                                                            */
/* Retour       :  nombre, identifiant unique du flux                        */
/*---------------------------------------------------------------------------*/

FUNCTION F_INSERT_PRDG_ECHANGE(p_emet     individu.numindiv%TYPE,
                               p_dest     individu.numindiv%TYPE,
                               p_idmsg    prdgechange.idmsg%TYPE,
                               p_datedeb  DATE,
                               p_datefin  DATE,
                               p_risque   NUMBER,
                               p_typeflux prdgflux.idprdgflux%TYPE,
                               p_fonction NUMBER,
                               p_nbdup    NUMBER,
                               p_msg      prdgechange.contenu%TYPE,
                               p_etat     NUMBER,
                               p_fichier   VARCHAR2)
RETURN NUMBER;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  GENERE_SGMT                                               */
/* Type         :  Privé                                                     */
/* Description  :  Génére un segment en fonction d'un enregisterment de      */
/*                curseur                                                    */
/* Entree       :  p_idsegment, identifiant du segment                       */
/*                 p_ligne, enregistrement du curseur actuel                 */
/*                 op_nb, niveau courant du parcourt                         */
/*                 p_nbsgt, nombre de segment                                */
/*                 p_DG, identifiant du DG                                   */
/*                 p_PR, identifiant du PR                                   */
/*                 p_fonct, fonction du flux                                 */
/*                 p_seqsgt, répétition du segment                           */
/*                 p_idmsg, identifiant unique du message                    */
/*                 p_ordrefx, ordre du flux dans le message                  */
/*                 p_datedeb, date de début demandée en paramètre            */
/*                 p_datefin, date de fin demandée en paramètre              */
/*                 p_totreg, total des règlements                            */
/* Sortie       :  p_sgt,segment généré                                      */
/*                 p_msgErreur, libellé de l'erreur                          */
/*                 p_erreur, numéro de l'erreur                              */
/* Entree/Sortie:                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE GENERE_SGMT(
  p_idFlux      IN prdgfxdo.IDPRDGFLUX%TYPE,
  p_idsegment   IN prdgfxsg.idsegment%TYPE,
  p_ligne       IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  op_nb         IN NUMBER,
  p_nbsgt       IN NUMBER,
  p_DG          IN individu.numindiv%TYPE,
  p_PR          IN individu.numindiv%TYPE,
  p_fonct       IN VARCHAR2,
  p_seqsgt      IN NUMBER,
  p_idmsg       IN NUMBER,
  p_risque      IN VARCHAR2,
  p_ordrefx     IN NUMBER,
  p_datedeb     IN DATE,
  p_datefin     IN DATE,
  p_nbdup       IN NUMBER,
  p_totreg      IN OUT NUMBER,
  p_sgt         OUT VARCHAR2,
  p_msgErreur   OUT VARCHAR2,
  p_erreur      OUT NUMBER
  );

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  RECH_SEGMENT_RECUR                                        */
/* Type         :  Privé                                                     */
/* Description  :  Défini le parcourt de la vue en fonction des cles de      */
/*                 rupture                                                   */
/* Entree       :  p_Tab_Sgt, tableau des segments fonctionnels              */
/*                 p_DG, identifiant du DG                                   */
/*                 p_PR, identifiant du PR                                   */
/*                 max_niv, niveau maximum à atteindre                       */
/* Entree/Sortie:  p_c_data, donnée à évaluer                                */
/*                 p_Ligne, enregistrement du curseur actuel                 */
/*                 p_LignePrecedente, enregistrement du curseur précédent    */
/*                 p_nbenr, nombre de segement créé                          */
/*                 p_totreg, total des règlements                            */
/*                 p_Tab_Corps, tableau d'enregistrement des segments fonct. */
/*                 op_nb, niveau courant du parcourt                         */
/*                 p_erreur, erreur de Génération du fichier                 */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

PROCEDURE RECH_SEGMENT_RECUR (
  p_idFlux           IN prdgfxdo.IDPRDGFLUX%TYPE,
  p_c_data           IN OUT INTEGER,
  p_Ligne            IN OUT PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  p_LignePrecedente  IN OUT PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  p_Tab_Sgt          IN TAB_T_Sgt,
  p_nbenr            IN OUT NUMBER,
  p_totreg           IN OUT NUMBER,
  p_Tab_Corps        IN OUT TAB_Flux,
  p_DG               IN individu.numindiv%TYPE,
  p_PR               IN individu.numindiv%TYPE,
  max_niv            IN NUMBER,
  max_clef           IN NUMBER,
  op_nb              IN OUT NUMBER,
  datedeb            IN DATE,
  datefin            IN DATE,
  p_erreur           OUT NUMBER) ;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_TEST_RUPTURE                                            */
/* Type         :  Privé                                                     */
/* Description  :  Teste en recursif si le niveau actuel présente une rupture*/
/*                 renvoit vrai si cles identiques et niveau max non atteint */
/* Entree       :  p_c_data, donnée à évaluer                                */
/*                 p_Ligne, enregistrement du curseur actuel                 */
/*                 p_LignePrecedente, enregistrement du curseur précédent    */
/*                 max_niv, niveau maximum à atteindre                       */
/*                 op_nb, niveau courant du parcourt                         */
/* Entree/Sortie:                                                            */
/* Retour       :  boolean                                                   */
/*---------------------------------------------------------------------------*/
FUNCTION F_TEST_RUPTURE (
  p_c_data           IN INTEGER,
  p_Ligne            IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  p_LignePrecedente  IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  max_niv            IN NUMBER,
  op_nb              IN NUMBER )
  RETURN BOOLEAN;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_POS_SGT                                                 */
/* Type         :  Privé                                                     */
/* Description  :  Retourne la postiion de la donnée dans le segment         */
/*                                                                           */
/* Entree       :  p_ordre, ordre de la donnée dans le segment               */
/*                 p_idsegment, Identifiant du segment                       */
/* Entree/Sortie:                                                            */
/* Retour       :  nombre                                                    */
/*---------------------------------------------------------------------------*/
FUNCTION F_POS_SGT (p_ordre NUMBER,
                    p_idsegment prdgsegment.idsegment%TYPE) RETURN NUMBER;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_FILE_TO_CLOB                                            */
/* Type         :  Privé                                                     */
/* Description  :  Retourne le clob généré à partir du fichier               */
/*                                                                           */
/* Entree       :  i_fichier, nom du fichier                                 */
/*                 i_repertoire, repertoire oracle d'esxportation            */
/* Entree/Sortie:  o_clob_error , erreur de tupe clob                        */
/* Retour       :  clob                                                      */
/*---------------------------------------------------------------------------*/
FUNCTION F_FILE_TO_CLOB (i_fichier     IN VARCHAR2,
                         i_repertoire  IN typ_batch.repertoire%TYPE,
                         o_clob_error  OUT NUMBER)
RETURN CLOB;

-- -- CORPS DES PROCEDURES PRIVEES ------------------------------------------


PROCEDURE GENERE_FLUX(
  p_prdg_flux IN OUT UTL_FILE.file_type,
  p_idFlux    IN prdgfxsg.idprdgflux%TYPE,
  p_DG        IN NUMBER,
  p_PR        IN NUMBER,
  p_fonct     IN VARCHAR2,
  p_ordreFx   IN NUMBER,
  p_idmsg     IN NUMBER,
  p_risque    IN VARCHAR2,--sante ou prévoyance
  p_datedeb   IN DATE,
  p_datefin   IN DATE,
  p_nbdup     IN NUMBER,
  p_msgErreur OUT VARCHAR2,
  p_erreur    OUT NUMBER
  ) IS

  loc_type       VARCHAR2(1);
  loc_flux       VARCHAR2(500):='';
  loc_sgt        VARCHAR2(2004):='';
  loc_risque     VARCHAR2(50);--risque PRDG
  loc_natdoc     VARCHAR2(50);--nature du document
  loc_totreg     NUMBER(15,2):=0; --montant total de travail
  loc_totVUE     NUMBER(15,2):=0; --montant total de travail issu de la vue
  loc_nbenr      NUMBER :=0; -- compteur d'enregistrement
  loc_msgErreur  VARCHAR2(200):='';
  loc_erreur     NUMBER :=0;
  loc_niv        NUMBER :=1;
  max_niv        NUMBER :=0;
  max_clef       NUMBER :=0;
  loc_op_nb      NUMBER :=1;
  i              NUMBER :=0;
  j              NUMBER :=0;

  --exception
  EXC_NAT_DOC_ERR     EXCEPTION;
  EXC_RISQUE_ERR      EXCEPTION;
  EXC_TOT_DIFF        EXCEPTION;

  --curseur de recherche de donnée en fonction du segment et du PR
  CURSOR C_Sgt_Flux IS
    SELECT f.*,s.taille ,s.nomsegment FROM PRDGFXSG f, PRDGSEGMENT s
    WHERE f.idsegment = s.idsegment
    AND f.IDPRDGFLUX = p_idFlux
    AND s.TYPESEGMENT = loc_type
    ORDER BY f.numordre;

  Rec_C_Sgt_Flux C_Sgt_Flux%ROWTYPE;



  --déclaration des curseurs dynamiques
  C_Data          INTEGER;
  Rec_C_Data      PK_PRDG_DYNAMIC_CURSOR.T_CLES;
  Rec_C_Data_prev PK_PRDG_DYNAMIC_CURSOR.T_CLES;

  --déclaration des tableaux d'enregistrements
  loc_Tab_Entete TAB_Flux;
  loc_Tab_Corps  TAB_Flux;
  loc_Tab_Pied   TAB_Flux;

BEGIN


  --Transcodifciation de la nature du document
  loc_natdoc := F_get_transco('PRDG','NAT_DOC', p_risque);
  IF loc_natdoc IS NULL THEN RAISE EXC_NAT_DOC_ERR;
  END IF;
  --Transodification du risque PRDG
  loc_risque := F_get_transco('PRDG','PRDG_RISQ', p_risque);
  IF loc_risque IS NULL THEN RAISE EXC_RISQUE_ERR;
  END IF;
  -- Génération des briques fonctionnelles
  loc_type :='F';

  --construction du tableau de référence des segments
  FOR Rec_C_Sgt_Flux IN C_Sgt_Flux LOOP
    i:=i+1;
    loc_Tab_Sgt(i).Idsegment := Rec_C_Sgt_Flux.Idsegment;
    loc_Tab_Sgt(i).numordre := Rec_C_Sgt_Flux.numordre;
    loc_Tab_Sgt(i).nbmin := Rec_C_Sgt_Flux.nbmin;
    loc_Tab_Sgt(i).nbmax := Rec_C_Sgt_Flux.nbmax;
    loc_Tab_Sgt(i).taille := Rec_C_Sgt_Flux.taille;
    loc_Tab_Sgt(i).niveau := Rec_C_Sgt_Flux.niveau;
    loc_Tab_Sgt(i).nom := Rec_C_Sgt_Flux.nomsegment;
  END LOOP;

  max_niv :=i; --nombre de segment à parcourir pour un flux, niveau max à atteindre
  max_clef :=loc_Tab_Sgt(i).niveau;--niveau max des clefs
  --initialisation du tableau de compteur
  FOR i IN 1..max_niv LOOP
    loc_Tab_Cpt(i) :=0;
  END LOOP;

  --g_nomflux:='DCS';

  --UTL_FILE.put_line (p_prdg_flux,g_nomflux);
  --Création du curseur dynamique c_data pour segment fonctionnel
  BEGIN
  PK_PRDG_DYNAMIC_CURSOR.p_open_dyncur (nom_flux => substr(g_nomflux,0,3),
                                        num_pr   => p_PR,
                                        datdeb   => p_datedeb,
                                        datfin   => p_datefin,
                                        gd_risque=> loc_risque,
                                        crs      => C_Data) ;

  EXCEPTION
    WHEN OTHERS THEN p_msgErreur:= 'Erreur technique de curseur : '||SQLERRM;
     p_erreur:=2;
     RETURN;
  END;

  --parcourt récursif des données fonctionnelles issues de la vue dynamique
  Rec_C_Data := PK_PRDG_DYNAMIC_CURSOR.F_FETCH_DYNCUR(crs=>C_Data);

  Rec_C_Data_prev:=Rec_C_Data;
  WHILE C_Data IS NOT NULL LOOP
    BEGIN
    RECH_SEGMENT_RECUR(
      p_idFlux           =>p_idFlux,
      p_c_data           => C_Data,
      p_Ligne            => Rec_C_Data,
      p_LignePrecedente  => Rec_C_Data_prev,
      p_Tab_Sgt          => loc_Tab_Sgt,
      p_nbenr            => loc_nbenr,
      p_totreg           => loc_totreg,
      p_Tab_Corps        => loc_Tab_Corps,
      p_DG               => p_DG,
      p_PR               => p_PR,
      max_niv            => max_niv,
      max_clef           => max_clef,
      op_nb              => loc_op_nb,
      datedeb            => p_datedeb,
      datefin            => p_datefin,
      p_erreur           => loc_erreur);

      IF NVL(loc_erreur,0) <> 0 THEN p_erreur :=loc_erreur;
      END IF;

      EXCEPTION
      WHEN OTHERS THEN raise EXC_TOT_DIFF;
      END;
  END LOOP;  -- fin curseur C_Data

  --total des montants de la vue
  loc_totVUE := PK_PRDG_DYNAMIC_CURSOR.f_total_flux(gd_risque  => loc_risque,
                                                    nom_flux  => substr(g_nomflux,0,3),
                                                    num_pr    => p_PR,
                                                    datdeb     => p_datedeb,
                                                    datfin   => p_datefin);

  --comparaisaon des montants obtenus
  IF loc_totVUE <> loc_totreg THEN
    RAISE EXC_TOT_DIFF;
  END IF;

  --génération de l'entete
  loc_type :='T';

  loc_nbenr:=loc_nbenr + 6;--on ne compte pas les segments STE STM STD STF
  i:=0;


  FOR Rec_C_Sgt_Flux IN C_Sgt_Flux LOOP
    j:=1;
    FOR j IN 1..Rec_C_Sgt_Flux.nbmin LOOP--occurence d'un segment
      i:=i+1;

      GENERE_SGMT(p_idFlux      =>p_idFlux,
                  p_idsegment   => Rec_C_Sgt_Flux.idsegment,
                  p_ligne       => Rec_C_Data_prev,
                  op_nb         => NULL,
                  p_nbsgt       => loc_nbenr,
                  p_DG          => p_DG,
                  p_PR          => p_PR,
                  p_fonct       => p_fonct,
                  p_seqsgt      => j,
                  p_idmsg       => p_idmsg,
                  p_risque      => loc_natdoc,
                  p_ordrefx     => p_ordrefx,
                  p_datedeb     => p_datedeb,
                  p_datefin     => p_datefin,
                  p_nbdup       => p_nbdup,
                  p_totreg      => loc_totreg,
                  p_sgt         => loc_sgt,
                  p_msgErreur   => loc_msgErreur,
                  p_erreur      => loc_erreur);
      --on ajoute l'enregistrement dans le tableau d'entete
      --dbms_output.put_line( 'loc_erreurT = '||loc_erreur);
      IF NVL(loc_erreur,0) <> 0 THEN p_erreur :=loc_erreur;
      END IF;
      loc_Tab_Entete(i):=loc_sgt;
     -- dbms_output.put_line( 'loc_sgtT = '||loc_sgt);
    END LOOP;

  END LOOP;

  --génération du pied
  loc_type :='P';
  i:=0;

  FOR Rec_C_Sgt_Flux IN C_Sgt_Flux LOOP
    j:=1;
    FOR j IN 1..Rec_C_Sgt_Flux.nbmin LOOP
      i:=i+1;

      GENERE_SGMT(p_idFlux      =>p_idFlux,
                  p_idsegment  => Rec_C_Sgt_Flux.idsegment,
                  p_ligne       => NULL,
                  op_nb         => NULL,
                  p_nbsgt       => loc_nbenr,
                  p_DG          => p_DG,
                  p_PR          => p_PR,
                  p_fonct       => p_fonct,
                  p_seqsgt      => j,
                  p_idmsg       => p_idmsg,
                  p_risque      => loc_natdoc,
                  p_ordrefx     => p_ordrefx,
                  p_datedeb     => p_datedeb,
                  p_datefin     => p_datefin,
                  p_nbdup       => p_nbdup,
                  p_totreg      => loc_totreg,
                  p_sgt         => loc_sgt,
                  p_msgErreur   => loc_msgErreur,
                  p_erreur      => loc_erreur);

      --on ajoute l'enregistrement dans le tableau de pied
      --dbms_output.put_line( 'loc_erreurP = '||loc_erreur);
      IF NVL(loc_erreur,0) <> 0 THEN p_erreur :=loc_erreur;
      END IF;
      loc_Tab_Pied(i):=loc_sgt;
      --dbms_output.put_line( 'loc_sgtP = '||loc_sgt);
    END LOOP;
  END LOOP;

  --Ecriture du flux généré
  FOR i IN 1..loc_Tab_Entete.count LOOP
    UTL_FILE.put_line (p_prdg_flux, loc_Tab_Entete(i));
  END LOOP;

  FOR i IN 1..loc_Tab_Corps.count LOOP
    UTL_FILE.put_line (p_prdg_flux, loc_Tab_Corps(i));
  END LOOP;

  FOR i IN 1..loc_Tab_Pied.count LOOP
  --dbms_output.put_line( 'loc_Tab_Pied(i) = '||loc_Tab_Pied(i));
    UTL_FILE.put_line (p_prdg_flux, loc_Tab_Pied(i));
  END LOOP;
 --dbms_output.put_line( 'ERREUR = '||p_erreur);

  EXCEPTION
   WHEN EXC_NAT_DOC_ERR THEN
      p_msgErreur := 'Nature du document demandée en erreur';
      p_ins_journal(p_msgErreur,0);
  WHEN  EXC_RISQUE_ERR THEN
     p_msgErreur := 'Grand risque du document demandée en erreur';
     p_ins_journal(p_msgErreur,0);
  WHEN EXC_TOT_DIFF THEN
     p_msgErreur := 'Montant total invalide';
     p_ins_journal(p_msgErreur,0);
  WHEN OTHERS THEN
      p_msgErreur:='Erreur de génération de flux : '||SQLERRM;
      p_erreur:=3;

END GENERE_FLUX;

PROCEDURE RECH_SEGMENT_RECUR (
  p_idFlux           IN prdgfxdo.IDPRDGFLUX%TYPE,
  p_c_data           IN OUT INTEGER,
  p_Ligne            IN OUT PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  p_LignePrecedente  IN OUT PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  p_Tab_Sgt          IN TAB_T_Sgt,
  p_nbenr            IN OUT NUMBER,
  p_totreg           IN OUT NUMBER,
  p_Tab_Corps        IN OUT TAB_Flux,
  p_DG               IN individu.numindiv%TYPE,
  p_PR               IN individu.numindiv%TYPE,
  max_niv            IN NUMBER,
  max_clef           IN NUMBER,
  op_nb              IN OUT NUMBER,
  datedeb            IN DATE,
  datefin            IN DATE,
  p_erreur           OUT NUMBER)
IS
  loc_sgt        VARCHAR2(2500):='';
  loc_msgErreur  VARCHAR2(200):='';
  loc_erreur     NUMBER :=0;
  n NUMBER :=0;
  --nb_cle         NUMBER :=0;
BEGIN


  WHILE F_TEST_RUPTURE(p_c_data,p_Ligne, p_LignePrecedente,max_clef,p_Tab_Sgt(op_nb).niveau)
    LOOP
     --  dbms_output.put_line('SIN :'||p_Ligne.cle(9) ||' op_nb:'||op_nb||' max_niv:'||max_niv ||' seg:'||p_Tab_Sgt(op_nb).nom);
       IF  p_Ligne.cle(p_Tab_Sgt(op_nb).niveau) <>'NV' THEN

         --lors de la remontée, on remonte un cran trop haut, donc si cles identiques on descend d'un niveau
         IF p_LignePrecedente.cle(p_Tab_Sgt(op_nb).niveau) = p_Ligne.cle(p_Tab_Sgt(op_nb).niveau)
            AND NOT F_TEST_RUPTURE(p_c_data,p_Ligne, p_LignePrecedente,max_clef,max_clef)  THEN
            op_nb:=op_nb+1;
            p_LignePrecedente:=p_Ligne;
         END IF;
        --dbms_output.put_line('ici');
         --compteur en global de chaque niveau
         loc_Tab_Cpt(op_nb) := NVL(loc_Tab_Cpt(op_nb),0) + 1;
         IF op_nb = 1 AND p_idFlux = 1 THEN --on réinitialise uniquement pour DCS
          FOR n IN op_nb+1 .. loc_Tab_Cpt.count LOOP
            loc_Tab_Cpt(n) := 0;
          END LOOP;
         END IF;

         --ecriture du segment
         dbms_output.put_line('----GENERE_SGMT op_nb :'||op_nb ||' sgt :'||p_Tab_Sgt(op_nb).nom);
         GENERE_SGMT(p_idFlux      =>p_idFlux,
                    p_idsegment  => p_Tab_Sgt(op_nb).Idsegment,
                    p_ligne       => p_Ligne,
                    op_nb         => op_nb,
                    p_nbsgt       => 0,
                    p_DG          => p_DG,
                    p_PR          => p_PR,
                    p_fonct       => NULL,
                    p_seqsgt      => 1,
                    p_idmsg       => NULL,
                    p_risque      => NULL,
                    p_ordrefx     => NULL,
                    p_datedeb     => datedeb,
                    p_datefin     => datefin,
                    p_nbdup       => NULL,
                    p_totreg      => p_totreg,
                    p_sgt         => loc_sgt,
                    p_msgErreur   => loc_msgErreur,
                    p_erreur      => loc_erreur);

         --on ajoute l'enregistrement dans le tableau
         p_nbenr := p_nbenr + 1;
         p_Tab_Corps(p_nbenr):=loc_sgt;
         --dbms_output.put_line( 'loc_sgtC = '||loc_sgt);
         IF NVL(loc_erreur,0)<>0 THEN p_erreur :=loc_erreur;
         END IF;
       END IF;

       --on atteint le niveau maximum, ou que la clef en cours=NV
       --on peut passer à l'enregistrement suivant du curseur dynamique
       IF max_niv=op_nb  OR  p_Ligne.cle(p_Tab_Sgt(op_nb).niveau) ='NV' THEN
          dbms_output.put_line('===>ligne suivante op_nb :'||op_nb ||' valeur clef:'||p_Ligne.cle(p_Tab_Sgt(op_nb).niveau));
          p_totreg := p_totreg + to_number(p_ligne.total);
          p_Ligne := PK_PRDG_DYNAMIC_CURSOR.F_FETCH_DYNCUR(crs=>p_c_data);
          --op_nb := op_nb + 1;--non nécessaire DCS ??
       --on passe au segment suivant
       ELSE
          op_nb := op_nb + 1;
          RECH_SEGMENT_RECUR(p_idFlux ,p_c_data,p_Ligne, p_LignePrecedente,p_Tab_Sgt,p_nbenr,p_totreg,p_Tab_Corps,p_DG,p_PR,max_niv,max_clef,op_nb, datedeb,datefin,loc_erreur);
          IF NVL(loc_erreur,0)<>0 THEN p_erreur :=loc_erreur;
          END IF;
       END IF;

  END LOOP;

  --Si on remonte au maximum, on recommence le process en égalisant les enregistrements
  IF op_nb=1  THEN
    p_LignePrecedente:=p_Ligne;
    op_nb:=op_nb+1;
  END IF;

  op_nb := op_nb - 1;

  --dbms_output.put_line( 'erreur recur = '||p_erreur);
END RECH_SEGMENT_RECUR;


-- Procédure de génération des segments
PROCEDURE GENERE_SGMT(
  p_idFlux      IN prdgfxdo.IDPRDGFLUX%TYPE,
  p_idsegment   IN prdgfxsg.idsegment%TYPE,
  p_ligne       IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  op_nb         IN NUMBER,
  p_nbsgt       IN NUMBER,--nombre de segment
  p_DG          IN individu.numindiv%TYPE,
  p_PR          IN individu.numindiv%TYPE,
  p_fonct       IN VARCHAR2,
  p_seqsgt      IN NUMBER, --répétition du segment
  p_idmsg       IN NUMBER,
  p_risque      IN VARCHAR2,
  p_ordrefx     IN NUMBER,
  p_datedeb     IN DATE,
  p_datefin     IN DATE,
  p_nbdup       IN NUMBER,
  p_totreg      IN OUT NUMBER,
  p_sgt         OUT VARCHAR2,
  p_msgErreur   OUT VARCHAR2,
  p_erreur      OUT NUMBER
  )IS

  loc_sgt        VARCHAR2(2500):='';
  loc_donnee     VARCHAR2(500):='';
  loc_date       DATE;
  loc_msgErreur  VARCHAR2(200):='';
  loc_erreur     NUMBER :=0;

  EXC_EMPTY_DATA  EXCEPTION;

  CURSOR C_Donnee_Sgt IS
  SELECT d.iddonnee,d.Taille,typdonnee,numordre,condition, NVL(fxdo.defaut,NVL(sd.defaut,d.defaut)) valeur ,
         NVL(sd.statut,d.statut) statut , nomdonnee, sg.nomsegment,sg.typesegment
  FROM  prdgsegment sg,PRDGDONNEE d,PRDGSGDO sd
  LEFT OUTER JOIN (
    SELECT iddonnee,idsegment,defaut from PRDGFXDO
    WHERE numindiv= p_PR
    AND idsegment = p_idsegment
    AND idprdgflux = p_idFlux)fxdo ON fxdo.iddonnee = sd.iddonnee
  WHERE sd.iddonnee = d.iddonnee
  AND sd.idsegment= p_idsegment
  AND sg.idsegment = sd.idsegment
  ORDER BY sd.numordre;

  Rec_C_Donnee_Sgt  C_Donnee_Sgt%ROWTYPE;
  Tab_donnee        PK_PRDG_FONCT.T_CHAR_TAB;

BEGIN

  BEGIN
    Tab_donnee:=PK_PRDG_FONCT.F_GET_SEGMENT(p_idsegment=> p_idsegment,p_ligne => p_ligne,
    p_niv=>op_nb,p_cle=>p_DG,p_cle2=>p_PR,p_seqsgt=>p_seqsgt,
    p_datedeb =>p_datedeb, p_datefin=>p_datefin,
    p_nomflux=> g_nomflux);
  EXCEPTION
      WHEN OTHERS THEN
        p_msgErreur:='Erreur Generation fonct. segt : '||p_idsegment||' ' ||SQLERRM;
        RAISE data_error;
  END;


  FOR Rec_C_Donnee_Sgt IN C_Donnee_Sgt LOOP
    loc_donnee:='';

    --Récupération de la valeur dans le tableau si la colonne existe
    IF Tab_donnee.EXISTS(Rec_C_Donnee_Sgt.numordre) THEN
      loc_donnee := Tab_donnee(Rec_C_Donnee_Sgt.numordre);
    END IF;

    --Si la donnée n'est pas présente dans le tableau alors on prend la valeur par défaut
    IF loc_donnee IS NULL OR loc_donnee='' THEN
      loc_donnee:=Rec_C_Donnee_Sgt.valeur;
    END IF;

    --transcription des valeurs par defaut formatée en balise dans le paramétrage
    P_EVAL_PARAM (p_donnee      => loc_donnee ,
                  p_taille      => Rec_C_Donnee_Sgt.taille,
                  p_nbsgt       => p_nbsgt ,
                  p_DG          => p_DG ,
                  p_PR          => p_PR ,
                  p_fonct       => p_fonct ,
                  p_seqsgt      => p_seqsgt ,
                  p_idmsg       => p_idmsg ,
                  p_risque      => p_risque,
                  p_ordrefx     => p_ordrefx ,
                  p_datedeb     => p_datedeb ,
                  p_datefin     => p_datefin ,
                  p_nbdup       => p_nbdup ,
                  p_totreg      => p_totreg,
                  p_date        => loc_date);

    --Evaluation de la condition paramétrée
    loc_donnee:= F_EVAL_CONDITION(p_chaine =>loc_donnee,p_condition =>Rec_C_Donnee_Sgt.condition);


    BEGIN
      IF Rec_C_Donnee_Sgt.statut='O' AND (trim(loc_donnee) ='' OR loc_donnee IS NULL) THEN
        RAISE EXC_EMPTY_DATA;-- donnée obligatoire vide
        --loc_donnee:='?';
        --loc_donnee :=lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,' ');
       -- GOTO fincase;
      ELSIF (loc_donnee ='' OR loc_donnee IS NULL) AND INSTR(Rec_C_Donnee_Sgt.typdonnee,'N')=1 THEN loc_donnee :='0';
      ELSIF loc_donnee ='' OR loc_donnee IS NULL THEN loc_donnee :=' ';
      END IF;


      --filler en fonction du type de donnée
      CASE Rec_C_Donnee_Sgt.typdonnee
        WHEN 'N' THEN -- si numérique on complète selon la taille de la donnée à gauche par des blancs
          loc_donnee := lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,'0');
        WHEN 'N1' THEN -- 2 décimals sans virgule
          loc_donnee := trim(to_char(ABS(loc_donnee),g_fmt_nb_2d));
          loc_donnee := lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,'0');
        WHEN 'N5' THEN -- 2 décimals sans virgule positif
          loc_donnee := trim(to_char(ABS(loc_donnee),g_fmt_nb_2d));
          loc_donnee := lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,'0');
        WHEN 'N2' THEN --pourcentage entier arrondi
          loc_donnee := trim(to_char(ABS(loc_donnee),g_fmt_nb_ent));
          loc_donnee := lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,'0');
        WHEN 'N3' THEN -- pourcentage 4 décimales
          loc_donnee := trim(to_char(ABS(loc_donnee),g_fmt_nb_4d));
          loc_donnee := lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,'0');
        WHEN 'N4' THEN -- entier (sans virgule) positif
          loc_donnee := trim(to_char(ABS(loc_donnee),g_fmt_nb_ent));
          loc_donnee := lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,'0');
        WHEN 'N6' THEN -- numéro siret
          loc_donnee := trim(to_char(ABS(loc_donnee),g_fmt_nb_ent));
          loc_donnee := lpad(loc_donnee,Rec_C_Donnee_Sgt.taille,'0');
        WHEN 'D' THEN
        -- dbms_output.put_line( Rec_C_Donnee_Sgt.iddonnee||'-Date ='||loc_donnee||'-');
          IF TRIM(loc_donnee) IS NULL THEN
            loc_donnee := '00000000';
          ELSE
            IF loc_date IS NULL THEN
              loc_date := e2d(loc_donnee);
              --dbms_output.put_line( Rec_C_Donnee_Sgt.iddonnee||'-Date = '||loc_donnee);
            END IF;
            loc_donnee := to_char(loc_date,'YYYYMMDD');
          END IF;
         -- dbms_output.put_line( Rec_C_Donnee_Sgt.iddonnee||'-Date = '||loc_donnee);
        WHEN 'D*' THEN
          IF loc_date IS NULL THEN
            loc_date := TO_DATE(loc_donnee);
            loc_donnee := to_char(loc_donnee,'YYYYMMDDHH24MISS');
          END IF;
          loc_donnee := to_char(loc_date,'YYYYMMDDHH24MISS');
        ELSE  --sinon AN on complète sur la droite
          loc_donnee := rpad(loc_donnee,Rec_C_Donnee_Sgt.taille,' ');

      END CASE;

    EXCEPTION
      WHEN EXC_EMPTY_DATA THEN
       p_msgErreur:='Erreur dans segt: '||Rec_C_Donnee_Sgt.nomsegment||' - donnee obligatoire '||to_char(Rec_C_Donnee_Sgt.iddonnee)||' :'||to_char(Rec_C_Donnee_Sgt.nomdonnee);
       IF Rec_C_Donnee_Sgt.typesegment ='F' THEN
         p_msgErreur := p_msgErreur || ' clef :'||p_ligne.cle(1)||'-'||p_ligne.cle(2)||'-'||p_ligne.cle(3)||'-'||p_ligne.cle(9);
       ELSE
         p_msgErreur := p_msgErreur || ' pour PR :'||p_PR;
       END IF;
       RAISE data_error;
      WHEN OTHERS THEN
        IF Rec_C_Donnee_Sgt.typesegment ='F' THEN
           p_msgErreur := p_msgErreur || ' clef :'||p_ligne.cle(1)||'-'||p_ligne.cle(2)||'-'||p_ligne.cle(3);
        ELSE
          p_msgErreur := p_msgErreur || ' pour PR :'||p_PR;
        END IF;
        p_msgErreur:='Erreur dans segt: '||Rec_C_Donnee_Sgt.nomsegment||'- donnee '||to_char(Rec_C_Donnee_Sgt.iddonnee)||' - '||p_msgErreur||' - '||SQLERRM;
        RAISE data_error;
      --dbms_output.put_line( 'Erreur donnee: '||to_char(Rec_C_Donnee_Sgt.iddonnee)||'-'||SQLERRM);
    END;


    <<fincase>>
    loc_donnee :=NVL(loc_donnee,'');
    loc_donnee:=substr(loc_donnee,0,Rec_C_Donnee_Sgt.taille);--substr peut renvoyer null

    --dbms_output.put_line( 'donnee = '||loc_donnee);

    loc_sgt:=loc_sgt || NVL(loc_donnee,'');

  END LOOP;
  --p_ins_journal( 'sgt: '||p_idsegment||'iddonne='||Rec_C_Donnee_Sgt.iddonnee||' donnee = ['||loc_donnee || '] taille = '||length(loc_sgt),1);
  p_sgt:=loc_sgt;

  EXCEPTION
    WHEN data_error THEN
      p_ins_journal(p_msgErreur,1);
      p_sgt :=p_msgErreur;
      p_erreur:=1;
      --dbms_output.put_line( 'ERREUR SGMT = '||p_erreur);
    WHEN OTHERS THEN
      p_msgErreur:='Erreur génération sgt: '||p_idsegment||'- donnée - ' || Rec_C_Donnee_Sgt.iddonnee||' -  taille = '||length(loc_sgt)||SQLERRM;
      p_sgt :=p_msgErreur;
      p_ins_journal(p_msgErreur,1);
      p_erreur:=1;

END GENERE_SGMT;



FUNCTION F_TEST_RUPTURE (
  p_c_data             IN INTEGER,
  p_Ligne            IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  p_LignePrecedente  IN PK_PRDG_DYNAMIC_CURSOR.T_CLES,
  max_niv            IN NUMBER,
  op_nb              IN NUMBER )
 RETURN BOOLEAN IS
BEGIN
	CASE op_nb
    WHEN 1  THEN RETURN(p_c_data IS NOT NULL AND p_Ligne.cle(1) = p_LignePrecedente.cle(1));
	  WHEN 2  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,1) AND p_Ligne.cle(2)  = p_LignePrecedente.cle(2)  AND max_niv >= op_nb);
	  WHEN 3  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,2) AND p_Ligne.cle(3)  = p_LignePrecedente.cle(3)  AND max_niv >= op_nb);
	  WHEN 4  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,3) AND p_Ligne.cle(4)  = p_LignePrecedente.cle(4)  AND max_niv >= op_nb);
	  WHEN 5  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,4) AND p_Ligne.cle(5)  = p_LignePrecedente.cle(5)  AND max_niv >= op_nb);
	  WHEN 6  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,5) AND p_Ligne.cle(6)  = p_LignePrecedente.cle(6)  AND max_niv >= op_nb);
	  WHEN 7  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,6) AND p_Ligne.cle(7)  = p_LignePrecedente.cle(7)  AND max_niv >= op_nb);
	  WHEN 8  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,7) AND p_Ligne.cle(8)  = p_LignePrecedente.cle(8)  AND max_niv >= op_nb);
	  WHEN 9  THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,8) AND p_Ligne.cle(9)  = p_LignePrecedente.cle(9)  AND max_niv >= op_nb);
	  WHEN 10 THEN RETURN(F_TEST_RUPTURE(p_c_data,p_Ligne,p_LignePrecedente,max_niv,9) AND p_Ligne.cle(10) = p_LignePrecedente.cle(10) AND max_niv >= op_nb);
    ELSE  dbms_output.put_line( 'CASE op_nb = '||op_nb);
  END CASE;

END F_TEST_RUPTURE;




FUNCTION F_NOM_FICHIER(p_nom IN VARCHAR2,
                       p_PR IN individu.numindiv%TYPE,
                       p_nomflux prdgflux.nomflux%TYPE)
RETURN VARCHAR2 IS
  loc_nom_fichier VARCHAR2(50);
  loc_date        VARCHAR2 (8);
  loc_heure       VARCHAR2 (8);
BEGIN

  loc_date := TO_CHAR (SYSDATE, 'YYYYMMDD');

  SELECT REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
  INTO loc_heure
  FROM DUAL;

  SELECT REPLACE(REPLACE (REPLACE (
                  REPLACE (p_nom, '#DT', loc_date),
                                      '#HR',loc_heure),
                                      '#PR',TO_CHAR (p_PR)),
                                      '#FX',TO_CHAR (p_nomflux))
  INTO loc_nom_fichier
  FROM DUAL;
RETURN loc_nom_fichier;
EXCEPTION
  WHEN OTHERS THEN RETURN loc_nom_fichier;

END F_NOM_FICHIER;

PROCEDURE P_FICHIER_PARAM (	I_traitement 	 	IN 	typ_batch.BATCHID%TYPE,
														O_nom_fichier		OUT typ_batch.RESSOURCE%TYPE,
														O_repertoire		OUT typ_batch.REPERTOIRE%TYPE ) IS
  CURSOR c_typ_batch IS
    SELECT ressource, repertoire
    FROM typ_batch
    WHERE batchid = upper(I_traitement);
  Rec_c_typ_batch c_typ_batch%ROWTYPE;

BEGIN

  FOR Rec_c_typ_batch IN c_typ_batch LOOP
    O_nom_fichier := Rec_c_typ_batch.ressource;
    O_repertoire  := Rec_c_typ_batch.repertoire;
  END LOOP;

END P_FICHIER_PARAM;

FUNCTION F_SPLIT(p_list VARCHAR2,p_pos NUMBER, p_sep IN VARCHAR2)
RETURN VARCHAR2 IS

	v_list varchar2(32767) := p_sep || p_list;
	pos_deb NUMBER;
	pos_fin NUMBER;

BEGIN
	pos_deb := instr(v_list, p_sep, 1, p_pos);
	IF pos_deb > 0 THEN
		pos_fin := instr( v_list, p_sep, 1, p_pos + 1);
		IF pos_fin = 0 THEN
			pos_fin := length(v_list) + 1;
		END IF;
		RETURN(substr(v_list, pos_deb + 1, pos_fin - pos_deb - 1));
	ELSE
		RETURN NULL;
	END IF;
END F_SPLIT;

FUNCTION F_NBR_OCCURENCE (p_chaine VARCHAR2, p_carac VARCHAR2) RETURN NUMBER IS
BEGIN
 RETURN NVL(LENGTH(p_chaine),0) - NVL(LENGTH(REPLACE(p_chaine,p_carac)),0);
END;


FUNCTION F_EVAL_CONDITION(p_chaine VARCHAR2,p_condition prdgsgdo.condition%TYPE)
RETURN VARCHAR2 IS
  loc_val VARCHAR2(500):='';
BEGIN
    loc_val:=p_chaine;
    --traitement de la condition val1|opérateur|val si condition remplie| valeur sinon
    IF p_condition IS NOT NULL  THEN

      IF F_evalue(loc_val,F_split(p_condition,1,'|'),F_split(p_condition,2,'|'))=1 THEN
        loc_val := F_split(p_condition,3,'|');
      ELSE
         loc_val := F_split(p_condition,4,'|');
      END IF;
    END IF;

    RETURN loc_val;
END F_EVAL_CONDITION;


PROCEDURE P_EVAL_PARAM(
  p_donnee      IN OUT VARCHAR2,
  p_taille      IN NUMBER,
  p_nbsgt       IN NUMBER,--nombre de segment
  p_DG          IN individu.numindiv%TYPE,--identifiant du DG
  p_PR          IN individu.numindiv%TYPE,--identifiant du PR
  p_fonct       IN VARCHAR2, --fonction du flux
  p_seqsgt      IN NUMBER, --répétition du segment
  p_idmsg       IN NUMBER,--identifiant unique du message
  p_risque      IN VARCHAR2, --nature du risque
  p_ordrefx     IN NUMBER,--ordre du flux dans le message
  p_datedeb     IN DATE,--date de début demandée en paramètre
  p_datefin     IN DATE,--date de fin demandée en paramètre
  p_nbdup       IN NUMBER,
  p_totreg      IN NUMBER,-- total des règlements
  p_date        OUT DATE
  ) IS
  n NUMBER:=1;

BEGIN

  FOR n IN 1..F_NBR_OCCURENCE(p_donnee,'|')+1 LOOP

    IF INSTR(F_split(p_donnee,n,'|'),'<')>0 THEN

      CASE trim(F_split(p_donnee,n,'|'))
        WHEN '<NBSEGMSG>' THEN p_donnee := replace(p_donnee,'<NBSEGMSG>', p_nbsgt);
        WHEN '<ORDREFX>'  THEN p_donnee :=replace(p_donnee,'<ORDREFX>', p_ordrefx);
        WHEN '<IDMSG>'    THEN p_donnee := replace(p_donnee,'<IDMSG>', p_idmsg);
        WHEN '<SEQSGT>'   THEN p_donnee := replace(p_donnee,'<SEQSGT>', p_seqsgt);
        WHEN '<FONCT>'    THEN p_donnee := replace(p_donnee,'<FONCT>', p_fonct);
        --WHEN '<REFCTRL>'  THEN p_donnee:=;
        WHEN '<DATEDEB>'  THEN p_date := replace(p_donnee,'<DATEDEB>', p_datedeb);
        WHEN '<DATEFIN>'  THEN p_date := replace(p_donnee,'<DATEFIN>', p_datefin);
        WHEN '<DATEDAY>'  THEN p_date := replace(p_donnee,'<DATEDAY>', sysdate);
        WHEN '<TOTREG>'   THEN p_donnee:= replace(p_donnee,'<TOTREG>', p_totreg);
        WHEN '<IDPR>'     THEN p_donnee:= replace(p_donnee,'<IDPR>', p_PR);
        WHEN '<IDDG>'     THEN p_donnee:= replace(p_donnee,'<IDDG>', p_DG);
        WHEN '<NATDOC>'   THEN p_donnee:= replace(p_donnee,'<NATDOC>', p_risque);
        WHEN '<NBDUP>'    THEN p_donnee:= replace(p_donnee,'<NBDUP>', p_nbdup);
        WHEN '<NBNIV1>'   THEN p_donnee:= replace(p_donnee,'<NBNIV1>', loc_tab_Cpt(1));
        WHEN '<NBNIV2>'   THEN p_donnee:= replace(p_donnee,'<NBNIV2>', loc_tab_Cpt(2));
        WHEN '<NBNIV3>'   THEN p_donnee:= replace(p_donnee,'<NBNIV3>', loc_tab_Cpt(3));
        WHEN '<NBNIV1-t>'   THEN p_donnee:= replace(p_donnee,'<NBNIV1-t>', lpad(loc_tab_Cpt(1),9,'0'));
        WHEN '<NBNIV2-t>'   THEN p_donnee:= replace(p_donnee,'<NBNIV2-t>', lpad(loc_tab_Cpt(2),9,'0'));
        WHEN '<NBNIV3-t>'   THEN p_donnee:= replace(p_donnee,'<NBNIV3-t>', lpad(loc_tab_Cpt(3),9,'0'));
        WHEN '<NBNIV4-t>'   THEN p_donnee:= replace(p_donnee,'<NBNIV4-t>', lpad(loc_tab_Cpt(4),9,'0'));
        WHEN '<NBNIV5-t>'   THEN p_donnee:= replace(p_donnee,'<NBNIV5-t>', lpad(loc_tab_Cpt(5),9,'0'));
        WHEN '<NBNIV6-t>'   THEN p_donnee:= replace(p_donnee,'<NBNIV6-t>', lpad(loc_tab_Cpt(6),9,'0'));
        WHEN '<NBNIV7-t>'   THEN p_donnee:= replace(p_donnee,'<NBNIV7-t>', lpad(loc_tab_Cpt(7),9,'0'));

        ELSE p_donnee:=''; --donnée paramatre non défini
      END CASE;
    END IF;
  END LOOP;
  p_donnee := replace(p_donnee,'|');
  p_date := replace(p_date,'|');
END P_EVAL_PARAM;



FUNCTION F_FILE_TO_CLOB (i_fichier     IN VARCHAR2,
                         i_repertoire  IN typ_batch.repertoire%TYPE,
                         o_clob_error  OUT NUMBER)
RETURN CLOB IS

   --variable pour clob
  Loc_clob CLOB;
  Loc_clob_empty CLOB;
  Loc_Bfile BFILE;
  Loc_clob_Len NUMBER := dbms_lob.lobmaxsize;
  Loc_start_src PLS_INTEGER := 1 ;
  Loc_start_dest PLS_INTEGER := 1 ;
  loc_clob_lang NUMBER := dbms_lob.default_lang_ctx ;

BEGIN

  Loc_Bfile := BFILENAME( i_repertoire, i_fichier);
  dbms_lob.fileopen(Loc_Bfile, dbms_lob.file_readonly);

  IF dbms_lob.fileexists( Loc_Bfile ) = 1 AND dbms_lob.getlength( Loc_Bfile ) >0 THEN

    DBMS_LOB.CREATETEMPORARY(Loc_clob,true);--initialisation du CLOB

    dbms_lob.loadclobfromfile(Loc_clob,              -- CLOB de destination
                              Loc_Bfile,             -- Pointeur fichier en entrée
                              Loc_clob_Len,          -- Nombre d'octets à lire
                              Loc_start_src,         -- Position source de départ
                              Loc_start_dest,        -- Position destination de départ
                              dbms_lob.default_csid, -- CSID
                              loc_clob_lang,         -- Contexte langue
                              o_clob_error);       -- Message d'avertissement
    dbms_lob.fileclose(Loc_Bfile);

   ELSE
    o_clob_error:=1;
   END IF;

   RETURN Loc_clob;

END F_FILE_TO_CLOB;


FUNCTION F_POS_SGT (p_ordre NUMBER, p_idsegment prdgsegment.idsegment%TYPE) RETURN NUMBER IS
  l_position NUMBER;
BEGIN
  SELECT sum(do.taille) INTO l_position
  FROM prdgdonnee do ,prdgsgdo s
  WHERE s.idsegment = p_idsegment
  AND s.numordre < p_ordre
  AND s.iddonnee = do.iddonnee;

  RETURN l_position;
  EXCEPTION
    WHEN OTHERS THEN RETURN 0;
END F_POS_SGT;

FUNCTION F_INSERT_PRDG_ECHANGE(p_emet     individu.numindiv%TYPE,
                               p_dest     individu.numindiv%TYPE,
                               p_idmsg    prdgechange.idmsg%TYPE,
                               p_datedeb  DATE,
                               p_datefin  DATE,
                               p_risque   NUMBER,
                               p_typeflux prdgflux.idprdgflux%TYPE,
                               p_fonction NUMBER,
                               p_nbdup    NUMBER,
                               p_msg      prdgechange.contenu%TYPE,
                               p_etat     NUMBER,
                               p_fichier   VARCHAR2)
RETURN NUMBER IS
  loc_user   utilisateurs.numutil%TYPE;
  loc_idflux prdgechange.idflux%TYPE;
BEGIN
  SELECT F_NUMUTIL INTO loc_user FROM DUAL;
  INSERT INTO PRDGECHANGE (IDMSG,IDPRDGFLUX,ETAT,EMETTEUR,DESTINATAIRE,DATEDEB,DATEFIN,RISQUE,FONCTION,NUMDUPLICATA,
                           DATCREATION,DATMAJ,USERCREATION,USERMAJ,FICHIER,CONTENU)
         VALUES (p_idmsg,p_typeflux,p_etat,p_emet,p_dest,p_datedeb,p_datefin,p_risque,p_fonction,p_nbdup,
                 sysdate,sysdate,loc_user,loc_user,p_fichier,p_msg)
                 returning idflux into loc_idflux;
  RETURN loc_idflux;

END F_INSERT_PRDG_ECHANGE;


PROCEDURE p_ins_journal(p_msg IN journal_adm.msg_adm%TYPE,p_niv journal_adm.niv_msg%TYPE)  IS
      l_idligne   NUMBER;
BEGIN
  IF (p_niv <= g_max_msg) THEN
    g_idligne := g_idligne + 1;

    IF (p_niv = 0) THEN l_idligne := -1 * g_idligne;
    ELSE l_idligne := g_idligne;
    END IF;

    pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                               i_session             => g_session,
                               i_niv_msg             => p_niv,
                               i_msg_adm             => substr(p_msg,0,132),
                               i_idligne             => l_idligne
                              );
  END IF;

END p_ins_journal;

-- -- FIN CORPS DES PROCEDURES PRIVEES --------------------------------------
----------------------------------------------------------------------------


-- -- CORPS DES PROCEDURES PUBLIQUES --------------------------------------



PROCEDURE P_EDIT_PRDGECHANGE(P_idflux IN prdgechange.idflux%TYPE,
                             P_typeFlux  IN prdgechange.idprdgflux%TYPE,
                             O_found        OUT NUMBER,
                             O_erreur       OUT VARCHAR2) IS
  NbLigne     NUMBER :=0;
  Nbre        NUMBER :=0;
  pos         NUMBER:=1; -- position dans le fichier
  l_idligne   NUMBER:=1;
  loc_clob    CLOB;
  loc_fichier prdgechange.fichier%TYPE;
  loc_msg     VARCHAR2(4000);
  i           NUMBER;
  l_sgt       prdgsegment.idsegment%TYPE;
  l_sid       prdgtempo.sid%TYPE;
  l_lgdo      prdgdonnee.taille%TYPE;
  v_position  NUMBER;

  CURSOR C_FxSg IS
    SELECT s.nomsegment, s.idsegment
    FROM  prdgsegment s, prdgfxsg fs
    WHERE s.idsegment = fs.idsegment
    AND fs.idprdgflux = P_typeFlux
    ORDER BY fs.idsegment;

  CURSOR C_EditDo(l_sgt NUMBER) IS
    SELECT d.taille, d.nomdonnee,d.iddonnee ,sd.numordre
    FROM prdgdonnee d , prdgsgdo sd, prdgfxsg fs
    WHERE  fs.idsegment=l_sgt
    AND fs.idprdgflux = P_typeFlux
    AND fs.idsegment = sd.idsegment
    AND sd.iddonnee = d.iddonnee
    AND sd.edit = 1
    ORDER BY sd.idsegment;

  TYPE T_PosDo      IS RECORD (taille prdgdonnee.taille%TYPE,nomdonnee prdgdonnee.nomdonnee%TYPE,position NUMBER);
  TYPE TAB_Do       IS TABLE OF T_PosDo index by binary_integer;
  TYPE TAB_Edit     IS TABLE OF TAB_Do index by VARCHAR2(50);

  Rec_C_FxSg   C_FxSg%ROWTYPE;
  Rec_C_EditDo C_EditDo%ROWTYPE;
  l_T_Edit     TAB_Edit;
  l_T_Do       TAB_Do;
  l_T_Do_Empty TAB_Do;

BEGIN

  SELECT to_char(sys_context('userenv', 'sid'))
  INTO l_sid FROM dual;

  --Remise à blanc de la table
  DELETE FROM prdgtempo WHERE (SID = l_sid OR idflux =P_idflux);

  SELECT contenu, fichier  INTO  loc_clob, loc_fichier FROM PRDGECHANGE
  WHERE idflux=P_idflux;

  --taille de la 1ère donnee du 1er segment pour le flux concerné
  SELECT do.taille INTO l_lgdo
  FROM PRDGSGDO sd, PRDGFXSG fs, PRDGDONNEE do
  WHERE fs.idprdgflux = P_typeFlux
  AND fs.numordre = 1
  AND fs.idsegment = sd.idsegment
  AND sd.numordre = 1
  AND sd.iddonnee = do.iddonnee;

  --Construction des tableaux de référence pour l'édition
  --tableau des segments
  l_sgt :='';
  --on ajoute le nom du fichier s'il n'a pas été constitué en erreur
  INSERT INTO PRDGTEMPO(IDFLUX,IDLIGNE,CONTENU,SID) VALUES ( P_idflux,0,'Nom du fichier généré : '|| loc_fichier,l_sid);

  FOR Rec_C_FxSg IN C_FxSg LOOP
    l_T_Do :=l_T_Do_Empty; --réinisialise le tableau de données
    i:=0;

    --tableau des données à éditer et
    FOR Rec_C_EditDo IN C_EditDo(Rec_C_FxSg.idsegment) LOOP
        v_position:=0;
        i:=i+1;
        v_position := F_POS_SGT(Rec_C_EditDo.numordre,Rec_C_FxSg.idsegment);

        l_T_Do(i).position := v_position;
        l_T_Do(i).nomdonnee := Rec_C_EditDo.nomdonnee;
        l_T_Do(i).taille := Rec_C_EditDo.taille;
    END LOOP;

    l_T_Edit(Rec_C_FxSg.nomsegment) := l_T_Do;

  END LOOP;
  l_T_Do :=l_T_Do_Empty;

	--parcourt du clob jusqu'a sa fin
  LOOP

    Nbre:=dbms_lob.INSTR(loc_clob,CHR(10),1,NbLigne+1); -- cherche le retour chariot

    EXIT WHEN Nbre IS NULL;
		EXIT WHEN Nbre=0;
		NBLigne:=NbLigne + 1;

    --identification des balises
    IF Nbre-pos =1 THEN
      l_idligne:=l_idligne + 1;
      --dbms_output.put_line('pos'||pos||' lg:'||Nbre ||':Erreur' );
      INSERT INTO PRDGTEMPO(IDFLUX,IDLIGNE,CONTENU,SID) VALUES ( P_idflux,l_idligne,'>>Erreur : ligne vide',l_sid);
    ELSE
      --reconnaissance du segment
      --dbms_output.put_line('subs'||substr(loc_clob,pos,10)||' pos : '||pos );
      l_T_Do := l_T_Edit(substr(loc_clob,pos,l_lgdo));--TO DO traiter si null

      FOR i IN 1..l_T_Do.count LOOP

        loc_msg :=  l_T_Do(i).nomdonnee || ' : ' || substr(loc_clob,pos + l_T_Do(i).position,l_T_Do(i).taille);
        --dbms_output.put_line('pos'||NBLigne||' lg:'||Nbre ||':'|| loc_msg );
        l_idligne:=l_idligne + 1;
        INSERT INTO PRDGTEMPO(IDFLUX,IDLIGNE,CONTENU,SID) VALUES ( P_idflux,l_idligne,loc_msg,l_sid);
      END LOOP;
    END IF;
    pos:= Nbre +1; -- positionne sur la ligne suivante
	END LOOP;
  COMMIT;


  EXCEPTION
    WHEN OTHERS THEN
      O_found :=1 ;
      O_erreur :='Impossible de consulter le fichier : '||SQLERRM;

END P_EDIT_PRDGECHANGE;



FUNCTION F_DONNEE_VALUE ( P_iddonnee  IN prdgdonnee.iddonnee%TYPE,
                          P_idsegment IN prdgsegment.idsegment%TYPE,
                          P_idflux    IN prdgechange.idflux%TYPE)
RETURN VARCHAR2 IS
  l_numordre  PRDGSGDO.numordre%TYPE;
  l_taille    PRDGDONNEE.taille%TYPE;
  l_nom       PRDGSEGMENT.nomsegment%TYPE;
  l_condition PRDGSGDO.condition%TYPE;
  l_position  NUMBER :=0;
  NbLigne     NUMBER :=0;
  Nbre        NUMBER :=0;
  pos         NUMBER:=1; -- position dans le fichier
  l_idligne   NUMBER:=1;
  loc_clob    CLOB;
  l_msg       VARCHAR2(50);
BEGIN
  SELECT contenu  INTO  loc_clob
  FROM PRDGECHANGE
  WHERE idflux=P_idflux;

  SELECT sd.numordre, d.taille ,s.nomsegment , sd.condition
      INTO l_numordre, l_taille,l_nom,l_condition
  FROM PRDGSGDO sd,PRDGDONNEE d,PRDGSEGMENT s
  WHERE sd.iddonnee = d.iddonnee
  AND s.idsegment = sd.idsegment
  AND sd.idsegment = P_idsegment
  AND d.iddonnee = P_iddonnee;

  LOOP

    Nbre:=dbms_lob.INSTR(loc_clob,CHR(10),1,NbLigne+1); -- cherche le retour chariot

    EXIT WHEN Nbre IS NULL;
		EXIT WHEN Nbre=0;
		NBLigne:=NbLigne + 1;

    -- dbms_output.put_line('pos'||NBLigne||' lg:'||Nbre ||':'|| l_msg ||'seg'||substr(loc_clob,pos,3));
    IF  substr(loc_clob,pos,3)=l_nom THEN
      l_position := F_POS_SGT(l_numordre,P_idsegment); -- position de la donnée
      l_msg :=  substr(loc_clob,pos + l_position,l_taille);
     /* IF l_condition IS NOT NULL THEN null;
      --  l_msg:= F_EVAL_CONDITION(l_msg ,l_condition ,2);
      END IF; */

      RETURN l_msg;
    END IF;


    pos:= Nbre +1; -- positionne sur la ligne suivante
  END LOOP;

  RETURN '';
END F_DONNEE_VALUE;


PROCEDURE P_REGEN_FILE(I_traitement IN 	typ_batch.BATCHID%TYPE,
                       P_idflux     IN prdgechange.idflux%TYPE,
                       p_fonction   IN NUMBER,
                       O_fichier    OUT VARCHAR2,
                       O_found      OUT NUMBER,
                       O_erreur     OUT VARCHAR2) IS

  loc_repertoire     typ_batch.repertoire%TYPE ;
  loc_fichier        VARCHAR2(50) ;
  l_prdg_flux        UTL_FILE.file_type;

  NbLigne       NUMBER :=0;
  Nbre          NUMBER :=0;
  pos           NUMBER:=1; -- position dans le fichier
  l_numligne    NUMBER:=1;
  loc_type      NUMBER;

  loc_msg       VARCHAR2(4000);
  loc_donnee    VARCHAR2(50);

  v_position     NUMBER;
  loc_etat       NUMBER;
  loc_idmsg      prdgechange.idmsg%TYPE;
  loc_nbdup        NUMBER;

  Loc_clob CLOB;
  Loc_clob_empty CLOB;
  loc_clob_error NUMBER;

  EXC_FLUX    EXCEPTION;
  EXC_PARAM   EXCEPTION;
  EXC_ENR_MSG EXCEPTION;

  CURSOR C_echange IS
    SELECT e.contenu,e.destinataire,e.emetteur ,f.nomflux,e.idmsg,e.datedeb,
           e.datefin,e.risque,e.idprdgflux,e.fonction,e.idprdgflux type_flux
    FROM prdgechange e , prdgflux f
    WHERE idflux=P_idflux
    AND f.idprdgflux = e.idprdgflux;

   CURSOR C_param (p_ordre NUMBER,p_type NUMBER) IS
    SELECT fs.idsegment,fs.numordre s_ordre, d.defaut,d.taille,sd.numordre d_ordre
    FROM   prdgfxsg fs, prdgsgdo sd,prdgdonnee d
    WHERE fs.idprdgflux = p_type
    AND fs.numordre = p_ordre
    AND d.defaut IN('<FONCT>','<NBDUP>')
    AND sd.idsegment=fs.idsegment
    AND sd.iddonnee=d.iddonnee;


  Rec_C_echange C_echange%ROWTYPE;
  Rec_C_param   C_param%ROWTYPE;


BEGIN
  O_found:=0;

  BEGIN
    --Flux à rééditer à partir de sa sauvegarde
    OPEN C_echange;
    FETCH C_echange INTO Rec_C_echange;
    IF C_echange%NOTFOUND THEN
      CLOSE C_echange;
      RAISE EXC_FLUX; --TO DO erreur
    --ELSIF Rec_C_echange.fonction a vorir si on ajoute des protections sur etat et fonction
    END IF;

    CLOSE C_echange;

    --format du fichier
    P_FICHIER_PARAM(I_traitement,loc_fichier,loc_repertoire);
    loc_fichier := NVL(loc_fichier,g_fichier);--v6
    loc_repertoire := NVL(loc_repertoire,g_repertoire);--v6

    --nom du fichier
    loc_fichier:=F_NOM_FICHIER(p_nom=>loc_fichier,p_PR=>Rec_C_echange.destinataire,p_nomflux=>Rec_C_echange.nomflux);
    l_prdg_flux := UTL_FILE.fopen (loc_repertoire, loc_fichier, 'W', 32767);

    --parcourt du clob jusqu'a sa fin
    LOOP

      Nbre:=dbms_lob.INSTR(Rec_C_echange.contenu,CHR(10),1,NbLigne+1); -- cherche le retour chariot

      EXIT WHEN Nbre IS NULL;
      EXIT WHEN Nbre=0;
      NBLigne:=NbLigne + 1;
      loc_msg := substr(Rec_C_echange.contenu,pos,Nbre-pos-1);

      FOR Rec_C_param IN C_param(l_numligne,Rec_C_echange.type_flux) LOOP
        --Modification si changement de fonction
        -- on se positionne sur le segment contenant la donnée
        --IF p_fonction IS NOT NULL AND Rec_C_echange.sens IS NULL THEN
          --RAISE EXC_PARAM;
        v_position := F_POS_SGT(Rec_C_param.d_ordre,Rec_C_param.idsegment);

        IF p_fonction IS NOT NULL  THEN
          IF  Rec_C_param.defaut ='<FONCT>' THEN
            --on modifie la donnée uniquement en fonction de son paramétrage
            loc_donnee := rpad(p_fonction,Rec_C_param.taille,' ');--la fonction est un AN
          ELSIF  Rec_C_param.defaut ='<NBDUP>' THEN

            SELECT count(e.idmsg)+1 INTO loc_nbdup
            FROM PRDGECHANGE e
            WHERE e.idmsg = Rec_C_echange.idmsg
            AND e.fonction = p_fonction;

            loc_donnee := rpad(loc_nbdup,Rec_C_param.taille,' ');--le nombre de duplicata est un AN
          END IF;
          --remplacement de la donnée
          loc_msg := substr(loc_msg,1,v_position) ||loc_donnee|| substr(loc_msg,v_position+4,Nbre-1) ;
        END IF;
      END LOOP;
      --dbms_output.put_line('pos'||pos||' Nbre:'||Nbre ||':'|| loc_msg );
      UTL_FILE.put_line(l_prdg_flux,loc_msg );
      l_numligne := l_numligne +1;
      pos:= Nbre +1; -- positionne sur le debut de la ligne suivante
    END LOOP;

    UTL_FILE.fclose (l_prdg_flux);

    --HISTORISATION par enregistrement du fichier généré dans un CLOB
    IF loc_fichier IS NOT NULL THEN
      Loc_clob:=Loc_clob_empty;
      BEGIN
       Loc_clob := F_FILE_TO_CLOB(loc_fichier,loc_repertoire,loc_clob_error);

        IF loc_clob IS NULL THEN
          O_erreur := O_erreur|| ' Fichier introuvable';
          UTL_FILE.fremove(loc_repertoire, loc_fichier);
          RAISE EXC_ENR_MSG;
        END IF;

        IF O_found = 0 THEN loc_etat := 0;
        ELSE
          loc_etat :=3;
        --  UTL_FILE.fremove(loc_repertoire, loc_fichier); --historisation mais suppression du fichier physique
          loc_fichier:=null;
        END IF;

        loc_idmsg:=F_INSERT_PRDG_ECHANGE(p_emet     => Rec_C_echange.emetteur,
                                         p_dest     => Rec_C_echange.destinataire,
                                         p_idmsg    => Rec_C_echange.idmsg,
                                         p_datedeb  => Rec_C_echange.datedeb ,
                                         p_datefin  => Rec_C_echange.datefin,
                                         p_risque   => Rec_C_echange.risque,
                                         p_typeflux => Rec_C_echange.idprdgflux,
                                         p_fonction => NVL(p_fonction,Rec_C_echange.fonction),
                                         p_nbdup    => loc_nbdup,
                                         p_msg      => Loc_clob,
                                         p_etat     => loc_etat,
                                         p_fichier  => loc_fichier);
      EXCEPTION
        WHEN OTHERS THEN
         O_erreur := O_erreur || 'Erreur de fichier :'||loc_clob_error||'-'||SQLERRM ;
        -- p_ins_journal(O_erreur,1);
         RAISE EXC_ENR_MSG;
      END;
    ELSE
       O_erreur := O_erreur|| 'Nom de fichier inconnu ';
    --   p_ins_journal(O_erreur,1);
       RAISE EXC_ENR_MSG;
    END IF;


  EXCEPTION
      WHEN EXC_FLUX THEN
        O_erreur :=O_erreur || 'Flux introuvable';
      WHEN EXC_PARAM THEN
         O_erreur := O_erreur|| ' Paramétrage manquant pour création du duplicata ';
      WHEN EXC_ENR_MSG THEN
       O_erreur := O_erreur|| ' Historisation du fichier généré impossible ';
      WHEN OTHERS THEN
        O_erreur := O_erreur ||'Impossible de consulter le fichier : '||SQLERRM;
  END;

  IF UTL_FILE.is_open (l_prdg_flux)  THEN
    UTL_FILE.fclose (l_prdg_flux);
  END IF;

  IF NVL(O_erreur,'0') <> '0' THEN
    O_found:=1;
  ELSE
    O_fichier :=loc_fichier;
  END IF;

END P_REGEN_FILE;

PROCEDURE P_EX31T (
  I_datedeb      IN DATE,
  I_datefin      IN DATE,
  I_DG           IN NUMBER,
  I_PRdeb        IN NUMBER,
  I_PRfin        IN NUMBER,
  I_typeflux     IN prdgflux.idprdgflux%TYPE,
  I_risque       IN NUMBER,
  I_fonction     IN NUMBER,
  I_idmsg        IN prdgechange.idmsg%TYPE,
  I_session      IN NUMBER DEFAULT 1,
  I_niv_msg      IN NUMBER DEFAULT 1,
  I_repertoire   IN VARCHAR2 DEFAULT NULL,
  I_fichier      IN VARCHAR2 DEFAULT NULL,
  O_found        OUT NUMBER,
  O_erreur       OUT VARCHAR2) IS


  loc_fichier    VARCHAR2(50);--v6/v7 different
  loc_fonction   NUMBER;
  v_fichier      VARCHAR2(50);--v6/v7 different
  v_msg_adm      journal_adm.msg_adm%TYPE;
  loc_idmsg      prdgechange.idmsg%TYPE;
  loc_nbdup      NUMBER;
  loc_etat       NUMBER;

  --variable pour clob
  Loc_clob CLOB;
  Loc_clob_empty CLOB;
  loc_clob_error NUMBER;

  --exceptions
  EXC_REPERTOIRE_VIDE EXCEPTION;
  EXC_FICHIER_VIDE    EXCEPTION;
  EXC_REEDIT_ERR      EXCEPTION;
  EXC_ENR_MSG         EXCEPTION;
  EXC_IDMSG           EXCEPTION;
  EXC_FLUX_INCONNU    EXCEPTION;
  EXC_MSGGEN          EXCEPTION;
  EXC_PARAM_PR        EXCEPTION;

  --curseurs
  CURSOR C_PR IS
    SELECT distinct fd.numindiv
    FROM prdgfxdo fd,prdgprfx pf
    WHERE fd.numindiv BETWEEN I_PRdeb AND NVL(I_PRfin,I_PRdeb)
    AND fd.numindiv = pf.numindiv
    AND pf.idprdgflux = I_typeflux
    AND pf.idprdgflux = fd.idprdgflux
    ORDER BY fd.numindiv;

  Rec_C_PR    C_PR%ROWTYPE;

BEGIN
  BEGIN

    o_found := 0;
    loc_fichier := NVL(i_fichier,g_fichier);
    g_max_msg := i_niv_msg;
    G_Session := I_Session;

    -- Ouverture du fichier d'export
    IF i_repertoire IS NULL  THEN
         Raise Exc_Repertoire_Vide;
    ELSIF NVL(loc_fichier,'0') = '0'  THEN
       RAISE EXC_FICHIER_VIDE;
    ELSIF I_idmsg IS NOT NULL AND I_PRfin IS NOT NULL THEN
       RAISE EXC_REEDIT_ERR;
    END IF;

   dbms_output.put_line('Début');
    --BOUCLE SUR LES PR
    -- parcourt de l'ensemble des PR défini dans prdgfxdo
    FOR Rec_C_PR IN C_PR LOOP

       --Récupération du nom du flux
        BEGIN
          SELECT nomflux INTO g_nomflux
          FROM PRDGFLUX
          WHERE IDPRDGFLUX = I_typeflux;

          EXCEPTION
            WHEN OTHERS THEN  RAISE EXC_FLUX_INCONNU;
        END;

      -- Formatage du nom de fichier
      v_fichier:=NULL;
      v_fichier:=F_NOM_FICHIER(p_nom=>loc_fichier,p_PR=>Rec_C_PR.numindiv,p_nomflux=>g_nomflux);
       dbms_output.put_line('PR'||i_repertoire);
      prdg_flux := UTL_FILE.fopen (i_repertoire, v_fichier, 'W', 32767);
      p_ins_journal('Ouverture du fichier '||v_fichier,1);
      dbms_output.put_line('Ouverture du fichier '||v_fichier);

      --création de l'identifiant uniquement du message
      IF I_idmsg IS NULL THEN
        SELECT NVL(MAX(idmsg),0) + 1 INTO loc_idmsg
        FROM prdgechange ;
      ELSE loc_idmsg := I_idmsg;
      END IF;

      --gestion des paramètres
      loc_fonction:=NVL(i_fonction,9); -- par défaut original

      IF loc_idmsg IS NOT NULL THEN
        --Recherche du nombre de duplicata
        IF loc_fonction = 7 THEN  --fonction duplicata PRDG
          BEGIN
            SELECT count(e.idmsg) INTO loc_nbdup
            FROM PRDGECHANGE e
            WHERE e.idmsg = loc_idmsg
            AND e.fonction = loc_fonction;
          EXCEPTION
            WHEN OTHERS THEN loc_nbdup:=0;
          END;
          loc_nbdup :=loc_nbdup +1;
          p_ins_journal('Création d''un duplicata n°'||loc_nbdup,1);
        END IF;
        --sinon loc_nbdup est à null
         p_ins_journal('Génération du flux n°'||loc_idmsg ||' pour le PR :'||Rec_C_PR.numindiv,1);

        -- TO DO boucle sur les PR
        BEGIN
        GENERE_FLUX( p_prdg_flux => prdg_flux,
                     p_idFlux    => I_typeflux,
                     p_DG        => I_DG,
                     p_PR        => Rec_C_PR.numindiv,
                     p_fonct     => loc_fonction,
                     p_ordreFx   => 1,
                     p_idmsg     => loc_idmsg,
                     p_risque    => I_risque,
                     p_datedeb   => I_datedeb,
                     p_datefin   => I_datefin,
                     p_nbdup     => loc_nbdup,
                     p_msgErreur => v_msg_adm,
                     p_erreur    => O_found  );
        EXCEPTION
          WHEN OTHERS THEN raise EXC_MSGGEN;
        END;

      ELSE --bloquant
         RAISE EXC_IDMSG;
      END IF;

      IF v_msg_adm IS NOT NULL THEN
        P_Ins_Journal(V_Msg_Adm,0);
        O_found:=1;
      END IF;


      -- fermeture du fichier généré
      UTL_FILE.fclose (prdg_flux);

      O_found := NVL(O_found,0);

      --HISTORISATION par enregistrement du fichier généré dans un CLOB
      IF v_fichier IS NOT NULL THEN
        Loc_clob:=Loc_clob_empty;
        BEGIN
          Loc_clob := F_FILE_TO_CLOB(v_fichier,i_repertoire,loc_clob_error);

          IF loc_clob IS NULL THEN
            v_msg_adm := 'Fichier introuvable';
            UTL_FILE.fremove(i_repertoire, v_fichier);
            p_ins_journal(v_msg_adm,1);
            RAISE EXC_ENR_MSG;
          END IF;

          IF O_found = 0 THEN loc_etat := 0;
          ELSE
            loc_etat :=3;
            UTL_FILE.fremove(i_repertoire, v_fichier); --historisation mais suppression du fichier physique
            v_fichier:=null;
          END IF;

          loc_idmsg:=F_INSERT_PRDG_ECHANGE(p_emet     => I_DG,
                                           p_dest     => Rec_C_PR.numindiv,
                                           p_idmsg    => loc_idmsg,
                                           p_datedeb  =>I_datedeb ,
                                           p_datefin  => I_datefin,
                                           p_risque   => I_risque,
                                           p_typeflux => I_typeflux,
                                           p_fonction => loc_fonction,
                                           p_nbdup    => loc_nbdup,
                                           p_msg      => Loc_clob,
                                           p_etat     => loc_etat,
                                           p_fichier  => v_fichier);
        EXCEPTION
          WHEN OTHERS THEN
           v_msg_adm := 'Erreur de fichier :'||loc_clob_error||SQLERRM;
           p_ins_journal(v_msg_adm,1);
           UTL_FILE.fremove(i_repertoire, v_fichier);
           RAISE EXC_ENR_MSG;
        END;
      ELSE
         v_msg_adm := 'Nom de fichier inconnu';
         p_ins_journal(v_msg_adm,1);
         RAISE EXC_ENR_MSG;
      END IF;

    END LOOP; --fin boucle PR
    IF g_nomflux IS NULL THEN
      RAISE EXC_PARAM_PR;
    END IF;
    COMMIT;

  EXCEPTION
    WHEN EXC_REPERTOIRE_VIDE THEN
       v_msg_adm := 'Nom du répertoire de sortie manquant';
    WHEN EXC_FICHIER_VIDE THEN
      V_Msg_Adm := 'Nom du fichier de sortie manquant';
    WHEN EXC_REEDIT_ERR THEN
      V_Msg_Adm := 'Réédition d''un message impossible pour plusieurs PR';
    WHEN EXC_FLUX_INCONNU THEN
      V_Msg_Adm:='Flux demandé inconnu, identifiant :'||I_Typeflux;
    WHEN EXC_IDMSG THEN
      v_msg_adm := 'Création du message impossible';
    WHEN EXC_MSGGEN THEN
      v_msg_adm := 'Génération du message impossible' ;
    WHEN EXC_ENR_MSG THEN
       v_msg_adm := 'Historisation du fichier généré impossible';
    WHEN EXC_PARAM_PR THEN
      v_msg_adm:='Paramétrage pour le couple preneur de risque/type de flux inexistant';
    WHEN UTL_FILE.internal_error THEN
       V_Msg_Adm := 'UTL_FILE.INTERNAL_ERROR';
    WHEN UTL_FILE.invalid_filehandle THEN
       V_Msg_Adm := 'UTL_FILE.INVALID_FILEHANDLE';
    WHEN UTL_FILE.invalid_mode THEN
       V_Msg_Adm := 'UTL_FILE.INVALID_MODE';
    WHEN UTL_FILE.invalid_operation THEN
       V_Msg_Adm := 'UTL_FILE.INVALID_OPERATION';
    WHEN UTL_FILE.invalid_path THEN
       V_Msg_Adm := 'UTL_FILE.INVALID_PATH';
    WHEN UTL_FILE.read_error THEN
       v_msg_adm := 'UTL_FILE.READ_ERROR';
    WHEN UTL_FILE.write_error THEN
       V_Msg_Adm := 'UTL_FILE.WRITE_ERROR';
    WHEN VALUE_ERROR THEN
       V_Msg_Adm := 'VALUE_ERROR' || Substr (Sqlerrm (Sqlcode), 1, 128);
    WHEN OTHERS THEN
       V_Msg_Adm := 'PK_PRDG_EXPORT - ' || Substr (Sqlerrm (Sqlcode), 1, 128);
  END;

  IF UTL_FILE.is_open (prdg_flux)  THEN
    UTL_FILE.fclose (prdg_flux);
  END IF;

  IF NVL(V_Msg_Adm,'0') <> '0' THEN
    p_ins_journal(v_msg_adm,1);
    O_found:=1;
  END IF;

  O_Erreur := V_Msg_Adm;

END P_EX31T;
-- ---------------------------------- Fin des corps des procedures publiques --


END PK_PRDG_EXPORT;
/
