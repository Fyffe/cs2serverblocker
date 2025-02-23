import 'package:cs_serverblocker/models/firewall_rule.dart';
import 'package:cs_serverblocker/models/server.dart';
import 'package:flutter/services.dart';

class FirewallService {
  final Map<String, FirewallRule> rules = {};
  bool _isInitialized = false;

  bool isInitialized() => _isInitialized;

  static const platform = MethodChannel('fiffe.apps.cs2blocker/firewall');

  Future<void> initializeRules(List<Server> servers) async {
    for(Server server in servers)
    {
      List<String> addresses = server.relays.map((elem) => elem.ipAddress)
      .toList();

      FirewallRule rule = FirewallRule(
        name: sanitizeName(server.name), 
        addresses: addresses,
        firewallService: this
      );

      rules[server.name] = rule;
      
      bool exists = await _doesRuleExistInFirewall(rule);

      if(!exists) {
        _addRuleToFirewall(rule);
        rule.isEnabled = true;
      } else {
        rule.isEnabled = await _isRuleEnabledInFirewall(rule);
      }
    }

    _isInitialized = true;
  }

  Future<bool> _doesRuleExistInFirewall(FirewallRule rule) async {
    int? result = await platform.invokeMethod<int>('does_rule_exist', {"rule_name": rule.name});

    return Future<bool>.value(result == 1 ? true : false);
  }

  Future<bool> _isRuleEnabledInFirewall(FirewallRule rule) async {    
    int? result = await platform.invokeMethod<int>('is_rule_enabled', {"rule_name": rule.name});

    return Future<bool>.value(result == 1 ? true : false);
  }

  Future<bool> _addRuleToFirewall(FirewallRule rule) async {
    
    List<String> addresses = rule.addresses.map((elem) => "$elem:255.255.255.255").toList();
    String joinedAddresses = addresses.join(",");

    int? result = await platform.invokeMethod<int>('add_rule', {"rule_name": rule.name, "addresses": joinedAddresses});

    return Future<bool>.value(result == 1 ? true : false);
  }

  // ignore: unused_element
  Future<bool> _removeRuleFromFirewall(FirewallRule rule) async {

    int? result = await platform.invokeMethod<int>('remove_rule', {"rule_name": rule.name});

    return Future<bool>.value(result == 1 ? true : false);
  }

  Future<bool> toggleRuleInFirewall(FirewallRule rule, bool shouldBeEnabled, Function(bool)? callback) async {
    await platform.invokeMethod<int>(shouldBeEnabled ? 'enable_rule' : 'disable_rule', {"rule_name": rule.name});

    bool isEnabled = await _isRuleEnabledInFirewall(rule);
    bool isSuccess = isEnabled == shouldBeEnabled;
    
    callback!(isEnabled);

    return Future<bool>.value(isSuccess);
  }

  String sanitizeName(String name) {
    String slug = name.trim();
    slug = slug.toLowerCase();
    slug = slug
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .replaceAll(' ', '_');

    return "cs2blocker_$slug";
  }
}