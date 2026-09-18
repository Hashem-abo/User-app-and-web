import 'zego_express_api.dart';
import 'impl/zego_express_impl.dart';
import 'zego_express_defines.dart';

// ignore_for_file: deprecated_member_use_from_same_package

extension ZegoExpressEngineCustomAudioSource on ZegoExpressEngine {
  /// Create custom audio source instance.
  ///
  /// Available since: 3.25.0
  /// Description: Create custom audio source instance.
  /// Use cases: Typically used to create an independent custom audio source and mix it into the publish stream as a mix source.
  /// When to call: After the engine is created [createEngine].
  /// Restrictions: None.
  /// Caution:
  ///  1. ZegoCustomAudioSource can only be used as a mix source, not as the main capture source.
  ///  2. Currently, up to 2 custom audio source instances are supported, with the screen sharing audio source occupying one instance.
  ///
  /// - Returns Custom audio source instance.
  Future<ZegoCustomAudioSource?> createCustomAudioSource() async {
    return await ZegoExpressImpl.instance.createCustomAudioSource();
  }

  /// Destroy custom audio source instance.
  ///
  /// Available since: 3.25.0
  /// Description: Destroy custom audio source instance.
  /// Use cases: Typically used to destroy a custom audio mix source instance.
  /// When to call: After the engine is created [createEngine].
  /// Restrictions: None.
  /// Caution: ZegoCustomAudioSource can only be used as a mix source, not as the main capture source.
  ///
  /// - [source] Custom audio source instance.
  Future<void> destroyCustomAudioSource(ZegoCustomAudioSource source) async {
    return await ZegoExpressImpl.instance.destroyCustomAudioSource(source);
  }
}
