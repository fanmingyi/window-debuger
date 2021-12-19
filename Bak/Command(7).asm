.386
.model flat,stdcall
option casemap:none
include MyDebugger.Inc

.data
	g_szCmdBuf db MAXBYTE dup(0)
	
	g_szErrCmd db "���������",0dh,0ah,0 
	g_sztesttt db "����ɾ��%d",0dh,0ah,0 

.code


SkipWhiteChart proc uses edi pCommand:dword ;�����հ��ַ�
	
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
		
			
				;���öϵ�
				invoke SkipWhiteChart,@pCmd
				mov @pCmd,eax
			
				;����bpc����
				invoke crt_strtoul,@pCmd,addr @pEnd,16;ת16����
				mov edx,@pEnd
				;�������0
				.if  @pCmd ==edx
					invoke crt_printf,offset g_szErrCmd
					.continue
				.endif
			
				
				invoke crt_printf,offset g_sztesttt,edx
				
				;ɾ���ϵ�
				invoke DelBreakPoint,0
			
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
		
		.else
			invoke crt_printf,offset g_szErrCmd
			
		.endif		
		
	
	.endw
	
	
	mov eax,@dwStatus
	
	ret

ParseCommand endp





end