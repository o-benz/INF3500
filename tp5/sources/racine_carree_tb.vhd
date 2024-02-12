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
use ieee.math_real.all;
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
	
	function calcul_erreur(nombre: natural; sqrt_resultat: natural) return real is
		variable sqrt_attendu : real range 0.0 to 256.0;
		variable erreur : real range -10.0 to 10.0;
	begin
		sqrt_attendu := SQRT(real(nombre));
		erreur := sqrt_attendu - real(sqrt_resultat);
		return abs(erreur);
		
	end function;
	
	
begin

    UUT : entity racine_carree(newton)
        generic map (16, 8, 10)
        port map (reset, clk, A, go, X, fini);

    clk <= not clk after periode / 2;
    reset <= '1' after 0 ns, '0' after 5 * periode / 4;
	process
	
		variable erreur_tb : real range -10.0 to 10.0;
		variable erreur_max : real range -10.0 to 10.0 := 0.0;
		variable A_max : natural range 0 to 2**N -1 := 0;
		variable erreur_somme : real range 0.0 to real(2**N);
		begin
		-- simulation exhaustsive	
		for k in 0 to 2**N - 1 loop
			A <= to_unsigned(k, A'length);                          
			wait for periode;
	    	go <= '0' after 0 ns, '1' after 27 ns, '0' after 37 ns;     -- une stimulation de base
			wait for 20 * periode;
			
			-- calcul de l'erreur maximale et moyenne
			erreur_tb := calcul_erreur(to_integer(A), to_integer(X));
			erreur_somme := erreur_somme + erreur_tb;
			if erreur_tb > erreur_max then
				erreur_max := erreur_tb;
				A_max := k;
			end if;
			
			assert (erreur_tb < 1.0) report "Nombre " & to_string(to_integer(A)) & " racine calculée: " & to_string(to_integer(X)) & " erreur: " & to_string(erreur_tb) severity error;
			
		end loop;
			report "Erreur maximale: Nombre = " & to_string(A_max) & " avec Erreur = " & to_string(erreur_max) severity note;
			report "Erreur moyenne: " & to_string((erreur_somme / real(2**N - 1))) severity note;
			report "simulation terminée" severity failure;
	end process;


end arch;

