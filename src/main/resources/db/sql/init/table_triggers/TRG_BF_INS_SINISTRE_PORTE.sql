CREATE TRIGGER ARTHUS."TRG_BF_INS_SINISTRE_PORTE"
before insert
on sinistre_porte
for each row
DECLARE
CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
L_rech_indiv  porte_param.rech_indiv%Type;
L_typbene  porte_param.typbene%Type;
L_numbene  porte_param.numbene%Type;
L_fr_rr    porte_param.fr_rr%Type;
loc_secteur  number;
loc_zone  number;
loc_action  number;
loc_motif  number;
loc_datporte porte_remise.dateporte%Type;
w_numano   number(6);
--TPE debut
l_datfact suivi_fact_tpe.datfact%TYPE;
--l_codadeli suivi_fact_tpe.codadeli%TYPE;
l_numindiv pers_tiers.numindiv%TYPE;
--l_datnais indvs.datnais%TYPE;
l_existe PLS_INTEGER;
--l_fact_reglee PLS_INTEGER;
l_fact_inconnue PLS_INTEGER;
l_no_data_1 BOOLEAN := FALSE;
--l_no_data_4 BOOLEAN := FALSE;
--l_no_data_5 BOOLEAN := FALSE;
--l_date_fausse BOOLEAN := FALSE;
l_codevefac suivi_fact_tpe.codevefac%TYPE;
l_enreg_facture sinistre_porte%ROWTYPE;
-- 20061003 Ano spécifique au paiement (B.Cotteblanche)
l_vrai_ano BOOLEAN := FALSE;
--ABO
loc_regime VARCHAR2(2);
--loc_etatd histo_dossier.etat%TYPE;
--loc_num_dossier dossier_sante.num_dossier%TYPE;

loc_num_dossier_liq dossier_sante.num_dossier%TYPE;
loc_dossier NUMBER(15);
loc_motifd histo_dossier.motif%TYPE;
loc_etatd histo_dossier.etat%TYPE;
loc_nature varchar2(3);
loc_codfrais porte_natfrais.codfrais%TYPE;
loc_sens_porte libelle.sens%TYPE;
loc_ano NUMBER;
loc_nbligne NUMBER;
l_nb_dossier_liq NUMBER;
loc_numfact suivi_fact_tpe.numfact%TYPE;
loc_datfact suivi_fact_tpe.datfact%TYPE;
exc_dossier_inconnu EXCEPTION;
exc_dossier_liquide EXCEPTION;
exc_dossier_ferme   EXCEPTION;
exc_dossier_perime  EXCEPTION;
exc_montant_diff    EXCEPTION;
exc_acte_inconnu    EXCEPTION;
exc_rej_technique   EXCEPTION;

loc_dossier_resil dossier_sante.num_dossier%TYPE:=NULL;
loc_ano_resil     NUMBER:=0;

loc_dossier_PEC     DOSSIER_SANTE.NUM_DOSSIER%TYPE:=NULL;
loc_dossier_creat   DOSSIER_SANTE.CREATION%TYPE:=NULL;

l_tabCond			PK_PORTE.TAB_Cond;

loc_list_dent   varchar2(100);

CURSOR C_sinistre_sante(p_num_dossier varchar2,
                        p_montant number,
                        p_nature varchar2,
                        p_codfrais Varchar2) IS

  SELECT s.numligne,s.numsin_sntrprt,s.mtprest_reel,s.codfrais
  FROM  sinistre_sante  s LEFT OUTER JOIN ntfrs_detail d ON ( s.codfrais = d.codfrais)
  WHERE num_dossier = p_num_dossier
  AND (s.codfrais = d.codfrais
  AND ((d.lentille = 1 AND p_nature='001')
    OR (d.monture = 1 AND p_nature='010')
    OR (d.verre = 1 AND p_nature='100'))
   OR (s.codfrais = p_codfrais AND p_nature='000'))
  AND NVL(s.mtprest_reel,0)=NVL(p_montant,0)
  AND s.numsin_sntrprt IS NULL
  order by numligne;


CURSOR C_dossier_sante (p_refcie VARCHAR2,p_numporte NUMBER) IS
  SELECT num_dossier, num_dossier_pec, ref_dossier,numindiv,numbene,numassu,numporte,nat_doss,num_dossier_porte,numremise_sntrprt
  FROM dossier_sante
  WHERE ref_dossier = trim(p_refcie)
  AND type_doss = 4
  AND numporte = p_numporte; -- MUR M0005718

CURSOR C_sntr_dossier (p_dossier NUMBER,p_numligne NUMBER) IS
  SELECT numsin_sntr
  FROM sntr_dossier
  WHERE num_dossier = TO_CHAR(p_dossier)
  AND numligne = p_numligne;

Rec_C_sinistre_sante C_sinistre_sante%ROWTYPE;
REc_C_dossier_sante C_dossier_sante%ROWTYPE;
Rec_C_sntr_dossier   C_sntr_dossier%ROWTYPE;

PROCEDURE histo_suivi_fact_tpe
IS
BEGIN
  INSERT INTO suivi_fact_tpe ( codadeli,
                               numfact,
                               numremise_import,
                               datfact,
                               codbenefinsee,
                               codbenefcle,
                               datnaibenef,
                               rangbenef,
                               codtypfact,
                               datreceptor,
                               datlimiamc,
                               numcompos,
                               codamcdet,
                               idcptebq,
                               reffin,
                               typavireg,
                               codevefac,
                               idfactpe,
                               montant,
                               complt_titre )
  ( SELECT codadeli,
           numfact,
           numremise_import,
           datfact,
           codbenefinsee,
           codbenefcle,
           datnaibenef,
           rangbenef,
           codtypfact,
           datreceptor,
           datlimiamc,
           numcompos,
           codamcdet,
           idcptebq,
           reffin,
           typavireg,
           30,
           idfactpe,
          montant,
          complt_titre
    FROM suivi_fact_tpe
    WHERE idfactpe = :NEW.idfactpe
    AND codevefac = :NEW.codevefac
    AND numremise_import = :NEW.numremise
    AND NOT EXISTS ( SELECT NULL
                     FROM suivi_fact_tpe
                     WHERE idfactpe = :NEW.idfactpe
                     AND codevefac = 30
                     AND numremise_import = :NEW.numremise )
  );
--
  :NEW.codevefac := 30;
