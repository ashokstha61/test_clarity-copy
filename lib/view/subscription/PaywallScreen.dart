import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offering? offering;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      setState(() {
        offering = offerings.current;
      });
    } catch (e) {
      print("❌ Error fetching offerings: $e");
    }
  }

  Future<void> _purchase(Package package) async {
    try {
      CustomerInfo info = (await Purchases.purchasePackage(package)) as CustomerInfo;
      if (info.entitlements.active.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Purchase successful!")),
        );
      }
    } catch (e) {
      print("❌ Purchase failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (offering == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final packages = offering!.availablePackages;
    if (packages.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No packages available")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Subscribe")),
      body: ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return ListTile(
            title: Text(package.storeProduct.title),
            subtitle: Text(package.storeProduct.description),
            trailing: Text(package.storeProduct.priceString),
            onTap: () => _purchase(package),
          );
        },
      ),
    );
  }
}
