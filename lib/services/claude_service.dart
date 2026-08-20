import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tools_ia.dart';

const String _systemPromptChat =
    'Eres Sira, el asistente de compras de Sirena. Respondes siempre en '
    'español, de forma breve y amigable. IMPORTANTE: nunca uses formato '
    'markdown (nada de **negritas**, guiones de lista, ni encabezados) — '
    'responde en texto plano simple, como si fuera un mensaje de chat normal. '
    'Si el usuario envía una imagen, analízala e identifica el producto. Usa '
    'la tool identificar_producto_por_imagen para buscarlo en el catálogo. '
    'Si la herramienta de búsqueda (ya sea por texto o por imagen) devuelve 0 resultados, '
    'comunícale al usuario que no tenemos ese producto. NUNCA inventes productos, '
    'marcas o precios que no estén en tu base de datos. Si la foto muestra algo que '
    'no cuadra con un producto de supermercado o no se encuentra, dilo claramente sin falsos positivos. '
    'Si el usuario pide ingredientes o una lista de compra para una receta '
    'dominicana precargada (por ahora: sancocho), usa SIEMPRE la tool '
    'armar_lista_receta primero — nunca uses buscar_producto ni '
    'identificar_producto_por_imagen para ese caso, ya que armar_lista_receta '
    'ya trae la lista exacta y verificada, y evita mezclar productos irrelevantes.';

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

  /// Chat simple, sin tools.
  Future<Map<String, dynamic>> enviarMensaje(String mensajeUsuario) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'CLAUDE_API_KEY vacía. Revisa el --dart-define en la Run Configuration.',
      );
    }

    _historial.add({'role': 'user', 'content': mensajeUsuario});
    final data = await _llamarAPI();
    _historial.add({'role': 'assistant', 'content': data['content']});
    return data;
  }

  /// Chat con tool use activo: ejecuta las tools que Claude pida y sigue
  /// el ciclo hasta que responda con texto final.
  Future<Map<String, dynamic>> enviarMensajeConTools(
    String mensajeUsuario, {
    String? base64Image,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'CLAUDE_API_KEY vacía. Revisa el --dart-define en la Run Configuration.',
      );
    }

    if (base64Image != null && base64Image.isNotEmpty) {
      _historial.add({
        'role': 'user',
        'content': [
          {
            "type": "image",
            "source": {
              "type": "base64",
              "media_type": "image/jpeg",
              "data": base64Image
            }
          },
          {
            "type": "text",
            "text": mensajeUsuario
          }
        ]
      });
    } else {
      _historial.add({'role': 'user', 'content': mensajeUsuario});
    }

    Map<String, dynamic> data = await _llamarAPI(tools: ToolsIA.definiciones);

    while (data['stop_reason'] == 'tool_use') {
      _historial.add({'role': 'assistant', 'content': data['content']});

      final bloques = data['content'] as List<dynamic>;
      final resultadosTools = <Map<String, dynamic>>[];

      for (final bloque in bloques) {
        if (bloque['type'] == 'tool_use') {
          final resultado = await ToolsIA.ejecutar(
            bloque['name'] as String,
            bloque['input'] as Map<String, dynamic>,
          );
          resultadosTools.add({
            'type': 'tool_result',
            'tool_use_id': bloque['id'],
            'content': jsonEncode(resultado),
          });
        }
      }

      _historial.add({'role': 'user', 'content': resultadosTools});
      data = await _llamarAPI(tools: ToolsIA.definiciones);
    }

    _historial.add({'role': 'assistant', 'content': data['content']});
    return data;
  }

  /// Llamada cruda a la API, reutilizada por los métodos de arriba/abajo.
  Future<Map<String, dynamic>> _llamarAPI({
    List<Map<String, dynamic>>? tools,
  }) async {
    final body = {
      'model': _modelo,
      'max_tokens': 2048,
      'system': _systemPromptChat,
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

    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }

  /// Extrae solo el texto plano de una respuesta (ignora bloques tool_use).
  String extraerTexto(Map<String, dynamic> respuesta) {
    final bloques = respuesta['content'] as List<dynamic>? ?? [];
    return bloques
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('\n');
  }

  /// Resumen corto (2-3 líneas) de la conversación, sin ensuciar el historial visible.
  Future<String> generarResumen() async {
    if (_historial.isEmpty || _apiKey.isEmpty) return '';

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