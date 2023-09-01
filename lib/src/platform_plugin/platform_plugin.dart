import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/* 

  This code's purpose is to install the dylibs inside the macOS app on build

  see: /dfc_gpt/macos/dfc_gpt_plugin_macos.podspec

  The podspec file loads the Libraries folder into the macOS bundle
  so they can get signed and packed up

  The linux and windows code is just there to look complete, but they do nothing

  on linux we package the models with flatpak
  on windows, we copy the models to the app folder on build

*/

class PlatformPlugin {
  String platform() {
    return PlatformPluginInterface.instance.platform();
  }
}

// =============================================================

abstract class PlatformPluginInterface extends PlatformInterface {
  PlatformPluginInterface() : super(token: _token);

  // ignore: no-object-declaration
  static final Object _token = Object();

  static PlatformPluginInterface _instance = DefaultHello();
  static PlatformPluginInterface get instance => _instance;

  static set instance(PlatformPluginInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  String platform() {
    throw UnimplementedError('platform() has not been implemented.');
  }
}

// =========================================================

class DefaultHello extends PlatformPluginInterface {
  @override
  String platform() {
    return 'default';
  }
}

// =========================================================

class LinuxHello extends PlatformPluginInterface {
  static void registerWith() {
    PlatformPluginInterface.instance = LinuxHello();
  }

  @override
  String platform() {
    return 'linux';
  }
}

// =========================================================

class WindowsHello extends PlatformPluginInterface {
  static void registerWith() {
    PlatformPluginInterface.instance = WindowsHello();
  }

  @override
  String platform() {
    return 'windows';
  }
}

// =========================================================

class MacOSHello extends PlatformPluginInterface {
  static void registerWith() {
    PlatformPluginInterface.instance = MacOSHello();
  }

  @override
  String platform() {
    return 'macOS';
  }
}
