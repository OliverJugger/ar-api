CREATE OR REPLACE PACKAGE ARTHUS."PK_PIECES"
AS


-- -- CONSTANTES PUBLIQUE -----------------------------------------------------

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
/* Nom          :  P_AD30T                                                   */
/* Type         :  Publique                                                  */
/* Description  :  Création automatisée pour GEREP de pièces de relance      */
/*                 adhésion par âge                                          */
/*                                                                           */
/* Entree       :  I_contexte_deb, contexte de la pièce                      */
/*                 I_contexte_fin,                                           */
/*                 I_piece, numéro de pièce                                  */
/*                 I_age, âge limite  maximum                                */
/*                 I_period, période de la pièce à créer                     */
/*                 I_delai, délai de la pièce à créer                        */
/*                 I_bloc, blocage O/N de la pièce à créer                   */
/*                 I_Nbrel, nombre de relance à initialiser                  */
/*                 I_session, numéro de la session                           */
/*                 I_niv_msg, niveau de trace du traitement                  */
/* Entree/Sortie:                                                            */
/* Retour       :  O_erreur, libellé de l'erreur                             */
/*                 O_found, erreur de Génération du fichier                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AD30T (
  I_contexte_deb IN PIECES.CONTEXTE%TYPE,
  I_contexte_fin IN PIECES.CONTEXTE%TYPE,
  I_piece        IN PIECES.NOPIECE%TYPE,
  I_age          IN NUMBER,
  I_period       IN PIECES.PERIOD%TYPE,
  I_delai        IN PIECES.DELAI%TYPE,
  I_bloc         IN PIECES.BLOC%TYPE DEFAULT 'N',
  I_Nbrel        IN PIECES.NBREL%TYPE DEFAULT 0,
  I_adhdeb       IN ADHESION.IDADHESION%TYPE,
  I_adhfin       IN ADHESION.IDADHESION%TYPE,
  I_session      IN NUMBER DEFAULT 1,
  I_niv_msg      IN NUMBER DEFAULT 1,
  O_found        OUT NUMBER,
  O_erreur       OUT VARCHAR2);

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AD31T                                                   */
/* Type         :  Publique                                                  */
/* Description  :  Blocage massif de pièces de relance                       */
/*                                                                           */
/* Entree       :  I_contexte_deb, contexte de la pièce                      */
/*                 I_contexte_fin,                                           */
/*                 I_piece, numéro de pièce                                  */
/*                 I_Nbrel, nombre de relance                                */
/*                 I_delai, delai ap emission de la relance ou dde de pièce  */
/*                 I_bloc, blocage O/N de la pièce à créer                   */
/*                 I_session, numéro de la session                           */
/*                 I_niv_msg, niveau de trace du traitement                  */
/* Entree/Sortie:                                                            */
/* Retour       :  O_erreur, libellé de l'erreur                             */
/*                 O_found, erreur de Génération du fichier                  */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AD31T (
  I_contexte_deb IN PIECES.CONTEXTE%TYPE,
  I_contexte_fin IN PIECES.CONTEXTE%TYPE,
  I_piece        IN PIECES.NOPIECE%TYPE,
  I_Nbrel        IN PIECES.NBREL%TYPE,
  I_delai        IN PIECES.DELAI%TYPE,
  I_session      IN NUMBER DEFAULT 1,
  I_niv_msg      IN NUMBER DEFAULT 1,
  O_found        OUT NUMBER,
  O_erreur       OUT VARCHAR2);
PROCEDURE P_INS_PIECES(I_PIECES  IN PIECES%ROWTYPE);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_PIECES;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_PIECES"
AS
/*===========================================================================*/
/* Package      : PK_PIECES .sql                                             */
/* Domaine      : Production adhésion individuelles                          */
/* Version      : V1.0                                                       */
/* Auteur       : ABO                                                        */
/* Création     : 03/07/2012                                                 */
/* Description  : */
/*              :         */
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

