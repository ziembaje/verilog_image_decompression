`ifndef DEFINE_STATE


typedef enum logic [6:0] {
	S_WAIT_FOR_PREVIOUS,
	S_LEAD_IN_START_1,
	S_2,
	S_3,
	S_4,
	S_5,
	S_6,
	S_7,
	S_8,
	S_9,
	S_10,
	S_11,
	S_12,
	S_13,
	S_14,
	S_15,
	S_16,
	S_17,
	S_18,
	
	S_LOOP_0,
	S_LOOP_1,
	S_LOOP_2,
	S_LOOP_3,
	S_LOOP_4,
	S_LOOP_5,
	S_LOOP_6,
	S_LOOP_7,
	S_LOOP_8,
	S_LOOP_9,
	
	S_LO_0,
	S_LO_1,
	S_LO_2,
	S_LO_3,
	S_LO_4,
	S_LO_5,
	S_LO_6,
	S_LO_7,
	S_LO_8,
	S_LO_9,
	S_LO_10,
	S_LO_11,
	S_LO_12,
	S_LO_13,
	S_LO_14,
	S_LO_15,
	S_LO_16,
	S_LO_17,
	S_LO_18,
	S_LO_19,
	S_LO_20,
	S_LO_21,
	S_LO_22,
	S_LO_23,
	S_LO_24,
	S_LO_25,
	S_LO_26,
	S_LO_27
	
} M1_state_type;


typedef enum logic [8:0] {
	
	S_FETCH_1, //first two clock cycles for initial fetching of s
	S_FETCH_2,
	S_FETCH_3,
	
	S_BLOCK1_1,
	S_BLOCK1_2,
	S_BLOCK1_3,
	S_BLOCK1_4,
	S_BLOCK1_5,
	S_BLOCK1_6,
	S_BLOCK1_7,
	
	S_BLOCK2_1,
	S_BLOCK2_2,
	S_BLOCK2_3,
	S_BLOCK2_4,
	S_BLOCK2_5,
	S_BLOCK2_6,
	S_BLOCK2_7,
	
	S_BLOCK3_1,
	S_BLOCK3_2,
	S_BLOCK3_3,
	S_BLOCK3_4,
	S_BLOCK3_5,
	S_BLOCK3_6,
	S_BLOCK3_7,
	
	S_BLOCK4_1,
	S_BLOCK4_2,
	S_BLOCK4_3,
	S_BLOCK4_4,
	S_BLOCK4_5,
	S_BLOCK4_6,
	S_BLOCK4_7,
	
} M2_state_type;

// This defines the states
typedef enum logic [3:0] {
	S_IDLE,
	S_ENABLE_UART_RX,
	S_WAIT_UART_RX,
	S_M1,
	S_M1_leave,
	S_M2,
	S_M2_leave
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

`define DEFINE_STATE 1
`endif
