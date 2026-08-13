CREATE OR REPLACE PACKAGE ARTHUS.PK_REQUETE_ENGLOB AS 
  
/*============================================================================*/
/* Package      : PK_REQUETE_ENGLOB.sql                                       */
/* Domaine      : Traitements différés                                        */
/* Version      : V1.0                                                        */
/* Auteur       : CLI                                                         */
/* Création     : 21/03/2016                                                  */
/* Description  : Package contenant les requetes appélé précedemment pas le   */
/*              : client. elles sont maintenant englobées dans un package     */
/*              : ce qui permet une meilleure gestion des action de           */
/*              : l'utilisateur                                               */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/*
  Procédure de mise a jours des sinistre importé qui sont a l'etat 3 => passage a " à caluler" ( etat 2)
  BA611T
*/
  procedure P_up_sntr_prt_Cacules(i_numRemiseDeb IN NUMBER, 
                                  i_numRemiseFin IN NUMBER,
																	I_session      IN NUMBER,
																	I_Niv_msg      IN NUMBER
                                  );
   /*
   Procédure de mise a jours des sinistre importé qui sont a l'etat 3 => passage a "traité non calculé" (etat 4)
   Prend en paramétre le numero de brodereau de remise debut et fin, ainsi que le code frais ( FRT ou FRH)
   BA612T, BA613T
   */
  PROCEDURE P_up_sntr_prt_non_cacules(i_numRemiseDeb IN NUMBER, 
                                      i_numRemiseFin IN NUMBER,
                                      i_codfrais     IN VARCHAR2,
																			I_session      IN NUMBER,
																			I_Niv_msg      IN NUMBER);
  /*
   Mise à jour de la quantité/coefficient/frais réels lors des imports
   NOEMIE/TPE/ISANTE
  */
	  PROCEDURE p_BA62( i_num_remise 			IN NUMBER ,
											i_num_sin_ext 		IN NUMBER,
											i_nouvelle_valeur IN NUMBER,
											i_champ 					IN NUMBER, --( 1 - quantité/ 2 - coefficient/ 3 - frais réels)
											I_session      		IN NUMBER,
											I_Niv_msg      		IN NUMBER
                );
  /*
   Mise à jour de date de fin d’une adhésion pour des adhésions
   en anomalie
  */
  PROCEDURE p_BA64( i_num_adhesion 		IN NUMBER,
                    i_numfor 					IN NUMBER,
                    i_date_fin 				IN DATE,
                    i_date_a_modifier IN DATE,
										I_session      		IN NUMBER,
										i_numindiv				IN NUMBER,
										I_Niv_msg      		IN NUMBER

                );                                    

  /*
    Procédure d'historisation des modification sur les sinistres importés
  */
  PROCEDURE p_historisation_sinistre_porte( i_numRemiseDeb  IN NUMBER,
                                            i_numRemiseFin  IN NUMBER,
                                            i_code_frais    IN VARCHAR2,
                                            i_etat          IN NUMBER
                                          ); 
  /*
    Procédure d'historisation des modification sur les sinistres importés spécifique a BA612 et BA613
  */						  
  PROCEDURE p_histo_sntr_porte_BA612_BA613( i_numRemiseDeb  IN NUMBER,
																						i_numRemiseFin  IN NUMBER,
																						i_code_frais    IN VARCHAR2,
																						i_etat          IN NUMBER
																					);

   /*
   
   Procédure interne d'historisation des modification des sinistre_portes
   */
 PROCEDURE p_historisation_BA62(i_num_sin_ext IN NUMBER,
                                i_num_remise  IN NUMBER,
                                i_champ       IN NUMBER
                                        );

END PK_REQUETE_ENGLOB;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_REQUETE_ENGLOB" AS

  procedure P_up_sntr_prt_Cacules(i_numRemiseDeb NUMBER,
																	i_numRemiseFin NUMBER,
																	I_session      IN NUMBER,
																	I_Niv_msg      IN NUMBER) AS
  id_ligne NUMBER;
  BEGIN
	 id_ligne :=0;
   PK_TRACE.P_INS_JOURNAL_ADM( 	I_nom_traitement =>'BA611T',
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Début de traitement',
																I_idligne => id_ligne,
																I_date   => sysdate );
	 id_ligne :=id_ligne+1;			
   p_historisation_sinistre_porte(i_numRemiseDeb=>i_numRemiseDeb,
                                  i_numRemiseFin=>i_numRemiseFin,
                                  i_etat => 3,
                                  i_code_frais => 'PFH');
                                
    update sinistre_porte set etat=2 
    where etat=3 
      and codfrais='PFH' 
      and numremise BETWEEN i_numRemiseDeb and nvl(i_numRemiseFin,i_numRemiseDeb);
	  PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA611T',
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Fin normale du traitement',
																I_date   => sysdate,
																I_idligne => id_ligne );
		id_ligne :=id_ligne+1;
  EXCEPTION  -- exception handlers begin
   WHEN OTHERS THEN  
    PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA611T',
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Erreur dans le traitement => '||SQLERRM,
																I_date   => sysdate,
																I_idligne => id_ligne );
	 id_ligne :=id_ligne+1;
  END P_up_sntr_prt_Cacules;


