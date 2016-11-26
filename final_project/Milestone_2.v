/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module Milestone_2 (

		input logic CLOCK_I,
		input logic RESETN_I,
		
		input logic 	[15:0]   SRAM_read_data,
		//input  logic            Enable,
   
		output logic   [17:0]   SRAM_address,
		output logic   [15:0]   SRAM_write_data,
		output logic            SRAM_we_n,
		
		/*output logic [6:0] READ_ADDRESS_O,
		output logic [6:0] WRITE_ADDRESS_O,		
		output logic [31:0] READ_DATA_A_O [1:0],
		output logic [31:0] READ_DATA_B_O [1:0],
		output logic [31:0] WRITE_DATA_B_O [1:0],
		output logic WRITE_ENABLE_B_O [1:0],*/
		input logic Initialize,
		output logic sim_done,
		
		output M2_state_type M2_state
);


// FSM to control the read and write sequence
logic [6:0] address_a[1:0], address_b[1:0];
logic [31:0] write_data_a [1:0];
logic [31:0] write_data_b [1:0];
logic write_enable_a [1:0];
logic write_enable_b [1:0];
logic [31:0] read_data_a [1:0];
logic [31:0] read_data_b [1:0];


logic [17:0] Y_sram_address;
logic [17:0] U_sram_address;
logic [17:0] V_sram_address;
logic [17:0] write_address;

logic [17:0] preIDCT_base_address;

logic [6:0] sprime_write_address;
logic [6:0] sprime_read_address;

logic [5:0] sprime_write_counter;


// Instantiate RAM1
dual_port_RAM1 dual_port_RAM_inst1 (

	.address_a ( address_a[1] ),
	.address_b ( address_b[1] ),
	.clock ( CLOCK_I ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	
);

// Instantiate RAM0
dual_port_RAM0 dual_port_RAM_inst0 (

	.address_a ( address_a[0] ),
	.address_b ( address_b[0] ),
	.clock ( CLOCK_I ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	
);


// FSM to control the read and write sequence
always_ff @ (posedge CLOCK_I or negedge RESETN_I) begin
	
	if (~RESETN_I) begin
	
	
		Y_sram_address <= 0;
		U_sram_address <= 38400;
		V_sram_address <= 57600;
		
		
		sprime_write_address <= 0;
		sprime_write_counter <= 0;

		sprime_read_address <=0;
		
		address_a[1] <= 0;
		address_a[0] <= 0;
		address_b[1] <= 0;
		address_b[0] <= 0;
		
		write_data_a[1] <= 0;
		write_data_a[0] <= 0;
		write_data_b[1] <= 0;
		write_data_b[0] <= 0;
		
		/*read_data_a[1] <= 0;
		read_data_a[0] <= 0;
		read_data_b[1] <= 0;
		read_data_b[0] <= 0;*/
		
		write_enable_a[1] <= 1;
		write_enable_a[0] <= 1;
		write_enable_b[1] <= 1;
		write_enable_b[0] <= 1;
		
		SRAM_we_n <= 1;
		
		write_address <= 146944;
		
		preIDCT_base_address <= 76800;
	
		M2_state <= S_WAIT_FOR_BEGIN;
	
	end else begin
	
	
		
		case(M2_state)
		
			S_WAIT_FOR_BEGIN: begin
			
				SRAM_we_n <= 1;
				
				if (Initialize == 1) begin
				
					M2_state <= S_FETCH_1;
					
				end
				
				
			end
			
			S_FETCH_1: begin
			
				SRAM_address <= preIDCT_base_address;
				preIDCT_base_address <= preIDCT_base_address + 1;
				
			
				M2_state <= S_FETCH_2;
				
			end
			
			S_FETCH_2: begin
			
				SRAM_address <= preIDCT_base_address;
				preIDCT_base_address <= preIDCT_base_address + 1;
		
		
				M2_state <= S_FETCH_3;
				
			end

			S_FETCH_3: begin
			
				SRAM_address <= preIDCT_base_address;
				preIDCT_base_address <= preIDCT_base_address + 1;
		
		
				M2_state <= S_BLOCK1_1;
				
			end
			
			/***************************** LOOPING STATES **************************************/
			S_BLOCK1_1: begin
			
				SRAM_address <= preIDCT_base_address;
				preIDCT_base_address <= preIDCT_base_address + 1;
			
				address_a[1] <= sprime_write_address;
				sprime_write_address <= sprime_write_address + 1;
				write_data_a[1] <= {{16{SRAM_read_data[15]}}, SRAM_read_data[15:0]};			
				write_enable_a[1] <= 1;
				
				sprime_write_counter <= sprime_write_counter + 1;
				
		
				M2_state <= S_BLOCK1_2;
				
			end
			
			S_BLOCK1_2: begin
			
				address_a[1] <= sprime_write_address;
				sprime_write_address <= sprime_write_address + 1;
				write_data_a[1] <= {{16{SRAM_read_data[15]}}, SRAM_read_data[15:0]};			
				write_enable_a[1] <= 1;
				
				sprime_write_counter <= sprime_write_counter + 1;
				
				if(sprime_write_counter == 61) begin 
					
					M2_state <= S_BLOCK1_3;
					
				end else begin
				
					SRAM_address <= preIDCT_base_address;
					preIDCT_base_address <= preIDCT_base_address + 1;
					
				
					M2_state <= S_BLOCK1_1;
					
				end
			
				
			end
			
			/***************************** LOOPING STATES **************************************/

			
			S_BLOCK1_3: begin
			
				address_a[1] <= sprime_write_address;
				sprime_write_address <= sprime_write_address + 1;
				write_data_a[1] <= {{16{SRAM_read_data[15]}}, SRAM_read_data[15:0]};			
				write_enable_a[1] <= 1;
				
				
				M2_state <= S_BLOCK1_4;
			
			end
			
			S_BLOCK1_4: begin
			
				address_a[1] <= sprime_write_address;
				sprime_write_address <= sprime_write_address + 1;
				write_data_a[1] <= {{16{SRAM_read_data[15]}}, SRAM_read_data[15:0]};			
				write_enable_a[1] <= 1;
			
				M2_state <= S_BLOCK1_5;
				
				sim_done <= 1;

			
			end

				
	
			
		default: M2_state <= M2_state;
			
		endcase
		
	

	
	end

end

endmodule


