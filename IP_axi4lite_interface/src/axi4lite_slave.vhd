-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : axi4lite_slave.vhd
-- Author       : E. Messerli    27.07.2017
-- Description  : slave interface AXI  (without burst)
-- used for     : SOCF lab
--| Modifications |-----------------------------------------------------------
-- Ver  Date       Auteur  Description
-- 1.0  26.03.2019  EMI    Adaptation du chablon pour les etudiants  
--
------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity axi4lite_slave is
    generic (
        -- Users to add parameters here

        -- User parameters ends

        -- Width of S_AXI data bus
        AXI_DATA_WIDTH  : integer   := 32;  -- 32 or 64 bits
        -- Width of S_AXI address bus
        AXI_ADDR_WIDTH  : integer   := 12
    );
    port (
        axi_clk_i       : in  std_logic;
        axi_reset_i     : in  std_logic;
        -- AXI4-Lite 
        axi_awaddr_i    : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        axi_awprot_i    : in  std_logic_vector( 2 downto 0);
        axi_awvalid_i   : in  std_logic;
        axi_awready_o   : out std_logic;
        axi_wdata_i     : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        axi_wstrb_i     : in std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
        axi_wvalid_i    : in  std_logic;
        axi_wready_o    : out std_logic;
        axi_bresp_o     : out std_logic_vector(1 downto 0);
        axi_bvalid_o    : out std_logic;
        axi_bready_i    : in  std_logic;
        axi_araddr_i    : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        axi_arprot_i    : in  std_logic_vector( 2 downto 0);
        axi_arvalid_i   : in  std_logic;
        axi_arready_o   : out std_logic;
        axi_rdata_o     : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        axi_rresp_o     : out std_logic_vector(1 downto 0);
        axi_rvalid_o    : out std_logic;
        axi_rready_i    : in  std_logic

        -- User input-output
        axi_keys_i      : in std_logic_vector(3 downto 0);
        axi_switchs_i   : in std_logic_vector(9 downto 0);
        
        axi_leds_o      : out std_logic_vector(9 downto 0);
        axi_hex_3_0_o   : out std_logic_vector(27 downto 0);
        axi_hex_5_4_o   : out std_logic_vector(13 downto 0);
        
    );
end entity axi4lite_slave;

architecture rtl of axi4lite_slave is

    signal reset_s : std_logic;

    -- local parameter for addressing 32 bit / 64 bits, cst: AXI_DATA_WIDTH
    -- ADDR_LSB is used for addressing word 32/64 bits registers/memories
    -- ADDR_LSB = 2 for 32 bits (n-1 downto 2)
    -- ADDR_LSB = 3 for 64 bits (n-1 downto 3)
    constant ADDR_LSB  : integer := (AXI_DATA_WIDTH/32)+ 1;
    
    --signal for the AXI slave
    --intern signal for output
    signal axi_awready_s       : std_logic;
    signal axi_arready_s       : std_logic;

     --intern signal for the axi interface
    signal axi_waddr_mem_s     : std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
    signal axi_araddr_mem_s    : std_logic_vector(AXI_ADDR_WIDTH-1 downto ADDR_LSB);

    signal axi_wdata_mem_s     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_rdata_mem_s     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);

    signal axi_const_reg_s     : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_test_reg_s      : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_keys_reg_s      : std_logic_vector(3 downto 0);
    signal axi_switchs_reg_s   : std_logic_vector(9 downto 0);
    signal axi_leds_reg_s      : std_logic_vector(9 downto 0);
    signal axi_hex_3_0_reg_s   : std_logic_vector(27 downto 0);
    signal axi_hex_5_4_reg_s   : std_logic_vector(13 downto 0);
    

    -- TO CHECK
    signal axi_bvalid_s        : std_logic;
    signal axi_bresp_s         : std_logic_vector(1 downto 0);
    signal axi_rvalid_s        : std_logic;
    signal axi_wready_s        : std_logic;
    signal axi_data_wren_s     : std_logic;

begin

    reset_s  <= axi_reset_i;

