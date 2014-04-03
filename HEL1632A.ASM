TITLE 16 to 32 thunking OS/2 assembly language program to display Hello world!
; HEL1632A.ASM
PAGE 0,80
.386         
N32  TYPEDEF PTR NEAR32
F32  TYPEDEF PTR FAR32
F16  TYPEDEF PTR FAR16

;STACK32 SEGMENT DWORD STACK FLAT 'STACK'
;STACK32 ENDS                     

STACK16 SEGMENT DWORD STACK USE16 'STACK'
STACK16 ENDS       
ASSUME ss:STACK16

DATA32 SEGMENT DWORD PUBLIC FLAT 'DATA'
msg  BYTE 0Dh,0Ah,'Hello World!',0Dh,0Ah ;length 16
Nparams  BYTE ?
wlen DWORD ? ;receives number of bytes written
ProgAddr DWORD ?
OurStack DWORD ?
OurDS    WORD  ?
Stack32  FWORD ?
ReturnPoint DWORD ?       
Entry32  FWORD ?
DATA32 ENDS            

DATA16 SEGMENT DWORD PUBLIC USE16 'DATA'
DATA16 ENDS

DGROUP GROUP DATA16
EXTERN DOS16SELTOFLAT:FAR16,DOS16FLATTOSEL:FAR16,DOS16EXIT:FAR16

CODE32 SEGMENT DWORD PUBLIC FLAT 'CODE'
ASSUME es:FLAT
EXTERN Dos32Write:NEAR;, DOS32EXIT:NEAR
Start32:                              
call  N32 PTR es:[ProgAddr]
jmp   F16 PTR es:[ReturnPoint]
CODE32 ENDS

CODE16 SEGMENT DWORD PUBLIC USE16 'CODE'

ASSUME ds:DGROUP

PRINT:   
mov   ax,SEG FLAT:DATA32
mov   es,ax                                           
mov   DWORD PTR es:Entry32,OFFSET FLAT:Start32
mov   WORD PTR es:Entry32+4,SEG FLAT:CODE32
mov   es:ProgAddr,OFFSET Dos32Write
mov   es:OurDS,ds
mov   WORD PTR es:OurStack+2,ss
mov   WORD PTR es:OurStack,sp
mov   WORD PTR es:ReturnPoint+2,cs
mov   WORD PTR es:ReturnPoint,OFFSET Return1 ;set up return jmp
push  OFFSET FLAT:wlen
pushd 16; length of data
push  OFFSET FLAT:msg
pushd 1; stdout handle
mov   ax,ss ;set up stack pointer and switch to flat form
shl   eax,16
mov   ax,sp
call  DOS16SELTOFLAT
mov   DWORD PTR es:Stack32,eax ;flat offset
mov   WORD PTR es:Stack32+4,SEG FLAT:DATA32
lss   esp,es:Stack32
mov   ds,WORD PTR es:Stack32+4
mov   al,4 ;denote 4 parameters
jmp   F32 PTR es:[Entry32] 
;add   esp,10h: not necessary because stack pointer will be restored to 16-bit    
Return1:                                
mov   bx,DGROUP
mov   ds,bx
lss   sp,es:OurStack ;restore to 16-bit
or    eax,eax; was write successful?
jnz   Errer        
pushw 0
pushw 1
call  DOS16EXIT
Errer: 
pushw 1
pushw 1
call  DOS16EXIT
CODE16 ENDS
END   PRINT
