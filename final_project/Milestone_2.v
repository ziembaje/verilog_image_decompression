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
		output logic [6:0] READ_ADDRESS_O,
		output logic [6:0] WRITE_ADDRESS_O,		
		output logic [31:0] READ_DATA_A_O [1:0],
		output logic [31:0] READ_DATA_B_O [1:0],
		output logic [31:0] WRITE_DATA_B_O [1:0],
		output logic WRITE_ENABLE_B_O [1:0],
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
	

end

endmodule


