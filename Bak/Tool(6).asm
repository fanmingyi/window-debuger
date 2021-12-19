.386
.model flat,stdcall
option casemap:none


include MyDebugger.Inc

.code
ReadMemory proc  dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	LOCAL @dwOldProtect:DWORD
	LOCAL @dwBytesReaded:DWORD
	

	invoke 
	invoke ReadProcessMemory,g_hProcess,g_dwAddr,pBuf,type g_bt01dCode,addr @dwBytesWrited

	ret
ReadMemory endp



WriteMemory proc dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	LOCAL @dwOldProtect:DWORD
	LOCAL @dwBytesWrited:DWORD


	invoke VirtualProtectEx,g_hProcess,dwAddr,dwSize,PAGE_EXECUTE_READWRITE,addr @dwOldProtect
	invoke WriteProcessMemory,g_hProcess,g_dwAddr,pBuf,type g_bt01dCode,addr @dwBytesWrited
	invoke VirtualProtectEx,g_hProcess,dwAddr,dwSize,@dwOldProtect ,addr @dwOldProtect
		

	ret
WriteMemory endp



end