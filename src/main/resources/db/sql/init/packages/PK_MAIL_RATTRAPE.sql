CREATE OR REPLACE PACKAGE ARTHUS.PK_MAIL_RATTRAPE IS

/*---------------------------------------------------------------------------*/
/* Pakcage jetable créé pour les rattrapage des mail automatiques GEREP      */
/* des 4, 5, 6 novembre 2020                                                 */
/*                                                                           */
/* Mantis assistance M0006957                                                */
/*                                                                           */
/*---------------------------------------------------------------------------*/


PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

PROCEDURE P_RATTRAP_MAIL_MASSE(p_dat_pivot date);

PROCEDURE P_RATTRAP_DCPT(p_dat_pivot date);
PROCEDURE P_RATTRAP_DCPT_PREV(p_dat_pivot date);
PROCEDURE P_RATTRAP_PIECE(p_dat_pivot date);
PROCEDURE P_RATTRAP_CARTE_TP(p_dat_pivot date);
PROCEDURE P_RATTRAP_ADH_INSTANCE(p_dat_pivot date);
PROCEDURE P_RATTRAP_ADHESION_VIGUEUR(p_dat_pivot date);
PROCEDURE P_RATTRAP_ADHESION_OPTION(p_dat_pivot date);
PROCEDURE P_RATTRAP_RUM(p_dat_pivot date);
PROCEDURE P_RATTRAP_VCOTIS(p_dat_pivot date);
PROCEDURE P_RATTRAP_PB2B(p_dat_pivot date);
PROCEDURE P_RATTRAP_RESIL(p_dat_pivot date);

PROCEDURE P_SEND_ALL_MAIL_JOB_RATTRAP (p_type_mail IN NUMBER, p_dat_pivot DATE);
 PROCEDURE CREER_MAIL_RATTRAP( I_envoi_mail IN OUT ENVOI_MAIL%ROWTYPE,
                      p_desactiv_ctrl_doublon IN VARCHAR2  DEFAULT 'N', p_dat_pivot date);


END PK_MAIL_RATTRAPE;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_MAIL_RATTRAPE IS

/*---------------------------------------------------------------------------*/
/* Pakcage jetable créé pour les rattrapage des mail automatiques GEREP      */
/* des 4, 5, 6 novembre 2020                                                 */
/*                                                                           */
/* Mantis assistance M0006957                                                */
/*                                                                           */
/*---------------------------------------------------------------------------*/


 -- -- Déclaration des variables globales   ----------------------------------
  g_session         journal_adm.id_session%TYPE DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:='MAIL_RATTRAP';
  g_niv_msg         journal_adm.niv_msg%TYPE;
  g_idligne         journal_adm.idligne%TYPE default 0;
  g_msg_adm         journal_adm.msg_adm%TYPE;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans journal_adm                                */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS

BEGIN

    g_idligne := g_idligne +1;
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => g_nom_traitement,
        I_session  => NVL(g_session, sid),
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => g_idligne);

END P_INS_journal;



PROCEDURE P_RATTRAP_MAIL_MASSE(p_dat_pivot date) IS


BEGIN

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_MAIL_MASSE',
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  ' début traitement' || d2e(p_dat_pivot), 
                               I_idligne  => 1);

  -- Rattrapage GEREP uniquement
  IF F_CLIENT  = 4 THEN 

    P_RATTRAP_DCPT(p_dat_pivot);
    P_RATTRAP_PIECE(p_dat_pivot);
    P_RATTRAP_DCPT_PREV(p_dat_pivot);
    P_RATTRAP_CARTE_TP(p_dat_pivot);
    P_RATTRAP_ADH_INSTANCE(p_dat_pivot);
    P_RATTRAP_ADHESION_OPTION(p_dat_pivot);
    P_RATTRAP_ADHESION_VIGUEUR(p_dat_pivot);
     -- PK_WS_WEB_MAJ_BACK.P_MAIL_INTERLOCUTEUR(p_dat_pivot); Pas de rattrapage car n'emet des mails que le lundi et/ou le 10 du mois
    P_RATTRAP_RUM(p_dat_pivot);
    P_RATTRAP_VCOTIS(p_dat_pivot);
    P_RATTRAP_PB2B(p_dat_pivot);   
  END IF;

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_MAIL_MASSE',
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  ' Fin traitement' || d2e(p_dat_pivot), 
                               I_idligne  => 1);


END;



/*============================================================================*/
/* Auteur       : ABO                                                         */
/* Création     : 27/04/2017                                                  */
/* Description  : Insertion des demandes de pièces dans la                    */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux assurés par un job                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : PBO M0006252 ajout des adhésions dans le futur validées RH  */
/*                et Gerep                                                    */
/*============================================================================*/
PROCEDURE P_RATTRAP_ADH_INSTANCE(p_dat_pivot date) IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;

  CURSOR c_adh_instance IS
      SELECT   adc.idadhesion, adc.numadhe, adc.date_adhe, c.numgar  -- PBO M006252
         FROM ADHESION ad , adhe_cntrt adc, contrat c , histo_adhesion had,  gar_cntrt gcnt, courrier_info cour, formule f
          WHERE adc.idadhesion = ad.idadhesion
          AND had.idadhesion = ad.idadhesion
          AND cour.numindiv = adc.numadhe
          AND f.numfor = ad.numfor
          AND gcnt.NUMFOR = ad.NUMFOR
          AND c.numgar = adc.numgar
          AND cour.type_crrr = 28 -- individu dématerialisé
          AND cour.moyen_info = 2
          AND f.typgar = 1 -- garantie de base
          AND gcnt.type = 1 -- SANTE
          AND trunc(had.datsai) = trunc(p_dat_pivot-2) -- permet de prendre les adhesions saisie il a 3 jours
          AND NOT EXISTS (SELECT clef FROM envoi_mail em WHERE em.numindiv_dest = adc.numadhe AND em.etendue = 2  AND em.idtexte in (5,11,24)) --mail pas déjà envoyé
          AND c.gest_prest = 1  --prestations gérées
          AND ad.typfor = 1 --couverture santé
          AND ad.rang=1 --non surco
          AND adc.date_adhe >= trunc(p_dat_pivot-2)  -- adhesion creer dans le futur par rapport a il y a 3 jours
          AND (ad.datper is  null OR trunc(ad.datper) > trunc(ad.DATAPLI))
          AND PK_WS_WEB_BACK.F_ETAT_ADHE_WS(ad.idadhesion, p_dat_pivot) = 0 -- adhesion en instance a ce jour -- hotfix M0006343
          and had.motif not in (58,59,60) -- MUR hotfix
          AND NOT EXISTS (SELECT *      -- verification des transfert des contrats
              FROM ADHESION  a, CONTRAT c1, formule f1
              WHERE a.numindiv = ad.numindiv
                AND c1.numgar = a.numgar
                AND a.idadhesion <> ad.idadhesion
                AND f1.numfor = a.numfor
                AND f1.typgar = f.typgar -- contrainte sur le même type de garantie que l'adhésion créée
                AND c1.gest_prest = 1  --prestations gérées
                AND a.typfor = 1 --couverture santé
                AND (p_dat_pivot BETWEEN a.datapli AND NVL(a.datper,p_dat_pivot) --couverture en cours
                    OR (a.datper IS NOT NULL AND add_months(a.datper,6) > p_dat_pivot)  --couverture datant de moins de 6 mois
                --  OR (a.datapli> sysdate) --couverture dans le futur
                    OR (a.datper is not null and a.maj > p_dat_pivot-7 )))  --cloture de la garantie précedente datant de moins de 7 jours	
      -- PBO M0006252 on ajoute les adhésions dans le futur validée RH et Gerep            
     UNION
      SELECT distinct datas.idadhesion,
             datas.numadhe,
             a1.date_adhe,
             c.numgar
         FROM(     
          SELECT distinct adhe_cntrt.numadhe, adhe_cntrt.idadhesion,adhe_cntrt.date_adhe,c.numgar 
           FROM  histo_adhesion, 
                 adhe_cntrt, 
                 adhesion ad , 
                 contrat c 
              WHERE 
                 histo_adhesion.IDADHESION = adhe_cntrt.IDADHESION 
                 AND adhe_cntrt.IDADHESION = ad.IDADHESION 
                 AND c.NUMGAR = ad.NUMGAR 
                 AND histo_adhesion.etat   =1    -- Adhésion en vigueur
                 AND trunc(DATSAI) >= trunc(p_dat_pivot-1)  	-- Saisie la veille
                 AND TRUNC(DEBUT) > TRUNC(p_dat_pivot)		-- Adhesion dans le futur uniquement
                 AND histo_adhesion.motif = 57			-- Affiliation pré-aff validée par Gerep
                 AND c.gest_prest = 1  
                 AND ad.typfor = 1 
                 AND ad.rang=1   
                 AND greatest(adhe_cntrt.date_adhe,p_dat_pivot) between datapli and nvl( datper,greatest(adhe_cntrt.date_adhe,p_dat_pivot))   
                 AND NOT EXISTS (                           --mail pas déjà envoyé
                            select 1 from envoi_mail 
                            where numindiv_dest = adhe_cntrt.numadhe 
                            and idtexte in(5,24) 
                           ) 
                 AND NOT EXISTS( 
                            select * from adhe_cntrt ad_ante 
                            where ad_ante.IDADHESION <> adhe_cntrt.IDADHESION 
                            and ad_ante.numadhe = adhe_cntrt.numadhe 
                            and ad_ante.DATE_ADHE < adhe_cntrt.DATE_ADHE 
                            and  p_dat_pivot between  ad_ante.DATE_ADHE and nvl(add_months(ad_ante.DATE_FIN_ADHE,6),p_dat_pivot) 
                            ) 
             ) datas      
              ,adhe_cntrt a1, contrat c,produit p 
               where datas.idadhesion = a1.idadhesion 
               and a1.numgar = c.numgar 
               and c.numprod = p.numprod
        ;


BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADH_INSTANCE',
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  ' début traitement' || d2e(p_dat_pivot), 
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('AINST',F_NUMUTIL) THEN
    FOR  rec_adh_instance   IN  c_adh_instance  LOOP
     PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADH_INSTANCE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  ' autorisation de creation de mail pour numindiv '||rec_adh_instance.numadhe,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_adh_instance.numadhe;
      loc_envoi.NUMBENE:=rec_adh_instance.numadhe;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=2;     -- adhesion
      loc_envoi.clef:= rec_adh_instance.idadhesion;
      loc_envoi.IDTEXTE:= 24;   --  mail de bienvenue
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
      loc_envoi.TEMPLATE_MAIL:= 3; -- Template mail de bienvenue
      io_envoi:=loc_envoi;

       PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADH_INSTANCE',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);


    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADH_INSTANCE',
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  ' fin traitement' || d2e(p_dat_pivot), 
                               I_idligne  => 1);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADH_INSTANCE',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_RATTRAP_ADH_INSTANCE;
    /*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : CLI                                                         */
/* Description  : Insertion des Cartes TP pour envoi de mail                  */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :  14/11/2017                                                 */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_RATTRAP_CARTE_TP(p_dat_pivot date) IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_sujet       ENVOI_MAIL.sujet%type;
  loc_corps       ENVOI_MAIL.corps%type;
  l_JOUR  VARCHAR2(8);
  l_date_debut DATE;
  L_date_fin DATE;
  l_date_du_jour date := p_dat_pivot;

  CURSOR c_carte_tp IS
      SELECT re.date_remise,re.numremise,adhe.NUMADHE, dtpad.debut, dtpad.fin, pa.IDADHESION
      FROM remise_externe re, porte_adhesion pa, adhe_cntrt adhe, demande_tp_ad dtpad , courrier_info ci
      WHERE re.numremise  = pa.NUMREMISE
        AND ci.numindiv   = adhe.NUMADHE
        AND re.valide = 'O'
        AND ci.type_crrr = 50 -- courrier info de la carte tp
        AND ci.moyen_info = 2 -- en demat
        AND re.numporte   = 2
        AND re.nature     = 3
        AND adhe.NUMADHE  = pa.numindiv -- On envoi un mail par adhérent, donc 2 mails en cas d'adhésion croisées.
        AND adhe.idadhesion  = pa.idadhesion
        AND dtpad.IDPORTE = pa.IDPORTE
        AND trunc (re.date_trans) between l_date_debut and l_date_fin -- on générer les mail sur les carte tp transmises il y a 3 jours  ouvré
        AND dtpad.debut IS NOT NULL
        AND NOT EXISTS(
          SELECT numindiv_dest
          FROM envoi_mail
          where numindiv_dest =adhe.NUMADHE
          AND idtexte = 23
          AND etat in( 0,1)
          AND datemis>re.date_trans) ;

BEGIN

--Cas pratique
--Ma remise est transmise le samedi 13. Quand dois-je envoyer le mail ? (Mercredi 17? Jeudi 18?) ou autre Mardi
--Ma remise est transmise le vendredi 12. Quand dois-je envoyer le mail ? ( Mardi 16? Mercredi 17?) ou autre Mardi
--Ma remise est transmise le Jeudi 11. Quand dois-je envoyer le mail ? (Lundi 15? Mardi 16?) ou autre Lundi
    l_jour:=TO_CHAR(l_date_du_jour, 'DAY', 'NLS_DATE_LANGUAGE=French');
     CASE
     WHEN trim(l_JOUR)IN('MARDI') THEN
      l_date_debut:= l_date_du_jour - 4;-- on prend le vendredi
      L_date_fin := l_date_du_jour - 3 ;  -- et le samedi
      --dbms_output.put_line(' on prend les carte tp transférées entre '||l_date_debut||' et '|| l_date_fin);
    WHEN trim(l_JOUR)IN('LUNDI') THEN
      l_date_debut := l_date_du_jour - 4;-- on prend le Jeudi
      L_date_fin   := l_date_debut;  -- et seulement le jeudi
    WHEN trim(l_JOUR)IN('MERCREDI', 'DIMANCHE') THEN
      l_date_debut := null;-- on prend le Jeudi
      L_date_fin   := null;  -- et seulement le jeudi
    ELSe
    l_date_debut := trunc(l_date_du_jour - 3);-- on prend trois jours glissant
      L_date_fin   := l_date_debut;
    null;

    END CASE;

   --  dbms_output.put_line('Cas '||l_JOUR||' '||l_date_du_jour ||' on prend les carte tp transférées entre '
   -- ||TO_CHAR(l_date_debut, 'DAY', 'NLS_DATE_LANGUAGE=French')
   -- ||' '||l_date_debut||' et '||TO_CHAR(l_date_fin, 'DAY', 'NLS_DATE_LANGUAGE=French')||' '|| l_date_fin);

--Determiner la date du jour pour determiner carte tp a prendre en compte
 PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_CARTE_TP',
                              I_session  => SID,
                              I_niv_msg  => 1, 
                              I_msg_adm  =>  'P_RATTRAP_CARTE_TP : début traitement ' || d2e(p_dat_pivot),
                              I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('CRTP',F_NUMUTIL) THEN

      SELECT corps_msg, sujet_msg
        INTO loc_corps,loc_sujet
        FROM mail_texte
        WHERE id_texte = 23; --loc_envoi.idtexte;

    FOR  rec_carte_tp  IN      c_carte_tp  LOOP
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_CARTE_TP',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_RATTRAP_CARTE_TP : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST   := rec_carte_tp.NUMADHE;
      loc_envoi.NUMBENE         := rec_carte_tp.NUMADHE;
      loc_envoi.NUMUTIL         := F_NUMUTIL;
      loc_envoi.etendue         := 2;   -- Carte Tp
      loc_envoi.clef            := rec_carte_tp.IDADHESION;
      loc_envoi.IDTEXTE         := 23;  -- votre carte tp  #ANNEE est disponibles sur l'extranet...
      loc_envoi.TYPE_MAIL       := 3;   -- Automatique
      loc_envoi.DATE_CREATION   := SYSDATE;

      -- valorisation de la date dans le message
      loc_envoi.sujet := replace(loc_sujet,'#ANNEE',to_char(to_date(rec_carte_tp.debut),'YYYY'));
      loc_envoi.corps := replace(loc_corps,'#ANNEE',to_char(to_date(rec_carte_tp.debut),'YYYY'));
      io_envoi:=loc_envoi;
      --  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_CARTE_TP',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_RATTRAP_CARTE_TP : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;
  END IF;

 PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_CARTE_TP',
                              I_session  => SID,
                              I_niv_msg  => 1, 
                              I_msg_adm  =>  'P_RATTRAP_CARTE_TP : fin traitement ' || d2e(p_dat_pivot),
                              I_idligne  => 1);

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_CARTE_TP',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_RATTRAP_CARTE_TP;


/*============================================================================*/
/* Auteur       : JBO                                                         */
/* Création     : JBO                                                         */
/* Description  : Insertion des décomptes virement soins santé édités dans la */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux assurés par un job                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_RATTRAP_DCPT(p_dat_pivot date) IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_date_pivot DATE := p_dat_pivot -1;
  CURSOR c_decpt_sante_vir
      IS

	SELECT max(decompte.NUMDEC ) numdec,
         sum(decompte.MONTANT_D) somme,
         decompte.NUMINDIV
    FROM decompte, affectation, decaismt
    WHERE decaismt.codope =affectation.codope
      AND affectation.codope =1
      AND affectation.numaffec = decompte.numdec
      AND affectation.numdecaismt = decaismt.NUMDECAISMT
      AND decaismt.datpay IS NOT NULL
    --AND decompte.numdec >0
      AND decaismt.MODPMT IN  (2,7) -- virement et virement manuel   (MOPM)
      AND decaismt.REFPMT > 0
      AND to_char(decaismt.DATPAY,'DD/MM/YYYY') =to_char(loc_date_pivot,'DD/MM/YYYY')
      AND decaismt.FLAGPAY =1
      AND decompte.typbene=1
      AND (EXISTS(SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv = decompte.numindiv)  OR F_CLIENT = 12)-- on fait sauter la condition pour welcare
      group by  decompte.NUMINDIV;



BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT', 
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  'P_RATTRAP_DCPT : début traitement ' || d2e(p_dat_pivot),
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('DCPT',F_NUMUTIL) THEN
    FOR  rec_decpt_sante_vir  IN      c_decpt_sante_vir  LOOP

     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_RATTRAP_DCPT : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_decpt_sante_vir.NUMINDIV;
      loc_envoi.NUMBENE:=rec_decpt_sante_vir.NUMINDIV;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=28;     -- Décompte soins de santé
      loc_envoi.clef:= rec_decpt_sante_vir.NUMDEC;
      loc_envoi.IDTEXTE:= 10;    -- Nous vous informons qu''un décompte soins de santé est disponible sur votre espace assuré(MAIL_TEXTE.ID_TEXTE =10)
    -- valorisation des décomptes
      SELECT corps_msg, sujet_msg
    	  INTO loc_envoi.corps,loc_envoi.sujet
    	  FROM mail_texte
    	  WHERE id_texte = loc_envoi.idtexte;
      loc_envoi.corps := replace(loc_envoi.corps, '#SOMME', trim(to_char(rec_decpt_sante_vir.somme, 9999999.99)));
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_RATTRAP_DCPT : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;
  END IF;

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT', 
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  'P_RATTRAP_DCPT : fin traitement ' || d2e(p_dat_pivot),
                               I_idligne  => 1);

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_RATTRAP_DCPT;
/*============================================================================*/
/* Auteur       : RKO                                                         */
/* Création     : P_RATTRAP_DCPT_PREV                                    */
/* Description  : Insertion des décomptes prevoyance dans la                  */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux interlocuteurs Utilisateur Espace Prevoyance
                  de la sociétés                                              */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_RATTRAP_DCPT_PREV(p_dat_pivot date) IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_date_pivot DATE := p_dat_pivot -1;

  CURSOR c_decpt_prev
      IS

	SELECT max(decompte_prev.NUMDEC ) numdec,
         decaismt.numdest,interlocuteur.interlocuteur
    FROM decompte_prev, affectation, decaismt, interlocuteur
    WHERE decaismt.codope =affectation.codope
      AND affectation.codope =2
      AND affectation.numaffec = decompte_prev.numdec
      AND affectation.numdecaismt = decaismt.NUMDECAISMT
      AND decaismt.datpay IS NOT NULL
      AND decaismt.MODPMT IN  (2,7) -- virement et virement manuel   (MOPM)
      AND decaismt.REFPMT > 0
      AND to_char(decaismt.DATPAY,'DD/MM/YYYY') = to_char(( loc_date_pivot),'DD/MM/YYYY')    
      AND decaismt.FLAGPAY =1
      AND interlocuteur.numindiv = decaismt.numdest
      AND f_coordonne_contact(interlocuteur.interlocuteur,4,1) IS NOT NULL
      AND interlocuteur.valide='O'
      AND ope_crrr=9 
     GROUP BY  decaismt.numdest, interlocuteur.interlocuteur
      ;


BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT_PREV', 
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  'P_RATTRAP_DCPT_PREV : début traitement ' || d2e(p_dat_pivot),
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('DCPT',F_NUMUTIL) THEN
    FOR  rec_decpt_prev  IN      c_decpt_prev  LOOP

      loc_envoi.NUMINDIV_DEST:=rec_decpt_prev.interlocuteur;
      loc_envoi.NUMBENE:=null;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=18;--Décompte soins prévoyance  
      loc_envoi.clef:= rec_decpt_prev.NUMDEC;
      loc_envoi.template_mail :=2;
      loc_envoi.IDTEXTE:= 37;    
    -- valorisation des décomptes
     /* SELECT corps_msg, sujet_msg         --RKO afin que le mail se genere sur mail pro en appelant creer_mail                                                        
    	  INTO loc_envoi.corps,loc_envoi.sujet
    	  FROM mail_texte
    	  WHERE id_texte = loc_envoi.idtexte;
      loc_envoi.corps := loc_envoi.corps;--replace(loc_envoi.corps, '#SOMME', trim(to_char(rec_decpt_prev.somme, 9999999.99))); */
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;

      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;
  END IF;

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT_PREV', 
                               I_session  => SID, 
                               I_niv_msg  => 1,   
                               I_msg_adm  =>  'P_RATTRAP_DCPT_PREV : Fin traitement ' || d2e(p_dat_pivot),
                               I_idligne  => 1);

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_DCPT_PREV',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_RATTRAP_DCPT_PREV;


/*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : P_RATTRAP_ADHESION_OPTION                                    */
/* Description  : Génération des mails concernant les nouvelles adhésions     */
/*              : Optionnelles                                                */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_RATTRAP_ADHESION_OPTION(p_dat_pivot date) IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_sujet       ENVOI_MAIL.sujet%type;
  loc_corps       ENVOI_MAIL.corps%type;
  loc_mail_exist NUMBER:=0;
  date_pivot  DATE := trunc(p_dat_pivot-2);   -- date de saisie des options -- M0006343 idem bienvenue adhesions en instance
  -- date_pivot  DATE := trunc(sysdate-1);
  CURSOR c_adhesions
      IS
      SELECT ad.idadhesion, h.datsai, ad.NUMINDIV, adhe.NUMADHE, adhe.mregl,adhe.date_adhe, ad.datapli, ad.datper
      FROM adhesion ad, adhe_cntrt adhe, histo_adhesion h, formule f, courrier_info cour
      WHERE
      ad.IDADHESION     = adhe.IDADHESION
      AND ad.IDADHESION = h.IDADHESION
      AND ad.NUMFOR     = f.numfor
      AND ad.numindiv   = adhe.numadhe -- uniquement pour les adhérents
      AND cour.numindiv = adhe.numadhe
      AND cour.type_crrr = 28 -- individu dématerialisé
      AND cour.moyen_info = 2
      AND h.etat in (0,1)  -- adhesion en instance ou en vigeur
      and h.motif not in (60,59) -- les validation du RH ne compte pas - MUR hotfix reprise livrable BIA
      AND trunc(h.DATSAI) =  date_pivot   -- adhesion souscrite la veille
      AND (date_pivot  BETWEEN ad.datapli AND  nvl(ad.datper, to_date(date_pivot)+1) OR (ad.datapli> date_pivot) )-- couverture en cour ou dans le futur
      AND ad.datapli <> nvl(ad.datper, ad.datapli+1)
      AND f.typgar = 2  -- option
      AND NOT EXISTS (SELECT *      -- verification des transfert de contrats juste pour les optionnels
              FROM ADHESION  a, CONTRAT c1, formule f1
              WHERE a.numindiv = ad.numindiv
                AND c1.numgar = a.numgar
                AND a.idadhesion <> ad.idadhesion
                AND c1.gest_prest = 1  --prestations gérées
                AND f1.numfor = a.numfor
                AND f1.typgar = f.typgar -- contrainte sur le même type de garantie que l'adhésion créée
                AND a.typfor = 1 --couverture santé
                AND (sysdate BETWEEN a.datapli AND NVL(a.datper,sysdate) --couverture en cours
                    OR (a.datper IS NOT NULL AND add_months(a.datper,6) > sysdate)  --couverture datant de moins de 6 mois
                --  OR (a.datapli> sysdate) --couverture dans le futur
                    OR (a.datper is not null and a.maj > sysdate-7 )))
     AND not exists (select 1 from rappel where numassu = ad.numindiv and type = 27 and trunc(creation) = date_pivot)  --CLI 22/11/2019 on envoi pas de mail optionnel si l'option viens du BIA
	   AND NOT EXISTS (SELECT clef FROM envoi_mail em WHERE em.numindiv_dest = adhe.numadhe AND em.etendue = 2  AND em.idtexte in (5,24) AND trunc(em.date_creation) = trunc(sysdate)) -- pas de création d'AR de souscription d'option le même jour qu'un Email de bienvenue (5/24) -- PBO M0006343 
    ORDER BY ad.idadhesion;



BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_OPTION',
                               I_session  => SID, I_niv_msg  => 1,
                               I_msg_adm  =>  'P_RATTRAP_ADHESION_OPTION : début traitement' || d2e(p_dat_pivot),
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('OPT',F_NUMUTIL) THEN
    FOR  rec_adhesion  IN      c_adhesions  LOOP
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_OPTION',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_RATTRAP_ADHESION_OPTION : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_adhesion.NUMADHE;
      loc_envoi.NUMBENE:=rec_adhesion.NUMINDIV;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=2;     -- Décompte soins de santé
      loc_envoi.clef:= rec_adhesion.IDADHESION;
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
      IF   rec_adhesion.MREGL IN (1,2) THEN
        loc_envoi.IDTEXTE:= 25;    -- Modele de mail gerep ( prelevement et chéque)
      ELSE
       loc_envoi.IDTEXTE:= 26; -- Modéle de mail par virement ( société)
      END IF;

      SELECT corps_msg, sujet_msg
        INTO loc_corps,loc_sujet
        FROM mail_texte
        WHERE id_texte = loc_envoi.idtexte;
      -- valorisation de la date dans le message
      loc_envoi.sujet := replace(loc_sujet,'#DATE_ADHE',d2e(rec_adhesion.DATE_ADHE));
      loc_envoi.corps := replace(loc_corps,'#DATE_ADHE',d2e(rec_adhesion.DATE_ADHE));
      io_envoi:=loc_envoi;


	     io_envoi:=loc_envoi;

      --  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_OPTION',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_RATTRAP_ADHESION_OPTION : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);


    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_OPTION',
                               I_session  => SID, I_niv_msg  => 1,
                               I_msg_adm  =>  'P_RATTRAP_ADHESION_OPTION : fin traitement' || d2e(p_dat_pivot),
                               I_idligne  => 1);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_OPTION',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_RATTRAP_ADHESION_OPTION;

/*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : P_RATTRAP_ADHESION_VIGUEUR                                    */
/* Description  : Génération des mails concernant les nouvelles adhésions     */
/*              : en vigueur                                                */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_RATTRAP_ADHESION_VIGUEUR(p_dat_pivot date) IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_sujet       ENVOI_MAIL.sujet%type;
  loc_corps       ENVOI_MAIL.corps%type;
  loc_mail_exist NUMBER:=0;
  date_pivot  DATE := trunc(p_dat_pivot-1);   -- date de saisie des option

  -- deux scenarios possibles soit les adhesions on été mis en instance et passent vigueur 
    CURSOR c_adhesions
      IS

SELECT distinct c.numgar,
       -- c.refcie,
        --c.numprod,
        --p.libelle, 
        datas.numadhe,
        datas.idadhesion
        --f_etat_adhe(datas.idadhesion, greatest(datas.date_adhe,sysdate)) etat_adhesion 
  FROM( 
    SELECT distinct adhe_cntrt.numadhe, adhe_cntrt.idadhesion,adhe_cntrt.date_adhe 
    FROM  histo_adhesion, 
          adhe_cntrt, 
          adhesion ad , 
          contrat c 
    WHERE 
          histo_adhesion.IDADHESION = adhe_cntrt.IDADHESION 
      AND adhe_cntrt.IDADHESION = ad.IDADHESION 
      AND c.NUMGAR = ad.NUMGAR 
      AND histo_adhesion.etat   =1  
      AND trunc(DATSAI) >= date_pivot    -- mouvement effectué hier
      AND TRUNC(DEBUT)  <= date_pivot +1 -- ABO M0006252 hotfix: si saisi au 30/10 avec debut le 01/11, on envoie le mail 5 le 01/11
      AND c.gest_prest = 1  
      AND ad.typfor = 1 
      AND ad.rang=1   
      AND greatest(adhe_cntrt.date_adhe,sysdate) between datapli and nvl( datper,greatest(adhe_cntrt.date_adhe,sysdate))   
    and not exists ( 
                    select 1 from envoi_mail 
                    where numindiv_dest = adhe_cntrt.numadhe 
                    and idtexte in(5,24) 
                   ) 
    and not exists( 
                    select * from adhe_cntrt ad_ante 
                    where ad_ante.IDADHESION <> adhe_cntrt.IDADHESION 
                    and ad_ante.numadhe = adhe_cntrt.numadhe 
                    and ad_ante.DATE_ADHE < adhe_cntrt.DATE_ADHE 
                    and  sysdate between  ad_ante.DATE_ADHE and nvl(add_months(ad_ante.DATE_FIN_ADHE,6),sysdate) 
                    ) 
       ) datas      
       ,adhe_cntrt a1, contrat c,produit p 
       where datas.idadhesion = a1.idadhesion 
       and a1.numgar = c.numgar 
       and c.numprod = p.numprod;

BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_VIGUEUR',
                               I_session  => SID, 
                               I_niv_msg  => 1,  
                               I_msg_adm  =>  'P_RATTRAP_ADHESION_VIGUEUR : début traitement' ||d2e(p_dat_pivot), 
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('NASSU',F_NUMUTIL) THEN
    FOR  rec_adhesion  IN      c_adhesions  LOOP
    loc_envoi :=  io_envoi;
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_VIGUEUR',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_RATTRAP_ADHESION_VIGUEUR : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
     IF  pk_mail.CHECK_DEMAT_INDIV(rec_adhesion.NUMADHE) =1 THEN
      loc_envoi.NUMINDIV_DEST:=rec_adhesion.NUMADHE;
      loc_envoi.NUMBENE:=rec_adhesion.NUMADHE;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=2;     -- Adhesion
      loc_envoi.clef:= rec_adhesion.IDADHESION;
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
      loc_envoi.IDTEXTE:= 5; --Mail de bienvenue
      loc_envoi.TEMPLATE_MAIL:= 3; -- PBO M0006130 Template mail de bienvenue

      SELECT corps_msg, sujet_msg
        INTO loc_corps,loc_sujet
        FROM mail_texte
        WHERE id_texte = loc_envoi.idtexte;

       PK_MAIL.CREER_MAIL(loc_envoi);
      END IF;

    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_VIGUEUR',
                             I_session  => SID, 
                             I_niv_msg  => 1,  
                             I_msg_adm  =>  'P_RATTRAP_ADHESION_VIGUEUR : Fin traitement' ||d2e(p_dat_pivot), 
                             I_idligne  => 1);

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_ADHESION_VIGUEUR',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END ;
/*============================================================================*/
/* Auteur       : ABO                                                         */
/* Création     : 27/04/2017                                                  */
/* Description  : Insertion des demandes de pièces dans la                    */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux assurés par un job                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_RATTRAP_PIECE(p_dat_pivot date) IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_nopiece    PIECES.NOPIECE%TYPE;

  CURSOR c_piece (p_nopiece NUMBER) IS
  SELECT distinct NUMINDIV_DEST,NUMBENE,CONTEXTE,ENTITE, MAX(NBREL) NBREL,decode(nopiece,p_nopiece,1,0) piece_detail
    FROM PIECES
    WHERE CONTEXTE  IN (4,12,20,19 ) --adhésion et dossier santé uniquement (télétransmission est traitée unitairement) -- MUR M0005618 ajout contexte 19 - pièces télétransmises
      AND TRUNC(NVL(DATEREL,DATEAVIS)) = TRUNC(p_dat_pivot-1)
      AND NVL(DATEREL,DATEAVIS) IS NOT NULL
      AND DATERECEP IS NULL --non déjà réceptionnée
      AND DATANNUL IS NULL --non annulée
      AND NVL(DATEREL,DATEAVIS) > add_months(p_dat_pivot,-12) -- datant de moins d'un an
      AND EXISTS(SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv =pieces.NUMINDIV_DEST) -- vérification que l assuré possède un circuit à 28
    --AND  (CONTEXTE<> 4 OR( CONTEXTE= 4 AND NOPIECE NOT IN (1,2,5,6,7) )) --black list présente aussi sur WS de consultation
	  AND EXISTS (SELECT 1 FROM adhesion a, contrat c --au moins une couverture santé
                  WHERE NUMINDIV = pieces.NUMBENE
                  AND c.numgar = a.numgar
	                AND c.gest_prest = 1  --prestations gérées
	                AND a.typfor = 1 --couverture santé
                  AND (p_dat_pivot BETWEEN a.datapli AND NVL(add_months(a.datper,3),p_dat_pivot) OR a.datapli > p_dat_pivot))
   AND nbrel < 80 -- ne pas tenir compte des pieces pour courrier d’information sur les limites d’âge
	 GROUP BY NUMINDIV_DEST,NUMBENE,CONTEXTE,ENTITE,NOPIECE
   ORDER BY 1;


   CURSOR c_piece_prev IS         --RKO EA PREV
   SELECT distinct  interlocuteur_dest.interlocuteur ,NUMBENE,CONTEXTE,ENTITE, MAX(NBREL) NBREL
    FROM PIECES, interlocuteur , interlocuteur interlocuteur_dest
    WHERE CONTEXTE  = 17 --contexte prevoyance pour société souscriptrice
      AND TRUNC(NVL(DATEREL,DATEAVIS)) = TRUNC(p_dat_pivot-1)   
      AND NVL(DATEREL,DATEAVIS) IS NOT NULL
      AND DATERECEP IS NULL --non déjà réceptionnée
      AND DATANNUL IS NULL --non annulée
      AND NVL(DATEREL,DATEAVIS) > add_months(p_dat_pivot,-12) -- datant de moins d'un an
	  AND EXISTS (SELECT 1 FROM adhesion a, contrat c  --au moins une couverture santé
                  WHERE NUMINDIV = pieces.NUMBENE
                  AND c.numgar = a.numgar
	                AND a.typfor = 2 --couverture prévoyances
                  AND (p_dat_pivot BETWEEN a.datapli AND NVL(add_months(a.datper,3),p_dat_pivot) OR a.datapli > p_dat_pivot))

     AND PIECES.numindiv_dest = interlocuteur.numindiv   --le destinataire doit avoir un email valide et être un interloc utilisateur de l'espace prevoy.
     AND interlocuteur.valide ='O'
     AND interlocuteur_dest.numindiv = interlocuteur.numindiv --meme société  (dans le cas ou l'interloc de la société du dossier prevoy n'est pas ouvert au domaine 9 on envoi quand meme aux autres interloc de la meme société qui sont en domaine 9)
     AND interlocuteur_dest.ope_crrr =9 
     AND interlocuteur_dest .valide ='O'
   AND nvl(nbrel,0) in (0,1,2) 
   AND f_coordonne_contact(interlocuteur_dest.interlocuteur,4,1) IS NOT NULL
	 GROUP BY interlocuteur_dest.interlocuteur,NUMBENE,CONTEXTE,ENTITE,NOPIECE
   ORDER BY 1;

BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PIECE',
                               I_session  => SID, I_niv_msg  => 1, 
                               I_msg_adm  =>  'P_RATTRAP_PIECE : début traitement ' || d2e(p_dat_pivot),
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('PIECE',F_NUMUTIL) THEN
    loc_nopiece :=to_number(f_get_transco('EA','SCOLA_N', 2,2));

    FOR  rec_piece  IN  c_piece(loc_nopiece)  LOOP
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PIECE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_RATTRAP_PIECE : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_piece.NUMINDIV_DEST;
      loc_envoi.NUMBENE:=rec_piece.NUMBENE;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      IF rec_piece.CONTEXTE = 20 THEN
        loc_envoi.etendue:=7;     -- soins de santé
        loc_envoi.clef:= rec_piece.NUMINDIV_DEST;
        loc_envoi.IDTEXTE:= 18;
         -- MUR M0005618
      ELSIF rec_piece.CONTEXTE = 19 THEN
         loc_envoi.etendue := 7 ; -- soins de santé
         loc_envoi.clef := rec_piece.NUMINDIV_DEST ;
         loc_envoi.IDTEXTE:= 30;
      ELSE
        loc_envoi.etendue:=2;     -- adhésion
        loc_envoi.clef:= rec_piece.ENTITE;
        IF rec_piece.NBREL = 0  AND rec_piece.piece_detail=0 THEN
		      loc_envoi.IDTEXTE:= 7;
        ELSIF rec_piece.NBREL = 1 AND rec_piece.piece_detail=0  THEN
          loc_envoi.IDTEXTE:= 27;
        ELSIF rec_piece.NBREL = 0  AND rec_piece.piece_detail=1 THEN --spécif certificat de sco avis
		      loc_envoi.IDTEXTE:= 35;
        ELSIF rec_piece.NBREL = 1 AND rec_piece.piece_detail=1  THEN --spécif certificat de sco relance
          loc_envoi.IDTEXTE:= 36;
        ELSIF rec_piece.NBREL > 1 THEN
          loc_envoi.IDTEXTE:= 28;
        END IF;
      END IF;

      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;

      --  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PIECE',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_RATTRAP_PIECE : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;

    --Génération des mails de pièces prévoyance
    FOR  rec_piece_prev  IN  c_piece_prev LOOP   
      loc_envoi.NUMINDIV_DEST:=rec_piece_prev.interlocuteur;
      loc_envoi.NUMBENE:=rec_piece_prev.NUMBENE;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      IF rec_piece_prev.CONTEXTE = 17 THEN
        loc_envoi.etendue:=1;    --prevoyance
        loc_envoi.clef:= rec_piece_prev.interlocuteur;
        loc_envoi.IDTEXTE:= NULL; 
        IF rec_piece_prev.NBREL = 0  THEN
		      loc_envoi.IDTEXTE:= 38;   
        ELSIF   rec_piece_prev.NBREL = 1  THEN--Relance 1
          loc_envoi.IDTEXTE:= 39;
        ELSE loc_envoi.IDTEXTE:= 40;    --Relance 2
        END IF;
      END IF;

      loc_envoi.TEMPLATE_MAIL:=2; 
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;


      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;

  END IF;

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PIECE',
                               I_session  => SID, I_niv_msg  => 1, 
                               I_msg_adm  =>  'P_RATTRAP_PIECE : fin traitement ' || d2e(p_dat_pivot),
                               I_idligne  => 1);

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PIECE',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_RATTRAP_PIECE;


