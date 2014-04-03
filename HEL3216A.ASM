TITLE Simple OS/2 assembly language program to display Hello world!
; HEL3216A.ASM
PAGE 0,80
.386

N32  TYPEDEF PTR NEAR32
F32  TYPEDEF PTR FAR32
F16  TYPEDEF PTR FAR16

STACK32 SEGMENT DWORD STACK FLAT 'STACK'
STACK32 ENDS

DATA32 SEGMENT DWORD PUBLIC FLAT 'DATA'
DATA32 ENDS

DATA16 SEGMENT DWORD PUBLIC USE16 'DATA'
msg  BYTE 0Dh,0Ah,'Hello World!',0Dh,0Ah ;length 16
wlen DWORD ? ;receives number of bytes written
OurStack FWORD ?
OurDS    WORD  ?
Stack16  DWORD ?
ProgAddr DWORD ? 
ReturnPoint FWORD ?       
Entry16  DWORD ?

DATA16 ENDS

EXTERN DOS16WRITE:FAR16
ASSUME ds:FLAT,ES:FLAT,SS:FLAT

CODE16 SEGMENT DWORD PUBLIC USE16 'CODE'
Start16:
call  F16 PTR FLAT:[ProgAddr]
jmp   F32 PTR FLAT:[ReturnPoint]

CODE16 ENDS

CODE32 SEGMENT DWORD PUBLIC FLAT 'CODE'
;TASM would give error message for undefined symbol: FLAT
EXTERN DOS32FLATTOSEL:NEAR

PRINT PROC NEAR
push  ebp
mov   ebp,esp
push  ebx
push  esi
push  edi
push  ebp
mov   OurDS,ds
mov   DWORD PTR OurStack,esp
mov   WORD PTR OurStack+4,ss 
mov   WORD PTR [Entry16+2],SEG Start16
mov   WORD PTR [Entry16],OFFSET Start16
mov   WORD PTR [ProgAddr+2],SEG DOS16WRITE
mov   WORD PTR [ProgAddr],OFFSET DOS16WRITE
mov   WORD PTR [ReturnPoint+4],cs
mov   DWORD PTR [ReturnPoint],OFFSET Return1
pushw 1; stdout handle
push  DATA16
push  OFFSET DATA16:msg ;segment & offset of msg
pushw 16; length of data
push  DATA16
push  OFFSET DATA16:wlen ;16:16 pointer to number of bytes written
mov   eax,esp
call  DOS32FLATTOSEL
mov   Stack16,eax
lss   sp,Stack16                            
;call  Dos16Write ;OS/2 system function
jmp   F16 PTR [Entry16]
Return1:
lss   esp,FLAT:OurStack
mov   ds,FLAT:OurDS
mov   es,FLAT:OurDS
pop   ebp
pop   edi
pop   esi
pop   ebx
or    ax,ax; was write successful?
jnz   Errer
mov   eax,0 ;return success code
leave
ret
Errer:
mov   eax,1; return error code
leave
ret
PRINT ENDP
CODE32 ENDS
END   PRINT
