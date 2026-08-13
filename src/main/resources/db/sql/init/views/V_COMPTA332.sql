CREATE FORCE VIEW ARTHUS.V_COMPTA332 AS
SELECT  DISTINCT
          contrat.numinterm                                               numsoc
         ,f_cpta_role(qttc_affec.numfor,1,2)                             rolesoc
         ,'encaismt'                                                  sur_entite
         ,encaismt.numencaismt                                        cle_unique
         ,'compte_client'                                                 entite
         ,1                                                            reg_piece
         ,compte_client.idaffec                                              cle
         ,compte_client.idcompta                                        idcompta
         ,332                                                             codope
         ,'4'                                                             scdope
         ,''                                                             codjnal
         ,1                                                             type_ope
         ,f_assureur(qttc_affec.numfor)                                      cie
         ,qttc_global.numquerable                                           indv
         ,qttc_affec.numfor                                                  gar
         ,0                                                                  int
         ,''                                                                 bqe
         ,substr(TO_CHAR(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1)
              ,'00000000'),2,8)
                  || TO_CHAR(compte_client.datope,'DDMMYY')             refpiece 
         ,compte_client.datope                                         dat_piece         
         ,nvl(encaismt.refpmt,encaismt.numencaismt)                  lib_piece_1
         ,encaismt.numcli                                            lib_piece_2
         ,ARTHUS.pk_cotis.mt_affec_d (qttc_global.numquit
                              ,qttc_affec.numfor
                              ,''
                              ,compte_client.idaffec)                   montant1
         ,0                                                             montant2
         ,0                                                             montant3
         ,0                                                             montant4
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,0,'')                                 montant5
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,1,'')                                 montant6
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,2,'')                                 montant7
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,3,'')                                 montant8
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,4,'')                                 montant9
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,0,'')                                montant10
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,1,'')                                montant11
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,2,'')                                montant12
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,3,'')                                montant13
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,4,'')                                montant14
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,0,'')                                montant15
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,1,'')                                montant16
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,2,'')                                montant17
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,3,'')                                montant18
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,4,'')                                montant19
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,0,'')                                montant20
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,1,'')                                montant21
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,2,'')                                montant22
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,3,'')                                montant23
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,4,'')                                montant24
         ,0                                                            montant25
         ,0                                                            montant26
         ,0                                                            montant27
         ,0                                                            montant28
         ,0                                                            montant29
         ,0                                                            montant30
         ,compte_client.monnaie_d                                         devise
         ,ARTHUS.pk_cotis.mt_affec_d (qttc_global.numquit
                              ,qttc_affec.numfor
                              ,''
                              ,compte_client.idaffec)                montant1_ct
         ,0                                                          montant2_ct
         ,0                                                          montant3_ct
         ,0                                                          montant4_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,0,'')                              montant5_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,1,'')                              montant6_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,2,'')                              montant7_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,3,'')                              montant8_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',1,4,'')                              montant9_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,0,'')                             montant10_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,1,'')                             montant11_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,2,'')                             montant12_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,3,'')                             montant13_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',3,4,'')                             montant14_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,0,'')                             montant15_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,1,'')                             montant16_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,2,'')                             montant17_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,3,'')                             montant18_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',2,4,'')                             montant19_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,0,'')                             montant20_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,1,'')                             montant21_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,2,'')                             montant22_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,3,'')                             montant23_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           qttc_affec.numfor,'',5,4,'')                             montant24_ct
         ,0                                                         montant25_ct
         ,0                                                         montant26_ct
         ,0                                                         montant27_ct
         ,0                                                         montant28_ct
         ,0                                                         montant29_ct
         ,0                                                         montant30_ct
         ,compte_client.monnaie_d                                      devise_ct
         ,ARTHUS.pk_personne.f_nom_compta 
          (decode(qttc_global.idadhesion,0,f_intermediaire(2,qttc_global.numgar,
          2,qttc_global.debut),f_intermediaire(4,qttc_global.idadhesion,
          2,qttc_global.debut)))                                           VAR01
         ,'NV'                                                             VAR02
         ,'NV'                                                             VAR03
         ,'NV'                                                             VAR04
         ,'NV'                                                             VAR05
         ,'NV'                                                             VAR06
         ,'NV'                                                             VAR07
         ,'NV'                                                             VAR08
         ,'NV'                                                             VAR09
         ,'NV'                                                             VAR10
         ,'NV'                                                             VAR11
         ,TO_CHAR(f_soc_assu(qttc_affec.numfor,1,2))                       VAR12
         ,ARTHUS.pk_personne.f_nom_compta(DECODE (qttc_global.idadhesion,0,
          f_intermediaire(2,qttc_global.numgar,1,qttc_global.debut),
          f_intermediaire(4,qttc_global.idadhesion,1,qttc_global.debut)))  VAR13
         ,f_code_regroupement(ARTHUS.pk_cotis.f_idcotis (
          3, qttc_global.numquit),ARTHUS.pk_cotis.f_idcotis (
          1, qttc_global.numquit),2,1,qttc_global.debut)                   VAR14
         ,TO_CHAR (contrat.numgar_ref)                                     VAR15
         ,f_code_regroupement(
          ARTHUS.pk_cotis.f_idcotis (3,qttc_global.numquit),
          ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit),
          2,1,qttc_global.debut)                                           VAR16
         ,decode(ARTHUS.pk_personne.f_dependance
          (contrat.numcli,99,qttc_global.debut),1,
           ARTHUS.pk_personne.f_nom_compta(contrat.numcli),999999999 )            VAR17
         ,f_code_regroupement(
           ARTHUS.pk_cotis.f_idcotis (3,qttc_global.numquit),
          ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit),
          2,1,qttc_global.debut)                                           VAR18
         ,f_code_regroupement(
           ARTHUS.pk_cotis.f_idcotis (3,qttc_global.numquit),
          ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit),
          2,1,qttc_global.debut)                                           VAR19
         ,to_char(CONTRAT.NUMGAR)                                          VAR20
         ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          VAR21
         ,contrat.portefeuille                                             VAR22
         ,TO_CHAR (qttc_global.debut, 'YYYY')                              VAR23
         ,to_char(encaismt.numcli)                                         VAR24
         ,'NV'                                                             VAR25
         ,'NV'                                                             VAR26
         ,'NV'                                                             VAR27
         ,'NV'                                                             VAR28
         ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        VAR29
         ,to_char(compte_client.datope,'DD/MM/YY')                         VAR30                  
         ,to_char(f_cpta_date_encaismt_operation(encaismt.numencaismt)
                                                            ,'DD/MM/YY')   VAR31
         ,Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        VAR32
         ,ARTHUS.pk_contrat.f_contrat_info_compl(contrat.numgar
                                        , contrat.numgar,4)                VAR33
         ,'NV'                                                             VAR34
         ,to_char(f_cpta_date_constatation (compte_client.codope
                                ,qttc_global.numquit),'DD/MM/YY')          VAR35
  FROM  
    compte_client,
    encaismt,
    qttc_affec,
    qttc_global,
    contrat  
  WHERE  contrat.numgar          = qttc_global.numgar
    AND  qttc_global.numquit     = compte_client.numfact
    AND  qttc_global.mt_affec_d  Is Not Null
    AND  qttc_affec.numquit      = qttc_global.numquit
    AND  qttc_affec.idaffec      = compte_client.idaffec
    AND  qttc_affec.numfor      != 0
    AND  encaismt.numencaismt    = compte_client.numencaismt
    AND  compte_client.montant   > 0
    AND  compte_client.codope    = 4
    AND  compte_client.idcompta  = -1
