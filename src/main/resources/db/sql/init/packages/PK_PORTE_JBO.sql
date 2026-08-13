CREATE OR REPLACE PACKAGE ARTHUS.PK_PORTE_JBO
AS
/*============================================================================*/
/* Package      : PK_PORTE.sql                                                */
/* Domaine      : PORTE                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : SDA                                                         */
/* Création     : ??/??/???                                                   */
/* Description  :                                                             */
/*              :                                                             */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :   SDA                                                       */
/* Date         :   28/11/2011                                                */
/* Commentaire  :   M3379                                                     */
/*============================================================================*/
/* Evolution    :   Ajout de la catégorie pour la gestion des centres de      */
/*                  santé dans la fonction f_carte_tp                         */
/* Auteur       :   JBO                                                       */
/* Date         :   09/10/2012                                                */
/*============================================================================*/
/* Evolution    : f_ouverte : colonne sens pour la recherche de la porte      */
/* Auteur       : JBO                                                         */
/* Date         : 27/08/2014                                                  */
/* Commentaire  : Projet P201407002_P201203001_Tiers_Payant_Hospitalier_GEREP */
/*============================================================================*/
/*Correction   : trigramme / date / commentaire                               */
/*============================================================================*/

  TYPE TAB_Cond IS TABLE OF VARCHAR2(200) INDEX BY  BINARY_INTEGER;


--
-- Test si la prestation est couverte par une carte TP
--

FUNCTION f_carte_tp_jbo (
   i_numindiv     IN   individu.numindiv%TYPE,
   i_codfrais     IN   natfrais.codfrais%TYPE,
   i_datsin       IN   DATE,
   i_idadhesion   IN   adhe_cntrt.idadhesion%TYPE DEFAULT 0,
   i_numporte     IN   porte_param.numporte%TYPE DEFAULT NULL,
   i_categorie    IN   acte_tp.categorie%TYPE DEFAULT NULL,
   i_TAB_Cond     IN   TAB_Cond
)
      RETURN NUMBER;




  PROCEDURE P_INS_journal(i_niv in NUMBER,
                          i_msg in VARCHAR2,
                          i_msg2 in varchar2 := null
                         );


-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_PORTE_JBO
AS
/*============================================================================*/
/* Package      : PK_PORTE.sql                                                */
/* Domaine      : PORTE                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : SDA                                                         */
/* Création     : ??/??/???                                                   */
/* Description  :                                                             */
/*              :                                                             */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :   SDA                                                       */
/* Date         :   28/11/2011                                                */
/* Commentaire  :   M3379                                                     */
/*============================================================================*/
/* Evolution    :   Ajout de la catégorie pour la gestion des centres de      */
/*                  santé dans la fonction f_carte_tp                         */
/* Auteur       :   JBO                                                       */
/* Date         :   09/10/2012                                                */
/*============================================================================*/
/* Evolution    : f_ouverte : colonne sens pour la recherche de la porte      */
/* Auteur       : JBO                                                         */
/* Date         : 27/08/2014                                                  */
/* Commentaire  : Projet P201407002_P201203001_Tiers_Payant_Hospitalier_GEREP */
/*============================================================================*/
/*Correction   : trigramme / date / commentaire                               */
/*============================================================================*/

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
--@glob
-- Parametres de la demande Tiers payant
   g_numporte     param_tiers_payant.numporte%TYPE;
   g_idadhesion   porte_adhesion.idadhesion%TYPE;
   g_numgar       param_tiers_payant.numgar%TYPE;
   g_numindiv     porte_adhesion.numindiv%TYPE;
   g_numindiv_init      porte_adhesion.numindiv%TYPE;
   g_numindiv_adhesion	adhesion.numindiv%TYPE;
   g_debut        DATE;
   g_type         porte_adhesion.TYPE%TYPE;
   g_numfor       adhesion.numfor%TYPE;
   g_debval       DATE;         -- date de debut de validite de l'attestation
   g_finval       DATE;           -- date de fin de validite de l'attestation
   g_ad_sans_od   BOOLEAN                              := FALSE;
--
-- Infos assures
--
   g_numassu      individu.numassu%TYPE;
   g_matorg       individu.matorg%TYPE;
   g_cless        individu.cless%TYPE;
   g_datnais      individu.datnais%TYPE;
   g_regime       individu.regime%TYPE;
   g_caisse       individu.caisse%TYPE;
   g_rang         individu.rang%TYPE;
   g_codpos       pers_adresse.codpos%TYPE;
