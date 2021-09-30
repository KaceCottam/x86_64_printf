section           .text
strlen:
push              rcx
mov               rcx, 0
.L0:
cmp               byte [rax], 0
jz                .exit
add               rax, 1
add               rcx, 1
jmp               .L0
.exit:
mov               rax, rcx
pop               rcx
ret

myprintf:
%define           fmt [rsp+8]
%define           arg1 [rsp+16]
%define           arg2 [rsp+24]
%define           arg3 [rsp+32]
%define           current_arg [rsp+48]
%define           temp [rsp+56]

%macro            get_next_argument 1
mov               temp, rbx              ; save rbx
mov               rbx, current_arg       ; get current arg
mov               %1, [rsp+rbx*8]        ; get next argument
add               rbx, 1                 ; increment
mov               current_arg, rbx       ; replace current arg var
mov               rbx, temp              ; load rbx
%endmacro

                                         ; increment a memory location by a size
%macro            increment 1
mov               temp, rdx
mov               rdx, %1
add               rdx, 1
mov               %1, rdx
mov               rdx, temp
%endmacro

add               rsp, 64
mov               fmt, rax               ; save all arguments
mov               arg1, rbx
mov               arg2, rcx
mov               arg3, rdx
mov               rax, dword 2
mov               current_arg, rax       ; let us keep track of a current_arg that starts at arg 2
jmp               .L0

.L00:
increment         fmt                    ; need to increment fmt by 1 byte
                                         ; then continue
.L0:                                     ; while
mov               rax, fmt               ; fmt
cmp               byte [rax], 0          ; != 0
jnz               .L1                    ; if not 0, goto single character write
jz                .exit                  ; else, goto exit

.L1:                                     ; parse a character
cmp               byte [rax], '%'        ; if this is not a '%'
jne               .L3                    ; we do not need special parsing
.L2:                                     ; else we are doing special parse
increment         fmt
mov               rax, fmt               ; look at next character
cmp               byte [rax], '%'        ; if "%%"
je                .L2                    ; need to print '%'
cmp               byte [rax], 'c'        ; if "%c"
je                .L3.character          ; need to print next argument
cmp               byte [rax], 's'        ; if "%s"
je                .L3.string             ; need to print next argument
cmp               byte [rax], 'd'        ; if "%s"
je                .L3.integer            ; need to print next argument
jmp               .error

.L3:                                     ; print a single character
mov               rsi, fmt               ; set buffer pointer to fmt
mov               rax, 1                 ; set syscall to write
mov               rdi, 1                 ; write to fd=1
mov               rdx, 1                 ; write 1 character
syscall                                  ; do syscall
jmp               .L00                   ; return to loop

.L3.character:
get_next_argument rax
mov               temp, rax
mov               rax, 1                 ; set syscall to write
mov               rdi, 1                 ; write to fd=1
mov               rsi, rsp               ; set buffer pointer to fmt
add               rsi, 56
mov               rdx, 1                 ; write 1 character
syscall                                  ; do syscall
jmp               .L00                   ; return to loop

.L3.string:
get_next_argument rax
mov               temp, rax
call              strlen
mov               rdx, rax
mov               rax, 1
mov               rdi, 1
mov               rsi, temp
syscall
jmp               .L00
.L3.integer:
get_next_argument rax
mov               rdx, rsp
mov               rbx, rax
cmp               rax, 0
mov               rdi, 0                 ; let rdi=len of string i need to print
jl                .L3.integer.lessThan0
jmp               .L3.integer.loop
.L3.integer.lessThan0:
push              rax
mov               temp, byte '-'         ; print '-' sign
mov               rax, 1
mov               rdi, 1
mov               rsi, rsp
add               rsi, 56
mov               rdx, 1
syscall
pop               rax
mov               rdi, 0
neg               rax
.L3.integer.loop:
                                         ; print "9876543210123456789" [10 + (tmp_value - value * base)] while value != 0
mov               rsi, rax               ; let rax be value, let rsi be tmp_value, base = 10
mov               rdx, 0                 ; clear dividend
mov               rcx, 10                ; divide by 10
div               rcx                    ; rax = div, rdx = mod                                                           ; let rax be value
mov               rbx, rax               ; copy rax                                                                       ; let rbx be value
mov               rax, 10                ; let rax be rbx*10
mul               rbx                    ; mult by rbx
mov               rdx, rsi               ; let rdx be tmp_value
sub               rdx, rax               ; let rdx be tmp_value - value*10
add               rdx, integerConversion ; let rdx be "0123456789" + (tmp_value - value * 10)
movsx             rdx, byte [rdx]        ; get character at the correct location
push              rdx                    ; add printed character to list of chars to print
add               rdi, 1                 ; increment # characters
mov               rax, rbx               ; let rax be value again
cmp               rax, 0                 ; while(value)
jnz               .L3.integer.loop
.L3.integer.print:
shl               rdi, 3
mov               rbx, rdi               ; need to remove rsp allocation later
mov               rdx, rdi
mov               rax, 1
mov               rdi, 1
mov               rsi, rsp
syscall
add               rsp, rbx
jmp               .L00


.error:
mov               rax, 1
mov               rdi, 1
mov               rsi, errorMsg
mov               rdx, errorMsgLen
syscall

.exit:                                   ; exit function
mov               rdx, arg3              ; restore all arguments
mov               rcx, arg2
mov               rbx, arg1
mov               rax, fmt
sub               rsp, 64
%undef            temp
%undef            arg3
%undef            arg2
%undef            arg1
%undef            fmt
%undef            get_next_argument
%undef            increment
ret

section           .data
errorMsg          db  0xa, "Error printing string", 0xa
errorMsgLen       equ $ - errorMsg
integerConversion db "0123456789"        ; spooky magic string for printing integers

section           .text
global            _start
_start:
mov               rax, hello
mov               rbx, world
mov               rcx, dword '!'
mov               rdx, qword -10245
call              myprintf

mov               rax, 60                ; good exit
mov               rdi, 0
syscall

section           .data
hello             db "Hello %s%c [%d]", 0xa, 0x0
world             db "world", 0x0
