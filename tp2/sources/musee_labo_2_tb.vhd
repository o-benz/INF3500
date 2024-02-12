-------------------------------------------------------------------------------
--
-- musee_labo_2_tb
--
-- v. 2.1 2022-01-08 Pierre Langlois version à compléter pour le labo 2
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.all;

entity musee_labo_2_tb is
    generic (
        N_tb : positive := 8
    );
end entity;

architecture arch of musee_labo_2_tb is
    
signal detecteurs_mouvement_tb : std_logic_vector(N_tb - 1 downto 0) ;
signal alarme_intrus_tb : std_logic;
signal alarme_jasette_tb : std_logic;
signal alarme_greve_tb : std_logic;
signal alarme_generale_tb : std_logic;
signal alarme_reserve_tb : std_logic;
signal zone_reserve_tb : unsigned(1 downto 0);
signal temp : unsigned(N-1 downto 0) := (others => '0');

function verifAlarmes(n : std_logic_vector(15 downto 0)) 
return std_logic_vector is variable alarmes: std_logic_vector(3 downto 0);
begin
	temp <= (others => '0');
        for i in n'range loop
            if n(i) = '1' then
                temp <= temp + 1;
            end if;
        end loop;
	alarmes(0) <= '1' when (temp >= 4 and temp <= 15) else '0';
	alarmes(1) <= '1' when (temp = 1 or temp = 2) else '0';
	alarmes(2) <= '1' when (n = "0000000000000000") else '0';
	alarmes(3) <= '1' when (n = "1111111111111111") else '0';
	return alarmes;
end verifAlarmes;
		
begin

    -- instanciation du module à vérifier UUT (Unit Under Test)
    UUT : entity musee_labo_2(arch)
        generic map (N => N_tb)
        port map (
            detecteurs_mouvement => detecteurs_mouvement_tb,
            alarme_intrus => alarme_intrus_tb,
            alarme_jasette => alarme_jasette_tb,
            alarme_greve => alarme_greve_tb,
            alarme_generale => alarme_generale_tb,
            alarme_reserve => alarme_reserve_tb,
            zone_reserve => zone_reserve_tb
            );
    
    -- application exhaustive des vecteurs de test, affichage et vérification
    process
    
    begin

        for k in 0 to 2 ** N_tb - 1 loop

            detecteurs_mouvement_tb <= std_logic_vector(to_unsigned(k, N_tb));

            wait for 10 ns; -- nécessaire pour que les signaux se propagent dans l'UUT
			
			assert alarme_intrus_tb = verifAlarmes(detecteurs_mouvement_tb) (0) and
       		alarme_jasette_tb = verifAlarmes(detecteurs_mouvement_tb) (1) and
       		alarme_greve_tb = verifAlarmes(detecteurs_mouvement_tb) (2) and
       		alarme_generale_tb = verifAlarmes(detecteurs_mouvement_tb) (3)
			report "Erreur pour l'entrée " & integer'image(k) severity warning;
            
        end loop;
            
        report "simulation terminée" severity failure;
        
    end process;
    
end arch;