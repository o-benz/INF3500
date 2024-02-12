---------------------------------------------------------------------------------------------------
--
-- PolyRISC_le_programme_pkg.vhd
--
-- contenu de la mémoire des instructions
--
---------------------------------------------------------------------------------------------------
use work.PolyRISC_utilitaires_pkg.all;

package PolyRISC_le_programme_pkg is

    -----------------------------------------------------------------------------------------------
    -- partie 0 : programme de démonstration, suite de Fibonacci
    --constant memoireinstructions : memoireinstructions_type := (
--    (memoire, liregpio_in, 0, 0, 0),               -- 0 : r0 := lire gpio_in
--    (reg_valeur, passeb, 1, 0, 2),                 -- 1 : r1 := #2
--    (reg_valeur, passeb, 3, 0, 0),                 -- 2 : r3 := #0
--    (memoire, ecriregpio_out, 3, 0, 0),            -- 3 : gpio_out := r3
--    (reg_valeur, passeb, 4, 0, 1),                 -- 4 : r4 := #1
--    (memoire, ecriregpio_out, 4, 0, 0),            -- 5 : gpio_out := r4
--    (reg, aplusb, 5, 3, 4),                        -- 6 : r5 := r3 + r4
--    (reg, passea, 3, 4, 0),                        -- 7 : r3 := r4
--    (reg, passea, 4, 5, 0),                        -- 8 : r4 := r5
--    (memoire, ecriregpio_out, 4, 0, 0),            -- 9 : gpio_out := r4
--    (reg_valeur, aplusb, 1, 1, 1),                 -- 10 : r1 := r1 + #1
--    (branchement, ppe, 0, 1, -5),                  -- 11 : si r1 <= r0 goto cp + -5
--    stop,
--    nop);

    -----------------------------------------------------------------------------------------------
    -- parties 1 et 2 : votre code à développer
    -- placez le code de la partie 0 en commentaires
    -- utilisez le code de la partie 0 pour vous inspirer

--    constant memoireInstructions : memoireInstructions_type := (
--    (memoire, lireGPIO_in, 0, 0, 0),               -- 0 : R0 := lire GPIO_in
--
--    -- votre code ici
	constant memoireInstructions : memoireInstructions_type := (
    (memoire, lireGPIO_in, 0, 0, 0),               -- 0 : R0 := lire GPIO_in	   
	(reg_valeur, passeB, 1, 0, 32767), 			   -- 1 : R1 := #32767
	(reg_valeur, passeB, 2, 0, 0),   			   -- 2 : R2 := #0
	(reg_valeur, passeB, 3, 0, 16),	               -- 3 : R3 := #16	
	(reg_valeur, passeB, 6, 0, 0),				   -- 4 : R6 := #0
	(reg, AplusB, 4, 1, 2),						   -- 5 : R4 := R1 + R2
	(reg_valeur, Adiv2, 4, 4, 0),				   -- 6 : R4 := R4/2
	(reg, AmulB, 5, 4, 4),						   -- 7 : R5 := R4 x R4
	(branchement, pgq, 0, 5, 2),				   -- 8 : si R5 > R0 goto CP + 2
	(branchement, ppe, 0, 5, 3),				   -- 9 : si R5 =< R0 goto CP + 3
	(reg, passeA, 1, 4, 0), 					   -- 10 : R1 := R4
	(branchement, toujours, 0, 0, 2),			   -- 11 : goto CP + 2
	(reg, passeA, 2, 4, 0),						   -- 12 : R2 := R4
	(reg_valeur, AmoinsB, 3, 3, 1),				   -- 13 : R3 := R3 -1
	(branchement, pgq, 6, 3, -9),				   -- 14 : si R3 > R6 goto CP + -9		  
	(memoire, ecrireGPIO_out, 4, 0, 0),			   -- 15 : GPIO_out := R4
    STOP,
    NOP);

end package;
