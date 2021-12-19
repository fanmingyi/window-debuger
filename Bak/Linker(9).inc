include windows.inc
include user32.inc
include kernel32.inc

includelib user32.lib
includelib kernel32.lib


Node struc
	m_pNext:DWORD
	m_pUserData:LPVOID	
Node ends


InitList Proto
PushBack proto pHead:ptr Node,m_pUserData:LPVOID,dwDataSize:DWORD
FindNode proto pHead:ptr Node,pfnCompare:DWORD,pData:DWORD
Travel proto pHead:ptr Node,pData:DWORD
FreeList proto pHead:ptr Node
DeleteNode proto pHead:ptr Node,pNode :ptr Node

		