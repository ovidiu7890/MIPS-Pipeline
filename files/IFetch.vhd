library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity IFetch is
    Port (jump, jmpr, PCSrc, en, RST, CLK: in std_logic;
           pc, instr: out std_logic_vector(31 downto 0);
           jumpAddress, BranchAddress, JRAddress: in std_logic_vector(31 downto 0)
          );
end IFetch;


architecture Behavioral of IFetch is
    type rom_type is array(63 downto 0) of std_logic_vector(31 downto 0);
    signal rom:rom_type:=(
         0 => B"100011_00000_00001_0000000000000000",--X"8C010000", lw $1, 0($0); load number from the memory at addr 0 in R1
         1 => B"100011_00000_00011_0000000000000100",--X"8C030004", lw $3, 4($0); load the address were the result should pe saved in R3
         2 => B"001000_00000_00010_0000000000000000",--X"20020000", addi $2, $0, 0; sets R2 to 0
         3 => B"001000_00001_00100_0000000000000000",--X"20240000", addi $4, $1, 0; R4 contains the number
         4 => B"001000_00000_00000_0000000000000000",--noop
         5 => B"001000_00000_00000_0000000000000000",--noop
         6 => B"001000_00010_00010_0000000000000001",--X"20420001", addi $2, $2, 1; adds 1 to R2
         7 => B"000000_00000_00001_00001_00001_000010",--X"00010842", srl $1, $1, 1; shift right the number
         8 => B"001000_00000_00000_0000000000000000",--noop
         9 => B"001000_00000_00000_0000000000000000",--noop
        10 => B"000100_00001_00000_0000000000000101",--X"10200001", beq $1, $0, 5; checks if the r1 is 0
        11 => B"001000_00000_00000_0000000000000000",--noop
        12 => B"001000_00000_00000_0000000000000000",--noop
        13 => B"001000_00000_00000_0000000000000000",--noop
        14 => B"000010_00000000000000000000000110",--X"08000004",j 6; jump if the condition above is not matched to 4
        15 => B"001000_00000_00000_0000000000000000",--noop
        16 => B"001000_00010_00101_1111111111111111",--X"2045FFFF", addi $5, $2, -1; R5 (has the number of the maximum bit that has 1)-1
        17 => B"001000_00000_00110_0000000000000001",--X"20060001", addi $6, $0, 1; R6=1
        18 => B"001000_00000_00000_0000000000000000",--noop
        19 => B"001000_00000_00000_0000000000000000",--noop
        20 => B"000000_00000_00110_00110_00001_000000",--X"00063040", sll $6, $6, 1; R6<<1
        21 => B"001000_00101_00101_1111111111111111",--X"20A5FFFF", addi $5, $5, -1; R5=R5-1
        22 => B"001000_00000_00000_0000000000000000",--noop
        23 => B"001000_00000_00000_0000000000000000",--noop
        24 => B"000100_00101_00000_0000000000000101",--X"10A00001", beq $5, $0, 5; jumps over the next instruction if R5=R0
        25 => B"001000_00000_00000_0000000000000000",--noop
        26 => B"001000_00000_00000_0000000000000000",--noop
        27 => B"001000_00000_00000_0000000000000000",--noop
        28 => B"000010_00000000000000000000010100",--X"0800000A", j 20; jumps back to 10 if the condition is not met
        29 => B"001000_00000_00000_0000000000000000",--noop
        30 => B"000000_00100_00110_00101_00000_100010",--X"00862822", sub $5, $4, $6; R5=number-(the biggest bit equal to 1)
        31 => B"000000_00000_00110_00110_00001_000000",--X"00063040", sll $6, $6, 1; R6=(the biggest bit equal to 1)<<1
        32 => B"001000_00000_00000_0000000000000000",--noop
        33 => B"001000_00000_00000_0000000000000000",--noop
        34 => B"000000_00110_00100_00110_00000_100010",--X"00C23022", sub $6, $6, $4; R6=R6-number
        35 => B"001000_00000_00000_0000000000000000",--noop
        36 => B"001000_00000_00000_0000000000000000",--noop
        37 => B"000000_00110_00101_00111_00000_101010",--X"00C5382A", slt $7, $6, $5; if R6<R5 {R7=1} else {R7=0}
        38 => B"001000_00000_00000_0000000000000000",--noop
        39 => B"001000_00000_00000_0000000000000000",--noop
        40 => B"000100_00111_00000_0000000000000110",--X"10E60001", beq $7, $0, 6; r7=1 => R6 lowest, r7=0 => r5 lowest
        41 => B"001000_00000_00000_0000000000000000",--noop
        42 => B"001000_00000_00000_0000000000000000",--noop
        43 => B"001000_00000_00000_0000000000000000",--noop
        44 => B"001000_00010_00010_0000000000000001",--X"20420001", addi $2, $2, 1; if r6 lowest => r2+1
        45 => B"001000_00000_00000_0000000000000000",--noop
        46 => B"001000_00000_00000_0000000000000000",--noop
        47 => B"001000_00010_00010_1111111111111111",--X"2042FFFF", addi $2, $2, -1;
        48 => B"001000_00000_00000_0000000000000000",--noop
        49 => B"001000_00000_00000_0000000000000000",--noop
        50 => B"101011_00011_00010_0000000000000000",--X"AC620000", sw $2, 0($3);save the result in the address from the memory
    others=>X"00000000"
    );
    signal q1, sum1, mux1, mux2, mux3:std_logic_vector(31 downto 0);
    
begin
    process(clk, rst)--pc
    begin
        if rst='1' then
            q1<=(others=>'0');
        elsif rising_edge(clk) then
            if en='1' then
                q1<=mux3;   
            end if;
        end if;
    end process;
    
    sum1<=q1+4;
    PC<=sum1;
    process(sum1, BranchAddress, PCSrc)
    begin
        if(PCSrc='1')then
            mux1<=BranchAddress;
        else
            mux1<=sum1;
        end if;
    end process;
    
    process(mux1, JumpAddress, Jump)
    begin   
        if(jump='1')then
            mux2<=JumpAddress;
        else
            mux2<=mux1;
        end if;
    end process;
    
    process(jmpR, JRAddress, mux2)
    begin
        if(jmpR='1')then
            mux3<=JRAddress;
        else
            mux3<=mux2;
        end if;
    end process;
    instr<=rom(conv_integer(q1(7 downto 2)));
    
end Behavioral;
