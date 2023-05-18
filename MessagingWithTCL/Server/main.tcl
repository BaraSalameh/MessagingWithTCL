source "../procedures.tcl"
source "../prepareInfo.tcl"

# Create a Simulator
set ns [new Simulator]

# Create a Trace file
set tracefile [open project.tr w]
$ns trace-all $tracefile

# NAM file creation
set namfile [open project.nam w]
$ns namtrace-all $namfile

# Finish Proc
proc finish {} {
	global ns tracefile namfile
	$ns flush-trace
	close $tracefile
	close $namfile
	exec nam project.nam &
	exit 0
}

#Procedure to send data
proc send_message {node agent} {
	global ns
	
	source "./Diffie-Hellman/dh.tcl"
	if {[$node node-addr] eq 0} {
		change_flag "00"
		set next_flag "01"
		
		set message [get_line_from_file "../Node0/Messages/Outgoing/aes.dat" 3]
		$ns trace-annotate "Message to be sent by [$node node-addr] : $message"
		
		source "../Node0/RSA/rsa.tcl"
		source "../Node0/AES/aes.tcl"
		
		set enc_message [read_file_content "../Node0/Messages/Outgoing/outgoing.txt"]
	} elseif {[$node node-addr] eq 1} {
		change_flag "10"
		set next_flag "11"
		
		set message [get_line_from_file "../Node1/Messages/Outgoing/aes.dat" 3]
		$ns trace-annotate "Message to be sent by [$node node-addr] : $message"
		
		source "../Node1/RSA/rsa.tcl"
		source "../Node1/AES/aes.tcl"
		
		set enc_message [read_file_content "../Node1/Messages/Outgoing/outgoing.txt"]
	} else {
		puts "WARNING: Third party in house!"
	}
	change_flag $next_flag
	
	$ns trace-annotate "Encoded Message sent by [$node node-addr] : $enc_message"
	eval {$agent} send 999 {$enc_message}
}

# UDP Agent procedure to process Recived Data
Agent/UDP instproc process_data {size data} {
	global ns
	$self instvar node_
	
	$ns trace-annotate "Message recived by [$node_ node-addr] : $data"
	
	if {[$node_ node-addr] eq 1} {
		set fIn [open "../Node1/Messages/Incoming/incoming.dat" w]
		puts $fIn $data
		close $fIn
		
		source "../Node1/RSA/rsa.tcl"
		source "../Node1/AES/aes.tcl"
		
		set dec_message [read_file_content "../Node1/Messages/Operations/decryption.txt"]
	} elseif {[$node_ node-addr] eq 0} {
		set fIn [open "../Node0/Messages/Incoming/incoming.txt" w]
		puts $fIn $data
		close $fIn
		
		source "../Node0/RSA/rsa.tcl"
		source "../Node0/AES/aes.tcl"
		
		set dec_message [read_file_content "../Node0/Messages/Operations/decryption.txt"]
	} else {
		puts "WARNING: Third party in house!"
	}
	$ns trace-annotate "Decoded Message recieved by [$node_ node-addr] : $dec_message"
}

set node0 [$ns node]
set node1 [$ns node]

$node0 color violet
$node0 label "encrypted node 1"
$node1 color violet
$node1 label "encrypted node 2"

# connection
$ns duplex-link $node0 $node1 0.7Mb 100ms DropTail

# Agent creation
set enc_udp0 [new Agent/UDP]
$ns attach-agent $node0 $enc_udp0
$enc_udp0 set fid_ 0

set enc_udp1 [new Agent/UDP]
$ns attach-agent $node1 $enc_udp1
$enc_udp1 set fid_ 1

$ns connect $enc_udp0 $enc_udp1

# Start Traffic
$ns at 0.1 "$ns trace-annotate {Starting Encrypted Communicaton...}"
$ns at 0.1 "send_message $node0 $enc_udp0"
$ns at 0.3 "send_message $node1 $enc_udp1"

#$ns at 0.1 "send_message $node1 $enc_udp1"
#$ns at 0.3 "send_message $node0 $enc_udp0"
$ns at 0.5 "finish"
$ns run

