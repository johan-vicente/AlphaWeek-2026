class Sucursal {
  final String id;
  final String nombre;
  final String direccion;
  final String horario;
  final String telefono;
  final String imagenPreview;

  const Sucursal({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.horario,
    required this.telefono,
    required this.imagenPreview,
  });
}

class SucursalesData {
  static const List<Sucursal> sucursales = [
    Sucursal(
      id: 'villa_mella',
      nombre: 'Sirena Villa Mella',
      direccion:
      'Av. Hermanas Mirabal esq. Av. Charles de Gaulle, Santo Domingo Norte, Santo Domingo - 11200',
      horario: 'Lun-Sáb 6:00 AM - 12:00 AM | Dom 7:00 AM - 9:00 PM',
      telefono: '809-569-4022',
      imagenPreview: 'assets/mapas_preview/villa_mella.jpg',
    ),
    Sucursal(
      id: 'las_americas',
      nombre: 'Sirena Las Américas',
      direccion:
      'Marginal Avenida Las Américas, Santo Domingo Este, Santo Domingo - 11501',
      horario: 'Lun-Sáb 6:00 AM - 12:00 AM | Dom 7:00 AM - 10:00 PM',
      telefono: '809-467-2752',
      imagenPreview: 'assets/mapas_preview/las_americas.jpg',
    ),
    Sucursal(
      id: 'autopista_san_isidro',
      nombre: 'Sirena Autopista San Isidro',
      direccion: 'Autopista San Isidro, Santo Domingo Este, Santo Domingo - 11501',
      horario: 'Lun-Sáb 6:00 AM - 12:00 AM | Dom 7:00 AM - 10:00 PM',
      telefono: '809-594-9116',
      imagenPreview: 'assets/mapas_preview/autopista_san_isidro.jpg',
    ),
  ];
}