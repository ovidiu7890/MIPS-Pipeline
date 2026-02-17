library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity test_env is
    Port (sw: in std_logic_vector(15 downto 0);
        btn: in std_logic_vector(4 downto 0);
        led: out std_logic_vector(15 downto 0);
        clk: in std_logic;
        an: out std_logic_vector(7 downto 0);
        cat: out std_logic_vector(6 downto 0));
end test_env;

        architecture Behavioral of test_env is
component IFetch
    Port (jump, jmpr, PCSrc, en, RST, CLK: in std_logic;
           pc, instr: out std_logic_vector(31 downto 0);
           jumpAddress, BranchAddress, JRAddress: in std_logic_vector(31 downto 0)
          );
end component;
component MPG
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;
component SSD
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;
component id
    Port (instr: in std_logic_vector(25 downto 0);
           reg_write, ext_op, en, clk: in std_logic;
           wd:in std_logic_vector(31 downto 0);
           wa:in std_logic_vector(4 downto 0);
           ext_imm, rd1, rd2:out std_logic_vector(31 downto 0);
           funct:out std_logic_vector(5 downto 0);
           rt, rd:out std_logic_vector(4 downto 0);
           sa:out std_logic_vector(4 downto 0));  
end component;
component uc
    Port (instr: in std_logic_vector(5 downto 0);
        reg_dst, ext_op, ALU_src, branch, br_gtz, jump, jmpr, mem_write, memto_reg, reg_write: out std_logic;
        alu_op: out std_logic_vector(2 downto 0));
end component;
component EX
    Port (ext_imm, rd1, rd2 , pc4:in std_logic_vector(31 downto 0);
          alu_op: in std_logic_vector(2 downto 0);
          func: in std_logic_vector(5 downto 0);
          sa, rt, rd: in std_logic_vector(4 downto 0);
          alu_src, reg_dst: in std_logic;
          gtz, zero: out std_logic;
          alu_res, br_adr: out std_logic_vector(31 downto 0);
          rwa: out std_logic_vector(4 downto 0)
    );
end component;
component mem
    port ( clk : in std_logic;
        we : in std_logic;
        en : in std_logic;
        alu_res_in: in std_logic_vector(31 downto 0);
        alu_res_out: out std_logic_vector(31 downto 0);
        di : in std_logic_vector(31 downto 0);
        do : out std_logic_vector(31 downto 0));
