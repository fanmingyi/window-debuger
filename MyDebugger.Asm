.386
.model flat,stdcall
option casemap:none


include MyDebugger.Inc
 
public g_bIsSystemCC
public g_bBpDataToReset
public g_bIsStepCommand
.data
	g_hProcess dd 0
	g_hThread dd 0

.data
	g_szExePath db "calc.exe",0
	g_szErrCreateProcess db "创建进程失败",0dh,0ah,0
	g_szCREATE_PROCESS_DEBUG_EVENT    db "CREATE_PROCESS_DEBUG_EVENT",0dh,0ah,0
	g_szCREATE_THREAD_DEBUG_EVENT    db "CREATE_THREAD_DEBUG_EVENT",0dh,0ah,0
	g_szEXCEPTION_DEBUG_EVENT    db "EXCEPTION_DEBUG_EVENT",0dh,0ah,0
	g_szEXIT_PROCESS_DEBUG_EVENT    db "EXIT_PROCESS_DEBUG_EVENT",0dh,0ah,0
	g_szEXIT_THREAD_DEBUG_EVENT    db "EXIT_THREAD_DEBUG_EVENT",0dh,0ah,0
	g_szLOAD_DLL_DEBUG_EVENT    db "LOAD_DLL_DEBUG_EVENT",0dh,0ah,0
	g_szOUTPUT_DEBUG_STRING_EVENT    db "OUTPUT_DEBUG_STRING_EVENT",0dh,0ah,0
	g_szRIP_EVENT    db "RIP_EVENT",0dh,0ah,0
	g_szUNLOAD_DLL_DEBUG_EVENT    db "UNLOAD_DLL_DEBUG_EVENT",0dh,0ah,0
	g_szLoadDllFmt db "[event] Lod Dll Base：%08X ImageName:%s",0dh,0ah,0 
	g_dwLoadDllFmtLen dd $-offset g_szLoadDllFmt
	

	
	g_szDebugFmt db "Excetion addr：%08X",0dh,0ah,0 
	g_szDebug2Fmt db "EXCEPTION_SINGLE_STEP addr：%08X",0dh,0ah,0 
	

	
	g_szmytest db "是我的断点地址 addr：%08X",0dh,0ah,0 
	g_szmytest2 db "单步断点地址 addr：%08X",0dh,0ah,0 
	g_szmytest3 db "Exception code %x",0dh,0ah,0 
	
	
	g_bIsSystemCC dd FALSE ;系统断点标志位
	g_bBpDataToReset dd NULL ;断步配合，重设断点
	g_bIsStepCommand	dd FALSE ;是否有单步命令
	g_bIsHardwareBpStep dd FALSE;是否是硬件断点的单步
.code



OnBreakPoint proc uses esi edi pER:ptr EXCEPTION_RECORD
	LOCAL @dwStatus:DWORD
	LOCAL @dwOldProtect:DWORD
	LOCAL @btCodeCC:BYTE
	LOCAL @dwBytesWrited:DWORD
	LOCAL @dwBytesReaded:DWORD
	LOCAL @ctx: CONTEXT
	
	
	mov @dwStatus,DBG_CONTINUE
	
	mov eax,@dwStatus
	
	mov esi,pER
	assume esi:ptr EXCEPTION_RECORD
	
	;系统断点，忽略
	.if g_bIsSystemCC==FALSE
		mov g_bIsSystemCC,TRUE
		invoke ParseCommand
	
		ret
	.endif
	
	
	
	;判断是否是自己的断点,遍历链表
	mov edi, g_pBpListHead
	
	
	
	assume edi:ptr Node
	.while edi !=NULL
		mov ebx,[edi].m_pUserData
		
		assume ebx:ptr BpData
		
		mov eax,[esi].ExceptionAddress
			
		.if [ebx].m_dwAddr==eax
			
			;是自己的断点，恢复断点，设置单步
			mov g_bBpDataToReset,ebx
			invoke ResCode,ebx
		
			;invoke ResCodeAndSetSingStep,ebx
			
			.if [ebx].m_bIsTmp == TRUE
				;int 3
				;临时断点
				invoke SetTFDecEip,FALSE,1
				invoke DelBreakPoint,[ebx].m_dwNumber
			.else
				invoke SetTFDecEip,TRUE,1
			.endif
			
			;输入新的命令
			invoke ParseCommand
			mov @dwStatus,eax
			invoke crt_printf,offset g_szmytest,[esi].ExceptionAddress
			.break
				
		.endif
		
		assume ebx:nothing
		
		mov edi,[edi].m_pNext
		
	.endw
	
	assume edi:nothing
	
	

	
	mov eax,@dwStatus
	ret
	
	ret

OnBreakPoint endp



