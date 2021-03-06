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
	output M1_state_type	   M1_state
	);
	
logic vga_enable;
logic [15:0] PIXEL_ROW_END;
logic [15:0] pixel_col_count;

logic data_req_flag;
logic UV_byte_flag;

logic [15:0] pixel_row_count;

logic [15:0] ee_high;
logic [15:0] ee_low;
logic [15:0] eo_high;
logic [15:0] eo_low;
logic [15:0] oo_high;
logic [15:0] oo_low;

logic [15:0] ee_buff;
logic [15:0] eo_buff;
logic [15:0] oo_buff;

logic [7:0] ee_high_writeout;
logic [7:0] oo_high_writeout;
logic [7:0] eo_high_writeout;

logic [7:0] ee_low_writeout;
logic [7:0] eo_low_writeout;
logic [7:0] oo_low_writeout;


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

logic [31:0] a_result;
logic [31:0] a_op1;
logic [31:0] a_op2;
logic [31:0] b_result;
logic [31:0] b_op1;
logic [31:0] b_op2;
logic [31:0] c_result;
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
	
		pixel_row_count <= 0;
		pixel_col_count <= 0;
		
		PIXEL_ROW_END <= 320;
		
		M1_state <= S_WAIT_FOR_PREVIOUS;
		SRAM_address <= 0;
		SRAM_we_n <= 1;
		
		data_req_flag <= 0;
		UV_byte_flag <= 0;
		
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
		
		vga_enable <= 0;
		
	end else begin
		case(M1_state)
			S_WAIT_FOR_PREVIOUS: begin
				vga_enable <= 1;
				if(Initialize == 1) begin
					M1_state <= S_LEAD_IN_START_1;
					vga_enable <= 0;
				end
					
			end
			
			// ****************** Lead In Begin ****************** \\
			S_LEAD_IN_START_1: begin
				SRAM_address <= Y_sram_address;
				Y_sram_address <= Y_sram_address + 1'b1;
				SRAM_we_n <= 1'b1;
				M1_state <= S_2;
				pixel_row_count <= 0;
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
				
				//flip UV byte flag to select second byte next time
				UV_byte_flag <= 1;
				
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
				
				VR[0]	<= V_data_buff[7:0];
				VR[1] <= VR[0];
				VR[2] <= VR[1];
				VR[3] <= VR[2];
				
				M1_state <= S_9;
				
			end
			
			S_9: begin
			
				UR[0]	<= U_data_buff[7:0];
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
				SRAM_write_data <= {ee_high_writeout, ee_low_writeout};
				write_address <= write_address + 18'b1;
				pixel_row_count <= pixel_row_count + 1;
	
				M1_state <= S_10;
				
			end
			
			S_10: begin
				
				SRAM_we_n <= 1'b1;
				
				UR[0]	<= U_data[15:8];
				UR[1] <= UR[0];
				UR[2] <= UR[1];
				UR[3] <= UR[2];
				UR[4] <= UR[3];

				VR[0]	<= V_data[7:0];
				VR[1] <= VR[0];
				VR[2] <= VR[1];
				VR[3] <= VR[2];
				VR[4] <= VR[3];
				VR[5] <= VR[4];
				
				M1_state <= S_11;
				
			end
			
			S_11: begin
				
				UR[0]	<= U_data[7:0];
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
			

				
				M1_state <= S_17;
				
			end
			
			S_17: begin
			
				a_select <= 0;
				a_IN1 <= 76284;
				a_IN2 <= Y_data[7:0] - 16;
				
				b_select <= 0;
				b_IN1 <= 104595;
				b_IN2 <= V_prime - 128;
				
				c_select <= 0;
				c_IN1 <= 25624 ;
				//grab data from bus instead of buffer for U
				c_IN2 <= U_prime - 128;		
			
			
			
				/*
				oo_high <= (a_result_buff - a_result - c_result_buff) >> 16;
				oo_low <= (a_result_buff + b_result) >> 16;
				*/
				
				SRAM_address <= V_sram_address;
				V_sram_address <= V_sram_address + 1'b1;

				M1_state <= S_18;
								
			end
			
			S_18: begin		
				
				//V_data_buff <= V_data;

				
				data_req_flag <= 1;
				
				Y_data <= SRAM_read_data;		
			
				
				eo_low <= ((a_result + b_result) >> 16);
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_prime - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_prime - 128;
				
				M1_state <= S_LOOP_0;
				
			end
			
			// ****************** Lead In End ****************** \\
			
			S_LOOP_0: begin
			
				oo_high <= (a_result_buff - a_result - c_result_buff) >> 16;
				oo_low <= (a_result_buff + b_result) >> 16;
				
				if (data_req_flag == 1) begin
					SRAM_address <= U_sram_address;
					U_sram_address <= U_sram_address + 1;
				end
				
				
				
				/*if ( data_req_flag == 1) begin


				
				end else begin
				
					b_IN2 <= V_data[15:8] - 128;
					c_IN2 <= U_data[15:8] - 128;	

				end*/
				
				
				if( UV_byte_flag == 0) begin
					b_IN2 <= V_data_buff[15:8] - 128;
					c_IN2 <= U_data_buff[15:8] - 128;	
					
				//	UV_byte_flag <= 1;
				
				end else begin
					b_IN2 <= V_data_buff[7:0] - 128;
					c_IN2 <= U_data_buff[7:0] - 128;	
					
				//	UV_byte_flag <= 0;
				
				end
				
				a_select <= 0;
				a_IN1 <= 76284;
				a_IN2 <= Y_data[15:8] - 16;
				
				b_select <= 0;
				b_IN1 <= 104595;
				
			
				c_select <= 0;
				c_IN1 <= 25624;

				M1_state <= S_LOOP_1;

			end
			
			S_LOOP_1: begin
			
				//store Red even pixel
				ee_high <= ((a_result + b_result) >> 16);
			
				// write previos EO values to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {eo_high_writeout, eo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				
				if (data_req_flag == 1) begin
					V_data <= SRAM_read_data;
					//buffer Vdata
					V_data_buff <= V_data;
					
					// buffer in new V data
					VR[0]	<= SRAM_read_data[15:8];
					VR[1] <= VR[0];
					VR[2] <= VR[1];
					VR[3] <= VR[2];
					VR[4] <= VR[3];
					VR[5] <= VR[4];
					
				end

				//store multiplier results
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				if(UV_byte_flag == 0) begin
					
					a_IN2 <= V_data_buff[15:8] - 128;
					b_IN2 <= U_data_buff[15:8] - 128;

					UV_byte_flag <= 1;
				
				end else begin
					a_IN2 <= V_data_buff[7:0] - 128;
					b_IN2 <= U_data_buff[7:0] - 128;			
				
					UV_byte_flag <= 0;

				end
				
				a_select <= 0;
				a_IN1 <= 53281;
				
				b_select <= 0;
				b_IN1 <= 132251;
				
				M1_state <= S_LOOP_2;
			
			end
			
			S_LOOP_2: begin
				
				//store green even
				ee_low <= (a_result_buff - a_result - c_result_buff) >> 16;
				//store blue even
				eo_high <= (a_result_buff + b_result) >> 16;
			
				// write previous odd pixel to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {oo_high_writeout, oo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				

				a_select <= 0;
				a_IN1 <= 21;
				a_IN2 <= VR[5];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= VR[4];
				
				c_select <= 0;
				c_IN1 <= 159 ;
				c_IN2 <= VR[3];		
				
				
				M1_state <= S_LOOP_3;
			
			end
			
			S_LOOP_3: begin
				
				V_MAC <= a_result - b_result + c_result;
			
			
				if (data_req_flag == 1) begin
					U_data_buff <= U_data;
					U_data <= SRAM_read_data;	
					
					
					
					UR[0]	<= SRAM_read_data[15:8];
					UR[1] <= UR[0];
					UR[2] <= UR[1];
					UR[3] <= UR[2];
					UR[4] <= UR[3];
					UR[5] <= UR[4];
				end

				

							
				a_select <= 0;
				a_IN1 <= 159;
				a_IN2 <= VR[2];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= VR[1];
				
				c_select <= 0;
				c_IN1 <= 21;
				c_IN2 <= VR[0];
			
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {ee_high_writeout, ee_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
			
				M1_state <= S_LOOP_4;
			
			end
			
			S_LOOP_4: begin
			
				V_prime <= (V_MAC + a_result - b_result + c_result + 128) >> 8;				

			
				SRAM_we_n <= 1;
				
				SRAM_address <= Y_sram_address;
				Y_sram_address <= Y_sram_address + 1;
				
				if (data_req_flag == 1) begin
					VR[0]	<= V_data[7:0];
					VR[1] <= VR[0];
					VR[2] <= VR[1];
					VR[3] <= VR[2];
					VR[4] <= VR[3];
					VR[5] <= VR[4];
				end
				
				
				
		
				a_select <= 0;
				a_IN1 <= 21;
				a_IN2 <= UR[5];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= UR[4];
				
				c_select <= 0;
				c_IN1 <= 159 ;
				c_IN2 <= UR[3];

				
				M1_state <= S_LOOP_5;
			
			end			
			
			S_LOOP_5: begin
			
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

				M1_state <= S_LOOP_6;
			end	
	
			
			S_LOOP_6: begin
			
				if( data_req_flag == 0) begin
					SRAM_address <= V_sram_address;
					V_sram_address <= V_sram_address + 1;
				end
			
				U_prime <= (U_MAC + a_result - b_result + c_result + 128) >> 8;			
					
				if (data_req_flag == 1) begin
					UR[0]	<= U_data[7:0];
					UR[1] <= UR[0];
					UR[2] <= UR[1];
					UR[3] <= UR[2];
					UR[4] <= UR[3];
					UR[5] <= UR[4];				
				end

				
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
			
			
				M1_state <= S_LOOP_7;
			end	
	
			S_LOOP_7: begin
			
				Y_data <= SRAM_read_data;
			
				eo_low <= ((a_result + b_result) >> 16);
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_prime - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_prime - 128;
				
				data_req_flag <= ~data_req_flag;
				
				
				if(pixel_row_count < 468) begin
					
					M1_state <= S_LOOP_0;
					
				end else begin
				
					M1_state <= S_LO_0;
					//sim_done <= 1;

				end
				
				//LOOK AT OVERLAP DIFFERENCE BETWEEN LEAD IN 0 AND LOOP 2 0
				

			end		
			
			//LEAD OUT
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//////////////////////////////////////////// DAMN, SON ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//
			
			
			
			S_LO_0: begin
			
				oo_high <= (a_result_buff - a_result - c_result_buff) >> 16;
				oo_low <= (a_result_buff + b_result) >> 16;
				
				
				
				//////////////////////// check buffer position
				a_select <= 0;
				a_IN1 <= 76284;
				a_IN2 <= Y_data[15:8] - 16;
				
				b_select <= 0;
				b_IN1 <= 104595;
				b_IN2 <= V_data_buff[7:0] - 128;

			
				c_select <= 0;
				c_IN1 <= 25624;
				c_IN2 <= U_data_buff[7:0] - 128;	
				
			
				VR[0]	<= VR[0];
				VR[1] <= VR[0];
				VR[2] <= VR[1];
				VR[3] <= VR[2];
				VR[4] <= VR[3];
				VR[5] <= VR[4];
			
				M1_state <= S_LO_1;
			
			end
			
			S_LO_1: begin
				
				UR[0]	<= UR[0];
				UR[1] <= UR[0];
				UR[2] <= UR[1];
				UR[3] <= UR[2];
				UR[4] <= UR[3];
				UR[5] <= UR[4];
				
				ee_high <= ((a_result + b_result) >> 16);
			
				// write previos EO values to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {eo_high_writeout, eo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
	

				//store multiplier results
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_data_buff[7:0] - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_data_buff[7:0] - 128;
				
				M1_state <= S_LO_2;
				
			
			
			end
			
			S_LO_2: begin
				
				ee_low <= (a_result_buff - a_result - c_result_buff) >> 16;
			
				eo_high <= (a_result_buff + b_result) >> 16;
			
				// write previous odd pixel to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {oo_high_writeout, oo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				

				a_select <= 0;
				a_IN1 <= 21;
				a_IN2 <= VR[5];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= VR[4];
				
				c_select <= 0;
				c_IN1 <= 159 ;
				c_IN2 <= VR[3];		
				
				
				M1_state <= S_LO_3;


				
			end
			
			S_LO_3: begin
			
				
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
			
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {ee_high_writeout, ee_low_writeout};
				pixel_row_count <= pixel_row_count + 1;


				M1_state <= S_LO_4;
			end
			
			S_LO_4: begin
			
				SRAM_we_n <= 1;

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
			

			
				SRAM_address <= Y_sram_address;
				Y_sram_address <= Y_sram_address + 1;
				
				M1_state <= S_LO_5;
			
			end
			
			S_LO_5: begin
			
			
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

			
			
				M1_state <= S_LO_6;
			end
			
			S_LO_6: begin
				
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
			
				M1_state <= S_LO_7;
			end
			
			S_LO_7: begin
			
				Y_data <= SRAM_read_data;
			
				eo_low <= ((a_result + b_result) >> 16);
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_prime - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_prime - 128;
			
			
				M1_state <= S_LO_8;
				
			end
			
			///////////////////////////////////////////////////////////////////////////////////////////RELOOP////////////////////////////////////////////
			
			S_LO_8: begin //0
			
				oo_high <= (a_result_buff - a_result - c_result_buff) >> 16;
				oo_low <= (a_result_buff + b_result) >> 16;
				
				
				
				//////////////////////// check buffer position
				a_select <= 0;
				a_IN1 <= 76284;
				a_IN2 <= Y_data[15:8] - 16;
				
				b_select <= 0;
				b_IN1 <= 104595;
				b_IN2 <= V_data[15:8] - 128;

			
				c_select <= 0;
				c_IN1 <= 25624;
				c_IN2 <= U_data[15:8] - 128;	
				
			
				VR[0]	<= VR[0];
				VR[1] <= VR[0];
				VR[2] <= VR[0];
				VR[3] <= VR[2];
				VR[4] <= VR[3];
				VR[5] <= VR[4];
			
			
				M1_state <= S_LO_9;
			
			end
			
			S_LO_9: begin // 1
				
				ee_high <= ((a_result + b_result) >> 16);	
			
				// write previos EO values to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {eo_high_writeout, eo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
					
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_data[15:8] - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_data[15:8] - 128;
				
			
				UR[0]	<= UR[0];
				UR[1] <= UR[0];
				UR[2] <= UR[0];
				UR[3] <= UR[2];
				UR[4] <= UR[3];
				UR[5] <= UR[4];
				
				M1_state <= S_LO_10;
			
			end
			
			S_LO_10: begin // 2
			
				//store green even
				ee_low <= (a_result_buff - a_result - c_result_buff) >> 16;
				//store blue even
				eo_high <= (a_result_buff + b_result) >> 16;
			
				// write previous odd pixel to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {oo_high_writeout, oo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				

				a_select <= 0;
				a_IN1 <= 21;
				a_IN2 <= VR[5];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= VR[4];
				
				c_select <= 0;
				c_IN1 <= 159 ;
				c_IN2 <= VR[3];	
				
			
				M1_state <= S_LO_11;
			
			end
			
			S_LO_11: begin // 3
			
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
			
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {ee_high_writeout, ee_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
			
				M1_state <= S_LO_12;
			
			end
			
			S_LO_12: begin // 4
			
				SRAM_we_n <= 1;

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
			

			
				SRAM_address <= Y_sram_address;
				Y_sram_address <= Y_sram_address + 1;
			
				M1_state <= S_LO_13;
			
			end
			
			S_LO_13: begin // 5
			
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
			
				M1_state <= S_LO_14;


			end
			
			S_LO_14: begin // 6
			
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
			
				
				M1_state <= S_LO_15;

			end
			
			S_LO_15: begin // 7 
			
				Y_data <= SRAM_read_data;
			
				eo_low <= ((a_result + b_result) >> 16);
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_prime - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_prime - 128;
								
								
				M1_state <= S_LO_16;

			
			
			end
			
			S_LO_16: begin // 0
			
				oo_high <= (a_result_buff - a_result - c_result_buff) >> 16;
				oo_low <= (a_result_buff + b_result) >> 16;
				
				
				
				//////////////////////// check buffer position
				a_select <= 0;
				a_IN1 <= 76284;
				a_IN2 <= Y_data[15:8] - 16;
				
				b_select <= 0;
				b_IN1 <= 104595;
				b_IN2 <= V_data[7:0] - 128;

			
				c_select <= 0;
				c_IN1 <= 25624;
				c_IN2 <= U_data[7:0] - 128;	
				
			
				VR[0]	<= VR[0];
				VR[1] <= VR[0];
				VR[2] <= VR[0];
				VR[3] <= VR[0];
				VR[4] <= VR[3];
				VR[5] <= VR[4];
			
			
				M1_state <= S_LO_17;
		
			end
			
			S_LO_17: begin // 1
				
				ee_high <= ((a_result + b_result) >> 16);	
			
				// write previos EO values to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {eo_high_writeout, eo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
			a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_data[7:0] - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_data[7:0] - 128;
				
				UR[0]	<= UR[0];
				UR[1] <= UR[0];
				UR[2] <= UR[0];
				UR[3] <= UR[0];
				UR[4] <= UR[3];
				UR[5] <= UR[4];
				
				M1_state <= S_LO_18;

			
			end
			
			S_LO_18: begin // 2
				
					//store green even
				ee_low <= (a_result_buff - a_result - c_result_buff) >> 16;
				//store blue even
				eo_high <= (a_result_buff + b_result) >> 16;
			
				// write previous odd pixel to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {oo_high_writeout, oo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				

				a_select <= 0;
				a_IN1 <= 21;
				a_IN2 <= VR[5];
				
				b_select <= 0;
				b_IN1 <= 52;
				b_IN2 <= VR[4];
				
				c_select <= 0;
				c_IN1 <= 159 ;
				c_IN2 <= VR[3];		
				
				
				M1_state <= S_LO_19;

			end
			
			S_LO_19: begin // 3
				//sim_done <= 1;
				
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
				
			
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {ee_high_writeout, ee_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				M1_state <= S_LO_20;
				
			end
			
			S_LO_20: begin // 4
			
				SRAM_we_n <= 1;

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
				
				
				M1_state <= S_LO_21;
			
			end
			
			S_LO_21: begin // 5
			
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
				
				
				M1_state <= S_LO_22;

			end
			
			S_LO_22: begin // 6
			
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
				
				
				M1_state <= S_LO_23;
			
			end
			
			S_LO_23: begin // 7
			
			
				eo_low <= ((a_result + b_result) >> 16);
				
				a_result_buff <= a_result;
				c_result_buff <= c_result;
				
				a_select <= 0;
				a_IN1 <= 53281;
				a_IN2 <= V_prime - 128;
				
				b_select <= 0;
				b_IN1 <= 132251;
				b_IN2 <= U_prime - 128;
				
				
				M1_state <= S_LO_24;

			end
			
			
			S_LO_24: begin // 0
				oo_high <= (a_result_buff - a_result - c_result_buff) >> 16;
				oo_low <= (a_result_buff + b_result) >> 16;
				
				M1_state <= S_LO_25;
				
			end
			
			S_LO_25: begin // 1
				
				ee_high <= ((a_result + b_result) >> 16);	
			
				// write previos EO values to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {eo_high_writeout, eo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				
				
				M1_state <= S_LO_26;
			end
			
			S_LO_26: begin // 
				
				ee_low <= (a_result_buff - a_result - c_result_buff) >> 16;
				//store blue even
				eo_high <= (a_result_buff + b_result) >> 16;
			
				// write previous odd pixel to SRAM
				SRAM_we_n <= 0;
				SRAM_address <= write_address;
				write_address <= write_address + 1;
				SRAM_write_data <= {oo_high_writeout, oo_low_writeout};
				pixel_row_count <= pixel_row_count + 1;
				
				
				M1_state <= S_LO_27;
			end
			
			S_LO_27: begin // 
			
				SRAM_we_n <= 1;
				
			V_sram_address <= V_sram_address - 1;
				//U_sram_address <= U_sram_address - 1;
				
				if (pixel_col_count == 239) begin
				
					vga_enable <= 1;
					sim_done <= 1;
					M1_state <= S_WAIT_FOR_PREVIOUS;

					
				end else begin
				
					pixel_col_count <= pixel_col_count + 1;
					M1_state <= S_LEAD_IN_START_1;

				
				end
				
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
				
				Y_data <= 0;
				U_data <= 0;
				V_data <= 0;
				
				U_data_buff <= 0;
				V_data_buff <= 0;

			end
			
									
			//default: M1_state <= S_LEADIN_IDLE;
		endcase
	end
end

always_comb begin
	// ee
	if (ee_high[15] == 1)		ee_high_writeout = 8'd0;
	else if (|ee_high[15:8])	ee_high_writeout = 8'hff;
	else								ee_high_writeout = ee_high[7:0];
	
	if (ee_low[15] == 1)			ee_low_writeout = 8'd0;
	else if (|ee_low[15:8])		ee_low_writeout = 8'hff;
	else								ee_low_writeout = ee_low[7:0];
	
	// eo
	if (eo_high[15] == 1)		eo_high_writeout = 8'd0;
	else if (|eo_high[15:8])	eo_high_writeout = 8'hff;
	else								eo_high_writeout = eo_high[7:0];
	
	if (eo_low[15] == 1)			eo_low_writeout = 8'd0;
	else if (|eo_low[15:8])		eo_low_writeout = 8'hff;
	else								eo_low_writeout = eo_low[7:0];

	// oo
	if (oo_high[15] == 1)		oo_high_writeout = 8'd0;
	else if (|oo_high[15:8])	oo_high_writeout = 8'hff;
	else								oo_high_writeout = oo_high[7:0];
	
	if (oo_low[15] == 1)			oo_low_writeout = 8'd0;
	else if (|oo_low[15:8])		oo_low_writeout = 8'hff;
	else								oo_low_writeout = oo_low[7:0];
	
end

//assign M1_current_state = M1_state;

endmodule