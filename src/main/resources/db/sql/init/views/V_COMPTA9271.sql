CREATE FORCE VIEW ARTHUS.V_COMPTA9271 AS
SELECT   compte.numsoc                                                   numsoc
        ,0                                                              rolesoc
        ,'remise_banque'                                             sur_entite
        ,remise_globale.numremise                                    cle_unique
        ,'encaismt'                                                      entite
        ,1                                                            reg_piece
        ,encaismt.numencaismt                                               cle
        ,encaismt.idcompta                                             idcompta
        ,9271                                                            codope
        ,''                                                              scdope
        ,nvl(compte.journal,'0')                                        codjnal
        ,1                                                             type_ope
        ,0                                                                  cie
        ,encaismt.numcli                                                   indv
        ,0                                                                  gar
        ,0                                                                  int
        ,compte.cmpt_gene                                                   bqe
        ,substr( to_char(remise_globale.numremise, '00000000'), 2, 8 ) refpiece
        ,F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)         dat_piece
        ,remise_globale.numremise                                   lib_piece_1
        ,remise_globale.numcpte                                     lib_piece_2
        ,encaismt.montant_d                                            montant1
        ,0                                                             montant2
        ,0                                                             montant3
        ,0                                                             montant4
        ,0                                                             montant5
        ,0                                                             montant6
        ,0                                                             montant7
        ,0                                                             montant8
        ,0                                                             montant9
        ,0                                                            montant10
        ,0                                                            montant11
        ,0                                                            montant12
        ,0                                                            montant13
        ,0                                                            montant14
        ,0                                                            montant15
        ,0                                                            montant16
        ,0                                                            montant17
        ,0                                                            montant18
        ,0                                                            montant19
        ,0                                                            montant20
        ,0                                                            montant21
        ,0                                                            montant22
        ,0                                                            montant23
        ,0                                                            montant24
        ,0                                                            montant25
        ,0                                                            montant26
        ,0                                                            montant27
        ,0                                                            montant28
        ,0                                                            montant29
        ,0                                                            montant30
        ,encaismt.monnaie_d                                              devise
        ,encaismt.montant_d                                         montant1_ct
        ,0                                                          montant2_ct
        ,0                                                          montant3_ct
        ,0                                                          montant4_ct
        ,0                                                          montant5_ct
        ,0                                                          montant6_ct
        ,0                                                          montant7_ct
        ,0                                                          montant8_ct
        ,0                                                          montant9_ct
        ,0                                                         montant10_ct
        ,0                                                         montant11_ct
        ,0                                                         montant12_ct
        ,0                                                         montant13_ct
        ,0                                                         montant14_ct
        ,0                                                         montant15_ct
        ,0                                                         montant16_ct
        ,0                                                         montant17_ct
        ,0                                                         montant18_ct
        ,0                                                         montant19_ct
        ,0                                                         montant20_ct
        ,0                                                         montant21_ct
        ,0                                                         montant22_ct
        ,0                                                         montant23_ct
        ,0                                                         montant24_ct
        ,0                                                         montant25_ct
        ,0                                                         montant26_ct
        ,0                                                         montant27_ct
        ,0                                                         montant28_ct
        ,0                                                         montant29_ct
        ,0                                                         montant30_ct
        ,encaismt.monnaie_d                                           devise_ct
        ,'NV'                                                             var01
        ,nvl(compte.journal,'0')                                          var02
        ,F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,2)                 var03
        ,compte.cmpt_gene                                                 var04
        ,'NV'                                                             var05
        ,'NV'                                                             var06
        ,'NV'                                                             var07
        ,'NV'                                                             var08
        ,'NV'                                                             var09
        ,'NV'                                                             var10
        ,'NV'                                                             var11
        ,'NV'                                                             var12
        ,'NV'                                                             var13
        ,'NV'                                                             var14
        ,'NV'                                                             var15
        ,'NV'                                                             var16
        ,decode (ARTHUS.pk_personne.f_dependance (encaismt.numcli,
                                           99,
                                           remise_globale.daterem
                                          ),
                 1,
                 ARTHUS.pk_personne.f_nom_compta(encaismt.numcli),
                 999999999
                )                                                         var17
        ,'NV'                                                             var18
        ,'NV'                                                             var19
        ,'NV'                                                             var20
        ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          var21
        ,'NV'                                                             var22
        ,'NV'                                                             var23
        ,to_char(encaismt.numcli)                                         var24
        ,'NV'                                                             var25
        ,'NV'                                                             var26
        ,'NV'                                                             var27
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,3))        var28
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        var29
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var30
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var31
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        var32
        ,'NV'                                                             var33
        ,'NV'                                                             var34
        ,'NV'                                                             var35
