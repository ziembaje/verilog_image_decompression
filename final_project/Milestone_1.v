`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module Milestone_1 (
   input  logic            Clock_50,
   input  logic            Resetn, 

   input  logic            Initialize,
	input logic 	[15:0]   SRAM_read_data,
   //input  logic            Enable,
   
   output logic   [17:0]   SRAM_address,
   output logic   [15:0]   SRAM_write_data,
   output logic            SRAM_we_n,
	output logic 				sim_done,
	output M1_state_type M1_state
);

logic [7:0] ee_high;
logic [7:0] ee_low;
logic [7:0] eo_high;
logic [7:0] eo_low;
logic [7:0] oo_high;
logic [7:0] oo_low;

logic [15:0] ee_buff;
logic [15:0] eo_buff;
logic [15:0] oo_buff;


logic [17:0] Y_sram_address;
logic [17:0] U_sram_address;
logic [17:0] V_sram_address;
logic [17:0] write_address;


logic [63:0] U_MAC;
logic [63:0] V_MAC;

logic [7:0] V_prime;
logic [7:0] U_prime;

logic [15:0] Y_data;
logic [15:0] U_data;
logic [15:0] V_data;

logic [15:0] V_data_buff;
logic [15:0] U_data_buff;

logic [7:0] UR[5:0]; 
logic [7:0] VR[5:0];

logic [63:0] a_result;
logic [31:0] a_op1;
logic [31:0] a_op2;
logic [63:0] b_result;
logic [31:0] b_op1;
logic [31:0] b_op2;
logic [63:0] c_result;
logic [31:0] c_op1;
logic [31:0] c_op2;

logic [31:0] a_IN1;
logic [31:0] a_IN2;
logic [31:0] a_IN3;
logic [31:0] a_IN4;

logic [31:0] b_IN1;
logic [31:0] b_IN2;
logic [31:0] b_IN3;
logic [31:0] b_IN4;

logic [31:0] c_IN1;
logic [31:0] c_IN2;
logic [31:0] c_IN3;
logic [31:0] c_IN4;

logic [31:0] a_result_buff;
logic [31:0] b_result_buff;
logic [31:0] c_result_buff;

logic a_select;
logic b_select;
logic c_select;

//M1_state_type M1_state;

// *************Multiplier Assignments*************************
always_comb begin
	if (a_select == 1'b0) begin
		a_op1 = a_IN1;
		a_op2 = a_IN2;
	end
	else begin
		a_op1 = a_IN3;
		a_op2 = a_IN4;
	end
end
assign a_result = a_op1*a_op2;
		
always_comb begin
	if (b_select == 1'b0) begin
		b_op1 = b_IN1;
		b_op2 = b_IN2;
	end
	else begin
		b_op1 = b_IN3;
		b_op2 = b_IN4;
	end
end
assign b_result = b_op1*b_op2;

always_comb begin
	if (c_select == 1'b0) begin
		c_op1 = c_IN1;
		c_op2 = c_IN2;
	end
	else begin
		c_op1 = c_IN3;
		c_op2 = c_IN4;
	end
end
assign c_result = c_op1*c_op2;
// ************************************************************
		
always @(posedge Clock_50 or negedge Resetn) begin
	if (~Resetn) begin
	
		M1_state <= S_WAIT_FOR_PREVIOUS;
		SRAM_address <= 0;
		SRAM_we_n <= 1;
		
		a_IN1 <= 0;
		a_IN2 <= 0;
		b_IN1 <= 0;
		b_IN2 <= 0;
		c_IN1 <= 0;
		c_IN2 <= 0;
				
		Y_sram_address <= 0;
		U_sram_address <= 38400;
		V_sram_address <= 57600;
		
		write_address <= 146944;
		
		Y_data <= 0;
		U_data <= 0;
		V_data <= 0;
		
		
		a_result_buff <= 0;
		b_result_buff <= 0;
		c_result_buff <= 0;
		
		VR[0]	<= 0;
		VR[1] <= 0;
		VR[2] <= 0;
		VR[3] <= 0;
		VR[4] <= 0;
		VR[5] <= 0;
		
		UR[0]	<= 0;
		UR[1] <= 0;
		UR[2] <= 0;
		UR[3] <= 0;
		UR[4] <= 0;
		UR[5] <= 0;
		
		ee_high <= 0;
		ee_low <= 0;
		eo_high <= 0;
		eo_low <= 0;
		oo_high <= 0;
		oo_low <= 0;

		
		ee_buff <= 0;
		eo_buff <= 0;
		oo_buff <= 0;

		
		sim_done <= 0;
		
		U_data_buff <= 0;
		V_data_buff <= 0;
		
		U_MAC <= 0;
		V_MAC <= 0;
		U_prime <= 0;
		V_prime <= 0;
	//	VR <= 0;
	//	UR <= 0;
		
	end else begin
		case(M1_state)
			S_WAIT_FOR_PREVIOUS: begin
				if(Initialize == 1)
					M1_state <= S_LEAD_IN_START_1;
			end
			
			// ****************** Lead In Begin ****************** \\
			S_LEAD_IN_START_1: begin
				SRAM_address <= Y_sram_address;
				Y_sram_address <= Y_sram_address + 1'b1;
				SRAM_we_n <= 1'b1;
				M1_state <= S_2;
			end
			
			S_2: begin	// request V0, receive null
				SRAM_address <= V_sram_address;
				V_sram_address <= V_sram_address + 1'b1;
				M1_state <= S_3;
			end
			
			S_3: begin  // request U0, receive null
				SRAM_address <= U_sram_address;
				U_sram_address = U_sram_address + 1'b1;
				M1_state <= S_4;
			end
			
			S_4: begin // request V1, receive Y0
				SRAM_address <= V_sram_address;
				V_sram_address <= V_sram_address + 1'b1;
				Y_data 		 <= SRAM_read_data;

				M1_state <= S_5;
			end
			
			S_5: begin // request U1, receive V0
				SRAM_address <= U_sram_address;
				U_sram_address <= U_sram_address + 1'b1;
				V_data 		 <= SRAM_read_data;
			
				//ADDED NOT CHECKED MBOBUS
				VR[0]			 <= SRAM_read_data[15:8];
				
				M1_state <= S_6;
				
			end
			
			S_6: begin // request null, receive U0
				U_data <= SRAM_read_data;
				
				UR[0]	 <= SRAM_read_data[15:8];

				//ADDED NOT CHECKED MBOBUS
				VR[0]	<= V_data[15:8];
				VR[1] <= VR[0];
				
				
				
				a_select <= 0;
				a_IN1 <= 76284;
				a_IN2 <= Y_data[15:8] - 16;
				
				b_select <= 0;
				b_IN1 <= 104595;
				b_IN2 <= V_data[15:8] -128;
				
				c_select <= 0;
				c_IN1 <= 25624 ;
				//grab data from bus instead of buffer for U
				c_IN2 <= SRAM_read_data[15:8] - 128;			

				
				
				//c_IN2 <= U_data[15:8] - 128;

				M1_state <= S_7;
				
			end
			
			S_7: begin // request null, receive V1
				
				UR[0]	<= U_data[15:8];
				UR[1] <= UR[0];
	
				VR[0]	<= V_data[15:8];
				VR[1] <= VR[0];
				VR[2] <= VR[1];
				
				V_data <= SRAM_read_data;
				V_data_buff <= V_data;
				
				/*ee_buff[15:8] <= (a_result + b_result);// >> 16;
				ee_buff[7:0]  <= 8'd0;
				*/
				
				//ee_buff <= {(a_result + b_result), 8'd0};
				
				//red even pixel
				ee_high <= ((a_result + b_result) >> 16);
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_data[15:8] - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_data[15:8] - 128;
				
				M1_state <= S_8;
				
			end
			
			S_8: begin
			
				U_data <= SRAM_read_data;
				U_data_buff <= U_data;
				
				//ee_buff <= {ee_buff[15:8], (a_result_buff - a_result - c_result_buff)};
				
				//green even pixel
				ee_low <= (a_result_buff - a_result - c_result_buff) >> 16;
				
				//blue even pixel
				eo_high <= (a_result_buff + b_result) >> 16;
				
				//ee_buff[7:0] <= (a_result_buff - a_result - c_result_buff); //>> 16;
				b_result_buff <= b_result;
				
				UR[0]	<= U_data[15:8];
				UR[1] <= UR[0];
				UR[2] <= UR[1];
				
				VR[0]	<= V_data[15:8];
				VR[1] <= VR[0];
				VR[2] <= VR[1];
				VR[3] <= VR[2];
				
				M1_state <= S_9;
				
			end
			
			S_9: begin
			
				UR[0]	<= U_data[15:8];
				UR[1] <= UR[0];
				UR[2] <= UR[1];
				UR[3] <= UR[2];
						
				VR[0]	<= V_data[15:8];
				VR[1] <= VR[0];
				VR[2] <= VR[1];
				VR[3] <= VR[2];
				VR[4] <= VR[3];

				SRAM_we_n <= 1'b0;
				SRAM_address <= write_address;
				SRAM_write_data <= {ee_high, ee_low};
				write_address <= write_address + 18'b1;
	
				M1_state <= S_10;
				
			end
			
			S_10: begin
				
				SRAM_we_n <= 1'b1;
				
				UR[0]	<= U_data[15:8];
				UR[1] <= UR[0];
				UR[2] <= UR[1];
				UR[3] <= UR[2];
				UR[4] <= UR[3];

				VR[0]	<= V_data[15:8];
				VR[1] <= VR[0];
				VR[2] <= VR[1];
				VR[3] <= VR[2];
				VR[4] <= VR[3];
				VR[5] <= VR[4];
				
				M1_state <= S_11;
				
			end
			
			S_11: begin
				
				UR[0]	<= U_data[15:8];
				UR[1] <= UR[0];
				UR[2] <= UR[1];
				UR[3] <= UR[2];
				UR[4] <= UR[3];
				UR[5] <= UR[4];
						
				a_select <= 0;
				a_IN1 <= 21;
				a_IN2 <= VR[5];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= VR[4];
				
				c_select <= 0;
				c_IN1 <= 159 ;
				c_IN2 <= VR[3];		
				

				M1_state <= S_12;

			end
			
			S_12: begin
				
				V_MAC <= a_result - b_result + c_result;
				
				a_select <= 0;
				a_IN1 <= 159;
				a_IN2 <= VR[2];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= VR[1];
				
				c_select <= 0;
				c_IN1 <= 21;
				c_IN2 <= VR[0];

				M1_state <= S_13;
				
			end
			
			S_13: begin
				
				V_prime <= (V_MAC + a_result - b_result + c_result + 128) >> 8;
				
				a_select <= 0;
				a_IN1 <= 21;
				a_IN2 <= UR[5];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= UR[4];
				
				c_select <= 0;
				c_IN1 <= 159 ;
				c_IN2 <= UR[3];		
					
				M1_state <= S_14;
					
			end
			
			S_14: begin
				
				U_MAC <= a_result - b_result + c_result;
				
				a_select <= 0;
				a_IN1 <= 159;
				a_IN2 <= UR[2];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= UR[1];
				
				c_select <= 0;
				c_IN1 <= 21;
				c_IN2 <= UR[0];
				
				M1_state <= S_15;
		
			end
			
			S_15: begin
				
				SRAM_address <= Y_sram_address;
				Y_sram_address <= Y_sram_address + 1'b1;
			
				U_prime <= (U_MAC + a_result - b_result + c_result + 128) >> 8;
				
				a_select <= 0;
				a_IN1 <= 76284;
				a_IN2 <= Y_data[7:0] - 16;
				
				b_select <= 0;
				b_IN1 <= 104595;
				b_IN2 <= V_prime - 128;
				
				c_select <= 0;
				c_IN1 <= 25624 ;
				//grab data from bus instead of buffer for U
				c_IN2 <= ((U_MAC + a_result - b_result + c_result + 128) >> 8) - 128;			

				M1_state <= S_16;
				
			end
			
			S_16: begin
			
				eo_low <= ((a_result + b_result) >> 16);
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_prime - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_prime - 128;
				
				M1_state <= S_17;
				
			end
			
			S_17: begin
			
				oo_high <= (a_result_buff - a_result - c_result_buff) >> 16;
				oo_low <= (a_result_buff + b_result) >> 16;
				
				SRAM_address <= V_sram_address;
				V_sram_address <= V_sram_address + 1'b1;

				M1_state <= S_18;
								
			end
			
			S_18: begin
				
				Y_data <= SRAM_read_data;
				
				sim_done <= 1;
				
			end
			
			// ****************** Lead In End ****************** \\
			
			//default: M1_state <= S_LEADIN_IDLE;
		endcase
	end
end

//assign M1_current_state = M1_state;

endmodule