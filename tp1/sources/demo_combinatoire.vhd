-------------------------------------------------------------------------------
--
-- demo_combinatoire.vhd
--
-- Processeur qui effectue des calculs sur un nombre donné en entrée.
-- Toutes les fonctions sont purement combinatoires.
--
-- v. 1.1 2022-01-04 Pierre Langlois
-- ** CETTE VERSION COMPORTE DES ERREURS DE SYNTAXE ET DES ERREURS FONCTIONNELLES **
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_combinatoire is
  generic (
    W : integer := 4 -- nombre de bits pour représenter le nombre
  );
  port (
    A      : in unsigned(W - 1 downto 0);
    pair   : out std_logic;        -- indique si le nombre est pair
    divpar4: out std_logic;        -- indique si le nombre est divisible par 4
    divpar5: out std_logic;        -- indique si le nombre est divisible par 5
    divpar8: out std_logic         -- indique si le nombre est divisible par 8
  );
end demo_combinatoire;

architecture arch1 of demo_combinatoire is
begin
  pair <= not A(0); -- Corrigé : 'not' avant A(0) et parenthèse fermante après.

  divpar4 <= (not A(3) and not A(2) and not A(1) and not A(0)) -- m0
    or (not A(3) and A(2) and not A(1) and not A(0))           -- m4   -- ajout et retrait de certains not avant 
    or (A(3) and not A(2) and not A(1) and not A(0))           -- m8   -- le bit voulu pour avoir les nombres pairs
    or (A(3) and A(2) and not A(1) and not A(0));             -- m12	 
    -- Corrigé : parenthèses fermantes.

  with to_integer(A) select
    divpar5 <=
      '1' when 0,
      '1' when 5,	--changement de '6' en '5'
      '1' when 10,
      '1' when 15, -- Corrigé : ajout d'une virgule.
      '0' when others;

  divpar8 <= '1' when A = "1000" or A = "0000" else '0';	--Changement du "0001" en "0000" car 1 n'est pas divisible par 8
    -- Corrigé : ajout de guillemets et on corrige la position de 'else'.

end arch1; -- Corrigé : nom de "arch" à "arch1".