--
END histo_suivi_fact_tpe;
--TPE fin
BEGIN
pk_noemie.P_SEL_porte_param (
    I_numporte  => :new.numporte,
    O_rech_indiv  => L_rech_indiv,
    O_typbene  => L_typbene,
    O_numbene  => L_numbene,
    O_fr_rr    => L_fr_rr );
  --
  --  ERREUR  Libelle
  --  1  Prestation negative
  --  2  Acte non gere
  --  3  En attente de pieces
  --  4  Honoraires globalises
  --  5  Plusieurs contrats retrouves
  --  40  Plusieurs assures correspondent aux criteres.
  --  41  Pas d'assure correspondant aux criteres
  --  42  Pas de codfrais correspondant
  --
/* Prestation de regularisation  */
If (:new.quantite < 0 ) then
  pk_noemie.P_INS_sinistre_ano(
    I_numporte  => :new.numporte,
    I_numano  => 1,
    I_numsin  => :new.numsin,
    I_datano  => Trunc(sysdate),
    I_etatano  => 1,
    I_numremise  => :new.numremise);
  :new.etat := 3 ;
End If;

If ( nvl(:new.coeff,0) = 0 ) then
  :new.coeff := 1;
End If;

/* Recherche assure  */
/* CTT 01/12/2005 : Pour retrouver nos quasi-centenaires on comparera la date reçue au siécle dernier...(fiche 394) */
If ( :new.numindiv = 0 or :new.numassu = 0 ) then
  /* Par matricule, datnais, rang  */
  w_numano := 0;
  If ( L_rech_indiv = 1 ) then
    -- PK_TRACE.P_INS_journal_adm('TEST_TPE', 0, 0, 'Recherche par matricule,datnais,rang', SYSDATE,  F_NEXT_idligne(0));
    -- CTT 02/03/06 (fiche 408) : Recherche sur l'année et mois de la date de naissance ('mmyy').
    -- CTT 10/03/06 (fiche 403 - 404) : Recherche uniquement sur couverture santé
    -- CTT 28/03/06(fiche 404 -retour 15/03/06 et fiche demande amélioration 177) : Nouvel algorithme de recherche.
    -- CTT 30/05/06 :  Le contrôle de date de naissance porte finalement sur la date naissance "regime"  de la table indvs
    BEGIN   --   Recherche de l'assuré avec la date de naissance complète
      select  numindiv,
          numassu
      into  :new.numindiv,
          :new.numassu
      from  indvs
      where  ((indvs.matorg   = :new.matorgindiv) OR (NVL(indvs.matorg2,indvs.matorg)   = :new.matorgindiv)) -- Gestion du double numéro de sécurité social
      and    datnais_regime   = :new.datnais_indiv
      and    nvl(rang,0)   = :new.rang_indiv;

    EXCEPTION
      WHEN too_many_rows THEN
        begin  -- Recherche de l'assuré avec date de naissance complète et couverture à la date des soins
          select  numindiv,
              numassu
          into  :new.numindiv,
              :new.numassu
          from  indvs
          where  ((indvs.matorg   = :new.matorgindiv) OR (NVL(indvs.matorg2,indvs.matorg)   = :new.matorgindiv)) -- Gestion du double numéro de sécurité social
          and    f_cvrtsante(indvs.numindiv, :NEW.datsin) = 1
          and    datnais_regime   = :new.datnais_indiv
          and    nvl(rang,0)   = :new.rang_indiv;
        exception
          when too_many_rows then
              w_numano := 40;
          when no_data_found then
              w_numano := 46;
          when others then null;
        end;  -- FIN de Recherche de l'assuré avec date de naissance complète et couverture à la date des soins

      WHEN no_data_found THEN
        begin  -- Recherche de l'assuré avec la date de naissance sans le jour
          select  numindiv,
              numassu
          into  :new.numindiv,
              :new.numassu
          from  indvs
          where  ((indvs.matorg   = :new.matorgindiv) OR (NVL(indvs.matorg2,indvs.matorg)   = :new.matorgindiv)) -- Gestion du double numéro de sécurité social
          and    substr(datnais_regime,3,4) = substr(:new.datnais_indiv,3,4)
          and    nvl(rang,0)     = :new.rang_indiv;
        exception
          when too_many_rows then
            begin  -- Recherche de l'assuré avec la date de naissance sans le jour et couverture à la date des soins
              select  numindiv,
                  numassu
              into  :new.numindiv,
                  :new.numassu
              from  indvs
              where  ((indvs.matorg   = :new.matorgindiv) OR (NVL(indvs.matorg2,indvs.matorg)   = :new.matorgindiv)) -- Gestion du double numéro de sécurité social
              and    f_cvrtsante(indvs.numindiv, :NEW.datsin) = 1
              and    substr(datnais_regime,3,4) = substr(:new.datnais_indiv,3,4)
              and    nvl(rang,0)     = :new.rang_indiv;
            exception
              when too_many_rows then
                w_numano := 40;
              when no_data_found then
                w_numano := 46;
              when others then null;
            end; -- Fin recherche de l'assuré avec la date de naissance sans le jour et couverture à la date des soins
          when no_data_found then
              w_numano := 71;
          when others then null;
        end;  -- FIN de Recherche de l'assuré avec date de naissance complète et couverture à la date des soins
      WHEN others THEN null;
      END;  --   FIN de Recherche de l'assuré avec la date de naissance complète
  End If; -- Fin de recherche par matricule, datnais, rang

/* Par matricule seulement  */
  If ( L_rech_indiv = 2 ) then
    --PK_TRACE.P_INS_journal_adm('TEST_TPE', 0, 0, 'Recherche par matricule', SYSDATE,  F_NEXT_idligne(0));
      begin
      select  numindiv,
          numassu
      into  :new.numindiv,
          :new.numassu
      from  indvs
      where  indvs.matorg = :new.matorgindiv
      and  indvs.natur=1;

    EXCEPTION
      When no_data_found then
        w_numano := 41;
      When too_many_rows then
        w_numano := 40;
      When others then null;
      End;
  End If; --Fin de recherche par matricule seulement

  /* Par numindiv    */
  If ( L_rech_indiv = 3 ) then
    --PK_TRACE.P_INS_journal_adm('TEST_TPE', 0, 0, 'Recherche numindiv', SYSDATE,  F_NEXT_idligne(0));
      begin
      select  numassu
      into  :new.numassu
      from  indvs
      where  indvs.numindiv = :new.numindiv;

    EXCEPTION
      When no_data_found then
        w_numano := 41;
      When too_many_rows then
        w_numano := 40;
      When others then null;
      End;
  End If; -- Fin de recherche par numindiv

  -- Traitement des anomalies des différentes recherches de l'individu assuré
  IF w_numano > 0 THEN
    pk_noemie.P_INS_sinistre_ano(
        I_numporte  => :new.numporte,
        I_numano  => w_numano,
        I_numsin  => :new.numsin,
        I_datano  => Trunc(sysdate),
        I_etatano  => 1,
        I_numremise  => :new.numremise);
    :new.etat := 3 ;
  END IF;
