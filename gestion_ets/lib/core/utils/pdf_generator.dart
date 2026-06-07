import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../../domain/entities/ets_entity.dart';

class PdfGenerator {
  /// Genera un documento PDF con los datos del ETS, y si existe un PDF adjunto, lo descarga y fusiona.
  /// Luego abre el menú nativo para compartir/guardar.
  static Future<void> exportarEts(EtsEntity ets) async {
    // 1. Creamos el documento PDF de detalles
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
                _buildFilaDato('Profesor Evaluador:', ets.profesorNombre),

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

    // 3. Guardar el PDF autogenerado en memoria
    Uint8List finalPdfBytes = await pdf.save();

    // 4. Si el examen tiene un PDF adjunto, lo descargamos y lo fusionamos
    if (ets.pdfUrl != null && ets.pdfUrl!.trim().isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(ets.pdfUrl!));
        if (response.statusCode == 200) {
          final uploadedPdfBytes = response.bodyBytes;

          // Crear documento combinado en memoria
          final sf.PdfDocument mergedDoc = sf.PdfDocument();

          // Cargar ambos PDFs
          final sf.PdfDocument baseDoc = sf.PdfDocument(inputBytes: finalPdfBytes);
          final sf.PdfDocument attachmentDoc = sf.PdfDocument(inputBytes: uploadedPdfBytes);

          // Copiar páginas del autogenerado
          for (int i = 0; i < baseDoc.pages.count; i++) {
            final sf.PdfTemplate template = baseDoc.pages[i].createTemplate();
            mergedDoc.pages.add().graphics.drawPdfTemplate(template, const Offset(0, 0));
          }

          // Copiar páginas del PDF adjunto
          for (int i = 0; i < attachmentDoc.pages.count; i++) {
            final sf.PdfTemplate template = attachmentDoc.pages[i].createTemplate();
            mergedDoc.pages.add().graphics.drawPdfTemplate(template, const Offset(0, 0));
          }

          // Guardar el PDF resultante
          finalPdfBytes = Uint8List.fromList(await mergedDoc.save());

          // Liberar recursos
          baseDoc.dispose();
          attachmentDoc.dispose();
          mergedDoc.dispose();
        }
      } catch (e) {
        // En caso de error, procedemos con el PDF autogenerado básico
        debugPrint('Error al descargar y fusionar el PDF adjunto: $e');
      }
    }

    // 5. Usamos el paquete printing para abrir el visualizador nativo del celular
    final nombreArchivo = 'ETS_${ets.materia.replaceAll(' ', '_')}.pdf';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => finalPdfBytes,
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