/*============================================================================*/
/* Auteur       : BCO                                                         */
/* Création     : BCO                                                         */
/* Description  : SEPA B2B - Envoi d'un mail automatique à la création d'un   */
/*                RUM attaché à un querable prélévement collectif             */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_RATTRAP_RUM(p_dat_pivot date) IS
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_corps         MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet         MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;

  loc_date_pivot DATE := p_dat_pivot - 1 ;

  CURSOR c_new_rum (typI IN INTERLOCUTEUR.OPE_CRRR%TYPE) IS
  SELECT DISTINCT  
    hm.mandat,
    hq.numquerable,
    it.interlocuteur,
    ct.numcli,
    cp.ICS
  FROM       histo_mandat   hm
  INNER JOIN histo_querable hq on hq.mandat   = hm.mandat
  INNER JOIN interlocuteur  it on it.numindiv = hq.numquerable
  INNER JOIN contrat        ct on ct.numgar   = hq.numgar
  -- Compte de prelèvement de Cotis
  INNER JOIN compte         cp on cp.NUMCPTE  = f_param_compte (ct.numgar_ref, 4, 2)
  WHERE
        TRUNC(hm.creation) = TRUNC(loc_date_pivot)
    AND hm.statut = 1
    AND hq.etat   = 1
    AND hq.mregl  = 2
    AND NVL(hq.idadhesion,0) = 0 
    -- Critères sur l'interlocureur
    AND f_coordonne_contact(it.interlocuteur,4,1) IS NOT NULL
    AND it.valide   = 'O'
    AND it.ope_crrr = typI;

BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RUM',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_RUM : début traitement',
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('RUM',F_NUMUTIL) THEN
    loc_envoi.idtexte :=  42 ;
    SELECT corps_msg,
           sujet_msg,
           type_interlocuteur,
           template_mail
    INTO loc_corps,
         loc_sujet,
         loc_type_interloc,
         loc_template_mail
    FROM mail_texte
    WHERE id_texte = loc_envoi.idtexte;

    FOR rec_new_rum IN c_new_rum ( 1 ) LOOP   -- 1 - Cotisation
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RUM', 
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  =>  'P_RATTRAP_RUM : Traitement ' || rec_new_rum.numquerable || '- Mandat :' || trim(rec_new_rum.mandat), 
                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST := rec_new_rum.interlocuteur;
      loc_envoi.NUMBENE       := rec_new_rum.numcli;
      loc_envoi.NUMUTIL       := F_NUMUTIL;
      loc_envoi.etendue       := 13;     
      loc_envoi.clef          := rec_new_rum.numquerable;
      loc_envoi.sujet         := loc_sujet;
      loc_envoi.corps         := loc_corps;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#CLIENT', f_nom(1)); 
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#NOMBENE',f_nom(rec_new_rum.numquerable));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#RUM', trim(rec_new_rum.mandat)) ;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#ICS', NVL(rec_new_rum.ICS,''));
      loc_envoi.template_mail := loc_template_mail;
      loc_envoi.TYPE_MAIL     := 3;   -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;

      io_envoi:=loc_envoi;
      PK_MAIL.CREER_MAIL(I_envoi_mail => io_envoi,
                         i_desactiv_ctrl_doublon => 'O');
      IF io_envoi.numenvoimail IS NOT NULL THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RUM',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'P_RATTRAP_RUM : mail créé',
                                     I_idligne  => 4);
      END IF;
    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RUM',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_RUM : fin traitement',
                               I_idligne  => 9);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RUM',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_RATTRAP_RUM;



/*============================================================================*/
/* Auteur       : BCO                                                         */
/* Création     : BCO                                                         */
/* Description  : SEPA B2B - Envoi d'un mail automatique à la validation      */
/*                de la cotisation en prélèvement                             */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_RATTRAP_VCOTIS(p_dat_pivot date) IS
  loc_envoi         ENVOI_MAIL%ROWTYPE;
  io_envoi          ENVOI_MAIL%ROWTYPE;
  loc_corps         MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet         MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;

  loc_trimestre     VARCHAR(10);
  loc_annee         VARCHAR(10);


  loc_date_pivot DATE := p_dat_pivot - 1 ;

  CURSOR c_new_vcotis (typI IN INTERLOCUTEUR.OPE_CRRR%TYPE) IS
    SELECT DISTINCT
       qg.numquerable
      ,it.interlocuteur
      ,ct.numcli 
      ,cp.ICS
    FROM       qttc_global   qg
    INNER JOIN interlocuteur it ON it.numindiv = qg.numquerable
    INNER JOIN contrat       ct ON ct.numgar   = qg.numgar
    INNER JOIN facture       ft ON ft.numfact  = qg.numquit
                               AND ft.codope   = 4
  -- Compte de prelèvement de Cotis
    INNER JOIN compte        cp ON cp.NUMCPTE  = f_param_compte (ct.numgar_ref, 4, 2)
    WHERE 
        qg.valid               = 'O'
    AND TRUNC(qg.dat_valid)    = TRUNC(loc_date_pivot)
    -- exclusion des cotisations régularisées et annulées 
    AND qg.comptant           <> 'R'
    AND qg.type_qttc          <> 3 
    AND ft.mregl               = 2
    -- Critères sur l'interlocureur
    AND f_coordonne_contact(it.interlocuteur,4,1) IS NOT NULL
    AND it.valide   = 'O'
    AND it.ope_crrr = typI;


  CURSOR c_mnt_vcotis (i_numquerable IN QTTC_GLOBAL.NUMQUERABLE%TYPE, i_numcli CONTRAT.NUMCLI%TYPE) IS
    SELECT 
       ct.numgar
      ,ct.refcie
      ,ct.college
      ,ct.type_contrat
      ,NVL(ft.montant_d,0) - NVL(qg.mt_affec_D,0) solde_d
      ,TO_CHAR(qg.debut,'YYYY') annee
      ,TO_CHAR(qg.debut,'Q')    trimestre

    FROM       qttc_global   qg
    INNER JOIN contrat       ct ON ct.numgar   = qg.numgar
    INNER JOIN facture       ft ON ft.numfact  = qg.numquit
                               AND ft.codope   = 4
    WHERE 
        qg.numquerable         = i_numquerable
    AND ct.numcli              = i_numcli
    AND qg.valid               = 'O'
    AND TRUNC(qg.dat_valid)    = TRUNC(loc_date_pivot)
    -- exclusion des cotisations régularisées et annulées 
    AND qg.comptant           <> 'R'
    AND qg.type_qttc          <> 3 
    AND ft.mregl               = 2 
    ORDER BY 
     TO_CHAR(qg.debut,'YYYY')
    ,TO_CHAR(qg.debut,'Q')
    ,ct.type_contrat
    ,ct.refcie ;


BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_VCOTIS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_VCOTIS : début traitement',
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('VCOTI',F_NUMUTIL) THEN
    loc_envoi.idtexte :=  43 ;
    SELECT corps_msg,
           sujet_msg,
           type_interlocuteur,
           template_mail
    INTO loc_corps,
         loc_sujet,
         loc_type_interloc,
         loc_template_mail
    FROM mail_texte
    WHERE id_texte = loc_envoi.idtexte;
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_VCOTIS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_RATTRAP_VCOTIS : Mail VCOTIS autorisé',
                                 I_idligne  => 1);
    FOR rec_new_vcotis IN c_new_vcotis ( 1 ) LOOP   -- 1 - Cotisation
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_VCOTIS', 
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  =>  'P_RATTRAP_VCOTIS : Traitement ' || rec_new_vcotis.numquerable, 
                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST := rec_new_vcotis.interlocuteur ;
      loc_envoi.NUMBENE       := rec_new_vcotis.numcli ;
      loc_envoi.NUMUTIL       := F_NUMUTIL;
      loc_envoi.etendue       := 13;     
      loc_envoi.clef          := rec_new_vcotis.numquerable;
      loc_envoi.TYPE_MAIL     := 3;   -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;
      loc_envoi.sujet         := loc_sujet;
      loc_envoi.corps         := loc_corps;
      loc_envoi.template_mail := loc_template_mail;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#CLIENT', f_nom(1)); 
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#NOMQUER',f_nom(rec_new_vcotis.numquerable));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#NOMBENE',f_nom(rec_new_vcotis.numcli));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#ICS', NVL(rec_new_vcotis.ICS,''));   

      loc_trimestre := NULL ;
      loc_annee     := NULL ;
      FOR rec_mnt_vcotis IN c_mnt_vcotis ( rec_new_vcotis.numquerable, rec_new_vcotis.numcli) LOOP
        -- si rupture sur annee/trimestre
        IF   loc_trimestre = rec_mnt_vcotis.trimestre 
         AND loc_annee     = rec_mnt_vcotis.annee THEN
          NULL;
        ELSE
          loc_trimestre   := rec_mnt_vcotis.trimestre ;
          loc_annee       := rec_mnt_vcotis.annee ;

          loc_envoi.corps := loc_envoi.corps || CHR(10) || CHR(10);
          CASE rec_mnt_vcotis.trimestre
            WHEN '1' THEN 
              loc_envoi.corps := loc_envoi.corps || '1er trimestre '   || rec_mnt_vcotis.annee ;
            WHEN '2' THEN 
              loc_envoi.corps := loc_envoi.corps || '2ième trimestre ' || rec_mnt_vcotis.annee ;
            WHEN '3' THEN 
              loc_envoi.corps := loc_envoi.corps || '3ième trimestre ' || rec_mnt_vcotis.annee ;
            WHEN '4' THEN 
              loc_envoi.corps := loc_envoi.corps || '4ième trimestre ' || rec_mnt_vcotis.annee ;
            ELSE 
              loc_envoi.corps := loc_envoi.corps || rec_mnt_vcotis.annee ;
          END CASE;
          loc_envoi.corps := loc_envoi.corps || CHR(10) || 'Détail du prélèvement par contrat : ';
        END IF;
        loc_envoi.corps := loc_envoi.corps || CHR(10);
        loc_envoi.corps := loc_envoi.corps ||
                  f_lble('TYP_CONT',rec_mnt_vcotis.type_contrat) ||
                 ' - ' || rec_mnt_vcotis.refcie ||
                 ' - ' || f_lble('COLLEGE',rec_mnt_vcotis.college) ||
                 ' : '  || LTRIM(TO_CHAR(rec_mnt_vcotis.solde_d,'9999990.99')) || ' euros';
      END LOOP;


      io_envoi                := loc_envoi;
      PK_MAIL.CREER_MAIL(I_envoi_mail => io_envoi,
                         i_desactiv_ctrl_doublon => 'O');


      IF io_envoi.numenvoimail IS NOT NULL THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_VCOTIS',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'P_RATTRAP_VCOTIS : mail créé',
                                     I_idligne  => 4);
      END IF;
    -- fin boucle querable/interlocuteur
    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_VCOTIS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_VCOTIS : fin traitement',
                               I_idligne  => 9);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_VCOTIS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_RATTRAP_VCOTIS;



