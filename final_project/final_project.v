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

// This is the top module
// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module final_project(
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[3:0] PUSH_BUTTON_I,           // pushbuttons
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// 7 segment displays/LEDs           ////////////
		output logic[6:0] SEVEN_SEGMENT_N_O[7:0], // 8 seven segment displays
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs

		/////// VGA interface                     ////////////
		output logic VGA_CLOCK_O,                 // VGA clock
		output logic VGA_HSYNC_O,                 // VGA H_SYNC
		output logic VGA_VSYNC_O,                 // VGA V_SYNC
		output logic VGA_BLANK_O,                 // VGA BLANK
		output logic VGA_SYNC_O,                  // VGA SYNC
		output logic[9:0] VGA_RED_O,              // VGA red
		output logic[9:0] VGA_GREEN_O,            // VGA green
		output logic[9:0] VGA_BLUE_O,             // VGA blue
		
		/////// SRAM Interface                    ////////////
		inout wire[15:0] SRAM_DATA_IO,            // SRAM data bus 16 bits
		output logic[17:0] SRAM_ADDRESS_O,        // SRAM address bus 18 bits
		output logic SRAM_UB_N_O,                 // SRAM high-byte data mask 
		output logic SRAM_LB_N_O,                 // SRAM low-byte data mask 
		output logic SRAM_WE_N_O,                 // SRAM write enable
		output logic SRAM_CE_N_O,                 // SRAM chip enable
		output logic SRAM_OE_N_O,                 // SRAM output logic enable
		
		/////// UART                              ////////////
		input logic UART_RX_I,                    // UART receive signal
		output logic UART_TX_O                // UART transmit signal
		
		////// M2 Additions:		
		// all output logic done
		
		
		
);
	
logic resetn;

top_state_type top_state;

logic M1_done;
logic M2_done;
logic done;

assign done = M1_done || M2_done;

// For Push button
logic [3:0] PB_pushed;
// For VGA SRAM interface
logic VGA_enable;
logic [17:0] VGA_base_address;
logic [17:0] VGA_SRAM_address;
logic VGA_adjust;

// For SRAM
logic sram_wen_temp;
logic [17:0] sram_address_temp;
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;

// For UART SRAM interface
logic UART_rx_enable;
logic UART_rx_initialize;
logic [17:0] UART_SRAM_address;
logic [15:0] UART_SRAM_write_data;
logic UART_SRAM_we_n;
logic [25:0] UART_timer;

logic [6:0] value_7_segment [7:0];

//milestone 1
logic [17:0] M1_SRAM_address;
logic [15:0] M1_SRAM_write_data;
logic M1_SRAM_we_n;

logic [17:0] M2_SRAM_address;
logic [15:0] M2_SRAM_write_data;
logic M2_SRAM_we_n;


// For error detection in UART
logic [3:0] Frame_error;

// For disabling UART transmit
assign UART_TX_O = 1'b1;

assign resetn = ~SWITCH_I[17] && SRAM_ready;

//************** New variables ************* \\
logic [17:0] Y_sram_address;
logic [17:0] U_sram_address;
logic [17:0] V_sram_address;

logic [17:0] RGB_sram_address;

logic lead_in_begin_M1;
logic lead_in_begin_M2;

M1_state_type M1_current_state;
M2_state_type M2_current_state;

// Push Button unit
PB_Controller PB_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PB_signal(PUSH_BUTTON_I),	
	.PB_pushed(PB_pushed)
);

// VGA SRAM interface
VGA_SRAM_interface VGA_unit (
	.Clock(CLOCK_50_I),
	.Resetn(resetn),
	.VGA_enable(VGA_enable),
	.VGA_adjust(VGA_adjust),
   
	// For accessing SRAM
	.SRAM_base_address(VGA_base_address),
	.SRAM_address(VGA_SRAM_address),
	.SRAM_read_data(SRAM_read_data),
   
	// To VGA pins
	.VGA_CLOCK_O(VGA_CLOCK_O),
	.VGA_HSYNC_O(VGA_HSYNC_O),
	.VGA_VSYNC_O(VGA_VSYNC_O),
	.VGA_BLANK_O(VGA_BLANK_O),
	.VGA_SYNC_O(VGA_SYNC_O),
	.VGA_RED_O(VGA_RED_O),
	.VGA_GREEN_O(VGA_GREEN_O),
	.VGA_BLUE_O(VGA_BLUE_O)
);

// UART SRAM interface
UART_SRAM_interface UART_unit(
	.Clock(CLOCK_50_I),
	.Resetn(resetn), 
   
	.UART_RX_I(UART_RX_I),
	.Initialize(UART_rx_initialize),
	.Enable(UART_rx_enable),
   
	// For accessing SRAM
	.SRAM_address(UART_SRAM_address),
	.SRAM_write_data(UART_SRAM_write_data),
	.SRAM_we_n(UART_SRAM_we_n),
	.Frame_error(Frame_error)
);

