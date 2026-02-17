library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity id is
    Port (instr: in std_logic_vector(25 downto 0);
           reg_write, ext_op, en, clk: in std_logic;
           wd:in std_logic_vector(31 downto 0);
           wa:in std_logic_vector(4 downto 0);
           ext_imm, rd1, rd2:out std_logic_vector(31 downto 0);
           funct:out std_logic_vector(5 downto 0);
           rt, rd:out std_logic_vector(4 downto 0);
           sa:out std_logic_vector(4 downto 0));      
    
end id;

architecture Behavioral of id is
    component reg_file
        port ( clk : in std_logic;
        ra1 : in std_logic_vector(4 downto 0);
        ra2 : in std_logic_vector(4 downto 0);
        wa : in std_logic_vector(4 downto 0);
        wd : in std_logic_vector(31 downto 0);
        regwr : in std_logic;
        en: in std_logic;
        rd1 : out std_logic_vector(31 downto 0);
        rd2 : out std_logic_vector(31 downto 0));
    end component;
begin
    regFile: reg_file port map(clk, instr(25 downto 21), instr(20 downto 16), wa, wd, reg_write, en, rd1, rd2);
    process(ext_op, instr(15 downto 0))--ext_unit
    begin
        if(ext_op='0')then
            ext_imm<=X"0000"&instr(15 downto 0);
        else
            ext_imm<=instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15) & instr(15 downto 0);
        end if;
    end process;
    funct<=instr(5 downto 0);
    sa<=instr(10 downto 6); 
    rt<=instr(20 downto 16);
    rd<=instr(15 downto 11);
end Behavioral;
