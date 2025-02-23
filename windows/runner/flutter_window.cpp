#include "flutter_window.h"

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <optional>

#include "flutter/generated_plugin_registrant.h"

using flutter::EncodableMap;
using flutter::EncodableValue;

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {
    }

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  firewall_utils_ = FirewallUtils();
  firewall_utils_.Initialize();

  flutter::MethodChannel<> channel(
    flutter_controller_->engine()->messenger(), "fiffe.apps.cs2blocker/firewall",
    &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler([this](const auto &call, auto result) {
    const auto* arguments = std::get_if<EncodableMap>(call.arguments());

    if (call.method_name() == "does_rule_exist") {
      auto rule_name_val = (arguments->find(EncodableValue("rule_name")))->second;
      std::string rule_name = std::get<std::string>(rule_name_val);
      bool does_exist = firewall_utils_.DoesRuleExist(rule_name);

      result->Success(does_exist ? 1 : 0);
    }
    else if(call.method_name() == "is_rule_enabled") {
      auto rule_name_val = (arguments->find(EncodableValue("rule_name")))->second;
      std::string rule_name = std::get<std::string>(rule_name_val);
      bool is_enabled = firewall_utils_.IsRuleEnabled(rule_name);

      result->Success(is_enabled ? 1 : 0);
    }
    else if(call.method_name() == "add_rule") {
      auto rule_name_val = (arguments->find(EncodableValue("rule_name")))->second;
      auto addresses_val = (arguments->find(EncodableValue("addresses")))->second;
      std::string rule_name = std::get<std::string>(rule_name_val);
      std::string addresses = std::get<std::string>(addresses_val);
      bool did_add = firewall_utils_.AddRule(rule_name, addresses);

      result->Success(did_add ? 1 : 0);
    }
    else if(call.method_name() == "remove_rule") {
      auto rule_name_val = (arguments->find(EncodableValue("rule_name")))->second;
      std::string rule_name = std::get<std::string>(rule_name_val);
      bool did_remove = firewall_utils_.RemoveRule(rule_name);

      result->Success(did_remove ? 1 : 0);
    }
    else if(call.method_name() == "enable_rule") {
      auto rule_name_val = (arguments->find(EncodableValue("rule_name")))->second;
      std::string rule_name = std::get<std::string>(rule_name_val);
      bool did_enable = firewall_utils_.ToggleRule(rule_name, true);

      result->Success(did_enable ? 1 : 0);
    }
    else if(call.method_name() == "disable_rule") {
      auto rule_name_val = (arguments->find(EncodableValue("rule_name")))->second;
      std::string rule_name = std::get<std::string>(rule_name_val);
      bool did_enable = firewall_utils_.ToggleRule(rule_name, false);

      result->Success(did_enable ? 1 : 0);
    } else {
      result->NotImplemented();
    }
  });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
