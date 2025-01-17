`timescale 1ns / 1ps
`include "xversat.vh"

module xunitF #(
         parameter DELAY_W = 10,
         parameter DATA_W = 32
              )
    (
    //control
    input               clk,
    input               rst,
    
    input               run,

    //input / output data
    input [DATA_W-1:0]  in0,
    input [DATA_W-1:0]  in1,
    input [DATA_W-1:0]  in2,
    input [DATA_W-1:0]  in3,
    input [DATA_W-1:0]  in4,
    input [DATA_W-1:0]  in5,
    input [DATA_W-1:0]  in6,
    input [DATA_W-1:0]  in7,

    input [DATA_W-1:0]  in8,
    input [DATA_W-1:0]  in9,

    output [DATA_W-1:0] out0,
    output [DATA_W-1:0] out1,
    output [DATA_W-1:0] out2,
    output [DATA_W-1:0] out3,
    output [DATA_W-1:0] out4,
    output [DATA_W-1:0] out5,
    output [DATA_W-1:0] out6,
    output [DATA_W-1:0] out7,

    //configurations
    input [7:0]         delay0 // Encodes delay
    );

reg [7:0] delay;
reg [0:0] latency;
reg [31:0] a,b,c,d,e,f,g,h;

assign out0 = a;
assign out1 = b;
assign out2 = c;
assign out3 = d;
assign out4 = e;
assign out5 = f;
assign out6 = g;
assign out7 = h;

wire [31:0] w = in8;
wire [31:0] k = in9;

function [31:0] ROTR_32(input [31:0] x,input [4:0] c);
begin
   ROTR_32 = (((x) >> (c)) | ((x) << (32 - (c))));
end
endfunction

function [31:0] Ch(input [31:0] x,y,z);
begin
   Ch = (((x) & (y)) ^ (~(x) & (z)));
end
endfunction

function [31:0] Maj(input [31:0] x,y,z); 
begin 
   Maj = (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)));
end
endfunction

function [31:0] Sigma0_32(input [31:0] x);
begin
   Sigma0_32 = (ROTR_32(x, 2) ^ ROTR_32(x,13) ^ ROTR_32(x,22));
end
endfunction

function [31:0] Sigma1_32(input [31:0] x);
begin
   Sigma1_32 = (ROTR_32(x, 6) ^ ROTR_32(x,11) ^ ROTR_32(x,25));
end
endfunction

wire [31:0] T1 = h + Sigma1_32(e) + Ch(e,f,g) + k + w;
wire [31:0] T2 = Sigma0_32(a) + Maj(a,b,c);

wire [31:0] T1_init = in7 + Sigma1_32(in4) + Ch(in4,in5,in6) + k + w;
wire [31:0] T2_init = Sigma0_32(in0) + Maj(in0,in1,in2);

always @(posedge clk,posedge rst)
begin
   if(rst) begin
      delay <= 0;
      a <= 0;
      b <= 0;
      c <= 0;
      d <= 0;
      e <= 0;
      f <= 0;
      g <= 0;
      h <= 0;
   end else if(run) begin
      delay <= delay0; 
      latency <= 1'h1;
   end else if(|delay) begin
      delay <= delay - 1;
   end else begin
      if(|latency) begin
         latency <= latency - 1;
      end

      if(latency == 1'h1) begin
         a <= T1_init + T2_init;
         b <= in0;
         c <= in1;
         d <= in2;
         e <= in3 + T1_init;
         f <= in4;
         g <= in5;
         h <= in6;
      end

      if(latency == 0) begin
         a <= T1 + T2;
         b <= a;
         c <= b;
         d <= c;
         e <= d + T1;
         f <= e;
         g <= f;
         h <= g;
      end
   end
end

endmodule
