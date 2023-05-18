# Requires tcllib
package require aes
package require tcl::transform::base64
package require md5

# Make some sort of key data, 16, 24, or 32 bytes long
#set key [string repeat - 16]

# 16-bytes long Diffie-Hellman shared key
#set key "18E10FD9DEF30A57"

# 24-bytes long Diffie-Hellman shared key
#set key "AA31E2FBE0CDF58FDCB8B171"

# 32-bytes long Diffie-Hellman shared key
#set key "51FC4837495B8A31ECC7D78C65A93D21"

set key [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 7]

# Generate an IV, 16 bytes long. MD5 of clock ticks, the Proc ID, and
# a random value. Take 16 bytes.
set iv [string range [md5::md5 [clock clicks]:[pid]:[expr {rand()}]] 0 15]

proc AES_Encryption {fIn key iv} {
	# Open the plain text and cipher text channels. Set them to binary 		
	# mode so all bytes are read if not readable
	set fOut [open "../Node1/Messages/Operations/aes_EDFlow.txt" w]
	fconfigure $fIn -translation binary
	fconfigure $fOut -translation binary
	
	# Set the Output Channel to also base64 encode on the write
	tcl::transform::base64 $fOut
	
	# Stick the IV at the begining of the file (based64 encoded of 
	# course)
	puts -nonewline $fOut $iv
	
	# Do encryption, CBC Mode, with Key and IV. Directly read from In and
	# write to Out. And again, automatically base64 encoded on the write.
	aes::aes -mode cbc -dir encrypt -key $key -iv $iv -out $fOut -in $fIn
	close $fIn
	close $fOut
}

proc AES_Decryption {fIn key} {
	# Open the cipher text and the destination channels. Set to binary mode.
	set fOut [open "../Node1/Messages/Operations/aes_EDFlow_Helper.txt" w]

	fconfigure $fIn -translation binary
	fconfigure $fOut -translation binary

	# Set input channel to decode base64 on read.
	tcl::transform::base64 $fIn

	# Read 16 bytes, this is the IV
	set iv [chan read $fIn 16]

	# Decrypt, CBC mode, same key, IV pulled from text. And automatically
	# decode base64.
	aes::aes -mode cbc -dir decrypt -key $key -iv $iv -out $fOut -in $fIn
	close $fOut
	close $fIn
	MEDF1
}

# Overview: flag.txt file contains a 2 bits string, it is initiated to differentiate netween the 4 phases og this application.
# Methodology: open the flag.txt file, read the content, close the file, the four phases are described in the if,elseif code block!
set flag_handler [open "./assets/flag.txt" r]
set flag [read $flag_handler]
close $flag_handler


if {$flag == "01"} {
	set message [get_line_from_file "../Node1/Messages/Incoming/incoming.dat" 3]
	
	set fOut [open "../Node1/Messages/Operations/aes_EDFlow.txt" w]
	puts $fOut $message
	close $fOut
	
	set fIn [open "../Node1/Messages/Operations/aes_EDFlow.txt" r]
	AES_Decryption $fIn $key
	
	set rsa "../Node1/Messages/Operations/fito.txt"
	set aes "../Node1/Messages/Operations/aes_EDFlow.txt"
	set destination "../Node1/Messages/Operations/decryption.txt"
	cuncatenate_messages $rsa $aes $destination
} elseif {$flag == "10"} {
	set A [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 4]
	set B [get_line_from_file "../Node1/Diffie-Hellman/flow.dat" 5]
	
	set_line_in_file "../Node1/Messages/Outgoing/aes.dat" 1 $B
	set_line_in_file "../Node1/Messages/Outgoing/aes.dat" 2 $A
	
	set plaintext [open "../Node1/Messages/Outgoing/aes.dat" r]
	AES_Encryption $plaintext $key $iv
	
	set rsa "../Node1/Messages/Operations/rsa_EDFlow.txt"
	set aes "../Node1/Messages/Operations/aes_EDFlow.txt"
	set destination "../Node1/Messages/Outgoing/outgoing.txt"
	cuncatenate_messages $rsa $aes $destination
}

