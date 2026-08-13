CREATE PROCEDURE ARTHUS.QTTC_VENTIL (a_numquit IN NUMBER
                     , a_signe   IN NUMBER DEFAULT 1
                     )
IS
/*===========================================================================*/
/* Procedure    : qttc_ventil.sql                                            */
/* Domaine      : Cotisation/Tresorerie                                      */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : DD/MM/AAAA                                                 */
/* Description  : ventilation des affectations de cotisations                */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : JBO / 25/06/2018 / ajout du 2ème paramétre pour coller à la*/
/*                V6. Mais attention cette version ne prend pas en compte le */
/*                commissionement V6, M3947...                               */
/*===========================================================================*/
loc_ratio  number;
loc_delta  number;
loc_ratio_d  number;
loc_delta_d  number;
loc_mt_frais  number;
loc_mt_reel  number;
loc_mt_affec  number;
loc_mt_frais_d  number;
loc_mt_reel_d  number;
loc_mt_affec_d  number;
loc_monnaie  number;
loc_monnaie_d  number;

Cursor fetch_affec is
  Select  idaffec,
      montant,
            monnaie,
            montant_d,
            monnaie_d
  From  qttc_affec
  Where  numquit = a_numquit
  And  numfor = -1;
loc_affec  fetch_affec%Rowtype;
BEGIN
For loc_affec in fetch_affec
loop
  /* On determine le ratio du reste a affecter   */

  Begin
     Select  loc_affec.montant / decode( qttc_global.mt_ttc,0,1,
          pk_funct.f_arrondi(4,
            qttc_global.numquit,
            qttc_global.mt_ttc) ),

      loc_affec.montant_d / decode( qttc_global.mt_ttc_d,0,1,
          pk_funct.f_arrondi(4,
            qttc_global.numquit,
            qttc_global.mt_ttc_d) ),
    qttc_global.mt_ttc,
                qttc_global.monnaie,
                qttc_global.mt_ttc_d,
                qttc_global.monnaie_d
  Into  loc_ratio,
            loc_ratio_d,
      loc_mt_reel,
            loc_monnaie,
            loc_mt_reel_d,
            loc_monnaie_d
  From  qttc_global
  Where  qttc_global.numquit = a_numquit
  And  qttc_global.mt_ttc is not null
        And  qttc_global.mt_ttc_d is not null;
  Exception When No_data_found then Exit;
  End;

  /* On retablit le montant a affecter par rapport au montant calcule */

   loc_mt_affec   := loc_mt_reel * loc_ratio;
   loc_mt_affec_d := loc_mt_reel_d * loc_ratio_d;

  /* On insere dans qttc_affec une ligne par garantie /assure */
  BEGIN
      Insert into qttc_affec
    (idaffec, idgar, numquit, numfor,
     numindiv, montant,monnaie,montant_d,monnaie_d,idrevers)
   ----- Revu par NS 25-07-2005 --- ---
   SELECT ALL loc_affec.idaffec,
         QTTC_GAR.IDGAR,
         a_numquit,
         QTTC_GAR.NUMFOR,
         QTTC_GAR.NUMINDIV,
         QTTC_GAR.MT_TTC*loc_ratio,
         QTTC_GAR.MONNAIE,
         QTTC_GAR.MT_TTC_D*loc_ratio_d,
         QTTC_GAR.MONNAIE_D,
         0
    FROM QTTC_GAR
    WHERE (QTTC_GAR.NUMQUIT = a_numquit
      AND QTTC_GAR.MT_TTC<>0
      AND QTTC_GAR.MT_TTC_D<>0);
  END;
   ----- Revu par NS 25-07-2005 --- ---

  /* On insere les frais dans affec_tfc */

  Begin
    BEGIN
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv,tfc, type_tfc, numbene,
                          montant,monnaie,montant_d,monnaie_d,idrevers)
        ----- Revu par NS 25-07-2005 --- --------------------
    SELECT ALL loc_affec.idaffec,
           a_numquit,
           QTTC_FRAIS.NUMFOR,
           0,
           DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3),
           QTTC_FRAIS.TYPE_FRAIS,
           QTTC_FRAIS.NUMBENE,
           SUM(QTTC_FRAIS.MONTANT)*loc_ratio,
           QTTC_FRAIS.MONNAIE,
           SUM(QTTC_FRAIS.MONTANT_D)*loc_ratio_d,
           QTTC_FRAIS.MONNAIE_D,
           0
      FROM QTTC_FRAIS
      WHERE QTTC_FRAIS.NUMQUIT = a_numquit
      GROUP BY QTTC_FRAIS.NUMFOR,
          DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3),
          QTTC_FRAIS.TYPE_FRAIS,
          QTTC_FRAIS.NUMBENE,
          QTTC_FRAIS.MONNAIE,
          QTTC_FRAIS.MONNAIE_D
      HAVING (SUM(QTTC_FRAIS.MONTANT)<>0
        AND SUM(QTTC_FRAIS.MONTANT_D)<>0) ;
    END;

    ----- Revu par NS 25-07-2005 --- --------------------

  /* On re-calcule la somme des frais affectes */
  ----- Revu par NS 25-07-2005 --- ----
    BEGIN
     SELECT ALL NVL(SUM(QTTC_AFFEC_TFC.MONTANT), 0),
            QTTC_AFFEC_TFC.MONNAIE,
            NVL(SUM(QTTC_AFFEC_TFC.MONTANT_D), 0),
            QTTC_AFFEC_TFC.MONNAIE_D
      Into  loc_mt_frais,
          loc_monnaie,
          loc_mt_frais_d,
          loc_monnaie_d
      FROM QTTC_AFFEC_TFC
      WHERE (QTTC_AFFEC_TFC.IDAFFEC = loc_affec.idaffec
        AND QTTC_AFFEC_TFC.TFC IN (3, 4))
      GROUP BY QTTC_AFFEC_TFC.MONNAIE,
           QTTC_AFFEC_TFC.MONNAIE_D ;
    EXCEPTION
       WHEN No_Data_Found THEN
        loc_monnaie   := 1;
        loc_monnaie_d  := 1;
                loc_mt_frais   := 0;
                loc_mt_frais_d := 0;
    END;
    ----- Revu par NS 25-07-2005 --- ---
  End;

  /* On determine le delta eventuel (Total encaisse - total affecte) */
  ----- Revu par NS 25-07-2005 --- -------
  BEGIN
  SELECT ALL loc_mt_affec - SUM(QTTC_AFFEC.MONTANT) - loc_mt_frais,
        QTTC_AFFEC.MONNAIE,
        loc_mt_affec_d - SUM(QTTC_AFFEC.MONTANT_D) - loc_mt_frais_d,
        QTTC_AFFEC.MONNAIE_D
    Into  loc_delta,
                loc_monnaie,
                loc_delta_d,
                loc_monnaie_d
    FROM QTTC_AFFEC
    WHERE (QTTC_AFFEC.IDAFFEC = loc_affec.idaffec
      AND QTTC_AFFEC.IDGAR<>0)
    GROUP BY QTTC_AFFEC.MONNAIE,
         QTTC_AFFEC.MONNAIE_D;
  Exception When No_data_found then
       loc_monnaie   := 1;
       loc_monnaie_d  := 1;
       loc_mt_frais  := 0;
       loc_mt_frais_d  := 0;
  END;
  ----- Revu par NS 25-07-2005 --- -------

  /* Qu'on affecte sur la premiere garantie */

  If ( loc_delta != 0 or loc_delta_d != 0) Then

    Begin
         Update  qttc_affec
         Set  montant   = montant + loc_delta,
                                monnaie   =loc_monnaie,
                                montant_d = montant_d + loc_delta_d,
                                monnaie_d =loc_monnaie_d
         Where  qttc_affec.idaffec = loc_affec.idaffec
         And  qttc_affec.idgar != 0
         and  rownum = 1;
         Exception When No_data_found then null;
    End;
  End if;

  /*  On met a jour le montant total affecte pour la garantie  */

     Update  qttc_gar
  Set  qttc_gar.mt_affec   = (select  sum(nvl(qttc_affec.montant,0))
                     from   qttc_affec
                     where  qttc_affec.numquit = a_numquit
                     and  qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.monnaie    = (select distinct(qttc_affec.monnaie)
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.mt_affec_d = (select sum(nvl(qttc_affec.montant_d,0))
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     ),
                qttc_gar.monnaie_d  = (select distinct( qttc_affec.monnaie_d)
                     from  qttc_affec
                     where qttc_affec.numquit = a_numquit
                     and   qttc_affec.idgar = qttc_gar.idgar
                     )
  Where  qttc_gar.numquit = a_numquit
  and qttc_gar.mt_ttc<>0
  and qttc_gar.mt_ttc_d<>0;

  /* On affecte les comm et les taxes */

  Begin
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv, tfc,
              type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers, prelev_revers)
    ----- Revu par NS 25-07-2005 --- --------------
    SELECT ALL loc_affec.idaffec,
          a_numquit,
          QTTC_COMM.NUMFOR,
          0,
          2,
          QTTC_COMM.TYPE_COMM,
          QTTC_COMM.NUMBENE,
          SUM(QTTC_COMM.MONTANT)*loc_ratio,
          QTTC_COMM.MONNAIE,
          SUM(QTTC_COMM.MONTANT_D)*loc_ratio_d,
          QTTC_COMM.MONNAIE_D,
          0,
          QTTC_COMM.PRELEV_REVERS
      FROM QTTC_COMM
      WHERE QTTC_COMM.NUMQUIT = a_numquit
      GROUP BY QTTC_COMM.NUMFOR,
           QTTC_COMM.TYPE_COMM,
           QTTC_COMM.NUMBENE,
           QTTC_COMM.PRELEV_REVERS,
           QTTC_COMM.MONNAIE,
           QTTC_COMM.MONNAIE_D
      HAVING (SUM(QTTC_COMM.MONTANT)<>0
        AND SUM(QTTC_COMM.MONTANT_D)<>0);
    ----- Revu par NS 25-07-2005 --- --------------

  Exception When No_data_found then null;
  End;

  Begin
      Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv, tfc,
              type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers, prelev_revers)
    ----- Revu par NS 25-07-2005 --- -------------
    SELECT ALL loc_affec.idaffec,
          a_numquit,
          QTTC_RETRO.NUMFOR,
          0,
          5,
          QTTC_RETRO.TYPE_COMM,
          QTTC_RETRO.NUMBENE,
          SUM(QTTC_RETRO.MONTANT)*loc_ratio,
          QTTC_RETRO.MONNAIE,
          SUM(QTTC_RETRO.MONTANT_D)*loc_ratio_d,
          QTTC_RETRO.MONNAIE_D,
          DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0),
          QTTC_RETRO.PRELEV_REVERS
      FROM QTTC_RETRO
      WHERE QTTC_RETRO.NUMQUIT = a_numquit
      GROUP BY QTTC_RETRO.NUMFOR,
           QTTC_RETRO.TYPE_COMM,
           QTTC_RETRO.NUMBENE,
           QTTC_RETRO.MONNAIE,
           QTTC_RETRO.MONNAIE_D,
           DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0),
           QTTC_RETRO.PRELEV_REVERS
      HAVING (SUM(QTTC_RETRO.MONTANT)<>0
        AND SUM(QTTC_RETRO.MONTANT_D)<>0);
   ----- Revu par NS 25-07-2005 --- ------------------

  Exception When No_data_found then null;

  End;

  Begin
          Insert into qttc_affec_tfc
             (idaffec, numquit, numfor, numindiv,
              tfc, type_tfc, numbene, montant,monnaie,montant_d,monnaie_d,idrevers)
          ----- Revu par NS 25-07-2005 ---
          SELECT ALL loc_affec.idaffec,
                     a_numquit,
               QTTC_TAXE.NUMFOR,
               0,
               1,
               QTTC_TAXE.TYPE_TAXE,
               QTTC_TAXE.NUMBENE,
               SUM(QTTC_TAXE.MONTANT)* loc_ratio,
               QTTC_TAXE.MONNAIE,
               SUM(QTTC_TAXE.MONTANT_D)*loc_ratio_d,
               QTTC_TAXE.MONNAIE_D,
               0
          FROM QTTC_TAXE
          WHERE QTTC_TAXE.NUMQUIT = a_numquit
          GROUP BY QTTC_TAXE.NUMFOR,
               QTTC_TAXE.TYPE_TAXE,
               QTTC_TAXE.NUMBENE,
               QTTC_TAXE.MONNAIE,
               QTTC_TAXE.MONNAIE_D
          HAVING (SUM(QTTC_TAXE.MONTANT)<>0
            AND SUM(QTTC_TAXE.MONTANT_D)<>0) ;
          ----- Revu par NS 25-07-2005 ---
  Exception When No_data_found then null;

  End;

  /* On marque l'idaffec comme etant ventile */

  Update  qttc_affec
  Set  numfor = 0,
    idrevers = -1
  Where  qttc_affec.idaffec = loc_affec.idaffec
  And  qttc_affec.numquit = a_numquit
  and  qttc_affec.idgar = 0;

end loop;
END;
/
