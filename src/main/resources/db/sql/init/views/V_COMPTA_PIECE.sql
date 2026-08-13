CREATE FORCE VIEW ARTHUS.V_COMPTA_PIECE AS
SELECT                                                         /* + RULE */
            compta.idcompta, compta.numsoc, compta.codope, compta.scdope,
            compta.journal, compta.refpiece, compta.dat_piece,
            compta.numpiece,
            SUM (DECODE (compta.sens, 'C', compta.montant, NULL)) credit,
            SUM (DECODE (compta.sens, 'D', compta.montant, NULL)) debit,
            DECODE (  SUM (DECODE (compta.sens, 'C', compta.montant, 0))
                    - SUM (DECODE (compta.sens, 'D', compta.montant, 0)),
                    0, 0,
                    1
                   ) solde,
            compta.type_ope, compta.lib_piece_1, compta.lib_piece_2,
            ARTHUS.pk_compta.f_lib_ecriture (compta.numsoc,
                                      compta.codope,
                                      compta.type_ope,
                                      compta.lib_piece_1,
                                      compta.lib_piece_2,
                                      'N'
                                     ) lib_piece,
            compta.devise
       FROM compta
   GROUP BY compta.idcompta,
            compta.numsoc,
            compta.codope,
            compta.journal,
            compta.refpiece,
            compta.dat_piece,
            compta.numpiece,
            compta.type_ope,
            compta.lib_piece_1,
            compta.lib_piece_2,
            compta.devise,
            compta.scdope
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_PIECE FOR ARTHUS.V_COMPTA_PIECE
