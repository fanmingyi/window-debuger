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
	
	;---------------------------
	;全局变量
	;---------------------------
	extern g_hProcess db 0
	extern g_hThread dd
	
	
	
	
	
	;---------------------------
	;工具函数
	;---------------------------
	ReadMemory proto  dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	WriteMemory proto dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	
	
	
	
	
		
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

	
	ParseCommand proto


ELSE
  echo -------------------------------------------
  echo WARNING duplicate include file MyDebugger
  echo -------------------------------------------
ENDIF