--
-- Informations porte
--
   g_idparam_tp   param_tiers_payant.idparam_tp%TYPE;
   g_fract        param_tiers_payant.period%TYPE;
   g_renouv       param_tiers_payant.renouv%TYPE;
--
-- Infos contrat
--
   g_eche_anniv   contrat.eche_anniv%TYPE;
   g_numsoc       contrat.numinterm%TYPE;
   g_numorg       contrat.numorg%TYPE;
--
-- Infos porte_adhesion
--
   g_fin          DATE;
   g_idporte      porte_adhesion.idporte%TYPE;
   g_nb_demande   NUMBER                               := 0;


    -- Variables de P_INS_journal
    G_nom_traitement  journal_adm.nom_traitement%TYPE;--  'SP07T';
    G_niv_msg         journal_adm.niv_msg%TYPE;
    G_idligne         journal_adm.idligne%TYPE;
    G_session         journal_adm.id_session%TYPE;
    g_msg_adm         journal_adm.msg_adm%TYPE;


/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_carte_tp                                                */
/* Type         :  Publique                                                  */
/* Description  :  Test si la prestation est couverte par une carte TP       */
/* Entree       :  i_numindiv                                                */
/*                 i_codfrais                                                */
/*                 i_datsin                                                  */
/*                 i_idadhesion                                              */
/*                 i_numporte                                                */
/*                 i_categorie                                               */
/*                 i_adeli                                                   */
/* Retour       :  numéro du bénéficiaire couverte par la carte TP           */
/*---------------------------------------------------------------------------*/
/* Evolution    :  Ajout de la catégorie pour la gestion des centres de santé*/
/* Auteur       :  JBO                                                       */
/*  Date        :  09/10/2012                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_carte_tp_jbo (
   i_numindiv     IN   individu.numindiv%TYPE,
   i_codfrais     IN   natfrais.codfrais%TYPE,
   i_datsin       IN   DATE,
   i_idadhesion   IN   adhe_cntrt.idadhesion%TYPE DEFAULT 0,
   i_numporte     IN   porte_param.numporte%TYPE DEFAULT NULL,
   i_categorie    IN   acte_tp.categorie%TYPE DEFAULT NULL,
   i_TAB_Cond     IN   TAB_Cond
)
   RETURN NUMBER
IS
  /*ABO 21/11/2012 RG de couverture GEREP Centre pour acte ouvert avec catégorie CS
     Catégorie 	Adeli	        action
      vide 	    vide	        non couvert carte TP
      vide 	    non centre	  non couvert carte TP
      vide 	    centre	      couvert carte TP
      CS	      vide	        couvert carte TP
      CS	      centre	      couvert carte TP
      CS	      non centre	  non couvert carte TP
      OO	      centre	      non couvert carte TP


      Catégorie Mode trait. action
      vide 	    vide	        non couvert carte TP
      vide 	    2	            non couvert carte TP
      vide 	    7 ou 10	      couvert carte TP
      CP	      vide	        couvert carte TP
      CP	      7 ou 10	      couvert carte TP
      CP	      2          	  non couvert carte TP
      OO	      7 ou 10	      non couvert carte TP

	  catégorie CP, PS centre de santé, mode de traitement à 2 => NON couvert carte de TP
      */


   CURSOR c_domaine_ext
   IS
     SELECT NVL(porte_param.numbene,0) numbene, acte_tp.categorie categorie
      FROM porte_param, v_demande_tp, param_demande_tp,acte_tp
       WHERE porte_param.numporte = NVL (i_numporte, porte_param.numporte)
         AND porte_param.numporte = v_demande_tp.numporte
         AND v_demande_tp.numindiv = i_numindiv
         AND i_datsin BETWEEN v_demande_tp.debut AND v_demande_tp.fin
         AND v_demande_tp.transmis = 1      
         AND param_demande_tp.idparam_tp = v_demande_tp.idparam_tp 
         AND acte_tp.domaine = param_demande_tp.domaine
         AND acte_tp.codfrais = i_codfrais
         AND acte_tp.numporte = NVL (i_numporte, acte_tp.numporte)
         AND acte_tp.numporte = v_demande_tp.numporte
         AND (acte_tp.categorie = NVL(i_categorie,acte_tp.categorie) OR acte_tp.categorie IS NULL);

  CURSOR c_domaine_int
   IS
      SELECT NVL(porte_param.numbene,0) numbene, acte_tp.categorie categorie
      FROM porte_param, v_demande_tp, param_demande_tp,acte_tp
       WHERE porte_param.numporte = NVL (i_numporte, porte_param.numporte)
         AND porte_param.numporte = v_demande_tp.numporte
         AND v_demande_tp.numindiv = i_numindiv
         AND v_demande_tp.idadhesion = decode(i_idadhesion,0, v_demande_tp.idadhesion,i_idadhesion)
         AND i_datsin BETWEEN v_demande_tp.debut AND v_demande_tp.fin
         AND v_demande_tp.transmis = 1      
         AND param_demande_tp.idparam_tp = v_demande_tp.idparam_tp 
         AND acte_tp.domaine = param_demande_tp.domaine
         AND acte_tp.codfrais = i_codfrais
         AND acte_tp.numporte = NVL (i_numporte, acte_tp.numporte)
         AND acte_tp.numporte = v_demande_tp.numporte
        AND acte_tp.categorie IS NULL;


  CURSOR C_Condition IS
    SELECT code, libelle, sens
    FROM libelle_bis
    WHERE mnemo='CAT_MASQ'
    AND sens <>-2;

  
  l_numtp             pers_tierspayant.numtp%TYPE   := 0;
  v_test              NUMBER ;


