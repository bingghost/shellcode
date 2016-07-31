
# 自制shellcode框架

>* GetAPIHash 计算API函数名称的hash值 用于减小shellcode体积
>* MsgBox shellcode 弹出msgbox例子
>* ShellcodeCalc  弹出计算机例子
>
>* 生成的代码可以直接拷贝任意进程的任意位置
>* 将当前eip指过去即可执行完shellcode
>* 
>* 不用在特意考虑重定位问题