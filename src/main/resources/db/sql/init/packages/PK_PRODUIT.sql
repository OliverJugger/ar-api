CREATE OR REPLACE PACKAGE ARTHUS.PK_PRODUIT AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_produit.sql	1.2  01/02/22
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --
-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --
-- -- TYPES PUBLIQUES ---------------------------------------------------------
-- Aucun
-- ------------------------------------------------- Fin des types publiques --
-- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--
-- Procedure permettant de mettre a jour les differentes tables en relation
-- avec la table Produit. Cette Procedure est appelee a partir du Trigger
-- sur la table Produit suite a la mise a jour de "deffet".
--
PROCEDURE P_UPD_relation_Produit(  I_numprod        IN produit.numprod%TYPE,
                                   I_old_deffet     IN produit.deffet%TYPE,
                                   I_new_deffet     IN produit.deffet%TYPE,
                                   I_Flag           IN VARCHAR2 DEFAULT NULL);
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_PRODUIT AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_produit.sql	1.2  01/02/22
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --
-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
PROCEDURE P_UPD_apporteur( I_cle            IN apporteur.cle%TYPE,
                           I_old_deffet     IN produit.deffet%TYPE,
                           I_new_deffet     IN produit.deffet%TYPE,
                           I_Flag           IN VARCHAR2);
--
PROCEDURE P_UPD_cond_adhesion( I_cle            IN cond_adhesion.cle%TYPE,
                               I_old_deffet     IN produit.deffet%TYPE,
                               I_new_deffet     IN produit.deffet%TYPE,
                               I_Flag           IN VARCHAR2);
--
PROCEDURE P_UPD_cond_proposition( I_cle           IN cond_proposition.cle%TYPE,
                                  I_old_deffet    IN produit.deffet%TYPE,
                                  I_new_deffet    IN produit.deffet%TYPE,
                                  I_Flag          IN VARCHAR2);
--
PROCEDURE P_UPD_grp_gar( I_clef           IN grp_gar.clef%TYPE,
                         I_old_deffet     IN produit.deffet%TYPE,
                         I_new_deffet     IN produit.deffet%TYPE,
                         I_Flag           IN VARCHAR2);
--
PROCEDURE P_UPD_val_variable ( I_clef           IN val_variable.clef%TYPE,
                               I_old_deffet     IN produit.deffet%TYPE,
                               I_new_deffet     IN produit.deffet%TYPE,
                               I_Flag           IN VARCHAR2);
--
PROCEDURE P_UPD_garanties( I_cle 	IN garanties.cle%TYPE,
                 	   I_old_debut 	IN garanties.debut%TYPE,
                 	   I_new_debut 	IN garanties.debut%TYPE,
                           I_Flag       IN VARCHAR2);
--
PROCEDURE P_UPD_frml_prime_simple( I_clef      IN frml_prime_simple.clef%TYPE,
                 	 	   I_old_debut IN frml_prime_simple.debut%TYPE,
	                     	   I_new_debut IN frml_prime_simple.debut%TYPE,
                                   I_Flag      IN VARCHAR2);
--
PROCEDURE P_UPD_frml_dedu( I_numfor 	IN frml_dedu.numfor%TYPE,
                 	   I_old_debut 	IN frml_dedu.debut%TYPE,
                       	   I_new_debut	IN frml_dedu.debut%TYPE,
                           I_Flag       IN VARCHAR2);
--
PROCEDURE P_UPD_frml_prest( I_numfor 	IN frml_prest.numfor%TYPE,
                 	    I_old_debut IN frml_prest.debut%TYPE,
                       	    I_new_debut	IN frml_prest.debut%TYPE,
                            I_Flag      IN VARCHAR2);
--
PROCEDURE P_UPD_frml_reval( I_numfor 	IN frml_reval.numfor%TYPE,
                 	    I_old_debut IN frml_reval.debut%TYPE,
                       	    I_new_debut	IN frml_reval.debut%TYPE,
                            I_Flag      IN VARCHAR2);
--
PROCEDURE P_UPD_formule( I_numprod 	IN formule.numprod%TYPE,
                         I_old_debut 	IN formule.debut%TYPE,
                         I_new_debut	IN formule.debut%TYPE,
                         I_Flag         IN VARCHAR2);
--
PROCEDURE P_UPD_calcul( I_numfor 	IN calcul.numfor%TYPE,
                        I_old_datapli	IN calcul.datapli%TYPE,
                        I_new_datapli	IN calcul.datapli%TYPE,
                        I_Flag          IN VARCHAR2);
