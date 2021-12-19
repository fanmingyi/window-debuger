.586
.model flat,stdcall
option casemap:none

include Linker.inc


.code




DeleteNode Proc pHead:ptr Node,pNodeToDel:ptr Node


DeleteNode endp



;返回值，新的头结点
PushBack proc pHead:ptr Node,m_pUserData:LPVOID,dwDataSize:DWORD
	LOCAL @pNewNode:ptr Node
	
	
	invoke crt_malloc,sizeof Node
	mov @pNewNode,eax
	
	
	;为用户数据申请内存
	invoke crt_malloc,dwDataSize
	mov @pNewNode.m_pUserData,eax
	
	;存储用户数据
	invoke crt_memcpy,@pNewNode.m_pUserData,m_pUserData,dwDataSize


	;链接新节点
	push pHead
	pop  @pNewNode,m_pNext 


	mov eax,@pNewNode
	ret
	
PushBack endp




FindNode proc uses esi pHead:ptr Node,pfnCompare:DWORD,pData:DWORD

	mov esi,pHead
	assume esi:ptr Node
	
	.while esi !=NULL
	
		push pData
		push [esi].m_pUserData
		call pfnCompare
		.if eax == TRUE
			mov eax,esi
			ret 
		.endif
		mov esi,[esi].m_pNext
	.endw
	
	assume esi:nothing
	
	xor eax,eax
	

	ret
	
FindNode endp

DeleteNode proc pHead:ptr Node,pNodeToDel:ptr Node
	LOCAL @pNewHead:ptr Node
	
	
	
	mov esi,pHead
	assume esi:ptr Node
	
	
	
	
	;存储新的头结点
	mov eax,[esi].m_pNext
	mov @pNewHead,eax
	
	mov eax,pNodeToDel	
	assume eax:ptr Node

	;交换数据
	push [eax].m_pUserData
	push [esi].m_pUserData
	pop [eax].m_pUserData
	pop [esi].m_pUserData
	
	;删除内存
	mov eax,pNodeToDel
	invoke crt_free,[eax].m_pUserData
	invoke crt_free,pNodeToDel
	assume eax:nothing
			
	
	
	mov eax,@pNewHead
	
	ret
DeleteNode endp


FreeList proc  uses esi pHead:ptr Node
	mov esi,pHead
	
	.while esi !=NULL
		invoke DeleteNode,esi,esi
		mov esi,eax
	.endw
	
	assume esi:nothing
	
	xor eax,eax
	ret	
FreeList endp

		