End If; -- Fin Recherche assure

/* Type bene charge ou porte  */
If ( :new.typbene = 0 ) then
  :new.typbene := L_typbene;
End If;

/* Numbene assure ou porte  */
If ( :new.numbene = 0 ) then
  If ( L_typbene = 1 ) then
    :new.numbene := :new.numassu;
  else
    :new.numbene := L_numbene;
  End If;
End If;


/*sinon transcodification habituel*/
/* Codfrais transcodification de l'acte */
If ( :new.codfrais is null AND :new.refcie IS  NULL ) then
  begin
  loc_secteur := 1;
  loc_zone := 0;
  IF :new.regime ='00' THEN loc_regime:='01';
  ELSE loc_regime:=:new.regime ;
  END IF;
  /* recherche si secteur conventione  */
  If :new.noe_spec != '00' then
    If :new.noe_zone != '00' then
      --PK_TRACE.P_INS_journal_adm('TEST_TPE', 0, 0, 'Secteur', SYSDATE,  F_NEXT_idligne(0));
      begin
      select  code_secteur,
          code_zone
      into  loc_secteur,
          loc_zone
      from  zone_trf
      where  regime = NVL(loc_regime,'01') --ABO 19/03/2010 ajout des regimes
      and  code_tarif = :new.noe_zone;

      EXCEPTION
      When no_data_found then
        loc_secteur := 1;
        loc_zone := 0;
      When others then null;
      End;
    End If;
  End If;

  -- PK_TRACE.P_INS_journal_adm('TEST_TPE', 0, 0, 'Codfrais', SYSDATE,  F_NEXT_idligne(0));
  --ABO 22/03/2010 ajout du filtre sur le régime suite à l'ouverture des échanges Noemie sur les autres régimes
  select  nvl(decode(loc_secteur,
            2, codfrais_porte_nc,
            codfrais),
            codfrais),
      action,
      motif
  into  :new.codfrais,
      loc_action,
      loc_motif
  from  porte_natfrais
  where  porte_natfrais.numporte = :new.numporte
  and  porte_natfrais.codfrais_porte = :new.codfrais_porte
  and porte_natfrais.regime = NVL(loc_regime,'01')
  and  (porte_natfrais.code_spec = NVL(F_SENS_LIBELLE('SPEC',:new.noe_spec),:new.noe_spec)
      or
    (porte_natfrais.code_spec = '00'
    and Not Exists (
      Select  1
      from  porte_natfrais
      where  porte_natfrais.numporte = :new.numporte
      and  porte_natfrais.codfrais_porte = :new.codfrais_porte
      and porte_natfrais.regime = NVL(loc_regime,'01')
      and porte_natfrais.code_spec = NVL(F_SENS_LIBELLE('SPEC',:new.noe_spec),:new.noe_spec))
      --decode(porte_natfrais.code_spec,18,80,porte_natfrais.code_spec) = :noe_spec)
      )
    )
  and  (porte_natfrais.code_zone = loc_zone
    or
    porte_natfrais.code_zone = 0)
  and exists (
    select  1
    from  natfrais
    where  natfrais.codfrais =
        decode(loc_secteur,
          2, porte_natfrais.codfrais_porte_nc,
          porte_natfrais.codfrais)
    )
  and  f_evalue( decode(porte_natfrais.champ,
          1, :new.coeff,
          2, :new.quantite,
          3, :new.taux,
          4, :new.mtfrais,
          5, :new.baseremb,
          6, :new.mtremb,
          Null),
      porte_natfrais.valeur, porte_natfrais.operateur ) = 1
  and  f_evalue_alpha( decode(porte_natfrais.champ2, 1, :new.indmco, Null),
            porte_natfrais.valeur2, porte_natfrais.operateur2 ) = 1
  ;
-- CTT 03/03/06 : uniformisation du package : la structure de la table porte_natfrais  et l'écran pe23 ont été livrés dans ce but.
-- CTT 11/05/06 : Ajout du rejet de la facture dans suivi_fact_tpe...
  EXCEPTION
  When no_data_found then
    pk_noemie.P_INS_sinistre_ano(
      I_numporte  => :new.numporte,
      I_numano  => 42,
      I_numsin  => :new.numsin,
      I_datano  => Trunc(sysdate),
      I_etatano  => 1,
      I_numremise  => :new.numremise);
    :new.etat := 3 ;
  When too_many_rows then
    pk_noemie.P_INS_sinistre_ano(
      I_numporte  => :new.numporte,
      I_numano  => 61,
      I_numsin  => :new.numsin,
      I_datano  => Trunc(sysdate),
      I_etatano  => 1,
      I_numremise  => :new.numremise);
    :new.etat := 3 ;
  When others then null;
  End;
End If;

l_tabCond(1) := :new.numexec;
l_tabCond(2) := :new.modtrait;

/* Paiement a tiers / mandataire  */
If ( :new.typbene = 56 or :new.typbene = 57 ) then
  begin
  /* Prestation couverte par carte T.P.  */
  -- JBO 09/10/2012 : Ajout de la catégorie dans pk_porte.f_carte_tp pour la gestion des centres de santé
   If ( pk_porte.f_carte_tp(:new.numindiv, :new.codfrais, :new.datsin,NULL, NULL, :new.categorie, l_tabCond) != 0 ) then
    pk_noemie.P_INS_sinistre_ano(
      I_numporte  => :new.numporte,
      I_numano  => 58,
      I_numsin  => :new.numsin,
      I_datano  => Trunc(sysdate),
      I_etatano  => 1,
      I_numremise  => :new.numremise);
    :new.etat := 4 ;
  else
    pk_noemie.P_INS_sinistre_ano(
      I_numporte  => :new.numporte,
      I_numano  => :new.typbene,
      I_numsin  => :new.numsin,
      I_datano  => Trunc(sysdate),
      I_etatano  => 1,
      I_numremise  => :new.numremise);
  End If;

  INSERT INTO sinistre_porte_forcage ( numremise, numsin,numordre,numzone,datfrcg, numutil,valeur)
  SELECT :new.numremise,:new.numsin,nvl(max(numordre),0)+1,f_column_id('sinistre_porte', 'typbene'),trunc(sysdate),f_numutil,:new.typbene
  FROM sinistre_porte_forcage
  WHERE  numremise = :new.numremise
  AND numsin = :new.numsin;

  :new.typbene := L_typbene;
  End;
