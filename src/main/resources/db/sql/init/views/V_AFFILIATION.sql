CREATE FORCE VIEW ARTHUS.V_AFFILIATION AS
SELECT DISTINCT affil_porte.numporte
        , affil_porte.numremise
        , affil_fichier.datefic
        , affil_fichier.ENTREPRISE
        , affil_fichier.ETABLI
        , affil_fichier.num_ordre
        , affil_fichier.NUMCLI
        , affil_porte.NUMLIGNE
        , affil_porte.numindiv
        , decode(affil_porte.numindiv,NULL,NVL(affil_porte.nomnais,affil_porte.nomsal)||' '||affil_porte.prenom, UPPER(f_nom(affil_porte.numindiv))) nom_affilie
        , affil_porte.type_mvt
        , affil_porte.fincon
        , affil_porte.etat
        , affil_porte_adh.numgar
        , affil_porte_adh.idadhesion
        , decode(affil_porte_adh.idadhesion, null, null,f_etat_adhe(affil_porte_adh.idadhesion,sysdate,1)) etat_adhesion
        , (SELECT MIN(decode(ACTION,'U', 'M','D','S','I','C',ACTION))
          FROM AFFIL_TRACE
          WHERE OBJET = 'ADHE_CNTRT'
          AND NUMREMISE = AFFIL_PORTE_ADH.NUMREMISE
          AND NUMPORTE =AFFIL_PORTE.NUMPORTE
          AND NUMLIGNE = AFFIL_PORTE_ADH.NUMLIGNE
          AND CLEF = AFFIL_PORTE_ADH.IDADHESION) FLAG_ADH
        ,(SELECT MIN(decode(ACTION,'U', 'M','D','S','I','C',ACTION))
            FROM AFFIL_TRACE
            WHERE OBJET = 'INDIVIDU'
            AND NUMREMISE = AFFIL_PORTE.NUMREMISE
            AND NUMPORTE =AFFIL_PORTE.NUMPORTE
            AND NUMLIGNE =AFFIL_PORTE.NUMLIGNE) FLAG_INDIV
        , (SELECT MIN(decode(ACTION,'U', 'M','D','S','I','C',ACTION))
            FROM AFFIL_TRACE
            WHERE OBJET = 'PERS_ADRESSE'
            AND NUMREMISE = AFFIL_PORTE.NUMREMISE
            AND NUMPORTE =AFFIL_PORTE.NUMPORTE
            AND NUMLIGNE = AFFIL_PORTE.NUMLIGNE) FLAG_ADR
        , (SELECT decode (COUNT(NUMORDRE),0,'N','O')
            FROM AFFIL_PORTE_FORCAGE
            WHERE NUMREMISE = AFFIL_PORTE.NUMREMISE
            AND NUMPORTE =AFFIL_PORTE.NUMPORTE
            AND NUMLIGNE = AFFIL_PORTE.NUMLIGNE) FLAG_FORC
        , decode (ARTHUS.pk_mail.CHECK_DEMAT_INDIV(affil_porte.numindiv ),1,'D','') FLAG_DEMAT
    FROM porte_remise, porte_param, affil_fichier ,affil_porte
    left outer join affil_porte_adh ON (
      affil_porte_adh.numremise = affil_porte.numremise
      AND affil_porte_adh.numporte = affil_porte.numporte
      AND affil_porte_adh.numligne = affil_porte.numligne
      AND affil_porte_adh.numayd=0)
    WHERE porte_remise.numporte = porte_param.numporte
    AND affil_fichier.numporte = porte_remise.numporte
    AND affil_fichier.numremise = porte_remise.numremise
    AND affil_porte.numremise = affil_fichier.numremise
    AND affil_porte.numporte = affil_fichier.numporte
    AND affil_porte.num_ordre = affil_fichier.num_ordre
    AND affil_porte.entreprise = affil_fichier.entreprise
    AND affil_porte.etabli = affil_fichier.etabli
    AND affil_fichier.num_annulante IS NULL
GO
CREATE OR REPLACE PUBLIC SYNONYM V_AFFILIATION FOR ARTHUS.V_AFFILIATION
