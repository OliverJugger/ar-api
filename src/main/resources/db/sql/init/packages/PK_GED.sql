CREATE OR REPLACE package ARTHUS.PK_GED as
-- $Rev ::                                        $ :  Revision du dernier commit
-- $Author ::                                     $ :  Auteur du dernier commit
-- $Date$ :  Date du dernier commit
-- $HeadURL$ :  Chemin
  /*========================================================================       */
  /* Package      : PK_GED.sql                                                     */
  /* Domaine      : PACKAGE responsable de la communication avec une GED           */
  /* Version      : V1.0                                                           */
  /* Auteur       : CLI                                                            */
  /* Création     : 09/08/2011                                                     */
  /* Description  : Package contenant les services exposés dans le cadre du projet */
  /*              : Extranet.                                                      */
  /* Projet       : P201609004_Extranet_assuré_GEREP, modifications	               */
  /* Evolution    :                                                                */
  /* Auteur       : CLI                                                            */
  /* Date         : 14/03/2017                                                     */
  /* Commentaire  :                                                                */
  /*==========================================================================     */
  /* Evolution   : CLI / 23072018 / AKIO                                           */
  /*==========================================================================     */
  /*                                                                               */
 PROCEDURE FLUSH_GED;
 PROCEDURE MOVE_EDITIONS;
 PROCEDURE FLUSH_AKIO_ADH;
 PROCEDURE FLUSH_AKIO_SOC;
 function f_get_conjoint(i_numindiv number) return varchar2 ;
END PK_GED;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_GED as
-- $Rev ::                                        $ :  Revision du dernier commit
-- $Author ::                                     $ :  Auteur du dernier commit
-- $Date$ :  Date du dernier commit
-- $HeadURL$ :  Chemin

PROCEDURE FLUSH_GED IS


  clob_list_adh clob;
  loc_repertoire  VARCHAR2(10);
  loc_fichier VARCHAR2(50);
  BEGIN
  /*A la différence du fichier du point a, c’est la colonne A qui sera vide (identifiant GED). Chaque ligne
  contiendra :
  - Nom de l’adhérent
  - Prénom de l’adhérent
  - N° de sécurité sociale de l’adhérent
  - Société de l’adhérent
  - Date de naissance de l’adhérent.
  - ID ARTHUS*/

  loc_repertoire:='GED';
  loc_fichier:='SYNC_ADH_GED_'||to_char(sysdate-1,'DD-MM-YYYY')||'.csv';


  SELECT dbms_xmlgen.convert(xmlagg(xmlelement(e,liste,'').extract('//text()')).GetClobVal(),1) INTO clob_list_adh  from (
    SELECT distinct';'||i.nom ||';'||i.prenom||';'||i.matorg||';'||TRIM(f_nom(c.numcli))||';'
    ||to_char(i.datnais,'dd/mm/yyyy')||';'||i.numindiv||';'|| CHR(13)||CHR(10) liste
    FROM ADHE_CNTRT a, HISTO_ADHESION h, INDIVIDU i, contrat c
    WHERE  a.idadhesion = h.idadhesion
    AND h.etat = 1
    AND i.numindiv= a.numadhe
    AND c.numgar = a.numgar
    AND trunc(h.datsai)=trunc(SYSDATE -1));

  IF clob_list_adh IS NOT NULL THEN
    clob_list_adh:='handle;nom;prenom;n SS;societe;date;id arthus;'|| CHR(13)||CHR(10)||clob_list_adh;
    DBMS_XSLPROCESSOR.clob2file( clob_list_adh
                                 , loc_repertoire
                                 , loc_fichier
                                );
   DBMS_XSLPROCESSOR.clob2file(   clob_list_adh
                                 , 'EXPORT'
                                 , loc_fichier
                                );
  END IF;

  EXCEPTION
   WHEN OTHERS THEN   PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_GED_FLUSH',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
END FLUSH_GED;




