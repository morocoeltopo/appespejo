import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:glass_down_v2/app/app.locator.dart';
import 'package:glass_down_v2/app/app.snackbar.dart';
import 'package:glass_down_v2/models/errors/io_error.dart';
import 'package:glass_down_v2/services/logs_service.dart';
import 'package:glass_down_v2/services/settings_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

class ExportLogsModel extends ReactiveViewModel {
  final _logs = locator<LogsService>();
  final _snackbar = locator<SnackbarService>();
  final _settings = locator<SettingsService>();

  String get exportLogsPath {
    if (_settings.exportLogsPath.length <= 20) {
      return 'Main Storage';
    }
    return _settings.exportLogsPath.substring(20);
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_settings];

  Future<void> pickFolder(BuildContext context) async {
    try {
      final result = await FilesystemPicker.openDialog(
        context: context,
        rootDirectory: Directory('/storage/emulated/0'),
        fsType: FilesystemType.folder,
        contextActions: [FilesystemPickerNewFolderContextAction()],
      );
      if (result == null) {
        throw IOError('Path has not been picked');
      }
      final testDir = Directory(result);
      final testFile = File('${testDir.path}/test.txt');
      testFile.createSync();
      testFile.deleteSync();
      _settings.setExportLogsPath(result);
      _snackbar.showCustomSnackBar(
        title: 'Info',
        message: 'Path saved succesfully',
        variant: SnackbarType.info,
      );
      rebuildUi();
    } catch (e) {
      FlutterLogs.logError(
        runtimeType.toString(),
        'pickFolder',
        'Cannot write to this folder',
      );
      _snackbar.showCustomSnackBar(
        title: 'Error',
        message: e is IOError ? e.message : "Can't pick this folder",
        variant: SnackbarType.info,
      );
    }
  }

  Future<void> exportLogs() async {
    try {
      await _logs.exportLogs();
      _snackbar.showCustomSnackBar(
        title: 'Logs',
        message: 'Logs exported',
        variant: SnackbarType.info,
      );
    } catch (e) {
      _snackbar.showCustomSnackBar(
        title: 'Error',
        message: e is IOError ? e.message : e.toString(),
        variant: SnackbarType.info,
      );
    }
  }
}
