CREATE FORCE VIEW ARTHUS.V_COMPTA512 AS
SELECT  contrat.numinterm                                               numsoc
         ,3                                                              rolesoc
         ,'affectation'                                               sur_entite
         ,affectation.numdecaismt                                     cle_unique
         ,'affectation'                                                   entite
         ,1                                                            reg_piece
         ,affectation.numdecaismt                                            cle
         ,affectation.idcompta                                          idcompta
         ,512                                                             codope
         ,'5'                                                             scdope
         ,''                                                             codjnal
         ,1                                                             type_ope
         ,0                                                                  cie
         ,decaismt.numbene                                                  indv
         ,0                                                                  gar
         ,0                                                                  int
         ,''                                                                 bqe
         --,Substr( to_char(affectation.numaffec, '00000000'), 2, 8 )
         ,Substr( to_char(DECODE(f_numbord_decaismt (decaismt.numdecaismt)
           ,0,decaismt.numdecaismt,f_numbord_decaismt (decaismt.numdecaismt)), '00000000'), 2, 8 )
          || to_char(f_cpta_date_decaismt_operation(decaismt.numdecaismt),'DDMMYY') refpiece
         ,f_cpta_date_decaismt_operation(decaismt.numdecaismt)         dat_piece
         ,nvl(decaismt.refpmt,decaismt.numdecaismt)                  lib_piece_1
         ,decaismt.numbene                                           lib_piece_2
         ,SUM (v_reversement_pretot.montant_d)                          montant1
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
         ,v_reversement_pretot.monnaie_d                                  devise
         ,SUM (v_reversement_pretot.montant_d)                       montant1_ct
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
         ,v_reversement_pretot.monnaie_d                               devise_ct
         ,'NV'                                                             VAR01
         ,'NV'                                                             VAR02
         ,'NV'                                                             VAR03
         ,'NV'                                                             VAR04
         ,'NV'                                                             VAR05
         ,'NV'                                                             VAR06
         ,'NV'                                                             VAR07
         ,'NV'                                                             VAR08
         ,'NV'                                                             VAR09
         ,ARTHUS.pk_personne.f_nom_compta (v_reversement_pretot.numorg)           VAR10
         ,'NV'                                                             VAR11
         ,TO_CHAR(v_reversement_pretot.numorg)                             VAR12
         ,'NV'                                                             VAR13
         ,f_code_regroupement(ARTHUS.pk_cotis.f_idcotis (
          3, v_reversement_pretot.numquit),ARTHUS.pk_cotis.f_idcotis (
          1, v_reversement_pretot.numquit),2,1,v_reversement_pretot.debut) VAR14
         ,TO_CHAR (contrat.numgar_ref)                                     VAR15
         ,'NV'                                                             VAR16
         ,decode (ARTHUS.pk_personne.f_dependance (decaismt.numbene,99,decaismt.datpay),
          1,ARTHUS.pk_personne.f_nom_compta (decaismt.numbene),999999999)         VAR17
         ,'NV'                                                             VAR18
         ,'NV'                                                             VAR19
         ,'NV'                                                             VAR20 -- to_char(contrat.numgar)
         ,ARTHUS.pk_personne.f_nom(affectation.numcli,15,2)                       VAR21
         ,'NV'                                                             VAR22 -- contrat.portefeuille
         ,TO_CHAR (decaismt.datpay, 'YYYY')                                VAR23
         ,To_char(affectation.numcli)                                      VAR24
         ,'NV'                                                             VAR25
         ,'NV'                                                             VAR26
         ,'NV'                                                             VAR27
         ,'NV'                                                             VAR28
         ,to_char(affectation.numaffec)                                    VAR29
         ,to_char(f_cpta_date_decaismt_operation(decaismt.numdecaismt)
                                                              ,'DD/MM/YY') VAR30
         --,to_char(reversement.datrevers,'DD/MM/YY')                        VAR31
         ,to_char(reversement.datvalide,'DD/MM/YY')                        VAR31
         ,TO_CHAR (DECODE(f_numbord_decaismt (decaismt.numdecaismt)
                            ,0
                            ,decaismt.numdecaismt
                            ,f_numbord_decaismt (decaismt.numdecaismt)
                     ))                                                    VAR32 --Substr( to_char(decaismt.numdecaismt, '00000000'), 2, 8 )
         ,'NV'                                                             VAR33
         ,'NV'                                                             VAR34
         ,'NV'                                                             VAR35
  FROM v_affectation_cpta affectation
      ,compte
      ,decaismt
       --,decompte
      ,contrat
      ,reversement
      ,v_reversement_pretot
  WHERE decaismt.numdecaismt    = affectation.numdecaismt
    AND compte.numcpte          = decaismt.numcpte
    AND reversement.idrevers    = affectation.numaffec
    AND v_reversement_pretot.idrevers = affectation.numaffec
    AND affectation.codope      = 5
    AND affectation.idcompta    = -1
    AND decaismt.flagpay        = 1
    AND reversement.valide      = 'O'
--    AND decompte.numdec         = decaismt.numdecaismt
--    AND decompte.numdec         = affectation.numaffec -- FAUX
    AND contrat.numgar          = v_reversement_pretot.numgar
  GROUP BY
          contrat.numinterm
         ,affectation.numdecaismt
         ,affectation.numdecaismt
         ,affectation.idcompta
         ,decaismt.numbene
         --,Substr( to_char(affectation.numaffec, '00000000'), 2, 8 )
         ,Substr( to_char(DECODE(f_numbord_decaismt (decaismt.numdecaismt)
          ,0,decaismt.numdecaismt,f_numbord_decaismt (decaismt.numdecaismt)), '00000000'), 2, 8 )
          || to_char(f_cpta_date_decaismt_operation(decaismt.numdecaismt),'DDMMYY')
         ,f_cpta_date_decaismt_operation(decaismt.numdecaismt)
         ,nvl(decaismt.refpmt,decaismt.numdecaismt)
         ,decaismt.numbene
         ,v_reversement_pretot.monnaie_d
         ,ARTHUS.pk_personne.f_nom_compta (v_reversement_pretot.numorg)
         ,TO_CHAR(v_reversement_pretot.numorg)
         ,f_code_regroupement(ARTHUS.pk_cotis.f_idcotis (
          3, v_reversement_pretot.numquit),ARTHUS.pk_cotis.f_idcotis (
          1, v_reversement_pretot.numquit),2,1,v_reversement_pretot.debut)
         ,TO_CHAR (contrat.numgar_ref)
         ,decode (ARTHUS.pk_personne.f_dependance (decaismt.numbene,99,decaismt.datpay),
          1,ARTHUS.pk_personne.f_nom_compta (decaismt.numbene),999999999)
         ,ARTHUS.pk_personne.f_nom(affectation.numcli,15,2)
         ,TO_CHAR (decaismt.datpay, 'YYYY')
         ,To_char(affectation.numcli)
         ,to_char(affectation.numaffec)
         ,to_char(f_cpta_date_decaismt_operation(decaismt.numdecaismt),'DD/MM/YY')
         --,to_char(reversement.datrevers,'DD/MM/YY')
         ,to_char(reversement.datvalide,'DD/MM/YY')
         ,TO_CHAR (DECODE(f_numbord_decaismt (decaismt.numdecaismt),0
          ,decaismt.numdecaismt,f_numbord_decaismt (decaismt.numdecaismt)))
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA512 FOR ARTHUS.V_COMPTA512
