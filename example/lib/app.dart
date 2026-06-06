import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import 'gallery/gallery_page.dart';
import 'ui/tokens.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hud_overlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: T.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: T.bg,
      ),
      // HudScope hosts the global overlay used by HudService. A dark preset is
      // the default look for context-free service calls in this demo.
      builder: (context, child) => HudScope(
        defaultTheme: HudTheme.dark(),
        child: child!,
      ),
      home: const GalleryPage(),
    );
  }
}
