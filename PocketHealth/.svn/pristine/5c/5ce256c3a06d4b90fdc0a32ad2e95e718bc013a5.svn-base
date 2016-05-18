// MsgCode.cpp: implementation of the MsgCode class.
//
//////////////////////////////////////////////////////////////////////


#include "MsgCode.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CMsgCode* CMsgCode::m_pObject = NULL;

CMsgCode::CMsgCode()
{
    
}

CMsgCode::~CMsgCode()
{
    m_MsgMap.clear();
}

CMsgCode* CMsgCode::GetObject()
{
    if (NULL==m_pObject)
    {
        m_pObject = new CMsgCode;
    }
    
    return m_pObject;
}

void CMsgCode::ReleaseObject()
{
    if (NULL!=m_pObject)
    {
        delete m_pObject;
        m_pObject = NULL;
    }
}

//ÃÌº”µΩœ˚œ¢map
//bool CMsgCode::AddMsgMap(int nType, ToMsgFun msgFun)
//{
//    m_MsgMap.insert(pair<int, ToMsgFun>(nType, msgFun));
//    
//    return true;
//}

//Ω” ’œ˚œ¢∫Ø ˝
//bool CMsgCode::InvokeMsgFun(int nType, void* pData)
//{
//	ToMsgFun msgFun = (ToMsgFun) m_MsgMap[nType];
//	if (NULL==msgFun)
//		return false;
//
//	return msgFun(pData);
//}
//扩展
bool CMsgCode::InvokeMsgFun(unsigned int nMsg, void* pData)
{
    map<unsigned int, ToMsgFun>::iterator it = m_MsgMap.find(nMsg);
    if(m_MsgMap.end()==it)
        return false;
    
    ToMsgFun msgFun = it->second;
    if (NULL==msgFun)
        return false;
    
    return msgFun(pData);
}
//
bool CMsgCode::AddMsgMap(unsigned int nMsg, ToMsgFun msgFun)
{
    pair<map<unsigned int, ToMsgFun>::iterator, bool> it =
    m_MsgMap.insert(pair<unsigned int, ToMsgFun>(nMsg, msgFun));
    return it.second;
}
//bool CMsgFun::MakeCover(unsigned int nMsg, MSGFUN msgFun)
//{
//    map<unsigned int, MSGFUN>::iterator it = m_mapMsgFun.find(nMsg);
//    if (m_mapMsgFun.end() == it)
//        return false;
//
//    m_mapMsgFun[nMsg]=msgFun;
//    
//    return true;
//}
