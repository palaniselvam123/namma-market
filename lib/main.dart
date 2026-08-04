import 'package:flutter/material.dart';
import 'app_state.dart';
import 'cart.dart';
import 'screens/cart_screen.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/shop.dart';
import 'theme.dart';
import 'widgets/phone_frame.dart';

void main() => runApp(const NammaMarketApp());

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
      listenable: appState,
      builder: (context, _) => Scaffold(
        backgroundColor: context.c.bg,
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

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  static const _tabs = [
    ('🏠', 'Home'),
    ('🛍️', 'Shop'),
    ('🛒', 'Cart'),
    ('👤', 'Account'),
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
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavButton(
                    index: i,
                    emoji: _tabs[i].$1,
                    label: _tabs[i].$2,
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: active ? 1.12 : 1,
                child: Text(emoji, style: const TextStyle(fontSize: 21)),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: active ? c.primary : c.t2,
                ),
              ),
            ],
          ),
          Positioned(
            top: 4,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: active ? 1 : 0,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          if (index == 2)
            Positioned(
              top: 2,
              left: 44,
              child: ListenableBuilder(
                listenable: cart,
                builder: (context, _) {
                  if (cart.count == 0) return const SizedBox.shrink();
                  return Container(
                    constraints: const BoxConstraints(minWidth: 17),
                    height: 17,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '${cart.count}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