--
PROCEDURE P_UPD_carence( I_numfor 	IN carence.numfor%TYPE,
                         I_old_datapli	IN carence.datapli%TYPE,
                         I_new_datapli	IN carence.datapli%TYPE,
                         I_Flag         IN VARCHAR2);
--
PROCEDURE P_UPD_cond_adhesion_gar( I_numfor    IN cond_adhesion_gar.numfor%TYPE,
                         	   I_old_debut IN cond_adhesion_gar.debut%TYPE,
                                   I_new_debut IN cond_adhesion_gar.debut%TYPE,
                                   I_Flag      IN VARCHAR2);
--
PROCEDURE P_UPD_franact( I_numfor 	IN franact.numfor%TYPE,
                         I_old_datapli	IN franact.datapli%TYPE,
                         I_new_datapli	IN franact.datapli%TYPE,
                         I_Flag         IN VARCHAR2);
--
PROCEDURE P_UPD_franfor( I_numfor 	IN franfor.numfor%TYPE,
                         I_old_datapli	IN franfor.datapli%TYPE,
                         I_new_datapli	IN franfor.datapli%TYPE,
                         I_Flag         IN VARCHAR2);
--
PROCEDURE P_UPD_maxact( I_numfor 	IN maxact.numfor%TYPE,
                        I_old_datapli	IN maxact.datapli%TYPE,
                        I_new_datapli	IN maxact.datapli%TYPE,
                        I_Flag          IN VARCHAR2);
--
PROCEDURE P_UPD_maxfor( I_numfor 	IN maxfor.numfor%TYPE,
                        I_old_datapli	IN maxfor.datapli%TYPE,
                        I_new_datapli	IN maxfor.datapli%TYPE,
                        I_Flag          IN VARCHAR2);
--
PROCEDURE P_UPD_defrub( I_numfor 	IN defrub.numfor%TYPE,
                        I_old_datapli	IN defrub.datapli%TYPE,
                        I_new_datapli	IN defrub.datapli%TYPE,
                        I_Flag          IN VARCHAR2);
--
PROCEDURE P_UPD_frml_tfc( I_numfor	IN frml_tfc.numfor%TYPE,
                	  I_old_debut	IN frml_tfc.debut%TYPE,
                	  I_new_debut	IN frml_tfc.debut%TYPE,
                          I_Flag        IN VARCHAR2);
--
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
PROCEDURE P_UPD_relation_produit ( I_numprod        IN produit.numprod%TYPE,
                                   I_old_deffet     IN produit.deffet%TYPE,
                                   I_new_deffet     IN produit.deffet%TYPE,
                                   I_Flag           IN VARCHAR2 DEFAULT NULL)
IS
BEGIN
  P_UPD_apporteur( I_cle        => I_numprod,
                   I_old_deffet => I_old_deffet,
                   I_new_deffet => I_new_deffet,
                   I_Flag       => I_Flag);
  --
  P_UPD_cond_adhesion( I_cle        => I_numprod,
                       I_old_deffet => I_old_deffet,
                       I_new_deffet => I_new_deffet,
                       I_Flag       => I_Flag);
  --
  P_UPD_cond_proposition( I_cle        => I_numprod,
                          I_old_deffet => I_old_deffet,
                          I_new_deffet => I_new_deffet,
                          I_Flag       => I_Flag);
  --
  P_UPD_grp_gar( I_clef       => I_numprod,
                 I_old_deffet => I_old_deffet,
                 I_new_deffet => I_new_deffet,
                 I_Flag       => I_Flag);
  --
  P_UPD_val_variable ( I_clef       => I_numprod,
                       I_old_deffet => I_old_deffet,
                       I_new_deffet => I_new_deffet,
                       I_Flag       => I_Flag);
  --
  P_UPD_garanties( I_cle       => I_numprod,
                   I_old_debut => I_old_deffet,
                   I_new_debut => I_new_deffet,
                   I_Flag      => I_Flag);
  --
  P_UPD_formule( I_numprod     => I_numprod,
                 I_old_debut   => I_old_deffet,
                 I_new_debut   => I_new_deffet,
                 I_Flag        => I_Flag);
  --
  P_UPD_frml_prime_simple( I_clef      => I_numprod,
            	           I_old_debut => I_old_deffet,
                 	   I_new_debut => I_new_deffet,
                           I_Flag      => I_Flag);
  --
