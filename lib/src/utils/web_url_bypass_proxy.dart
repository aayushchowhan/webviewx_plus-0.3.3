import 'package:http/http.dart' as http;
import 'package:webviewx_plus/src/utils/utils.dart';
import 'dart:developer';
import 'dart:convert';


/// Proxy which will be used to fetch page sources in the [SourceType.urlBypass] mode.
abstract class BypassProxy {
  const BypassProxy();

  /// Builds the proxied url
  String buildProxyUrl(String pageUrl);

  /// Returns the page source from the response body
  String extractPageSource(String responseBody);

  /// A default list of public proxies
  static const publicProxies = <BypassProxy>[
   // BridgedBypassProxy(),
    CodeTabsBypassProxy(),
  //  WeCorsAnyWhereProxy(),
  ];

  Future<String> fetchPageSource({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final proxiedUri = Uri.parse(buildProxyUrl(Uri.encodeFull(url)));

    Future<http.Response> request;

    if (method == 'get') {
      request = http.get(proxiedUri, headers: headers);
    } else {
      request = http.post(proxiedUri, headers: headers, body: body);
    }

    final response = await request;

    final decodedHtml = utf8.decode(response.bodyBytes);

    log("${decodedHtml} body");

    return extractPageSource(decodedHtml);
  }
}

/// cors.bridged.cc proxy
class BridgedBypassProxy extends BypassProxy {
  const BridgedBypassProxy();

  @override
  String buildProxyUrl(String pageUrl) {
    return 'https://cors.bridged.cc/$pageUrl';
  }

  @override
  String extractPageSource(String responseBody) {
    return responseBody;
  }
}

/// api.codetabs.com proxy
class CodeTabsBypassProxy extends BypassProxy {
  const CodeTabsBypassProxy();

  @override
  String buildProxyUrl(String pageUrl) {
    return 'https://devcmsconapp.redriver-22ad8644.uksouth.azurecontainerapps.io?destination=$pageUrl';
  }

  @override
  String extractPageSource(String responseBody) {
    return responseBody;
  }
}

/// we-cors-anywhere.herokuapp.com proxy
class WeCorsAnyWhereProxy extends BypassProxy {
  const WeCorsAnyWhereProxy();

  @override
  String buildProxyUrl(String pageUrl) {
    return 'https://we-cors-anywhere.herokuapp.com/$pageUrl';
  }

  @override
  String extractPageSource(String responseBody) {
    return responseBody;
  }
}

/* 
Example for when the proxy's response is not the page source directly,
but instead it's a JSON object.

Such as this: {"response": "<html><head>......."}



class ExampleExtractPageSourceBypassProxy implements BypassProxy {
  @override
  String buildRequestUrl(String pageUrl) {
    return 'https://example-extract-page-source/$pageUrl';
  }

  @override
  String extractPageSource(String responseBody) {
    final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
    return jsonResponse['response'] as String;
  }
}
*/