End If;

/* Pas de frais reeels  */
If ( :new.mtfrais = 0 ) then
  -- Cetip : Frais reels = base remb
  If (:new.baseremb != 0 and :new.noe_qualif is null) then
    :new.mtfrais := :new.baseremb;
  End If;
End If;


/* Acte bloque ou rejete (sur transcodification)  */
-- CTT 11/05/06 : Ajout du rejet de la facture dans suivi_fact_tpe...
-- CTT 08/06/06 : finalement ... retour au traitement initial : Une anomalie est "signalée" mais la facture n'est pas rejetée
If loc_action != 1 then
  pk_noemie.P_INS_sinistre_ano(
    I_numporte  => :new.numporte,
    I_numano  => loc_motif,
    I_numsin  => :new.numsin,
    I_datano  => Trunc(sysdate),
    I_etatano  => 1,
    I_numremise  => :new.numremise);
  --
  If loc_action = 2 then
      :new.etat := 4; /* ne pas calculer */
  Else
    :new.etat := 3 ;
  End If;
End If;

/* Frais reels = remboursement regime */
If ( :new.mtremb = :new.mtfrais ) OR (:new.mtfrais = 0) then
  If ( L_fr_rr = 'N' ) then
    :new.etat := 4;
  End if;
End if;

-- CTT 10/08/06 Test de prescription de la date du sinistre
-- CTT 09/01/07 Initialement positionné à tort pour les seules factures TPE (codevefac =10)
begin
select  dateporte
into  loc_datporte
from   porte_remise
where   numremise = :new.numremise
and numporte = :new.numporte; -- MUR M0005615
IF loc_datporte is not null THEN
  IF f_numorg_prescription ( :NEW.numindiv, :NEW.datsin, sysdate) = 1 THEN
          pk_noemie.P_INS_sinistre_ano(
                I_numporte      => :new.numporte,
                I_numano        => 94,
                I_numsin        => :new.numsin,
                I_datano        => Trunc(sysdate),
                I_etatano       => 1,
                I_numremise     => :new.numremise);
          :new.etat := 3 ;
  END IF;
END IF;
--ajout MUR M0005615
EXCEPTION when others then loc_datporte := null ;
end;

 /* ABO 12/01/2012 Codfrais transcodification de l'acte s'il fait partie s'une PEC Sp Sante*/
