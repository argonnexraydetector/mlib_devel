`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UCSB
// Author: Matt Strader
// 
// Create Date:    Sept 10, 2015
// Module Name:    adcdac_2g
// Description:  
//////////////////////////////////////////////////////////////////////////////////
module adcdac_2g_ctrl(

    //-- to from hardware
    input spi_dout_p,
    input spi_dout_n,
    output spi_clk_p,
    output spi_clk_n,
    output spi_ss_p,
    output spi_ss_n,
    output spi_din_p,
    output spi_din_n,
      
    //--------------------------------------
    //-- signals to/from design
    //--------------------------------------
    //-- clock from FPGA    
    input fpga_clk,

    input user_spi_clk,
    input user_spi_ss,
    input user_spi_din,
    output user_spi_dout
    );

// First set clock manager
    
//  -----------------------------------------------------
//  -- Clock 
//  -----------------------------------------------------


    // ------------------------------------------------------
    // -- ADC data inputs --
    // -- 	Requires a Serdes with DDR to parallelize, and an 
    // --	IBUFDS to convert from a differential signal.
    // ------------------------------------------------------
     
    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_spi_clk
    (
     .O(spi_clk_p),
     .OB(spi_clk_n),
     .I(user_spi_clk)
    );
    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_spi_ss
    (
     .O(spi_ss_p),
     .OB(spi_ss_n),
     .I(user_spi_ss)
    );
    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_spi_din
    (
     .O(spi_din_p),
     .OB(spi_din_n),
     .I(user_spi_din)
    );

    IBUFDS #(.IOSTANDARD("LVDS_25"))
    IBUFDS_inst_spi_dout
    (
      .O(user_spi_dout),
      .I(spi_dout_p),
      .IB(spi_dout_n)
    );

endmodule

