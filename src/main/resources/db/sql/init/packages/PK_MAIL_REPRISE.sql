CREATE OR REPLACE PACKAGE ARTHUS.PK_MAIL_REPRISE IS
/*============================================================================*/
/* PACKAGE      : PK_MAIL_REPRISE.sql                                         */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : PBO                                                         */
/* Creation     : 12/07/2021                                                  */
/* Description  : PK temporaire lié au ticket ARTGEREP_499                    */
/*                permet la regeneration des mails de bienvenue               */
/*                pour le numcli 395953 à une date donnee                     */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/

 PROCEDURE P_CHARGE_ADH_VIGUEUR_REPRISE;
 PROCEDURE P_SEND_ALL_MAIL_JOB_REPRISE (i_type_mail IN NUMBER, i_date DATE);

END PK_MAIL_REPRISE;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_MAIL_REPRISE IS

/******************Procedure de reprise des mails de bienvenue 5*****************/

PROCEDURE P_CHARGE_ADH_VIGUEUR_REPRISE IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_sujet       ENVOI_MAIL.sujet%type;
  loc_corps       ENVOI_MAIL.corps%type;
  loc_mail_exist NUMBER:=0;
  date_pivot  DATE := trunc(sysdate-1);   -- date de saisie des option

    CURSOR c_adhesions_reprises
      IS
      SELECT DISTINCT 
        datas.num_nv_contrat numgar,
        datas.adherent numadhe,
        datas.nvelle_adh idadhesion
      FROM (select distinct
        ad_ante.numadhe adherent
        ,ad_ante.idadhesion Adh_existante
        ,ad_ante.date_Adhe date_adh_existante
        ,ad_ante.date_fin_adhe   date_fin_adh_existante
        ,c1.numgar num_contrat_existant
        ,decode(c1.type_contrat,1,'SANTE',2,'PREVOYANCE') type_contrat
        ,ac.idadhesion nvelle_adh
        ,ac.date_adhe date_nvelle_adh
        ,c2.numgar num_nv_contrat
        ,decode(c2.type_contrat,1,'SANTE',2,'PREVOYANCE') type_nv_contrat
        ,f.numfor garantie
        ,decode(f.typgar,1,'BASE',2,'OPTION') garantie_base
        ,c1.numcli client
        ,ha.datsai date_saisie
        ,ha.motif motif
        from
        adhe_cntrt ad_ante
        , adhe_cntrt ac
        inner join gar_cntrt gc on gc.numgar = ac.numgar and gc.type = 1 -- santé
        inner join formule f on f.numfor = gc.numfor and f.typgar = 1 -- base uniquement
        , contrat c1
        , contrat c2
        , histo_adhesion ha
        , adhesion ad
        where ad_ante.IDADHESION <> ac.IDADHESION
        and ha.idadhesion = ad.idadhesion
        and c1.numgar = ad_ante.numgar
        and c2.numgar = ac.numgar
        --and c2.portefeuille not in (10,12,14,2,5,7)--exclusion des adhesions contrats options
        and ac.idadhesion = ha.idadhesion
        and ad_ante.numadhe = ac.numadhe
        and ad_ante.numadhe not in (select em.numindiv_dest
                                      from envoi_mail em
                                    where
                                      (
                                         (em.numindiv_dest = ad_ante.numadhe and em.idtexte in (5,24) and trunc(em.datemis) between trunc(add_months(sysdate,-1)) and trunc(sysdate)) -- Pas d'Emails de bienvenue depuis 1 mois glissant
                                       OR
                                        (em.numindiv_dest = ad_ante.numadhe and em.idtexte in (29) and sujet like '%IRIS%' and trunc(em.datemis) between trunc(add_months(sysdate,-1)) and trunc(sysdate)) -- Pas d'Emails d'AR compte IRIS depuis 1 mois glissant
                                      )
                                   )
        and ad_ante.DATE_ADHE < ac.DATE_ADHE
        -- exlusion des adh santé résiliées la veille d'une nvelle mise en vigueur
        and not exists (select 1 from adhe_cntrt
                          where adhe_cntrt.numadhe = ac.numadhe
                          and trunc(adhe_cntrt.date_fin_adhe) <= trunc(ac.date_adhe -1)
                          and   c1.type_contrat = 1)
        and sysdate between ad_ante.DATE_ADHE and nvl(add_months(ad_ante.DATE_FIN_ADHE,6),sysdate)
        and ha.IDHISTOADHE in (select max(idhistoadhe) from histo_adhesion where histo_adhesion.idadhesion = ha.idadhesion)
        and ha.motif = 57 --Pré-aff validée GEREP
        and ac.date_adhe <= ha.datsai -- en vigueur dans le passé uniquement
        and ac.date_adhe >= e2d('01/07/2021') -- adhésion en vigueur à partir du 1er juillet 2021
        and ha.datsai >=e2d('01/10/2021') -- saisie après la mise en vigueur
        and trunc(ha.datsai) <= trunc(sysdate-1) -- mais saisie à J-1 max dans le respect de la RG des Emails de bienvenues de type 3.
        order by adherent
      ) datas
     where datas.adherent in (433404,
                              519178,
                              320292,
                              458622,
                              392742,
                              481350,
                              522653,
                              504306,
                              483028,
                              519161,
                              518621,
                              464381,
                              491134,
                              379743,
                              431990,
                              518935,
                              314810,
                              505914,
                              309720,
                              494185,
                              521535)    -- Liste validée GEREP pr rattrapage du 20/10/2021
                              ;

