import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/ets_entity.dart';

class PdfGenerator {
  /// Genera un documento PDF con los datos del ETS y abre el menú nativo para compartir/guardar
  static Future<void> exportarEts(EtsEntity ets) async {
    // 1. Creamos el documento PDF
    final pdf = pw.Document();

    // 2. Añadimos una página y dibujamos el contenido
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado
                pw.Center(
                  child: pw.Text(
                    'Instituto Politécnico Nacional',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Escuela Superior de Cómputo',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                ),
                pw.SizedBox(height: 40),

                // Título del documento
                pw.Text(
                  'Detalles del Examen a Título de Suficiencia (ETS)',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Datos del ETS
                _buildFilaDato('Materia:', ets.materia),
                _buildFilaDato(
                  'Fecha:',
                  ets.fecha.toLocal().toString().split(' ')[0],
                ),
                _buildFilaDato('Turno:', ets.turno),
                _buildFilaDato('Edificio / Salón:', ets.salon),
                _buildFilaDato('Profesor Evaluador:', ets.profesor),

                pw.Spacer(),

                // Pie de página
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'Documento generado por el Sistema de Gestión de ETS',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // 3. Usamos el paquete printing para abrir el visualizador nativo del celular
    final nombreArchivo = 'ETS_${ets.materia.replaceAll(' ', '_')}.pdf';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: nombreArchivo,
    );
  }

  // Widget auxiliar para no repetir código al dibujar las filas de datos
  static pw.Widget _buildFilaDato(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              etiqueta,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(valor)),
        ],
      ),
    );
  }
}
