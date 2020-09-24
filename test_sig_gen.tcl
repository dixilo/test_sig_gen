set ip_name "test_sig_gen"
create_project $ip_name "." -force
source ./util.tcl

# file
set proj_fileset [get_filesets sources_1]
add_files -norecurse -scan_for_includes -fileset $proj_fileset [list \
    "test_sig_gen.v" \
]

set_property "top" "test_sig_gen" $proj_fileset

ipx::package_project -root_dir "." -vendor kuhep -library user -taxonomy /kuhep
set_property name $ip_name [ipx::current_core]
set_property vendor_display_name {kuhep} [ipx::current_core]

################################################ IP generation
############### DDC QUAD
### DDS
create_ip -vlnv [latest_ip dds_compiler] -module_name dds
set_property CONFIG.Parameter_Entry "Hardware_Parameters" [get_ips dds]
set_property CONFIG.PINC1 0 [get_ips dds]
set_property CONFIG.DDS_Clock_Rate 312.5 [get_ips dds]
set_property CONFIG.Mode_of_Operation "Standard" [get_ips dds]
set_property CONFIG.Phase_Increment "Streaming" [get_ips dds]
set_property CONFIG.Phase_offset "Streaming" [get_ips dds]
set_property CONFIG.Phase_Width 20 [get_ips dds]
set_property CONFIG.Output_Width 16 [get_ips dds]
set_property CONFIG.Noise_Shaping "None" [get_ips dds]
set_property CONFIG.Resync {true} [get_ips dds]


#### Adder for phase
create_ip -vlnv [latest_ip c_addsub] -module_name adder_phase
set_property CONFIG.A_Width 20 [get_ips adder_phase]
set_property CONFIG.B_Width 20 [get_ips adder_phase]
set_property CONFIG.Out_Width 20 [get_ips adder_phase]
set_property CONFIG.CE "false" [get_ips adder_phase]
set_property CONFIG.Latency 3 [get_ips adder_phase]
set_property generate_synth_checkpoint 0 [get_files adder_phase.xci]


################################################ Register XCI files
# file groups
ipx::add_file ./${ip_name}.srcs/sources_1/ip/dds/dds.xci \
[ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]

ipx::add_file ./${ip_name}.srcs/sources_1/ip/adder_phase/adder_phase.xci \
[ipx::get_file_groups xilinx_anylanguagesynthesis -of_objects [ipx::current_core]]

# Reordering
ipx::reorder_files \
    -after ./${ip_name}.srcs/sources_1/ip/adder_phase/adder_phase.xci \
    ./test_sig_gen.v [ipx::get_file_groups \
                        xilinx_anylanguagesynthesis \
                        -of_objects [ipx::current_core]]
