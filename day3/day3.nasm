; ----------------------------------------------------------------------------------------
; Writes "Hello, World" to the console using only system calls. Runs on 64-bit Linux only.
; To assemble and run:
;
;     nasm -felf64 hello.asm && ld hello.o && ./a.out
; ----------------------------------------------------------------------------------------

section .data
message:        db  "Hello, World", 10 ; 10 = '\n'
message_len     equ $ - message ; $ means the current address here

message2:       db "Hello, World2", 10
message2_len    equ $ - message2

file_name:      db "day3.exp", 0

section .bss
%define buffer_len 100
buffer: resb buffer_len


global _start

section .text
    _start:
        mov rax, 1              ; system call for write
        mov rdi, 1              ; file handle 1 is stdout
        mov rsi, message        ; address of string to output
        mov rdx, message_len    ; number of bytes
        syscall                 ; invoke operating system to do the write

    _open:
        mov rax, 2                  ; system call for open
        mov rdi, file_name          ; file name
        mov rsi, 0                  ; read-only
        mov rdx, 0                  ; mode is ignored
        syscall ; fd in rax at this point
        mov r15, rax ; put the file descriptor in r15 for safekeeping
    
    _test_read: ; read from the file
        mov        rdx, buffer_len    ; length
        mov        rsi, buffer        ; buffer
        mov        rdi, r15             ; fd
        mov        rax, 0               ; read syscall
        syscall ; rax = number of bytes written
    
    _add_newline: ; add a newline to the end of the buffer if it doesn't already have one
        mov r8, buffer[rax-1]
        cmp r8, 10
        je _newline_added
        mov byte [buffer+rax], 10
        inc rax
    _newline_added:
    
    _test_write: ; write to stdout
        mov rdx, rax
        mov rsi, buffer
        mov rdi, 1
        mov rax, 1
        syscall

    _map_file: ; map the file to memory
        mov r9, 0   ; offset
        mov r8, r15 ; fd
        mov r10, 0x2    ; flag (private)
        mov rdx, 0x1  ; prot (read only)
        mov rsi, 5  ; length
        mov rdi, 0  ; addr
        mov rax, 9
        syscall
    
    _test:
        mov rdx, 5
        mov rsi, rax
        mov rdi, 1
        mov rax, 1
        syscall

    _exit:
        mov       rax, 60                 ; system call for exit
        xor       rdi, rdi                ; exit code 0
        syscall                           ; invoke operating system to exit