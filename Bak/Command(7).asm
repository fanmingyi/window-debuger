.386
.model flat,stdcall
option casemap:none
include MyDebugger.Inc

.data
	g_szCmdBuf db MAXBYTE dup(0)
	
	g_szErrCmd db "错误的命令",0dh,0ah,0 
	g_sztesttt db "调用删除%d",0dh,0ah,0 

.code


SkipWhiteChart proc uses edi pCommand:dword ;跳过空白字符
	
	mov edi,pCommand
	
	.while byte ptr[edi] == ' ' || byte  ptr [edi]==9
	 	add edi,1	
	.endw
	mov eax,edi

	ret

SkipWhiteChart endp

 
ParseCommand proc
	LOCAL @dwStatus:DWORD
	LOCAL @pCmd:DWORD
	LOCAL @pEnd:DWORD
	
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
		
			
				;设置断点
				invoke SkipWhiteChart,@pCmd
				mov @pCmd,eax
			
				;解析bpc命令
				invoke crt_strtoul,@pCmd,addr @pEnd,16;转16进制
				mov edx,@pEnd
				;如果返回0
				.if  @pCmd ==edx
					invoke crt_printf,offset g_szErrCmd
					.continue
				.endif
			
				
				invoke crt_printf,offset g_sztesttt,edx
				
				;删除断点
				invoke DelBreakPoint,0
			
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
		
		.else
			invoke crt_printf,offset g_szErrCmd
			
		.endif		
		
	
	.endw
	
	
	mov eax,@dwStatus
	
	ret

ParseCommand endp





end