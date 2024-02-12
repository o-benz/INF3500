---------------------------------------------------------------------------------------------------
-- 
-- racine_carree.vhd
--
-- v. 1.0 Pierre Langlois 2022-02-25 laboratoire #4 INF3500 - code de base
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity racine_carree is
    generic (
        N : positive := 16;                     -- nombre de bits de A
        M : positive := 8;                      -- nombre de bits de X
        kmax : positive := 10                   -- nombre d'itérations à faire
    );
    port (
        reset, clk : in std_logic;
        A : in unsigned(N - 1 downto 0);        -- le nombre dont on cherche la racine carrée
        go : in std_logic;                      -- commande pour débuter les calculs
        X : out unsigned(M - 1 downto 0);       -- la racine carrée de A, telle que X * X = A
        fini : out std_logic                    -- '1' quand les calculs sont terminés ==> la valeur de X est stable et correcte
    );
end racine_carree;

architecture newton of racine_carree is
    
    constant W_frac : integer := 14;               -- pour le module de division, nombre de bits pour exprimer les réciproques
    
    type etat_type is (attente, calculs, erreur);
    signal etat : etat_type := attente;	 
	signal resultat: unsigned(N + W_frac - 1 downto 0);
	signal erreur_div_0: std_logic;  		  
	signal xk: unsigned(M - 1 downto 0) := (others => '1');	-- 255 par defaut
begin
	
    diviseur : entity division_par_reciproque(arch)
       generic map (N, M, W_frac)
       port map (A, xk, resultat, erreur_div_0);

--	diviseur : entity division_goldshmidt(arch) -- Attention! Division non optomisée. Chronophage! 
--		generic map (N, M, W_frac, 10)
--		port map (A, xk, resultat, erreur_div_0);
	
	process(all) 
	variable k: natural range 0 to kmax := 0; 
	variable A_int : natural range 0 to (2**N - 1);	 
	variable quotient: unsigned(M - 1 downto 0);
	variable somme: unsigned(M downto 0);
	variable error_div : std_logic := erreur_div_0;
	constant num_limite: natural range 0 to (2**N - 1) := 65280; -- nombre limite divisible par 255 sur 8 bits
	constant num_div_impr: natural range 0 to (2**N - 1) := 64528; -- nombre où la division par réciproque devient imprécise (au delà de M bits) 
	
	begin
		if reset = '1' then
			etat <= attente;
		elsif rising_edge(clk) then
			
			case etat is
				when attente =>
				if (go = '1') then
					k := 0;	
					A_int := to_integer(A);
					xk <= to_unsigned(255, xk'length);
					etat <= calculs;
					case A_int is  -- pour partie 4
						when 0 to 64 =>
							xk <= to_unsigned(8, xk'length);
						when 65 to 256 =>
							xk <= to_unsigned(16, xk'length);
						when 257 to 1024 =>
							xk <= to_unsigned(32, xk'length);
						when 1025 to 4096 =>
							xk <= to_unsigned(64, xk'length);
						when 4097 to 16384 =>
							xk <= to_unsigned(128, xk'length);
						-- cas où division imprécise (au delà de M bits)
						when num_div_impr to num_limite - 1 =>
							xk <= to_unsigned(254, xk'length);
							etat <= attente;
						when 65280 to 65535 =>
							xk <= to_unsigned(255, xk'length);
							etat <= attente;
						when others =>
							xk <= to_unsigned(255, xk'length); 
					end case;						
				end if;
				
				when calculs =>
				if error_div = '1' then
					etat <= erreur;
				end if;
				
				quotient := resultat((w_frac + 7) downto w_frac);
				somme := resize(xk, somme'length) + quotient;
				xk <= resize(somme / 2, xk'length);
				

				k := k + 1;
				if (k = kmax) then
					etat <= attente;
				end if;
				
				when others => -- si erreur, ne rien faire et attendre le reset
			end case;
		end if;	
	
	end process;
	
	process(all)
	begin
	X <= xk;
		case etat is
			when attente =>
				fini <= '1';
			when others =>
				fini <= '0';
		end case;
	end process;

    
end newton;