--
UNION ALL
--
  SELECT  DISTINCT
          contrat.numinterm                                               numsoc
         ,f_cpta_role(contrat.numgar,2,2)                                rolesoc 
         ,'encaismt'                                                  sur_entite
         ,encaismt.numencaismt                                        cle_unique
         ,'compte_client'                                                 entite
         ,1                                                            reg_piece
         ,compte_client.idaffec                                              cle
         ,compte_client.idcompta                                        idcompta
         ,332                                                             codope
         ,'4'                                                             scdope
         ,''                                                             codjnal
         ,1                                                             type_ope
         ,0                                                                  cie
         ,qttc_global.numquerable                                           indv
         ,0                                                                  gar
         ,0                                                                  int
         ,''                                                                 bqe
         ,substr(TO_CHAR(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1)
              ,'00000000'),2,8)
                  || TO_CHAR(compte_client.datope,'DDMMYY')             refpiece 
         ,compte_client.datope                                         dat_piece         
         ,nvl(encaismt.refpmt,encaismt.numencaismt)                  lib_piece_1
         ,encaismt.numcli                                            lib_piece_2
         ,0                                                             montant1
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
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,0,'')                                               montant25
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,1,'')                                               montant26
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,2,'')                                               montant27
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,3,'')                                               montant28
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,4,'')                                               montant29
         ,0                                                            montant30
         ,compte_client.monnaie_d                                         devise
         ,0                                                          montant1_ct
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
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,0,'')                                            montant25_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,1,'')                                            montant26_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,2,'')                                            montant27_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,3,'')                                            montant28_ct
         ,ARTHUS.pk_cotis.mt_affec_tfc_d(qttc_global.numquit,'',compte_client.idaffec,
           '','',4,4,'')                                            montant29_ct
         ,0                                                         montant30_ct
         ,compte_client.monnaie_d                                      devise_ct
         ,ARTHUS.pk_personne.f_nom_compta 
          (decode(qttc_global.idadhesion,0,f_intermediaire(2,qttc_global.numgar,
          2,qttc_global.debut),f_intermediaire(4,qttc_global.idadhesion,
          2,qttc_global.debut)))                                           VAR01
         ,'NV'                                                             VAR02
         ,'NV'                                                             VAR03
         ,'NV'                                                             VAR04
         ,'NV'                                                             VAR05
         ,'NV'                                                             VAR06
         ,'NV'                                                             VAR07
         ,'NV'                                                             VAR08
         ,'NV'                                                             VAR09
         ,'NV'                                                             VAR10
         ,'NV'                                                             VAR11
         ,'NV'                                                             VAR12
         ,ARTHUS.pk_personne.f_nom_compta(DECODE (qttc_global.idadhesion,0,
          f_intermediaire(2,qttc_global.numgar,1,qttc_global.debut),
          f_intermediaire(4,qttc_global.idadhesion,1,qttc_global.debut)))  VAR13
         ,f_code_regroupement(ARTHUS.pk_cotis.f_idcotis (
          3, qttc_global.numquit),ARTHUS.pk_cotis.f_idcotis (
          1, qttc_global.numquit),2,1,qttc_global.debut)                   VAR14
         ,TO_CHAR (contrat.numgar_ref)                                     VAR15
         ,f_code_regroupement(
          ARTHUS.pk_cotis.f_idcotis (3,qttc_global.numquit),
          ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit),
          2,1,qttc_global.debut)                                           VAR16
         ,decode(ARTHUS.pk_personne.f_dependance
          (contrat.numcli,99,qttc_global.debut),1,
           ARTHUS.pk_personne.f_nom_compta(contrat.numcli),999999999 )            VAR17
         ,f_code_regroupement(
           ARTHUS.pk_cotis.f_idcotis (3,qttc_global.numquit),
          ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit),
          2,1,qttc_global.debut)                                           VAR18
         ,f_code_regroupement(
           ARTHUS.pk_cotis.f_idcotis (3,qttc_global.numquit),
          ARTHUS.pk_cotis.f_idcotis (1,qttc_global.numquit),
          2,1,qttc_global.debut)                                           VAR19
         ,to_char(CONTRAT.NUMGAR)                                          VAR20
         ,ARTHUS.pk_personne.f_nom(encaismt.numcli,15,2)                          VAR21
         ,contrat.portefeuille                                             VAR22
         ,TO_CHAR (qttc_global.debut, 'YYYY')                              VAR23
         ,to_char(encaismt.numcli)                                         VAR24
         ,'NV'                                                             VAR25
         ,'NV'                                                             VAR26
         ,'NV'                                                             VAR27
         ,'NV'                                                             VAR28
         ,to_char(F_CPTA_LIB_ENCAISMT(9271,encaismt.numencaismt,1))        VAR29
         ,to_char(compte_client.datope,'DD/MM/YY')                         VAR30                  
         ,to_char(f_cpta_date_encaismt_operation(encaismt.numencaismt)
                                                            ,'DD/MM/YY')   VAR31
         ,Substr( to_char(encaismt.numencaismt, '00000000'), 2, 8 )        VAR32
         ,ARTHUS.pk_contrat.f_contrat_info_compl(contrat.numgar
                                        , contrat.numgar,4)                VAR33
         ,'NV'                                                             VAR34
         ,to_char(f_cpta_date_constatation (compte_client.codope
                                ,qttc_global.numquit),'DD/MM/YY')          VAR35
  FROM  
    compte_client,
    encaismt,
    qttc_global,
    contrat  
  WHERE  contrat.numgar          = qttc_global.numgar
    AND  qttc_global.numquit     = compte_client.numfact
    AND  qttc_global.mt_affec_d  Is Not Null
    AND  encaismt.numencaismt    = compte_client.numencaismt
    AND  compte_client.montant   > 0
    AND  compte_client.codope    = 4
    AND  compte_client.idcompta  = -1
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA332 FOR ARTHUS.V_COMPTA332
