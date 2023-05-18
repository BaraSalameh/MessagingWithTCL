# RSA Encryption function
proc RSA_Encryption {message e n} {
	set sep [get_line_from_file "../info.txt" 25]
	puts "separate located in line 25: $sep"
	set mylist [split [separate $message $sep] { }]
	set c ""
	foreach {char} $mylist {
		scan $char %d asc
		set res [expr [expr {$asc ** $e}] % $n]
		append c $res
		append c " "
	}
	set file_handler [open "../Node1/Messages/Operations/rsa_EDFlow.txt" w]
	puts -nonewline $file_handler $c
	close $file_handler
}

# RSA Decryption function
proc RSA_Decryption {cypher d n} {
	set mylist [split $cypher { }]
	set p ""
	set counter 0
	foreach {char} $mylist {
		if {$counter == [expr [strlen $mylist] - 1]} {
			break
		} else {
			set counter [expr $counter + 1]
		}
		scan $char %d asc
		set res 1
		for {set i 1} {$i <= $d} {incr i} {
			set res [expr {($res * $asc) % $n}]
		}
		append p "$res "
	}
	return [converter [maintain $p]]
}

set flag_handler [open "./assets/flag.txt" r]
set flag [read $flag_handler]
close $flag_handler

if {$flag == "01"} {
	set b [get_line_from_file "../Node1/Messages/Incoming/incoming.dat" 1]
	set a [get_line_from_file "../Node1/Messages/Incoming/incoming.dat" 2]
	set d [get_line_from_file "../info.txt" 19]
	set n [get_line_from_file "../info.txt" 20]
	puts "node1{d} located in line 19: $d"
	puts "node1{n} located in line 20: $n"
	set a [RSA_Decryption $a $d $n]
	set_line_in_file "../Node1/Messages/Operations/fito.txt" 1 $b
	set_line_in_file "../Node1/Messages/Operations/fito.txt" 2 $a
	
} elseif {$flag == "10"} {
	set a [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 3]
	set e [get_line_from_file "../info.txt" 17]
	set n [get_line_from_file "../info.txt" 18]
	puts "node1{e} located in line 17: $e"
	puts "node1{n} located in line 18: $n"
	RSA_Encryption $a $e $n
	
	set b [get_line_from_file "../Node1/Messages/Operations/fito.txt" 1]
	delete_file_content "../Node1/Messages/Operations/fito.txt"
	set_line_in_file "../Node1/Messages/Operations/rsa_EDFlow.txt" 2 $b
}
	
