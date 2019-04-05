`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/29 08:42:10
// Design Name: 
// Module Name: Spi_Festival_Config
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

module Spi_Festival_Config(

    input                   clk_i,        //时钟输入
    input                   rst_n,      //复位信号
input          [12:0]   wr_addr,
    input          [31:0]   wr_data,
    input                   wr_en,
    input                   spi_miso,    //SPI 总线数据信号输入
    output  wire           spi_sclk,    //SPI 总线时钟信号输出
    output  wire           spi_mosi,    //SPI 总线数据信号
    output  wire           spi_cs       //SPI  使能
); 
//  内部寄存器及连线
 (* mark_debug = "true" *)reg [15:0] spi_data_reg;
 (* mark_debug = "true" *)reg        spi_start;
 (* mark_debug = "true" *)wire       SPI_END;  //寄存器并串转换结束标志位
 (* mark_debug = "true" *)reg [15:0] reg_data;
 (* mark_debug = "true" *)reg [7:0]  addr_index;
//时钟参数
parameter CLK_Freq = 100000000; //输入的系统时钟 100MHz
parameter SPI_Freq = 50000000; //SPI 总线时钟 10MHz
//存储SPI配置数据的查找表容量
parameter LUT_SIZE = 72;  


 (* mark_debug = "true" *)reg [1:0]      state;
//state machine code
   localparam     S_IDLE      = 2'b00;
   localparam     S_START     = 2'b01; //start bit
   localparam     S_STOP      = 2'b10;
//////100MHz 时钟分频得到 10MHz 的 SPI 控制时钟//////
 (* mark_debug = "true" *)reg  [7:0]  spi_clk_div;
 (* mark_debug = "true" *)reg         spi_ctrl_clk;
    always@(posedge clk_i or negedge rst_n)
    begin
    if(!rst_n)
       begin
         spi_ctrl_clk <= 0;
         spi_clk_div <= 8'h00;
       end
    else
       begin
         if( spi_clk_div ==(CLK_Freq/SPI_Freq-1'b1))
           begin
             spi_clk_div <= 0;
             spi_ctrl_clk <= ~spi_ctrl_clk;
           end
   
         else
            spi_clk_div <= spi_clk_div+1;
       end
    end
 wire                initial_en; //触发信号,可使用单脉冲做触发源；
 reg                 initial_clr; //初始化结束清零位；
 reg                 wr_start_en;  //初始化使能开始；
 assign   initial_en=(wr_addr==12'h660 & wr_en);
    always@(posedge clk_i)
   begin
     if(initial_clr)
       begin
         wr_start_en<=1'b0;
        end
     else if(initial_en)
       begin
        wr_start_en<=1'b1;
       end
   end
//////////////////////  配置过程控制  ///////////////////////
    always@(posedge spi_ctrl_clk or negedge rst_n)
    begin
      if(~rst_n) //复位
        begin
          addr_index <= 0;
          spi_start <= 0;
        end
      else
        begin
          if (wr_start_en)
            begin 
               if(addr_index<LUT_SIZE)
                    begin
                      case(state)
                           S_IDLE: begin //第一步：准备数据，启动传输
                                spi_data_reg <=  reg_data;
                                spi_start <= 1'b1;
                                state <= 1'b1;end
                           S_START:
                              begin
                                if(SPI_END) //第二步：检验传输是否正常结束
                                        begin
                                          state <= S_STOP;
                                          spi_start <= 1'b0;
                                        end                                         
                                 else
                                         state <= S_START;
                             end
                         S_STOP: begin //传输结束，改变 LUT_INDEX 的值，准备传输下一个数据
                                    addr_index <= addr_index+1;
                                    state <= S_IDLE;end
                      endcase
                    end
               else 
                     begin
                       state <= S_IDLE;
                       addr_index<=0;
                       initial_clr<=1'b1;                     
                     end  
               end
          else    initial_clr<=1'b0;  
       end
    end
/////////////////////    配置数据查找表  //////////////////////////
    always @(posedge clk_i )
    begin
        case(addr_index)
          8'd00          : begin  reg_data <= 16'h0000; end
          8'd01          : begin  reg_data <= 16'h0000; end      
          8'd02          : begin  reg_data <= 16'h0020; end
          8'd03          : begin  reg_data <= 16'h0020; end
          8'd04          : begin  reg_data <= 16'h0040; end
          8'd05          : begin  reg_data <= 16'h1140; end
          8'd06          : begin  reg_data <= 16'h1180; end
          8'd07          : begin  reg_data <= 16'h15ff; end
          8'd08          : begin  reg_data <= 16'h1549; end
          8'd09          : begin  reg_data <= 16'h7f49; end
          8'd10          : begin  reg_data <= 16'h7f49; end
          8'd11          : begin  reg_data <= 16'h1549; end
          8'd12          : begin  reg_data <= 16'h15ff; end
          8'd13          : begin  reg_data <= 16'h1180; end
          8'd14          : begin  reg_data <= 16'h1140; end
          8'd15          : begin  reg_data <= 16'h0040; end
          8'd16          : begin  reg_data <= 16'h0020; end
          8'd17          : begin  reg_data <= 16'h0020; end
          
          8'd18          : begin  reg_data <= 16'h0000; end
          8'd19          : begin  reg_data <= 16'h0000; end
          8'd20          : begin  reg_data <= 16'h0800; end
          8'd21          : begin  reg_data <= 16'h0800; end
          8'd22          : begin  reg_data <= 16'h0900; end
          8'd23          : begin  reg_data <= 16'h0900; end
          8'd24          : begin  reg_data <= 16'h7f00; end
          8'd25          : begin  reg_data <= 16'h7f00; end
          8'd26          : begin  reg_data <= 16'h0900; end
          8'd27          : begin  reg_data <= 16'h09ff; end
          8'd28          : begin  reg_data <= 16'h09ff; end
          8'd29          : begin  reg_data <= 16'h0900; end
          8'd30          : begin  reg_data <= 16'h7f20; end
          8'd31          : begin  reg_data <= 16'h7f20; end
          8'd32          : begin  reg_data <= 16'h0910; end
          8'd33          : begin  reg_data <= 16'h09f0; end
          8'd34          : begin  reg_data <= 16'h0800; end
          8'd35          : begin  reg_data <= 16'h0800; end
          
          8'd36          : begin  reg_data <= 16'h0000; end
          8'd37          : begin  reg_data <= 16'h0000; end
          8'd38          : begin  reg_data <= 16'h0180; end
          8'd39          : begin  reg_data <= 16'h0e00; end
          8'd40          : begin  reg_data <= 16'h7fff; end
          8'd41          : begin  reg_data <= 16'h7fff; end     
          8'd42          : begin  reg_data <= 16'h0c00; end
          8'd43          : begin  reg_data <= 16'h0443; end
          8'd44          : begin  reg_data <= 16'h0842; end
          8'd45          : begin  reg_data <= 16'h084c; end
          8'd46          : begin  reg_data <= 16'h0858; end
          8'd47          : begin  reg_data <= 16'h7fe0; end
          8'd48          : begin  reg_data <= 16'h0870; end
          8'd49          : begin  reg_data <= 16'h084c; end
          8'd50          : begin  reg_data <= 16'h0846; end
          8'd51          : begin  reg_data <= 16'h0fc2; end
          8'd52          : begin  reg_data <= 16'h0041; end
          8'd53          : begin  reg_data <= 16'h0040; end
          
          8'd54          : begin  reg_data <= 16'h0000; end
          8'd55          : begin  reg_data <= 16'h0000; end
          8'd56          : begin  reg_data <= 16'h0006; end
          8'd57          : begin  reg_data <= 16'h3f8c; end
          8'd58          : begin  reg_data <= 16'h2098; end
          8'd59          : begin  reg_data <= 16'h20b0; end
          8'd60          : begin  reg_data <= 16'h2081; end
          8'd61          : begin  reg_data <= 16'h2081; end
          8'd62          : begin  reg_data <= 16'h2083; end
          8'd63          : begin  reg_data <= 16'h2ffe; end
          8'd64          : begin  reg_data <= 16'h2080; end
          8'd65          : begin  reg_data <= 16'h4080; end
          8'd66          : begin  reg_data <= 16'h4080; end
          8'd67          : begin  reg_data <= 16'h4098; end
          8'd68          : begin  reg_data <= 16'h408c; end
          8'd69          : begin  reg_data <= 16'h4086; end
          8'd70          : begin  reg_data <= 16'h0000; end
          8'd71          : begin  reg_data <= 16'h0000; end 
          default:  begin  reg_data <= 16'h0000; end 
        endcase
    end
 // 定义上位机单独配置寄存器的值，无需更改不用配置
 reg          pci_write_en;
 reg  [15:0]  spi_data;
 reg  [7:0]   wr_en_cnt; 
 
    always@(posedge clk_i)
   begin
     if(SPI_END)
       begin
         pci_write_en<=1'b0;
        end
     else if(wr_addr==12'h650 & wr_en)
        pci_write_en<=1'b1;
   end  
   always@(posedge clk_i)
   begin
   if(~rst_n) 
           spi_data<=16'h0000;
   else 
     begin
         if((wr_addr[12:0]==13'h640) &  wr_en)
                  spi_data<=wr_data[15:0];                        
         else if(spi_start)  
                  spi_data<=spi_data_reg[15:0];
     end
   end

    wire     spi_en;
   assign    spi_en=pci_write_en | spi_start;

       ////例化 SPI 控制器  将16位并行数据完成并串转换///
       SPI_16Bit_Controller SPI_16Bit_Controller_inst(
       .clk_i        (spi_ctrl_clk), //  SPI 控制器工作时钟
       .spi_sclk     (), //  SPI 总线时钟信号
       .spi_miso     (), //  SPI 总线数据信号
       .spi_mosi     (), //  SPI 总线数据信号
       .spi_cs       (), //  SPI 总线使能信号
       .spi_data     (spi_data), //寄存器data
       .spi_start    (spi_en),    //  启动传输
       .data_end     (SPI_END),   //  传输结束标志
       .rst_n        (rst_n)      //复位信号
        );
endmodule