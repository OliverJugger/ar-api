CREATE FORCE VIEW ARTHUS.V_COMPTA_ECRAN AS
SELECT   idcompta, numsoc, codope, type_ope, journal, refpiece, dat_piece,
            compte, sens, montant, DECODE (sens, 'D', montant_ct) debit,
            DECODE (sens, 'C', montant_ct) credit,
            ARTHUS.pk_compta.f_lib_ventil (numsoc,
                                    codope,
                                    scdope,
                                    rolesoc,
                                    numordre
                                   ) lib_ecriture,
            ARTHUS.pk_compta.f_lib_ecriture (compta.numsoc,
                                      compta.codope,
                                      compta.type_ope,
                                      compta.lib_piece_1,
                                      compta.lib_piece_2,
                                      'N'
                                     ) lib_piece,
            numtiers, numpiece, numordre, lib_piece_1, lib_piece_2, central,
            entite, cle, compte_aux, devise, libelle, axana1, axana2, axana3,
            axana4, axana5, zonex1, zonex2, zonex3, zonex4, zonex5, nature,
            scdope, zserv1, zserv2, zserv3, zserv4, zserv5, montant_ct,
            devise_ct, idcptacent, zreg, zreg_val, rolesoc, refpiececent,
            reg_piece
       FROM compta
   ORDER BY idcompta,
            codope,
            scdope,
            journal,
            refpiececent,
            refpiece,
            numtiers,
            sens desc,
            montant,
            compte,
            lib_piece
GO
CREATE OR REPLACE PUBLIC SYNONYM V_COMPTA_ECRAN FOR ARTHUS.V_COMPTA_ECRAN
