.386
.model flat,stdcall
option casemap:none


include MyDebugger.Inc

.code
ReadMemory proc  dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	LOCAL @dwOldProtect:DWORD
	LOCAL @dwBytesReaded:DWORD
	

	invoke ReadProcessMemory,g_hProcess,dwAddr,pBuf,dwSize,addr @dwBytesReaded

	ret
ReadMemory endp



WriteMemory proc dwAddr:DWORD,pBuf:LPVOID,dwSize:DWORD
	LOCAL @dwOldProtect:DWORD
	LOCAL @dwBytesWrited:DWORD


	invoke VirtualProtectEx,g_hProcess,dwAddr,dwSize,PAGE_EXECUTE_READWRITE,addr @dwOldProtect
	invoke WriteProcessMemory,g_hProcess,dwAddr,pBuf,dwSize,addr @dwBytesWrited
	invoke VirtualProtectEx,g_hProcess,dwAddr,dwSize,@dwOldProtect ,addr @dwOldProtect
		

	ret
WriteMemory endp



end