BEGIN
 -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_VIGUEUR', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_ADHESION_VIGUEUR : debut traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('NASSU',F_NUMUTIL) THEN
    FOR rec_adhesion IN c_adhesions_reprises LOOP
    loc_envoi :=  io_envoi;
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_VIGUEUR',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_ADHESION_VIGUEUR : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
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

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_VIGUEUR_REPRISE',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END ;



/******************Procedure d''envoi des mails repris *****************/

PROCEDURE P_SEND_ALL_MAIL_JOB_REPRISE (i_type_mail IN NUMBER, i_date DATE)is
  -- MUR M0005764 ajout idtexte 33 - Accuse de reception demande affiliation  -  pour envoi du mail au fil de l'eau
  -- ABO M0005769 ajout idtexte 31 - mail hebdo pour RH recapitulatif
  -- PBO M0006241 Email manuel texte 34 a  envoyer le lendemain
  CURSOR c_liste_mails IS
  SELECT  numenvoimail FROM envoi_mail
    WHERE type_mail = i_type_mail
    AND nvl(etat,0) = 0 -- on prend les mails a envoyer
    AND datemis IS NULL -- double securite, on ne prend que les mail n'ayant pas de date d'emission.
    AND(  (i_type_mail = 2 AND NVL(IDTEXTE,0)!=34)         -- mail manuel different de texte 34 - ajout nvl sur idtexte M0006301
	  -- AND(  i_type_mail = 2-- mail manuel
      OR( i_type_mail = 2 AND IDTEXTE=34 AND TRUNC(date_creation)=TRUNC(i_date-1)) -- Email manuel texte 34 de la veille
       OR(
       ((i_type_mail = 1 AND TRUNC(date_creation)=TRUNC(i_date-1)) --mail unitaire auto genere au fil de l'eau la veille
        OR  ( i_type_mail = 3
          AND (TRUNC(date_creation)=TRUNC(i_date) OR
              (NUMENVOI_ORIGINE IS NOT NULL AND TRUNC(date_creation)=TRUNC(i_date-1) )
              ) -- prise en compte des email regenre de type masse
            )
          ) 
        AND idtexte in (select id_texte from mail_texte where actif = 1)  -- blocage des autre envoi de mail ( pris en compte uniquement pour les mails auto )
       )
     )
  UNION
    SELECT numenvoimail FROM envoi_mail   --EVO EXTRANET 2018 on envoi les accuses de reception Corbeille (type 3) en meme temps que les mails manuels
      WHERE type_mail = 3
      AND  i_type_mail= 2
      and  idtexte in (29 , 33)
      AND nvl(etat,0) = 0 -- on prend les mails a envoyer
      AND datemis IS NULL
     ;

  mails_in_error ty_mail_in_error;
  nb_msg_err NUMBER(5) :=0;
  nb_msg_err_copy NUMBER(5) :=0;
  nb_msg_tot NUMBER(5) :=0;
  date_session Date := i_date;
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
END P_SEND_ALL_MAIL_JOB_REPRISE;


END PK_MAIL_REPRISE;
/
