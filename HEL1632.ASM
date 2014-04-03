TITLE OS/2 assembly language program to display Hello world!
; HEL1632.ASM
PAGE 0,80
.386
;For 16 bit OS/2 2.0 using DOS32WRITE
N32  TYPEDEF PTR NEAR32
F32  TYPEDEF PTR FAR32
F16  TYPEDEF PTR FAR16

STACK16 SEGMENT DWORD STACK USE16 'STACK'
STACK16 ENDS

ASSUME ds:DGROUP,ss:STACK16

DATA32 SEGMENT DWORD PUBLIC FLAT 'DATA'
DATA32 ENDS
; DATA32 segment must come before DATA16 segment, otherwise FLAT selector will
; be wrong

DATA16 SEGMENT DWORD PUBLIC USE16 'DATA'
msg  BYTE 0Dh,0Ah,'Hello World!',0Dh,0Ah ;length 16
Nparams  BYTE ? ;value to be placed in AL on call to 32-bit API
wlen DWORD ? ;receives number of bytes written
OurStack DWORD ?
OurDS    WORD  ?
Stack32  FWORD ?    
ProgAddr DWORD ?
ReturnPoint DWORD ?
Entry32  FWORD ?             
DATA16 ENDS
                                      
DGROUP GROUP DATA16
EXTERN DOS16SELTOFLAT:FAR16,DOS16FLATTOSEL:FAR16,DOS16EXIT:FAR16

CODE32 SEGMENT DWORD PUBLIC FLAT 'CODE'
EXTERN DOS32WRITE:NEAR, DOS32EXIT:NEAR
Start32:            
mov   ax,SEG FLAT:DATA32
mov   ds,ax ;set up FLAT context
mov   es,ax                       
mov   al,gs:Nparams
call  N32 PTR gs:[ProgAddr]
; Designed to be usable for any call to 32-bit API, thus avoiding repetitious
; coding in the case of many different 32-bit API calls
;mov   bx,DGROUP
;mov   gs,bx ;needed only if 32-bit API resets gs without restoring
; But apparently OS/2 operating system doesn't disturb GS
jmp   F16 PTR gs:[ReturnPoint]                                       
CODE32 ENDS

CODE16 SEGMENT DWORD PUBLIC USE16 'CODE'

PRINT:
push  ds
pop   gs ;keep reference to DATA16, if this be OK with OS/2
; Apparently OS/2 uses DS, ES and FS but not GS, so we are free to use GS
mov   OurDS,ds
mov   ProgAddr,OFFSET FLAT:DOS32WRITE
mov   WORD PTR ReturnPoint+2,cs
mov   WORD PTR ReturnPoint,OFFSET Return1; set up return address
mov   WORD PTR OurStack+2,ss
mov   WORD PTR OurStack,sp
mov   DWORD PTR Entry32,OFFSET FLAT:Start32
mov   WORD PTR Entry32+4,SEG FLAT:CODE32
mov   ax,DGROUP
shl   eax,16; create 16:16 pointer to convert to FLAT 0:32
mov   ax,OFFSET wlen
call  DOS16SELTOFLAT
push  eax          
pushd 16 ;length of message
mov   ax,DGROUP
shl   eax,16
mov   ax,OFFSET msg
call  DOS16SELTOFLAT
push  eax
pushd 1; stdout handle
;mov   ax,SEG FLAT:DATA32 ;see in IPMD if this is 53 or 5B or other
mov   ax,ss
shl   eax,16
mov   ax,sp
call  DOS16SELTOFLAT
mov   DWORD PTR Stack32,eax
mov   WORD PTR Stack32+4,SEG FLAT:DATA32
lss   esp,Stack32 
mov   DGROUP:Nparams,4; number of parameters to DOS32WRITE
jmp   F32 PTR DGROUP:[Entry32]; 32-bit call will be done from there
;call  Dos32Write ;OS/2 system function
Return1:
mov   bx,DGROUP
mov   ds,bx
lss   sp,ds:OurStack
or    eax,eax; was write successful?
jnz   Errer
pushw 0;return code
pushw 1; action code: end all threads in process
call  DOS16EXIT
Errer:
pushw 1
pushw 1
call  DOS16EXIT
CODE16 ENDS
END   PRINT
