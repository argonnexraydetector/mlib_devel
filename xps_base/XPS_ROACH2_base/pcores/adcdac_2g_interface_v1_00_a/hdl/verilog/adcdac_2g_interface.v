`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UCSB
// Author: Matt Strader
// 
// Create Date:    Sept 10, 2015
// Module Name:    adcdac_2g
// Description:  
//////////////////////////////////////////////////////////////////////////////////
module adcdac_2g_interface(
    //-- differential data read from ADC
    input [14:0]data0_p,
    input [14:0]data0_n,
    input [14:0]data1_p,
    input [14:0]data1_n,
    input [14:0]data2_p,
    input [14:0]data2_n,
    input [14:0]data3_p,
    input [14:0]data3_n,

    //-- sample clocks
    input data0_smpl_clk_p,
    input data0_smpl_clk_n,
    input data1_smpl_clk_p,
    input data1_smpl_clk_n,
    input data2_smpl_clk_p,
    input data2_smpl_clk_n,
    input data3_smpl_clk_p,
    input data3_smpl_clk_n,

    //-- ready to receive pins
    output data0_rdy_p,
    output data0_rdy_n,
    output data1_rdy_p,
    output data1_rdy_n,
    output data2_rdy_p,
    output data2_rdy_n,
    output data3_rdy_p,
    output data3_rdy_n,

    input sync_pps_p,
    input sync_pps_n,
    
    //-- pps port for synching multiple boards
    //input pps_sync,
    
      
    //--------------------------------------
    //-- signals to/from design
    //--------------------------------------
    
    //-- clock from FPGA    
    //input fpga_clk,

    //-- clock to FPGA
    output adc_clk_out,
    output adc_clk90_out,
    output adc_clk180_out,
    output adc_clk270_out,

   // -- mmcm locked 
    output adc_mmcm_locked,

    //-- yellow block ports
    output [11:0]user_data_i0,
    output [11:0]user_data_i1,
    output [11:0]user_data_i2,
    output [11:0]user_data_i3,
    output [11:0]user_data_i4,
    output [11:0]user_data_i5,
    output [11:0]user_data_i6,
    output [11:0]user_data_i7,
    output [11:0]user_data_q0,
    output [11:0]user_data_q1,
    output [11:0]user_data_q2,
    output [11:0]user_data_q3,
    output [11:0]user_data_q4,
    output [11:0]user_data_q5,
    output [11:0]user_data_q6,
    output [11:0]user_data_q7,
    
    output [2:0]user_info_i0,
    output [2:0]user_info_i1,
    output [2:0]user_info_i2,
    output [2:0]user_info_i3,
    output [2:0]user_info_i4,
    output [2:0]user_info_i5,
    output [2:0]user_info_i6,
    output [2:0]user_info_i7,
    output [2:0]user_info_q0,
    output [2:0]user_info_q1,
    output [2:0]user_info_q2,
    output [2:0]user_info_q3,
    output [2:0]user_info_q4,
    output [2:0]user_info_q5,
    output [2:0]user_info_q6,
    output [2:0]user_info_q7,
    output user_sync,

    input user_rdy_i0,
    input user_rdy_i1,
    input user_rdy_q0,
    input user_rdy_q1

    );

// First set clock manager


    
//  -----------------------------------------------------
//  -- Clock 
//  -----------------------------------------------------

//  -- data0 sample clock from ADC 

    wire data0_smpl_clk;
    IBUFGDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_adc_clk(
          .O(data0_smpl_clk),           
          .I(data0_smpl_clk_p),
          .IB(data0_smpl_clk_n)
          );


    //  -- MMCM INPUT
      

    wire mmcm_clk_in;
    BUFG BUFG_data_clk(
        .I(data0_smpl_clk),
        .O(mmcm_clk_in));
      
     
      
    // --  clkinv <= not clk;
      
        
    //  -- MMCM

    wire smpl_clkdiv;
    wire mmcm_smpl_clkdiv_out;
    wire mmcm_smpl_clk_out;
    wire mmcm_clk_out_0;
    wire mmcm_clk_out_90;
    wire mmcm_clk_out_180;
    wire mmcm_clk_out_270;
    MMCM_BASE #(
       .BANDWIDTH("OPTIMIZED"),   // Jitter programming ("HIGH","LOW","OPTIMIZED")
       .CLKFBOUT_MULT_F(8.0),     // Multiply value for all CLKOUT (5.0-64.0).
       .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (0.00-360.00).
       //Input 125 MHz -> 8 ns
       .CLKIN1_PERIOD(8.000),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       .CLKOUT4_CASCADE("FALSE"), // Cascase CLKOUT4 counter with CLKOUT6 (TRUE/FALSE)
       .CLOCK_HOLD("FALSE"),      // Hold VCO Frequency (TRUE/FALSE)
       .DIVCLK_DIVIDE(1),         // Master division value (1-80)
       .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
       .STARTUP_WAIT("FALSE"),     // Not supported. Must be set to FALSE.

       //Output 125 MHz
       .CLKOUT0_DIVIDE_F(8.0),    // Divide amount for CLKOUT0 (1.000-128.000).
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),

       //Output 500 MHz
       .CLKOUT1_DIVIDE(2),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT1_PHASE(0.0),

       //Output 250 MHz 0deg for fpga
       .CLKOUT2_DIVIDE(4),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT2_PHASE(0.0),

       //Output 250 MHz 90deg for fpga
       .CLKOUT3_DIVIDE(4),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT3_PHASE(90.0),

       //Output 250 MHz 180deg for fpga
       .CLKOUT4_DIVIDE(4),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT4_PHASE(180.0),
       
       //Output 250 MHz 270deg for fpga
       .CLKOUT5_DIVIDE(4),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT5_PHASE(270.0),

        //unused
       .CLKOUT6_DIVIDE(4),
       .CLKOUT6_DUTY_CYCLE(0.5),
       .CLKOUT6_PHASE(0.0)
    )
    CLK_MMCM (
       // Clock Outputs: 1-bit (each) output: User configurable clock outputs
       .CLKOUT0(mmcm_smpl_clkdiv_out), 
       .CLKOUT0B(),
       .CLKOUT1(mmcm_smpl_clk_out),
       .CLKOUT1B(), 
       .CLKOUT2(mmcm_clk_out_0),
       .CLKOUT2B(), 
       .CLKOUT3(mmcm_clk_out_90),
       .CLKOUT3B(),
       .CLKOUT4(mmcm_clk_out_180),
       .CLKOUT5(mmcm_clk_out_270),
       .CLKOUT6(),
       // Feedback Clocks
       .CLKFBOUTB(),
       // Status Port
       .LOCKED(adc_mmcm_locked),
       // Clock Input
       .CLKIN1(mmcm_clk_in),
       // Control Ports
       .PWRDWN(1'b0),       // 1-bit input: Power-down input
       .RST(1'b0),             // 1-bit input: Reset input
       // Feedback Clocks
       .CLKFBIN(smpl_clkdiv)      // 1-bit input: Feedback clock input
    );

    //  -- MMCM OUTPUT
    //  Now put all mmcm outputs through a BUFG

      //125 MHz clocks for the slow parallel side of serdes
    BUFG BUFG_clkdiv
         (.I(mmcm_smpl_clkdiv_out), .O(smpl_clkdiv));
     
     //500 MHz clock for the fast serial side of serdes
    wire smpl_clk;
    BUFG BUFG_clkfast 
       (.I(mmcm_smpl_clk_out), .O(smpl_clk));
     
     //250 MHz clocks with phases 0,90,180,270 for the fpga clock
    wire clk_0;
    wire clk_90;
    wire clk_180;
    wire clk_270;
    BUFG BUFG_clk0
       (.I(mmcm_clk_out_0),.O(clk_0));
    BUFG  BUFG_clk90 
      (.I(mmcm_clk_out_90), .O(clk_90));
    BUFG BUFG_clk180 
     (.I(mmcm_clk_out_180), .O(clk_180));
    BUFG BUFG_clk270 
      (.I(mmcm_clk_out_270), .O(clk_270));

    assign adc_clk_out = clk_0;
    assign adc_clk90_out = clk_90;
    assign adc_clk180_out = clk_180;
    assign adc_clk270_out = clk_270;

    // ------------------------------------------------------
    // -- ADC data inputs --
    // -- 	Requires a Serdes with DDR to parallelize, and an 
    // --	IBUFDS to convert from a differential signal.
    // ------------------------------------------------------
     
    wire [14:0]buf_data0;
    genvar j;
    generate
    for (j=0; j<15;j=j+1)
    begin: IBUFDS_inst_data0_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data0[j]),
          .I(data0_p[j]),
          .IB(data0_n[j])
        );
    end
    endgenerate

    wire [14:0]buf_data1;
    generate
    for (j=0; j<15;j=j+1)
    begin: IBUFDS_inst_data1_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data1[j]),
          .I(data1_p[j]),
          .IB(data1_n[j])
        );
    end
    endgenerate

    wire [14:0]buf_data2;
    generate
    for (j=0; j<15;j=j+1)
    begin: IBUFDS_inst_data2_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data2[j]),
          .I(data2_p[j]),
          .IB(data2_n[j])
        );
    end
    endgenerate

    wire [14:0]buf_data3;
    generate
    for (j=0; j<15;j=j+1)
    begin: IBUFDS_inst_data3_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data3[j]),
          .I(data3_p[j]),
          .IB(data3_n[j])
        );
    end
    endgenerate

    //For each data stream (data0,data1,data2,...) parallelize with a serdes
    wire [14:0]serdes_data0_t0;
    wire [14:0]serdes_data0_t1;
    wire [14:0]serdes_data0_t2;
    wire [14:0]serdes_data0_t3;
    generate
        for (j=0; j<15;j=j+1) //one for each bit in a data bus
        begin: ISERDES_NODELAY_inst_data0_generate
           ISERDESE1 #(
              .DATA_RATE("DDR"),           // "SDR" or "DDR" 
              .DATA_WIDTH(4),              // Parallel data width (2-8, 10)
              .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (TRUE/FALSE)
              .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (TRUE/FALSE)
              // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
              .INIT_Q1(1'b0),
              .INIT_Q2(1'b0),
              .INIT_Q3(1'b0),
              .INIT_Q4(1'b0),
              .INTERFACE_TYPE("NETWORKING"),   // "MEMORY", "MEMORY_DDR3", "MEMORY_QDR", "NETWORKING", or "OVERSAMPLE" 
              .IOBDELAY("NONE"),           // "NONE", "IBUF", "IFD", "BOTH" 
              .NUM_CE(1),                  // Number of clock enables (1 or 2)
              .OFB_USED("FALSE"),          // Select OFB path (TRUE/FALSE)
              .SERDES_MODE("MASTER"),      // "MASTER" or "SLAVE" 
              // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
              .SRVAL_Q1(1'b0),
              .SRVAL_Q2(1'b0),
              .SRVAL_Q3(1'b0),
              .SRVAL_Q4(1'b0)
           )
           ISERDES_NODELAY_inst_i (
              .O(O),                       // 1-bit output: Combinatorial output
              // Q1 - Q6: 1-bit (each) output: Registered data outputs
              .Q1(serdes_data0_t0[j]),
              .Q2(serdes_data0_t1[j]),
              .Q3(serdes_data0_t2[j]),
              .Q4(serdes_data0_t3[j]),
              .Q5(),
              .Q6(),

              // SHIFTOUT1-SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
              .SHIFTOUT1(),
              .SHIFTOUT2(),
              .BITSLIP(1'b0),           // 1-bit input: Bitslip enable input
              // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
              .CE1(1'b1),
              // Clocks: 1-bit (each) input: ISERDESE1 clock input ports
              .CLK(smpl_clk),                   // 1-bit input: High-speed clock input, 500 MHz
              .CLKB(!smpl_clk),                 // 1-bit input: High-speed secondary clock input
              .CLKDIV(clk_0),             // 1-bit input: Divided clock input, 250 MHz
              .OCLK(1'b0),                 // 1-bit input: High speed output clock input used when
                                           // INTERFACE_TYPE="MEMORY" 

              // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
              .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion input
              .DYNCLKSEL(1'b0),       // 1-bit input: Dynamic CLK/CLKB inversion input
              // Input Data: 1-bit (each) input: ISERDESE1 data input ports
              .D(buf_data0[j]),                       // 1-bit input: Data input
              .DDLY(1'b0),                 // 1-bit input: Serial input data from IODELAYE1
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate
                          
    wire [14:0]serdes_data1_t0;
    wire [14:0]serdes_data1_t1;
    wire [14:0]serdes_data1_t2;
    wire [14:0]serdes_data1_t3;
    generate
        for (j=0; j<15;j=j+1) //one for each bit in a data bus
        begin: ISERDES_NODELAY_inst_data1_generate
           ISERDESE1 #(
              .DATA_RATE("DDR"),           // "SDR" or "DDR" 
              .DATA_WIDTH(4),              // Parallel data width (2-8, 10)
              .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (TRUE/FALSE)
              .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (TRUE/FALSE)
              // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
              .INIT_Q1(1'b0),
              .INIT_Q2(1'b0),
              .INIT_Q3(1'b0),
              .INIT_Q4(1'b0),
              .INTERFACE_TYPE("NETWORKING"),   // "MEMORY", "MEMORY_DDR3", "MEMORY_QDR", "NETWORKING", or "OVERSAMPLE" 
              .IOBDELAY("NONE"),           // "NONE", "IBUF", "IFD", "BOTH" 
              .NUM_CE(1),                  // Number of clock enables (1 or 2)
              .OFB_USED("FALSE"),          // Select OFB path (TRUE/FALSE)
              .SERDES_MODE("MASTER"),      // "MASTER" or "SLAVE" 
              // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
              .SRVAL_Q1(1'b0),
              .SRVAL_Q2(1'b0),
              .SRVAL_Q3(1'b0),
              .SRVAL_Q4(1'b0)
           )
           ISERDES_NODELAY_inst_i (
              .O(O),                       // 1-bit output: Combinatorial output
              // Q1 - Q6: 1-bit (each) output: Registered data outputs
              .Q1(serdes_data1_t0[j]),
              .Q2(serdes_data1_t1[j]),
              .Q3(serdes_data1_t2[j]),
              .Q4(serdes_data1_t3[j]),
              .Q5(),
              .Q6(),

              // SHIFTOUT1-SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
              .SHIFTOUT1(),
              .SHIFTOUT2(),
              .BITSLIP(1'b0),           // 1-bit input: Bitslip enable input
              // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
              .CE1(1'b1),
              // Clocks: 1-bit (each) input: ISERDESE1 clock input ports
              .CLK(smpl_clk),                   // 1-bit input: High-speed clock input, 500 MHz
              .CLKB(!smpl_clk),                 // 1-bit input: High-speed secondary clock input
              .CLKDIV(clk_0),             // 1-bit input: Divided clock input, 250 MHz
              .OCLK(1'b0),                 // 1-bit input: High speed output clock input used when
                                           // INTERFACE_TYPE="MEMORY" 

              // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
              .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion input
              .DYNCLKSEL(1'b0),       // 1-bit input: Dynamic CLK/CLKB inversion input
              // Input Data: 1-bit (each) input: ISERDESE1 data input ports
              .D(buf_data1[j]),                       // 1-bit input: Data input
              .DDLY(1'b0),                 // 1-bit input: Serial input data from IODELAYE1
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate

    wire [14:0]serdes_data2_t0;
    wire [14:0]serdes_data2_t1;
    wire [14:0]serdes_data2_t2;
    wire [14:0]serdes_data2_t3;
    generate
        for (j=0; j<15;j=j+1) //one for each bit in a data bus
        begin: ISERDES_NODELAY_inst_data2_generate
           ISERDESE1 #(
              .DATA_RATE("DDR"),           // "SDR" or "DDR" 
              .DATA_WIDTH(4),              // Parallel data width (2-8, 10)
              .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (TRUE/FALSE)
              .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (TRUE/FALSE)
              // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
              .INIT_Q1(1'b0),
              .INIT_Q2(1'b0),
              .INIT_Q3(1'b0),
              .INIT_Q4(1'b0),
              .INTERFACE_TYPE("NETWORKING"),   // "MEMORY", "MEMORY_DDR3", "MEMORY_QDR", "NETWORKING", or "OVERSAMPLE" 
              .IOBDELAY("NONE"),           // "NONE", "IBUF", "IFD", "BOTH" 
              .NUM_CE(1),                  // Number of clock enables (1 or 2)
              .OFB_USED("FALSE"),          // Select OFB path (TRUE/FALSE)
              .SERDES_MODE("MASTER"),      // "MASTER" or "SLAVE" 
              // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
              .SRVAL_Q1(1'b0),
              .SRVAL_Q2(1'b0),
              .SRVAL_Q3(1'b0),
              .SRVAL_Q4(1'b0)
           )
           ISERDES_NODELAY_inst_i (
              .O(O),                       // 1-bit output: Combinatorial output
              // Q1 - Q6: 1-bit (each) output: Registered data outputs
              .Q1(serdes_data2_t0[j]),
              .Q2(serdes_data2_t1[j]),
              .Q3(serdes_data2_t2[j]),
              .Q4(serdes_data2_t3[j]),
              .Q5(),
              .Q6(),

              // SHIFTOUT1-SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
              .SHIFTOUT1(),
              .SHIFTOUT2(),
              .BITSLIP(1'b0),           // 1-bit input: Bitslip enable input
              // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
              .CE1(1'b1),
              // Clocks: 1-bit (each) input: ISERDESE1 clock input ports
              .CLK(smpl_clk),                   // 1-bit input: High-speed clock input, 500 MHz
              .CLKB(!smpl_clk),                 // 1-bit input: High-speed secondary clock input
              .CLKDIV(clk_0),             // 1-bit input: Divided clock input, 250 MHz
              .OCLK(1'b0),                 // 1-bit input: High speed output clock input used when
                                           // INTERFACE_TYPE="MEMORY" 

              // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
              .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion input
              .DYNCLKSEL(1'b0),       // 1-bit input: Dynamic CLK/CLKB inversion input
              // Input Data: 1-bit (each) input: ISERDESE1 data input ports
              .D(buf_data2[j]),                       // 1-bit input: Data input
              .DDLY(1'b0),                 // 1-bit input: Serial input data from IODELAYE1
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate

    wire [14:0]serdes_data3_t0;
    wire [14:0]serdes_data3_t1;
    wire [14:0]serdes_data3_t2;
    wire [14:0]serdes_data3_t3;
    generate
        for (j=0; j<15;j=j+1) //one for each bit in a data bus
        begin: ISERDES_NODELAY_inst_data3_generate
           ISERDESE1 #(
              .DATA_RATE("DDR"),           // "SDR" or "DDR" 
              .DATA_WIDTH(4),              // Parallel data width (2-8, 10)
              .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (TRUE/FALSE)
              .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (TRUE/FALSE)
              // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
              .INIT_Q1(1'b0),
              .INIT_Q2(1'b0),
              .INIT_Q3(1'b0),
              .INIT_Q4(1'b0),
              .INTERFACE_TYPE("NETWORKING"),   // "MEMORY", "MEMORY_DDR3", "MEMORY_QDR", "NETWORKING", or "OVERSAMPLE" 
              .IOBDELAY("NONE"),           // "NONE", "IBUF", "IFD", "BOTH" 
              .NUM_CE(1),                  // Number of clock enables (1 or 2)
              .OFB_USED("FALSE"),          // Select OFB path (TRUE/FALSE)
              .SERDES_MODE("MASTER"),      // "MASTER" or "SLAVE" 
              // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
              .SRVAL_Q1(1'b0),
              .SRVAL_Q2(1'b0),
              .SRVAL_Q3(1'b0),
              .SRVAL_Q4(1'b0)
           )
           ISERDES_NODELAY_inst_i (
              .O(O),                       // 1-bit output: Combinatorial output
              // Q1 - Q6: 1-bit (each) output: Registered data outputs
              .Q1(serdes_data3_t0[j]),
              .Q2(serdes_data3_t1[j]),
              .Q3(serdes_data3_t2[j]),
              .Q4(serdes_data3_t3[j]),
              .Q5(),
              .Q6(),

              // SHIFTOUT1-SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
              .SHIFTOUT1(),
              .SHIFTOUT2(),
              .BITSLIP(1'b0),           // 1-bit input: Bitslip enable input
              // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
              .CE1(1'b1),
              // Clocks: 1-bit (each) input: ISERDESE1 clock input ports
              .CLK(smpl_clk),                   // 1-bit input: High-speed clock input, 500 MHz
              .CLKB(!smpl_clk),                 // 1-bit input: High-speed secondary clock input
              .CLKDIV(clk_0),             // 1-bit input: Divided clock input, 250 MHz
              .OCLK(1'b0),                 // 1-bit input: High speed output clock input used when
                                           // INTERFACE_TYPE="MEMORY" 

              // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
              .DYNCLKDIVSEL(1'b0), // 1-bit input: Dynamic CLKDIV inversion input
              .DYNCLKSEL(1'b0),       // 1-bit input: Dynamic CLK/CLKB inversion input
              // Input Data: 1-bit (each) input: ISERDESE1 data input ports
              .D(buf_data3[j]),                       // 1-bit input: Data input
              .DDLY(1'b0),                 // 1-bit input: Serial input data from IODELAYE1
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate

    reg [14:0]recapture_data0_t0;
    reg [14:0]recapture_data0_t1;
    reg [14:0]recapture_data0_t2;
    reg [14:0]recapture_data0_t3;
    reg [14:0]recapture_data1_t0;
    reg [14:0]recapture_data1_t1;
    reg [14:0]recapture_data1_t2;
    reg [14:0]recapture_data1_t3;
    reg [14:0]recapture_data2_t0;
    reg [14:0]recapture_data2_t1;
    reg [14:0]recapture_data2_t2;
    reg [14:0]recapture_data2_t3;
    reg [14:0]recapture_data3_t0;
    reg [14:0]recapture_data3_t1;
    reg [14:0]recapture_data3_t2;
    reg [14:0]recapture_data3_t3;
    //recapture all DDR inputs to clk's rising edge
    always @(posedge clk_0)
    begin
        recapture_data0_t0 <= serdes_data0_t0;
        recapture_data0_t1 <= serdes_data0_t1;
        recapture_data0_t2 <= serdes_data0_t2;
        recapture_data0_t3 <= serdes_data0_t3;

        recapture_data1_t0 <= serdes_data1_t0;
        recapture_data1_t1 <= serdes_data1_t1;
        recapture_data1_t2 <= serdes_data1_t2;
        recapture_data1_t3 <= serdes_data1_t3;

        recapture_data2_t0 <= serdes_data2_t0;
        recapture_data2_t1 <= serdes_data2_t1;
        recapture_data2_t2 <= serdes_data2_t2;
        recapture_data2_t3 <= serdes_data2_t3;

        recapture_data3_t0 <= serdes_data3_t0;
        recapture_data3_t1 <= serdes_data3_t1;
        recapture_data3_t2 <= serdes_data3_t2;
        recapture_data3_t3 <= serdes_data3_t3;
    end

    //Use registers to buffer and move data around to be in the proper temporal order
    reg [14:0] adata0_t0;
    reg [14:0] adata0_t1;
    reg [14:0] adata0_t2;
    reg [14:0] adata0_t3;
    reg [14:0] adata1_t0;
    reg [14:0] adata1_t1;
    reg [14:0] adata1_t2;
    reg [14:0] adata1_t3;
    reg [14:0] adata2_t0;
    reg [14:0] adata2_t1;
    reg [14:0] adata2_t2;
    reg [14:0] adata2_t3;
    reg [14:0] adata3_t0;
    reg [14:0] adata3_t1;
    reg [14:0] adata3_t2;
    reg [14:0] adata3_t3;

    reg [14:0] bdata0_t0;
    reg [14:0] bdata0_t1;
    reg [14:0] bdata0_t2;
    reg [14:0] bdata0_t3;
    reg [14:0] bdata1_t0;
    reg [14:0] bdata1_t1;
    reg [14:0] bdata1_t2;
    reg [14:0] bdata1_t3;
    reg [14:0] bdata2_t0;
    reg [14:0] bdata2_t1;
    reg [14:0] bdata2_t2;
    reg [14:0] bdata2_t3;
    reg [14:0] bdata3_t0;
    reg [14:0] bdata3_t1;
    reg [14:0] bdata3_t2;
    reg [14:0] bdata3_t3;

    reg [14:0] cdata0_t0;
    reg [14:0] cdata0_t1;
    reg [14:0] cdata0_t2;
    reg [14:0] cdata0_t3;
    reg [14:0] cdata1_t0;
    reg [14:0] cdata1_t1;
    reg [14:0] cdata1_t2;
    reg [14:0] cdata1_t3;
    reg [14:0] cdata2_t0;
    reg [14:0] cdata2_t1;
    reg [14:0] cdata2_t2;
    reg [14:0] cdata2_t3;
    reg [14:0] cdata3_t0;
    reg [14:0] cdata3_t1;
    reg [14:0] cdata3_t2;
    reg [14:0] cdata3_t3;

    reg [14:0] idata0;
    reg [14:0] idata1;
    reg [14:0] idata2;
    reg [14:0] idata3;
    reg [14:0] idata4;
    reg [14:0] idata5;
    reg [14:0] idata6;
    reg [14:0] idata7;
    reg [14:0] qdata0;
    reg [14:0] qdata1;
    reg [14:0] qdata2;
    reg [14:0] qdata3;
    reg [14:0] qdata4;
    reg [14:0] qdata5;
    reg [14:0] qdata6;
    reg [14:0] qdata7;

     always @(posedge smpl_clkdiv)
     begin
        adata0_t0 <= recapture_data0_t0;
        adata0_t1 <= recapture_data0_t1;
        adata0_t2 <= recapture_data0_t2;
        adata0_t3 <= recapture_data0_t3;
        adata1_t0 <= recapture_data1_t0;
        adata1_t1 <= recapture_data1_t1;
        adata1_t2 <= recapture_data1_t2;
        adata1_t3 <= recapture_data1_t3;

        adata2_t0 <= recapture_data2_t0;
        adata2_t1 <= recapture_data2_t1;
        adata2_t2 <= recapture_data2_t2;
        adata2_t3 <= recapture_data2_t3;
        adata3_t0 <= recapture_data3_t0;
        adata3_t1 <= recapture_data3_t1;
        adata3_t2 <= recapture_data3_t2;
        adata3_t3 <= recapture_data3_t3;
     end 
    
     always @(negedge smpl_clkdiv)
     begin
        bdata0_t0 <= recapture_data0_t0;
        bdata0_t1 <= recapture_data0_t1;
        bdata0_t2 <= recapture_data0_t2;
        bdata0_t3 <= recapture_data0_t3;
        bdata1_t0 <= recapture_data1_t0;
        bdata1_t1 <= recapture_data1_t1;
        bdata1_t2 <= recapture_data1_t2;
        bdata1_t3 <= recapture_data1_t3;

        bdata2_t0 <= recapture_data2_t0;
        bdata2_t1 <= recapture_data2_t1;
        bdata2_t2 <= recapture_data2_t2;
        bdata2_t3 <= recapture_data2_t3;
        bdata3_t0 <= recapture_data3_t0;
        bdata3_t1 <= recapture_data3_t1;
        bdata3_t2 <= recapture_data3_t2;
        bdata3_t3 <= recapture_data3_t3;
     end 

     always @(negedge smpl_clkdiv)
     begin
        cdata0_t0 <= bdata0_t0;
        cdata0_t1 <= bdata0_t1;
        cdata0_t2 <= bdata0_t2;
        cdata0_t3 <= bdata0_t3;
        cdata1_t0 <= bdata1_t0;
        cdata1_t1 <= bdata1_t1;
        cdata1_t2 <= bdata1_t2;
        cdata1_t3 <= bdata1_t3;

        cdata2_t0 <= bdata2_t0;
        cdata2_t1 <= bdata2_t1;
        cdata2_t2 <= bdata2_t2;
        cdata2_t3 <= bdata2_t3;
        cdata3_t0 <= bdata3_t0;
        cdata3_t1 <= bdata3_t1;
        cdata3_t2 <= bdata3_t2;
        cdata3_t3 <= bdata3_t3;
     end

     always @(posedge clk_0)
     begin
        if (smpl_clkdiv)
        begin
            idata0  <= bdata0_t0;
            idata1  <= bdata0_t1;
            idata2  <= bdata0_t2;
            idata3  <= bdata0_t3;
            idata4  <= adata0_t0;
            idata5  <= adata0_t1;
            idata6  <= adata0_t2;
            idata7  <= adata0_t3;

            qdata0  <= bdata2_t0;
            qdata1  <= bdata2_t1;
            qdata2  <= bdata2_t2;
            qdata3  <= bdata2_t3;
            qdata4  <= adata2_t0;
            qdata5  <= adata2_t1;
            qdata6  <= adata2_t2;
            qdata7  <= adata2_t3;
        end
        else
        begin
            idata0  <= cdata1_t0;
            idata1  <= cdata1_t1;
            idata2  <= cdata1_t2;
            idata3  <= cdata1_t3;
            idata4  <= adata1_t0;
            idata5  <= adata1_t1;
            idata6  <= adata1_t2;
            idata7  <= adata1_t3;

            qdata0  <= cdata3_t0;
            qdata1  <= cdata3_t1;
            qdata2  <= cdata3_t2;
            qdata3  <= cdata3_t3;
            qdata4  <= adata3_t0;
            qdata5  <= adata3_t1;
            qdata6  <= adata3_t2;
            qdata7  <= adata3_t3;
        end
     end

    //send reordered data to module outputs
    assign user_data_i0 = idata0[11:0];
    assign user_data_i1 = idata1[11:0];
    assign user_data_i2 = idata2[11:0];
    assign user_data_i3 = idata3[11:0];
    assign user_data_i4 = idata4[11:0];
    assign user_data_i5 = idata5[11:0];
    assign user_data_i6 = idata6[11:0];
    assign user_data_i7 = idata7[11:0];

    assign user_data_q0 = qdata0[11:0];
    assign user_data_q1 = qdata1[11:0];
    assign user_data_q2 = qdata2[11:0];
    assign user_data_q3 = qdata3[11:0];
    assign user_data_q4 = qdata4[11:0];
    assign user_data_q5 = qdata5[11:0];
    assign user_data_q6 = qdata6[11:0];
    assign user_data_q7 = qdata7[11:0];

    assign user_info_i0 = idata0[14:12];
    assign user_info_i1 = idata1[14:12];
    assign user_info_i2 = idata2[14:12];
    assign user_info_i3 = idata3[14:12];
    assign user_info_i4 = idata4[14:12];
    assign user_info_i5 = idata5[14:12];
    assign user_info_i6 = idata6[14:12];
    assign user_info_i7 = idata7[14:12];

    assign user_info_q0 = qdata0[14:12];
    assign user_info_q1 = qdata1[14:12];
    assign user_info_q2 = qdata2[14:12];
    assign user_info_q3 = qdata3[14:12];
    assign user_info_q4 = qdata4[14:12];
    assign user_info_q5 = qdata5[14:12];
    assign user_info_q6 = qdata6[14:12];
    assign user_info_q7 = qdata7[14:12];

    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_data0_rdy_p
    (
     .O(data0_rdy_p),
     .OB(data0_rdy_n),
     .I(user_rdy_i0)
    );
    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_data1_rdy_p
    (
     .O(data1_rdy_p),
     .OB(data1_rdy_n),
     .I(user_rdy_i1)
    );
    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_data2_rdy_p
    (
     .O(data2_rdy_p),
     .OB(data2_rdy_n),
     .I(user_rdy_q0)
    );
    wire d3_rdy_p = 1'b1;
    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_data3_rdy_p
    (
     .O(data3_rdy_p),
     .OB(data3_rdy_n),
     .I(user_rdy_q1)
    );

    //assign user_sync = 1'b0;

    IBUFDS #(.IOSTANDARD("LVDS_25"))
    IBUFDS_inst_sync 
    (
      .O(user_sync),
      .I(sync_pps_p),
      .IB(sync_pps_n)
    );


endmodule

