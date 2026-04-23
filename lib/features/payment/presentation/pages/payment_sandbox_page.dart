import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/payment_entity.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class PaymentSandboxPage extends StatelessWidget {
  const PaymentSandboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PaymentBloc>(),
      child: const _PaymentSandboxView(),
    );
  }
}

class _PaymentSandboxView extends StatefulWidget {
  const _PaymentSandboxView();

  @override
  State<_PaymentSandboxView> createState() => _PaymentSandboxViewState();
}

class _PaymentSandboxViewState extends State<_PaymentSandboxView> {
  final _bookingIdController = TextEditingController();
  final _paymentIdController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.payos;

  String _logString = '';

  void _log(String message) {
    setState(() {
      _logString = '[${DateTime.now().toIso8601String().split('T').last}] $message\n\n$_logString';
    });
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    _paymentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dev: Payment Sandbox',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentLoading) {
            _log('Status: Loading...');
          } else if (state is PaymentLoaded) {
            _paymentIdController.text = state.payment.id;
            _log('Loaded Payment: ${state.payment.id}\nStatus: ${state.payment.status.name}\nAmount: ${state.payment.amount}');
          } else if (state is PaymentCreated) {
            _paymentIdController.text = state.payment.id;
            _log('Created Payment: ${state.payment.id}\nStatus: ${state.payment.status.name}');
          } else if (state is PaymentSuccess) {
            _log('Simulate Success: ${state.message}\nPayment ID: ${state.payment.id}\nStatus: ${state.payment.status.name}');
          } else if (state is PaymentRefunded) {
            _log('Refunded Payment: ${state.payment.id}\nStatus: ${state.payment.status.name}');
          } else if (state is PaymentUrlGenerated) {
            _log('URL Generated:\nCheckout Url: ${state.paymentUrl}\nDeeplink: ${state.deeplink ?? 'N/A'}\nQRCode: ${state.qrCode != null ? 'Present' : 'None'}');
          } else if (state is PaymentFailure) {
            _log('ERROR: ${state.message}');
          } else if (state is NoPaymentFound) {
            _log('No payment found for this booking.');
          }
        },
        builder: (context, state) {
          final isLoading = state is PaymentLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader('Inputs'),
                        TextField(
                          controller: _bookingIdController,
                          decoration: const InputDecoration(
                            labelText: 'Booking ID',
                            hintText: 'Enter a valid booking ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _paymentIdController,
                          decoration: const InputDecoration(
                            labelText: 'Payment ID',
                            hintText: 'Enter a valid payment ID',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<PaymentMethod>(
                          value: _selectedMethod,
                          decoration: const InputDecoration(
                            labelText: 'Payment Method (for Create)',
                            border: OutlineInputBorder(),
                          ),
                          items: PaymentMethod.values.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedMethod = value);
                            }
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Actions - Booking Related'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (_bookingIdController.text.isEmpty) return _log('Missing Booking ID');
                                context.read<PaymentBloc>().add(LoadPaymentByBookingEvent(_bookingIdController.text));
                              },
                              child: const Text('Get by Booking ID'),
                            ),
                            ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (_bookingIdController.text.isEmpty) return _log('Missing Booking ID');
                                context.read<PaymentBloc>().add(CreatePaymentEvent(
                                  bookingId: _bookingIdController.text,
                                  method: _selectedMethod,
                                ));
                              },
                              child: const Text('Create Payment'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Actions - Payment Related'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (_paymentIdController.text.isEmpty) return _log('Missing Payment ID');
                                context.read<PaymentBloc>().add(GetPaymentByIdEvent(_paymentIdController.text));
                              },
                              child: const Text('Get Payment by ID'),
                            ),
                            ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (_paymentIdController.text.isEmpty) return _log('Missing Payment ID');
                                context.read<PaymentBloc>().add(InitiatePayOSEvent(_paymentIdController.text));
                              },
                              child: const Text('Initiate PayOS'),
                            ),
                            ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (_paymentIdController.text.isEmpty) return _log('Missing Payment ID');
                                context.read<PaymentBloc>().add(InitiateMoMoEvent(_paymentIdController.text));
                              },
                              child: const Text('Initiate MoMo'),
                            ),
                            ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (_paymentIdController.text.isEmpty) return _log('Missing Payment ID');
                                context.read<PaymentBloc>().add(SimulatePaymentSuccessEvent(_paymentIdController.text));
                              },
                              child: const Text('Simulate Success'),
                            ),
                            ElevatedButton(
                              onPressed: isLoading ? null : () {
                                if (_paymentIdController.text.isEmpty) return _log('Missing Payment ID');
                                context.read<PaymentBloc>().add(RefundPaymentEvent(_paymentIdController.text));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              child: const Text('Refund Payment'),
                            ),
                            if (state is PaymentUrlGenerated) ... [
                              ElevatedButton(
                                onPressed: () {
                                  final uri = Uri.tryParse(state.paymentUrl);
                                  if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Open Payment Link'),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Logs',
                              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => setState(() => _logString = ''),
                            )
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _logString,
                              style: GoogleFonts.robotoMono(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
