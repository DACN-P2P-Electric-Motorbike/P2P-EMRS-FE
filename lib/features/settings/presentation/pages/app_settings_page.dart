import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/app_preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../data/privacy_remote_data_source.dart';

class AppSettingsPage extends StatefulWidget {
  final PrivacyRemoteDataSource? privacyRemoteDataSource;

  const AppSettingsPage({super.key, this.privacyRemoteDataSource});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late final PrivacyRemoteDataSource _privacyRemoteDataSource;
  final List<PrivacyRequestItem> _privacyRequests = [];
  bool _isExporting = false;
  bool _isDeleting = false;
  bool _isLoadingRequests = false;
  String? _privacyError;

  @override
  void initState() {
    super.initState();
    _privacyRemoteDataSource =
        widget.privacyRemoteDataSource ?? sl<PrivacyRemoteDataSource>();
    _loadPrivacyRequests(showError: false);
  }

  Future<void> _loadPrivacyRequests({bool showError = true}) async {
    setState(() {
      _isLoadingRequests = true;
      if (showError) _privacyError = null;
    });

    try {
      final requests = await _privacyRemoteDataSource.getMyRequests();
      if (!mounted) return;
      setState(() {
        _privacyRequests
          ..clear()
          ..addAll(requests);
      });
    } catch (error) {
      if (!mounted) return;
      final message = _errorMessage(error);
      setState(() => _privacyError = message);
      if (showError) _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() => _isLoadingRequests = false);
      }
    }
  }

  Future<void> _exportPersonalData() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isExporting = true;
      _privacyError = null;
    });

    try {
      final export = await _privacyRemoteDataSource.exportPersonalData();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.t('exportSummary')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryLine(
                label: l10n.t('exportGeneratedAt'),
                value: _formatDate(export.generatedAt),
              ),
              _SummaryLine(
                label: l10n.t('exportBookings'),
                value:
                    '${export.listCount('bookingsAsRenter') + export.listCount('bookingsAsOwner')}',
              ),
              _SummaryLine(
                label: l10n.t('exportPayments'),
                value:
                    '${export.listCount('paymentsAsPayer') + export.listCount('paymentsAsReceiver')}',
              ),
              _SummaryLine(
                label: l10n.t('exportTrips'),
                value: '${export.listCount('trips')}',
              ),
              _SummaryLine(
                label: l10n.t('exportReviews'),
                value: '${export.listCount('reviews')}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.t('close')),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = _errorMessage(error, fallback: l10n.t('exportFailed'));
      setState(() => _privacyError = message);
      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _requestAccountDeletion() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('deleteRequestConfirmTitle')),
        content: Text(l10n.t('deleteRequestConfirmBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
      _privacyError = null;
    });

    try {
      final request = await _privacyRemoteDataSource.requestAccountDeletion();
      if (!mounted) return;
      setState(() {
        _privacyRequests
          ..removeWhere((item) => item.id == request.id)
          ..insert(0, request);
      });
      _showSnackBar(
        '${l10n.t('deleteRequestCreated')} ${_formatDate(request.dueAt)}',
      );
    } catch (error) {
      if (!mounted) return;
      final message = _errorMessage(error, fallback: l10n.t('deleteFailed'));
      setState(() => _privacyError = message);
      _showSnackBar(message);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _errorMessage(Object error, {String? fallback}) {
    if (error is AppException) return error.message;
    return fallback ?? error.toString();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal());
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preferences = AppPreferencesScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('settingsTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle(l10n.t('appearance')),
          const SizedBox(height: 12),
          _SettingsPanel(
            children: [
              Text(
                l10n.t('language'),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'vi',
                    label: Text(l10n.t('vietnamese')),
                    icon: const Icon(Icons.language_outlined),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text(l10n.t('english')),
                    icon: const Icon(Icons.translate_outlined),
                  ),
                ],
                selected: {preferences.locale.languageCode},
                onSelectionChanged: (selected) {
                  preferences.setLocale(Locale(selected.first));
                },
              ),
              const SizedBox(height: 22),
              Text(
                l10n.t('theme'),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.t('system')),
                    icon: const Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.t('light')),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.t('dark')),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {preferences.themeMode},
                onSelectionChanged: (selected) {
                  preferences.setThemeMode(selected.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsPanel(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.signal_cellular_alt_outlined),
                title: Text(
                  l10n.t('dataSaver'),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  l10n.t('dataSaverDescription'),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                value: preferences.dataSaverEnabled,
                onChanged: preferences.setDataSaverEnabled,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(l10n.t('privacy')),
          const SizedBox(height: 12),
          _SettingsPanel(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.privacy_tip_outlined, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.t('privacyDescription'),
                      style: GoogleFonts.poppins(fontSize: 13, height: 1.45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isExporting ? null : _exportPersonalData,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined),
                    label: Text(l10n.t('exportData')),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _isDeleting ? null : _requestAccountDeletion,
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(l10n.t('deleteAccountRequest')),
                  ),
                ],
              ),
              if (_privacyError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _privacyError!,
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.t('privacyRequests'),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.t('refresh'),
                    onPressed: _isLoadingRequests
                        ? null
                        : () => _loadPrivacyRequests(),
                    icon: const Icon(Icons.refresh_outlined),
                  ),
                ],
              ),
              if (_isLoadingRequests && _privacyRequests.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                )
              else if (_privacyRequests.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.t('noPrivacyRequests'),
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                ..._privacyRequests.map(
                  (request) => _PrivacyRequestTile(
                    request: request,
                    formatDate: _formatDate,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }
}

class _PrivacyRequestTile extends StatelessWidget {
  final PrivacyRequestItem request;
  final String Function(DateTime?) formatDate;

  const _PrivacyRequestTile({required this.request, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor(request.status);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.manage_accounts_outlined),
        title: Text(
          request.type == 'DELETE_ACCOUNT'
              ? l10n.t('deleteAccountRequest')
              : request.type,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${l10n.t('requestCreatedAt')} ${formatDate(request.createdAt)}\n'
          '${l10n.t('requestDueAt')} ${formatDate(request.dueAt)}',
          style: GoogleFonts.poppins(fontSize: 12, height: 1.4),
        ),
        trailing: Text(
          _statusLabel(l10n, request.status),
          style: GoogleFonts.poppins(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'PENDING':
        return l10n.t('statusPending');
      case 'COMPLETED':
        return l10n.t('statusCompleted');
      case 'REJECTED':
        return l10n.t('statusRejected');
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final List<Widget> children;

  const _SettingsPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