OnSingleStep proc pER:ptr EXCEPTION_RECORD   
	LOCAL @dwOldProtect:DWORD
	LOCAL @btCodeCC:BYTE
	LOCAL @dwBytesWrited:DWORD
	LOCAL @dwBytesReaded:DWORD
	LOCAL @dwStatus:DWORD
	LOCAL @ctx:CONTEXT

	;处理调试事件
	mov @dwStatus,DBG_CONTINUE
	
	.if g_bBpDataToReset !=NULL
		mov esi,g_bBpDataToReset
		assume esi:ptr BpData
		mov @btCodeCC,0cch
		invoke crt_printf,offset g_szmytest2,[esi].m_dwAddr
		invoke WriteMemory,[esi].m_dwAddr,addr @btCodeCC,type @btCodeCC
		
		mov g_bBpDataToReset,NULL
		assume esi:nothing
	.endif
	
	;有单步命令
	.if g_bIsStepCommand==TRUE
		mov g_bIsStepCommand, FALSE
		invoke ParseCommand
		mov @dwStatus ,eax
	.endif
	
	
	
	
	;判断是否有硬件断点命令
	invoke RtlZeroMemory,addr @ctx,type @ctx
	mov @ctx.ContextFlags,CONTEXT_FULL or  CONTEXT_DEBUG_REGISTERS
	invoke GetThreadContext,g_hThread,addr @ctx
	
	
	;有硬件断点标志，那么还原硬件断点
	.if g_bIsHardwareBpStep == TRUE
		or @ctx.iDr7,11b
		
		and @ctx.iDr6,0
		invoke SetThreadContext,g_hThread,addr @ctx
		mov g_bIsHardwareBpStep,FALSE
		mov eax,DBG_CONTINUE
		ret 
	.endif
	
	
	;
	.if @ctx.iDr6 & 1
		;清除Dr0的硬件执行断点
		;and @ctx.iDr7,0fffffffch
		;or @ctx.regFlag,100h;设置单步
		
		and @ctx.iDr6,0;清空调试寄存器状态
		invoke SetThreadContext,g_hThread,addr @ctx
		;硬件执行断点需要在执行后
		;mov g_bIsHardwareBpStep,TRUE ;为后续还原状态寄存器
		
		
		invoke ParseCommand
		mov @dwStatus,eax
	.endif
	
	
	
	

	
	mov eax,@dwStatus 
	ret 

OnSingleStep endp

OnException proc uses esi pDe:ptr DEBUG_EVENT
	LOCAL @dwStatus:DWORD
	LOCAL @dwOldProtect:DWORD
	LOCAL @btCodeCC:BYTE
	LOCAL @dwBytesWrited:DWORD
	LOCAL @dwBytesReaded:DWORD
	LOCAL @ctx: CONTEXT
	
	;处理调试事件
	mov @dwStatus,DBG_CONTINUE
	
	mov esi,pDe
	assume esi:ptr DEBUG_EVENT
	
	lea esi,[esi].u.Exception
	
	
	assume esi:ptr EXCEPTION_RECORD 
	

	invoke crt_printf,offset g_szmytest3,[esi].ExceptionCode
	.if [esi].ExceptionCode==EXCEPTION_BREAKPOINT
		invoke crt_printf,offset g_szDebugFmt,[esi].ExceptionAddress
		invoke OnBreakPoint,esi
		ret
	.elseif [esi].ExceptionCode==EXCEPTION_SINGLE_STEP
		invoke crt_printf,offset g_szDebug2Fmt,[esi].ExceptionAddress
		invoke OnSingleStep,esi
		ret
	.else
		
	
	.endif 
	
	
	
	
	
	assume esi:nothing
	mov eax,@dwStatus
 
 ret

OnException endp



OnCreateProcess proc uses esi pDe:ptr DEBUG_EVENT
	LOCAL @dwOldProtect:DWORD
	LOCAL @btCodeCC:BYTE
	LOCAL @dwBytesWrited:DWORD
	LOCAL @dwBytesReaded:DWORD
	
	;invoke VirtualProtectEx,g_hProcess,g_dwAddr,1,PAGE_EXECUTE_READWRITE,addr @dwOldProtect
	
;	mov @btCodeCC,0cch
;	invoke ReadProcessMemory,g_hProcess,g_dwAddr,offset g_bt01dCode,type g_bt01dCode,addr @dwBytesReaded
;	invoke WriteProcessMemory,g_hProcess,g_dwAddr,addr @btCodeCC,type @btCodeCC,addr @dwBytesWrited


;	invoke VirtualProtectEx,g_hProcess,g_dwAddr,1,@dwOldProtect,addr @dwOldProtect
	
	ret
	
	
OnCreateProcess endp


