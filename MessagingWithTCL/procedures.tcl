# Procedure to return the content of a file
# Overview- receives the pure file name (not the object) and rturns the file content
# Methodology: receives the file name, opens the file in read mode, read the content, closes the file (it's very important to always close the file, otherwise, like the procedure didn't read anything), return the content.
proc read_file_content {file_name} {
	set file_handler [open $file_name r]
	set content [read $file_handler]
	close $file_handler
	return $content
}

# Procedure to change the value inside a static file (the same file)
# Overview: receives a value in order to replace the file content with the value and returns nothing.
# Methodology: receives the value, opens the file in write mode, inserts the received value in the file, Note(the previous content of the file will be deleted), close the file. (static procedure)
proc change_flag {next_flag} {
	set flag_handler [open "./assets/flag.txt" w]
	puts $flag_handler $next_flag
	close $flag_handler
}

# The same as the previous procedure, but, this procedure is for another static file (node0 and node1 Diffie-Hellman flag file). (static procedure)
proc change_DH_flag {value} {
	set flag_controller [open "./Diffie-Hellman/flag.dat" w]
	puts $flag_controller $value
	close $flag_controller
}

# Procedure to return a specific line from a file, the file is knows by file_name attribute, the specific line known by number attribute.
proc get_line_from_file {file_name number} {
	set fIn [open $file_name r]
	set line_number 1
	set output ""
	while {[gets $fIn line] != -1} {
		if {$line_number == $number} {
			append output $line
			break
		}
		incr line_number
	}
	close $fIn
	return $output
}

# Procedure to replace a specific line within a file, the file known by file_name attribute, the specific line to replace is known by line_number, and finally, new_content attribute holds the ne content to be inserted within the file.
proc set_line_in_file {file_name line_number new_content} {
	set line_number [expr $line_number - 1]
	set fIn [open $file_name r]
	set content [read $fIn]
	close $fIn
	
	set lines [split $content "\n"]
	set lines [lreplace $lines $line_number $line_number $new_content]
	set new_content [join $lines "\n"]
	set fOut [open $file_name w]
	puts -nonewline $fOut $new_content
	close $fOut
}

# Procedure to Manage Encryption Decryption Files in node0, replaces the plaintext file with the encrypted text content. (static procedure)
proc MEDF0 {} {
	set fIn [open "../Node0/Messages/Operations/aes_EDFlow_Helper.txt" r]
	set content [read $fIn]
	close $fIn
	
	set fOut [open "../Node0/Messages/Operations/aes_EDFlow.txt" w]
	puts $fOut $content
	close $fOut
}

# Procedure to Manage Encryption Decryption Files in node1, replaces the plaintext file with the encrypted text content. (static procedure)
proc MEDF1 {} {
	set fIn [open "../Node1/Messages/Operations/aes_EDFlow_Helper.txt" r]
	set content [read $fIn]
	close $fIn
	
	set fOut [open "../Node1/Messages/Operations/aes_EDFlow.txt" w]
	puts $fOut $content
	close $fOut
}

# Procedure to cuncatenate the content of two files in one file, the first two files are known by first, second attributes, the destination file to hold the content is known by destination attribute. (static procedure)
proc cuncatenate_messages {first second destination} {
	set trash [open $destination w]
	close $trash
	
	set fIn [open $second r]
	set second [read $fIn]
	close $fIn
	
	set_line_in_file $destination 1 [get_line_from_file $first 1]
	set_line_in_file $destination 2 [get_line_from_file $first 2]
	set_line_in_file $destination 3 $second
}

# A function to help the RSA_Encryption function with separating the message into digits depending on the intended value passed
proc separate {message amount} {
	set mylist [split $message {}]
	set res ""
	set flag 0
	set appender [expr $amount - 1]
	for {set i 0} {$i < [llength $mylist]} {incr i} {
		set flag [expr $flag + 1]
		if {$flag <= $amount} {
		set controller [scan [lindex $mylist $appender] %c]
			if {$controller < 100} {
				append res 0
			}
			append res $controller
			set appender [expr $appender - 1]
		} else {
			set flag 0
			set i [expr $i - 1]
			set appender [expr $amount + $i]
			append res " "
		}
	}
	return $res
}

# a function to re-unite the separated characters, delas with RSA decryption procedure only.
proc maintain {message} {
	set realNumber ""
	foreach {char} $message {
		scan $char %d number
		while {$number != 0} {
			append realNumber [expr $number % 1000]
			append realNumber " "
			set number [expr $number / 1000]
		}
	}
	return $realNumber
}

# a function to convert the decrypted ascii values into letters, deals with RSA decryption only.
proc converter {ascii} {
	set myList [split $ascii { }]
	set counter 0
	set plain ""
	foreach {num} $myList {
		if {$counter == [expr [strlen $myList] - 1]} {
			break
		} else {
			set counter [expr $counter + 1]
		}
		scan $num %d asc
		set newchar [format "%c" $asc]
		append plain "$newchar"
	}
	return $plain
}

# a function to figure a string length. deals with converter procedure only (static)
proc strlen {s} {
	set answer 0
	foreach {node} [split $s { }] {incr answer}
	return $answer
}

# Procedure to delete the content of a file by opening it in write mode.
proc delete_file_content {file_name} {
	set trash [open $file_name w]
	close $trash
}

