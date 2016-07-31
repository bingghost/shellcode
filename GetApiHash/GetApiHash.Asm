		.386
		.model	flat,stdcall
		option	casemap:none

include	windows.inc
include	user32.inc
include	kernel32.inc
include	msvcrt.inc
includelib	msvcrt.lib
includelib	user32.lib
includelib	kernel32.lib

;                   _ooOoo_
;                  o8888888o
;                  88" . "88
;                  (| -_- |)
;                  O\  =  /O
;               ____/`---'\____
;             .'  \\|     |//  `.
;            /  \\|||  :  |||//  \
;           /  _||||| -:- |||||-  \
;           |   | \\\  -  /// |   |
;           | \_|  ''\---/''  |   |
;           \  .-\__  `-`  ___/-. /
;         ___`. .'  /--.--\  `. . __
;      ."" '<  `.___\_<|>_/___.'  >'"".
;     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
;     \  \ `-.   \_ __\ /__ _/   .-` /  /
;======`-.____`-.___\_____/___.-`____.-'======
;                   `=---='
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;       佛祖保佑    永无BUG   永不修改


L	macro	var:VARARG
	LOCAL	@Lbl
	.const	
	@Lbl		db	var,0
	.code
	exitm	<offset @Lbl>
endm
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;Data Segment
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.data?

		.const


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;Code Segment
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		.code

;00401000                                  /$  8B5424 04     mov edx,dword ptr ss:[esp+0x4]
;00401004                                  |.  8A0A          mov cl,byte ptr ds:[edx]
;00401006                                  |.  33C0          xor eax,eax
;00401008                                  |.  84C9          test cl,cl
;0040100A                                  |.  74 15         je short hash.00401021
;0040100C                                  |.  8D6424 00     lea esp,dword ptr ss:[esp]
;00401010                                  |>  0FBEC9        /movsx ecx,cl
;00401013                                  |.  C1C8 07       |ror eax,0x7
;00401016                                  |.  83C2 01       |add edx,0x1
;00401019                                  |.  03C1          |add eax,ecx
;0040101B                                  |.  8A0A          |mov cl,byte ptr ds:[edx]
;0040101D                                  |.  84C9          |test cl,cl
;0040101F                                  |.^ 75 EF         \jnz short hash.00401010
;00401021                                  \>  C3            retn

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;功  能:计算API的Hash值
;参  数:
;   edx = 字符串首地址
;返回值:
;   返回API名的Hash值
;备  注:
;   use eax,edx,ecx
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_GetApiHash proc 
  
  xor eax,eax
  test edx,edx
  je END_FUN
  
  mov cl,byte ptr ds:[edx]
  test cl,cl
  je END_FUN

LOOP_HASH:
  movsx ecx,cl
  ror eax,7h
  add edx,1h
  add eax,ecx
  mov cl,byte ptr ds:[edx]
  test cl,cl
  jnz LOOP_HASH
  
END_FUN:
  ret

_GetApiHash endp


;GetApiHash proc uses uses esi ebx ecx lpApiName:DWORD
;  
;  mov  edx,lpApiName
;	call _GetApiHash
;  ret
;
;GetApiHash endp

GetApiHash macro lpApiName
  
  .code
  mov  edx,lpApiName
	call _GetApiHash

endm


_Main		proc
	
  GetApiHash(L("MessageBoxA"));
	invoke	crt_printf,L("MessageBoxA",9h,"%X",0ah,0dh),eax
	
	GetApiHash(L("LoadLibraryA"));
	invoke	crt_printf,L("LoadLibraryA",9h,"%X",0ah,0dh),eax
	
  GetApiHash(L("ExitProcess"));
	invoke	crt_printf,L("ExitProcess",9h,"%X",0ah,0dh),eax
	
	GetApiHash(L("WinExec"));
	invoke	crt_printf,L("WinExec",9h,"%X",0ah,0dh),eax
	
	GetApiHash(L("MessageBoxA"));
	invoke	crt_printf,L("MessageBoxA",9h,"%X",0ah,0dh),eax
	
	GetApiHash(L("MessageBoxA"));
	invoke	crt_printf,L("MessageBoxA",9h,"%X",0ah,0dh),eax
	
	
	ret

_Main endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
	call 		_Main
	invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

End start