IF ( :new.codfrais IS NULL AND :new.refcie IS NOT NULL AND :new.numporte = 2 ) THEN
   BEGIN
      --:new.refcie := trim(replace(:new.refcie,0));
      :new.refcie := LTRIM(:new.refcie,0);
      w_numano :=0;
      dbms_output.put_line(':new.refcie :'||:new.refcie);
      --contrôle de l'existence du dossier de PEC
      OPEN C_dossier_sante(:new.refcie,15); -- MUR M0005718
      FETCH C_dossier_sante INTO Rec_C_dossier_sante;

      -- JBO : 3900 : ajout de loc_dossier_resil : permet de supprimer l ano de controle de fin de garantie
      -- uniquement pour les prestations issues d une prise en charge
      loc_dossier_resil:=Rec_C_dossier_sante.num_dossier;

      IF C_dossier_sante%NOTFOUND THEN
        RAISE exc_dossier_inconnu;
      END IF;


      loc_etatd:=F_ETAT_DOSSIER_SANTE(Rec_C_dossier_sante.num_dossier,sysdate,1);
      loc_motifd := F_ETAT_DOSSIER_SANTE(Rec_C_dossier_sante.num_dossier,sysdate,2);

      BEGIN
        SELECT num_dossier
        INTO loc_dossier
        FROM dossier_sante
        WHERE type_doss=1
        AND num_dossier_pec = Rec_C_dossier_sante.num_dossier
        AND numremise_sntrprt = :new.numremise;
      EXCEPTION
        WHEN no_data_found THEN loc_dossier:=0;
      END;

      IF (Rec_C_dossier_sante.num_dossier_pec IS NOT NULL AND loc_dossier=0 ) -- dossier facturé au PS
      OR ( :NEW.codevefac NOT IN(50,60) AND loc_etatd=0 AND loc_motifd=6) THEN -- ou déjà dans circuit facture
        RAISE exc_dossier_liquide;
      --contrôle de l'état du dossier fermé ?
      ELSIF loc_etatd = 1 THEN
        --contrôle du motif :
        IF :NEW.codevefac  IN(50,60) AND loc_motifd = 2 THEN NULL; --attention on doit laissé passé ceux qui ont été facturé avant péremption pour les avis de paiement
        ELSIF loc_motifd IN (2,3) THEN --dossier perime
          RAISE exc_dossier_perime ;
        ELSE -- dossier ferme ?
          RAISE exc_dossier_ferme;
        END IF;
      --TODO ajouter un filtre sur l'état accepté que à 2... on sait jamais..
      END IF;

      --avis de paiement, creation du dossier au 1er sinistre uniquement
      IF :NEW.codevefac IN(50,60) AND loc_dossier=0 THEN

        SELECT numfact,datfact INTO loc_numfact ,loc_datfact
        FROM suivi_fact_tpe
        WHERE idfactpe = :new.idfactpe
        AND numremise_import=:NEW.numremise
        AND codevefac = :NEW.codevefac;

        loc_dossier:= PK_CALCUL_DOSSIER.F_LIQ_DOSSIER(:new.refcie,:new.numremise,loc_numfact,loc_datfact);

        IF loc_dossier = 0 THEN
          RAISE exc_dossier_inconnu;
        ELSIF loc_dossier =-1 THEN
          RAISE exc_rej_technique;
        END IF;


      ELSIF :NEW.codevefac NOT IN(50,60) THEN
        loc_dossier :=Rec_C_dossier_sante.num_dossier;
        UPDATE dossier_sante
        SET numremise_sntrprt = :new.numremise
        WHERE num_dossier = Rec_C_dossier_sante.num_dossier;
      END IF;

      --transcodification porte 2 pour lier les sinistres au sinistre_porte
      BEGIN
        dbms_output.put_line(':new.codfrais_porte :'||:new.codfrais_porte);

        BEGIN
          SELECT NVL(d.verre,0) || NVL(d.monture,0) || NVL(d.lentille,0),p.codfrais
          INTO loc_nature, loc_codfrais
          FROM  porte_natfrais p  left outer join  ntfrs_detail d ON (d.codfrais = p.codfrais )
          WHERE p.numporte = :new.numporte
          AND p.regime = 1
          AND p.codfrais_porte = :new.codfrais_porte;
          dbms_output.put_line('loc_nature :'||loc_nature);
          dbms_output.put_line('loc_codfrais :'||loc_codfrais);

        EXCEPTION
          WHEN no_data_found THEN
            RAISE exc_acte_inconnu;
          WHEN too_many_rows THEN
            RAISE exc_acte_inconnu;
        END;
        :NEW.codfrais:=loc_codfrais; --acte transco TPE
        loc_action:=1;
        OPEN C_sinistre_sante(loc_dossier,:new.mtprest,loc_nature,loc_codfrais) ;
        FETCH C_sinistre_sante INTO Rec_C_sinistre_sante;

        IF C_sinistre_sante%NOTFOUND THEN

          IF C_sinistre_sante%ISOPEN THEN CLOSE  C_sinistre_sante;
          END IF;

          RAISE exc_montant_diff;--montant du sinistre différent
        END IF;


        --on a trouvé au moins 1 acte de mˆme nature et montant dans le dossier de PEC

        :new.mtprestarmedi :=  Rec_C_sinistre_sante.mtprest_reel; --mise àjour du montant
        :new.codfrais :=Rec_C_sinistre_sante.codfrais;--acte transco détaillée
         dbms_output.put_line(':new.mtprest :'||:new.mtprestarmedi);
        --conditionné en fonction du type de fichier facture ou avis de paiement
        IF :NEW.codevefac IN(50,60) THEN
          :new.etat:=1; --etat calculé
        ELSE
          :new.etat:=7; --etat controllé
        END IF;
        dbms_output.put_line('update :new.numsin :'||:new.numsin);
        dbms_output.put_line('Rec_C_sinistre_sante.numligne :'||Rec_C_sinistre_sante.numligne);
        dbms_output.put_line('loc_dossier:'||loc_dossier);
        --mise à jour de la référence porte
        UPDATE sinistre_sante
        SET numsin_sntrprt =  :new.numsin
        WHERE numligne = Rec_C_sinistre_sante.numligne
        AND num_dossier = TO_CHAR(loc_dossier);


       --ABO pansement pour la création de la référence pour décompte
        IF :NEW.codevefac IN(50,60) THEN
          FOR REC_sntr_dossier IN C_sntr_dossier(loc_dossier,Rec_C_sinistre_sante.numligne)   LOOP
            INSERT INTO sntr_ref (numsin,numsin_porte,numremise,ref)
            VALUES (REC_sntr_dossier.numsin_sntr,:new.numsin,:new.numremise,:new.numremise);
            --pour prise en compte par la constitution des décomptes
            UPDATE SINISTRE SET flagam ='p'
            WHERE numsin =REC_sntr_dossier.numsin_sntr;
          END LOOP;
        END IF;

        CLOSE  C_sinistre_sante;


        --on regarde si tous les sinistres sante du dossier (de liquidation ou de PEC) ont une référence

        SELECT count(numligne)
        INTO loc_nbligne
        FROM sinistre_sante
        WHERE num_dossier = TO_CHAR(loc_dossier)
        AND numsin_sntrprt IS NULL;

        IF loc_nbligne =0  AND F_SUIVI_FACTPE(:new.idfactpe) <> 30  AND :NEW.codevefac NOT IN(50,60) THEN --uniquement si facture non rejetée
        dbms_output.put_line('loc_nbligne suivi'||F_SUIVI_FACTPE(:new.idfactpe));
          --verrou pour empecher l'annulation WS des dossiers facturés
          PK_CTRL_TP.P_INS_HISTO_DOSSIER(Rec_C_dossier_sante.num_dossier,0,6,sysdate);
          --suppression de la péremption
          DELETE histo_dossier WHERE num_dossier =Rec_C_dossier_sante.num_dossier and etat = 1 and motif = 2;
        END IF;
      END;
   EXCEPTION
      WHEN exc_dossier_inconnu THEN w_numano :=96; --705 pec inconnue
      WHEN exc_dossier_liquide THEN w_numano :=67; --697 facture déja règlée au PS
      WHEN exc_dossier_ferme THEN w_numano :=99; --706
      WHEN exc_dossier_perime THEN w_numano :=97; --706 validité expirée
      WHEN exc_montant_diff THEN w_numano :=98; --707
      WHEN exc_acte_inconnu THEN w_numano:=85; --125
      WHEN exc_rej_technique THEN w_numano:=63;--900
      WHEN OTHERS THEN w_numano:=63;

   END;
  IF w_numano>0 THEN
    --il faut rejetter tous les sinistre de la pec.
    --créer donc des sinistre ano pour tout ceux qui ont déjà été enregistré => NON car les ano concerne que ce sinistre !
    --sinistre en cours
    pk_noemie.P_INS_sinistre_ano(
      I_numporte  => :new.numporte,
      I_numano  => w_numano,
      I_numsin  => :new.numsin,
      I_datano  => Trunc(sysdate),
      I_etatano  => 1,
      I_numremise  => :new.numremise);
    IF :NEW.codevefac NOT IN(50,60) THEN
       :new.etat := 3 ;
    ELSE  :new.etat := 4 ;--ne pas calculer
    END IF;
    dbms_output.put_line('sinistre_ano :');

    -- effacer les référence externe des sinistres sante
    IF Rec_C_dossier_sante.num_dossier IS NOT NULL THEN
      IF :NEW.codevefac IN(50,60) THEN
        null;
      --  l_nb_dossier_liq:=PK_CALCUL_DOSSIER.F_ANNUL_DOSSIER_LIQ(null, Rec_C_dossier_sante.num_dossier);
      --on est en avis de paiement, les seuls cas ou on devrait rentrer la dedans sont ceux acte inconnu et montant incohérent.
      -- et si c'est passé en facture cela devrait passé en liquidation... attention néanmoins...

      ELSE
        -- Mise à jour du dossier de liquidation
        SELECT count(numligne)
        INTO loc_nbligne
        FROM sinistre_sante
        WHERE num_dossier = TO_CHAR(loc_dossier)
        AND numsin_sntrprt IS NULL;
        IF loc_nbligne <> 0 THEN
          UPDATE sinistre_sante
          SET numsin_sntrprt = NULL
          WHERE num_dossier = Rec_C_dossier_sante.num_dossier;
          Rec_C_dossier_sante.numremise_sntrprt:=NULL;--cas erreur technique
        END IF;
      END IF;
    END IF;
  ELSE
    loc_action:=1;
  END IF;

  IF C_sinistre_sante%ISOPEN THEN CLOSE  C_sinistre_sante;
  END IF;
  IF C_Dossier_sante%ISOPEN THEN CLOSE  C_dossier_sante;
  END IF;