FROM  compte
     ,remise_globale
     ,encaismt
WHERE compte.numcpte = remise_globale.numcpte
  AND encaismt.idcompta = -1
  AND encaismt.numencaismt IN
      (SELECT numencaismt
         FROM remise_banque
        WHERE remise_banque.numremise = remise_globale.numremise
      )
UNION ALL
--   Compte client des encaissements remis en banque
SELECT   compte.numsoc                                                   numsoc
        ,0                                                              rolesoc
        ,'encaismt'                                                  sur_entite
        ,encaismt.numencaismt                                        cle_unique
        ,'encaismt'                                                      entite
        ,1                                                            reg_piece
        ,encaismt.numencaismt                                               cle
        ,encaismt.idcompta                                             idcompta
        ,9271                                                            codope
        ,''                                                              scdope
        ,nvl(compte.journal,'0')                                        codjnal
        ,4                                                             type_ope
        ,0                                                                  cie
        ,encaismt.numcli                                                   indv
        ,0                                                                  gar
        ,0                                                                  int
        ,compte.cmpt_gene                                                   bqe
        ,substr( to_char(remise_globale.numremise, '00000000'), 2, 8 ) refpiece
        ,F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)         dat_piece
        ,nvl(encaismt.refpmt,encaismt.numencaismt)                  lib_piece_1
        ,encaismt.numcli                                            lib_piece_2
        ,0                                                             montant1
        ,encaismt.montant_d                                            montant2
        ,0                                                             montant3
        ,0                                                             montant4
        ,0                                                             montant5
        ,0                                                             montant6
        ,0                                                             montant7
        ,0                                                             montant8
        ,0                                                             montant9
        ,0                                                            montant10
        ,0                                                            montant11
        ,0                                                            montant12
        ,0                                                            montant13
        ,0                                                            montant14
        ,0                                                            montant15
        ,0                                                            montant16
        ,0                                                            montant17
        ,0                                                            montant18
        ,0                                                            montant19
        ,0                                                            montant20
        ,0                                                            montant21
        ,0                                                            montant22
        ,0                                                            montant23
        ,0                                                            montant24
        ,0                                                            montant25
        ,0                                                            montant26
        ,0                                                            montant27
        ,0                                                            montant28
        ,0                                                            montant29
        ,0                                                            montant30
        ,encaismt.monnaie_d                                              devise
        ,0                                                          montant1_ct
        ,encaismt.montant_d                                         montant2_ct
        ,0                                                          montant3_ct
        ,0                                                          montant4_ct
        ,0                                                          montant5_ct
        ,0                                                          montant6_ct
        ,0                                                          montant7_ct
        ,0                                                          montant8_ct
        ,0                                                          montant9_ct
        ,0                                                         montant10_ct
        ,0                                                         montant11_ct
        ,0                                                         montant12_ct
        ,0                                                         montant13_ct
        ,0                                                         montant14_ct
        ,0                                                         montant15_ct
        ,0                                                         montant16_ct
        ,0                                                         montant17_ct
        ,0                                                         montant18_ct
        ,0                                                         montant19_ct
        ,0                                                         montant20_ct
        ,0                                                         montant21_ct
        ,0                                                         montant22_ct
        ,0                                                         montant23_ct
        ,0                                                         montant24_ct
        ,0                                                         montant25_ct
        ,0                                                         montant26_ct
        ,0                                                         montant27_ct
        ,0                                                         montant28_ct
        ,0                                                         montant29_ct
        ,0                                                         montant30_ct
        ,encaismt.monnaie_d                                           devise_ct
        ,'NV'                                                             var01
        ,nvl(compte.journal,'0')                                          var02
        ,F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,2)                 var03
        ,compte.cmpt_gene                                                 var04
        ,'NV'                                                             var05
        ,'NV'                                                             var06
        ,'NV'                                                             var07
        ,'NV'                                                             var08
        ,'NV'                                                             var09
        ,'NV'                                                             var10
        ,'NV'                                                             var11
        ,'NV'                                                             var12
        ,'NV'                                                             var13
        ,'NV'                                                             var14
        ,'NV'                                                             var15
        ,'NV'                                                             var16
        ,decode (ARTHUS.pk_personne.f_dependance (encaismt.numcli,
                                           99,
                                           remise_globale.daterem
                                          ),
                 1,
                 ARTHUS.pk_personne.f_nom_compta (encaismt.numcli),
                 999999999
                )                                                         var17
        ,'NV'                                                             var18
        ,'NV'                                                             var19
        ,'NV'                                                             var20
        ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          var21
        ,'NV'                                                             var22
        ,'NV'                                                             var23
        ,to_char(encaismt.numcli)                                         var24
        ,'NV'                                                             var25
        ,'NV'                                                             var26
        ,'NV'                                                             var27
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,3))        var28
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        var29
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var30
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var31
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        var32
        ,'NV'                                                             var33
        ,'NV'                                                             var34
        ,'NV'                                                             var35
