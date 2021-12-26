.586
.model flat,stdcall
option casemap:none

include MyDebugger.Inc


.data
	g_pBpListHead dd NULL
	g_dwNumber dd 0
	g_szList db "�ϵ��б�",0dh,0ah,0
	g_szFmt db "%d %08X",0dh,0ah,0 
g_szFmtxxx db "looping",0dh,0ah,0 

.code

;bIsTmp:�Ƿ�����ʱ�ϵ�
SetBreakPoint proc uses edi dwAddr:DWORD,bIsTmp:DWORD
	LOCAL @bpdata:BpData
	LOCAL @btCodeCC:BYTE
	
	
	
	push dwAddr
	pop @bpdata.m_dwAddr
	push bIsTmp
	pop @bpdata.m_bIsTmp
	push g_dwNumber
	pop @bpdata.m_dwNumber
	inc g_dwNumber;�ϵ����л�����

	
	;����ɵ�
	lea edi,@bpdata.m_bt01dCode
	invoke ReadMemory,dwAddr,edi,type @bpdata.m_bt01dCode
	
	
	;д��cc
	mov @btCodeCC,0cch
	invoke WriteMemory,dwAddr,addr @btCodeCC,type @btCodeCC
	
	
	;��������
	invoke PushBack,g_pBpListHead,addr @bpdata , type @bpdata
	mov g_pBpListHead,eax	

	 
	
	xor eax,eax
	ret
SetBreakPoint endp

DelBreakPoint proc uses esi edi ebx dwNumber:DWORD

	mov esi,g_pBpListHead
	assume esi:ptr Node
	.while esi !=NULL
	
		invoke crt_printf,offset g_szFmtxxx
		
		mov edi,[esi].m_pUserData
		assume edi:ptr BpData
		
		mov eax,dwNumber
		
		.if [edi].m_dwNumber== eax
			;��ԭָ��
			lea ebx,[edi].m_bt01dCode
			invoke WriteMemory,[edi].m_dwAddr,ebx,type [edi].m_bt01dCode
			;ɾ���ڵ�
			invoke DeleteNode,g_pBp	ListHead,esi
			mov g_pBpListHead,eax 
			
			ret
		.endif
		
		assume edi:nothing
		mov esi,[esi].m_pNext
		
	.endw
	
	assume esi:nothing


	ret
DelBreakPoint endp




ListBreakPoint proc uses esi edi
	invoke crt_printf,offset g_szList
	mov esi,g_pBpListHead
	assume esi:ptr Node
	.while esi !=NULL
	
		mov edi,[esi].m_pUserData
		assume edi:ptr BpData
		
		invoke crt_printf,offset g_szFmt,[edi].m_dwNumber,[edi].m_dwAddr
		
		assume edi:nothing
		mov esi,[esi].m_pNext
		
	.endw
	assume esi:nothing
	ret
ListBreakPoint endp

ResCode proc uses edi ebx bBpData:ptr BpData
	LOCAL @ctx:CONTEXT
	
	
	;�ָ�ָ��
	mov edi,bBpData
	assume edi:ptr BpData
	lea ebx,[edi].m_bt01dCode
	invoke WriteMemory,[edi].m_dwAddr,ebx,type [edi].m_bt01dCode
	
	
	
	ret	
ResCode endp
	

SetTFDecEip proc  bTF:BOOL,dwCount:DWORD
	LOCAL @ctx:CONTEXT
	;TF��λ
	invoke RtlZeroMemory,addr @ctx,type @ctx
	mov @ctx.ContextFlags,CONTEXT_ALL
	invoke GetThreadContext,g_hThread,addr @ctx
	
	.if bTF ==TRUE
		or @ctx.regFlag,100h
	.else
		
	.endif

	
	mov eax,dwCount
	sub @ctx.regEip,eax
	invoke SetThreadContext,g_hThread,addr @ctx
	ret
SetTFDecEip endp 

ResCodeAndSetSingStep proc  proc uses edi ebx  bBpData:ptr BpData
	LOCAL @ctx:CONTEXT
	
	
	;�ָ�ָ��
	mov edi,bBpData
	assume edi:ptr BpData
	lea ebx,[edi].m_bt01dCode
	invoke WriteMemory,[edi].m_dwAddr,ebx,type [edi].m_bt01dCode
	
	;TF��λ
	invoke RtlZeroMemory,addr @ctx,type @ctx
	mov @ctx.ContextFlags,CONTEXT_ALL
	invoke GetThreadContext,g_hThread,addr @ctx
	or @ctx.regFlag,100h
	dec @ctx.regEip
	invoke SetThreadContext,g_hThread,addr @ctx
		
	
	ret	
ResCodeAndSetSingStep endp

end
