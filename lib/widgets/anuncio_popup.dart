import 'dart:async';
import 'package:flutter/material.dart';
import '../models/promocion.dart';
import '../services/promociones_service.dart';
import '../screens/productos_categoria_screen.dart';

class AnuncioPopup extends StatefulWidget {
  const AnuncioPopup({super.key});

  @override
  State<AnuncioPopup> createState() => _AnuncioPopupState();
}

class _AnuncioPopupState extends State<AnuncioPopup> {
  final PageController _pageController = PageController();
  Timer? _timerAutoAvance;
  int _paginaActual = 0;

  final List<Promocion> _promos = PromocionesService.promociones;

  @override
  void initState() {
    super.initState();
    _iniciarAutoAvance();
  }

  void _iniciarAutoAvance() {
    _timerAutoAvance = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || _promos.isEmpty) return;
      final siguiente = (_paginaActual + 1) % _promos.length;
      _pageController.animateToPage(
        siguiente,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timerAutoAvance?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _tocarAnuncio(Promocion promo) {
    if (promo.categoriaRelacionada == null) return;
    Navigator.pop(context); // cierra el popup
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductosCategoriaScreen(categoria: promo.categoriaRelacionada!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 950 / 522, // proporción real de tus banners, sin recorte
              child: PageView.builder(
                controller: _pageController,
                itemCount: _promos.length,
                onPageChanged: (i) => setState(() => _paginaActual = i),
                itemBuilder: (context, index) {
                  final promo = _promos[index];
                  return GestureDetector(
                    onTap: () => _tocarAnuncio(promo),
                    child: Image.asset(promo.imagenAsset, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_promos.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _paginaActual ? Colors.white : Colors.white38,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}