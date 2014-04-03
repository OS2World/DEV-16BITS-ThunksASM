TITLE OS/2 assembly language program to display Hello world!             
; calling 16-bit API from 32-bit module
.LIST
; HEL3216.ASM
PAGE 0,80
.386
;For 32 bit OS/2 2.0 using DOS16WRITE
N32  TYPEDEF PTR NEAR32
F32  TYPEDEF PTR FAR32
F16  TYPEDEF PTR FAR16
STACK32 SEGMENT DWORD STACK FLAT 'STACK'
STACK32 ENDS

DATA32 SEGMENT DWORD PUBLIC FLAT 'DATA'
msg  BYTE 0Dh,0Ah,'Hello World!',0Dh,0Ah ;length 16
wlen WORD ? ;receives number of bytes written
OurStack FWORD ?
OurDS    WORD  ?
Stack16  DWORD ?
ProgAddr DWORD ? 
ReturnPoint FWORD ?       
Entry16  DWORD ?
DATA32 ENDS

EXTERN DOS16WRITE:FAR16, DOS16EXIT:FAR16       
ASSUME ds:FLAT,ES:FLAT,SS:FLAT

CODE16 SEGMENT DWORD PUBLIC USE16 'CODE'
Start16:        
; This method of indirect calls and jumps enables the code to be reusable for
; any number of 16-bit API calls instead of using separate code for each API
; function called
call  F16 PTR FLAT:[ProgAddr]
jmp   F32 PTR FLAT:[ReturnPoint]

CODE16 ENDS

CODE32 SEGMENT DWORD PUBLIC FLAT 'CODE'
;should it be EXTERN DOS16WRITE:NEAR?   
EXTERN DOS32FLATTOSEL:NEAR, DOS32SELTOFLAT:NEAR
ASSUME ds:FLAT,ES:FLAT,SS:FLAT

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
pushw 1; stdout handle for DOS16WRITE
mov   eax,OFFSET msg; DOSFLATTOSEL and DOSSELTOFLAT take parameter in EAX
call  DOS32FLATTOSEL
push  eax ;seg & offset of msg  
pushw 16 ;length of message
mov   eax,OFFSET wlen
call  DOS32FLATTOSEL
push  eax; seg & offset of wlen
mov   eax,esp
call  DOS32FLATTOSEL
mov   Stack16,eax
lss   sp,Stack16                            
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
