import 'package:cs_serverblocker/common/app_styles.dart';
import 'package:cs_serverblocker/interfaces/rule_toggled_listener.dart';
import 'package:cs_serverblocker/services/firewall_service.dart';
import 'package:cs_serverblocker/widgets/animated_loader.dart';
import 'package:flutter/material.dart';

class RuleSwitch extends StatefulWidget {
  final FirewallService firewallService;
  final String associatedServerName;

  const RuleSwitch({super.key, required this.firewallService, 
  required this.associatedServerName});

  @override
  State<RuleSwitch> createState() => _RuleSwitchState();
}

class _RuleSwitchState extends State<RuleSwitch> implements RuleToggledListener {
  bool isEnabled = false;
  bool isBusy = false;

  static const WidgetStateProperty<Icon> thumbIcon = 
  WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.disabled: Icon(Icons.block, color: Colors.transparent),
      WidgetState.selected: Icon(Icons.block, color: Colors.black87),
      WidgetState.any: Icon(Icons.play_arrow_rounded, color: Colors.black87)
    }
  );

  static const WidgetStateProperty<Color> overlayColor =
  WidgetStateProperty<Color>.fromMap(
    <WidgetStatesConstraint, Color>{
      WidgetState.selected: AppStyles.serverDisabledAlpha,
      WidgetState.any: AppStyles.serverEnabledAlpha
    }
  );

  static const WidgetStateProperty<Color> trackColor =
  WidgetStateProperty<Color>.fromMap(
    <WidgetStatesConstraint, Color>{
      WidgetState.disabled: Colors.grey,
      WidgetState.selected: AppStyles.serverDisabled,
      WidgetState.any: AppStyles.serverEnabled
    }
  );

  @override
  void initState() {
    super.initState();

    isEnabled = widget.firewallService.rules[widget.associatedServerName]?.isEnabled ?? false;

    widget.firewallService.rules[widget.associatedServerName]?.addListener(this);
  }

  @override
  void dispose() {
    widget.firewallService.rules[widget.associatedServerName]?.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: isBusy ? [ buildSwitch(), buildAnimatedWidget() ] : [ buildSwitch() ],
    );
  }

  Widget buildSwitch() => Switch(
    value: isEnabled,
    overlayColor: overlayColor,
    trackColor: trackColor,
    thumbIcon: thumbIcon,
    thumbColor: WidgetStatePropertyAll(Colors.white),
    trackOutlineWidth: WidgetStatePropertyAll(0.0),
    trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
    splashRadius: 16,
    onChanged: isBusy ? null : toggleSwitch,
  );

  Widget buildAnimatedWidget() => Positioned(
    top: 12,
    left: isEnabled ? 32 : 12,
    child: IgnorePointer(
      child: 
        Stack(
          children: [
            AnimatedLoader(
              width: 16,
              isDark: true,
            ),
          ],
        ),
    )
  );
  
  @override
  void onRuleToggled(bool isRuleEnabled) {
    setState(() {
      isEnabled = isRuleEnabled;
      isBusy = false;
    });
  }

  void toggleSwitch(bool value) {
    setState(() {
      isBusy = true;
    });

    widget.firewallService.rules[widget.associatedServerName]?.toggle(!isEnabled);
  }
}