-----------------------------------------------------------
-- Write address channel

    process (reset_s, axi_clk_i)
    begin
        if reset_s = '1' then
            axi_awready_s <= '0';
            axi_waddr_mem_s <= (others => '0');
        elsif rising_edge(axi_clk_i) then
            if (axi_awready_s = '0' and axi_awvalid_i = '1')  then --and axi_wvalid_i = '1') then  modif EMI 10juil2018
                -- slave is ready to accept write address when
                -- there is a valid write address
                axi_awready_s <= '1';
                -- Write Address memorizing
                axi_waddr_mem_s <= axi_awaddr_i(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
            else
                axi_awready_s <= '0';
            end if;
        end if;
    end process;
    axi_awready_o <= axi_awready_s;


-----------------------------------------------------------
-- Write data channel

    -- Implement axi_wready generation
    process (reset_s, clk_i)
    begin
        if reset_s = '1' then
            axi_waddr_done_s <= '0'; 
            axi_wready_s    <= '0';
        elsif rising_edge(clk_i) then

            --to be completed
            if(axi_wready_s = '0' and axi_wvalid_i = '1') then

                --Envoi du signal ready
                axi_wready_s <= '1';
                -- Mémorisation de la valeur de data
                axi_wdata_mem_s <= axi_wdata_i;
            else
                axi_wready_s <= '0';
            end if;
        end if;
    end process;
    
    axi_wready_o <= axi_wready_s;


    --condition to write data
    axi_data_wren_s <= axi_wready_s; --to be completed....     ;
    
    
    process (reset_s, clk_i)
        --number address to access 32 or 64 bits data
        variable int_waddr_v : natural;
    begin
        if reset_s = '1' then
            
            --to be completed
            axi_const_reg_s    <= x"50CFCAFE"; 
            axi_test_reg_s     <= (others => '0');
            axi_keys_reg_s     <= (others => '0');
            axi_switchs_reg_s  <= (others => '0');
            axi_leds_reg_s     <= (others => '0');
            axi_hex_3_0_reg_s  <= (others => '0');
            axi_hex_5_4_reg_s  <= (others => '0');

            
            
        elsif rising_edge(clk_i) then

            if axi_data_wren_s = '1' then
                int_waddr_v   := to_integer(unsigned(axi_waddr_mem_s));
                case int_waddr_v is
                    when 0   => null;
                    
                    when 1   => axi_test_reg_s <= axi_wdata_s
                    when 4   => axi_leds_reg_s <= axi_wdata_s(9 downto 0)
                    when 5   => axi_hex_3_0_reg_s <= axi_wdata_s(27 downto 0)
                    when 6   => axi_hex_5_4_reg_s <= axi_wdata_s(13 downto 0)
                    
                    
                    --to be completed


                    when others => null;
                end case;
            end if;
        end if;
    end process;
                    

-----------------------------------------------------------
-- Write response channel


    --to be completed

    process (reset_s, axi_clk_i)
        begin
            if reset_s = '1' then

                axi_bvalid_s <= '0';
                axi_bresp_s <= "00";
            elsif rising_edge(axi_clk_i) then

                if(axi_awready_s = '1' and axi_wready_s = '1') then
                    axi_bvalid_s <= '1';
                    axi_bresp_s <= "00";
                elsif(axi_bready_i = '1' and axi_bvalid_s = '1') then
                    axi_bvalid_s <= '0';
                end if;
            end if;
    end process;

    axi_bvalid_o <= axi_bvalid_s;
    axi_bresp_o <= axi_bresp_s;


    

-----------------------------------------------------------
-- Read address channel

    process (reset_s, axi_clk_i)
    begin
        if reset_s = '1' then
           axi_arready_s    <= '0';
           axi_araddr_mem_s <= (others => '1');
        elsif rising_edge(axi_clk_i) then
            if axi_arready_s = '0' and axi_arvalid_i = '1' then
                -- indicates that the slave has acceped the valid read address
                axi_arready_s    <= '1';
                -- Read Address memorizing
                axi_araddr_mem_s <= axi_araddr_i(AXI_ADDR_WIDTH-1 downto ADDR_LSB);
            else
                axi_arready_s    <= '0';
            end if;
        end if;
    end process;
    axi_arready_o <= axi_arready_s;

-----------------------------------------------------------
-- Read data channel

    --to be completed
    process (reset_s, axi_clk_i)
        --number address to access 32 or 64 bits data
        variable int_raddr_v : natural;
    begin
        if reset_s = '1' then
            axi_rdata_s <= (others => '0');
            axi_rvalid_s    <= '0';
        elsif rising_edge(axi_clk_i) then

            if axi_arready_s = '1' and axi_arvalid_i = '1' then

                axi_rvalid_s <= '1';
                int_raddr_v   := to_integer(unsigned(axi_araddr_mem_s));
                case int_raddr_v is
                    when 0   => axi_rdata_s <= axi_const_reg_s;   -- constante
                    when 1   => axi_rdata_s <= axi_test_reg_s;    -- registre de test
                    when 2   => axi_rdata_s <= axi_keys_reg_s;    -- registre des boutons keys
                    when 3   => axi_rdata_s <= axi_switchs_reg_s; -- registre des switchs
                    when 4   => axi_rdata_s <= axi_leds_reg_s;    -- registre des leds
                    when 5   => axi_rdata_s <= axi_hex_3_0_reg_s; -- registre des afficheurs 7-seg 3 à 0
                    when 6   => axi_rdata_s <= axi_hex_5_4_reg_s; -- registre des afficheurs 7-seg 5 à 4
                    when others => null; 
                end case;
            else
                axi_rvalid_s <= '0';
            end if;
        end if;
    end process;

    axi_rvalid_o <= axi_rvalid_s;
    axi_rdata_o <= axi_rdata_s;
    axi_rresp_o <= "00";


    -- attribution des signaux de sorties
    leds_o   <= axi_leds_reg_s; 
    hex03_o  <= axi_hex_3_0_reg_s; 
    hex54_o  <= axi_hex_5_4_reg_s;

end rtl;