PROCEDURE MOVE_EDITIONS
IS
CURSOR C_EDITIONS IS
  SELECT numedit,
         decode(idtexte,
            17,'EA_HOSPI',
            6,'EA_DOSSIER',
            8,'EA_DOSSIER',
            9,'EA_DOSSIER',
            12,'EA_DOSSIER',
            30,'EA_TELE',
            NULL ) repertoire
  FROM envoi_mail
  WHERE TRUNC(DATE_CREATION) =  TRUNC(sysdate) - 1
    AND TYPE_MAIL = 1 -- automatique
    AND ETAT IN (0,1,2)
    AND NUMEDIT IS NOT NULL
  UNION
  SELECT numedit,
        'EA_DOSSIER' repertoire
  FROM ENVOI
  WHERE TRUNC(DATE_VALIDE) =  TRUNC(sysdate) - 1
    AND ETENDUE = 6
  UNION
  SELECT  distinct numedit,
          'EA_HOSPI' repertoire
  FROM ENVOI
  WHERE TRUNC(DATEMIS)= TRUNC(sysdate) - 1
    AND ETENDUE = 9
  UNION
  SELECT distinct to_number(t.numedit),
        'EA_TELE' repertoire
  FROM
    (SELECT MAX(numedit) numedit,
            pc.entite
    FROM  param_dmnde p,
          file_edition f,
          pieces pc
    WHERE f.numdmnde = p.numdmnde
      AND pc.contexte = 19
      AND valdeb1 = substr(pc.entite, 0, 6)
      AND TRUNC(pc.DATEAVIS) = TRUNC(SYSDATE)-1
      AND NVL(valdeb2,ltrim(substr(pc.entite,7),'0')) = ltrim(substr(pc.entite,7),'0')
      AND batchid = 'PE80T'
      AND f.execute IS NOT NULL
      AND status = 2    -- status édité uniquement
    GROUP BY pc.entite) t;

  rec_editions c_editions%rowtype;
BEGIN

    FOR rec_editions   IN    C_EDITIONS  LOOP
        IF  rec_editions.repertoire IS NOT NULL THEN
        BEGIN
          UTL_FILE.FCOPY ( 'EDITION', -- le repertoire édition dot être créé.
                           rec_editions.numedit||'.pdf',
                           rec_editions.repertoire,
                           rec_editions.numedit||'.pdf');
        EXCEPTION
          WHEN OTHERS THEN
             PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'PK_GED_EDIT',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 3);
             raise_application_error(-20000, 'Impossible de copier le fichier '
                                    || rec_editions.numedit||'.pdf de EDITION vers '|| rec_editions.repertoire);
          END;
        END IF;

    END LOOP;

END MOVE_EDITIONS;

/*******************************************************************************/

PROCEDURE FLUSH_AKIO_ADH IS


  clob_list_adh clob;
  loc_repertoire  VARCHAR2(10);
  loc_fichier VARCHAR2(50);
  BEGIN

  loc_repertoire:='AKIO';
  loc_fichier:='AKIO_ADH.csv';


  With individus as (
                  SELECT numindiv
                  from pers_adresse
                  where trunc(sysdate-1) = trunc(pers_adresse.maj) -- mise a jour d'adresse*/
                  UNION
                  SELECT adhe_cntrt.numadhe
                  from
                  adhe_cntrt, individu soc,contrat
                  where adhe_cntrt.numgar = contrat.numgar
                  AND contrat.numcli = soc.numindiv
                  AND trunc(sysdate-1)in ( trunc(soc.maj),-- mise a jour de la société
                                           trunc(soc.creation))
                  UNION
                  select distinct numindiv
                  from individu i
                  where  trunc(sysdate-1) in (trunc(i.creation),-- création de l'adhérent
                                              trunc(i.maj)-- mise a jour de l'adhérent
                                              )
                  UNION
                   select distinct numindiv
                   from contact ctc
                          where trunc(sysdate-1) in (trunc(ctc.creation), -- mise a jour du contact
                                                     trunc(ctc.maj)-- création du contact
                                                   )
                  UNION
                    select numindiv
                    from histo_courrier_info hci   -- modification du type 52
                    where hci.type_crrr= 52
                      and  trunc(sysdate-1) = trunc(DATE_HISTO)
                   UNION
                    SELECT numindiv
                    from adhesion               -- si une adhesion viens d'être instancié on prend la dernière ce qui changera le nom du produit
                    where sysdate between  datapli and nvl(adhesion.datper,sysdate)
                    and trunc(adhesion.creation) = trunc(sysdate-1)
                   )
