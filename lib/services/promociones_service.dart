import '../models/promocion.dart';

class PromocionesService {
  static final List<Promocion> promociones = [
        Promocion(
      imagenAsset: 'assets/promociones/anuncio1.jpg',
      titulo: 'Escolares — Vuelta a Clases',
      descripcion:
      'Promoción de útiles escolares con descuentos especiales para la temporada de regreso a clases.',
      categoriaRelacionada: null,
    ),
    Promocion(
      imagenAsset: 'assets/promociones/anuncio2.jpg',
      titulo: 'Colección Market Manía',
      descripcion:
      'Promoción de coleccionables Minions: completa las postalitas de tu '
          'libro comprando en la sirena y participa por un viaje para 4 personas a Orlando, Florida.',
      categoriaRelacionada: 'Despensa',
    ),
  ];
}