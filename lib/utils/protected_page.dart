import 'package:flutter/material.dart';
import 'session_guard.dart';

abstract class ProtectedPage extends StatefulWidget {
  const ProtectedPage({super.key});
}

abstract class ProtectedState<T extends ProtectedPage>
    extends State<T> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SessionGuard.checkSessionAndRedirect(context);
    });
  }
}