SELECT dbms_xmlgen.convert(xmlagg(xmlelement(e,liste,'').extract('//text()')).GetClobVal(),1)
INTO clob_list_adh
              FROM (
            SELECT "N° d’adhérent"||';'
                  ||"Nom Société"||';'
                  ||"Nom produit"||';'
                  ||"Civilité"||';'
                  ||"Nom"||';'
                  ||"Prénom"||';'
                  ||"Date de naissance"||';'
                  ||"N° SS"||';'
                  ||"Code régime" ||';'
                  ||"Code caisse"||';'
                  ||"Code centre"||';'
                  || (select MIN (rang)  from adhesion
              where typfor = 1
              and sysdate between datapli and NVL(datper, sysdate)
              and numindiv = "N° d’adhérent"  )||';'
                  ||"Adresse1"||';'
                  ||"Adresse2"||';'
                  ||"Adresse3"||';'
                  ||codpos||';'
                  ||ville||';'
                  ||codeiso||';'
                  ||"Tel 1"||';'
                  ||"Tel 2"||';'
                  ||"Adresse mail"||';'
                  ||"Commentaires"||';'
                  ||"ref vip"||';'
                  ||"compte_actif"||';'
                  ||pk_ged.f_get_conjoint("N° d’adhérent")||';'
                  || CHR(13)||CHR(10) liste
              FROM
            (
            SELECT DISTINCT
                  a.numadhe as "N° d’adhérent",
                  f_nom(c.numcli) as "Nom Société",
                  p.libelle as"Nom produit",
                  F_LBLE('QLTE',i.QUALITE) as "Civilité",
                  i.nom as "Nom",
                  i.prenom as "Prénom",
                  d2e(i.datnais) as "Date de naissance",
                  i.matorg as "N° SS",
                  i.regime as "Code régime" ,
                  i.caisse as "Code caisse",
                  i.guichetorg "Code centre",
                  pk_personne.f_recompose( ad.no_voie, ad.bis,ad.type_voie,ad.nom_voie, 90 ) as "Adresse1",
                  ad.adresse_2 as "Adresse2",
                  ad.comp_adresse as "Adresse3",
                  ad.codpos,
                  ad.ville,
                  pays.codeiso,
                  replace(replace(replace(F_COORDONNE_CONTACT(i.NUMINDIV,1,1),' ',''),'.',''),'-','') as "Tel 1",
                  replace(replace(replace(F_COORDONNE_CONTACT(i.NUMINDIV,1,2),' ',''),'.',''),'-','') as "Tel 2",
                  F_COORDONNE_CONTACT(i.NUMINDIV,4,2) as "Adresse mail",
                  null as "Commentaires",
                  i.refcie as "ref vip",
                  decode(ci.moyen_info, 2,'OUI', 'NON') "compte_actif"
                  from adhe_cntrt a , contrat c, produit p,individu soc ,individus, individu i
                  left outer join courrier_info ci on i.numindiv = ci.numindiv and type_crrr = 52
                  left outer join pers_adresse ad on ( ad.numindiv = i.numindiv  and ad.idadresse =pk_personne.f_idadresse(i.numindiv)  )
                  left outer join pays on (  ad.codpays = pays.codpays  )
                  where NVL(date_fin_adhe,sysdate)> add_months(sysdate,-24)
                  AND  a.numadhe = individus.numindiv
                  and  a.numadhe = i.numindiv
                  and  a.numgar  = c.numgar
                  and  c.numprod = p.numprod
                  and  c.numcli = soc.numindiv

                  -- and (F_COORDONNE_CONTACT(i.NUMINDIV,4,2) is not null OR  NVL(F_COORDONNE_CONTACT(i.NUMINDIV,4,2), F_COORDONNE_CONTACT(i.NUMINDIV,4,1)) is  null )
                  and a.idadhesion IN (
                    select max(idadhesion) from adhesion
                    where
                    NVL(datper,sysdate)> add_months(sysdate,-24)
                    and numindiv = a.numadhe
                    and typfor=1)
           UNION
              select distinct
                  a.numadhe as "N° d’adhérent",
                  f_nom(c.numcli) as "Nom Société",
                  p.libelle as"Nom produit",
                  F_LBLE('QLTE',i.QUALITE) as "Civilité",
                  i.nom as "Nom",
                  i.prenom as "Prénom",
                  d2e(i.datnais) as "Date de naissance",
                  i.matorg as "N° SS",
                  i.regime as "Code régime" ,
                  i.caisse as "Code caisse",
                  i.guichetorg "Code centre",

                   pk_personne.f_recompose( ad.no_voie, ad.bis,ad.type_voie,ad.nom_voie, 90 ) as "Adresse1",
                   ad.adresse_2 as "Adresse2",
                    ad.comp_adresse as "Adresse3",
                  ad.codpos,
                  ad.ville,
                  pays.codeiso,
                   replace(replace(replace(F_COORDONNE_CONTACT(i.NUMINDIV,1,1),' ',''),'.',''),'-','') as "Tel 1",
                   replace(replace(replace(F_COORDONNE_CONTACT(i.NUMINDIV,1,2),' ',''),'.',''),'-','') as "Tel 2",
                  F_COORDONNE_CONTACT(i.NUMINDIV,4,1) as "Adresse mail",
                  null as "Commentaires",
                  i.refcie as "ref vip" ,
                  decode(ci.moyen_info, 2,'OUI', 'NON') "compte_actif"
                  from adhe_cntrt a , contrat c, produit p , individu soc,individus,contact ct , individu i
                  left outer join courrier_info ci on i.numindiv = ci.numindiv and type_crrr = 52
                  left outer join pers_adresse ad on ( ad.numindiv = i.numindiv  and ad.idadresse =pk_personne.f_idadresse(i.numindiv)  )
                  left outer join pays on (  ad.codpays = pays.codpays  )
                  where NVL(date_fin_adhe,sysdate)> add_months(sysdate,-24)
                  AND  a.numadhe =  individus.numindiv
                  and  a.numadhe = i.numindiv
                  and  a.numgar  = c.numgar
                  and  c.numprod = p.numprod
                  and  c.numcli = soc.numindiv
                  AND ct.nature = 4 and ct.type=1 and ct.numindiv = i.numindiv and ct.coordonnee is not null and ct.flag ='O'
                 -- and F_COORDONNE_CONTACT(i.NUMINDIV,4,1) is not null
                  and a.idadhesion IN (
                    select MAX(idadhesion) from adhesion
                    where  NVL(datper,sysdate)> add_months(sysdate,-24)
                    and numindiv = a.numadhe
                    and typfor=1)
                            )
              );



  IF clob_list_adh IS NOT NULL THEN
    clob_list_adh:='N° d’adhérent;Nom Société;Nom produit;Civilité;Nom;Prénom;Date de naissance;N° SS;Code régime;Code caisse;Code centre;rang;Adresse1;Adresse2;Adresse3;CODPOS;VILLE;NOM;Tel 1;Tel 2;Adresse mail;Commentaires;ref vip;compte_actif;numassuetconj;'|| CHR(13)||CHR(10)||clob_list_adh;
    DBMS_XSLPROCESSOR.clob2file( clob_list_adh
                                 , loc_repertoire
                                 , loc_fichier
                                );
    loc_fichier:='AKIO_ADH_'||to_char(sysdate,'DD-MM-YYYY')||'.csv';
    DBMS_XSLPROCESSOR.clob2file(   clob_list_adh
                                 , 'EXPORT'
                                 , loc_fichier
                                );
  END IF;

  EXCEPTION
   WHEN OTHERS THEN   PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'FLUSH_AKIO',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
