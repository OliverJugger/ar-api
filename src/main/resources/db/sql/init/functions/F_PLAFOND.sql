CREATE FUNCTION ARTHUS.F_PLAFOND (
   i_numsin       IN   NUMBER,
   i_nature       IN   NUMBER DEFAULT 1,
   i_idadhesion   IN   NUMBER,
   i_numfor       IN   NUMBER,
   i_numassu      IN   NUMBER,
   i_numindiv     IN   NUMBER,
   i_codfrais     IN   VARCHAR2,
   i_rubrique     IN   VARCHAR2,
   i_datsin       IN   DATE,
   i_numdossier   IN   VARCHAR2 DEFAULT '0'
)
   RETURN NUMBER
AS
/*===========================================================================*/
/* Fonction     : F_PLAFOND                                                  */
/* Domaine      : Prestation santé                                           */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : DD/MM/AAAA                                                 */
/* Description  : Extraction des plafonds paramétrés en nb et montants actes */
/*              :                                                            */
/*===========================================================================*/
/* Correction   : PHA / date26/05/2014 / utilisation de la famille au niveau */
/*                des actes/garanties (évolution CCAM dentaire)              */
/*                utilisation de la table calcul en lieu et place de natfrais*/
/*===========================================================================*/
/* Evolution    : Contrat responsable cumul des plafonds                     */
/* Auteur       : ABO                                                        */
/* Date         : 27/07/2015                                                 */
/* Commentaire  : refonte totale du fonctionnement                           */
/*===========================================================================*/
--



 loc_trav_plafond TRAV_PLAFOND%ROWTYPE;
 loc_type_plfd_doss MAXDOSS.TYPE_PLAFOND%TYPE;
 loc_perimetre varchar(10);
 --loc_devise_doss MAXDOSS.MONNAIE%TYPE;
