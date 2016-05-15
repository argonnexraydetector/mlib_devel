`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UCSB
// Author: Matt Strader
// 
// Create Date:    May 12, 2016
// Module Name:    adcdac_2g
// Description:    communicates with the FNAL 2Gsps ADC/DAC with a UART over
// two ZDOK pairs
//////////////////////////////////////////////////////////////////////////////////
module adcdac_2g_ctrl(

    //-- to from hardware
    input zdok_rx_data_p,
    input zdok_rx_data_n,
    output zdok_tx_data_p,
    output zdok_tx_data_n,
      
    //--------------------------------------
    //-- signals to/from design
    //--------------------------------------
    //-- clock from FPGA    
    input fpga_clk,

    input user_tx_rst,
    input user_rx_rst,
    input [7:0]user_tx_data,
    input user_tx_val,
    output user_tx_full,
    output user_rx_full,
    output [7:0]user_rx_data,
    output user_rx_val
    );

    // convert input and output differential signals
     
    wire zdok_tx_data;
    wire zdok_rx_data;

    OBUFDS #(.IOSTANDARD("LVDS_25"))
    OBUFDS_inst_tx_data
    (
     .O(zdok_tx_data_p),
     .OB(zdok_tx_data_n),
     .I(zdok_tx_data)
    );

    IBUFDS #(.IOSTANDARD("LVDS_25"))
    IBUFDS_inst_rx_data
    (
      .O(zdok_rx_data),
      .I(zdok_rx_data_p),
      .IB(zdok_rx_data_n)
    );
    //while testing direct loopback
    //assign zdok_tx_data = 1'b0;
    //wire temp_loopback_serial;

    reg en_16_x_baud = 1'b0;
    wire uart_tx_half_full;//unused
    wire uart_tx_data_present;//unused
    wire tx_full;
    //reg write_to_uart_tx = 1'b0;
    //data_in
    uart_tx6 tx
    (
      .data_in(user_tx_data),
      .en_16_x_baud(en_16_x_baud),
      .serial_out(zdok_tx_data),
      //.serial_out(temp_loopback_serial),
      .buffer_write(user_tx_val),
      .buffer_data_present(uart_tx_data_present),
      .buffer_half_full(uart_tx_half_full ),
      .buffer_full(tx_full),
      .buffer_reset(user_tx_rst),              
      .clk(fpga_clk)
    );
    assign user_tx_full = tx_full;

    wire [7:0]uart_rx_data_out;
    wire uart_rx_data_present;
    wire uart_rx_half_full;// unused
    wire rx_full;
    reg read_from_uart_rx;
    
    uart_rx6 rx
    (
      .serial_in(zdok_rx_data),
      //.serial_in(temp_loopback_serial),
      .en_16_x_baud(en_16_x_baud),
      .data_out(uart_rx_data_out),
      .buffer_read(read_from_uart_rx),
      .buffer_data_present(uart_rx_data_present),
      .buffer_half_full(uart_rx_half_full),
      .buffer_full(rx_full ),
      .buffer_reset(user_rx_rst ),              
      .clk(fpga_clk)
    );
    reg capture_rx_val = 1'b0;
    reg just_read_from_rx = 1'b0;
    reg [7:0]capture_rx_data;
    assign user_rx_val = capture_rx_val;
    assign user_rx_data = capture_rx_data;

    reg latch_data_present = 1'b0;
    assign user_rx_full = rx_full;

    always @(posedge fpga_clk)
    begin
        if (uart_rx_data_present && ! just_read_from_rx)
        begin
            just_read_from_rx <= 1'b1;
            capture_rx_val <= 1'b1;
            capture_rx_data <= uart_rx_data_out;
            read_from_uart_rx <= 1'b1;
        end
        else if (uart_rx_data_present && just_read_from_rx)
        begin
            just_read_from_rx <= 1'b0;
            capture_rx_val <= 1'b0;
            read_from_uart_rx <= 1'b0;
        end
        else
        begin
            just_read_from_rx <= 1'b0;
            capture_rx_val <= 1'b0;
            read_from_uart_rx <= 1'b0;
        end
    end

    //
    /////////////////////////////////////////////////////////////////////////////////////////
    // UART baud rate 
    /////////////////////////////////////////////////////////////////////////////////////////
    // To set serial communication baud rate to 115,200 then en_16_x_baud must pulse 
    // High at 1,843,200Hz which is every 27.13 cycles at 50MHz. 
//    reg baud_count = 1'b0;
//    always @ (posedge sys_clk )
//    begin
//        if (baud_count == 5'b11010) begin       // counts 27 states including zero
//            baud_count <= 5'b00000;
//            en_16_x_baud <= 1'b1;                 // single cycle enable pulse
//        end
//        else begin
//            baud_count <= baud_count + 5'b00001;
//            en_16_x_baud <= 1'b0;
//        end
//    end

    // To set serial communication baud rate to 9600 then en_16_x_baud must pulse 
    // High at 153600Hz which is every 1627.604 cycles at 250MHz. In this implementation 
    // a pulse is generated every 1628 cycles resulting is a baud rate of 9597.67 baud 
    // which is 0.02% low, but is less than the 5% tolerance mentioned in the example

    reg [10:0]baud_count = 11'b00000000000;
    always @ (posedge fpga_clk )
    begin
        if (baud_count == 11'b11001011011) begin       // counts 651 states including zero
            baud_count <= 11'b00000000000;
            en_16_x_baud <= 1'b1;                 // single cycle enable pulse
        end
        else begin
            baud_count <= baud_count + 11'b00000000001;
            en_16_x_baud <= 1'b0;
        end
    end


endmodule