BEGIN
  v_test:=0;
  IF (i_idadhesion != 0)  THEN
    FOR rec_c_domaine_int IN c_domaine_int LOOP
        l_numtp := rec_c_domaine_int.numbene;
    END LOOP;
  ELSE
     FOR rec_c_domaine_ext IN c_domaine_ext LOOP
       v_test  := 1;
       FOR Rec_Condition IN C_Condition LOOP

        BEGIN
          IF i_categorie IS NULL AND (rec_c_domaine_ext.categorie<>Rec_Condition.code AND rec_c_domaine_ext.categorie IS NOT NULL) THEN
             v_test:=0;
           --   dbms_output.put_line('Rec_Condition.libelle jbo:'||Rec_Condition.libelle);
          ELSE
            
            --dbms_output.put_line('Rec_Condition.libelle:'||Rec_Condition.libelle);
            --dbms_output.put_line('loc_TAB_Cond(Rec_Condition.sens):'||to_char(i_TAB_Cond(Rec_Condition.sens))); --pose des problem de compil
            SELECT 1 INTO v_test FROM dual
            WHERE
            ( REGEXP_like(i_TAB_Cond(Rec_Condition.sens),Rec_Condition.libelle)
            AND  Rec_Condition.code =NVL(i_categorie,Rec_Condition.code))
            OR  (Rec_Condition.code=i_categorie AND i_TAB_Cond(Rec_Condition.sens) IS NULL);
          END IF;
          
          
          EXCEPTION
            WHEN NO_DATA_FOUND THEN 
             IF i_categorie IS NULL AND rec_c_domaine_ext.categorie IS NULL THEN v_test:=1;
              ELSIF Rec_Condition.code=NVL(i_categorie,Rec_Condition.code) OR v_test=0 THEN v_test:=0;
             -- dbms_output.put_line('Rec_Condition.libelle no_data:'||Rec_Condition.libelle);
              ELSE v_test:=-1;
              END IF;
            WHEN OTHERS THEN v_test:=0; --dbms_output.put_line('Rec_Condition.libelle others:'||Rec_Condition.libelle);
        END;
      --  dbms_output.put_line('v_test'||v_test);
        IF v_test  = 1 THEN
          l_numtp := rec_c_domaine_ext.numbene;
          EXIT;
        ELSE l_numtp :=0;
        END IF;

      END LOOP;
      IF v_test =-1 AND rec_c_domaine_ext.numbene>0 THEN
        l_numtp:=rec_c_domaine_ext.numbene;
        EXIT;
      ELSIF v_test=1 THEN EXIT;
      END IF;

    END LOOP;
  END IF;
  RETURN (l_numtp);
END f_carte_tp_jbo;



/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure d'insertion dans journal ADM                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(i_niv in NUMBER,
                        i_msg in VARCHAR2,
                        i_msg2 in varchar2 := null
                       )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF g_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3,1)
       INTO g_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = g_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
         g_niv_msg := 1;
    END;
  END IF;

  IF g_niv_msg >= i_niv THEN
     g_idligne := g_idligne +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => g_nom_traitement,
        I_session  => nvl(g_session,SID),
        I_niv_msg  => i_niv,
        I_msg_adm  => substr(i_msg||' '||i_msg2,1,132),
        I_idligne  => g_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

-- ------------------------------------ Fin des corps des procedures privees --
END;
/