END FLUSH_AKIO_ADH;

/*******************************************************************************/
PROCEDURE FLUSH_AKIO_SOC IS


  clob_list_adh clob;
  loc_repertoire  VARCHAR2(10);
  loc_fichier VARCHAR2(50);
  BEGIN

  loc_repertoire:='AKIO';
  loc_fichier:='AKIO_SOC.csv';

  SELECT dbms_xmlgen.convert(xmlagg(xmlelement(e,liste,'').extract('//text()')).GetClobVal(),1) INTO clob_list_adh
      FROM (
     SELECT   "Nom société"||';'
            ||"N° société"||';'
            ||num_interloc1||';'
            ||nom_interloc1||';'
            ||"ope1"||';'
            ||tel_interloc1||';'
            ||mail_interloc1||';'
            ||num_interloc2||';'
            ||nom_interloc2||';'
            ||"ope2"||';'
            ||tel_interloc2||';'
            ||mail_interloc2||';'
            ||num_interloc3||';'
            ||nom_interloc3||';'
            ||"ope3"||';'
            ||tel_interloc3||';'
            ||mail_interloc3||';'
            ||"N° de SIRET"||';'
            ||"Adresse1"||';'
            ||"Adresse2"||';'
            ||"Adresse3"||';'
            ||codpos ||';'
            ||ville||';'
            ||"PAYS"||';'
            ||"Tel sté"||';'
            ||"Adresse sté"||';'||CHR(10)||chr(13) liste
FROM (SELECT DISTINCT
            f_nom(c.numcli) as "Nom société",
            c.numcli as "N° société",
            i1.interlocuteur num_interloc1,
            f_nom(i1.interlocuteur) nom_interloc1,
            pk_libelle.f_lib('OPE_CRRR',i1.ope_crrr) as "ope1",
            F_COORDONNE_CONTACT(i1.interlocuteur,1,1) tel_interloc1,
            F_COORDONNE_CONTACT(i1.interlocuteur,4,1) mail_interloc1,
            i2.interlocuteur num_interloc2,
            decode(i2.interlocuteur,NULL,'',f_nom(i2.interlocuteur)) nom_interloc2,
            decode(i2.interlocuteur,NULL,'',pk_libelle.f_lib('OPE_CRRR',i2.ope_crrr)) as "ope2",
            decode(i2.interlocuteur,NULL,'',F_COORDONNE_CONTACT(i2.interlocuteur,1,1)) tel_interloc2,
            decode(i2.interlocuteur,NULL,'',F_COORDONNE_CONTACT(i2.interlocuteur,4,1)) mail_interloc2,
            i3.interlocuteur num_interloc3,
            decode(i3.interlocuteur,NULL,'',f_nom(i3.interlocuteur)) nom_interloc3,
            decode(i3.interlocuteur,NULL,'',pk_libelle.f_lib('OPE_CRRR',i3.ope_crrr)) as "ope3",
            decode(i3.interlocuteur,NULL,'',F_COORDONNE_CONTACT(i3.interlocuteur,1,1)) tel_interloc3,
            decode(i3.interlocuteur,NULL,'',F_COORDONNE_CONTACT(i3.interlocuteur,4,1)) mail_interloc3,
            p.siret as "N° de SIRET",
            pk_personne.f_recompose( ad.no_voie, ad.bis,ad.type_voie,ad.nom_voie, 90 ) as "Adresse1",
            ad.adresse_2 as "Adresse2",
            ad.comp_adresse as "Adresse3",
            ad.codpos ,
            ad.ville,
            pays.codeiso as "PAYS",
            replace(replace(replace(F_COORDONNE_CONTACT(p.numindiv,1,1),' ',''),'.',''),'-','') as "Tel sté",
            F_COORDONNE_CONTACT(p.numindiv,4,1) as "Adresse sté"
            /*Adresse mail 2
            Commentaires*/
            FROM pers_morale p, pers_adresse ad ,pays, contrat c --left outer join affil_fichier af
            --ON (af.datefic =e2d('01/04/2018') and af.numcli is not null and af.numcli =c.numcli)
            LEFT OUTER JOIN interlocuteur i1  on( i1.numindiv  =c.numcli and i1.valide ='O')
            LEFT OUTER JOIN interlocuteur i2  on( i2.numindiv  =c.numcli and i2.valide ='O' and I2.Idinterlocuteur > NVL(I1.Idinterlocuteur,900000))
            LEFT OUTER JOIN interlocuteur i3  on( i3.numindiv  =c.numcli and i3.valide ='O' and I3.Idinterlocuteur > NVL(I2.Idinterlocuteur,900000))
            where p.numindiv=c.numcli
            --AND   nvl(F_COORDONNE_CONTACT(p.numindiv,1,1) ,F_COORDONNE_CONTACT(p.numindiv,4,1)  ) is not null
            AND c.type_contrat in( 1,4)
            AND pk_histo_contrat.f_sel_etat(c.numgar) = 1
            AND ad.idadresse = pk_personne.f_idadresse(p.numindiv)
            AND ad.codpays = pays.codpays
            AND EXISTS (
              SELECT 1 from CONTACT CTC
              WHERE ctc.numindiv  IN (i1.numindiv,i2.numindiv ,i3.numindiv)
             /* AND (ctc.creation between e2d('10/07/2018') and e2d('18/07/2018')
              OR ctc.maj between e2d('10/07/2018') and e2d('18/07/2018')
              OR p.creation between e2d('10/07/2018') and e2d('18/07/2018'))*/
              and  trunc(SYSDATE-1) IN(trunc(ctc.creation), trunc(ctc.maj), trunc(p.creation))

               )
            )  );



  IF clob_list_adh IS NOT NULL THEN
    clob_list_adh:='Nom société;N° société;num_interloc1;nom_interloc1;ope1;tel_interloc1;mail_interloc1;num_interloc2;nom_interloc2;ope2;tel_interloc2;mail_interloc2;num_interloc3;nom_interloc3;ope3;tel_interloc3;mail_interloc3;N° de SIRET;Adresse1;Adresse2;Adresse3;codpos;ville;PAYS;Tel sté;Adresse sté;'|| CHR(13)||CHR(10)||clob_list_adh;
    DBMS_XSLPROCESSOR.clob2file(   clob_list_adh
                                 , loc_repertoire
                                 , loc_fichier
                                );
   loc_fichier:='AKIO_SOC_'||to_char(sysdate,'DD-MM-YYYY')||'.csv';
   DBMS_XSLPROCESSOR.clob2file(   clob_list_adh
                                 , 'EXPORT'
                                 , loc_fichier
                                );
  END IF;

  EXCEPTION
   WHEN OTHERS THEN   PK_trace.P_INS_journal_adm (
              I_nom_traitement => 'FLUSH_AKIO',
              I_session  => SID,
              I_niv_msg  => 3,
              I_msg_adm  => substr(sqlerrm,1,132),
              I_idligne  => 2);
END FLUSH_AKIO_SOC;


function f_get_conjoint(i_numindiv number) return varchar2  IS
loc_couple varchar2(20):=to_char(i_numindiv);
BEGIN

  select distinct individu.numassu||'|'||individu.numindiv
  into loc_couple
  from adhesion,
       adhe_cntrt,
       individu
  where   adhe_cntrt.numadhe = i_numindiv
    and individu.numassu =  adhe_cntrt.numadhe
    and adhe_cntrt.idadhesion = adhesion.idadhesion
    and adhesion.DATPER is null
    and individu.typadr in (1,3,7)
  ;

  return  loc_couple;
exception when others then
return to_char(i_numindiv);
END f_get_conjoint;
END PK_GED;
/
