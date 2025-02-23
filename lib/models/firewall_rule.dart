import 'package:cs_serverblocker/interfaces/rule_toggled_listener.dart';
import 'package:cs_serverblocker/services/firewall_service.dart';

class FirewallRule {
  final String name;
  final List<String> addresses;
  final List<RuleToggledListener> _listeners = [];
  final FirewallService _firewallService;

  bool isEnabled = false;

  void addListener(RuleToggledListener listener) {
    _listeners.add(listener);
  }

  void removeListener(RuleToggledListener listener) {
    _listeners.remove(listener);
  }

  void toggle(bool shouldBeEnabled) {
    _firewallService.toggleRuleInFirewall(this, shouldBeEnabled, onToggled);
  }

  void onToggled(bool shouldBeEnabled) {
    isEnabled = shouldBeEnabled;

    for(RuleToggledListener listener in _listeners) {
      listener.onRuleToggled(isEnabled);
    }
  }
  
  FirewallRule({
    required this.name,
    required this.addresses,
    required FirewallService firewallService,
  }) : _firewallService = firewallService;
}