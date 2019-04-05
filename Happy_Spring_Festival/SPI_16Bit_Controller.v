`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/29 09:18:43
// Design Name: 
// Module Name: SPI_16Bit_Controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module SPI_16Bit_Controller(
    input                    clk_i,  //SPI 控制器时钟输入，
    input          [15:0]    spi_data,//SPI 总线时钟信号并行输入
    input                    spi_start,//启动传输
    input                    rst_n,//SPI 控制器复位信号
 (* mark_debug = "true" *)input                    spi_miso,//SPI 总线数据信号输入
 (* mark_debug = "true" *)output   wire           spi_mosi,//SPI 总线数据信号输出
 (* mark_debug = "true" *)output   wire           spi_sclk,//SPI 总线时钟信号输出
 (* mark_debug = "true" *)output   wire           spi_cs, //SPI 总线片选信号输出
    output   reg            data_end//传输结束标志
);
//以下信号为测试信号 
 (* mark_debug = "true" *)reg  [5:0]       sd_counter;//SPI 数据发送计数器
 (* mark_debug = "true" *)reg              spi_sdo_reg;//SPI 控制器发送的串行数据
 (* mark_debug = "true" *)reg              spi_cs_reg;
 (* mark_debug = "true" *)reg      [15:0]  spi_data_reg;
    assign           spi_sclk= (~spi_cs_reg )& ( ((sd_counter >= 2) & (sd_counter <=18))? ~clk_i :0 );
    assign           spi_mosi =spi_sdo_reg ; //如果输出数据为 1，spi_SDAT 设为高阻
    assign           spi_cs=spi_cs_reg; 
//--SPI 计数器
    always @(negedge rst_n or posedge clk_i ) 
    begin
       if (!rst_n) sd_counter=6'b000000;
       else begin
               if (spi_start==0)
                  sd_counter=0;
               else 
                   begin 
                      if (sd_counter == 6'b010011)
                          sd_counter<=0;
                       else
                          sd_counter=sd_counter+1;
                   end
             end
    end
    always @(negedge rst_n or posedge clk_i ) 
    begin
     if (!rst_n) 
        begin spi_cs_reg=1'b1; spi_sdo_reg=1'b0 ; data_end=1'b1;end
     else
       case (sd_counter)
          6'd0 : begin spi_cs_reg<=1'b1;data_end<=1'b0; spi_sdo_reg=1'b0; end
////////////////////////SPI START////////////////////////////////////
          6'd1 : begin spi_cs_reg<=1'b1;spi_data_reg<=spi_data;end
//发送从设备地址
          6'd2 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[15]; end
          6'd3 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[14]; end
          6'd4 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[13]; end
          6'd5 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[12]; end
          6'd6 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[11]; end
          6'd7 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[10]; end
          6'd8 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[9]; end
          6'd9 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[8]; end
          6'd10: begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[7]; end 
          6'd11 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[6]; end
          6'd12 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[5]; end
          6'd13 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[4]; end
          6'd14 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[3]; end
          6'd15 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[2]; end
          6'd16 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[1]; end
          6'd17 : begin spi_cs_reg<=1'b0; spi_sdo_reg<=spi_data_reg[0]; end
//////////////////////SPI STOP//////////////////////////////////////
          6'd18 : begin spi_cs_reg<=1'b0;  spi_sdo_reg<=1'b0; data_end<=1'b0 ; end
          6'd19 : begin spi_cs_reg<=1'b1;  spi_sdo_reg<=1'b0; data_end<=1'b1 ; end
        default : begin spi_cs_reg<=1'b1;  spi_sdo_reg<=1'b0; data_end<=1'b0 ; end
       endcase
    end
endmodule