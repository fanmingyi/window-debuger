.386
.model flat,stdcall
option casemap:none
include MyDebugger.Inc

.data
	g_szCmdBuf db MAXBYTE dup(0)
	
	g_szErrCmd db "���������",0dh,0ah,0 
	g_sztesttt db "����ɾ��%d",0dh,0ah,0 

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
	
	
	;TF��λ
	invoke RtlZeroMemory,addr @ctx,type @ctx
	mov @ctx.ContextFlags,CONTEXT_ALL
	invoke GetThreadContext,g_hThread,addr @ctx
	push @ctx.regEip
	pop g_dwEip
	
	
	
	;��ȡeipλ�õĻ�����
	invoke ReadMemory,g_dwEip,offset g_arrCode,g_dwCodeLen
	
	;�����
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

	
	;TF��λ
	invoke RtlZeroMemory,addr @ctx,type @ctx
	mov @ctx.ContextFlags,CONTEXT_ALL
	invoke GetThreadContext,g_hThread,addr @ctx
	or @ctx.regFlag,100h

	invoke SetThreadContext,g_hThread,addr @ctx
	
	;���ñ�־
	mov g_bIsStepCommand, TRUE
	
	ret

ExcuteTCmd endp


ExcutePCmd proc
	LOCAL @ctx:CONTEXT
	
	mov esi,offset g_aryDisAsm
	;�ж��Ƿ�λcallָ��
	.if byte ptr[esi]=='c' &&  byte ptr[esi+1]=='a' &&  byte ptr[esi+2]=='l' &&  byte ptr[esi+3]=='l'
		
		;call ָ�� ����һ��������ʱ�ϵ�
		mov eax,g_dwEip
		add eax,g_dwDisCodeLen
		invoke SetBreakPoint,eax,TRUE
	.elseif
		;��callָ����
		invoke	ExcuteTCmd	
	.endif
	
	ret

ExcutePCmd endp



SkipWhiteChart proc uses edi pCommand:dword ;�����հ��ַ�
	
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
	

	;����
	.while TRUE
		;��ȡһ��
		invoke crt_gets,offset g_szCmdBuf
		
		;��������ǰ��Ŀհ��ַ�
		invoke SkipWhiteChart,offset g_szCmdBuf
		mov @pCmd,eax
		;�ж�����
		mov esi,@pCmd
		.if byte ptr[esi]=='b' && byte ptr [esi+1]=='p'
			
			add @pCmd,2 ;����bp�ַ�
			
			mov esi,@pCmd
			.if byte ptr [esi] == 'l'
			
				;------------------------------
				; ɾ���ϵ� pbl
				;------------------------------
			
			
				;��ʾ�ϵ��б�
				invoke ListBreakPoint
			
			
			.elseif byte ptr[esi]=='c'
			
				
				;------------------------------
				; ɾ���ϵ� pbc 
				;------------------------------
		
				inc @pCmd
				;���öϵ�
				invoke SkipWhiteChart,@pCmd
				mov @pCmd,eax
			
				;����bpc����
				invoke crt_strtoul,@pCmd,addr @pEnd,10;ת16����
				mov edx,@pEnd
				;�������0
				.if  @pCmd ==edx
					invoke crt_printf,offset g_szErrCmd
					.continue
				.endif
			
				
				
				;invoke crt_printf,offset g_sztesttt,eax
				
				;ɾ���ϵ�
				invoke DelBreakPoint,eax
			
			.else
			
				;------------------------------
				;���öϵ� pb
				;------------------------------
		
			
				;���öϵ�
				invoke SkipWhiteChart,@pCmd
				mov @pCmd,eax
			
				;����bp�����ַ
				invoke crt_strtoul,@pCmd,addr @pEnd,16;ת16����
				mov edx,@pEnd
				;�������0
				.if eax ==0 || @pCmd ==edx
					invoke crt_printf,offset g_szErrCmd
					.continue
				.endif
			
				;���öϵ�
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