PROCEDURE P_up_sntr_prt_non_cacules(i_numRemiseDeb 	IN NUMBER, 
                                    i_numRemiseFin 	IN NUMBER,
                                    i_codfrais    	IN VARCHAR2,
																		I_session      	IN NUMBER,
																		I_Niv_msg      	IN NUMBER) AS
 l_code_batch 	VARCHAR2(10);
 id_ligne 			NUMBER;
BEGIN
	 id_ligne :=0;
   SELECT DECODE (i_codfrais, 'FRT','BA612T', 'FRH','BA613T','erreur') into l_code_batch from dual;

   PK_TRACE.P_INS_JOURNAL_ADM( 	I_nom_traitement => l_code_batch,
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Dédut de traitement sur les codes '||i_codfrais,
																I_date   => sysdate,
																I_idligne => id_ligne );
	id_ligne := id_ligne+1;

   p_histo_sntr_porte_BA612_BA613( i_numRemiseDeb=>i_numRemiseDeb,
																	 i_numRemiseFin=>i_numRemiseFin,
																	 i_etat => 3,
																	 i_code_frais => i_codfrais);
	 id_ligne :=id_ligne+1;

       UPDATE sinistre_porte set etat=4 
          WHERE etat=3 
            AND codfrais_porte =i_codfrais 
            AND numremise BETWEEN i_numRemiseDeb AND nvl(i_numRemiseFin,i_numRemiseDeb);
            
			 PK_TRACE.P_INS_JOURNAL_ADM( 	I_nom_traitement => l_code_batch,
																		I_session   => I_session,
																		I_niv_msg   => 1,
																		I_msg_adm   => 'Fin de normale de traitement sur les codes '||i_codfrais,
																		I_date   => sysdate,
																		I_idligne => id_ligne );
 id_ligne := id_ligne+1;
            
EXCEPTION  -- exception handlers begin
   WHEN OTHERS THEN  
    PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>l_code_batch,
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Erreur dans le traitement => '||SQLERRM,
																I_date   => sysdate,
																I_idligne => id_ligne );
	 id_ligne :=id_ligne+1;
END P_up_sntr_prt_non_cacules;



PROCEDURE p_BA62( i_num_remise 		IN NUMBER ,
                  i_num_sin_ext 	IN NUMBER,
                  i_nouvelle_valeur IN NUMBER,
                  i_champ 			IN NUMBER, --( 1 - quantité/ 2 - coefficient/ 3 - frais réels)
                  I_session      	IN NUMBER,
									I_Niv_msg      	IN NUMBER
				) AS
id_ligne NUMBER;
BEGIN
 id_ligne :=0;
  PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA62T',
															I_session   => I_session,
															I_niv_msg   => 1,
															I_msg_adm   => 'Dédut de traitement BA62T',
															I_date   => sysdate,
															I_idligne => id_ligne);
 id_ligne := id_ligne+1;
                
      CASE 
        WHEN i_champ = 1 AND i_nouvelle_valeur IS NOT NULL THEN -- Problèmes de quantité(Appareillage et transport)
          p_historisation_BA62( i_num_sin_ext => i_num_sin_ext, i_num_remise => i_num_remise ,i_champ => i_champ );                      
          update sinistre_porte set quantite = i_nouvelle_valeur where numremise=i_num_remise  and numsin= i_num_sin_ext;
          
        WHEN i_champ = 2 AND i_nouvelle_valeur IS NOT NULL THEN --Problèmes de coéfficient (en phamacie surtout)	
          p_historisation_BA62( i_num_sin_ext => i_num_sin_ext, i_num_remise => i_num_remise ,i_champ => i_champ );
          update sinistre_porte set coeff = i_nouvelle_valeur where numremise = i_num_remise and numsin = i_num_sin_ext;
          
        WHEN i_champ = 3 THEN  --Différence entre Frais réels et Base rbt SS	
          p_historisation_BA62( i_num_sin_ext => i_num_sin_ext, i_num_remise => i_num_remise , i_champ => i_champ );
          update sinistre_porte set mtfrais = baseremb where numremise = i_num_remise and numsin = i_num_sin_ext;
          
        ELSE 
          PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA62T',
																			I_session   => I_session,
																			I_niv_msg   => 1,
																			I_msg_adm   => 'Les informations entrées ne permettent pas de prendre en compte la demande de traitement.',
																			I_date   => sysdate,
																			I_idligne =>id_ligne );
					id_ligne := id_ligne+1;
      END CASE;
      
      PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA62T',
																	I_session   => I_session,
																	I_niv_msg   => 1,
																	I_msg_adm   => 'Fin de traitement BA62T',
																	I_date   => sysdate,
																	I_idligne =>id_ligne);
			id_ligne := id_ligne+1;
                        
                        
                          EXCEPTION  -- exception handlers begin
   WHEN OTHERS THEN  
    PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA62T',
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Erreur dans le traitement => '||SQLERRM,
																I_date   => sysdate,
																I_idligne => id_ligne );
	id_ligne :=id_ligne+1;
