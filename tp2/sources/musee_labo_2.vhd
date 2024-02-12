-------------------------------------------------------------------------------
--
-- musee_labo_2.vhd
--
-- v. 2.1 2022-01-08 Pierre Langlois, version à compléter pour le labo 2
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;

entity musee_labo_2 is
    generic (
        N : positive := 16 -- nombre de salles
    );
    port (
    detecteurs_mouvement : in std_logic_vector(N - 1 downto 0) ;
    alarme_intrus : out std_logic;
    alarme_jasette : out std_logic;
    alarme_greve : out std_logic;
    alarme_generale : out std_logic;
    alarme_reserve : out std_logic;
    zone_reserve : out unsigned(1 downto 0)
    );
end;

architecture arch of musee_labo_2 is
	signal nb_detecteurs_actifs : unsigned(N-1 downto 0) := (others => '0');

begin
    
    assert N mod 4 = 0 report "Cette architecture ne fonctionne que pour N muliple de 4." severity error;

    -- code à modifier pour la partie 1	
	process(detecteurs_mouvement)
	begin	   
		nb_detecteurs_actifs <= (others => '0');
		for i in detecteurs_mouvement'range loop
			if detecteurs_mouvement(i) = '1' then
			nb_detecteurs_actifs <= nb_detecteurs_actifs + 1;
			end if;
		end loop;
	end process;
		
	
    alarme_intrus <= '1' when ( nb_detecteurs_actifs >= 4 and nb_detecteurs_actifs <= 15) else '0';
    alarme_jasette <= '1'when (nb_detecteurs_actifs = 1 or nb_detecteurs_actifs = 2) else '0';
    alarme_greve <= '1' when (nb_detecteurs_actifs = 0) else '0';
    alarme_generale <= '1' when (nb_detecteurs_actifs = 16) else '0';
    
    -- code à modifier pour le bonus de la partie 4a.
    alarme_reserve <= '1';
    zone_reserve <= to_unsigned(3, zone_reserve'length);

end;