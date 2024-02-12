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
    
    type etat_type is (attente, calculs);
    signal etat : etat_type := attente;
	
    
--- votre code ici
	signal num : unsigned(N - 1 downto 0);	   --signaux utilisés pour la division    
	signal A_div_xk : unsigned(M-1 downto 0);
	signal quotient : unsigned(N+W_frac-1 downto 0);
	signal err : std_logic;

begin
    
--    diviseur : entity division_par_reciproque(arch)
--        generic map (N, M, W_frac)
--        port map (un-signal-ici, un-signal-ici, un-signal-ici, un-signal-ici); 

division : entity work.division_par_reciproque
generic map (W_num => N, W_denom => M, W_frac => W_frac)
port map (num => num, denom => A_div_xk, quotient => quotient, erreur_div_par_0 => err);

process (all)
variable k : integer;
variable Xk : unsigned(M-1 downto 0);
variable res : unsigned(N + W_frac - 1 downto 0);

begin
	if rising_edge(clk) then 
		if reset = '1' then
			etat <= attente;
		elsif etat = attente then
			if go = '1' then
				fini <= '0';
				k := 0;
				-- Choix de X0 en fonction de A avec des inégalités
                if A > 16384 then
                    Xk := "11111111";
                elsif A > 4096 then
                    Xk := "10000000";
                elsif A > 1024 then
                    Xk := "01000000";
                elsif A > 256 then
                    Xk := "00100000";
                elsif A > 64 then
                    Xk := "00010000";
                else
                    Xk := "00001000";
                end if;
				etat <= calculs;
			end if;
		elsif etat = calculs then
			fini <= '0';
			k := k+1;
			--xk = (xk + A / xk) / 2;
			num	<= Xk + A;
			A_div_xk <= Xk;
           
            if err = '1' then  --vérification qu'on ne divise pas par 0
	        	fini <= '1'; 
		    else
		        res := quotient(quotient'high - 1 downto 0) & '0';
				Xk := res(21 downto 14);   -- partie entière
				X <= xk;
			end if;
			
			if k = kmax then
				etat <= attente;
			end if;
		end if;	 
		if etat = attente then	
			fini <= '1'; 
		else 
			fini <= '0';
		end if;
	end if;
	end process;	 
    
end newton;
