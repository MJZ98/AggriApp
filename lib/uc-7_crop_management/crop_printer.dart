import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'crop_model.dart';

class CropPrinter {
  // دالة لطباعة محصول
  static Future<void> printCrop(CropModel crop) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Crop Management Report',
                  style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 20),
              pw.Text('Crop Name: ${crop.name}'),
              pw.Text('Planting Date: ${crop.plantingDate}'),
              pw.Text('Harvest Date: ${crop.harvestDate}'),
              pw.Text('Location: ${crop.lat}, ${crop.lng}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}