OnLoadDll proc uses esi pDe:ptr DEBUG_EVENT
	LOCAL @szFileName[MAX_PATH*2 ]:CHAR
	LOCAL @dwAddr:DWORD 
	LOCAL @dwBytesReaded:DWORD
	LOCAL @szwLoadDllFmt[MAX_PATH ]:CHAR
	mov esi,pDe
	assume esi:ptr DEBUG_EVENT
	
	
	invoke ReadProcessMemory,g_hProcess,[esi].u.LoadDll.lpImageName,addr @dwAddr,type @dwAddr,addr @dwBytesReaded

	.if eax==FALSE || @dwAddr ==NULL
	 
		ret
	.endif
	
	 
	invoke ReadProcessMemory,g_hProcess,@dwAddr,addr @szFileName,MAX_PATH*2,addr @dwBytesReaded
	
	
	
	.if [esi].u.LoadDll.fUnicode ==TRUE
		invoke crt_mbstowcs,addr @szwLoadDllFmt,offset g_szLoadDllFmt,g_dwLoadDllFmtLen
		invoke crt_wprintf,addr @szwLoadDllFmt,[esi].u.LoadDll.lpBaseOfDll,addr @szFileName
	.else
		invoke crt_printf ,offset g_szLoadDllFmt,[esi].u.LoadDll.lpBaseOfDll,addr @szFileName
	.endif
	
		
	
	assume esi:nothing
	
	
	ret

OnLoadDll endp


main proc 
	LOCAL @si:STARTUPINFO
	LOCAL @pi:PROCESS_INFORMATION
	LOCAL @de:DEBUG_EVENT 
	LOCAL @dwStatus:DWORD
	
	
	
	invoke RtlZeroMemory,addr @si,type @si
	mov @si.cb,type @si
	 
	
	invoke RtlZeroMemory,addr @pi,type @pi
	
	
	
	invoke CreateProcess,offset g_szExePath,NULL,NULL,NULL,FALSE,DEBUG_ONLY_THIS_PROCESS,NULL,NULL,addr @si,addr @pi
	.if eax==FALSE
		invoke crt_printf,offset g_szErrCreateProcess
		ret
		
	.endif
	
	push @pi.hProcess
	pop g_hProcess
	
	
	.while TRUE 
		;等候调试事件
		invoke RtlZeroMemory,addr @de,type @de
		invoke WaitForDebugEvent,addr @de,INFINITE
	 	
	 	;获取线程句柄
	 	invoke OpenThread,THREAD_ALL_ACCESS,FALSE,@de.dwThreadId
	 	mov g_hThread,eax
	 	
	 	;处理调试事件
	 	mov @dwStatus,DBG_CONTINUE
	 	
	 	.if @de.dwDebugEventCode == CREATE_PROCESS_DEBUG_EVENT
	 		invoke OnCreateProcess,addr @de
	 		invoke crt_printf,offset g_szCREATE_PROCESS_DEBUG_EVENT
	 	.elseif  @de.dwDebugEventCode ==CREATE_THREAD_DEBUG_EVENT
	 		invoke crt_printf,offset g_szCREATE_THREAD_DEBUG_EVENT
	 	.elseif  @de.dwDebugEventCode ==EXCEPTION_DEBUG_EVENT
	 		invoke crt_printf,offset g_szEXCEPTION_DEBUG_EVENT
	 		invoke OnException, addr @de
	 		mov @dwStatus,eax
	 		
	 	.elseif  @de.dwDebugEventCode ==EXIT_PROCESS_DEBUG_EVENT
	 		invoke crt_printf,offset g_szEXIT_PROCESS_DEBUG_EVENT
	 	.elseif  @de.dwDebugEventCode ==EXIT_THREAD_DEBUG_EVENT
	 		invoke crt_printf,offset g_szEXIT_THREAD_DEBUG_EVENT
	 	.elseif  @de.dwDebugEventCode ==LOAD_DLL_DEBUG_EVENT
	 		invoke OnLoadDll,addr @de
	 		invoke crt_printf,offset g_szLOAD_DLL_DEBUG_EVENT
	 	.elseif  @de.dwDebugEventCode ==OUTPUT_DEBUG_STRING_EVENT
	 		invoke crt_printf,offset g_szOUTPUT_DEBUG_STRING_EVENT
	 	.elseif  @de.dwDebugEventCode ==RIP_EVENT
	 		invoke crt_printf,offset g_szRIP_EVENT
	 	.elseif  @de.dwDebugEventCode ==UNLOAD_DLL_DEBUG_EVENT
	 		invoke crt_printf,offset g_szUNLOAD_DLL_DEBUG_EVENT
	 	.endif
	 
	 
		invoke CloseHandle,g_hThread 
		invoke ContinueDebugEvent,@de.dwProcessId,@de.dwThreadId,DBG_CONTINUE
		
	.endw
	
	
	ret

main endp



START:
 	invoke main
 	xor eax,eax
 	invoke ExitProcess,eax

end START