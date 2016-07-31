		.386
		.model flat,stdcall
		option casemap:none

include	windows.inc
include	user32.inc
include	kernel32.inc
include	msvcrt.inc
includelib	msvcrt.lib
includelib	user32.lib
includelib	kernel32.lib

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;功能:----定义字符串到常量段---返回首地址
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
L	macro	@var:VARARG
	LOCAL	@lbl
	.const
	@lbl		db	@var,0
	.code
	exitm	<offset @lbl>
endm

.data
