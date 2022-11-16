library vizo_recaptcha;

import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'contants.dart';

class CustomRecaptchaV2 extends StatefulWidget {
  final RecaptchaV2Controller controller;
  final void Function(JavascriptMessage) onMessageReceived;
  final String apiKey;
  final String apiSecret;
  final String pluginUrl;
  final String? textCancelButton;

  final Function(String token) onVerifiedSuccessfully;
  final Function(String error)? onVerifiedError;

  const CustomRecaptchaV2({
    Key? key,
    required this.controller,
    required this.apiKey,
    required this.apiSecret,
    required this.onVerifiedSuccessfully,
    this.onVerifiedError,
    this.pluginUrl = 'https://recaptcha-flutter-plugin.firebaseapp.com/',
    this.textCancelButton = 'CANCEL CAPTCHA',
    required this.onMessageReceived,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomRecaptchaV2State();
}

class _CustomRecaptchaV2State extends State<CustomRecaptchaV2> {
  RecaptchaV2Controller get controller => widget.controller;
  WebViewPlusController? webViewController;

  void onListen() {
    if (controller.visible) {}
    setState(() {
      controller.visible;
    });
  }

  @override
  void initState() {
    controller.addListener(onListen);
    super.initState();
  }

  @override
  void didUpdateWidget(CustomRecaptchaV2 oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(onListen);
      controller.removeListener(onListen); // TODO ??
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.removeListener(onListen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (controller.visible == false) return const SizedBox.shrink();

    return WillPopScope(
      onWillPop: () {
        if (controller.visible) {
          controller.hide();
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: GestureDetector(
        onTap: controller.hide,
        child: AnimatedContainer(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * .1,
            vertical: size.height * .10,
          ),
          duration: const Duration(milliseconds: 600),
          color: Colors.black.withOpacity(0.5),
          child: Stack(
            children: [
              WebViewPlus(
                initialUrl: AppConstants.getRecaptchaWebViewUrl(widget.pluginUrl, widget.apiKey),
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: <JavascriptChannel>{
                  JavascriptChannel(
                    name: 'RecaptchaFlutterChannel',
                    onMessageReceived: widget.onMessageReceived,
                  ),
                },
                onWebViewCreated: (_controller) {
                  webViewController = _controller;
                },
              ),
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Visibility(
      visible: widget.textCancelButton != null,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                child: Text(widget.textCancelButton ?? ''),
                onPressed: () {
                  controller.hide();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecaptchaV2Controller extends ChangeNotifier {
  bool isDisposed = false;
  List<VoidCallback> _listeners = [];

  bool _visible = false;
  bool get visible => _visible;

  void show() {
    _visible = true;
    if (!isDisposed) notifyListeners();
  }

  void hide() {
    _visible = false;
    if (!isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _listeners = [];
    isDisposed = true;
    super.dispose();
  }

  @override
  void addListener(listener) {
    _listeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(listener) {
    _listeners.remove(listener);
    super.removeListener(listener);
  }
}