BEGIN
  loc_trav_plafond := NULL;
  loc_type_plfd_doss :=NULL;
  --type 0 Acte , 1 Famille, 2 Garantie , -1 dossier
  --retourne le consommé si plafond en fonction du type



 ----------------------------------
 --  RECHERCHE PRESENCE PLAFOND  --
 ----------------------------------
  BEGIN
   loc_trav_plafond.nature := i_nature;
   loc_trav_plafond.numsin := i_numsin;
   loc_trav_plafond.numfor := i_numfor;

   IF i_nature = 0 THEN loc_perimetre := i_codfrais;
   ELSIF i_nature = 1 THEN loc_perimetre := i_rubrique;
  -- ELSIF i_nature = 2 THEN loc_perimetre = i_numfor;
   END IF;

   IF i_nature IN (0,1) THEN
     --Plafond acte ou famille
     SELECT  maxact.etendue,
        NVL(maxact.nummath, 0), NVL(maxact.montant, 0),
        NVL(maxact.indice, 0),    NVL(maxact.nbindice, 0),
        NVL(maxact.taux, 0),    NVL(maxact.nummath_c, 0),
        NVL(maxact.nbactes, 0), loc_perimetre
      INTO loc_trav_plafond.etendue,
        loc_trav_plafond.nummath,loc_trav_plafond.montant,
        loc_trav_plafond.indice, loc_trav_plafond.nbindice,
        loc_trav_plafond.taux,   loc_trav_plafond.nummath_c,
        loc_trav_plafond.nbactes,loc_trav_plafond.codfrais
      FROM maxact, gar_cntrt
      WHERE gar_cntrt.numfor = i_numfor
      AND maxact.numfor = pk_qttc.f_sel_numfor (gar_cntrt.numgar, gar_cntrt.numfor)
      AND maxact.datapli != NVL(maxact.datper, maxact.datapli + 1)
      AND i_datsin BETWEEN maxact.datapli     AND NVL (maxact.datper, i_datsin)
      AND maxact.codfrais = loc_perimetre;

      loc_trav_plafond.codano    := -1;

    ELSIF i_nature =2 THEN
      --Plafond garantie
      SELECT  maxfor.etendue,
        NVL(maxfor.nummath, 0), NVL(maxfor.montant, 0),
        NVL(maxfor.indice, 0),    NVL(maxfor.nbindice, 0),
        NVL(maxfor.taux, 0),    NVL(maxfor.nummath_c, 0),
        NULL,NULL
      INTO loc_trav_plafond.etendue,
        loc_trav_plafond.nummath,loc_trav_plafond.montant,
        loc_trav_plafond.indice, loc_trav_plafond.nbindice,
        loc_trav_plafond.taux,   loc_trav_plafond.nummath_c,
        loc_trav_plafond.nbactes,loc_trav_plafond.codfrais
      FROM maxfor, gar_cntrt
      WHERE gar_cntrt.numfor = i_numfor
      AND maxfor.numfor = pk_qttc.f_sel_numfor (gar_cntrt.numgar, gar_cntrt.numfor)
      AND maxfor.datapli != NVL(maxfor.datper, maxfor.datapli + 1)
      AND i_datsin BETWEEN maxfor.datapli     AND NVL (maxfor.datper, i_datsin);

      loc_trav_plafond.codano    := -1;

    ELSIF i_nature =-1 THEN
    --Périodicité Dossier : D pour dossier et A pour Annuel   -- plafond en devise de référence
      SELECT 1,
        NVL (nummath, 0), NVL (pk_devise.f_conv_montant(monnaie,pk_devise.devise_ref,plafond,i_datsin,'O'), 0),
        NVL (indice, 0), NVL (nbindice, 0),
        NVL (taux, 0),0,
        NVL (nbactes, 0),  NULL,
        date_deb, date_fin,
        type_plafond
      INTO loc_trav_plafond.etendue,
        loc_trav_plafond.nummath,loc_trav_plafond.montant,
        loc_trav_plafond.indice, loc_trav_plafond.nbindice,
        loc_trav_plafond.taux,   loc_trav_plafond.nummath_c,
        loc_trav_plafond.nbactes,loc_trav_plafond.codfrais,
        loc_trav_plafond.deb_conso, loc_trav_plafond.fin_conso,
        loc_type_plfd_doss

        FROM maxdoss
       WHERE num_dossier = i_numdossier
         AND i_datsin BETWEEN date_deb AND NVL (date_fin, i_datsin);

      loc_trav_plafond.codano :=3; --présence d'un plafond dossier, les autres plafonds doivent donc être ignorés

    END IF;


  EXCEPTION
    WHEN no_data_found THEN
       loc_trav_plafond.codano := 0; --pas de plafond n'est pas une anomalie
    WHEN Too_many_rows THEN
      loc_trav_plafond.codano := 2;
    WHEN OTHERS THEN
      loc_trav_plafond.codano := 1;

  END;

  IF  NVL(loc_trav_plafond.codano,0) NOT IN (0,1,2) THEN
    ----------------------------------
    --  PERIODE CONCERNEE           --
    ----------------------------------
    --si on a une formule de consommé on indique pas la période car pourrait induire en erreur
    IF loc_trav_plafond.nummath_c != 0 THEN
      loc_trav_plafond.deb_conso :=NULL;
      loc_trav_plafond.fin_conso:=NULL;
    -- plafond annuel strict dont plafond dossier annuel
    ELSIF (i_nature IN (0,1,2)) OR (i_nature = -1  AND loc_type_plfd_doss ='A') THEN
      loc_trav_plafond.deb_conso := TRUNC(i_datsin,'YYYY');
      loc_trav_plafond.fin_conso := add_months(loc_trav_plafond.deb_conso,12)-1;
    --si le plafond dossier est de type 'D' alors deb et fin sont déjà valorisés.
    END IF;


    ----------------------------------
    --  RECHERCHE CONSO            --
    ----------------------------------
    IF i_nature = -1  AND loc_trav_plafond.nummath_c = 0  THEN
      SELECT SUM ( NVL(conso.mtreel,0)) , SUM (NVL (conso.nbacte, 0))
      INTO loc_trav_plafond.conso_mt,
           loc_trav_plafond.conso_nb
      FROM (
        SELECT SUM ( NVL(sntr.mtreel,0)) mtreel, SUM (NVL (sntr.nbacte, 0)) nbacte
        FROM sntr, sntr_dossier, frmls
        WHERE sntr_dossier.numsin_sntr = sntr.numsin
        AND sntr_dossier.num_dossier = i_numdossier
        AND sntr.numannul IS NULL
        AND pk_qttc.f_sel_numfor (sntr.numgar, sntr.numfor) = frmls.numfor
        AND frmls.flag_regime = 'C'
        AND sntr.datsin BETWEEN loc_trav_plafond.deb_conso AND NVL (loc_trav_plafond.fin_conso, sntr.datsin    )
        AND NOT EXISTS (SELECT 1
                          FROM sntr a
                         WHERE a.numannul = sntr.numsin)
        AND sntr.mtreel <> 0
        UNION
        SELECT SUM ( NVL(travsn.mtreel,0)) mtreel, SUM (NVL (travsn.nbacte, 0)) nbacte
        FROM travsn, frmls
        WHERE travsn.numindiv = i_numindiv
        AND pk_qttc.f_sel_numfor (travsn.numgar, travsn.numpopu) = frmls.numfor
        AND frmls.flag_regime = 'C'
        AND travsn.datsin BETWEEN loc_trav_plafond.deb_conso AND NVL (loc_trav_plafond.fin_conso, travsn.datsin    )
        AND travsn.mtreel <> 0) conso;

    ELSIF loc_trav_plafond.nummath_c = 0 THEN
      --ABO attention l'étendue des plafonds paramétrés est codifié en 1 individu, 2 famille alors que la fonction ACTE_CONSO 0 individu , 1 famille
      loc_trav_plafond.conso_mt := pk_funct.f_act_cons_c( i_numindiv, i_idadhesion, i_numfor, i_nature, loc_perimetre,loc_trav_plafond.deb_conso,loc_trav_plafond.fin_conso , loc_trav_plafond.etendue-1,2,0);
      loc_trav_plafond.conso_nb := pk_funct.f_act_cons_c( i_numindiv, i_idadhesion, i_numfor, i_nature, loc_perimetre,loc_trav_plafond.deb_conso,loc_trav_plafond.fin_conso , loc_trav_plafond.etendue-1,1,0);
    END IF;

    ----------------------------------
    --  RECHERCHE PLAFOND           --
    ----------------------------------
    IF loc_trav_plafond.nummath = 0 THEN
      loc_trav_plafond.plfd_mt := f_calcul_plafond (1,loc_trav_plafond.montant, loc_trav_plafond.indice, loc_trav_plafond.taux, loc_trav_plafond.nbindice,i_datsin, loc_trav_plafond.nbactes);
      loc_trav_plafond.plfd_nb := f_calcul_plafond (2,loc_trav_plafond.montant, loc_trav_plafond.indice, loc_trav_plafond.taux, loc_trav_plafond.nbindice,i_datsin, loc_trav_plafond.nbactes);
    END IF;
     --historisation du plafond
    INSERT INTO TRAV_PLAFOND VALUES loc_trav_plafond;
  END IF;


  RETURN NVL(loc_trav_plafond.codano,0);

  EXCEPTION
    WHEN OTHERS THEN pk_trace.p_ins_journal_adm('GS19T', 1,1,'Erreur plafond'||SQLERRM,sysdate);
       RETURN(1);

END F_PLAFOND;
