onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_project_v2/Clock_50
add wave -noupdate -divider {some label for my divider}
add wave -noupdate /tb_project_v2/uut/SRAM_we_n
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/SRAM_write_data
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/SRAM_read_data
add wave -noupdate -radix unsigned /tb_project_v2/uut/SRAM_address
add wave -noupdate /tb_project_v2/uut/top_state
add wave -noupdate /tb_project_v2/uut/M1_unit/M1_state
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/SRAM_read_data
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/Y_data
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/U_data
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/V_data
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/U_data_buff
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/V_data_buff
add wave -noupdate -radix decimal /tb_project_v2/uut/M1_unit/a_IN2
add wave -noupdate -radix decimal /tb_project_v2/uut/M1_unit/b_IN2
add wave -noupdate -radix decimal /tb_project_v2/uut/M1_unit/c_IN2
add wave -noupdate -radix unsigned /tb_project_v2/uut/M1_unit/a_result
add wave -noupdate -radix unsigned /tb_project_v2/uut/M1_unit/b_result
add wave -noupdate -radix unsigned /tb_project_v2/uut/M1_unit/c_result
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/ee_high
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/ee_low
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/eo_high
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/eo_low
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/oo_high
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/oo_low
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/UR
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/VR
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/V_MAC
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/V_prime
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/U_MAC
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/M1_unit/U_prime
add wave -noupdate -radix unsigned /tb_project_v2/uut/M1_unit/pixel_row_count
add wave -noupdate /tb_project_v2/uut/M1_unit/data_req_flag
add wave -noupdate /tb_project_v2/uut/M1_unit/UV_byte_flag
add wave -noupdate -radix hexadecimal /tb_project_v2/uut/done
add wave -noupdate -radix unsigned /tb_project_v2/uut/UART_timer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17769200 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {17769100 ps} {17770100 ps}
