CREATE FORCE VIEW ARTHUS.V_COMPTA511 AS
select      T.numinterm                                                 numsoc
            ,f_cpta_role (T.numfor, 1, 2)                       rolesoc
            ,'qttc'                                                   sur_entite
            ,T.numquit                                      cle_unique
            ,'reversement'                                                entite
            ,1                                                         reg_piece
            ,T.idrevers                                            cle
            ,T.idcompta                                       idcompta
            ,511                                                          codope
            ,''                                                           scdope
            ,''                                                          codjnal
            ,1                                                          type_ope
            ,T.numorg                                              cie
            ,T.numquerable                                        indv
            ,T.numfor                                               gar
            ,0                                                               int
            ,''                                                              bqe
            ,substr(to_char(T.idrevers, '00000000'), 2, 8)
           || TO_CHAR (T.datvalide,'DDMMYY')                refpiece
             ,T.datvalide                                     dat_piece
            ,T.numquit                                      lib_piece_1
            ,T.numquerable                                 lib_piece_2
            ,T.mt_prime                                                 montant1
            ,T.mt_com1                                                  montant2
            ,T.mt_com2                                                  montant3
            ,T.mt_com3                                                  montant4
            ,T.mt_prime - T.mt_com1 - T.mt_com2 - T.mt_com3             montant5
            ,0                                                          montant6
            ,0                                                          montant7
            ,0                                                          montant8
            ,0                                                          montant9
            ,0                                                         montant10
            ,0                                                         montant11
            ,0                                                         montant12
            ,0                                                         montant13
            ,0                                                         montant14
            ,0                                                         montant15
            ,0                                                         montant16
            ,0                                                         montant17
            ,0                                                         montant18
            ,0                                                         montant19
            ,0                                                         montant20
            ,0                                                         montant21
            ,0                                                         montant22
            ,0                                                         montant23
            ,0                                                         montant24
            ,0                                                         montant25
            ,0                                                         montant26
            ,0                                                         montant27
            ,0                                                         montant28
            ,0                                                         montant29
            ,0                                                         montant30
            ,T.monnaie_d                                                  devise
            ,T.mt_prime                                              montant1_ct
            ,T.mt_com1                                               montant2_ct
            ,T.mt_com2                                               montant3_ct
            ,T.mt_com3                                               montant4_ct
            ,T.mt_prime - T.mt_com1 - T.mt_com2 - T.mt_com3          montant5_ct
            ,0                                                       montant6_ct
            ,0                                                       montant7_ct
            ,0                                                       montant8_ct
            ,0                                                       montant9_ct
            ,0                                                      montant10_ct
            ,0                                                      montant11_ct
            ,0                                                      montant12_ct
            ,0                                                      montant13_ct
            ,0                                                      montant14_ct
            ,0                                                      montant15_ct
            ,0                                                      montant16_ct
            ,0                                                      montant17_ct
            ,0                                                      montant18_ct
            ,0                                                      montant19_ct
            ,0                                                      montant20_ct
            ,0                                                      montant21_ct
            ,0                                                      montant22_ct
            ,0                                                      montant23_ct
            ,0                                                      montant24_ct
            ,0                                                      montant25_ct
            ,0                                                      montant26_ct
            ,0                                                      montant27_ct
            ,0                                                      montant28_ct
            ,0                                                      montant29_ct
            ,0                                                      montant30_ct
            ,T.monnaie_d                                      devise_ct
            ,'NV'                                                          var01
            ,'NV'                                                          var02
            ,'NV'                                                          var03
            ,'NV'                                                          var04
            ,'NV'                                                          var05
            ,'NV'                                                          var06
            ,'NV'                                                          var07
            ,to_char(f_nat_risq_cpta (T.numgar
                                     ,T.numfor))                           var08
            ,TRIM(to_char(f_code_cmcr (T.numgar
                                      ,T.numfor),'000'))                   var09
            ,ARTHUS.pk_personne.f_nom_compta (T.numorg)                           var10
            ,'NV'                                                          var11
            ,TO_CHAR(T.numorg)                                             var12
            ,'NV'                                                          var13
            ,f_code_regroupement(ARTHUS.pk_cotis.f_idcotis (
             3, T.numquit),ARTHUS.pk_cotis.f_idcotis (
             1, T.numquit),2,1,T.debut) var14
            ,to_char(T.numgar_ref)                                         var15
            ,'NV'                                                          var16
            ,decode(ARTHUS.pk_personne.f_dependance
             (T.numcli,99,T.datrevers),1,
             ARTHUS.pk_personne.f_nom_compta(T.numcli),999999999)                 var17
            ,'NV'                                                          var18
            ,f_code_regroupement (ARTHUS.pk_cotis.f_idcotis (3,T.numquit),
                                  ARTHUS.pk_cotis.f_idcotis (1,T.numquit),
                                  2,
                                  1,
                                  T.debut
                                 )                                         var19
            ,to_char(T.numgar)                                             var20
            ,ARTHUS.pk_personne.f_nom(T.numquerable,15,2)                         var21
            ,'NV'                                                          var22
            ,to_char(T.datvalide, 'YYYY')                                  var23
            ,'NV'                                                          var24
            ,to_char(T.fin,'DD/MM/YY')                                     var25
            ,'NV'                                                          var26
            ,'NV'                                                          var27
            ,'NV'                                                          var28
            ,'NV'                                                          var29
            --,to_char(reversement.datrevers,'DD/MM/YY')                     var30
            ,to_char(T.datvalide,'DD/MM/YY')                               var30
            --,to_char(reversement.datvalide,'DD/MM/YY')                     var31
            ,to_char(T.datemis,'DD/MM/YY')                                 var31
            ,substr(to_char(T.idrevers, '00000000'), 2, 8)                 var32
            ,'NV'                                                          var33
            ,'NV'                                                          var34
            ,to_char(T.datope,'DD/MM/YY')                                  var35