/*============================================================================*/
/* Auteur       : BCO                                                         */
/* Création     : BCO                                                         */
/* Description  : SEPA B2B - Envoi d'un mail automatique à la génération d'un */
/*                bordereau de prélèvement B2B validé                         */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_RATTRAP_PB2B(p_dat_pivot date) IS
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_corps         MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet         MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;

  loc_date_pivot DATE := p_dat_pivot -1 ;

  CURSOR c_new_pb2b (typI IN INTERLOCUTEUR.OPE_CRRR%TYPE) IS
  SELECT
     pr.numremise
    ,pr.numquerable
    ,SUM(NVL(pr.montant,0)) smontant
    ,rp.eche_prelev_sepa
    ,it.interlocuteur
  FROM       remise_prelev rp
  INNER JOIN prelevement   pr ON pr.numremise = rp.numremise
  INNER JOIN interlocuteur it ON it.numindiv  = pr.numquerable
  WHERE rp.typesepa = 2 
    AND rp.valide   = 'O'
    AND TRUNC(rp.datdisk) = TRUNC(loc_date_pivot)
    -- Critères sur l'interlocureur
    AND f_coordonne_contact(it.interlocuteur,4,1) IS NOT NULL
    AND it.valide   = 'O'
    AND it.ope_crrr = typI
  GROUP BY
     pr.numremise
    ,pr.numquerable
    ,rp.eche_prelev_sepa
    ,it.interlocuteur
    ;

  CURSOR c_numcli_pb2b (i_numremise   IN PRELEVEMENT.NUMREMISE%TYPE,
                        i_numquerable IN PRELEVEMENT.NUMQUERABLE%TYPE) IS
  SELECT DISTINCT 
    ct.numcli
  FROM       remise_prelev      rp
  INNER JOIN prelevement        pr ON pr.numremise = rp.numremise
  INNER JOIN prelevement_detail pd ON pd.numprelev = pr.numprelev
  INNER JOIN qttc_global        qg ON qg.numquit   = pd.numfact 
  INNER JOIN contrat            ct ON ct.numgar    = qg.numgar  
  WHERE rp.numremise     = i_numremise
    AND pr.numquerable   = i_numquerable
    AND rp.typesepa      = 2 
    AND rp.valide        = 'O'
    AND TRUNC(rp.datdisk) = TRUNC(loc_date_pivot)
    ;

BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PB2B',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_PB2B : début traitement',
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('PB2B',F_NUMUTIL) THEN
    loc_envoi.idtexte :=  44 ;
    SELECT corps_msg,
           sujet_msg,
           type_interlocuteur,
           template_mail
    INTO loc_corps,
         loc_sujet,
         loc_type_interloc,
         loc_template_mail
    FROM mail_texte
    WHERE id_texte = loc_envoi.idtexte;

    FOR rec_new_pb2b IN c_new_pb2b ( 1 ) LOOP   -- 1 - Cotisation
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PB2B', 
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  =>  'P_RATTRAP_PB2B : Traitement ' || rec_new_pb2b.numremise, 
                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST := rec_new_pb2b.interlocuteur;
      loc_envoi.NUMBENE       := rec_new_pb2b.numquerable;
      loc_envoi.NUMUTIL       := F_NUMUTIL;
      loc_envoi.etendue       := 13;     
      loc_envoi.clef          := rec_new_pb2b.numquerable;
      loc_envoi.sujet         := loc_sujet;
      loc_envoi.corps         := loc_corps;
      loc_envoi.template_mail := loc_template_mail;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#MNT', LTRIM(TO_CHAR(rec_new_pb2b.smontant,'9999990.99'))); 
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#DATEPRELEV', TO_CHAR(TO_DATE(rec_new_pb2b.eche_prelev_sepa,'DDMMYYYY'),'DD/MM/YYYY')) ;
      loc_envoi.TYPE_MAIL     := 3;   -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;

      FOR rec_numcli_pb2b IN c_numcli_pb2b ( rec_new_pb2b.numremise ,rec_new_pb2b.numquerable ) LOOP
        loc_envoi.corps := loc_envoi.corps || CHR(10);
        loc_envoi.corps := loc_envoi.corps || f_nom(rec_numcli_pb2b.numcli) ;
      END LOOP;

      io_envoi:=loc_envoi;
      PK_MAIL.CREER_MAIL(I_envoi_mail => io_envoi,
                         i_desactiv_ctrl_doublon => 'O');
      IF io_envoi.numenvoimail IS NOT NULL THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PB2B',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'P_RATTRAP_PB2B : mail créé',
                                     I_idligne  => 4);
      END IF;
    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PB2B',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_PB2B : fin traitement',
                               I_idligne  => 9);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_PB2B',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_RATTRAP_PB2B;

/******************Procedure de reprise des mails de radiations*****************/

PROCEDURE P_RATTRAP_RESIL(p_dat_pivot DATE) IS

  CURSOR c_adhesion_resil(p_motif NUMBER, p_date DATE) IS
    SELECT distinct ad.numadhe,ad.idadhesion, ha.datsai, ha.motif, cr.numgar, cr.numprod, cr.numcli,a.datper
    FROM adhe_cntrt ad, histo_adhesion ha,adhesion a, contrat_ref cr
    WHERE ad.idadhesion = a.idadhesion
    AND ad.idadhesion = ha.idadhesion
    AND ad.numadhe = a.numindiv
    AND cr.numgar = a.numgar
	and cr.numprod NOT IN (select code from LIBELLE where mnemo like 'PRODEXCLU' and code <> -2) --RKO M0006951 exlusion des produits 198,204 et 384
    AND cr.numprod IS NOT NULL
	AND cr.type_contrat = 1--contrat santé RG3 exclusion des contrats prévoyance de l'envoi des mails et courriers
    AND trunc(a.datapli) <> NVL(a.datper,e2d('01/01/1900'))
    AND pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe, p_date),  a_type=>1) in (1,3) -- en vigueur à la date du jour et resilié dans le futur ou resilié à la date du jour
    AND pk_mail.check_demat_indiv(ad.numadhe) =1 -- assuré dématérialisé
    AND ha.etat = 3
    AND a.datper = ha.debut
	AND trunc(a.datper)> trunc(p_date -90) -- pas de mail si radiation trop ancienne
    AND trunc(ha.datsai) = trunc(p_date -1)   -- adhérents radiés dont le mouvement de radiation a été effectué la veille
    AND to_number(LPAD(ha.motif,4,0)) IN ( SELECT distinct to_number(substr(substr(code,6,9),1,4)) FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD') --les motifs paramétrés selon le type de produit
    --AND ha.motif NOT IN (select distinct to_number(substr(substr(code,6,9),1,4)) FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,10,10)=1)  -- hors motif=18 fin de maintien de garantie Mail généré à M-1
    AND ha.motif <> p_motif -- hors motif=18 --fin de maintien de garantie --Mail généré à M-1
	AND NOT EXISTS (SELECT 1 FROM histo_adhesion ha3 where ha3.idadhesion = ha.idadhesion and ha3.IDHISTOADHE > ha.IDHISTOADHE )     -- pas de mouvement autre plus recent que la radiation
    AND 1 in (SELECT etat
            FROM histo_adhesion ha2
            WHERE ha2.idadhesion = a.idadhesion
            AND ha2.debut <= ha.debut
            AND ha2.IDHISTOADHE < ha.IDHISTOADHE
            order by ha2.IDHISTOADHE desc
            fetch first 1 row only)
    and  not exists (select distinct ad2.* from adhe_cntrt ad2, adhesion a2, histo_adhesion ha2, contrat_ref cr2 --verif si pas d'adhesion en vigueur/instance postérieure sur un autre contrat
                where ad2.numadhe=ad.numadhe --413077
                and ad2.idadhesion=a2.idadhesion
                and ad2.numgar=cr2.numgar
                and a2.numgar in (select cr2.numgar
                from contrat_ref cr2 where cr2.type_contrat = 1 ) -- sur contrat santé et pas d'obligation que le souscript soit le meme
                and ha2.etat in (0,1)
				AND trunc(a2.datapli) <> NVL(a2.datper,e2d('01/01/1900'))
                and trunc(a2.datapli)>trunc(a.datper) --trunc(sysdate)
				and pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a2.idadhesion, a_date    => greatest(ad2.date_adhe, p_date),  a_type=>1) in (0,1) --en vigueur ou en instance

				)
    UNION
    SELECT distinct ad.numadhe, ad.idadhesion, ha.datsai, ha.motif, cr.numgar, cr.numprod, cr.numcli, a.datper
    FROM adhe_cntrt ad, histo_adhesion ha,adhesion a, contrat_ref cr
    WHERE ad.idadhesion = a.idadhesion
    AND ad.idadhesion = ha.idadhesion
    AND ad.numadhe = a.numindiv
    AND cr.numgar = a.numgar
	and cr.numprod NOT IN (select code from LIBELLE where mnemo like 'PRODEXCLU' and code <> -2) --RKO M0006951 exlusion des produits 198,204 et 384
    AND cr.numprod IS NOT NULL
	AND cr.type_contrat = 1--contrat santé RG3 exclusion des contrats prévoyance de l'envoi des mails et courriers
    AND trunc(a.datapli) <> NVL(a.datper,e2d('01/01/1900'))
    AND pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    =>add_months(p_date,1) ,  a_type=>1) = 3 --resilié  dans un mois
    AND pk_mail.check_demat_indiv(ad.numadhe) =1 --assuré dématérialisé
    AND ha.etat = 3
    --AND ha.motif IN (select distinct to_number(substr(substr(code,6,9),1,4)) FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,10,10)=1)  -- motif=18 --fin de maintien de garantie --Mail généré à M-1
    AND ha.motif = p_motif -- motif=18 --fin de maintien de garantie --Mail généré à M-1
	AND a.datper = ha.debut
	AND trunc(a.datper)> trunc(p_date -90) -- pas de mail si radiation trop ancienne
    AND NOT EXISTS (SELECT idadhesion FROM adhesion a2 where a2.idadhesion =ad.idadhesion AND a2.datper IS NULL) --verif si pas couverture ouverte
    AND ((TRUNC(a.datper) = TRUNC(add_months(p_date,1))) --fin de couverture dans un mois       -- exple  adhesion 482180 et 471804 finissent dans 1mois par rapport au 02/09 avec motif 18 --> Mail à M-1
       OR (TRUNC(a.datper) < TRUNC (add_months(p_date,1)) AND TRUNC(ha.datsai)=TRUNC(p_date-1)) -- saisie tardive de radiation
       OR TRUNC(p_date) BETWEEN TRUNC(add_months(a.datper,-1)) AND TRUNC(add_months(a.datper,+1)) --mail envoyé à J+1 (date du jour) si la date du jour est dans la période comprise entre date de radiation-1mois (M-1) et date de radiation + 1mois (M+1). Dans le futur, on attend le M-1 de la date de radiation, pour emettre le mail à J + 1.
       )
    AND NOT EXISTS (SELECT 1 FROM histo_adhesion ha3 WHERE ha3.idadhesion = ha.idadhesion AND ha3.IDHISTOADHE > ha.IDHISTOADHE )     -- pas de mouvement autre plus recent que la radiation
    AND 1 in (SELECT etat
            FROM histo_adhesion ha2
            WHERE ha2.idadhesion = a.idadhesion
            AND ha2.debut <= ha.debut
            AND ha2.IDHISTOADHE < ha.IDHISTOADHE
            order by ha2.IDHISTOADHE desc
            fetch first 1 row only)

	;

  loc_envoi             ENVOI_MAIL%ROWTYPE;
  io_envoi              ENVOI_MAIL%ROWTYPE;
  loc_corps             MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet             MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail     MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc     MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;
  loc_idlig             NUMBER:=0;
  v_prod_motif          libelle_bis.code%TYPE;
  v_idtexte             Number;
  loc_doubl_mail_resil  NUMBER;
  loc_motif_18          NUMBER;
  v_motif_profil3       NUMBER;
  v_deb                 NUMBER;
  v_delai               NUMBER;

