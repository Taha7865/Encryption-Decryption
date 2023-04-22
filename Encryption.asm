.eqv SysPrintInt 1
.eqv SysPrintFloat 2
.eqv SysPrintDouble 3
.eqv SysPrintString 4
.eqv SysReadInt 5
.eqv SysReadFloat 6
.eqv SysReadDouble 7
.eqv SysReadString 8
.eqv SysAlloc 9
.eqv SysExit 10
.eqv SysPrintChar 11
.eqv SysReadChar 12
.eqv SysOpenFile 13
.eqv SysReadFile 14
.eqv SysWriteFile 15
.eqv SysCloseFile 16
.eqv SysExitValue 17
.eqv KeySize 60
.eqv BlockSize 1024
.eqv MaxSizeOfPathFile 500
.data
men_menu: .ascii "\nMain menu:\n\n"
	  .ascii "1: Encrypt the file.\n"
	  .ascii "2: Decrypt the file.\n"
	  .ascii "3. Exit.\n"
	  .asciiz "Select Option: "
file_name_msg: .asciiz "enter file name: "
key_msg: .asciiz "enter key: "
input_open_error: .asciiz "we can't open input file for reading \n"
output_open_error: .asciiz "we can't open output file for writing \n"
input_read_error: .asciiz "we can't read from input file \n"
output_write_error: .asciiz "we can't write to output file \n"
invalid_option: .asciiz "Invalid option try again \n"
empty_key: .asciiz "empty key please try again.\n"
file_name: .space MaxSizeOfPathFile
keyBuf: .space KeySize
Buf: .space BlockSize
.text
main:
	# print menu 
	li $v0,SysPrintString	#Printing Menu
	la $a0,men_menu
	syscall
	# read option
	li $v0,SysReadInt	# Reading value for the menu
	syscall
	blt $v0,1,main_bad_option	# checking the value input for the menu
	beq $v0,3,main_exit		# if equal to 3, exit
	bgt $v0,3,main_bad_option
	move $s0,$v0 # save option in $s0 
	# read file name 
	li $v0,SysPrintString		# Print enter file name
	la $a0,file_name_msg
	syscall
	li $v0,SysReadString		# Read in file name
	la $a0,file_name		# store file name in $a0
	li $a1,MaxSizeOfPathFile
	syscall
	la $a0,file_name		# load file name in $a0, and remove /n character at the end
	jal remove_new_line
	# read key 
	li $v0,SysPrintString		# Print key message
	la $a0,key_msg
	syscall				# Read in a key, with max buffer size
	li $v0,SysReadString		
	la $a0,keyBuf			# Max size of they key is 60 
	li $a1,KeySize
	syscall
	la $a0,file_name		# load into variables
	la $a1,Buf
	la $a2,keyBuf
	move $a3,$s0			
	jal enc_dec_rypt
	beq $v0,-1,main_bad_option	# testing valid input, if not vaild, print out error messages
	beq $v0,-2,main_input_open_error
	beq $v0,-3,main_input_read_error
	beq $v0,-4,main_output_open_error
	beq $v0,-5,main_output_write_error
	beq $v0,-6,main_empty_key
	j main # go to show menu again
main_bad_option:
	li $v0,SysPrintString		# print invalid option
	la $a0,invalid_option
	syscall
	j main
main_input_open_error:			# error when trying to open input file
	li $v0,SysPrintString
	la $a0,input_open_error
	syscall
	j main
main_output_open_error:			# error when trying to open output file
	li $v0,SysPrintString
	la $a0,output_open_error
	syscall
	j main
main_input_read_error:
	li $v0,SysPrintString		# error when trying to read input file
	la $a0,input_read_error
	syscall
	j main
main_output_write_error:
	li $v0,SysPrintString		# error when trying to write to output file
	la $a0,output_write_error
	syscall
	j main
main_empty_key:				# if the key is empty
	li $v0,SysPrintString
	la $a0,empty_key
	syscall
	j main
main_exit:				# sys exit
	li $v0,SysExit
	syscall