FROM  compte
     ,remise_globale
     ,encaismt
WHERE compte.numcpte = remise_globale.numcpte
  AND encaismt.idcompta = -1
  AND encaismt.numencaismt IN
      (SELECT numencaismt
         FROM remise_banque
        WHERE remise_banque.numremise = remise_globale.numremise
      )
--   Bordereaux de prelevement
UNION ALL
SELECT   compte.numsoc                                                   numsoc
        ,0                                                              rolesoc
        ,'prelevement'                                               sur_entite
        ,remise_prelev.numremise                                     cle_unique
        ,'encaismt'                                                      entite
        ,2                                                            reg_piece
        ,encaismt.numencaismt                                               cle
        ,encaismt.idcompta                                             idcompta
        ,9271                                                            codope
        ,''                                                              scdope
        ,nvl(compte.journal,'0')                                        codjnal
        ,2                                                             type_ope
        ,0                                                                  cie
        ,encaismt.numcli                                                   indv
        ,0                                                                  gar
        ,0                                                                  int
        ,compte.cmpt_gene                                                   bqe
        ,substr( to_char(remise_prelev.numremise, '00000000'), 2, 8 )  refpiece
        ,F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)         dat_piece
        ,remise_prelev.numremise                                    lib_piece_1
        ,remise_prelev.numcpte                                      lib_piece_2
        ,encaismt.montant_d                                            montant1
        ,0                                                             montant2
        ,0                                                             montant3
        ,0                                                             montant4
        ,0                                                             montant5
        ,0                                                             montant6
        ,0                                                             montant7
        ,0                                                             montant8
        ,0                                                             montant9
        ,0                                                            montant10
        ,0                                                            montant11
        ,0                                                            montant12
        ,0                                                            montant13
        ,0                                                            montant14
        ,0                                                            montant15
        ,0                                                            montant16
        ,0                                                            montant17
        ,0                                                            montant18
        ,0                                                            montant19
        ,0                                                            montant20
        ,0                                                            montant21
        ,0                                                            montant22
        ,0                                                            montant23
        ,0                                                            montant24
        ,0                                                            montant25
        ,0                                                            montant26
        ,0                                                            montant27
        ,0                                                            montant28
        ,0                                                            montant29
        ,0                                                            montant30
        ,encaismt.monnaie_d                                              devise
        ,encaismt.montant_d                                         montant1_ct
        ,0                                                          montant2_ct
        ,0                                                          montant3_ct
        ,0                                                          montant4_ct
        ,0                                                          montant5_ct
        ,0                                                          montant6_ct
        ,0                                                          montant7_ct
        ,0                                                          montant8_ct
        ,0                                                          montant9_ct
        ,0                                                         montant10_ct
        ,0                                                         montant11_ct
        ,0                                                         montant12_ct
        ,0                                                         montant13_ct
        ,0                                                         montant14_ct
        ,0                                                         montant15_ct
        ,0                                                         montant16_ct
        ,0                                                         montant17_ct
        ,0                                                         montant18_ct
        ,0                                                         montant19_ct
        ,0                                                         montant20_ct
        ,0                                                         montant21_ct
        ,0                                                         montant22_ct
        ,0                                                         montant23_ct
        ,0                                                         montant24_ct
        ,0                                                         montant25_ct
        ,0                                                         montant26_ct
        ,0                                                         montant27_ct
        ,0                                                         montant28_ct
        ,0                                                         montant29_ct
        ,0                                                         montant30_ct
        ,encaismt.monnaie_d                                           devise_ct
        ,'NV'                                                             var01
        ,nvl(compte.journal,'0')                                          var02
        ,F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,2)                 var03
        ,compte.cmpt_gene                                                 var04
        ,'NV'                                                             var05
        ,'NV'                                                             var06
        ,'NV'                                                             var07
        ,'NV'                                                             var08
        ,'NV'                                                             var09
        ,'NV'                                                             var10
        ,'NV'                                                             var11
        ,'NV'                                                             var12
        ,'NV'                                                             var13
        ,'NV'                                                             var14
        ,'NV'                                                             var15
        ,'NV'                                                             var16
        ,decode (ARTHUS.pk_personne.f_dependance (encaismt.numcli,
                                           99,
                                           remise_prelev.date_prelev
                                          ),
                 1,
                 ARTHUS.pk_personne.f_nom_compta (encaismt.numcli),
                 999999999 )                                              var17
        ,'NV'                                                             var18
        ,'NV'                                                             var19
        ,'NV'                                                             var20
        ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          var21
        ,'NV'                                                             var22
        ,'NV'                                                             var23
        ,to_char(encaismt.numcli)                                         var24
        ,'NV'                                                             var25
        ,'NV'                                                             var26
        ,'NV'                                                             var27
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,3))        var28
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        var29
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var30
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var31
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        var32
        ,'NV'                                                             var33
        ,'NV'                                                             var34
        ,'NV'                                                             var35