-- Variables de P_INS_journal
  g_nom_traitement            journal_adm.nom_traitement%TYPE      DEFAULT 'AD30T';
  g_session                   journal_adm.id_session%TYPE          DEFAULT 1;
  g_max_msg                   journal_adm.niv_msg%TYPE             := 2;
  g_idligne                   journal_adm.idligne%TYPE             := 0;
  g_erreur                    journal_adm.msg_adm%TYPE;


-- -- FIN  ------------------------------------------------------------------

-- -- PROCEDURES PRIVEES ----------------------------------------------------

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


-- -- CORPS DES PROCEDURES PRIVEES ------------------------------------------


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


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AD30T                                                   */
/* Type         :  Pubique                                                   */
/* Description  : ajout de pièces massivement                                */
/*                                                                           */
/* Entree       :                                                            */
/* Sortie       :                                                            */
/* Entree/Sortie:                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
/*Correction    : ABO assistance pour le cas où une pièce a été réceptionnée */
/*                avant appel massif et exclusion en dur produit 99 M4240    */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AD30T (
  I_contexte_deb IN PIECES.CONTEXTE%TYPE,
  I_contexte_fin IN PIECES.CONTEXTE%TYPE,
  I_piece        IN PIECES.NOPIECE%TYPE,
  I_age          IN NUMBER,
  I_period       IN PIECES.PERIOD%TYPE,
  I_delai        IN PIECES.DELAI%TYPE,
  I_bloc         IN PIECES.BLOC%TYPE DEFAULT 'N',
  I_Nbrel        IN PIECES.NBREL%TYPE DEFAULT 0,  
  I_adhdeb       IN ADHESION.IDADHESION%TYPE,
  I_adhfin       IN ADHESION.IDADHESION%TYPE,
  I_session      IN NUMBER DEFAULT 1,
  I_niv_msg      IN NUMBER DEFAULT 1,
  O_found        OUT NUMBER,
  O_erreur       OUT VARCHAR2) IS

  CURSOR C_population(p_age NUMBER,p_contexte_deb NUMBER,p_contexte_fin NUMBER, p_var NUMBER, p_adhdeb NUMBER,p_adhfin NUMBER) IS
    SELECT distinct ad.idadhesion, dest.numbene ,i.datnais, dest.type_bene contexte, dest.numindiv destinataire,  
    F_VAL_VAR_ALL(ad.numgar,p_var) limite_cntrt, age_mp(i.numindiv, sysdate) annee_naiss
    FROM adhesion ad, individu i, v_bene_justif dest, contrat_ref c, formule f
    WHERE ad.numindiv= i.numindiv
    AND i.typadr = 2
	AND ad.numfor = f.numfor
	AND c.GEST_PREST <>3
    AND f.TYPGAR =1 --uniquement les garanties de base
    --cas supérieur age inf limite age
    AND ((age_mp(i.numindiv, sysdate)>= NVL(p_age,age_mp(i.numindiv, sysdate)) --annee de naissance de l'assure sup à l'age maximum
        AND age_mp(i.numindiv, sysdate)< F_VAL_VAR_ALL(ad.numgar,p_var) -- annee de naissance de l'assure inf à l'age max par contrat
        AND p_age>=0)
    -- cas inf limite age
    OR ( age_mp(i.numindiv, sysdate)>= F_VAL_VAR_ALL(ad.numgar,p_var) -- annee de naissance de l'assure sup à la limite d'age par contrat
        AND p_age<0))
    AND f_etat_adhe(ad.idadhesion,sysdate,1)=1
    AND ad.typfor=1 -- garantie santé uniquement    	
    AND ad.numgar =c.numgar
    AND sysdate BETWEEN ad.datapli and NVL(ad.datper,sysdate)
    AND dest.idadhesion = ad.idadhesion
    AND dest.numbene = ad.numindiv
    AND dest.type_bene BETWEEN NVL(p_contexte_deb,dest.type_bene) AND NVL(p_contexte_fin,p_contexte_deb)
    AND (p_adhdeb IS NULL OR (ad.idadhesion BETWEEN p_adhdeb AND NVL(p_adhfin,999999999)))
	AND dest.numbene NOT IN( --sans piece identique en cours
      SELECT p.numbene
      FROM pieces p
      WHERE p.contexte = dest.type_bene
      AND  p.entite = dest.idadhesion
      AND  p.nopiece = I_piece
      AND p.idrepartition = 0 
      --AND p.daterecep IS NULL 
	  AND p.dateenreg BETWEEN trunc(SYSDATE, 'Y') AND SYSDATE
    )
    --AND c.numprod <> 99 
    ORDER BY 1,2;
   
   
  Rec_C_population C_population%ROWTYPE;

  v_pieces pieces%ROWTYPE;
  loc_var DEF_VARIABLE.idvariable%TYPE;
  loc_cpt NUMBER:=0;
  loc_Nbrel PIECES.NBREL%TYPE;

