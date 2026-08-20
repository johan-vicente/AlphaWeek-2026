import '../models/promocion.dart';
import '../services/promociones_service.dart';

class AnuncioPasilloMap {
  static Map<String, Promocion> get mapa => {
    'zona_electrodomesticos': PromocionesService.promociones[0], // anuncio1 - Escolares
    'pasillo5': PromocionesService.promociones[1], // anuncio2 - Market Manía (Limpieza)
    'pasillo6': PromocionesService.promociones[1], // anuncio2 - Market Manía (Cuidado de la Ropa)
  };
}