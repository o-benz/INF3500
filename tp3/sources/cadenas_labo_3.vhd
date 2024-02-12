---------------------------------------------------------------------------------------------------
-- 
-- cadenas_labo_3.vhd
--
-- v. 1.0 Pierre Langlois 2022-01-21 laboratoire #3 INF3500, fichier de démarrage
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity cadenas_labo_3 is
    generic (
        M : positive := 5; -- le nombre d'entrées dans la combinaison
        N : positive := 4 -- le nombre de boutons
        );
    port (
        reset, clk : in std_logic;
        boutons : in std_logic_vector(N - 1 downto 0);
        mode : in std_logic_vector(1 downto 0);
        ouvrir : out std_logic;
        alarme : out std_logic;
        message : out string
        );
end cadenas_labo_3;

architecture arch of cadenas_labo_3 is
    
    type etat_type is (e_00, e_01, e_02, e_03, e_04, e_05, e_bon, e_echec, e_set0, e_set1, e_set2, e_set3, e_set4, e_alrm);
    signal etat : etat_type := e_00;
    
    type combinaison_type is array (0 to M - 1) of std_logic_vector(N - 1 downto 0);
    constant combinaison_base : combinaison_type := ("0001", "0010", "0100", "1000", "0001");							  
    signal combinaison : combinaison_type := combinaison_base;
	  
	signal echec : boolean := false;
	signal compte_echec : integer := 0;
	
begin	
																					
    
    -- processus pour la séquence des états comme dans la partie 1 avec quelques modifications pour la partie 2
    process(boutons)
    begin
        if reset = '1' then
            etat <= e_00; 
			echec <= false;
        elsif boutons /= "0000" then
			if mode = "01" then  -- mode de fonctionnement obfusqué bonus 
            	case etat is
	                when e_00 => 
						echec <= false;
	                    if boutons /= combinaison(0) then --comparaison de boutons directement avec la bonne combinaison 
							echec <= true;
	                    end if;
						etat <= e_01; 
	                when e_01 =>
	                    if boutons /= combinaison(1) then 
							echec <= true;
	                    end if;	 
						 etat <= e_02;
	                when e_02 =>
						if boutons /= combinaison(2) then  
							echec <= true;
	                    end if;	
						etat <= e_03;
	                when e_03 =>
	                    if boutons /= combinaison(3) then  
							echec <= true;
	                    end if;
						etat <= e_04;
	                when e_04 =>
	                    if boutons /= combinaison(4) then 
							echec <= true;
	                    end if;
						etat <= e_05; 
						
					--code pour la partie 2, entrée de la nouvelle combinaison
					when e_05 => 
						if echec = false then -- bonus
							etat <= e_bon;
						else
							compte_echec <= compte_echec + 1;
							etat <= e_echec;
						end if;
					--bonus	
					when e_bon =>
						if boutons(1) = '1' and boutons(3) = '1' then 
							etat <= e_set0;	
						elsif boutons(0) = '1' and boutons(2) = '1' then
							etat <= e_00; 
						end if;
					when e_echec =>
						if compte_echec = 3	then
							etat <= e_alrm;
						else
							etat <= e_00;
						end if;
					when e_alrm =>
						if reset = '1' then
							etat <= e_00;
						end if;	
					--fin bonus
					when e_set0	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(0) <= boutons;
							etat <= e_set1;
						end if;	
						
					when e_set1	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(1) <= boutons; 
							etat <= e_set2;
						end if;	 
						
					when e_set2	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(2) <= boutons;
							etat <= e_set3;
						end if;
						
					when e_set3	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(3) <= boutons;	
							etat <= e_set4;
						end if;
						
					when e_set4	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(4) <= boutons;
							etat <= e_00;
						end if;	  
	                 when others =>
	                    
	            end case;
			else 
				case etat is -- mode de fonctionnement normal
	                when e_00 =>
	                    if boutons = combinaison(0) then --comparaison de boutons directement avec la bonne combinaison
	                        etat <= e_01; 
						else 
							etat <= e_00;
	                    end if;
	                when e_01 =>
	                    if boutons = combinaison(1) then
	                        etat <= e_02;	 
						else 
							etat <= e_00;
	                    end if;
	                when e_02 =>
	                    if boutons = combinaison(2) then
	                        etat <= e_03;
						else 
							etat <= e_00;
	                    end if;
	                when e_03 =>
	                    if boutons = combinaison(3) then
	                        etat <= e_04; 
						else 
							etat <= e_00;
	                    end if;
	                when e_04 =>
	                    if boutons = combinaison(4) then
	                        etat <= e_05; 
						else 
							etat <= e_00;
	                    end if;	
						
					--code pour la partie 2, entrée de la nouvelle combinaison
					when e_05 => 
						if boutons(1) = '1' and boutons(3) = '1' then --dans l'etat ouvert possibilité de mofification
							etat <= e_set0;	
						elsif boutons(0) = '1' and boutons(2) = '1' then
							etat <= e_00; 
						end if;	
						
					when e_set0	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(0) <= boutons;
							etat <= e_set1;
						end if;	
						
					when e_set1	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(1) <= boutons; 
							etat <= e_set2;
						end if;	 
						
					when e_set2	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(2) <= boutons;
							etat <= e_set3;
						end if;
						
					when e_set3	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(3) <= boutons;	
							etat <= e_set4;
						end if;
						
					when e_set4	=>	
						if ( reset = '1' ) then
							combinaison <= combinaison_base;
						else
							combinaison(4) <= boutons;
							etat <= e_00;
						end if;	  
	                 when others =>
                    
           	 end case;
		  end if;
        end if;
    end process;
    
    -- processus pour les sorties
    process(all)
    begin
		if mode = "01" then	  -- fonctionnement mode offusqué
	        case etat is
	            when e_00 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "br_1";
	            when e_01 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "br_2";
	            when e_02 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "br_3";
	            when e_03 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "br_4";
	            when e_04 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "br_5";
				when e_05 =>
					ouvrir <= '0';
					alarme <= '0';
					message <= "e_05"; 
				--bonus
				when e_bon =>
					ouvrir <= '1';
				 	alarme <= '0';
					message <= "ourr";
				when e_echec =>
					ouvrir <= '0';
					alarme <= '0';
					message <= "barr";
				when e_alrm =>
					ouvrir <= '0';
					alarme <= '1';
					message <= "alrm";
				--sortie pour la partie 2
				when e_set0 =>
					message <= "cmod";	 
				when e_set1 =>
					message <= "cmod";
				when e_set2 =>
					message <= "cmod";
				when e_set3 =>
					message <= "cmod";
				when e_set4 =>
					message <= "cmod";
	            when others =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "eror";
	        end case;
		else
			case etat is   -- fonctionnement classique
	            when e_00 =>
	                ouvrir <= '0';
	                alarme <= '1';
	                message <= "e_00";
	            when e_01 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "e_01";
	            when e_02 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "e_02";
	            when e_03 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "e_03";
	            when e_04 =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "e_04";
				when e_05 =>
					ouvrir <= '1';
					alarme <= '0';
					message <= "ourr"; 
				--sortie pour la partie 2
				when e_set0 =>
					message <= "cmod";	 
				when e_set1 =>
					message <= "cmod";
				when e_set2 =>
					message <= "cmod";
				when e_set3 =>
					message <= "cmod";
				when e_set4 =>
					message <= "cmod";
	            when others =>
	                ouvrir <= '0';
	                alarme <= '0';
	                message <= "eror";
	        end case;
		end if; 
    end process; 
					
    
end arch;
