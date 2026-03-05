import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(
  MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('my first app'),
        centerTitle: true,
        backgroundColor: Colors.red[600],
      ),
      body: Center(
        child: Text(
          'hello, ninjas!',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: Colors.red[600],
        child: Text('click'),
      ),
    ),
  ),
);
