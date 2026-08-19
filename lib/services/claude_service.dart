import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio base de comunicación con la API de Claude (Anthropic).
/// Maneja el historial de la conversación activa y el resumen al cerrar.
class ClaudeService {
  static final ClaudeService _instancia = ClaudeService._interno();
  factory ClaudeService() => _instancia;
  ClaudeService._interno();

  static const String _urlBase = 'https://api.anthropic.com/v1/messages';
  static const String _modelo = 'claude-haiku-4-5-20251001';
  static const String _apiKey = String.fromEnvironment('CLAUDE_API_KEY');

  final List<Map<String, dynamic>> _historial = [];

  List<Map<String, dynamic>> get historial => List.unmodifiable(_historial);

  /// Envía un mensaje del usuario a Claude y devuelve la respuesta completa
  /// (incluye texto y, más adelante en el Issue 2, posibles tool_use).
  /// [tools] se deja opcional para que el Issue 2 lo conecte sin tocar este método.
  Future<Map<String, dynamic>> enviarMensaje(
      String mensajeUsuario, {
        List<Map<String, dynamic>>? tools,
      }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'CLAUDE_API_KEY vacía. Revisa el --dart-define en la Run Configuration.',
      );
    }

    _historial.add({
      'role': 'user',
      'content': mensajeUsuario,
    });

    final body = {
      'model': _modelo,
      'max_tokens': 2048,
      'messages': _historial,
      if (tools != null && tools.isNotEmpty) 'tools': tools,
    };

    final respuesta = await http
        .post(
      Uri.parse(_urlBase),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode(body),
    )
        .timeout(const Duration(seconds: 20));

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error de Claude API (${respuesta.statusCode}): ${respuesta.body}',
      );
    }

    final data = jsonDecode(respuesta.body) as Map<String, dynamic>;

    // Guardamos la respuesta del asistente en el historial para mantener contexto
    _historial.add({
      'role': 'assistant',
      'content': data['content'],
    });

    return data;
  }

  /// Extrae solo el texto plano de una respuesta (ignora bloques de tool_use).
  /// Útil para el Día 1 (chat básico sin tools todavía).
  String extraerTexto(Map<String, dynamic> respuesta) {
    final bloques = respuesta['content'] as List<dynamic>? ?? [];
    return bloques
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('\n');
  }

  /// Pide a Claude un resumen corto (2-3 líneas) de la conversación actual,
  /// SIN agregar esa petición al historial visible del chat.
  Future<String> generarResumen() async {
    if (_historial.isEmpty) return '';
    if (_apiKey.isEmpty) return '';

    final resumenRequest = {
      'model': _modelo,
      'max_tokens': 150,
      'messages': [
        ..._historial,
        {
          'role': 'user',
          'content':
          'Resume esta conversación en 2-3 líneas cortas, en español, '
              'mencionando qué productos o categorías buscó el usuario y si '
              'mencionó algún presupuesto. Responde SOLO el resumen, sin preámbulo.',
        },
      ],
    };

    final respuesta = await http
        .post(
      Uri.parse(_urlBase),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode(resumenRequest),
    )
        .timeout(const Duration(seconds: 15));

    if (respuesta.statusCode != 200) return '';

    final data = jsonDecode(respuesta.body) as Map<String, dynamic>;
    return extraerTexto(data);
  }

  /// Limpia el historial — se llama al cerrar el chat, después de guardar el resumen.
  void reiniciarConversacion() {
    _historial.clear();
  }
}