from(
  select
    contrat.numinterm,
    qttc_global.numquit,
    qttc_affec.numfor,
    reversement.idrevers,
    reversement.idcompta,
    reversement.numorg  ,
    reversement.datvalide,
    qttc_global.numquerable  ,
    qttc_affec.idaffec,
    sum(ARTHUS.pk_cotis.mt_affec_d(qttc_affec.numquit
                                   , qttc_affec.numfor
                                   , qttc_affec.numindiv
                                   , qttc_affec.idaffec)) mt_prime,
    (ARTHUS.pk_cotis.comm_prelev_d(qttc_global.numquit,qttc_affec.idrevers,qttc_affec.idaffec, qttc_affec.numfor,1,2,1)) mt_com1,
    (ARTHUS.pk_cotis.comm_prelev_d(qttc_global.numquit,qttc_affec.idrevers,qttc_affec.idaffec, qttc_affec.numfor,1,2,2)) mt_com2,
    (ARTHUS.pk_cotis.comm_prelev_d(qttc_global.numquit,qttc_affec.idrevers,qttc_affec.idaffec, qttc_affec.numfor,1,2,3)) mt_com3,
    qttc_affec.monnaie_d,
    qttc_global.numgar,
    qttc_global.debut,
    reversement.datrevers,
    contrat.numcli,
    reversement.fin,
    emission.datemis,
    contrat.numgar_ref,
    compte_client.datope
  from
    reversement
    ,qttc_affec
    ,qttc_global
    ,contrat
    ,emission
    ,compte_client
  where        reversement.idcompta       = -1
  AND          reversement.idrevers    = qttc_affec.idrevers
  AND          qttc_global.numgar      = contrat.numgar
  AND          qttc_affec.numquit = qttc_global.numquit
  AND          qttc_affec.numfor       <> 0
  AND          reversement.valide      = 'O'
  AND          emission.numfact = qttc_global.numquit
  AND          emission.numrelance =0
  AND          qttc_affec.idaffec       = compte_client.idaffec
  AND compte_client.codope + 0 = 4
  group by
  contrat.numinterm,
  qttc_global.numquit,
  qttc_affec.numfor,
  reversement.idrevers,
  reversement.idcompta,
  reversement.numorg  ,
  reversement.datvalide,
  qttc_global.numquerable  ,
  qttc_affec.idaffec,
  (ARTHUS.pk_cotis.comm_prelev_d(qttc_global.numquit,qttc_affec.idrevers,qttc_affec.idaffec, qttc_affec.numfor,1,2,1)),
  (ARTHUS.pk_cotis.comm_prelev_d(qttc_global.numquit,qttc_affec.idrevers,qttc_affec.idaffec, qttc_affec.numfor,1,2,2)),
  (ARTHUS.pk_cotis.comm_prelev_d(qttc_global.numquit,qttc_affec.idrevers,qttc_affec.idaffec, qttc_affec.numfor,1,2,3)),
  qttc_affec.monnaie_d,
  qttc_global.numgar,
  qttc_global.debut,
  reversement.datrevers,
  contrat.numcli,
  reversement.fin,
  emission.datemis,
  contrat.numgar_ref,
  compte_client.datope) T
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA511 FOR ARTHUS.V_COMPTA511
