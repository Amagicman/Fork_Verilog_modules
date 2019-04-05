//4*16fifo
module fifo_four(clk,rstp,din,readp,writep,dout,emptyp,fullp);
  input clk;                //时钟
  input rstp;               //复位
  input[15:0]din;           //16位输入信号
  input readp;              //读指令
  input writep;              //写指令
  output[15:0]dout;         //16位输出信号
  output emptyp;            //空指示信号
  output fullp;             //满指示信号

  parameter DEPTH=2,MAX_COUNT=2'b11;

  reg[15:0]dout;
  reg emptyp;
  reg fullp;

  reg[(DEPTH-1):0] tail; //读指针
  reg[(DEPTH-1):0] head;//写指针
  reg[(DEPTH-1):0] count; //计数器
  reg[15:0]fifomem[0:MAX_COUNT]; //四个16位存储单元

  //read
  always@(posedge clk)
    if(rstp==1)    
        dout<=0;  
    else if(readp==1&&emptyp==0)
      dout<=fifomem[tail];
   //write   
  always@(posedge clk)
      if(rstp==1&&writep==1&&fullp==0)
        fifomem[head]<=din;

  //更新head指针
  always@(posedge clk)    
  if(rstp==1)
    head<=0;
  else if(writep==1&&fullp==0)
    head<=head+1;

  //更新tail指针
  always@(posedge clk)    
  if(rstp==1)
    tail<=0;
  else if(readp==1&&emptyp==0)
    tail<=tail+1;

  //count
  always@(posedge clk)
  if(rstp==1)
    count<=0;
  else
     case({readp,writep})
     2'b00:
          count<=count;
     2'b01:
          if(count!=MAX_COUNT)
          count<=count+1;
     2'b10:
          if(count!=0)
          count<=count-1;
     2'b11:
          count<=count;
    endcase

  //更新标志位emptyp
  always@(count)
  if(count==0)
     emptyp<=1;
   else
     emptyp<=0;

  //更新标志位tail
  always@(count)
  if(count==MAX_COUNT)
    tail<=1;
  else
    tail<=0;

endmodule