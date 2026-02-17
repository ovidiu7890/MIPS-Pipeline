library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity mem is
    port ( clk : in std_logic;
        we : in std_logic;
        en : in std_logic;
        alu_res_in: in std_logic_vector(31 downto 0);
        alu_res_out: out std_logic_vector(31 downto 0);
        di : in std_logic_vector(31 downto 0);
        do : out std_logic_vector(31 downto 0));
end mem ;

architecture Behavioral of mem is
    type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (
    0 => X"00000013",
    1 => X"00000008",
    others => X"00000000"
);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and en = '1' then
                ram(conv_integer(alu_res_in(7 downto 2))) <= di;
            end if;
        end if;
    end process;
    alu_res_out<=alu_res_in;
    do <= ram(conv_integer(alu_res_in(7 downto 2)));
end Behavioral;