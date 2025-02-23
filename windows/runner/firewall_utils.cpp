#include "firewall_utils.h"
#include <stdio.h>
#include <wchar.h>
#include <comutil.h>
#include <atlcomcli.h>

const wchar_t kGroupName[] = L"cs2blocker";

std::wstring Utf8ToUtf16(const std::string &sString) {
    if (sString.empty()) {
        return std::wstring();
    }

    int target_length = MultiByteToWideChar(
                        CP_UTF8, MB_ERR_INVALID_CHARS, 
                        sString.data(),
                        static_cast<int>(sString.length()), 
                        nullptr, 
                        0
    );

    if (target_length == 0) {
        return std::wstring();
    }

    std::wstring wString;
    wString.resize(target_length);

    int converted_length = MultiByteToWideChar(
                            CP_UTF8, MB_ERR_INVALID_CHARS, 
                            sString.data(),
                            static_cast<int>(sString.length()),
                            wString.data(), 
                            target_length
    );

    if (converted_length == 0) {
        return std::wstring();
    }

    return wString;
}

FirewallUtils::FirewallUtils() {

}

FirewallUtils::~FirewallUtils() {
    if(SUCCEEDED(hrComInit)) {
        CoUninitialize();
    }
}

bool FirewallUtils::Initialize() {
    if(bIsInitialized) {
        return true;
    }

    hrComInit = CoInitializeEx(0, COINIT_APARTMENTTHREADED);

    if(hrComInit != RPC_E_CHANGED_MODE) {
        if(FAILED(hrComInit)) {
            printf("CoInitializeEx failed: 0x%08lx\n", hrComInit);
            
            return false;
        }
    }

    bIsInitialized = true;

    return true;
}

bool FirewallUtils::AddRule(std::string const& ruleName, std::string addresses) {
    if(ruleName.empty() || addresses.empty()) {
        return false;
    }
    
    bool bIsSuccess = false;
    long lProfilesBitMask = NET_FW_PROFILE2_ALL;

    INetFwPolicy2* pNetFwPolicy2 = NULL;
    INetFwRules* pNetFwRules = NULL;

    HRESULT hr = InitializeFirewall(pNetFwPolicy2, pNetFwRules);

    if(FAILED(hr)) {
        CleanupFirewall(pNetFwPolicy2, pNetFwRules);
        
        return false;
    }

    INetFwRule* pFwRule = NULL;

    hr = CoCreateInstance(
        __uuidof(NetFwRule),
        NULL,
        CLSCTX_INPROC_SERVER,
        __uuidof(INetFwRule),
        (void**)&pFwRule
    );

    if(FAILED(hr)) {
        CleanupFirewall(pNetFwPolicy2, pNetFwRules);

        return false;
    }

    BSTR bstrRuleName = SysAllocString(Utf8ToUtf16(ruleName).c_str());
    BSTR bstrAddresses = SysAllocString(Utf8ToUtf16(addresses).c_str());
    BSTR bstrGroupName = SysAllocString(kGroupName);

    pFwRule->put_Name(bstrRuleName);
    pFwRule->put_Grouping(bstrGroupName);
    pFwRule->put_Direction(NET_FW_RULE_DIR_OUT);
    pFwRule->put_Profiles(lProfilesBitMask);
    pFwRule->put_Action(NET_FW_ACTION_BLOCK);
    pFwRule->put_RemoteAddresses(bstrAddresses);
    pFwRule->put_Enabled(VARIANT_FALSE);

    hr = pNetFwRules->Add(pFwRule);

    if(SUCCEEDED(hr)) {
        bIsSuccess = true;
    }

    if(pFwRule != NULL) {
        pFwRule->Release();
    }

    CleanupFirewall(pNetFwPolicy2, pNetFwRules);

    SysFreeString(bstrRuleName);
    SysFreeString(bstrAddresses);
    SysFreeString(bstrGroupName);

    return bIsSuccess;
}

bool FirewallUtils::RemoveRule(std::string const& ruleName) {
    if(ruleName.empty()) {
        return false;
    }
    
    bool bIsSuccess = false;

    INetFwPolicy2* pNetFwPolicy2 = NULL;
    INetFwRules* pNetFwRules = NULL;

    HRESULT hr = InitializeFirewall(pNetFwPolicy2, pNetFwRules);

    if(FAILED(hr)) {
        CleanupFirewall(pNetFwPolicy2, pNetFwRules);
        
        return false;
    }

    BSTR bstrRuleName = SysAllocString(Utf8ToUtf16(ruleName).c_str());

    hr = pNetFwRules->Remove(bstrRuleName);

    if(SUCCEEDED(hr)) {
        bIsSuccess = true;
    }

    CleanupFirewall(pNetFwPolicy2, pNetFwRules);

    SysFreeString(bstrRuleName);

    return bIsSuccess;
}

bool FirewallUtils::ToggleRule(std::string const& ruleName, bool bIsEnabled) {
    if(ruleName.empty()) {
        return false;
    }

    INetFwPolicy2* pNetFwPolicy2 = NULL;
    INetFwRules* pNetFwRules = NULL;

    HRESULT hr = InitializeFirewall(pNetFwPolicy2, pNetFwRules);

    if(FAILED(hr)) {
        CleanupFirewall(pNetFwPolicy2, pNetFwRules);
        
        return false;
    }

    INetFwRule* pFwRule = NULL;

    std::wstring wstrRuleName = Utf8ToUtf16(ruleName);
    BSTR bstrInName = SysAllocString(wstrRuleName.c_str()); 

    hr = GetRule(pNetFwPolicy2, pNetFwRules, pFwRule, bstrInName);

    if(SUCCEEDED(hr)) {
        VARIANT_BOOL varBool = bIsEnabled ? VARIANT_TRUE : VARIANT_FALSE;

        hr = pFwRule->put_Enabled(varBool);
    }

    SysFreeString(bstrInName);

    if(pFwRule != NULL) {
        pFwRule->Release();
    }

    CleanupFirewall(pNetFwPolicy2, pNetFwRules);

    return SUCCEEDED(hr);
}