END IF;
/* CTT 05/09/2006 : Suppression du controle sur la saisie manuelle, ce test est déporté vers
le calcul des prestations (comm_gs19) */
-------------------------------------------------------------------------------------------------------------------
--TPE debut
-- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE

IF :NEW.codevefac = 10 THEN
  l_codevefac := f_suivi_factpe_prec(:NEW.idfactpe, :NEW.numremise);
  -- CTT 19/12/2005
  -- 10,20,30,40 déjà reçue, en cours de traitement
  -- 50,60 déjà payée
  -- 35 Rejetée (sur bordereau, on pourrait aussi controler la date de transmission si elle
  --        correspondait vraiment à la transmission du fichier...)
  --            on considère que cette facture est une nouvelle demande d'acceptation
  If (l_codevefac = 10 or l_codevefac = 20 or l_codevefac = 30 or l_codevefac = 40) then
    pk_noemie.P_INS_sinistre_ano(
                   I_numporte      => :new.numporte,
                  I_numano        => 87,
                  I_numsin        => :new.numsin,
                  I_datano        => Trunc(sysdate),
                  I_etatano       => 1,
                  I_numremise     => :new.numremise);
    :new.etat := 3 ;
  ElsIf (l_codevefac = 50 or l_codevefac = 60) then
    pk_noemie.P_INS_sinistre_ano(
                   I_numporte      => :new.numporte,
                  I_numano        => 67,
                  I_numsin        => :new.numsin,
                  I_datano        => Trunc(sysdate),
                  I_etatano       => 1,
                  I_numremise     => :new.numremise);
    :new.etat := 3 ;

  End if;

  --PK_TRACE.P_INS_journal_adm('TEST_TPE', 0, 0, 'Datfact', SYSDATE,  F_NEXT_idligne(0));
  BEGIN
    SELECT datfact
    INTO l_datfact
    FROM suivi_fact_tpe
    WHERE idfactpe = :NEW.idfactpe
    AND codevefac = :NEW.codevefac
    AND numremise_import = :NEW.numremise;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN l_no_data_1 := TRUE;
    --WHEN TOO_MANY_ROWS THEN RAISE_APPLICATION_ERROR(-20001,'Doublon dans le fichier des factures !'); -- mettre en commentaire pour laisser passer l'import
    WHEN TOO_MANY_ROWS THEN l_datfact := null ;                                                         --  pour laisser passer l'import
  END;
  --
  /* CTT 30/05/2006 : Suppression du contrôle de la date de naissance (date "lunaire" éventuelle !)
  DECLARE
    l_datnais_indiv DATE;
   --  CTT 11/01/2006 : on ne limite plus le contrôle au niveau du jour dans le mois,
   -- toute erreur de cohérence provoque le rejet technique sur date.
   -- e_date_fausse EXCEPTION;
   -- PRAGMA EXCEPTION_INIT ( e_date_fausse, -01847 );
  BEGIN
    SELECT TO_DATE ( :NEW.datnais_indiv, 'DDMMYY' )
    INTO l_datnais_indiv
    FROM DUAL;
  EXCEPTION
    WHEN OTHERS THEN l_date_fausse := TRUE;
  END; */
  --
  --Code 63 REJET TECHNIQUE
  IF ( l_datfact IS NULL
  OR l_datfact > SYSDATE )
  AND l_no_data_1 = FALSE THEN
    pk_noemie.P_INS_sinistre_ano(
                   I_numporte      => :new.numporte,
                  I_numano        => 63,
                  I_numsin        => :new.numsin,
                  I_datano        => Trunc(sysdate),
                  I_etatano       => 1,
                  I_numremise     => :new.numremise);
    :new.etat := 3 ;
  END IF;

  --
  -- CTT 01/03/06 (fiche 403) : contrôles via la fonction f_idcvrt possibles si l'assuré et le code frais sont connus
  -- CTT 10/03/06 (fiche 403) : Distinction entre garantie santé et acte garanti à la date des soins
  -- CTT 19/05/06 (fiche 405) : Ajout de la condition "à calculer" (B. Cotteblanche)
  IF (:new.numassu > 0 ) AND (:new.codfrais IS NOT NULL) AND loc_action = 1 THEN
    -- CTT 03/04/2006 Test sur attestation TPE (fiche 419)
    -- Code 92 : Pas d'attestation TPE pour cet acte (Erreur CETIP devient 651 au lieu de 413 : 07/06/2006)
    -- CTT 07/06/06 (fiche 419) : Le contrôle est effectué si l'assuré et le code frais sont connus et que la prestation est à calculer
    -- CTT 29/08/06 CTT : Suite à remarque de B. Cotteblanche (mail 20/07/2006) test supplémentaire sur numindiv
    -- JBO 09/10/2012 : Ajout de la catégorie dans pk_porte.f_carte_tp pour la gestion des centres de santé
   -- IF ( pk_porte.f_carte_tp(:new.numassu, :new.codfrais, :new.datsin, 0, :new.numporte, :new.categorie) = 0 ) then

      IF ( pk_porte.f_carte_tp(:new.numindiv, :new.codfrais, :new.datsin, 0, :new.numporte, :new.categorie, l_tabCond) = 0 ) then
          pk_noemie.P_INS_sinistre_ano(
                         I_numporte      => :new.numporte,
                        I_numano        => 92,
                        I_numsin        => :new.numsin,
                        I_datano        => Trunc(sysdate),
                        I_etatano       => 1,
                        I_numremise     => :new.numremise);
          :new.etat := 3 ;
      END IF;
   -- END IF;
    --
    -- CTT 10/03/06 (fiche 410) : Le test sur la date de prescription n'a pas été retenu dans le cahier des charges V3
    -- Code 69 Periode de validite prescription : Cetip 122
    /*IF f_idcvrt ( :NEW.numindiv, :NEW.codfrais, :NEW.datpresc ) IS NULL THEN
    pk_noemie.P_INS_sinistre_ano(
                   I_numporte      => :new.numporte,
                  I_numano        => 69,
                  I_numsin        => :new.numsin,
                  I_datano        => Trunc(sysdate),
                  I_etatano       => 1,
                  I_numremise     => :new.numremise);
    :new.etat := 3 ;
    END IF;*/

    IF f_cvrtsante ( :NEW.numindiv, :NEW.datsin ) = 0 THEN
    --Code 46 : aucune garantie active à la date des soins : Cetip 122
    pk_noemie.P_INS_sinistre_ano(
             I_numporte      => :new.numporte,
            I_numano        => 46,
            I_numsin        => :new.numsin,
            I_datano        => Trunc(sysdate),
            I_etatano       => 1,
            I_numremise     => :new.numremise);
    :new.etat := 3 ;

      -- JBO M3900 : vérification de l état de la garantie entre la date de PEC et la facturation
      -- si une aucune garantie n'est couverte uniquement à la facturation, on supprime l anomalie 46 (Aucune garantie active à la date des soins)
      -- afin de permettre à l AMC de récupérer l argent
      IF TRIM(loc_dossier_resil) IS NOT NULL THEN

        SELECT COUNT(*)
          INTO loc_ano_resil
          FROM sinistre_ano
         WHERE numremise=:new.numremise
           AND numsin=:new.numsin
           AND numporte=:new.numporte
           AND etatano=1
           AND numano=46;
