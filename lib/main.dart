import 'package:flutter/material.dart';
import 'app_state.dart';
import 'cart.dart';
import 'catalog_store.dart';
import 'screens/cart_screen.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/shop.dart';
import 'supabase_config.dart';
import 'theme.dart';
import 'widgets/phone_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const NammaMarketApp());
  // Fire-and-forget: don't block first paint on the network round trip.
  catalogStore.loadRemoteProducts();
}

class NammaMarketApp extends StatelessWidget {
  const NammaMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namma MahaRaja Super Market',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: Scaffold(
        body: PhoneFrame(
          // A nested navigator keeps sheets and dialogs inside the phone
          // frame instead of spanning the whole browser window.
          child: Navigator(
            onGenerateRoute: (_) =>
                MaterialPageRoute(builder: (_) => const Shell()),
          ),
        ),
      ),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appState, catalogStore]),
      builder: (context, _) => Scaffold(
        backgroundColor: context.c.bg,
        appBar: const _TopBar(),
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: appState.tab,
            children: const [
              HomeScreen(),
              ShopScreen(),
              CartScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: const _BottomNav(),
      ),
    );
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Namma MahaRaja',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: c.t0,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => appState.goTab(2),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('🛒', style: const TextStyle(fontSize: 22)),
                        ),
                        ListenableBuilder(
                          listenable: cart,
                          builder: (context, _) {
                            if (cart.count == 0) return const SizedBox.shrink();
                            return Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 18),
                                height: 18,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: c.primary,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  '${cart.count}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => appState.goTab(3),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('👤', style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const _tabs = [
    (0, '🏠', 'Home'),
    (1, '🛍️', 'Shop'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (final (index, emoji, label) in _tabs)
                Expanded(
                  child: _NavButton(
                    index: index,
                    emoji: emoji,
                    label: label,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final int index;
  final String emoji;
  final String label;

  const _NavButton({
    required this.index,
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final active = appState.tab == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => appState.goTab(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: active ? 1.08 : 1,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: c.t2,
            ),
          ),
        ],
      ),
    );
  }
}
