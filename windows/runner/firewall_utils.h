#ifndef RUNNER_WIN32_FIREWALL_UTILS_H_
#define RUNNER_WIN32_FIREWALL_UTILS_H_

#include <windows.h>
#include <netfw.h>
#include <string>

class FirewallUtils {
public:
    FirewallUtils();
    ~FirewallUtils();

    bool Initialize();

    bool AddRule(std::string const& ruleName, std::string addresses);

    bool RemoveRule(std::string const& ruleName);

    bool ToggleRule(std::string const& ruleName, bool bIsEnabled);

    bool DoesRuleExist(std::string const& ruleName);

    bool IsRuleEnabled(std::string const& ruleName);
private:
    HRESULT WFCOMInitialize(INetFwPolicy2** ppNetFwPolicy2);

    HRESULT InitializeFirewall(INetFwPolicy2*& pNetFwPolicy2, INetFwRules*& pNetFwRules);

    HRESULT GetRule(INetFwPolicy2*& pNetFwPolicy2, INetFwRules*& pNetFwRules, INetFwRule*& pNetFwRule, BSTR& bstrRuleName);

    void CleanupFirewall(INetFwPolicy2*& pNetFwPolicy2, INetFwRules*& pNetFwRules);

private:
    bool bIsInitialized = false;

    HRESULT hrComInit = S_OK;
};

#endif