########################################
	# encrypt or decrypt if option = 1 mean encrypt if option = 2 mean decrypt 
	# other option return -1 ( mean bad option )
	# $a0 = input file name  
	# $a1 = buffer that will recieve block data 
	# $a2 = key string
	# $a3 = option 
	# 
	# return 
	# $v0 = number of bytes encrypted or decrypted 
	# $v0 = -1 ( bad option )
	# $v0 = -2 ( can't open input file for reading ) 
	# $v0 = -3 ( can't read from input file )
	# $v0 = -4 ( can't open output file for writing ) 
	# $v0 = -5 ( can't write to output file )
	# $v0 = -6 ( empty key )
########################################
.data
txtMsg: .asciiz "txt"
encMsg: .asciiz "enc"
.text
enc_dec_rypt:
	addiu $sp,$sp,-36 # using stack to load in variables
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $s2,12($sp)
	sw $s3,16($sp)
	sw $s4,20($sp)
	sw $s5,24($sp)
	sw $s6,28($sp)
	sw $s7,32($sp)
	
	blt $a3,1,enc_dec_rypt_1 	# checking option to see if we encrypt or decrypt
	bgt $a3,2,enc_dec_rypt_1	# 2 to decrypt
	
	lbu $t0,0($a2)			#checking key
	beq $t0,'\n',enc_dec_rypt_6	# check to see if we are at the end of the key
	
	move $s0,$a0 # save $a0 at $s0 
	move $s1,$a1 # save $a1 at $s1 
	move $s2,$a2 # save $a2 at $s2 
	move $s3,$a3 # save $a3 at $s3 
	
	
	
	li $v0,SysOpenFile
					# $a0 = input file name
	li $a1,0			# counters
	li $a2,0
	syscall
	blt $v0,$zero,enc_dec_rypt_2	
	move $s4,$v0
	

	move $a0,$s0			# we calculate lenght of path and file name of input file 
	jal strlen
	
	move $a0,$v0
	li $v0,SysAlloc
	syscall
	move $s5,$v0
	
	move $a0,$s5			# copy the path to output buffer
	move $a1,$s0
	jal strcpy
					# find the first period before extension 
	move $s6,$s5 			# in $s6 with address of input file name 
enc_dec_rypt_path:
	move $a0,$s6
	li $a1,'.'			# if ., then end encyrption
	jal strchr
	beq $v0,$zero,enc_dec_rypt_path_done
	addiu $s6,$v0,1			# move over 1 and continue to decyrpt
	j enc_dec_rypt_path
enc_dec_rypt_path_done:
	move $a0,$s6
	beq $s3,1,enc_dec_rypt_path_en
					# here decryption
	la $a1,txtMsg
	j enc_dec_rypt_path_up
enc_dec_rypt_path_en:
	la $a1,encMsg
enc_dec_rypt_path_up:
	jal strcpy
	li $v0,SysOpenFile		# opening input file
	move $a0,$s5 			# $a0 = output file name
	li $a1,1
	li $a2,0
	syscall
	blt $v0,$zero,enc_dec_rypt_4	#decrypt or encyrpt
	move $s5,$v0 			# we use s5 for save file descriptor of output 
	
	li $s7,0
enc_dec_rypt_loop:
	# read block data 
	li $v0,SysReadFile		# Read file block size
	move $a0,$s4
	move $a1,$s1
	li $a2,BlockSize
	syscall
	beq $v0,$zero,enc_dec_rypt_loop_done	# if no more characters, we are done encyrpting/decyrpting
	blt $v0,$zero,enc_dec_rypt_3
	add $s7,$s7,$v0 			# update $s7
	move $s6,$v0 				# save number character read in $s6
						# here we encrypt or we decrypt 
	move $t1,$s1
	move $t2,$s2 
enc_dec_rypt_loop_inner:
	lbu $t0,0($t1)				# loops to read in file
enc_dec_rypt_loop_inner_key:
	lbu $t3,0($t2)
	bne $t3,'\n',enc_dec_rypt_loop_inner_up
	move $t2,$s2
	j enc_dec_rypt_loop_inner_key
