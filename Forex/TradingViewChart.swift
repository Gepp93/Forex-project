import SwiftUI
import WebKit

#if os(iOS)
struct TradingViewChart: UIViewRepresentable {
    @State private var isLoading = true
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = false
        
        // Load TradingView widget with a more robust error handling
        DispatchQueue.main.async {
            let html = """
            <!DOCTYPE html>
            <html style="height: 100%; width: 100%; margin: 0; padding: 0;">
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    body { margin: 0; padding: 0; height: 100%; width: 100%; }
                    .tradingview-widget-container { height: 100%; width: 100%; }
                    #tradingview_chart { height: 100%; width: 100%; }
                </style>
            </head>
            <body>
                <div class="tradingview-widget-container">
                    <div id="tradingview_chart"></div>
                </div>
                <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
                <script type="text/javascript">
                    new TradingView.widget({
                        "autosize": true,
                        "symbol": "FX:EURUSD",
                        "interval": "15",
                        "timezone": "exchange",
                        "theme": "dark",
                        "style": "1",
                        "toolbar_bg": "#f1f3f6",
                        "enable_publishing": false,
                        "hide_side_toolbar": false,
                        "allow_symbol_change": true,
                        "container_id": "tradingview_chart",
                        "hide_volume": true,
                        "hide_left_toolbar": true,
                        "toolbar_bg": "#000000",
                        "studies": []
                    });
                </script>
            </body>
            </html>
            """
            
            webView.loadHTMLString(html, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: TradingViewChart
        
        init(_ parent: TradingViewChart) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("WebView error: \(error.localizedDescription)")
        }
    }
}
#else
// macOS implementation
struct TradingViewChart: NSViewRepresentable {
    @State private var isLoading = true
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // Load TradingView widget
        DispatchQueue.main.async {
            let html = """
            <!DOCTYPE html>
            <html style="height: 100%; width: 100%; margin: 0; padding: 0;">
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <style>
                    body { margin: 0; padding: 0; height: 100%; width: 100%; }
                    .tradingview-widget-container { height: 100%; width: 100%; }
                    #tradingview_chart { height: 100%; width: 100%; }
                </style>
            </head>
            <body>
                <div class="tradingview-widget-container">
                    <div id="tradingview_chart"></div>
                </div>
                <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
                <script type="text/javascript">
                    new TradingView.widget({
                        "autosize": true,
                        "symbol": "FX:EURUSD",
                        "interval": "15",
                        "timezone": "exchange",
                        "theme": "dark",
                        "style": "1",
                        "toolbar_bg": "#f1f3f6",
                        "enable_publishing": false,
                        "hide_side_toolbar": false,
                        "allow_symbol_change": true,
                        "container_id": "tradingview_chart",
                        "hide_volume": true,
                        "hide_left_toolbar": true,
                        "toolbar_bg": "#000000",
                        "studies": []
                    });
                </script>
            </body>
            </html>
            """
            
            webView.loadHTMLString(html, baseURL: nil)
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: TradingViewChart
        
        init(_ parent: TradingViewChart) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("WebView error: \(error.localizedDescription)")
        }
    }
}
#endif 