bool FirewallUtils::DoesRuleExist(std::string const& ruleName) {
    if(ruleName.empty()) {
        return false;
    }

    INetFwPolicy2* pNetFwPolicy2 = NULL;
    INetFwRules* pNetFwRules = NULL;

    HRESULT hr = InitializeFirewall(pNetFwPolicy2, pNetFwRules);

    if(FAILED(hr)) {
        CleanupFirewall(pNetFwPolicy2, pNetFwRules);
        
        return false;
    }

    INetFwRule* pFwRule = NULL;

    std::wstring wstrRuleName = Utf8ToUtf16(ruleName);
    BSTR bstrInName = SysAllocString(wstrRuleName.c_str()); 

    bool bDoesExist = false;

    hr = GetRule(pNetFwPolicy2, pNetFwRules, pFwRule, bstrInName);

    if(SUCCEEDED(hr)) {
        bDoesExist = true;
    }
    
    SysFreeString(bstrInName);

    if(pFwRule != NULL) {
        pFwRule->Release();
    }

    CleanupFirewall(pNetFwPolicy2, pNetFwRules);

    return bDoesExist;
}

bool FirewallUtils::IsRuleEnabled(std::string const& ruleName) {
    if(ruleName.empty()) {
        return false;
    }

    bool bIsEnabled = false;

    INetFwPolicy2* pNetFwPolicy2 = NULL;
    INetFwRules* pNetFwRules = NULL;

    HRESULT hr = InitializeFirewall(pNetFwPolicy2, pNetFwRules);

    if(FAILED(hr)) {
        CleanupFirewall(pNetFwPolicy2, pNetFwRules);
        
        return false;
    }

    INetFwRule* pFwRule = NULL;

    std::wstring wstrRuleName = Utf8ToUtf16(ruleName);
    
    BSTR bstrInName = SysAllocString(wstrRuleName.c_str()); 

    hr = GetRule(pNetFwPolicy2, pNetFwRules, pFwRule, bstrInName);

    if(SUCCEEDED(hr)) {
        VARIANT_BOOL vIsEnabled;

        if(SUCCEEDED(pFwRule->get_Enabled(&vIsEnabled))){
            bIsEnabled = vIsEnabled;
        }
    }

    SysFreeString(bstrInName);

    if(pFwRule != NULL) {
        pFwRule->Release();
    }    

    return bIsEnabled;
}

HRESULT FirewallUtils::WFCOMInitialize(INetFwPolicy2** ppNetFwPolicy2) {
    HRESULT hr = S_OK;

    hr = CoCreateInstance(
        __uuidof(NetFwPolicy2), 
        NULL, 
        CLSCTX_INPROC_SERVER,
        __uuidof(INetFwPolicy2),
        (void**)ppNetFwPolicy2
    );

    if(FAILED(hr)) {
        printf("CoCreateInstance for INetFwPolicy2 failed: 0x%08lx\n", hr);
    }

    return hr;
}

HRESULT FirewallUtils::InitializeFirewall(INetFwPolicy2*& pNetFwPolicy2, INetFwRules*& pNetFwRules) {
    HRESULT hr = WFCOMInitialize(&pNetFwPolicy2);

    if(FAILED(hr)) {
        return hr;
    }

    hr = pNetFwPolicy2->get_Rules(&pNetFwRules);

    if(FAILED(hr)) {
        printf("Failed to get firewall rules: 0x%08lx\n", hr);

        return hr;
    }

    return S_OK;
}

HRESULT FirewallUtils::GetRule(INetFwPolicy2*& pNetFwPolicy2, INetFwRules*& pNetFwRules, INetFwRule*& pNetFwRule, BSTR& bstrRuleName) {
    long fwRuleCount;

    HRESULT hr = pNetFwRules->get_Count(&fwRuleCount);

    if(FAILED(hr)) {
        printf("Failed to get firewall rules count: 0x%08lx\n", hr);

        return hr;
    }

    IUnknown* pEnumerator;
    IEnumVARIANT* pVariant = NULL;
    ULONG cFetched = 0; 
    CComVariant var;

    pNetFwRules->get__NewEnum(&pEnumerator);

    if(pEnumerator) {
        hr = pEnumerator->QueryInterface(__uuidof(IEnumVARIANT), (void**)&pVariant);
    }

    BSTR bstrName;

    while(SUCCEEDED(hr) && hr != S_FALSE) {
        var.Clear();
        hr = pVariant->Next(1, &var, &cFetched);

        if(hr != S_FALSE) {
            if(SUCCEEDED(hr)) {
                hr = var.ChangeType(VT_DISPATCH);
            }
            if(SUCCEEDED(hr)) {
                hr = (V_DISPATCH(&var))->QueryInterface(__uuidof(INetFwRule), reinterpret_cast<void**>(&pNetFwRule));
            }
            if(SUCCEEDED(hr)) {
                if(SUCCEEDED(pNetFwRule->get_Name(&bstrName))) {
                    if(wcscmp(bstrName, bstrRuleName) == 0) {
                        return S_OK;
                    }
                }
            }
        }
    }

    return S_FALSE;
}

void FirewallUtils::CleanupFirewall(INetFwPolicy2*& pNetFwPolicy2, INetFwRules*& pNetFwRules) {
    if(pNetFwRules != NULL) {
        pNetFwRules->Release();
    }

    if(pNetFwPolicy2 != NULL) { 
        pNetFwPolicy2->Release();
    }
}