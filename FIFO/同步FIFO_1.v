module FIFO_Buffer(
  Data_out, 			//数据输出
  stack_full,  			//栈满
  stack_almost_full, 	//栈近满
  stack_half_full, 		//栈半满
  stack_almost_empty,	 //栈近空
  stack_empty, 			//栈空
  Data_in, 				//数据输入
  write_to_stack,		//写入栈
  read_from_stack,		//读出栈
  clk,					//时钟
  rst					//时钟
  );
  
  parameter stack_width=32; //栈宽
  parameter stack_height=8; //栈深
  parameter stack_ptr_width=3; //栈宽
  parameter AE_level=2; 
  parameter AF_level=6;
  parameter HF_level=4;
  
  output [stack_width-1:0] Data_out;
  output                 stack_full,stack_almost_full,stack_half_full; //栈指示信号
  output                 stack_almost_empty,stack_empty;			//栈指示信号
  input[stack_width-1:0] Data_in;
  input                  write_to_stack,read_from_stack;      //写指针、读指针
  input                  clk,rst;

  reg[stack_ptr_width-1:0] read_ptr,write_ptr;
  reg[stack_ptr_width:0]   ptr_gap;
  reg[stack_width-1:0]     Data_out;
  reg[stack_width-1:0]     stack[stack_height-1:0];

  assign stack_full=(ptr_gap==stack_height);
  assign stack_almost_full=(ptr_gap==AF_level);
  assign stack_half_full=(ptr_gap==HF_level);
  assign stack_almost_empty=(ptr_gap==AE_level);
  assign stack_empty=(ptr_gap==0);

  always @(posedge clk or posedge rst)
   if(rst)begin
       Data_out<=0;
       read_ptr<=0;
       write_ptr<=0;
       ptr_gap<=0;
   end
   else if(write_to_stack &&(!stack_full)&&(!read_from_stack))begin
       stack[write_ptr]<=Data_in;
       write_ptr<=write_ptr+1;
       ptr_gap<=ptr_gap+1;
   end
   else if((!write_to_stack)&&(!stack_empty)&&read_from_stack)begin
       Data_out<=stack[read_ptr];
       read_ptr<=read_ptr+1;
       ptr_gap<=ptr_gap-1;
   end
   else if(write_to_stack &&read_from_stack&&stack_empty)begin
       stack[write_ptr]<=Data_in;
       write_ptr<=write_ptr+1;
       ptr_gap<=ptr_gap+1;
   end
   else if(write_to_stack &&read_from_stack&&stack_full)begin
       Data_out<=stack[read_ptr];
       read_ptr<=read_ptr+1;
       ptr_gap<=ptr_gap-1;
   end
   else if(write_to_stack&&read_from_stack&&(!stack_full)&&(!stack_empty))
   begin
       Data_out<=stack[read_ptr];
       stack[write_ptr]<=Data_in;
       read_ptr<=read_ptr+1;
       write_ptr<=write_ptr+1;
   end
endmodule