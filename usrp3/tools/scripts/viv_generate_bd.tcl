#
# Copyright 2016 Ettus Research
#

# ---------------------------------------
# Gather all external parameters
# ---------------------------------------
set bd_file         $::env(BD_FILE)               ;# Absolute path to XCI file from src dir
set part_name       $::env(PART_NAME)              ;# Full Xilinx part name
set bd_name [file rootname [file tail $bd_file]]   ;# Extract IP name

# Delete any previous output cookie file
file delete -force "$bd_file.out"
# ---------------------------------------
# Vivado Commands
# ---------------------------------------
puts "BUILDER: Adding Block Diagram: $bd_file"
create_project -part $part_name -in_memory
#set_property target_simulator XSim [current_project]
add_files -norecurse $bd_file
puts "BUILDER: Generating BD Target first pass..."
generate_target all [get_files $bd_file] -force
#puts "BUILDER: Export IP user files of $bd_name"
report_ip_status
puts "BUILDER: Report_ip_status done"
upgrade_ip [ get_ips $bd_name* ]
puts "BUILDER: upgrade_ip to current part done"
open_bd_design $bd_file
puts "open_bd_design done"
puts "BUILDER: Generating BD Target..."
generate_target all [get_files $bd_file]
puts "BUILDER: Generate all done"

if { [get_msg_config -count -severity ERROR] == 0 } {
    # Write output cookie file
    set outfile [open "$bd_file.out" w]
    puts $outfile "This file was auto-generated by viv_generate_ip.tcl and signifies that BD generation is done."
    close $outfile
} else {
    exit 1
}

