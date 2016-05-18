// MsgCode.h: interface for the MsgCode class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MSGCODE_H__26899B27_AF62_47A8_8098_73051A254C0D__INCLUDED_)
#define AFX_MSGCODE_H__26899B27_AF62_47A8_8098_73051A254C0D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <iostream>
#include <map>
using namespace std;

typedef bool (*ToMsgFun)(void* );

class CMsgCode  
{
private:
	CMsgCode();
	virtual ~CMsgCode();

public:
	static CMsgCode* GetObject();
	static void ReleaseObject(); //πÿ±’≥Ã–Úµƒ ±∫Úµ˜”√
//	bool AddMsgMap(int nType, ToMsgFun msgFun);
//	bool InvokeMsgFun(int nType, void* pData);
    
    bool AddMsgMap(unsigned int nType, ToMsgFun msgFun);
    bool InvokeMsgFun(unsigned int nType, void* pData);

private:
//	map<int, ToMsgFun> m_MsgMap;
    map<unsigned int , ToMsgFun> m_MsgMap;
	static CMsgCode* m_pObject;

};

#endif // !defined(AFX_MSGCODE_H__26899B27_AF62_47A8_8098_73051A254C0D__INCLUDED_)
