library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity division_vhdl is
    generic (
        N : integer := 16;  -- Nombre de bits du numérateur
        M : integer := 8   -- Nombre de bits du dénominateur
    );
    port (
        clk, reset : in std_logic;	 
        numerator : in unsigned(N - 1 downto 0);  -- Numérateur
        denominator : in unsigned(M - 1 downto 0);  -- Dénominateur
        result : out unsigned(M - 1 downto 0);  -- Résultat de la division 
		erreur_div_0 : out std_logic;
    );
end entity division_vhdl;

architecture behavioral of division_vhdl is	 
    signal remainder : unsigned(N - 1 downto 0) := numerator;
    signal count : unsigned(M - 1 downto 0); 

begin
    process (clk, reset)
    begin
        if reset = '1' then		
            remainder <= (others => '0');
            count <= "00000000";	   
        elsif rising_edge(clk) then
            if start = '1' then
				erreur_div_par_0 <= '1' when denominator = 0 else '0';
                if remainder > numerator then
					remainder <= remainder - denominator;
					count <= count + 1;
				end if;
            end if;
        end if;
    end process;

    result <= count;  

end architecture behavioral;