END p_BA62;

PROCEDURE p_BA64( i_num_adhesion 	IN NUMBER,
                  i_numfor 			IN NUMBER,
                  i_date_fin 		IN DATE,
                  i_date_a_modifier IN DATE,
									I_session      	IN NUMBER,
									i_numindiv		IN NUMBER,
									I_Niv_msg      	IN NUMBER

                ) AS
				
id_ligne NUMBER;
BEGIN
	  id_ligne :=0;
     PK_TRACE.P_INS_JOURNAL_ADM( 	I_nom_traitement =>'BA64T',
																	I_session   => I_session,
																	I_niv_msg   => 1,
																	I_msg_adm   => 'Debut de traitement  BA64T',
																	I_date   		=> sysdate,
																	I_idligne 	=> id_ligne );
		id_ligne :=id_ligne+1;
         
		update adhesion set datper = i_date_fin 
			where numfor	= i_numfor 
				and idadhesion	= i_num_adhesion 
				and numindiv 	= i_numindiv
				and datper		= i_date_a_modifier;
            
		PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA64T',
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Fin de traitement BA64T',
																I_date   		=> sysdate,
																I_idligne 	=> id_ligne);
	id_ligne :=id_ligne+1;		
	                        
  EXCEPTION  
   WHEN OTHERS THEN  
    PK_TRACE.P_INS_JOURNAL_ADM( I_nom_traitement =>'BA64T',
																I_session   => I_session,
																I_niv_msg   => 1,
																I_msg_adm   => 'Erreur dans le traitement => '||SQLERRM,
																I_date   => sysdate,
																I_idligne => id_ligne );
	id_ligne :=id_ligne+1;

END p_BA64;
----------------------------------------------------------------------------------------------------------
------------------------------------------ PROCÉDURE GÉNÉRIQUES ------------------------------------------
----------------------------------------------------------------------------------------------------------


procedure p_historisation_sinistre_porte( i_numRemiseDeb IN  NUMBER,
                                          i_numRemiseFin IN  NUMBER,
                                          i_code_frais in VARCHAR2,
                                          i_etat IN NUMBER
                                        ) as
begin
insert into sinistre_porte_forcage( NUMREMISE ,    
																		NUMSIN    ,    
																		NUMORDRE  ,   
																		NUMZONE   ,   
																		DATFRCG   ,       
																		NUMUTIL   , 
																		VALEUR  ) 
       (select sinistre_porte.NUMREMISE           NUMREMISE,   
            sinistre_porte.NUMSIN                 NUMSIN, 
            nvl( max(numordre),0)+1               NUMORDRE,
            f_column_id('sinistre_porte', 'etat') NUMZONE, 
            sysdate                               DATFRCG,  
            f_numutil()                           NUMUTIL, 
            sinistre_porte.Etat                   VALEUR 
         from sinistre_porte, sinistre_porte_forcage 
         where sinistre_porte.etat = i_etat 
            and sinistre_porte.codfrais = i_code_frais
            and sinistre_porte.numsin = sinistre_porte_forcage.numsin  
            and sinistre_porte.numremise = sinistre_porte_forcage.numremise
            and sinistre_porte.numremise BETWEEN i_numRemiseDeb and nvl(i_numRemiseFin,i_numRemiseDeb)
        group by 
            sinistre_porte.numsin, 
            sinistre_porte.numremise,
            f_column_id('sinistre_porte', 'etat'),  
            f_numutil(), 
            sinistre_porte.Etat 
       ) ;
end  p_historisation_sinistre_porte;
procedure p_histo_sntr_porte_BA612_BA613( i_numRemiseDeb IN  NUMBER,
																					i_numRemiseFin IN  NUMBER,
																					i_code_frais in VARCHAR2,
																					i_etat IN NUMBER
                                        ) as
