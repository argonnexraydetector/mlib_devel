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
    input [11:0]data0_p,
    input [11:0]data0_n,
    input [11:0]data1_p,
    input [11:0]data1_n,
    input [11:0]data2_p,
    input [11:0]data2_n,
    input [11:0]data3_p,
    input [11:0]data3_n,
    input [1:0]info0_p,
    input [1:0]info0_n,
    input [1:0]info1_p,
    input [1:0]info1_n,
    input [1:0]info2_p,
    input [1:0]info2_n,
    input [1:0]info3_p,
    input [1:0]info3_n,
    input valid_p,
    input valid_n,

    //-- sample clocks
    input data0_smpl_clk_p,
    input data0_smpl_clk_n,

    //-- ready to receive pins
    output data0_rdy_p,
    output data0_rdy_n,

    output sync_out_p,
    output sync_out_n,

    input sync_pps_p,
    input sync_pps_n,
    
    //-- pps port for synching multiple boards
    //input pps_sync,
    
      
    //--------------------------------------
    //-- signals to/from design
    //--------------------------------------
    
    //-- clock from FPGA    
    //input fpga_clk,
    input sys_clk,

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
    
    output [1:0]user_info_i0,
    output [1:0]user_info_i1,
    output [1:0]user_info_i2,
    output [1:0]user_info_i3,
    output [1:0]user_info_i4,
    output [1:0]user_info_i5,
    output [1:0]user_info_i6,
    output [1:0]user_info_i7,
    output [1:0]user_info_q0,
    output [1:0]user_info_q1,
    output [1:0]user_info_q2,
    output [1:0]user_info_q3,
    output [1:0]user_info_q4,
    output [1:0]user_info_q5,
    output [1:0]user_info_q6,
    output [1:0]user_info_q7,
    output user_valid,
    output user_sync,
    output user_mmcm_locked,

    //ready for adcdac board to start sending adc values
    input user_rdy_i0,
    //val to load into an iodelay
    input [4:0]user_dly_val,
    //choose which bit's iodelay to load above value into 
    input [5:0]user_load_dly0,
    input user_pos_mmcm_phs,
    input user_inc_mmcm_phs
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

    wire clk_0;
    wire clk_90;
    wire clk_180;
    wire clk_270;

    reg inc_mmcm_phs;

    //we'll fanout the user_load_dly0 to make timing easier
    reg [4:0]dly_val0;
    reg [4:0]dly_val1;
    reg [4:0]dly_val2;
    reg [4:0]dly_val3;
    //demux the user load_dly0 value to wires controlling each bit's iodelay
    // reset
    wire [55:0]load_bit_dly;
    genvar k;
    generate
        for (k = 0; k < 56; k = k + 1) 
        begin : load_dly_demux
            assign load_bit_dly[k] = (user_load_dly0 == k) ? (1'b1) : (1'b0);
        end
    endgenerate

    reg [55:0]load_bit_dly_reg;
    always @(posedge sys_clk)
    begin
        load_bit_dly_reg <= load_bit_dly;
    end

    //if the user togles on user_inc_mmcm_phs, send a one cycle pulse along
    reg already_triggered_inc;
    initial begin
        already_triggered_inc = 1'b0;
    end
    always @(posedge sys_clk)
    begin
       if (user_inc_mmcm_phs && !already_triggered_inc) 
       begin
            already_triggered_inc <= ~already_triggered_inc;
            inc_mmcm_phs <= 1;
       end
       else if (!user_inc_mmcm_phs) 
       begin
            already_triggered_inc <= 1'b0;
       end
       else 
       begin
            inc_mmcm_phs <= 0;
       end
    end

    /*
    IODELAYE1 #(
        .DELAY_SRC        ("CLKIN"),
        .IDELAY_TYPE      ("VAR_LOADABLE"),
        .IDELAY_VALUE     (1'b0),
        .REFCLK_FREQUENCY (200),
        .HIGH_PERFORMANCE_MODE ("TRUE"),
        .SIGNAL_PATTERN("CLOCK")
        ) IODELAY_smpl_clk [13:0] (
            .C           (sys_clk),
            .CE          (1'b0),
            .DATAIN      (1'b0),
            .IDATAIN     (1'b0),
            .CLKIN       (data0_smpl_clk),
            .INC         (1'b0),
            .ODATAIN     (),
            .RST         (user_load_dly0[14]),
            .T           (1'b0),
            .DATAOUT     (data0_smpl_clk_dlyy),
            .CNTVALUEOUT (),
            .CNTVALUEIN (user_dly_val)
            );
            */

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
    wire mmcm_feedback_clk;
    wire mmcm_feedback_clk_out;
    MMCM_ADV #(
       .BANDWIDTH("HIGH"),   // Jitter programming ("HIGH","LOW","OPTIMIZED")
       .CLKFBOUT_MULT_F(8.0),     // Multiply value for all CLKOUT (5.0-64.0).
       .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (0.00-360.00).
       //I'm going to lie to the mmcm and tell it the input is 135 MHz but
       //it'll really be 125 Mhz.  This is to trick it to use HIGH bandwidth
       //mode for f_pfd=125 MHz when it's usually limited to 135 MHz.
       .CLKIN1_PERIOD(7.407),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       .CLKOUT4_CASCADE("FALSE"), // Cascase CLKOUT4 counter with CLKOUT6 (TRUE/FALSE)
       .CLOCK_HOLD("FALSE"),      // Hold VCO Frequency (TRUE/FALSE)
       .DIVCLK_DIVIDE(1),         // Master division value (1-80)
       .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
       .STARTUP_WAIT("FALSE"),     // Not supported. Must be set to FALSE.
       .CLKFBOUT_USE_FINE_PS("TRUE"),

       //Output 480 MHz
       .CLKOUT0_DIVIDE_F(2),    // Divide amount for CLKOUT0 (1.000-128.000).
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),

       //Output 120 MHz
       .CLKOUT1_DIVIDE(8),
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
       .CLKOUT0(mmcm_smpl_clk_out), 
       .CLKOUT0B(),
       .CLKOUT1(mmcm_smpl_clkdiv_out),
       .CLKOUT1B(), 
       .CLKOUT2(mmcm_clk_out_0),
       .CLKOUT2B(), 
       .CLKOUT3(mmcm_clk_out_90),
       .CLKOUT3B(),
       .CLKOUT4(mmcm_clk_out_180),
       .CLKOUT5(mmcm_clk_out_270),
       .CLKOUT6(),
       // Feedback Clocks
       .CLKFBOUT(mmcm_feedback_clk_out),
       // Status Port
       .LOCKED(adc_mmcm_locked),
       // Clock Input
       .CLKIN1(mmcm_clk_in),
       // Control Ports
       .PWRDWN(1'b0),       // 1-bit input: Power-down input
       .RST(1'b0),             // 1-bit input: Reset input
       // Feedback Clocks
       .CLKFBIN(mmcm_feedback_clk),      // 1-bit input: Feedback clock input
       .PSCLK(sys_clk), //phase shift clock
       .PSEN(inc_mmcm_phs), //when high synchronously with PSCLK, will increment/decrement phase by one click
       .PSINCDEC(user_pos_mmcm_phs) //phase-shift increment/decrement control, high for increment, low for decrement
    );

    //  -- MMCM OUTPUT
    //  Now put all mmcm outputs through a BUFG
    BUFG BUFG_fb_clk
         (.I(mmcm_feedback_clk_out), .O(mmcm_feedback_clk));

      //125 MHz clocks for the slow parallel side of serdes
    BUFG BUFG_clkdiv
         (.I(mmcm_smpl_clkdiv_out), .O(smpl_clkdiv));
     
     //500 MHz clock for the fast serial side of serdes
    wire smpl_clk;
    BUFG BUFG_clkfast 
       (.I(mmcm_smpl_clk_out), .O(smpl_clk));
     
     //250 MHz clocks with phases 0,90,180,270 for the fpga clock
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
    assign user_mmcm_locked = adc_mmcm_locked;

    // ------------------------------------------------------
    // -- ADC data inputs --
    // -- 	Requires a Serdes with DDR to parallelize, and an 
    // --	IBUFDS to convert from a differential signal.
    // ------------------------------------------------------
     
    wire [13:0]buf_data0;
    genvar j;
    generate
    for (j=0; j<12;j=j+1)
    begin: IBUFDS_inst_data0_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data0[j]),
          .I(data0_p[j]),
          .IB(data0_n[j])
        );
    end
    endgenerate

    generate
    for (j=0; j<2;j=j+1)
    begin: IBUFDS_inst_info0_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data0[12+j]),
          .I(info0_p[j]),
          .IB(info0_n[j])
        );
    end
    endgenerate

    wire [13:0]buf_data1;
    generate
    for (j=0; j<12;j=j+1)
    begin: IBUFDS_inst_data1_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data1[j]),
          .I(data1_p[j]),
          .IB(data1_n[j])
        );
    end
    endgenerate
    generate
    for (j=0; j<2;j=j+1)
    begin: IBUFDS_inst_info1_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data1[12+j]),
          .I(info1_p[j]),
          .IB(info1_n[j])
        );
    end
    endgenerate

    wire [13:0]buf_data2;
    generate
    for (j=0; j<12;j=j+1)
    begin: IBUFDS_inst_data2_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data2[j]),
          .I(data2_p[j]),
          .IB(data2_n[j])
        );
    end
    endgenerate


    generate
    for (j=0; j<2;j=j+1)
    begin: IBUFDS_inst_info2_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data2[12+j]),
          .I(info2_p[j]),
          .IB(info2_n[j])
        );
    end
    endgenerate

    wire [13:0]buf_data3;
    generate
    for (j=0; j<12;j=j+1)
    begin: IBUFDS_inst_data3_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data3[j]),
          .I(data3_p[j]),
          .IB(data3_n[j])
        );
    end
    endgenerate
    generate
    for (j=0; j<2;j=j+1)
    begin: IBUFDS_inst_info3_generate

        IBUFDS #(.IOSTANDARD("LVDS_25"))
        IBUFDS_inst_data (
            .O(buf_data3[12+j]),
          .I(info3_p[j]),
          .IB(info3_n[j])
        );
    end
    endgenerate

   
    wire [13:0]buf_data0_dly;
    IODELAYE1 #(
        .DELAY_SRC        ("I"),
        .IDELAY_TYPE      ("VAR_LOADABLE"),
        .IDELAY_VALUE     (1'b0),
        .REFCLK_FREQUENCY (200),
        .HIGH_PERFORMANCE_MODE ("TRUE")
        ) IODELAY_data0 [13:0] (
            .C           (clk_0),
            .CE          (1'b0),
            .DATAIN      (1'b0),
            .IDATAIN     (buf_data0),
            .INC         (1'b0),
            .ODATAIN     (),
            .RST         (load_bit_dly_reg[13:0]),
            .T           (1'b0),
            .DATAOUT     (buf_data0_dly),
            .CNTVALUEOUT (),
            .CNTVALUEIN (dly_val0)
            );
    wire [13:0]buf_data1_dly;
    IODELAYE1 #(
        .DELAY_SRC        ("I"),
        .IDELAY_TYPE      ("VAR_LOADABLE"),
        .IDELAY_VALUE     (1'b0),
        .REFCLK_FREQUENCY (200),
        .HIGH_PERFORMANCE_MODE ("TRUE")
        ) IODELAY_data1 [13:0] (
            .C           (clk_0),
            .CE          (1'b0),
            .DATAIN      (1'b0),
            .IDATAIN     (buf_data1),
            .INC         (1'b0),
            .ODATAIN     (),
            .RST         (load_bit_dly_reg[27:14]),
            .T           (1'b0),
            .DATAOUT     (buf_data1_dly),
            .CNTVALUEOUT (),
            .CNTVALUEIN (dly_val1)
            );
    wire [13:0]buf_data2_dly;
    IODELAYE1 #(
        .DELAY_SRC        ("I"),
        .IDELAY_TYPE      ("VAR_LOADABLE"),
        .IDELAY_VALUE     (1'b0),
        .REFCLK_FREQUENCY (200),
        .HIGH_PERFORMANCE_MODE ("TRUE")
        ) IODELAY_data2 [13:0] (
            .C           (clk_0),
            .CE          (1'b0),
            .DATAIN      (1'b0),
            .IDATAIN     (buf_data2),
            .INC         (1'b0),
            .ODATAIN     (),
            .RST         (load_bit_dly_reg[41:28]),
            .T           (1'b0),
            .DATAOUT     (buf_data2_dly),
            .CNTVALUEOUT (),
            .CNTVALUEIN (dly_val2)
            );
    wire [13:0]buf_data3_dly;
    IODELAYE1 #(
        .DELAY_SRC        ("I"),
        .IDELAY_TYPE      ("VAR_LOADABLE"),
        .IDELAY_VALUE     (1'b0),
        .REFCLK_FREQUENCY (200),
        .HIGH_PERFORMANCE_MODE ("TRUE")
        ) IODELAY_data3 [13:0] (
            .C           (clk_0),
            .CE          (1'b0),
            .DATAIN      (1'b0),
            .IDATAIN     (buf_data3),
            .INC         (1'b0),
            .ODATAIN     (),
            .RST         (load_bit_dly_reg[55:42]),
            .T           (1'b0),
            .DATAOUT     (buf_data3_dly),
            .CNTVALUEOUT (),
            .CNTVALUEIN (dly_val3)
            );
    //For each data stream (data0,data1,data2,...) parallelize with a serdes
    wire [13:0]serdes_data0_t0;
    wire [13:0]serdes_data0_t1;
    wire [13:0]serdes_data0_t2;
    wire [13:0]serdes_data0_t3;
    generate
        for (j=0; j<14;j=j+1) //one for each bit in a data bus
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
              .IOBDELAY("IFD"),           // "NONE", "IBUF", "IFD", "BOTH" 
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
              .O(),                       // 1-bit output: Combinatorial output
              // Q1 - Q6: 1-bit (each) output: Registered data outputs
              .Q1(serdes_data0_t3[j]),
              .Q2(serdes_data0_t2[j]),
              .Q3(serdes_data0_t1[j]),
              .Q4(serdes_data0_t0[j]),
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
              //.D(buf_data0[j]),                       // 1-bit input: Data input
              .D(1'b0),                       // 1-bit input: Data input
              .DDLY(buf_data0_dly[j]),                 // 1-bit input: Serial input data from IODELAYE1
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate
                          
    wire [13:0]serdes_data1_t0;
    wire [13:0]serdes_data1_t1;
    wire [13:0]serdes_data1_t2;
    wire [13:0]serdes_data1_t3;
    generate
        for (j=0; j<14;j=j+1) //one for each bit in a data bus
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
              .IOBDELAY("IFD"),           // "NONE", "IBUF", "IFD", "BOTH" 
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
              .Q1(serdes_data1_t3[j]),
              .Q2(serdes_data1_t2[j]),
              .Q3(serdes_data1_t1[j]),
              .Q4(serdes_data1_t0[j]),
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
              .DDLY(buf_data1_dly[j]), 
              .D(1'b0),                 
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate

    wire [13:0]serdes_data2_t0;
    wire [13:0]serdes_data2_t1;
    wire [13:0]serdes_data2_t2;
    wire [13:0]serdes_data2_t3;
    generate
        for (j=0; j<14;j=j+1) //one for each bit in a data bus
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
              .IOBDELAY("IFD"),           // "NONE", "IBUF", "IFD", "BOTH" 
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
              .Q1(serdes_data2_t3[j]),
              .Q2(serdes_data2_t2[j]),
              .Q3(serdes_data2_t1[j]),
              .Q4(serdes_data2_t0[j]),
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
              .DDLY(buf_data2_dly[j]), 
              .D(1'b0),                 
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate

    wire [13:0]serdes_data3_t0;
    wire [13:0]serdes_data3_t1;
    wire [13:0]serdes_data3_t2;
    wire [13:0]serdes_data3_t3;
    generate
        for (j=0; j<14;j=j+1) //one for each bit in a data bus
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
              .IOBDELAY("IFD"),           // "NONE", "IBUF", "IFD", "BOTH" 
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
              .Q1(serdes_data3_t3[j]),
              .Q2(serdes_data3_t2[j]),
              .Q3(serdes_data3_t1[j]),
              .Q4(serdes_data3_t0[j]),
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
              .DDLY(buf_data3_dly[j]),                       
              .D(1'b0),                 
              .OFB(OFB),                   // 1-bit input: Data feedback input from OSERDESE1
              .RST(1'b0),                   // 1-bit input: Active high asynchronous reset input
              // SHIFTIN1-SHIFTIN2: 1-bit (each) input: Data width expansion input ports
              .SHIFTIN1(1'b0),
              .SHIFTIN2(1'b0)
           );
        end
    endgenerate

    reg [13:0]recapture_data0_t0;
    reg [13:0]recapture_data0_t1;
    reg [13:0]recapture_data0_t2;
    reg [13:0]recapture_data0_t3;
    reg [13:0]recapture_data1_t0;
    reg [13:0]recapture_data1_t1;
    reg [13:0]recapture_data1_t2;
    reg [13:0]recapture_data1_t3;
    reg [13:0]recapture_data2_t0;
    reg [13:0]recapture_data2_t1;
    reg [13:0]recapture_data2_t2;
    reg [13:0]recapture_data2_t3;
    reg [13:0]recapture_data3_t0;
    reg [13:0]recapture_data3_t1;
    reg [13:0]recapture_data3_t2;
    reg [13:0]recapture_data3_t3;

    //fanout the user values to multiple registers make timing easier
    always @(posedge sys_clk)
    begin
        dly_val0 <= user_dly_val;
        dly_val1 <= user_dly_val;
        dly_val2 <= user_dly_val;
        dly_val3 <= user_dly_val;
    end

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

    //send recaptured data to module outputs
    assign user_data_i0 = recapture_data0_t0[11:0];
    assign user_data_i1 = recapture_data0_t1[11:0];
    assign user_data_i2 = recapture_data0_t2[11:0];
    assign user_data_i3 = recapture_data0_t3[11:0];
    assign user_data_i4 = recapture_data1_t0[11:0];
    assign user_data_i5 = recapture_data1_t1[11:0];
    assign user_data_i6 = recapture_data1_t2[11:0];
    assign user_data_i7 = recapture_data1_t3[11:0];

    assign user_data_q0 = recapture_data2_t0[11:0];
    assign user_data_q1 = recapture_data2_t1[11:0];
    assign user_data_q2 = recapture_data2_t2[11:0];
    assign user_data_q3 = recapture_data2_t3[11:0];
    assign user_data_q4 = recapture_data3_t0[11:0];
    assign user_data_q5 = recapture_data3_t1[11:0];
    assign user_data_q6 = recapture_data3_t2[11:0];
    assign user_data_q7 = recapture_data3_t3[11:0];

    assign user_info_i0 = recapture_data0_t0[13:12];
    assign user_info_i1 = recapture_data0_t1[13:12];
    assign user_info_i2 = recapture_data0_t2[13:12];
    assign user_info_i3 = recapture_data0_t3[13:12];
    assign user_info_i4 = recapture_data1_t0[13:12];
    assign user_info_i5 = recapture_data1_t1[13:12];
    assign user_info_i6 = recapture_data1_t2[13:12];
    assign user_info_i7 = recapture_data1_t3[13:12];

    assign user_info_q0 = recapture_data2_t0[13:12];
    assign user_info_q1 = recapture_data2_t1[13:12];
    assign user_info_q2 = recapture_data2_t2[13:12];
    assign user_info_q3 = recapture_data2_t3[13:12];
    assign user_info_q4 = recapture_data3_t0[13:12];
    assign user_info_q5 = recapture_data3_t1[13:12];
    assign user_info_q6 = recapture_data3_t2[13:12];
    assign user_info_q7 = recapture_data3_t3[13:12];


    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_data0_rdy_p
    (
     .O(data0_rdy_p),
     .OB(data0_rdy_n),
     .I(user_rdy_i0)
    );

    //assign user_sync = 1'b0;

    IBUFDS #(.IOSTANDARD("LVDS_25"))
    IBUFDS_inst_sync 
    (
      .O(user_sync),
      .I(sync_pps_p),
      .IB(sync_pps_n)
    );

    IBUFDS #(.IOSTANDARD("LVDS_25"))
    IBUFDS_inst_valid 
    (
      .O(user_valid),
      .I(valid_p),
      .IB(valid_n)
    );


    //For debugging, send a signal to sync_out
    
    reg[3:0] divctr = 4'b0;
    reg sync_out_reg = 1'b0;
    /*
    always @(posedge mmcm_clk_in)
    begin
        divctr <= divctr + 4'b1;
        
        if (divctr == 0)
        begin
            sync_out_reg <= 1'b1;
        end
        else
        begin
            sync_out_reg <= 1'b0;
        end
    end
    */
    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_sync_out
    (
     .O(sync_out_p),
     .OB(sync_out_n),
     .I(user_rdy_i0)
    );

endmodule

