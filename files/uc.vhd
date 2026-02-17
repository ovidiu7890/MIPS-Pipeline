library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.All;

entity uc is
    Port (instr: in std_logic_vector(5 downto 0);
        reg_dst, ext_op, ALU_src, branch, br_gtz, jump, jmpr, mem_write, memto_reg, reg_write: out std_logic;
        alu_op: out std_logic_vector(2 downto 0));
end uc;

architecture Behavioral of uc is

begin
    process(instr)
    begin
        reg_dst<='0';ext_op<='0';ALU_src<='0'; branch<='0'; br_gtz<='0'; jump<='0'; jmpr<='0';memto_reg<='0'; reg_write<='0';alu_op<="000";mem_write<='0';
        case instr is
            when "000000"=>
                reg_dst<='1';
                memto_reg<='1';
                reg_write<='1';
            when "001000"=>
                ext_op<='1';
                ALU_src<='1';
                memto_reg<='1';
                reg_write<='1';
                alu_op<="001";
            when "100011"=>
                ext_op<='1';
                ALU_src<='1';
                alu_op<="001";
                reg_write<='1';
            when "101011"=>
                ext_op<='1';
                ALU_src<='1';
                mem_write<='1';
                alu_op<="001";
            when "000100"=>
                ext_op<='1';
                branch<='1';
                alu_op<="010";
            when "001010"=>
                ext_op<='1';
                ALU_src<='1';
                memto_reg<='1';
                reg_write<='1';
                alu_op<="011";
            when "001101"=>
                ALU_src<='1';
                memto_reg<='1';
                reg_write<='1';
                alu_op<="100";
            when "000010"=>
                ALU_src<='1';
                jump<='1';
                memto_reg<='1';
            when "000111"=>
                ext_op<='1';
                br_gtz<='1';
                memto_reg<='1';
                alu_op<="010";
            when "000001"=>
                jmpr<='1';
            when others=>
                ext_op<='0';
        end case;
    end process;

end Behavioral;
