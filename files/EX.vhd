library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.All;
use IEEE.numeric_std.All;

entity EX is
    Port (ext_imm, rd1, rd2 , pc4:in std_logic_vector(31 downto 0);
          alu_op: in std_logic_vector(2 downto 0);
          func: in std_logic_vector(5 downto 0);
          sa, rt, rd: in std_logic_vector(4 downto 0);
          alu_src, reg_dst: in std_logic;
          gtz, zero: out std_logic;
          alu_res, br_adr: out std_logic_vector(31 downto 0);
          rwa: out std_logic_vector(4 downto 0)
    );
end EX;

architecture Behavioral of EX is
    signal mux_ri, c, imm: std_logic_vector(31 downto 0);
    signal alu_ctrl: std_logic_vector(2 downto 0);
    signal gez, z: std_logic;
begin
    mux_regdst:process(rt, rd, reg_dst)
    begin
        if reg_dst='1' then
            rwa<=rd;
        else
            rwa<=rt;
        end if;
    end process;
    mux_alu_src:process(alu_src, rd2, ext_imm)
    begin
        if alu_src='0' then
            mux_ri<=rd2;
        else
            mux_ri<=ext_imm;
        end if;
    end process;
    ALUcontrol:process(alu_op, func)
    begin
        case alu_op is
            when "000"=>
                case func is
                    when "100000"=> alu_ctrl<="000";--+
                    when "100010"=> alu_ctrl<="100";---
                    when "000000"=> alu_ctrl<="101";--<<L
                    when "000010"=> alu_ctrl<="110";-->>l
                    when "100100"=> alu_ctrl<="001";--&
                    when "100101"=> alu_ctrl<="010";--|
                    when "101010"=> alu_ctrl<="011";--<
                    when "000100"=> alu_ctrl<="111";--lv
                    when others=>   alu_ctrl<="XXX";
                end case;
            when "001"=>
                alu_ctrl<="000";
            when "010"=>
                alu_ctrl<="010";
            when "011"=>
                alu_ctrl<="011";
            when "100"=>
                alu_ctrl<="010";
            when others=>
                alu_ctrl<="XXX";
        end case;
    end process;
    ALU: process(alu_ctrl, sa, rd1, mux_ri)
    begin
        case alu_ctrl is
            when "000"=> c <= std_logic_vector(signed(rd1) + signed(mux_ri));
            when "001"=> c<=rd1 and mux_ri;
            when "010"=> c<=rd1 or mux_ri;
            when "011"=>
                if signed(rd1)<signed(mux_ri)then
                    c<=X"00000001";
                else
                    c<=X"00000000";
                end if;
            when "100"=> c<=std_logic_vector(signed(rd1) - signed(mux_ri));
            when "101"=> c<=to_stdlogicvector(to_bitvector(mux_ri)sll conv_integer(sa));
            when "110"=> c<=to_stdlogicvector(to_bitvector(mux_ri)srl conv_integer(sa));
            when "111"=> c<=to_stdlogicvector(to_bitvector(mux_ri)sll conv_integer(rd1));
            when others=> c<=(others=>'X');
        end case;
    end process;

    process(c)
    begin
        if(c=X"00000000")then
            z<='1';
        else
            z<='0';
        end if;
        if(c(31)='1') then
            gez<='0';
        else
            gez<='1';
        end if;
        if(z='1' and gez='1')then
            gtz<='1';
        else
            gtz<='0';
        end if;
    end process;
    zero<=z;
    alu_res<=c;
    br_adr<=((ext_imm(29 downto 0) & "00")+pc4);
end Behavioral;