FROM  compte
     ,remise_prelev
     ,encaismt
WHERE compte.numcpte = encaismt.numcpte
  AND encaismt.idcompta = -1
  AND encaismt.numencaismt IN
      (SELECT numencaismt
         FROM prelevement
        WHERE prelevement.numremise = remise_prelev.numremise
      )
UNION ALL
--   Compte client des encaissements faisant partie d'un bordereau de prelevement
SELECT   compte.numsoc                                                   numsoc
        ,0                                                              rolesoc
        ,'encaismt'                                                  sur_entite
        ,encaismt.numencaismt                                        cle_unique
        ,'encaismt'                                                      entite
        ,2                                                            reg_piece
        ,encaismt.numencaismt                                               cle
        ,encaismt.idcompta                                             idcompta
        ,9271                                                            codope
        ,''                                                              scdope
        ,nvl(compte.journal,'0')                                        codjnal
        ,4                                                             type_ope
        ,0                                                                  cie
        ,encaismt.numcli                                                   indv
        ,0                                                                  gar
        ,0                                                                  int
        ,compte.cmpt_gene                                                   bqe
        ,substr( to_char(remise_prelev.numremise, '00000000'), 2, 8 )  refpiece
        ,F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)         dat_piece
        ,nvl(encaismt.refpmt,encaismt.numencaismt)                  lib_piece_1
        ,encaismt.numcli                                            lib_piece_2
        ,0                                                             montant1
        ,encaismt.montant_d                                            montant2
        ,0                                                             montant3
        ,0                                                             montant4
        ,0                                                             montant5
        ,0                                                             montant6
        ,0                                                             montant7
        ,0                                                             montant8
        ,0                                                             montant9
        ,0                                                            montant10
        ,0                                                            montant11
        ,0                                                            montant12
        ,0                                                            montant13
        ,0                                                            montant14
        ,0                                                            montant15
        ,0                                                            montant16
        ,0                                                            montant17
        ,0                                                            montant18
        ,0                                                            montant19
        ,0                                                            montant20
        ,0                                                            montant21
        ,0                                                            montant22
        ,0                                                            montant23
        ,0                                                            montant24
        ,0                                                            montant25
        ,0                                                            montant26
        ,0                                                            montant27
        ,0                                                            montant28
        ,0                                                            montant29
        ,0                                                            montant30
        ,encaismt.monnaie_d                                              devise
        ,0                                                          montant1_ct
        ,encaismt.montant_d                                         montant2_ct
        ,0                                                          montant3_ct
        ,0                                                          montant4_ct
        ,0                                                          montant5_ct
        ,0                                                          montant6_ct
        ,0                                                          montant7_ct
        ,0                                                          montant8_ct
        ,0                                                          montant9_ct
        ,0                                                         montant10_ct
        ,0                                                         montant11_ct
        ,0                                                         montant12_ct
        ,0                                                         montant13_ct
        ,0                                                         montant14_ct
        ,0                                                         montant15_ct
        ,0                                                         montant16_ct
        ,0                                                         montant17_ct
        ,0                                                         montant18_ct
        ,0                                                         montant19_ct
        ,0                                                         montant20_ct
        ,0                                                         montant21_ct
        ,0                                                         montant22_ct
        ,0                                                         montant23_ct
        ,0                                                         montant24_ct
        ,0                                                         montant25_ct
        ,0                                                         montant26_ct
        ,0                                                         montant27_ct
        ,0                                                         montant28_ct
        ,0                                                         montant29_ct
        ,0                                                         montant30_ct
        ,encaismt.monnaie_d                                           devise_ct
        ,'NV'                                                             var01
        ,nvl(compte.journal,'0')                                          var02
        ,F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,2)                 var03
        ,compte.cmpt_gene                                                 var04
        ,'NV'                                                             var05
        ,'NV'                                                             var06
        ,'NV'                                                             var07
        ,'NV'                                                             var08
        ,'NV'                                                             var09
        ,'NV'                                                             var10
        ,'NV'                                                             var11
        ,'NV'                                                             var12
        ,'NV'                                                             var13
        ,'NV'                                                             var14
        ,'NV'                                                             var15
        ,'NV'                                                             var16
        ,decode (ARTHUS.pk_personne.f_dependance (encaismt.numcli,
                                           99,
                                           remise_prelev.date_prelev
                                          ),
                 1,
                 ARTHUS.pk_personne.f_nom_compta (encaismt.numcli),
                 999999999
                )                                                         var17
        ,'NV'                                                             var18
        ,'NV'                                                             var19
        ,'NV'                                                             var20
        ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          var21
        ,'NV'                                                             var22
        ,'NV'                                                             var23
        ,to_char(encaismt.numcli)                                         var24
        ,'NV'                                                             var25
        ,'NV'                                                             var26
        ,'NV'                                                             var27
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,3))        var28
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        var29
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var30
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var31
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        var32
        ,'NV'                                                             var33
        ,'NV'                                                             var34
        ,'NV'                                                             var35
