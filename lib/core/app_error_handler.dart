import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppErrorHandler {
  static void show(
    BuildContext context, {
    dynamic error,
    int? code,
    String? message,
  }) {
    String finalMessage = _mapError(error, code, message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          finalMessage,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ----------------------------------------------------------
  // CONVERT RAW BACKEND ERRORS INTO FRIENDLY MESSAGES
  // ----------------------------------------------------------
  static String _mapError(dynamic error, int? code, String? msg) {
    if (code != null) {
      switch (code) {
        case 401:
          return "You're not authorized. Please login again.";
        case 403:
          return "You don't have permission to access this feature.";
        case 404:
          return "We couldn't find what you were looking for.";
        case 408:
          return "The server is taking too long. Please try again.";
        case 500:
          return "Server is facing issues. Please try later.";
      }
    }

    // NETWORK ERRORS
    if (error.toString().contains("SocketException")) {
      return "No internet connection. Check your network.";
    }

    if (error.toString().contains("TimeoutException")) {
      return "Request timed out. Please try again.";
    }

    // CUSTOM BACKEND MESSAGES (cleaned)
    if (msg != null && msg.isNotEmpty) {
      return _cleanMessage(msg);
    }

    return "Something went wrong. Please try again.";
  }

  // Removes ugly backend formatting
  static String _cleanMessage(String msg) {
    return msg
        .replaceAll(RegExp(r"\b\d{3}\b"), "")
        .replaceAll("Exception:", "")
        .replaceAll("Error:", "")
        .trim();
  }
}
