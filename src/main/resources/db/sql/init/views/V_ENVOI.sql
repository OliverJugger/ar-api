CREATE FORCE VIEW ARTHUS.V_ENVOI AS
SELECT   numenvoimail,
        NULL numero,
        datemis,
        'Mail' AS TYPE,
        sujet,
        util.nom AS traite,
        numedit,
        DECODE (pc1 || pc2 || pc3 || pc4, NULL, 'N', 'O') AS lien,
        numindiv_dest,
        numbene,
        envoi_mail.idtexte,
        null as code,
            envoi_mail.numutil,
            envoi_mail.etendue,
            envoi_mail.clef,
            envoi_mail.TYPE_MAIL,
            envoi_mail.DATE_CREATION,
            envoi_mail.ETAT,
            null as VALIDE,
            null as DATE_VALIDE,
            null as NUMUTIL_VAL,
            null as INVALIDE,
            null as DATE_INVALIDE,
            null as NUMUTIL_INVAL,
            individu.nom ||' '||individu.prenom   as NOM_DEST,
            NUMENVOI_ORIGINE
       FROM envoi_mail, util, individu
      WHERE util.numutil = envoi_mail.numutil
        AND individu.numindiv = numindiv_dest
   UNION ALL  -- pas de controle de doublon => augmentation de la vitesse
   SELECT   numenvoi, envoi.numero, datemis, 'Courrier' AS TYPE,
            nom_crrr || ' ' || lib_para, nom AS traite, numedit,
            DECODE (numedit, NULL, 'N', 'O') AS lien, numindiv_dest, numbene,
            param_texte.idtexte,
            DECODE (param_texte.code,
                    2, 1,
                    6, 1,
                    23, 1,
                    3, 2,
                    4, 2,
                    24, 2,
                    8, 3,
                    21, 3,
                    14, 4,
                    22, 4,
                    7, 5,
                    13, 6,
                    11, 7,
                    27, 8,
                    9, 9,
                    NULL
                   ) code,
            envoi.numutil,
            envoi.etendue,
            envoi.clef,
            null as TYPE_MAIL,
            null as DATE_CREATION,
            null as ETAT,
            VALIDE as VALIDE,
            DATE_VALIDE as DATE_VALIDE,
            NUMUTIL_VAL as NUMUTIL_VAL,
            INVALIDE as INVALIDE,
            DATE_INVALIDE as DATE_INVALIDE,
            NUMUTIL_INVAL as NUMUTIL_INVAL,
            ARTHUS.pk_personne.f_nom(numindiv_dest),
            null as NUMENVOI_ORIGINE
       FROM envoi, param_texte, util
      WHERE envoi.idtexte = param_texte.idtexte
        AND util.numutil = envoi.numutil
        AND NOT EXISTS (SELECT 1        --on evite d'afficher le courrier si il est déjà envoyé par mail.
                          FROM envoi_mail
                         WHERE envoi_mail.numedit = envoi.numedit AND envoi_mail.type_mail = 2)
   ORDER BY datemis DESC
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ENVOI FOR ARTHUS.V_ENVOI