FROM  compte
     ,remise_prelev
     ,encaismt
WHERE compte.numcpte = encaismt.numcpte
  AND encaismt.idcompta = -1
  AND encaismt.numencaismt IN
      (SELECT numencaismt
         FROM prelevement
        WHERE prelevement.numremise = remise_prelev.numremise
      )
UNION ALL
--   Encaissements Non remis en banque
SELECT   compte.numsoc                                                   numsoc
        ,0                                                              rolesoc
        ,'encaismt'                                                  sur_entite
        ,encaismt.numencaismt                                        cle_unique
        ,'encaismt'                                                      entite
        ,3                                                            reg_piece
        ,encaismt.numencaismt                                               cle
        ,encaismt.idcompta                                             idcompta
        ,9271                                                            codope
        ,''                                                              scdope
        ,nvl(compte.journal,'0')                                        codjnal
        ,3                                                             type_ope
        ,0                                                                  cie
        ,encaismt.numcli                                                   indv
        ,0                                                                  gar
        ,0                                                                  int
        ,compte.cmpt_gene                                                   bqe
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )     refpiece
        ,F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)         dat_piece
        ,nvl(encaismt.refpmt,encaismt.numencaismt)                  lib_piece_1
        ,encaismt.numcli                                            lib_piece_2
        ,encaismt.montant_d                                            montant1
        ,0                                                             montant2
        ,0                                                             montant3
        ,0                                                             montant4
        ,0                                                             montant5
        ,0                                                             montant6
        ,0                                                             montant7
        ,0                                                             montant8
        ,0                                                             montant9
        ,0                                                            montant10
        ,0                                                            montant11
        ,0                                                            montant12
        ,0                                                            montant13
        ,0                                                            montant14
        ,0                                                            montant15
        ,0                                                            montant16
        ,0                                                            montant17
        ,0                                                            montant18
        ,0                                                            montant19
        ,0                                                            montant20
        ,0                                                            montant21
        ,0                                                            montant22
        ,0                                                            montant23
        ,0                                                            montant24
        ,0                                                            montant25
        ,0                                                            montant26
        ,0                                                            montant27
        ,0                                                            montant28
        ,0                                                            montant29
        ,0                                                            montant30
        ,encaismt.monnaie_d                                              devise
        ,encaismt.montant_d                                         montant1_ct
        ,0                                                          montant2_ct
        ,0                                                          montant3_ct
        ,0                                                          montant4_ct
        ,0                                                          montant5_ct
        ,0                                                          montant6_ct
        ,0                                                          montant7_ct
        ,0                                                          montant8_ct
        ,0                                                          montant9_ct
        ,0                                                         montant10_ct
        ,0                                                         montant11_ct
        ,0                                                         montant12_ct
        ,0                                                         montant13_ct
        ,0                                                         montant14_ct
        ,0                                                         montant15_ct
        ,0                                                         montant16_ct
        ,0                                                         montant17_ct
        ,0                                                         montant18_ct
        ,0                                                         montant19_ct
        ,0                                                         montant20_ct
        ,0                                                         montant21_ct
        ,0                                                         montant22_ct
        ,0                                                         montant23_ct
        ,0                                                         montant24_ct
        ,0                                                         montant25_ct
        ,0                                                         montant26_ct
        ,0                                                         montant27_ct
        ,0                                                         montant28_ct
        ,0                                                         montant29_ct
        ,0                                                         montant30_ct
        ,encaismt.monnaie_d                                           devise_ct
        ,'NV'                                                             var01
        ,nvl(compte.journal,'0')                                          var02
        ,F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,2)                 var03
        ,compte.cmpt_gene                                                 var04
        ,'NV'                                                             var05
        ,'NV'                                                             var06
        ,'NV'                                                             var07
        ,'NV'                                                             var08
        ,'NV'                                                             var09
        ,'NV'                                                             var10
        ,'NV'                                                             var11
        ,'NV'                                                             var12
        ,'NV'                                                             var13
        ,'NV'                                                             var14
        ,'NV'                                                             var15
        ,'NV'                                                             var16
        ,decode (ARTHUS.pk_personne.f_dependance (encaismt.numcli,
                                           99,
                                           encaismt.datpay
                                          ),
                 1,
                 ARTHUS.pk_personne.f_nom_compta (encaismt.numcli),
                 999999999
                )                                                         var17
        ,'NV'                                                             var18
        ,'NV'                                                             var19
        ,'NV'                                                             var20
        ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          var21
        ,'NV'                                                             var22
        ,'NV'                                                             var23
        ,to_char(encaismt.numcli)                                         var24
        ,'NV'                                                             var25
        ,'NV'                                                             var26
        ,'NV'                                                             var27
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,3))        var28
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        var29
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var30
        ,to_char(F_CPTA_DATE_ENCAISMT(encaismt.numencaismt),'DD/MM/YY')   var31
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        var32
        ,'NV'                                                             var33
        ,'NV'                                                             var34
        ,'NV'                                                             var35