begin
insert into sinistre_porte_forcage(	NUMREMISE ,    
																		NUMSIN    ,    
																		NUMORDRE  ,   
																		NUMZONE   ,   
																		DATFRCG   ,       
																		NUMUTIL   , 
																		VALEUR  ) 
       (select sinistre_porte.NUMREMISE           NUMREMISE,   
            sinistre_porte.NUMSIN                 NUMSIN, 
            nvl( max(numordre),0)+1               NUMORDRE,
            f_column_id('sinistre_porte', 'etat') NUMZONE, 
            sysdate                               DATFRCG,  
            f_numutil()                           NUMUTIL, 
            sinistre_porte.Etat                   VALEUR 
         from sinistre_porte, sinistre_porte_forcage 
         where sinistre_porte.etat = i_etat 
            and sinistre_porte.codfrais_porte = i_code_frais
            and sinistre_porte.numsin=sinistre_porte_forcage.numsin  
            and sinistre_porte.numremise=sinistre_porte_forcage.numremise
            and sinistre_porte.numremise BETWEEN i_numRemiseDeb and nvl(i_numRemiseFin,i_numRemiseDeb)
        group by 
            sinistre_porte.numsin, 
            sinistre_porte.numremise,
            f_column_id('sinistre_porte', 'etat'),  
            f_numutil(), 
            sinistre_porte.Etat 
       ) ;
end   p_histo_sntr_porte_BA612_BA613;

procedure p_historisation_BA62( i_num_sin_ext IN NUMBER,
                                i_num_remise IN NUMBER,
                                i_champ     IN NUMBER
                                        ) as
l_numordre NUMBER;	
l_numzone VARCHAR(50);									
begin

select DECODE( i_champ , 1 , 'quantite' ,2,'coeff',3,'mtfrais' ) into l_numzone  from dual;

select nvl(max(numordre),0)+1 into l_numordre from sinistre_porte_forcage where numremise = i_num_remise and numsin = i_num_sin_ext; 

 insert into sinistre_porte_forcage(NUMREMISE ,    
																		NUMSIN    ,    
																		NUMORDRE  ,   
																		NUMZONE   ,   
																		DATFRCG   ,       
																		NUMUTIL   , 
																		VALEUR  )  
			(
			select 	i_num_remise      			NUMREMISE,   
							i_num_sin_ext           NUMSIN, 
							l_numordre              NUMORDRE,
							f_column_id('sinistre_porte', l_numzone) 	NUMZONE, 
							sysdate                               		DATFRCG,  
							f_numutil()                           		NUMUTIL, 
							(case when i_champ = 1 then sinistre_porte.quantite                 
										when i_champ = 2 then sinistre_porte.coeff
										when i_champ = 3 then sinistre_porte.mtfrais  
							end ) VALEUR
					 
			from sinistre_porte
			where 
						sinistre_porte.numremise = i_num_remise 
						and sinistre_porte.numsin= i_num_sin_ext);
/* requete factrorisée a revoir
insert into sinistre_porte_forcage( 
            NUMREMISE ,    
            NUMSIN    ,    
            NUMORDRE  ,   
            NUMZONE   ,   
            DATFRCG   ,       
            NUMUTIL   , 
            VALEUR  ) 
       (select sinistre_porte.NUMREMISE           NUMREMISE,   
            sinistre_porte.NUMSIN                 NUMSIN, 
            nvl( max(numordre),0)+1               NUMORDRE,
            f_column_id('sinistre_porte', DECODE( i_champ , 1 , 'quantite' ,2,'coeff',3,'mtfrais' )) NUMZONE, 
            sysdate                               DATFRCG,  
            f_numutil()                           NUMUTIL, 
			
            (case when i_champ = 1 then sinistre_porte.quantite                 
                 when i_champ = 2 then sinistre_porte.coeff
                 when i_champ = 3 then sinistre_porte.mtfrais  
            end case) valeur
         from sinistre_porte, sinistre_porte_forcage 
         where
                sinistre_porte.numremise = i_num_remise 
            and sinistre_porte.numsin= i_num_sin_ext
            --jointure
            and sinistre_porte.numsin=sinistre_porte_forcage.numsin  
            and sinistre_porte.numremise=sinistre_porte_forcage.numremise
        group by 
            sinistre_porte.numsin, 
            sinistre_porte.numremise,
            f_column_id('sinistre_porte', 'etat'),  
            f_numutil(), 
            sinistre_porte.Etat 
       ) ;
    */   
      
end  p_historisation_BA62;

END ;
/
