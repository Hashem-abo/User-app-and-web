import 'dart:convert';
import 'dart:developer';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';

class PusherHelper {
  static PusherChannelsClient? pusherClient;

  static Future<void> initializePusher() async {
    final splashController = Get.isRegistered<SplashController>() ? Get.find<SplashController>() : null;
    final config = splashController?.configModel;

    // Check if websocket is enabled in the backend config
    if (config?.websocketEnabled != true) {
      log('Pusher: WebSocket is not enabled in backend config');
      return;
    }

    // Determine host: prefer config websocketUrl, fallback to AppConstants.baseUrl host
    String host = (config?.websocketUrl != null && config!.websocketUrl!.trim().isNotEmpty)
        ? config.websocketUrl!.trim()
        : Uri.parse(AppConstants.baseUrl).host;

    // Strip out any protocol scheme if present in host
    if (host.contains('://')) {
      host = Uri.parse(host).host;
    }

    bool isHttps = AppConstants.baseUrl.startsWith('https') || (config?.websocketUrl?.startsWith('wss') ?? false);
    String scheme = isHttps ? 'wss' : 'ws';
    int port = config?.websocketPort ?? (isHttps ? 443 : 6001);
    String key = (config?.websocketKey != null && config!.websocketKey!.trim().isNotEmpty)
        ? config.websocketKey!.trim()
        : '6ammart';

    try {
      if (pusherClient != null) {
        await pusherClient?.disconnect();
        pusherClient = null;
      }

      PusherChannelsOptions options = PusherChannelsOptions.fromHost(
        host: host,
        scheme: scheme,
        key: key,
        port: port,
      );

      log('Pusher: Initializing connection to $scheme://$host:$port with key: $key');

      pusherClient = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) async {
          log('Pusher connection error: $exception');
        },
      );

      pusherClient?.lifecycleStream.listen((event) {
        if (event == PusherChannelsClientLifeCycleState.establishedConnection) {
          log('=================Pusher Connected');
        } else if (event == PusherChannelsClientLifeCycleState.disconnected ||
            event == PusherChannelsClientLifeCycleState.connectionError) {
          log('=================Pusher Disconnected: $event');
        }
      });

      await pusherClient?.connect();
    } catch (e) {
      log('Pusher initialize error: $e');
    }
  }

  PublicChannel? publicChannel;

  void pusherDriverStatus({required String deliverymanId, required Function(RecordLocationBodyModel) onLocationReceived}) {
    if (pusherClient == null) {
      log('Pusher: Cannot subscribe, pusherClient is null');
      return;
    }

    String channel = 'dm_location_$deliverymanId';
    log('========channel is: $channel');

    publicChannel = pusherClient!.publicChannel(channel);
    publicChannel?.subscribeIfNotUnsubscribed();

    publicChannel?.bind('pusher:subscription_succeeded').listen((_) {
      log('=======Public Subscribed');
    });

    publicChannel?.bind('pusher:subscription_error').listen((error) {
      log('=======Public Subscription Failed: ${error.data}');
    });

    publicChannel?.bind(channel).listen((event) {
      log('===========pusherDriverStatus bind is: ${event.data}');
      if (event.data != null) {
        try {
          final data = jsonDecode(event.data);
          onLocationReceived(RecordLocationBodyModel(
            latitude: data['latitude']?.toString(),
            longitude: data['longitude']?.toString(),
            location: data['location']?.toString(),
          ));
        } catch (e) {
          log('Error parsing driver location: $e');
        }
      }
    });
  }

  void pusherDisconnectPusher() {
    try {
      publicChannel?.unsubscribe();
      pusherClient?.disconnect();
    } catch (e) {
      log('Error disconnecting pusher: $e');
    }
  }
}

class RecordLocationBodyModel {
  String? latitude;
  String? longitude;
  String? location;

  RecordLocationBodyModel({this.latitude, this.longitude, this.location});
}