// SRAM unit
SRAM_Controller SRAM_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.SRAM_address(SRAM_address),
	.SRAM_write_data(SRAM_write_data),
	.SRAM_we_n(SRAM_we_n),
	.SRAM_read_data(SRAM_read_data),		
	.SRAM_ready(SRAM_ready),
		
	// To the SRAM pins
	.SRAM_DATA_IO(SRAM_DATA_IO),
	.SRAM_ADDRESS_O(SRAM_ADDRESS_O),
	.SRAM_UB_N_O(SRAM_UB_N_O),
	.SRAM_LB_N_O(SRAM_LB_N_O),
	.SRAM_WE_N_O(SRAM_WE_N_O),
	.SRAM_CE_N_O(SRAM_CE_N_O),
	.SRAM_OE_N_O(SRAM_OE_N_O)
);

Milestone_1 M1_unit (
	
	//inputs
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn), 
	.Initialize(lead_in_begin_M1),
	.SRAM_read_data(SRAM_read_data),
	
	//outputs
	.SRAM_address(M1_SRAM_address),
	.SRAM_write_data(M1_SRAM_write_data),
	.SRAM_we_n(M1_SRAM_we_n),
	.M1_state(M1_current_state),
	.sim_done(M1_done)

);

Milestone_2 M2_unit (
		
		//inputs
		.CLOCK_I(CLOCK_50_I),
		.RESETN_I(resetn),
		.Initialize(lead_in_begin_M2),
		.SRAM_read_data(SRAM_read_data),

		
		//outputs
		.SRAM_address(M2_SRAM_address),
		.SRAM_write_data(M2_SRAM_write_data),
		.SRAM_we_n(M2_SRAM_we_n),
		
		
		
		.sim_done(M2_done)
);

always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		top_state <= S_IDLE;
		
		UART_rx_initialize <= 1'b0;
		UART_rx_enable <= 1'b0;
		
		// MBOBUS
		 UART_timer <= 26'd0; //original
		//UART_timer <= 26'd49999990; //simulation (500000000 cycles takes to long in simulation so we just increase the counter)
		
		VGA_enable <= 1'b1;
		lead_in_begin_M1 <= 0;
		lead_in_begin_M2 <= 0;
		
	end else begin
		UART_rx_initialize <= 1'b0; 
		UART_rx_enable <= 1'b0; 
		//UART_timer <= 26'd0;
		
		// Timer for timeout on UART
		// This counter reset itself every time a new data is received on UART
		if (UART_rx_initialize | ~UART_SRAM_we_n) UART_timer <= 26'd0;
		else UART_timer <= UART_timer + 26'd1;

		case (top_state)
		S_IDLE: begin
			VGA_enable <= 1'b1;// NOW ENABLE MILESTONE 1 ENABLE VGA  MILESTONE 1 IS COMPLETE!!!
			//AFTER
			
			/////////////////////// FOR M2 SIMULATION //////////////////
			lead_in_begin_M2 <= 1; //remove when running on board
			top_state <= S_M2; // remove when running on board

			
			/////////////////////// FOR M1 SIMULATION //////////////////
			//lead_in_begin_M1 <= 1; //remove when running on board
			//top_state <= S_M1; // remove when running on board

			
			if (~UART_RX_I | PB_pushed[0]) begin
				// UART detected a signal, or PB0 is pressed
				UART_rx_initialize <= 1'b1;
				
				VGA_enable <= 1'b0;
								
				top_state <= S_ENABLE_UART_RX;
			end
		end
		
		
		S_ENABLE_UART_RX: begin
			// Enable the UART receiver
			UART_rx_enable <= 1'b1;
			top_state <= S_WAIT_UART_RX;
		end
		S_WAIT_UART_RX: begin
			//MBOBUS
			/////////////////////// FOR SIMULATION //////////////////
			//if ((UART_timer == 26'd49999999) || (UART_SRAM_address != 18'h00000)) begin//////////////////////////////////////	WE CHANGED THE && TO || FOR SIMULATION
			/////////////////////// FOR BOARD ///////////////////////
			if ((UART_timer == 26'd49999999) && (UART_SRAM_address != 18'h00000)) begin//////////////////////////////////////	WE CHANGED THE && TO || FOR SIMULATION
			/////////////////////////////////////////////////////////
			// Timeout on UART
				UART_rx_initialize <= 1'b1;
				 				
				//VGA_enable <= 1'b1;
				
				//** To be written to 1 once we start displaying the converted RGB pixels (they are being read from SRAM, they should not be displayed as we convert from YUV)
				
				//top_state <= S_M1;
				top_state <= S_M2;
			end 
			
		end	
		
		
		
		S_M2: begin
			lead_in_begin_M2 <= 1;
			
			if (M2_done == 1)
				top_state <= S_M2_leave;
		end
		
		
		S_M2_leave: begin
			VGA_enable <= 1;
			lead_in_begin_M2 <= 0;
			
			top_state <= S_IDLE;
		end
		
		
		/****************************** Remove Start Line. 
			// - States that start and end M1.
			
		S_M1: begin
				lead_in_begin_M1 <= 1;
				
				
				if (M1_done == 1)
					top_state <= S_M1_leave;

		
		end
		
		S_M1_leave: begin
			VGA_enable <= 1;
			top_state <= S_IDLE;
			
			lead_in_begin_M1 <= 0;
			
		end
		*/ //***********************************// Remove End Line
		default: top_state <= S_IDLE;
		endcase
	end