end component;
signal RegDst_ID_EX , ExtOp_ID_EX, AluSrc_ID_EX, Branch_ID_EX, Br_gtz_ID_EX, MemWrite_ID_EX, MemtoReg_ID_EX, RegWrite_ID_EX, Branch_EX_MEM, MemWrite_EX_MEM, MemtoReg_EX_MEM, RegWrite_EX_MEM, Zero_EX_MEM, Gtz_EX_MEM, RegWrite_MEM_WB, MemtoReg_MEM_WB, enable, reg_dst, reg_write, ext_op, jump, jmpr, alu_src, gtz, zero, branch, br_gtz, pc_src, memto_reg, mem_write:std_logic;
signal Instruction_IF_ID, PCp4_IF_ID, Rd1_ID_EX, Rd2_ID_EX, Ext_ID_EX, PCp4_ID_EX, Alu_res_EX_MEM, Br_addr_EX_MEM, Rd2_EX_MEM, Alu_res_out_MEM_WB, Do_MEM_WB, pc, instr, ext_imm, rd1, rd2, f_ext, s_ext, mux2, jmp_addr, alu_res, br_addr, alu_res_out, mem_data, write_back: std_logic_vector(31 downto 0);
signal funct, Func_ID_EX: std_logic_vector(5 downto 0);
signal ALUOp_ID_EX:std_logic_vector(2 downto 0);
signal sa, rt, rd, rwa, Sa_ID_EX, rd_ID_EX, rt_ID_EX, rWA_EX_MEM, rWA_MEM_WB: std_logic_vector(4 downto 0);
signal alu_op: std_logic_vector(2 downto 0);
begin
    monopulse:MPG port map(enable, btn(0), clk);
    sevenSegmentDisplay:SSD port map(clk, mux2, an, cat);
    fetch:IFetch port map(jump, jmpr, pc_src, enable, btn(1), clk, pc, instr, jmp_addr, Br_addr_EX_MEM, rd1);    
    instrDecode:id port map(Instruction_IF_ID(25 downto 0), RegWrite_MEM_WB, ext_op, enable, clk, write_back, rWA_MEM_WB,ext_imm, rd1, rd2, funct, rt, rd, sa);
    control:uc port map(Instruction_IF_ID(31 downto 26), reg_dst, ext_op, alu_src, branch, br_gtz, jump, jmpr, mem_write, memto_reg, reg_write, alu_op);
    execute:EX port map(Ext_ID_EX, Rd1_ID_EX, Rd2_ID_EX, PCp4_ID_EX, ALUOp_ID_EX, Func_ID_EX, Sa_ID_EX, rt_ID_EX, rd_ID_EX, AluSrc_ID_EX, RegDst_ID_EX, Br_gtz_ID_EX, zero, alu_res, br_addr, rwa);
    memory:mem port map(clk, MemWrite_EX_MEM, enable, Alu_res_EX_MEM, alu_res_out, Rd2_EX_MEM, mem_data);
    process(MemtoReg_MEM_WB, Alu_res_out_MEM_WB, Do_MEM_WB)
    begin
        if(MemtoReg_MEM_WB='0')then
            write_back<=Do_MEM_WB;
        else
            write_back<=Alu_res_out_MEM_WB;
        end if;
    end process;
    process(clk, enable)
    begin
        if rising_edge(clk) then
            if enable='1' then
                --IF/ID
                Instruction_IF_ID<=instr;
                PCp4_IF_ID<=pc;
                --ID/EX
                Rd1_ID_EX<=rd1;
                Rd2_ID_EX<=rd2;
                Ext_ID_EX<=ext_imm;
                Func_ID_EX<=funct;
                Sa_ID_EX<=sa;
                PCp4_ID_EX<=PCp4_IF_ID;
                rd_ID_EX<=rd;
                rt_ID_EX<=rt;
                RegDst_ID_EX<=reg_dst;
                --ExtOp_ID_EX<=ext_op;
                AluSrc_ID_EX<=alu_src;
                Branch_ID_EX<=branch;
                Br_gtz_ID_EX<=br_gtz;
                MemWrite_ID_EX<=mem_write;
                MemtoReg_ID_EX<=memto_reg;
                ALUOp_ID_EX<=alu_op;
                RegWrite_ID_EX<=reg_write;
                --EX/MEM
                Branch_EX_MEM<=Branch_ID_EX;
                MemWrite_EX_MEM<=MemWrite_ID_EX;
                MemtoReg_EX_MEM<=MemtoReg_ID_EX;
                RegWrite_EX_MEM<=RegWrite_ID_EX;
                Zero_EX_MEM<=zero;
                Gtz_EX_MEM<=gtz;
                Alu_res_EX_MEM<=alu_res;
                Br_addr_EX_MEM<=br_addr;
                Rd2_EX_MEM<=Rd2_ID_EX;
                rWA_EX_MEM<=rwa;
                --MEM/WB
                RegWrite_MEM_WB<=RegWrite_EX_MEM;
                MemtoReg_MEM_WB<=MemtoReg_EX_MEM;
                Alu_res_out_MEM_WB<=alu_res_out;
                Do_MEM_WB<=mem_data;
                rWA_MEM_WB<=rWA_EX_MEM;
            end if;
        end if;
    end process;
    pc_src<=(Zero_EX_MEM and Branch_EX_MEM)or(br_gtz and Gtz_EX_MEM);
    f_ext<=X"000000"&"00"&funct;
    s_ext<=X"000000"&"000"&sa;
    led(1)<=memto_reg;
    led(2)<=mem_write;
    led(5)<=br_gtz;
    led(6)<=branch;
    led(7)<=alu_src;
    led(8)<=ext_op;
    led(9)<=reg_dst;
    led(3)<=jump;
    led(4)<=jmpr;
    led(0)<=reg_write;
    led(12 downto 10)<=alu_op;
    led(13)<=pc_src;
    jmp_addr<=PCp4_IF_ID(31 downto 28)&Instruction_IF_ID(25 downto 0)&"00";
    process(sw(7 downto 5))
    begin
        case sw(7 downto 5) is
            when "000"=>mux2<=instr;
            when "001"=>mux2<=pc;
            when "010"=>mux2<=Rd1_ID_EX;
            when "011"=>mux2<=Rd2_ID_EX;
            when "100"=>mux2<=Ext_ID_EX;
            when "101"=>mux2<=alu_res;
            when "110"=>mux2<=mem_data;
            when "111"=>mux2<=write_back;
            when others=>mux2<=X"00000000";
        end case;
    end process;
end Behavioral;
