---------------------------------------------------------------------------------------------------
-- 
-- racine_carree_tb.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-25 laboratoire #4 INF3500, fichier de démarrage
--
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity racine_carree_tb is
    generic (
    N : positive := 16;
    M : positive := 8
    );
end racine_carree_tb;

architecture arch of racine_carree_tb is

    signal reset : STD_LOGIC;
    signal clk : STD_LOGIC := '0';
    constant periode : time := 10 ns;
    
    signal A : unsigned(N - 1 downto 0);        -- le nombre dont on cherche la racine carrée
    signal go : std_logic;                      -- commande pour débuter les calculs
    signal X : unsigned(M - 1 downto 0);        -- la racine carrée de A, telle que X * X = A
    signal fini : std_logic;                    -- '1' quand les calculs sont terminés ==> la valeur de X est stable et correcte
    
    -- votre code ici  
	signal error_max : unsigned(M-1 downto 0) := "00000000"; 
	signal error_mid : unsigned(M - 1 downto 0) := "00000000"; --signaux pour le calcul des erreurs
	signal diff : unsigned(M - 1 downto 0);
    
begin

    UUT : entity racine_carree(newton)
        generic map (16, 8, 10)
        port map (reset, clk, A, go, X, fini);

    clk <= not clk after periode / 2;
    reset <= '1' after 0 ns, '0' after 5 * periode / 4;

    --A <= to_unsigned(30000, A'length);                          -- une stimulation de base
    --go <= '0' after 0 ns, '1' after 27 ns, '0' after 37 ns;     -- une stimulation de base
    
    -- votre code ici 
	stim_process : process
	begin
		wait for 1 ns;	 --attente du début
			for i in 1 to 255 loop --On vérifie tout les cas ou A est un carré parfait
            	A <= to_unsigned(i * i, N);  --assigne i^2 à A donc on connait la racine de A	 
            	go <= '1';    --début de racine_carree.vhd
            	wait until fini = '1';  
            	go <= '0';	 --arret
           
            	if X = to_unsigned(i, M) then
                	report "Test " & integer'image(i) & " passed" severity note;
            	else
					diff <= X-i;   --si i et X différent on regarde l'erreur
					if diff < 0 then
						diff <= i-X;   --assure que erreur est positive
					end if;					
					if diff > error_max then 
						error_max <= diff;
					end if;
                	error_mid <= error_mid + diff; 
					report "Test " & integer'image(i) & " failed" severity error;
            	end if;
            
               
				wait for 10 ns;
        	end loop;
			error_mid <= error_mid / 255;	--moyenne
			report "Max Error: " & to_string(error_max);
            report "Average Error: " & to_string(error_mid);

    end process;

end arch;