BEGIN
  v_deb:=DBMS_UTILITY.GET_TIME;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_RESIL : début traitement '|| v_deb,
                               I_idligne  => loc_idlig+1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('RESIL',F_NUMUTIL) THEN
    BEGIN
		select distinct to_number(substr(substr(code,6,9),1,4)) into loc_motif_18
		FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,10,10)=1;
	EXCEPTION
		WHEN OTHERS THEN loc_motif_18 :=18;
	END;

    FOR  r_adhesion_resil  IN c_adhesion_resil(loc_motif_18, p_dat_pivot)  LOOP
		BEGIN

            BEGIN
                select distinct to_number(substr(substr(code,6,9),1,4)) into v_motif_profil3 
                from libelle_bis 
                WHERE mnemo LIKE 'MOTIF_PROD' 
                and substr(code,1,5) =0 and tableau ='P3'
                and to_number(substr(substr(code,6,9),1,4))= r_adhesion_resil.motif; 

            EXCEPTION
                WHEN NO_DATA_FOUND THEN v_motif_profil3 := null;
                PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'ce n''est pas un profil 3 ou paramétrage manquant adhésion '||r_adhesion_resil.idadhesion ||' motif ' ||r_adhesion_resil.motif||' produit '||r_adhesion_resil.numprod||' idtexte '||loc_envoi.idtexte,
                               I_idligne  =>1);
            END;
			--recherche idtexte selon le numproduit et le motif de résil.
            IF v_motif_profil3 IS NOT NULL THEN --RKO M0006959
                select sens into v_idtexte --profil 3
                from libelle_bis  
                where to_number(substr(substr(code,6,9),1,4))= v_motif_profil3 
                and mnemo LIKE 'MOTIF_PROD' 
                ;
           ELSE
			SELECT TO_CHAR(LPAD(decode(r_adhesion_resil.numprod,272,272,0),5,0)||LPAD(r_adhesion_resil.motif,4,0)) INTO v_prod_motif FROM dual;
			SELECT  sens /*(qui est idtexte)*/ INTO v_idtexte FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,1,9) = v_prod_motif;
          END IF;	
            loc_envoi.idtexte := v_idtexte;

            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'adhesion '||r_adhesion_resil.idadhesion ||' motif ' ||r_adhesion_resil.motif||' produit '||r_adhesion_resil.numprod||' idtexte '||loc_envoi.idtexte,
                               I_idligne  =>1);

        EXCEPTION
			WHEN OTHERS THEN v_prod_motif :=null; v_idtexte :=null; loc_envoi.idtexte :=null;
				PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Absence de paramétrage produit-motif pour mail. Motif :'||r_adhesion_resil.motif||' produit '||r_adhesion_resil.numprod||' adhesion '||r_adhesion_resil.idadhesion,
                               I_idligne  =>1);

		END;
PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'rko1 adhesion'||r_adhesion_resil.idadhesion ||'loc_envoi.idtexte'|| loc_envoi.idtexte,
                               I_idligne  =>1);
      IF loc_envoi.idtexte IS NOT NULL THEN  --on creer le mail que s'il ya paramétrage
        SELECT corps_msg,
              sujet_msg,
              type_interlocuteur,
              template_mail
        INTO loc_corps,
            loc_sujet,
            loc_type_interloc,
            loc_template_mail
        FROM mail_texte
        WHERE id_texte = loc_envoi.idtexte;

        loc_envoi.NUMINDIV_DEST:=r_adhesion_resil.numadhe;
        loc_envoi.NUMBENE:=r_adhesion_resil.numadhe;
        loc_envoi.NUMUTIL:= F_NUMUTIL;
        loc_envoi.etendue:=2; --adhesion
        loc_envoi.clef:= r_adhesion_resil.idadhesion;
        loc_envoi.NUMUTIL       := F_NUMUTIL;
        loc_envoi.sujet         := loc_sujet;
        --loc_envoi.corps         := loc_corps;
        loc_envoi.corps         := REPLACE(loc_corps, '#DATEFINADH', TO_CHAR(r_adhesion_resil.datper,'DD/MM/YYYY')) ;
        loc_envoi.template_mail := loc_template_mail;
        loc_envoi.TYPE_MAIL     := 3;   -- Automatique
        loc_envoi.DATE_CREATION := p_dat_pivot;
        io_envoi:=loc_envoi;
PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'rko2 adhesion'||io_envoi.clef ||'io_envoi.idtexte'|| io_envoi.idtexte,
                               I_idligne  =>1);

		IF r_adhesion_resil.motif = loc_motif_18 THEN	-- Uniquement pour le motif=18
			--On n'émet pas de mail si l'assuré a déjà été recu un mail l'informant de la radiation de son adhesion dans l'intervalle M-1 M+1 de la date debut de radiation
			select count(numenvoimail) INTO loc_doubl_mail_resil 
			FROM envoi_mail
			where /*clef=r_adhesion_resil.idadhesion --RKO M0006950
			AND*/ numindiv_dest= r_adhesion_resil.numadhe 
			AND numbene=r_adhesion_resil.numadhe 
			AND trunc(date_creation) BETWEEN TRUNC(add_months(r_adhesion_resil.datper,-1)) AND TRUNC(add_months(r_adhesion_resil.datper,+1))
			AND TYPE_MAIL = 3
			AND idtexte in (SELECT  distinct sens FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD'and sens<>1)--sécurité en cas de changement de motif dans les 90jrs  
			AND (etat = 0 --non envoyé
				OR (etat = 1 AND TRUNC(datemis) BETWEEN TRUNC(add_months(r_adhesion_resil.datper,-1)) AND TRUNC(add_months(r_adhesion_resil.datper,+1)))
			)FETCH FIRST 1 ROWS ONLY;

			IF loc_doubl_mail_resil>0 THEN continue; --on ne cree pas le mail
			ELSE
                --PK_MAIL.CREER_MAIL(io_envoi,'O'); -- désactivation du controle de doublon dans l'appel de creer_mail  RKO M0006950
				CREER_MAIL_RATTRAP(io_envoi,'O',p_dat_pivot);   
				PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 3,
                               I_msg_adm  => 'P_RATTRAP_RESIL :motif 18 mail crée pour assuré: '||io_envoi.numbene||' sur io_envoi.clef '||io_envoi.clef,
                               I_idligne  =>loc_idlig+1);
			END IF;
		ELSE
            --PK_MAIL.CREER_MAIL(io_envoi);
			CREER_MAIL_RATTRAP(io_envoi,'N',p_dat_pivot); 
			PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 3,
                               I_msg_adm  => 'P_RATTRAP_RESIL : mail crée pour assuré: '||io_envoi.numbene||' sur io_envoi.clef '||io_envoi.clef||' idtexte '||io_envoi.idtexte,
                               I_idligne  =>loc_idlig+1);
		END IF;

PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'rko3 adhesion'||io_envoi.clef ||'io_envoi.idtexte'|| io_envoi.idtexte,
                               I_idligne  =>1);
      ELSE --loc_envoi.idtexte IS NOT NULL
            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'attention mail non crée car absence de paramétrage adhesion'||r_adhesion_resil.idadhesion ||'io_envoi.idtexte'|| io_envoi.idtexte,
                               I_idligne  =>1);
      END IF;
    END LOOP;
  END IF;
  v_delai:=DBMS_UTILITY.GET_TIME - v_deb;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_RATTRAP_RESIL : temps de traitement en sec : '||v_delai/100,
                               I_idligne  =>loc_idlig+1);

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_RATTRAP_RESIL',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 1);
END P_RATTRAP_RESIL;

PROCEDURE CREER_MAIL_RATTRAP( I_envoi_mail IN OUT ENVOI_MAIL%ROWTYPE,
                      p_desactiv_ctrl_doublon IN VARCHAR2  DEFAULT 'N', p_dat_pivot date) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  loc_doublon  ENVOI_MAIL.NUMENVOIMAIL%TYPE;
  loc_etat ENVOI_MAIL.ETAT%TYPE;
  loc_type_interloc NUMBER;
  loc_sujet ENVOI_MAIL.SUJET%TYPE;
  loc_corps ENVOI_MAIL.CORPS%TYPE;
BEGIN

  pk_mail.P_INS_journal(3,'dans la procédure de création');
  -- Gestion des doublons de mail
  IF p_desactiv_ctrl_doublon = 'N' THEN
  BEGIN
    --recherche de doublon de mail, on ne peut pas envoyé deux fois dans la même journée un même e-mail (idtexte)
    SELECT NUMENVOIMAIL,ETAT INTO loc_doublon, loc_etat
    FROM ENVOI_MAIL
    WHERE numindiv_dest = I_envoi_mail.numindiv_dest
    --AND type_mail = I_envoi_mail.type_mail
    --AND etendue = I_envoi_mail.etendue
    --AND clef = I_envoi_mail.clef
    AND idtexte = I_envoi_mail.idtexte
    AND nvl(I_envoi_mail.sujet,sujet)  = sujet
    AND type_mail <> 2  -- controle de doublon uniquemet pour les mails auto ou de masse
      AND trunc(date_creation) = trunc(p_dat_pivot)    --envoyé le même jour
    AND (etat = 0 --non envoyé
       OR (etat = 1 AND TRUNC(datemis) = TRUNC(p_dat_pivot)))
      FETCH FIRST 1 ROWS ONLY;


  EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
	pk_mail.P_INS_journal(1,'CREER_MAIL_RATTRAP erreur'||SQLERRM);
	return;
  END;

  --pour les prises en charge hospitalière et pièce télétrans, on met a jour le mail avec le dernier numedit (si le gestionnaire réédite plusieurs fois le même courrier)
  IF loc_doublon IS NOT NULL  AND I_envoi_mail.numedit IS NOT NULL AND loc_etat = 0  AND I_envoi_mail.idtexte in(18,17) THEN
    UPDATE ENVOI_mail set numedit = I_envoi_mail.numedit
    WHERE numindiv_dest = I_envoi_mail.numindiv_dest
      AND type_mail = I_envoi_mail.type_mail
      AND etendue = I_envoi_mail.etendue
      AND numbene = I_envoi_mail.numbene
      AND clef = I_envoi_mail.clef
      AND etat = 0;
    COMMIT;
    RETURN;
  ELSIF loc_doublon IS NOT NULL  AND I_envoi_mail.numedit IS  NULL THEN
	pk_mail.P_INS_journal(1,'CREER_MAIL_RATTRAP doublon de mail detecté pour individu'||I_envoi_mail.numindiv_dest);
    RETURN;
  END IF;
  -- FinSi Controle doublon
  END IF;

  SELECT NUMENVOIMAIL.nextval INTO I_envoi_mail.NUMENVOIMAIL FROM DUAL;
  I_envoi_mail.etat :=0;

   -- récuperation du message paramétré dans mail_texte lorsque l'email est automatique
  IF I_envoi_mail.type_mail  IN (1,3) THEN
    BEGIN
      SELECT corps_msg, sujet_msg, type_interlocuteur
      INTO loc_corps,loc_sujet,loc_type_interloc
      FROM mail_texte
	  WHERE id_texte = I_envoi_mail.idtexte;

      --enrichissement seulement si non vide pour ne pas écraser les textes dynamiques #VALEUR
      IF I_envoi_mail.corps IS NULL OR I_envoi_mail.sujet IS NULL THEN
        I_envoi_mail.corps:=loc_corps;
        I_envoi_mail.sujet:=loc_sujet;
      END IF;

       --mail pro M6649 mail 29 multi contexte assuré / RH prise en compte du template
      IF NVL(loc_type_interloc,0) =1 OR (loc_type_interloc=0 AND I_envoi_mail.template_mail  in (2,5))  THEN
        I_envoi_mail.destinataire:= f_coordonne_contact(I_envoi_mail.numindiv_dest,4,1);
      ELSE
        I_envoi_mail.destinataire:= NVL(f_coordonne_contact(I_envoi_mail.numindiv_dest,4,2),f_coordonne_contact(I_envoi_mail.numindiv_dest,4,1))  ;
      END IF ;

    EXCEPTION
      WHEN no_data_found THEN  I_envoi_mail.etat := 3;
    END;
  ELSIF I_envoi_mail.destinataire IS NULL THEN
    I_envoi_mail.destinataire :=NVL(f_coordonne_contact(I_envoi_mail.numindiv_dest,4,2),f_coordonne_contact(I_envoi_mail.numindiv_dest,4,1)) ; --adresse perso puis pro par défaut
  END IF;



  INSERT INTO ENVOI_MAIL VALUES I_envoi_mail ;

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
    pk_mail.P_INS_journal(3,'[Creation mail]impossible, numDest['||I_envoi_mail.numindiv_dest||'] étendue['||I_envoi_mail.etendue||'] clef['||I_envoi_mail.clef||']');
    --g_idligne :=0; -- remise a 0 de l'id ligne pour les opéarations réalisées par le ws qui as toujours la même sessions et par conséquente ne remet pas 0 le package
    ROLLBACK;
END CREER_MAIL_RATTRAP;

/******************Procedure d''envoi des mails repris à la date de reprise*****************/

PROCEDURE P_SEND_ALL_MAIL_JOB_RATTRAP (p_type_mail IN NUMBER, p_dat_pivot DATE)is
  -- MUR M0005764 ajout idtexte 33 - Accusé de reception demande affiliation  -  pour envoi du mail au fil de l'eau
  -- ABO M0005769 ajout idtexte 31 - mail hebdo pour RH récapitulatif
  -- PBO M0006241 Email manuel texte 34 à envoyer le lendemain
  CURSOR c_liste_mails IS
  SELECT  numenvoimail FROM envoi_mail
    WHERE type_mail = p_type_mail
    AND nvl(etat,0) = 0 -- on prend les mails a envoyer
    AND datemis IS NULL -- double sécurité, on ne prend que les mail n'ayant pas de date d'émission.
    AND(  (p_type_mail = 2 AND NVL(IDTEXTE,0)!=34)         -- mail manuel différent de texte 34 - ajout nvl sur idtexte M0006301
	  -- AND(  i_type_mail = 2-- mail manuel
      OR( p_type_mail = 2 AND IDTEXTE=34 AND TRUNC(date_creation)=TRUNC(p_dat_pivot-1)) -- Email manuel texte 34 de la veille
       OR(
       ((p_type_mail = 1 AND TRUNC(date_creation)=TRUNC(p_dat_pivot-1)) --mail unitaire auto généré au fil de l'eau la veille
        OR  ( p_type_mail = 3
          AND (TRUNC(date_creation)=TRUNC(p_dat_pivot) OR
              (NUMENVOI_ORIGINE IS NOT NULL AND TRUNC(date_creation)=TRUNC(p_dat_pivot-1) )
              ) -- prise en compte des email régénré de type masse
            )
          ) 
        AND idtexte in (select id_texte from mail_texte where actif = 1)  -- blocage des autre envoi de mail ( pris en compte uniquement pour les mails auto )
       )
     )
  UNION
    SELECT numenvoimail FROM envoi_mail   --EVO EXTRANET 2018 on envoi les accusés de reception Corbeille (type 3) en même temps que les mails manuels
      WHERE type_mail = 3
      AND  p_type_mail= 2
      and  idtexte in (29 , 33)
      AND nvl(etat,0) = 0 -- on prend les mails a envoyer
      AND datemis IS NULL
     ;

  mails_in_error ty_mail_in_error;
  nb_msg_err NUMBER(5) :=0;
  nb_msg_err_copy NUMBER(5) :=0;
  nb_msg_tot NUMBER(5) :=0;
  date_session Date := p_dat_pivot;
  Rec_mail  c_liste_mails%ROWTYPE;
BEGIN


  mails_in_error  :=  ty_mail_in_error();
  -- selection des mails a envoyer
  OPEN c_liste_mails;
  LOOP
    FETCH c_liste_mails INTO Rec_mail;
    EXIT WHEN c_liste_mails%NOTFOUND;
        nb_msg_tot := nb_msg_tot+1;
         pk_mail.P_INS_journal(3,'Id  de mail a envoyer ' || Rec_mail.numenvoimail  );
         PK_MAIL.MAIL_JOB(Rec_mail.numenvoimail,nb_msg_err);
         if nb_msg_err > nb_msg_err_copy THEN
           nb_msg_err_copy := nb_msg_err;
           mails_in_error.extend;
           mails_in_error(nb_msg_err) := Rec_mail.numenvoimail;
         END IF;
    END LOOP;
    --fermeture du curseur
    IF c_liste_mails%ISOPEN THEN
           CLOSE c_liste_mails;
    END IF;

  pk_mail.P_INS_journal(3,'P_SEND_ALL_MAIL_JOB Nb mail en erreur =['||nb_msg_err||']');
  /*P_SEND_RAPPORT_ENVOI_MAIL(i_nb_mail_error=>nb_msg_err,
                            nb_total_msg =>nb_msg_tot,
                            i_date_session=>date_session,
                            i_mails_in_error => mails_in_error
                            );  */ --POUR TU EA PREV 12/03/2020
END P_SEND_ALL_MAIL_JOB_RATTRAP;


END PK_MAIL_RATTRAPE;
/