END;
--
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
PROCEDURE P_UPD_apporteur( I_cle                  IN apporteur.cle%TYPE,
                           I_old_deffet           IN produit.deffet%TYPE,
                           I_new_deffet           IN produit.deffet%TYPE,
                           I_Flag                 IN VARCHAR2)
IS
BEGIN
  Update  apporteur
  Set     debut   = I_new_deffet
  Where   etendue = 7
  And     cle     = I_cle
  And     (  ( Trunc(debut) = I_old_deffet
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_cond_adhesion( I_cle              IN cond_adhesion.cle%TYPE,
                               I_old_deffet       IN produit.deffet%TYPE,
                               I_new_deffet       IN produit.deffet%TYPE,
                               I_Flag             IN VARCHAR2)
IS
BEGIN
  Update  Cond_adhesion
  Set     debut   = I_new_deffet
  Where   etendue = 7
  And     cle     = I_cle
  And     (  (Trunc(debut) = I_old_deffet
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_cond_proposition(I_cle            IN cond_proposition.cle%TYPE,
                           	 I_old_deffet     IN produit.deffet%TYPE,
                           	 I_new_deffet     IN produit.deffet%TYPE,
                                 I_Flag           IN VARCHAR2)
IS
BEGIN
  Update  cond_proposition
  Set     debut   = I_new_deffet
  Where   etendue = 7
  And     cle     = I_cle
  And     (  (Trunc(debut) = I_old_deffet
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_grp_gar( I_clef                 IN grp_gar.clef%TYPE,
                         I_old_deffet           IN produit.deffet%TYPE,
                         I_new_deffet           IN produit.deffet%TYPE,
                         I_Flag                 IN VARCHAR2)
IS
BEGIN
  Update  grp_gar
  Set     datapli = I_new_deffet
  Where   etendue = 7
  And     clef    = I_clef
  And     (  (Trunc(datapli) = I_old_deffet
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_val_variable ( I_clef             IN val_variable.clef%TYPE,
                               I_old_deffet       IN produit.deffet%TYPE,
                               I_new_deffet       IN produit.deffet%TYPE,
                               I_Flag             IN VARCHAR2)
IS
BEGIN
  Update val_variable
  Set     debut    = I_new_deffet
  Where   etendue  = 7
  And     clef     = I_clef
  And     statique = 'O'
  And     (  (Trunc(debut) = I_old_deffet
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
--
PROCEDURE P_UPD_garanties( I_cle 	IN garanties.cle%TYPE,
                 	   I_old_debut 	IN garanties.debut%TYPE,
                 	   I_new_debut 	IN garanties.debut%TYPE,
                           I_Flag       IN VARCHAR2)
IS
  CURSOR C_garanties IS
         Select numfor
         From   garanties
         Where   cle = I_cle
         And     etendue = 7
  	 And     (  (Trunc(debut) = I_old_debut
                     And I_flag Is Null
                    )
                  Or( I_Flag Is Not Null
                    )
                 )
         For Update of debut;
--
L_numfor   Garanties.Numfor%TYPE;
BEGIN
  OPEN C_garanties;
  LOOP
     FETCH C_garanties INTO L_numfor;
     EXIT WHEN C_garanties%NOTFOUND;
     --
     -- Mise a jour des differentes tables a partir du Numfor
     P_UPD_frml_dedu( I_numfor    => L_numfor,
                      I_old_debut => I_old_debut,
                      I_new_debut => I_new_debut,
                      I_Flag      => I_Flag);
     --
     P_UPD_frml_prest( I_numfor    => L_numfor,
                       I_old_debut => I_old_debut,
                       I_new_debut => I_new_debut,
                       I_Flag      => I_Flag);
     --
     P_UPD_frml_reval( I_numfor    => L_numfor,
                       I_old_debut => I_old_debut,
                       I_new_debut => I_new_debut,
                       I_Flag      => I_Flag);
     --
     UPDATE Garanties
     Set    debut = I_new_debut
     Where  Current of C_garanties;
     --
  END LOOP;
  CLOSE C_garanties;
END;
--
PROCEDURE P_UPD_frml_dedu( I_numfor 	IN frml_dedu.numfor%TYPE,
                 	   I_old_debut 	IN frml_dedu.debut%TYPE,
                       	   I_new_debut	IN frml_dedu.debut%TYPE,
                           I_Flag       IN VARCHAR2)
IS
BEGIN
  Update frml_dedu
  Set    debut  =  I_new_debut
  Where	 numfor =  I_numfor
  And     (  (Trunc(debut) = I_old_debut
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_frml_prest( I_numfor 	IN frml_prest.numfor%TYPE,
                 	    I_old_debut IN frml_prest.debut%TYPE,
                       	    I_new_debut	IN frml_prest.debut%TYPE,
                            I_Flag      IN VARCHAR2)
IS
BEGIN
  Update frml_prest
  Set    debut  =  I_new_debut
  Where	 numfor =  I_numfor
  And     (  (Trunc(debut) = I_old_debut
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_frml_reval( I_numfor 	IN frml_reval.numfor%TYPE,
                 	    I_old_debut IN frml_reval.debut%TYPE,
                       	    I_new_debut	IN frml_reval.debut%TYPE,
                            I_Flag      IN VARCHAR2)
IS
BEGIN
  Update frml_reval
  Set    debut  =  I_new_debut
  Where	 numfor =  I_numfor
  And     (  (Trunc(debut) = I_old_debut
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_formule( I_numprod 	IN formule.numprod%TYPE,
                         I_old_debut 	IN formule.debut%TYPE,
                         I_new_debut	IN formule.debut%TYPE,
                         I_Flag         IN VARCHAR2)
IS
  CURSOR C_formule IS
         Select numfor
         From   formule
         Where  numprod = I_numprod
  	 And     (  (Trunc(debut) = I_old_debut
                     And I_flag Is Null
                    )
                  Or( I_Flag Is Not Null
                    )
                 )
         For Update of debut;
--
  L_numfor   Formule.Numfor%TYPE;
--
BEGIN
  OPEN C_formule;
  LOOP
     FETCH C_formule INTO L_numfor;
     EXIT WHEN C_formule%NOTFOUND;
     -- Mise a jour des differentes tables a partir du Numfor
     --
     P_UPD_calcul( I_numfor      => L_numfor,
                   I_old_datapli => I_old_debut,
                   I_new_datapli => I_new_debut,
                   I_Flag        => I_Flag);
     --
     P_UPD_carence( I_numfor      => L_numfor,
                    I_old_datapli => I_old_debut,
                    I_new_datapli => I_new_debut,
                    I_Flag        => I_Flag);
     --
     P_UPD_cond_adhesion_gar( I_numfor    => L_numfor,
                              I_old_debut => I_old_debut,
                              I_new_debut => I_new_debut,
                              I_Flag      => I_Flag);
     --
     P_UPD_franact( I_numfor      => L_numfor,
                    I_old_datapli => I_old_debut,
                    I_new_datapli => I_new_debut,
                    I_Flag        => I_Flag);
     --
     P_UPD_franfor( I_numfor      => L_numfor,
                    I_old_datapli => I_old_debut,
                    I_new_datapli => I_new_debut,
                    I_Flag        => I_Flag);
     --
     P_UPD_maxact ( I_numfor      => L_numfor,
                    I_old_datapli => I_old_debut,
                    I_new_datapli => I_new_debut,
                    I_Flag        => I_Flag);
     --
     P_UPD_maxfor(  I_numfor      => L_numfor,
                    I_old_datapli => I_old_debut,
                    I_new_datapli => I_new_debut,
                    I_Flag        => I_Flag);
     --
     P_UPD_defrub( I_numfor      => L_numfor,
                   I_old_datapli => I_old_debut,
                   I_new_datapli => I_new_debut,
                   I_Flag        => I_Flag);
     --
     UPDATE Formule
     Set    debut = I_new_debut
     Where  Current of C_formule;
     --
  END LOOP;
  CLOSE C_formule;
END;
--
PROCEDURE P_UPD_calcul( I_numfor 	IN calcul.numfor%TYPE,
                        I_old_datapli	IN calcul.datapli%TYPE,
                        I_new_datapli	IN calcul.datapli%TYPE,
                        I_Flag          IN VARCHAR2)
IS
BEGIN
  Update calcul
  Set    datapli=  I_new_datapli
  Where	 numfor =  I_numfor
  And     (  (Trunc(datapli) = I_old_datapli
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_carence( I_numfor 	IN carence.numfor%TYPE,
                         I_old_datapli	IN carence.datapli%TYPE,
                         I_new_datapli	IN carence.datapli%TYPE,
                         I_Flag         IN VARCHAR2)
IS
BEGIN
  Update carence
  Set    datapli=  I_new_datapli
  Where	 numfor =  I_numfor
  And     (  (Trunc(datapli) = I_old_datapli
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_cond_adhesion_gar( I_numfor    IN cond_adhesion_gar.numfor%TYPE,
                         	   I_old_debut IN cond_adhesion_gar.debut%TYPE,
                                   I_new_debut IN cond_adhesion_gar.debut%TYPE,
                                   I_Flag      IN VARCHAR2)
IS
BEGIN
  Update cond_adhesion_gar
  Set    debut  =  I_new_debut
  Where	 numfor =  I_numfor
  And     (  (Trunc(debut) = I_old_debut
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_franact( I_numfor 	IN franact.numfor%TYPE,
                         I_old_datapli	IN franact.datapli%TYPE,
                         I_new_datapli	IN franact.datapli%TYPE,
                         I_Flag         IN VARCHAR2)
IS
BEGIN
  Update franact
  Set    datapli=  I_new_datapli
  Where	 numfor =  I_numfor
  And     (  (Trunc(datapli) = I_old_datapli
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_franfor( I_numfor 	IN franfor.numfor%TYPE,
                         I_old_datapli	IN franfor.datapli%TYPE,
                         I_new_datapli	IN franfor.datapli%TYPE,
                         I_Flag         IN VARCHAR2)
IS
BEGIN
  Update franfor
  Set    datapli=  I_new_datapli
  Where	 numfor =  I_numfor
  And     (  (Trunc(datapli) = I_old_datapli
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_maxact( I_numfor 	IN maxact.numfor%TYPE,
                        I_old_datapli	IN maxact.datapli%TYPE,
                        I_new_datapli	IN maxact.datapli%TYPE,
                        I_Flag          IN VARCHAR2)
IS
BEGIN
  Update maxact
  Set    datapli=  I_new_datapli
  Where	 numfor =  I_numfor
  And     (  (Trunc(datapli) = I_old_datapli
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_maxfor( I_numfor 	IN maxfor.numfor%TYPE,
                        I_old_datapli	IN maxfor.datapli%TYPE,
                        I_new_datapli	IN maxfor.datapli%TYPE,
                        I_Flag          IN VARCHAR2)
IS
BEGIN
  Update maxfor
  Set    datapli=  I_new_datapli
  Where	 numfor =  I_numfor
  And     (  (Trunc(datapli) = I_old_datapli
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_defrub( I_numfor 	IN defrub.numfor%TYPE,
                        I_old_datapli	IN defrub.datapli%TYPE,
                        I_new_datapli	IN defrub.datapli%TYPE,
                        I_Flag          IN VARCHAR2)
IS
BEGIN
  Update defrub
  Set    datapli=  I_new_datapli
  Where	 numfor =  I_numfor
  And     (  (Trunc(datapli) = I_old_datapli
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
PROCEDURE P_UPD_frml_prime_simple( I_clef      IN frml_prime_simple.clef%TYPE,
                 	 	   I_old_debut IN frml_prime_simple.debut%TYPE,
	                     	   I_new_debut IN frml_prime_simple.debut%TYPE,
                                   I_Flag      IN VARCHAR2)
IS
  CURSOR C_prime_simple IS
         Select numfor
         From   frml_prime_simple
         Where   clef = I_clef
  	 And     (  (Trunc(debut) = I_old_debut
                     And I_flag Is Null
                    )
                  Or( I_Flag Is Not Null
                    )
                 )
         For Update of debut;
--
L_numfor   frml_prime_simple.Numfor%TYPE;
--
BEGIN
  OPEN C_prime_simple;
  LOOP
     FETCH C_prime_simple INTO L_numfor;
     EXIT WHEN C_prime_simple%NOTFOUND;
     -- Mise a jour de la table frm_tfc a partir du Numfor
     --
     P_UPD_frml_tfc( I_numfor    => L_numfor,
                     I_old_debut => I_old_debut,
                     I_new_debut => I_new_debut,
                     I_Flag      => I_Flag);
     --
     UPDATE frml_prime_simple
     Set    debut = I_new_debut
     Where  Current of C_prime_simple;
     --
  END LOOP;
  CLOSE C_prime_simple;
END;
--
PROCEDURE P_UPD_frml_tfc( I_numfor	IN frml_tfc.numfor%TYPE,
                	  I_old_debut	IN frml_tfc.debut%TYPE,
                	  I_new_debut	IN frml_tfc.debut%TYPE,
                          I_Flag        IN VARCHAR2)
IS
BEGIN
  Update frml_tfc
  Set    debut  =  I_new_debut
  Where	 numfor =  I_numfor
  And     (  (Trunc(debut) = I_old_debut
               And I_flag Is Null
             )
           Or( I_Flag Is Not Null
             )
          );
END;
--
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
