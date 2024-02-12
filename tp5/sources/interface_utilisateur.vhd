---------------------------------------------------------------------------------------------------
--
-- interface_utilisateur.vhd
--
-- v. 1.0 Pierre Langlois 2022-03-16 pour le labo #5, INF3500
--
-- TODO : comme les états sont très semblables, on pourrait les paramétrer selon quelques catégories, et utiliser une machine
-- générale pour les parcourir. La machine lirait les paramètres et les appliquerait.
-- 		message ou non, le message ou un pointeur
-- 		entrée ou non
-- 		pause ou non
-- 		prochain état
-- 		etc.
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.utilitaires_inf3500_pkg.all;
use work.all;

entity interface_utilisateur is
    generic (
        f_clk      : positive := 100e6;     -- fréquence de l'horloge de référence, en Hz
        taux_tx    : positive := 9600       -- taux de transmission en baud (symboles par seconde), ici des bits par seconde
    );
    port (
        reset, clk : in  std_logic;
        RsRx       : in  std_logic;         -- interface USB-RS-232 réception
        RsTx       : out std_logic;         -- interface USB-RS-232 transmission
        A          : out unsigned(15 downto 0);-- 2 : On a plus besoin de A et B sur 8 bits mais eulement A sur 16 bits
        input_ok   : out std_logic          -- on a reçu toutes les entrées des utilisateurs
    );
end;

architecture arch of interface_utilisateur is

    -- ** Tous les messages doivent avoir la même taille **
    -- CR, "carriage return," est un retour de charriot au début de la ligne
    -- LF, "line feed,"       est un changement de ligne
    constant m0 : string := CR & LF & "Bonjour, bienvenue au programme du calcul du PGFC entre deux nombres.v1751" & CR & LF;
    constant m1 : string := CR & LF & "Entrez le nombre à quatre chiffres hexadécimaux {0 - 9, A - F}.           " & CR & LF;
    --constant m2 : string := CR & LF & "Entrez le deuxième nombre à deux chiffres hexadécimaux {0 - 9, A - F}.    " & CR & LF;
	-- on a plus besoin de m2 car on ne rentre qu'un chiffre mais on modifie le texte de m1 car sur 16 bits on peut avoir 4 chiffres hexadecimaux.
    constant m3 : string := CR & LF & "Calculs en cours. Résultats sur la carte.                                 " & CR & LF;
    constant m4 : string := CR & LF & "--------------------------------------------------------------------------" & CR & LF;
    constant m9 : string := CR & LF & "Erreur, nombre invalide, chiffres hexadécimaux seulement {0 - 9, A - F}.  " & CR & LF;

    signal message : string(1 to m0'length);
    signal caractere : character;

    type etat_type is (s_bienvenue, s_n1_m, s_n1_H, s_n1_L, s_n1_HL, s_n1_LL, s_calcul, s_resultat, s_erreur); --2 : on enlève les états qui servaient au second nombre car on en a plus qu'un et on met des etats pour séparer en deux segments de 8 bits
    signal etat : etat_type := s_bienvenue;

    signal go_tx   : std_logic;
    signal tx_pret : std_logic;
    signal car_recu : std_logic;

    signal clk_1_MHz : std_logic;

begin

    transmetteur : entity uart_tx_message(arch)
		generic map (f_clk, taux_tx, m0'length)
		port map (reset, clk, message, go_tx, tx_pret, RsTx);

    recepteur : entity uart_rx_char(arch)
		generic map (f_clk, taux_tx)
		port map (reset, clk, RsRx, caractere, car_recu);

    -- une horloge pour ralentir l'interface et laisser le temps aux communications de se faire
    gen_horloge_1_MHz  : entity generateur_horloge_precis(arch) generic map (f_clk, 1e6)  port map (clk, clk_1_MHz);

    process(all)
    variable c : character;
    constant delai : natural := 4; -- délai entre deux transmissions, en 1 / secondes (10 == 0.1 s, 5 == 0.2 s, etc.)
    variable compteur_delai : natural range 0 to f_clk / delai - 1; -- pour insérer une pause dans les transmissions
    begin
        if reset = '1' then
            etat <= s_bienvenue;
            go_tx <= '0';
            compteur_delai := f_clk / delai - 1;
        elsif rising_edge(clk) then
            case etat is
            when s_bienvenue =>
                -- message de bienvenue
                go_tx <= '0';
                -- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail
                if compteur_delai = 0 then
                    if tx_pret = '1' then
                        message <= m0;
                        go_tx <= '1';
                        etat <= s_n1_m;
                        compteur_delai := f_clk / delai - 1;
                    end if;
                else
                    compteur_delai := compteur_delai - 1;
                end if;
            when s_n1_m =>
                -- message pour le premier nombre
                go_tx <= '0';
                -- prendre une pause entre deux messages, pour laisser au transmetteur le temps de faire son travail
                if compteur_delai = 0 then
                    if tx_pret = '1' then
                        message <= m1;
                        go_tx <= '1';
                        etat <= s_n1_H;
                    end if;
                else
                    compteur_delai := compteur_delai - 1;
                end if;
            when s_n1_H =>
                -- recevoir le chiffre le plus significatif du premier nombre
                go_tx <= '0';
                if car_recu = '1' then
                    A(15 downto 12) <= character_to_hex(caractere);	--2 : on prend les bits les plus significatif de A 
                    etat <= s_n1_L;
                end if;
            when s_n1_L =>
                -- recevoir le chiffre le moins significatif du premier nombre
                go_tx <= '0';
                if car_recu = '1' then
                    A(11 downto 8) <= character_to_hex(caractere); --2 : on prend les bits dans A car on a plus que A comme chiffre
                    etat <= s_n1_HL;
                end if;
            --when s_n2_m =>
--                -- message pour le 2e nombre
--                go_tx <= '0';
--                if tx_pret = '1' then
--                    message <= m2;
--                    go_tx <= '1';
--                    etat <= s_n2_H;
--                end if;
--On a plus besoin de message pour le deuxieme nombre car on en a qu'un
            when s_n1_HL =>
                -- recevoir le chiffre le plus significatif du 2e nombre
                go_tx <= '0';
                if car_recu = '1' then
                    A(7 downto 4) <= character_to_hex(caractere); --2 : On continue a prendre les bits de A car on a pas de B
                    etat <= s_n1_LL;
                end if;
            when s_n1_LL =>
                -- recevoir le chiffre moins significatif du 2e nombre
                go_tx <= '0';
                if car_recu = '1' then
                    A(3 downto 0) <= character_to_hex(caractere); --2 : On prend les bits les moins signifiactifs de A et on aura parcouru les 16 bits de A et ainsi on aura eu le nombre au complet
                    etat <= s_resultat;
                end if;
            when s_resultat =>
                -- message pour les résultats
                go_tx <= '0';
                if tx_pret = '1' then
                    message <= m3;
                    go_tx <= '1';
                    etat <= s_bienvenue;
                    compteur_delai := f_clk / delai - 1;
                end if;
            when others =>
                go_tx <= '0';
                etat <= s_bienvenue;
                compteur_delai := f_clk / delai - 1;
            end case;
        end if;
    end process;

    input_ok <= '1' when etat = s_resultat else '0';

end;
