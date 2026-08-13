CREATE FORCE VIEW ARTHUS.V_LIB_AFFEC AS
SELECT affectation.codope, affectation.numaffec, affectation.numdecaismt,
          DECODE (affectation.codope,
                  1,  'Décpte maladie'
                   || ' No '
                   || affectation.numaffec
                   || ' du '
                   || TO_CHAR (affectation.dataffec, 'dd/mm/yy'),
                  2,  'Décpte prevoyance'
                   || ' No '
                   || affectation.numaffec
                   || ' du '
                   || TO_CHAR (affectation.dataffec, 'dd/mm/yy'),
                  5, f_piece_detail (affectation.codope, affectation.numaffec),
                  6, f_piece_detail (affectation.codope, affectation.numaffec),
                  8, f_piece_detail (affectation.codope, affectation.numaffec),
                  9,  'Annulé le '
                   || f_piece_detail (affectation.codope,
                                      affectation.numaffec),
                  10, 'Règlement fournisseur',
                  11, f_piece_detail (affectation.codope,
                                      affectation.numaffec)
                 ) lib_affec,
          affectation.montant montant, affectation.monnaie,
          affectation.montant_d montant_d, affectation.monnaie_d,
          DECODE (affectation.codope,
                  1, 'gd01',
                  2, 'gdp1',
                  5, '',
                  6, '',
                  8, '',
                  9, '',
                  10, 'de54',
                  11, 'gdd1'
                 ) codapli
     FROM affectation
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIB_AFFEC FOR ARTHUS.V_LIB_AFFEC
