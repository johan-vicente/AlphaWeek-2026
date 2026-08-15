import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/sucursal.dart';
import '../utils/app_colors.dart';

enum TipoEntrada { delivery, pickup, sirenaMap }

class MenuEntradaPopup extends StatefulWidget {
  const MenuEntradaPopup({super.key});

  @override
  State<MenuEntradaPopup> createState() => _MenuEntradaPopupState();
}

class _MenuEntradaPopupState extends State<MenuEntradaPopup> {
  TipoEntrada? _tipoSeleccionado;
  String? _sucursalSeleccionadaId;
  String _busqueda = '';

  List<Sucursal> get _sucursalesFiltradas {
    if (_busqueda.isEmpty) return SucursalesData.sucursales;
    final q = _busqueda.toLowerCase();
    return SucursalesData.sucursales
        .where((s) => s.nombre.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 620),
        decoration: BoxDecoration(
          color: AppColors.blanco,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOpciones(),
                    if (_tipoSeleccionado == TipoEntrada.sirenaMap) ...[
                      const SizedBox(height: 20),
                      _buildSeccionSirenaMap(),
                    ],
                  ],
                ),
              ),
            ),
            if (_tipoSeleccionado == TipoEntrada.sirenaMap) _buildBotonVisualizar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.amarilloSirena,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/branding/logo_sirena.svg', height: 28),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Escoge tu tipo de entrada',
              style: TextStyle(
                color: AppColors.cianSirenaMas,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 17,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpciones() {
    return Row(
      children: [
        _buildOpcionPill(TipoEntrada.delivery, Icons.local_shipping, 'Delivery'),
        _buildOpcionPill(TipoEntrada.pickup, Icons.storefront, 'Pickup'),
        _buildOpcionPill(TipoEntrada.sirenaMap, Icons.location_on, 'SirenaMap'),
      ],
    );
  }

  Widget _buildOpcionPill(TipoEntrada tipo, IconData icono, String label) {
    final seleccionado = _tipoSeleccionado == tipo;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => setState(() => _tipoSeleccionado = tipo),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: seleccionado ? AppColors.azulSirena : AppColors.blanco,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: seleccionado ? AppColors.azulSirena : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icono,
                  color: seleccionado ? AppColors.blanco : AppColors.azulSirena,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: seleccionado ? AppColors.blanco : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionSirenaMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visualiza el mapa de tu sucursal',
          style: TextStyle(
            color: AppColors.azulSirena,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (value) => setState(() => _busqueda = value),
          decoration: InputDecoration(
            hintText: 'Ingresa una ubicación',
            filled: true,
            fillColor: Colors.grey.shade100,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.amarilloSirena,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.search, color: Colors.black87, size: 16),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_sucursalesFiltradas.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No se encontraron sucursales'),
          )
        else
          ..._sucursalesFiltradas.map(_buildSucursalCard),
      ],
    );
  }

  Widget _buildSucursalCard(Sucursal sucursal) {
    final seleccionada = _sucursalSeleccionadaId == sucursal.id;
    return GestureDetector(
      onTap: () => setState(() => _sucursalSeleccionadaId = sucursal.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: seleccionada ? AppColors.azulSirena : Colors.grey.shade300,
            width: seleccionada ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: sucursal.id,
              groupValue: _sucursalSeleccionadaId,
              activeColor: AppColors.azulSirena,
              onChanged: (value) => setState(() => _sucursalSeleccionadaId = value),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sucursal.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  _filaInfo(Icons.location_on, sucursal.direccion),
                  _filaInfo(Icons.access_time, sucursal.horario),
                  _filaInfo(Icons.phone, sucursal.telefono),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      sucursal.imagenPreview,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaInfo(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildBotonVisualizar() {
    final habilitado = _sucursalSeleccionadaId != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: habilitado
              ? () {
            Navigator.of(context).pop();
            // TODO Ticket 16: Navigator.push a SirenaMapScreen(sucursalId: _sucursalSeleccionadaId!)
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.amarilloSirena,
            disabledBackgroundColor: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            'Visualizar',
            style: TextStyle(
              color: habilitado ? AppColors.azulSirena : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}