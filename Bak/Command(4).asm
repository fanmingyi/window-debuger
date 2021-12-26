.386
.model flat,stdcall
option casemap:none
include MyDebugger.Inc

.data
	g_szCmdBuf db MAXBYTE dup(0)
	
	g_szErrCmd db "错误的命令",0dh,0ah,0 
	g_sztesttt db "调用删除%d",0dh,0ah,0 

	g_arrCode db 32 dup(0)
 	g_dwCodeLen dd $-offset g_arrCode
	g_aryDisAsm db 256 dup(0)
	g_aryHex db 256 dup (0)
	g_dwDisCodeLen dd 0
	g_dwEip dd 00401000h
	g_szShowDisasmFmt db "%08X %- 16s %s",0dh,0ah,0
.code

ShowDisAsm proc
	LOCAL @ctx:CONTEXT
	
	
	;TF置位
	invoke RtlZeroMemory,addr @ctx,type @ctx
	mov @ctx.ContextFlags,CONTEXT_ALL
	invoke GetThreadContext,g_hThread,addr @ctx
	push @ctx.regEip
	pop g_dwEip
	
	
	
	;读取eip位置的机器码
	invoke ReadMemory,g_dwEip,offset g_arrCode,g_dwCodeLen
	
	;返汇编
	invoke DisAsm,offset g_arrCode, g_dwCodeLen,g_dwEip,offset g_aryDisAsm,offset g_aryHex,offset g_dwDisCodeLen
	
	
	invoke crt_printf,offset g_szShowDisasmFmt,g_dwEip,offset g_aryHex,offset g_aryDisAsm

	
	ret
	
	;or @ctx.regFlag,100h
	;dec @ctx.regEip
	;invoke SetThreadContext,g_hThread,addr @ctx
	ret

ShowDisAsm endp



ExcuteTCmd proc
	LOCAL @ctx:CONTEXT

	
	;TF置位
	invoke RtlZeroMemory,addr @ctx,type @ctx
	mov @ctx.ContextFlags,CONTEXT_ALL
	invoke GetThreadContext,g_hThread,addr @ctx
	or @ctx.regFlag,100h

	invoke SetThreadContext,g_hThread,addr @ctx
	
	;设置标志
	mov g_bIsStepCommand, TRUE
	
	ret

ExcuteTCmd endp


ExcutePCmd proc
	LOCAL @ctx:CONTEXT
	
	mov esi,offset g_aryDisAsm
	;判断是否位call指令
	.if byte ptr[esi]=='c' &&  byte ptr[esi+1]=='a' &&  byte ptr[esi+2]=='l' &&  byte ptr[esi+3]=='l'
		
		;call 指令 在下一行设置临时断点
		mov eax,g_dwEip
		add eax,g_dwDisCodeLen
		invoke SetBreakPoint,eax,TRUE
	.elseif
		;非call指令与
		invoke	ExcuteTCmd	
	.endif
	
	ret

ExcutePCmd endp



SkipWhiteChart proc uses edi pCommand:dword ;跳过空白字符
	
	mov edi,pCommand
	
	.while byte ptr[edi] == ' ' || byte  ptr [edi]==9
	 	add edi,1	
	.endw
	mov eax,edi

	ret

SkipWhiteChart endp

 
ParseCommand proc uses esi 
	LOCAL @dwStatus:DWORD
	LOCAL @pCmd:DWORD
	LOCAL @pEnd:DWORD
	
	
	invoke ShowDisAsm
	mov @dwStatus,DBG_CONTINUE
	

	;解析
	.while TRUE
		;获取一行
		invoke crt_gets,offset g_szCmdBuf
		
		;跳过命令前面的空白字符
		invoke SkipWhiteChart,offset g_szCmdBuf
		mov @pCmd,eax
		;判断命令
		mov esi,@pCmd
		.if byte ptr[esi]=='b' && byte ptr [esi+1]=='p'
			
			add @pCmd,2 ;跳过bp字符
			
			mov esi,@pCmd
			.if byte ptr [esi] == 'l'
			
				;------------------------------
				; 删除断点 pbl
				;------------------------------
			
			
				;显示断点列表
				invoke ListBreakPoint
			
			
			.elseif byte ptr[esi]=='c'
			
				
				;------------------------------
				; 删除断点 pbc 
				;------------------------------
		
				inc @pCmd
				;设置断点
				invoke SkipWhiteChart,@pCmd
				mov @pCmd,eax
			
				;解析bpc命令
				invoke crt_strtoul,@pCmd,addr @pEnd,10;转16进制
				mov edx,@pEnd
				;如果返回0
				.if  @pCmd ==edx
					invoke crt_printf,offset g_szErrCmd
					.continue
				.endif
			
				
				
				;invoke crt_printf,offset g_sztesttt,eax
				
				;删除断点
				invoke DelBreakPoint,eax
			
			.else
			
				;------------------------------
				;设置断点 pb
				;------------------------------
		
			
				;设置断点
				invoke SkipWhiteChart,@pCmd
				mov @pCmd,eax
			
				;解析bp命令地址
				invoke crt_strtoul,@pCmd,addr @pEnd,16;转16进制
				mov edx,@pEnd
				;如果返回0
				.if eax ==0 || @pCmd ==edx
					invoke crt_printf,offset g_szErrCmd
					.continue
				.endif
			
				;设置断点
				invoke SetBreakPoint,eax,FALSE		
			.endif
			
			
			
			
			
		.elseif  byte ptr[esi]=='u'
		
		.elseif byte ptr[esi]=='g'
		
			mov eax,DBG_CONTINUE
			ret
		
		
		
		.elseif byte ptr[esi]=='t'
			invoke ExcuteTCmd
			mov eax,DBG_CONTINUE
			ret
		.elseif byte ptr[esi]=='p'
			invoke ExcutePCmd
			mov eax,DBG_CONTINUE
			ret
		.else
			invoke crt_printf,offset g_szErrCmd
			
		.endif		
		
	
	.endw
	
	
	mov eax,@dwStatus
	
	ret

ParseCommand endp





end