FROM  compte
     ,encaismt
WHERE compte.numcpte = encaismt.numcpte
  AND encaismt.idcompta = -1
  AND Not Exists (SELECT 1
                    FROM prelevement
                   WHERE prelevement.numencaismt = encaismt.numencaismt
                 )
  AND Not Exists (SELECT 1
                    FROM remise_banque
                   WHERE remise_banque.numencaismt = encaismt.numencaismt
                 )
UNION ALL
--   Compte client des Encaissements Non remis en banque
SELECT   compte.numsoc                                                   numsoc
        ,0                                                              rolesoc
        ,'encaismt'                                                  sur_entite
        ,encaismt.numencaismt                                        cle_unique
        ,'encaismt'                                                      entite
        ,3                                                            reg_piece
        ,encaismt.numencaismt                                               cle
        ,encaismt.idcompta                                             idcompta
        ,9271                                                            codope
        ,''                                                              scdope
        ,nvl(compte.journal,'0')                                        codjnal
        ,4                                                             type_ope
        ,0                                                                  cie
        ,encaismt.numcli                                                   indv
        ,0                                                                  gar
        ,0                                                                  int
        ,compte.cmpt_gene                                                   bqe
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )     refpiece
        ,F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)         dat_piece
        ,nvl(encaismt.refpmt,encaismt.numencaismt)                  lib_piece_1
        ,encaismt.numcli                                            lib_piece_2
        ,0                                                             montant1
        ,encaismt.montant_d                                            montant2
        ,0                                                             montant3
        ,0                                                             montant4
        ,0                                                             montant5
        ,0                                                             montant6
        ,0                                                             montant7
        ,0                                                             montant8
        ,0                                                             montant9
        ,0                                                            montant10
        ,0                                                            montant11
        ,0                                                            montant12
        ,0                                                            montant13
        ,0                                                            montant14
        ,0                                                            montant15
        ,0                                                            montant16
        ,0                                                            montant17
        ,0                                                            montant18
        ,0                                                            montant19
        ,0                                                            montant20
        ,0                                                            montant21
        ,0                                                            montant22
        ,0                                                            montant23
        ,0                                                            montant24
        ,0                                                            montant25
        ,0                                                            montant26
        ,0                                                            montant27
        ,0                                                            montant28
        ,0                                                            montant29
        ,0                                                            montant30
        ,encaismt.monnaie_d                                              devise
        ,0                                                          montant1_ct
        ,encaismt.montant_d                                         montant2_ct
        ,0                                                          montant3_ct
        ,0                                                          montant4_ct
        ,0                                                          montant5_ct
        ,0                                                          montant6_ct
        ,0                                                          montant7_ct
        ,0                                                          montant8_ct
        ,0                                                          montant9_ct
        ,0                                                         montant10_ct
        ,0                                                         montant11_ct
        ,0                                                         montant12_ct
        ,0                                                         montant13_ct
        ,0                                                         montant14_ct
        ,0                                                         montant15_ct
        ,0                                                         montant16_ct
        ,0                                                         montant17_ct
        ,0                                                         montant18_ct
        ,0                                                         montant19_ct
        ,0                                                         montant20_ct
        ,0                                                         montant21_ct
        ,0                                                         montant22_ct
        ,0                                                         montant23_ct
        ,0                                                         montant24_ct
        ,0                                                         montant25_ct
        ,0                                                         montant26_ct
        ,0                                                         montant27_ct
        ,0                                                         montant28_ct
        ,0                                                         montant29_ct
        ,0                                                         montant30_ct
        ,encaismt.monnaie_d                                           devise_ct
        ,'NV'                                                             var01
        ,nvl(compte.journal,'0')                                          var02
        ,F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,2)                 var03
        ,compte.cmpt_gene                                                 var04
        ,'NV'                                                             var05
        ,'NV'                                                             var06
        ,'NV'                                                             var07
        ,'NV'                                                             var08
        ,'NV'                                                             var09
        ,'NV'                                                             var10
        ,'NV'                                                             var11
        ,'NV'                                                             var12
        ,'NV'                                                             var13
        ,'NV'                                                             var14
        ,'NV'                                                             var15
        ,'NV'                                                             var16
        ,decode (ARTHUS.pk_personne.f_dependance (encaismt.numcli,
                                           99,
                                           encaismt.datpay),
                 1,
                 ARTHUS.pk_personne.f_nom_compta(encaismt.numcli),
                 999999999
                )                                                         var17
        ,'NV'                                                             var18
        ,'NV'                                                             var19
        ,'NV'                                                             var20
        ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          var21
        ,'NV'                                                             var22
        ,'NV'                                                             var23
        ,to_char(encaismt.numcli)                                         var24
        ,'NV'                                                             var25
        ,'NV'                                                             var26
        ,'NV'                                                             var27
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,3))        var28
        ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        var29
        ,to_char(F_CPTA_DATE_ENCAISMT_OPERATION(encaismt.numencaismt)
                 ,'DD/MM/YY')                                             var30
        ,to_char(F_CPTA_DATE_ENCAISMT(encaismt.numencaismt),'DD/MM/YY')   var31
        ,substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        var32
        ,'NV'                                                             var33
        ,'NV'                                                             var34
        ,'NV'                                                             var35
FROM  compte
     ,encaismt
WHERE compte.numcpte = encaismt.numcpte
  AND encaismt.idcompta = -1
  AND Not Exists (SELECT 1
                    FROM prelevement
                   WHERE prelevement.numencaismt = encaismt.numencaismt
                 )
  AND Not Exists (SELECT 1
                    FROM remise_banque
                   WHERE remise_banque.numencaismt = encaismt.numencaismt
                 )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA9271 FOR ARTHUS.V_COMPTA9271
