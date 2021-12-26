IFNDEF MyDebugger
MyDebugger equ <1>
	
	include windows.inc
	include user32.inc
	include kernel32.inc
	include msvcrt.inc
	include Linker.inc
	
	
	includelib msvcrt.lib
	includelib user32.lib
	includelib kernel32.lib
	includelib libudis86.lib
	;---------------------------
	;全局变量
	;---------------------------
	externdef g_hProcess:dword
	externdef g_hThread:dword
	externdef g_pBpListHead:dword
	externdef g_bIsStepCommand:dword
	
	
	
	;---------------------------
	;工具函数
	;---------------------------
	ReadMemory proto  dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	WriteMemory proto dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	DisAsm proto stdcall pMachineCode:LPBYTE,dwCOdeSize:DWORD,dwEip:DWORD,pDisAsm:LPSTR,pCodeHex:LPSTR,pdwCodeLen:LPWORD
	
	
	
	
	
		
	;-------------------------------------
	;软件断点相关
	;-------------------------------------
		
	BpData struc
		m_dwAddr dd 0
		m_bIsTmp dd 0
		m_dwNumber dd 0
		m_bt01dCode db 0 ;原来的指令		
	BpData ends
	
	;bIsTmp:是否是临时断点
	SetBreakPoint proto pAddr:DWORD,bIsTemp:DWORD
	DelBreakPoint proto dwAddr:DWORD
	ListBreakPoint proto
	ResCode proto pBpData:ptr BpData
	SetTFDecEip proto bTF:BOOL,dwCount:DWORD

	ResCodeAndSetSingStep proto  uses edi bBpData:ptr BpData
	
	ParseCommand proto


ELSE
  echo -------------------------------------------
  echo WARNING duplicate include file MyDebugger
  echo -------------------------------------------
ENDIF