BEGIN
  g_max_msg := i_niv_msg;
  G_Session := I_Session;
  g_nom_traitement :='AD30T';
  O_found:=0;
  p_ins_journal( TO_CHAR(Sysdate, 'dd/mm/yyyy - hh24:mi') || ' - traitement '||g_nom_traitement,1);
  loc_var :=F_FIND_VAR('LIM_AGE_CT');
  
  IF NVL(I_Nbrel,0) = 0 THEN loc_Nbrel := NULL;
  ELSE loc_Nbrel:=I_Nbrel;
  END IF;
  
  FOR Rec_C_population IN C_population(I_age,I_contexte_deb,I_contexte_fin,loc_var,I_adhdeb,I_adhfin) LOOP
   BEGIN
    --insertion de la pièce
    v_pieces.contexte   := Rec_C_population.contexte;
    v_pieces.entite     := Rec_C_population.idadhesion;
    v_pieces.numfor     := 0 ;
    v_pieces.numbene    := Rec_C_population.numbene ;
    v_pieces.numindiv_dest := Rec_C_population.destinataire;
    v_pieces.idrepartition := 0 ;
    v_pieces.nopiece    := I_piece ;
    v_pieces.period     := I_period;
    v_pieces.delai      := I_delai ;
    v_pieces.bloc       := I_bloc ;
    v_pieces.nbrel      := loc_Nbrel ;
    IF NVL(loc_Nbrel,0) <>0 THEN
      v_pieces.dateavis := sysdate;
      v_pieces.daterel  := sysdate;
    END IF;
    v_pieces.dateenreg  := sysdate;

    P_INS_PIECES(v_pieces);
  
    loc_cpt := loc_cpt+1;
    --trace systématique pour le rapport détaillé
    p_ins_journal('Assuré : '||Rec_C_population.numbene
                 ||' Age (annee naissance) : '||Rec_C_population.annee_naiss 
                 ||' limite contrat : '||Rec_C_population.limite_cntrt ,2);
    EXCEPTION
      WHEN OTHERS THEN p_ins_journal('Insertion impossible pour : '||Rec_C_population.numbene,1);
    END;
  END LOOP;
  
  p_ins_journal( 'Nombre de pièces créées : '||loc_cpt,1);
  
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      rollback;
      O_Erreur :=g_nom_traitement ||' - ' || Substr (Sqlerrm (Sqlcode), 1, 128);
      p_ins_journal(O_Erreur,1);
      O_found:=1;


END P_AD30T;