enc_dec_rypt_loop_inner_up:
	beq $s3,1,enc_dec_rypt_loop_inner_en
	# here decryption
	subu $t0,$t0,$t3
	j enc_dec_rypt_loop_inner_update
enc_dec_rypt_loop_inner_en:
	addu $t0,$t0,$t3
enc_dec_rypt_loop_inner_update:
	sb $t0,0($t1) 
	addiu $t1,$t1,1 			# update next char at buffer
	addiu $t2,$t2,1				# update next char at key
	addi $v0,$v0,-1
	bne $v0,$zero,enc_dec_rypt_loop_inner
						# here encryption or decryption done 
						# we need to write that block data to output file 
	li $v0,SysWriteFile
	move $a0,$s5
	move $a1,$s1
	move $a2,$s6
	syscall 
	blt $v0,$zero,enc_dec_rypt_5
	j enc_dec_rypt_loop
enc_dec_rypt_loop_done:
	# close files 
	li $v0,SysCloseFile
	move $a0,$s4 
	syscall
	li $v0,SysCloseFile
	move $a0,$s5
	syscall
	move $v0,$s7
enc_dec_rypt_done:
	lw $ra,0($sp)				# done encrypting, so we load data back from stack
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $s2,12($sp)
	lw $s3,16($sp)
	lw $s4,20($sp)
	lw $s5,24($sp)
	lw $s6,28($sp)
	lw $s7,32($sp)
	addiu $sp,$sp,36			# restore stack
	jr $ra
enc_dec_rypt_1:
	li $v0,-1
	j enc_dec_rypt_done			#close files and print messages
enc_dec_rypt_2:
	li $v0,-2
	j enc_dec_rypt_done
enc_dec_rypt_4:
	li $v0,-4
	j enc_dec_rypt_done
enc_dec_rypt_3:
	li $v0,SysCloseFile			# close file and output to file
	move $a0,$s4 
	syscall
	li $v0,-3
	j enc_dec_rypt_done
enc_dec_rypt_5:
	li $v0,SysCloseFile			# close file and output to file
	move $a0,$s5
	syscall
	li $v0,-5
	j enc_dec_rypt_done
enc_dec_rypt_6:
	li $v0,-6
	j enc_dec_rypt_done	
	
	
						# get length of string 
						# $a0 = address of string 
						# return 
						# $v0 = length of string 
strlen:
	li $v0,0
strlen_loop:
	lbu $t0,0($a0)
	beq $t0,$zero,strlen_done
	addiu $a0,$a0,1
	addi $v0,$v0,1
	j strlen_loop
strlen_done:
	jr $ra
	
						# copy source string to destination string 
						# $a0 = address of destination string 
						# $a1 = address of source string 
						# return 
strcpy:
	lb $t0,0($a1)
	beq $t0,$zero,strcpy_done
	sb $t0,0($a0)
	addiu $a0,$a0,1
	addiu $a1,$a1,1
	j strcpy
strcpy_done:
	sb $t0,0($a0)
	jr $ra 


						
strchr:
						# Returns a pointer to the first occurrence of character in the string
	lbu $t0,0($a0) 				# $v0 = A pointer to the first occurrence of character in str.
	beq $t0,$zero,strchr_0			# if character is not found, the function returns null
	beq $t0,$a1,strchr_found
	addiu $a0,$a0,1				# move over to next one
	j strchr				#repeat
strchr_found:	
	move $v0,$a0 
	jr $ra
strchr_0:
	addiu $v0,$zero,0 # return 0
	jr $ra
remove_new_line:
	lbu $t0,0($a0)				#remove the first /0
	beq $t0,$zero,remove_new_line_done	#return string adress
	beq $t0,'\n',remove_new_lineR
	addiu $a0,$a0,1
	j remove_new_line
remove_new_lineR:
	sb $zero,0($a0)
remove_new_line_done:
	jr $ra	 
	
	
	
