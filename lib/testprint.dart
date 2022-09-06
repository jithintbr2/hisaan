import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';

class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample(String companyName,String type,String itemName,String sellingCost,String mrp,String qty,String totalCost,String employeeId,String code,String brand,String qtyType,String section,String barcode ) async {
    final DateFormat formatter = DateFormat('d-M-yyyy');
    final String formatted =
    formatter.format(DateTime.now());
    String time=new DateFormat.jm().format(DateTime.now());
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom(companyName, 1, 1);
        bluetooth.printQRcode1(code, 300, 65, 1);
        bluetooth.printCustom("Barcode : "+code,1, 0);
        bluetooth.printCustom("Item Name : "+itemName,1, 0);
        bluetooth.printCustom("Price : "+sellingCost+"  MRP: "+mrp,1, 0,charset: "windows-1250");
        bluetooth.printCustom("Qty: "+qty+"  Brand: "+brand, 1, 0);
        bluetooth.printCustom("Net Amount: "+totalCost+" Type: "+qtyType, 1, 0);
        bluetooth.printCustom("Date:"+formatted+" "+time+" "+"Section:"+section,0, 0);
        bluetooth.printQRcode1(employeeId, 200, 40,1);
        bluetooth.printCustom('Empid:'+employeeId, 0, 1);
        bluetooth.printCustom("Powered By Hisan Technologies",0, 1);
        bluetooth.printCustom("www.hisantechnologies.com",0, 1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    });
  }
}