--abo attention blocage massif doit se faire uniquement en santé (ne pas prendre les pièces des adhésions prévoyance !!!)
PROCEDURE P_AD31T (
  I_contexte_deb IN PIECES.CONTEXTE%TYPE,
  I_contexte_fin IN PIECES.CONTEXTE%TYPE,
  I_piece        IN PIECES.NOPIECE%TYPE,
  I_Nbrel        IN PIECES.NBREL%TYPE,
  I_delai        IN PIECES.DELAI%TYPE,
  I_session      IN NUMBER DEFAULT 1,
  I_niv_msg      IN NUMBER DEFAULT 1,
  O_found        OUT NUMBER,
  O_erreur       OUT VARCHAR2) IS

  CURSOR C_pieces(p_contexte_deb NUMBER,
                  p_contexte_fin NUMBER,
                  p_nopiece NUMBER,
                  p_Nbrel  NUMBER,
                  p_delai   NUMBER) IS
    SELECT p.entite,p.nopiece, p.numbene ,p.contexte,p.bloc
    FROM pieces p,adhesion ad
    WHERE p.nopiece = p_nopiece
    AND p.nbrel = NVL(p_Nbrel,NVL(F_SENS_LIBELLE('JUSTIF_'||p.contexte,p_nopiece),-1)) --paramétrage possible du nb de relance max par pièce
    AND ad.idadhesion = p.entite
    AND p.numbene = ad.numindiv
    AND f_etat_adhe(ad.idadhesion,sysdate,1)=1
    AND ad.typfor=1 -- garantie santé uniquement
    AND sysdate BETWEEN ad.datapli and NVL(ad.datper,sysdate)
    AND p.contexte BETWEEN NVL(p_contexte_deb,p.contexte) AND NVL(p_contexte_fin,p_contexte_deb)
    AND p.bloc = 'N'
    AND TRUNC(NVL(p.DATEREL,P.DATEAVIS) + p_delai) <= TRUNC(SYSDATE) --delai après emission de la relance ou de l'avis de demande de piece
    AND dateavis  IS NOT NULL
    AND daterecep IS NULL
    ORDER BY 1,2
    FOR UPDATE of BLOC;

  Rec_C_pieces C_pieces%ROWTYPE;
  loc_cpt NUMBER:=0;

  

BEGIN
  g_max_msg := i_niv_msg;
  G_Session := I_Session;
  g_nom_traitement :='AD31T';
  O_found:=0;
  p_ins_journal( TO_CHAR(Sysdate, 'dd/mm/yyyy - hh24:mi') || ' - traitement '||g_nom_traitement,1);
  
  FOR Rec_C_pieces IN C_pieces(I_contexte_deb,I_contexte_fin,I_piece,I_Nbrel,I_delai) LOOP
   BEGIN

     UPDATE pieces
     SET BLOC = 'O'
     WHERE CURRENT OF C_pieces;

    --trace systématique pour le rapport détaillé
    p_ins_journal('Piece '||Rec_C_pieces.nopiece || 'contexte '|| Rec_C_pieces.contexte
                  ||' pour : '||Rec_C_pieces.numbene || ' adhésion :'||Rec_C_pieces.entite,2);
    loc_cpt := loc_cpt+1;
    EXCEPTION
      WHEN OTHERS THEN p_ins_journal('Blocage impossible piece '||Rec_C_pieces.nopiece|| ' contexte '|| Rec_C_pieces.contexte
                                     ||' pour assuré : '||Rec_C_pieces.numbene || ' adhésion :'||Rec_C_pieces.entite,1);
    END;
  END LOOP;
  
   p_ins_journal( 'Nombre de pièces bloquées : '||loc_cpt,1);
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      O_Erreur :=g_nom_traitement ||' - ' || Substr (Sqlerrm (Sqlcode), 1, 128);
      p_ins_journal(O_Erreur,1);
      O_found:=1;
      ROLLBACK;
    

END P_AD31T;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_PIECES                                              */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans pieces                         */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_PIECES(I_PIECES  IN PIECES%ROWTYPE) IS
BEGIN

  INSERT INTO PIECES VALUES I_PIECES;

END P_INS_PIECES;
-- ---------------------------------- Fin des corps des procedures publiques --


END PK_PIECES;
/
