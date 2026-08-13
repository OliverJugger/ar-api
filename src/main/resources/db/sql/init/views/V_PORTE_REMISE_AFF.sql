CREATE FORCE VIEW ARTHUS.V_PORTE_REMISE_AFF AS
SELECT porte_remise.numremise, porte_remise.numporte,
          porte_param.type_circuit, porte_param.nat_porte,
          porte_remise.dateremise, porte_remise.dateporte,
          SUBSTR (ARTHUS.pk_libelle.f_lib ('PORTE', porte_remise.numporte),
                  1,
                  45
                 ) libelle,
          SUBSTR (   ARTHUS.pk_libelle.f_lib ('FIC_IMP', porte_remise.nature)
                  || ' du '
                  || TO_CHAR (NVL (porte_remise.dateporte,
                                   porte_remise.dateremise
                                  ),
                              'DD/MM/YYYY'
                             ),
                  1,
                  75
                 ) edateremise,
          porte_remise.nature,
          SUBSTR (   ARTHUS.pk_libelle.f_lib ('FIC_IMP', porte_remise.nature)
          || ' imp. le '
          || TO_CHAR ( porte_remise.dateremise, 'DD/MM/YYYY' )
          ||' '|| TRIM(porte_remise.ref_ext),1,75) libelle_2
        --  affil_fichier.entreprise,
       --   affil_fichier.numcli
     FROM porte_remise, porte_param--, affil_fichier
    WHERE porte_remise.numporte = porte_param.numporte
    --AND affil_fichier.numporte = porte_remise.numporte
    --AND affil_fichier.numremise = porte_remise.numremise
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PORTE_REMISE_AFF FOR ARTHUS.V_PORTE_REMISE_AFF
