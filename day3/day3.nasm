; ----------------------------------------------------------------------------------------
; Writes "Hello, World" to the console using only system calls. Runs on 64-bit Linux only.
; To assemble and run:
;
;     nasm -felf64 hello.asm && ld hello.o && ./a.out
; ----------------------------------------------------------------------------------------

section .rodata
; message:        db  "Hello, World", 10 ; 10 = '\n'
; message_len     equ $ - message ; $ means the current address here

; message2:       db "Hello, World2", 10
; message2_len    equ $ - message2

file_name:      db "day3.exp", 0
file_length     equ 71

%define MAX_NUM_LEN 3

section .bss
%define buffer_len 100
buffer: resb buffer_len

%define out_buffer_len 100
out_buffer: resb out_buffer_len

global _start

section .text
    ; _start:
    ;     mov rax, 1              ; system call for write
    ;     mov rdi, 1              ; file handle 1 is stdout
    ;     mov rsi, message        ; address of string to output
    ;     mov rdx, message_len    ; number of bytes
    ;     syscall                 ; invoke operating system to do the write

    _open:
        mov rax, 2                  ; system call for open
        mov rdi, file_name          ; file name
        mov rsi, 0                  ; read-only
        mov rdx, 0                  ; mode is ignored
        syscall ; fd in rax at this point
        mov r15, rax ; put the file descriptor in r15 for safekeeping
    
    ; _test_read: ; read from the file
    ;     mov        rdx, buffer_len    ; length
    ;     mov        rsi, buffer        ; buffer
    ;     mov        rdi, r15             ; fd
    ;     mov        rax, 0               ; read syscall
    ;     syscall ; rax = number of bytes written
    
    ; _add_newline: ; add a newline to the end of the buffer if it doesn't already have one
    ;     mov r8, buffer[rax-1]
    ;     cmp r8, 10
    ;     je _newline_added
    ;     mov byte [buffer+rax], 10
    ;     inc rax
    ; _newline_added:
    
    ; _test_write: ; write to stdout
    ;     mov rdx, rax
    ;     mov rsi, buffer
    ;     mov rdi, 1
    ;     mov rax, 1
    ;     syscall

    _map_file: ; map the file to memory
        mov r9, 0   ; offset
        mov r8, r15 ; fd
        mov r10, 0x2    ; flag (private)
        mov rdx, 0x1  ; prot (read only)
        mov rsi, file_length  ; length
        mov rdi, 0  ; addr
        mov rax, 9
        syscall

        mov r14, rax ; put the address of the file in r14 for safekeeping
        mov r13, rax
        add r13, file_length
    
    ; _test:
    ;     mov rdx, file_length ; length
    ;     mov rsi, r14 ; buffer
    ;     mov rdi, 1 ; fd
    ;     mov rax, 1 ; write syscall
    ;     syscall
    
    _main:
        mov r12, 0

    _fsm_start:
        ; r14 - current position
        ; r13 - end position
        ; r12 - current sum
        ; al - current character
        ; r11 - number count
        ; r10 - number 2
        ; r9  - number 1
        ; r8 - return address

%macro read_next 3
    cmp %2, %3
    je _parse_done
    mov %1, byte [%2]
    inc %2
%endmacro


%macro accept_letter 3
    cmp %1, %2
    je %3
%endmacro

    _m:
        read_next al, r14, r13
        accept_letter al, 'm', _u
        jmp _fsm_start

    _u:
        read_next al, r14, r13
        accept_letter al, 'u', _l
        jmp _fsm_start
    
    _l:
        read_next al, r14, r13
        accept_letter al, 'l', _ob
        jmp _fsm_start
    
    _ob:
        read_next al, r14, r13
        accept_letter al, '(', _num_1
        jmp _fsm_start
    
    _num_1:
        mov r8, _num_1_end
        mov rax, _num
        jmp rax
    _num_1_end:
        mov r9, r10
        jmp _comma
    
    _comma:
        read_next al, r14, r13
        accept_letter al, ',', _num_2
        jmp _fsm_start
    
    _num_2:
        mov r8, _num_2_end
        mov rax, _num
        jmp rax
    _num_2_end:
        jmp _cb
    
    _cb:
        read_next al, r14, r13
        accept_letter al, ')', _accept
        jmp _fsm_start
    
    _accept:
        mov rax, r9
        mul r10
        add r12, rax
        jmp _fsm_start
    
    _num:
        mov r11, 0
        mov r10, 0
    _num_loop:
        mov rax, 0
        read_next al, r14, r13
        cmp al, '0'
        jl _num_end
        cmp al, '9'
        jg _num_end
        sub al, '0'
        xchg r10, rax ; swap rax and r10
        mov rdx, 10 ; use rdx as mul will but overflow into rdx
        mul rdx ; mul always multiplies rax by the operand (which must be a register or memory location)
        add rax, r10
        mov r10, rax
        add r11, 1
        cmp r11, MAX_NUM_LEN
        je _num_end
        jmp _num_loop
        
    _num_end:
        dec r14 ; move back one
        cmp r11, 0 ; if r11 is 0, then no numbers were read
        je _fsm_start
        jmp r8

    _parse_done:
        mov r14, 0
        mov r13, 10
        mov rsi, out_buffer
        mov rax, r12
    _parse_loop:
        mov rdx, 0
        div r13
        add rdx, '0'
        mov byte [rsi+r14], dl
        inc r14
        cmp rax, 0
        jne _parse_loop
        jmp _write_output

    _write_output:
        mov byte [rsi+r14], `\n` ; add a newline
        inc r14 

        mov rdx, r14
        sub rsi, r14
        mov rsi, out_buffer
        mov rdi, 1
        mov rax, 1
        syscall

    _exit:
        mov       rax, 60                 ; system call for exit
        xor       rdi, rdi                ; exit code 0
        syscall                           ; invoke operating system to exit