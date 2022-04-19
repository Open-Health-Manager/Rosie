// This shows the getting started page.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
      Container(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text("Get Started with Preventative Health Check", style: GoogleFonts.ubuntu(fontSize: 24.0)),
          const SizedBox(height: 300),
          const Text("Looks like you don't have any health data sources yet", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("Connect your health data sources to have a more comprehensive view of your own health.", style: TextStyle(fontSize: 12.0)),
          const Expanded(child: SizedBox()),
          ElevatedButton(child: const Text("Connect Data & Services"), onPressed: () { },)
        ]),
      )
    );
  }

}