/*
        pk_trace.p_ins_journal_adm ('TRG_BF_INS_SINISTRE_PORTE', sid,3,
                                  'COUNT(*) loc_ano_resil :'||to_char(loc_ano_resil)||',:new.etat:'||to_char(:new.etat)||',:new.numporte:'||to_char(:new.numporte),SYSDATE,3
                                 );
*/
        IF loc_ano_resil > 0 THEN
          delete sinistre_ano
           where numremise=:new.numremise
             and numsin=:new.numsin
             and numporte=:new.numporte
             and etatano=1
             and numano=46;
          :new.etat := 2; -- on met la prestation a l etat 2 'A calculer'
        END IF; -- IF loc_ano_resil > 0 THEN
      END IF; -- IF TRIM(loc_dossier_resil) IS NOT NULL THEN



    ELSE
      BEGIN
        --Code 91: Acte non couvert  à la date des soins : Cetip 122
        IF f_idcvrt ( :NEW.numindiv, :NEW.codfrais, :NEW.datsin ) IS NULL THEN
          pk_noemie.P_INS_sinistre_ano(
                 I_numporte      => :new.numporte,
                I_numano        => 91,
                I_numsin        => :new.numsin,
                I_datano        => Trunc(sysdate),
                I_etatano       => 1,
                I_numremise     => :new.numremise);
          :new.etat := 3 ;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
         pk_noemie.P_INS_sinistre_ano(
            I_numporte      => :new.numporte,
            I_numano        => 46,
            I_numsin        => :new.numsin,
            I_datano        => Trunc(sysdate),
            I_etatano       => 1,
            I_numremise     => :new.numremise);
        :new.etat := 3 ;
      END;
    END IF;
  END IF;

  --Code 65 Date des soins : REJET TECHNIQUE
  IF :NEW.datsin > l_datfact
  AND l_no_data_1 = FALSE THEN
  pk_noemie.P_INS_sinistre_ano(
           I_numporte      => :new.numporte,
          I_numano        => 65,
          I_numsin        => :new.numsin,
          I_datano        => Trunc(sysdate),
          I_etatano       => 1,
          I_numremise     => :new.numremise);
  :new.etat := 3 ;
  END IF;
  --Code 66 Date naissance benef fausse : REJET TECHNIQUE
 /* CTT 30/05/2006 : Suppression du controle de la date de naissance (date "lunaire" éventuelle !)
   IF l_date_fausse = TRUE THEN
  pk_noemie.P_INS_sinistre_ano(
           I_numporte      => :new.numporte,
          I_numano        => 66,
          I_numsin        => :new.numsin,
          I_datano        => Trunc(sysdate),
          I_etatano       => 1,
          I_numremise     => :new.numremise);
  :new.etat := 3 ;
  END IF;*/
END IF; -- :NEW.codevefac = 10
--
IF (:NEW.codevefac = 50) THEN
      l_codevefac := f_suivi_factpe_prec(:NEW.idfactpe, :NEW.numremise);
    -- CTT 19/12/2005
    -- 10,20,30,35 : en cours de traitement
    -- 50,60 : déjà payée
    -- 0   : avis de paiement sur facture inconnue (ou à  null ...Fiche 390)
    If (l_codevefac = 10 or l_codevefac = 20 or l_codevefac = 30 or l_codevefac = 35 ) then
      pk_noemie.P_INS_sinistre_ano(
                     I_numporte      => :new.numporte,
                    I_numano        => 87,
                    I_numsin        => :new.numsin,
                    I_datano        => Trunc(sysdate),
                    I_etatano       => 1,
                    I_numremise     => :new.numremise);
      :new.etat  := 3 ;
      l_vrai_ano := TRUE;
    Elsif (l_codevefac = 50 or l_codevefac = 60) then
      pk_noemie.P_INS_sinistre_ano(
                     I_numporte      => :new.numporte,
                    I_numano        => 82,
                    I_numsin        => :new.numsin,
                    I_datano        => Trunc(sysdate),
                    I_etatano       => 1,
                    I_numremise     => :new.numremise);
      :new.etat  := 3 ;
      l_vrai_ano := TRUE;
    Elsif (l_codevefac = 0 or l_codevefac is null) then
      pk_noemie.P_INS_sinistre_ano(
                     I_numporte      => :new.numporte,
                    I_numano        => 83,
                    I_numsin        => :new.numsin,
                    I_datano        => Trunc(sysdate),
                    I_etatano       => 1,
                    I_numremise     => :new.numremise);
      :new.etat := 3 ;
      l_vrai_ano := TRUE;
    End if;

