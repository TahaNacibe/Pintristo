import 'package:flutter/material.dart';
import 'package:pintresto/widgets/costume_input_filed.dart';
import 'package:pintresto/widgets/switch_tile.dart';

class AdvancedSettings extends StatefulWidget {
  final Map<String, dynamic> oldSettings;
  const AdvancedSettings({required this.oldSettings, super.key});

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  //* switch tiles vars
  bool _allowComments = true;
  bool _showSimilarProduct = true;

  //* controllers
  final TextEditingController _altController = TextEditingController();

  //* function
  void switchAllowComments(bool state) {
    setState(() {
      _allowComments = state;
    });
  }

  //* function
  void switchShowSimilarProduct(bool state) {
    setState(() {
      _showSimilarProduct = state;
    });
  }

  //* init
  @override
  void initState() {
    if (widget.oldSettings.isNotEmpty) {
      _allowComments = widget.oldSettings["allowComments"] ?? true;
      _showSimilarProduct = widget.oldSettings["showSimilarProducts"] ?? true;
      _altController.text = widget.oldSettings["altText"] ?? "";
    }
    super.initState();
  }

  //* Ui tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarForPostSettings(),
      body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
             Navigator.of(context).pop({
              "allowComments": _allowComments,
              "showSimilarProducts": _showSimilarProduct,
              "altText": _altController.text
            });
          },
          child: bodyForAdvancedSettings()),
    );
  }

  //* appBar widget
  PreferredSizeWidget appBarForPostSettings() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop({
              "allowComments": _allowComments,
              "showSimilarProducts": _showSimilarProduct,
              "altText": _altController.text
            });
          },
          icon: const Icon(Icons.arrow_back_ios)),
      centerTitle: true,
      title: const Text(
        "Advanced Settings",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
      ),
    );
  }

  //* body widget
  Widget bodyForAdvancedSettings() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* title
            sectionTitle(title: "Engagement settings"),
            //* allow comments switch
            switchTile(
                title: "Allow comments",
                value: _allowComments,
                onSwitch: switchAllowComments),
            //* alt text
            altText(controller: _altController),
            //? second section
            //* title
            sectionTitle(title: "Shopping recommendations"),
            //* allow comments switch
            switchTile(
                title: "Show similar products",
                value: _showSimilarProduct,
                onSwitch: switchShowSimilarProduct),
            //* just a text don't need a separated widget
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "People can shop products similar to what's shown in this Pin using visual search\n\nShopping recommendations aren't available for Pins with tagged products or paid partnership label",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.grey.withOpacity(.9)),
              ),
            )
          ],
        ),
      ),
    );
  }

  //* section title
  Widget sectionTitle({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
    );
  }

  //* alt text widget
  Widget altText({required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Alt Text"),
          costumeInputFiled(
              hintText: "Describe your Pin's visual details",
              horizontalPadding: 2,
              textController: controller),
          Text(
            "This helps people using screen readers understand what your Pin is about.",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey.withOpacity(.9)),
          )
        ],
      ),
    );
  }
}
