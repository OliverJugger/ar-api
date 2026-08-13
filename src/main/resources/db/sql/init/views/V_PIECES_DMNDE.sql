CREATE FORCE VIEW ARTHUS.V_PIECES_DMNDE AS
SELECT   p.ROWID AS ROW_ID
       , p.NUMENVOI
       , p.CONTEXTE
       , p.ENTITE
       , p.NUMFOR
       , p.NUMBENE
       , p.NUMINDIV_DEST
       , p.IDREPARTITION
       , p.NOPIECE
       , p.DELAI
       , p.PERIOD
       , p.NBREL
       , p.BLOC
       , p.DATEENREG
       , p.DATEAVIS
       , p.DATERECEP
       , p.DATEREL
       , p.RENOUV
       , p.DATANNUL
       , p.IDPIECE
       FROM pieces p, repartition, repartition_bene
      WHERE repartition_bene.idrepartition = repartition.idrepartition
        AND p.idrepartition = repartition.idrepartition
        AND repartition_bene.valide = 'O'
        AND repartition.valide = 'O'
        AND repartition_bene.numbene = p.numbene
        AND p.idrepartition > 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PIECES_DMNDE FOR ARTHUS.V_PIECES_DMNDE