ELSIF (:NEW.codevefac = 60) THEN
      l_codevefac := f_suivi_factpe_prec(:NEW.idfactpe, :NEW.numremise);
    -- CTT 19/12/2005
    -- 50,60 : déjà payée
    -- 0     : avis de paiement sur facture inconnue (ou à  null ...Fiche 390)
    If (l_codevefac = 50 or l_codevefac = 60) then
      pk_noemie.P_INS_sinistre_ano(
                     I_numporte      => :new.numporte,
                    I_numano        => 82,
                    I_numsin        => :new.numsin,
                    I_datano        => Trunc(sysdate),
                    I_etatano       => 1,
                    I_numremise     => :new.numremise);
      :new.etat := 3 ;
      l_vrai_ano := TRUE;
    Elsif (l_codevefac = 0 or l_codevefac is null) then
      pk_noemie.P_INS_sinistre_ano(
                     I_numporte      => :new.numporte,
                    I_numano        => 83,
                    I_numsin        => :new.numsin,
                    I_datano        => Trunc(sysdate),
                    I_etatano       => 1,
                    I_numremise     => :new.numremise);
      :new.etat := 3 ;
      l_vrai_ano := TRUE;
    End if;
--
END IF; -- :NEW.codevefac = 50 OR :NEW.codevefac = 60


-- CTT 19/05/2006 : Suivi de facture TPE en cas d'erreur...
-- CTT 12/09/2006 : mais pour éviter les incohérences, on ne gère plus
-- les erreurs lorsqu'il s'agit de paiements
-- 20061003 Ano spécifique au paiement (B.Cotteblanche)
IF :new.codevefac is not null THEN
  IF :new.etat = 3 THEN
    IF (:new.codevefac = 50 or :new.codevefac = 60) THEN
       IF l_vrai_ano = FALSE THEN
           :new.etat := 2;
       END IF ;
    ELSE
      -- JBO : 26/03/2013 : M3878
      -- Si une facture est rejetée, il faut suprimer le motif du dossier "Dossier en cours de facturation"
      -- et remettre le dossier en état
      -- JBO : 26/03/2013 : M3878
      -- Si une facture est rejetée, il faut suprimer le motif du dossier "Dossier en cours de facturation"
      -- et remettre le dossier en état
      IF :NEW.codevefac= 10 AND :NEW.etat = 3 AND TRIM(:new.refcie) IS NOT NULL THEN
        --PK_trace.P_INS_journal_adm ('M3878', SID, 3, 'new.refcie:'||:new.refcie||'new.numremise:'||:new.numremise);
        --PK_trace.P_INS_journal_adm ('M3878', SID, 3, 'new.codevefac:'||:new.codevefac);
        -- Recherche du dossier à mettre à jour
        SELECT NVL(MAX(num_dossier),0), MAX(d.creation)
          INTO loc_dossier_PEC, loc_dossier_creat
          FROM dossier_sante d
         WHERE d.ref_dossier = TRIM(:new.refcie)
           AND d.numindiv=:new.numindiv
           AND d.numremise_sntrprt=:new.numremise -- à conserver au cas où plusieurs pec
		   AND d.num_dossier_pec IS NULL
           AND d.type_doss = 4;
        IF loc_dossier_PEC > 0 THEN
          -- Si le dossier est déjà facturé ou dossier avec un sinistre bloqué
			--> on met à jour l'historique au lieu de le supprimer motif 6(Dossier en cours de facturation 687)
			--Remise en place du délai de la péremption, motif 2 (Prise en charge périmée) dans l'historique du dossier santé
      UPDATE histo_dossier SET motif=2 , etat =1, debut= ADD_MONTHS(loc_dossier_creat,F_SENS_LIBELLE('HISTO_D1', 2))

			WHERE num_dossier=loc_dossier_PEC AND motif=6 AND etat =0;
            -- Mise à blanc du numsin_sntrprt de sinistre_sante
            UPDATE sinistre_sante SET numsin_sntrprt=NULL WHERE num_dossier=loc_dossier_PEC;
            -- Mise à blanc du numremise_sntrprt de dossier_sante
            UPDATE dossier_sante SET numremise_sntrprt=NULL WHERE num_dossier=loc_dossier_PEC;
           -- PK_trace.P_INS_journal_adm ('M3878', SID, 3, 'loc_dossier_PEC :'||loc_dossier_PEC);
        END IF;
      END IF;
      histo_suivi_fact_tpe;
    END IF;
  END IF;
END IF;--TPE fin
--
-- Gestion Euro / Franc
If ( :new.codmon != pk_devise.devise_ref ) then
  pk_noemie.P_CONV_devise_ref (
    I_codmon  =>  :new.codmon,
    I_mtfrais  =>  :new.mtfrais,
    I_baseremb  =>  :new.baseremb,
    I_mtremb  =>  :new.mtremb,
    I_autrb    =>  :new.autrb,
    I_mtprest  =>  :new.mtprest,
    O_mtfrais  =>  :new.mtfrais,
    O_baseremb  =>  :new.baseremb,
    O_mtremb  =>  :new.mtremb,
    O_autrb    =>  :new.autrb,
    O_mtprest  =>  :new.mtprest
    );
  :new.codmon := pk_devise.devise_ref;
End if;

/* MUR M0006442 doublon dentaire */
if :new.numporte = 1 then
	loc_list_dent :=  :new.LOCDENT1  ||','
				   || :new.LOCDENT2  ||','
				   || :new.LOCDENT3  ||','
				   || :new.LOCDENT4  ||','
				   || :new.LOCDENT5  ||','
				   || :new.LOCDENT6  ||','
				   || :new.LOCDENT7  ||','
				   || :new.LOCDENT8  ||','
				   || :new.LOCDENT9  ||','
				   || :new.LOCDENT10 ||','
				   || :new.LOCDENT11 ||','
				   || :new.LOCDENT12 ||','
				   || :new.LOCDENT13 ||','
				   || :new.LOCDENT14 ||','
				   || :new.LOCDENT15 ||','
				   || :new.LOCDENT16 ;

	if F_CTRL_DOUBLON_DENT( :new.numindiv,loc_list_dent ,ADD_MONTHS(sysdate, -24),:new.codfrais,null,null) = 1 then
	  pk_noemie.P_INS_sinistre_ano(I_numporte      => :new.numporte,
								                 I_numano        => 100,
												         I_numsin        => :new.numsin,
												         I_datano        => Trunc(sysdate),
												         I_etatano       => 1,
												         I_numremise     => :new.numremise);
	  if :new.etat = 2 then :new.etat := 3  ; end if ;
	end if ;
end if ;

END;