end

assign VGA_adjust = SWITCH_I[0];
assign VGA_base_address = 18'd146944;

// Give access to SRAM for UART and VGA at appropriate time

/*always_comb begin
	
	if (M1_current_state != 0)
		sram_address_temp = M1_SRAM_address;
	else if ((top_state == S_ENABLE_UART_RX) | (top_state == S_WAIT_UART_RX))
		sram_address_temp = UART_SRAM_address;
	else
		sram_address_temp = VGA_SRAM_address;

end*/

/*assign SRAM_address = ((top_state == S_ENABLE_UART_RX) | (top_state == S_WAIT_UART_RX)) 
						? UART_SRAM_address 
						: VGA_SRAM_address;
*/
//assign SRAM_address = sram_address_temp;

//assign SRAM_write_data = M1_current_state != 0 ? M1_SRAM_write_data : UART_SRAM_write_data ;


/*assign SRAM_address = ((top_state == S_ENABLE_UART_RX) | (top_state == S_WAIT_UART_RX))
								? UART_SRAM_address : ((top_state == S_M1) ? M1_SRAM_address : VGA_SRAM_address);*/
								
assign SRAM_address = ((top_state == S_ENABLE_UART_RX) | (top_state == S_WAIT_UART_RX))
								? UART_SRAM_address : (top_state == S_M1) ? M1_SRAM_address : ((top_state == S_M2) ? M2_SRAM_address :VGA_SRAM_address);							
								
assign SRAM_write_data = (top_state == S_M1) ? M1_SRAM_write_data : ((top_state == S_M2) ? M2_SRAM_write_data :UART_SRAM_write_data);

assign SRAM_we_n = ((top_state == S_ENABLE_UART_RX) | 
						(top_state == S_WAIT_UART_RX)) ? UART_SRAM_we_n : (top_state == S_M1) ? M1_SRAM_we_n : ((top_state == S_M2) ? M2_SRAM_we_n : 1'b1);

/*always_comb begin
	
	if (M1_current_state != 1'b0)
		sram_wen_temp = M1_SRAM_we_n;
	else if ((top_state == S_ENABLE_UART_RX) | (top_state == S_WAIT_UART_RX))
		sram_wen_temp = UART_SRAM_we_n;
	else sram_wen_temp = 1'b1;

end*/

//assign SRAM_we_n = sram_wen_temp;
/*assign SRAM_we_n = ((top_state == S_ENABLE_UART_RX) | (top_state == S_WAIT_UART_RX)) 
						? UART_SRAM_we_n 
						: 1;*/

// 7 segment displays
convert_hex_to_seven_segment unit7 (
	.hex_value(SRAM_read_data[15:12]), 
	.converted_value(value_7_segment[7])
);

convert_hex_to_seven_segment unit6 (
	.hex_value(SRAM_read_data[11:8]), 
	.converted_value(value_7_segment[6])
);

convert_hex_to_seven_segment unit5 (
	.hex_value(SRAM_read_data[7:4]), 
	.converted_value(value_7_segment[5])
);

convert_hex_to_seven_segment unit4 (
	.hex_value(SRAM_read_data[3:0]), 
	.converted_value(value_7_segment[4])
);

convert_hex_to_seven_segment unit3 (
	.hex_value({2'b00, SRAM_address[17:16]}), 
	.converted_value(value_7_segment[3])
);

convert_hex_to_seven_segment unit2 (
	.hex_value(SRAM_address[15:12]), 
	.converted_value(value_7_segment[2])
);

convert_hex_to_seven_segment unit1 (
	.hex_value(SRAM_address[11:8]), 
	.converted_value(value_7_segment[1])
);

convert_hex_to_seven_segment unit0 (
	.hex_value(SRAM_address[7:4]), 
	.converted_value(value_7_segment[0])
);

assign   
   SEVEN_SEGMENT_N_O[0] = value_7_segment[0],
   SEVEN_SEGMENT_N_O[1] = value_7_segment[1],
   SEVEN_SEGMENT_N_O[2] = value_7_segment[2],
   SEVEN_SEGMENT_N_O[3] = value_7_segment[3],
   SEVEN_SEGMENT_N_O[4] = value_7_segment[4],
   SEVEN_SEGMENT_N_O[5] = value_7_segment[5],
   SEVEN_SEGMENT_N_O[6] = value_7_segment[6],
   SEVEN_SEGMENT_N_O[7] = value_7_segment[7];

assign LED_GREEN_O = {resetn, VGA_enable, ~SRAM_we_n, Frame_error, lead_in_begin_M1};

endmodule
