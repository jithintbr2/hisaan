import 'package:flutter/material.dart';
import 'package:flutter_app_check/common.dart';
import 'package:new_version/new_version.dart';

class ForceUpdate extends StatefulWidget {


  @override
  _ForceUpdateState createState() => _ForceUpdateState();
}

class _ForceUpdateState extends State<ForceUpdate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Update!!!', style: TextStyle(
                color: Colors.black,

                fontSize: 20)),
            Padding(
              padding: const EdgeInsets.only(top:20,bottom: 30,left:40,right:40),
              child: Text('Mscale Recomend That You Update To The Latest Version.', style: TextStyle(
                  color: Colors.black,

                  fontSize: 15)),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.045,
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(0),
              ),
              child: FlatButton(
                onPressed: () async {
                  Common.showProgressDialog(context, "Loading..");
                  _dialogue(context);



                },
                //onPressed:()=>_dialogue(context),
                child: Text(
                  'Update',
                  style: TextStyle(
                      color: Colors.white,

                      fontSize: 16),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  void _dialogue(BuildContext context) async {
    final newVersion=NewVersion(
      androidId:"com.pavithra.user",
    );
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'UPDATE!!!',
        dialogText: 'Please Update The app From "+ "${status.localVersion}"+" to "+"${status.storeVersion}',
        updateButtonText: "Update",
        allowDismissal: false,
      );
    }
  }

}
