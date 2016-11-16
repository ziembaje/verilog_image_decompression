library verilog;
use verilog.vl_types.all;
library work;
entity Milestone_1 is
    port(
        Clock_50        : in     vl_logic;
        Resetn          : in     vl_logic;
        Initialize      : in     vl_logic;
        SRAM_read_data  : in     vl_logic_vector(15 downto 0);
        SRAM_address    : out    vl_logic_vector(17 downto 0);
        SRAM_write_data : out    vl_logic_vector(15 downto 0);
        SRAM_we_n       : out    vl_logic;
        sim_done        : out    vl_logic;
        M1_state        : out    work.\Milestone_1_v_unit\.\M1_state_type\
    );
end Milestone_1;
