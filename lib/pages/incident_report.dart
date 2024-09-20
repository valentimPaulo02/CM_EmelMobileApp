import 'package:flutter/material.dart';
import 'package:parking_app/data/database.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/view_models/incident_report_view_model.dart';
import 'package:parking_app/widgets/button.dart';
import 'package:provider/provider.dart';

import '../domain/incident.dart';
import '../main.dart';
import '../widgets/toast.dart';

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({
    super.key,
    required this.setPage,
  });

  final void Function(AppPage page) setPage;

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  late final GlobalAppState _globalAppState;
  bool _stateAlreadyInitialized = false;
  late final IncidentReportViewModel _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_stateAlreadyInitialized) {
      _globalAppState = Provider.of<GlobalAppState>(context);
      _viewModel = IncidentReportViewModel(_globalAppState);
      _stateAlreadyInitialized = true;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _viewModel.time ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    surface: Theme.of(context).listItemBackground1,
                    surfaceTint: Colors.transparent,
                    onPrimary: Theme.of(context).colorScheme.secondary,
                  ),
              dialogBackgroundColor: Theme.of(context).menuBackground,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            ));
      },
    );

    if (pickedTime != null && pickedTime != _viewModel.time) {
      setState(() {
        _viewModel.setTime = pickedTime;
        _viewModel.setFilledTime = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _viewModel.date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: Theme.of(context).listItemBackground1,
                  surfaceTint: Colors.transparent,
                  onPrimary: Theme.of(context).colorScheme.secondary,
                ),
            dialogBackgroundColor: Theme.of(context).menuBackground,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _viewModel.date) {
      setState(() {
        _viewModel.setDate = pickedDate;
        _viewModel.setFilledDate = true;
      });
    }
  }

  void _showPhotoPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Choose an option',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          surfaceTintColor: Theme.of(context).listItemBackground1,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.camera,
                  size: 32,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
                title: Text(
                  'Take a photo',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8),
                  ),
                ),
                onTap: () {
                  _viewModel.setPicture = 'Photo';
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.image,
                  size: 32,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8),
                  ),
                ),
                onTap: () {
                  _viewModel.setPicture = 'Gallery';
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _travelToDashboard() {
    widget.setPage(AppPage.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<LocalDatabase>();

    return ChangeNotifierProvider(
        create: (_) => _viewModel,
        child: Consumer<IncidentReportViewModel>(
            builder: (context, model, child) => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TextWidget(
                            'Parking Lot',
                            18,
                            Theme.of(context).colorScheme.secondary,
                            FontWeight.bold,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 45,
                            alignment: Alignment.center,
                            decoration: _containerDecoration(
                                context, _viewModel.filledPark),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: Container(height: 0),
                                hint: const _TextWidget(
                                  'Select a parking lot',
                                  16,
                                  Color(0xFF708090),
                                  FontWeight.normal,
                                ),
                                value: _viewModel.parkName,
                                items: model.parkingLotNames
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _viewModel.setParkName = newValue!;
                                    _viewModel.setFilledPark = true;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TextWidget(
                                  'Date',
                                  18,
                                  Theme.of(context).colorScheme.secondary,
                                  FontWeight.bold,
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    height: 45,
                                    decoration: _containerDecoration(
                                        context, _viewModel.filledDate),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _viewModel.date != null
                                              ? Text(
                                                  _viewModel.date
                                                      .toString()
                                                      .substring(0, 10),
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )
                                              : const _TextWidget(
                                                  'Select date',
                                                  16,
                                                  Color(0xFF708090),
                                                  FontWeight.normal,
                                                ),
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 20,
                                            color: Color(0xFF708090),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 35.0),
                            child: _TextWidget(
                              '-',
                              30,
                              Theme.of(context).colorScheme.secondary,
                              FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TextWidget(
                                  'Time',
                                  18,
                                  Theme.of(context).colorScheme.secondary,
                                  FontWeight.bold,
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () => _selectTime(context),
                                  child: Container(
                                    height: 45,
                                    decoration: _containerDecoration(
                                        context, _viewModel.filledTime),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _viewModel.time != null
                                              ? Text(
                                                  '${_viewModel.time!.hour.toString().padLeft(2, '0')}h${_viewModel.time!.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )
                                              : const _TextWidget(
                                                  'Select time',
                                                  16,
                                                  Color(0xFF708090),
                                                  FontWeight.normal,
                                                ),
                                          const Icon(
                                            Icons.access_time,
                                            size: 22,
                                            color: Color(0xFF708090),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TextWidget(
                            'Description',
                            18,
                            Theme.of(context).colorScheme.secondary,
                            FontWeight.bold,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 100,
                            decoration: _containerDecoration(context, true),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
                              child: SingleChildScrollView(
                                child: TextField(
                                  maxLines: null,
                                  onChanged: (value) {
                                    setState(() {
                                      _viewModel.setDescription = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Brief description of the incident',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF708090),
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TextWidget(
                            'Severity',
                            18,
                            Theme.of(context).colorScheme.secondary,
                            FontWeight.bold,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SeverityButton(
                                severity: 1,
                                isSelected: _viewModel.severity ==
                                    IncidentSeverity.veryLow,
                                onPressed: (severity) {
                                  setState(() {
                                    _viewModel.setSeverity =
                                        IncidentSeverity.veryLow;
                                    _viewModel.setFilledSeverity = true;
                                  });
                                },
                                isFilled: _viewModel.filledSeverity,
                              ),
                              _SeverityButton(
                                severity: 2,
                                isSelected:
                                    _viewModel.severity == IncidentSeverity.low,
                                onPressed: (severity) {
                                  setState(() {
                                    _viewModel.setSeverity =
                                        IncidentSeverity.low;
                                    _viewModel.setFilledSeverity = true;
                                  });
                                },
                                isFilled: _viewModel.filledSeverity,
                              ),
                              _SeverityButton(
                                severity: 3,
                                isSelected: _viewModel.severity ==
                                    IncidentSeverity.medium,
                                onPressed: (severity) {
                                  setState(() {
                                    _viewModel.setSeverity =
                                        IncidentSeverity.medium;
                                    _viewModel.setFilledSeverity = true;
                                  });
                                },
                                isFilled: _viewModel.filledSeverity,
                              ),
                              _SeverityButton(
                                severity: 4,
                                isSelected: _viewModel.severity ==
                                    IncidentSeverity.high,
                                onPressed: (severity) {
                                  setState(() {
                                    _viewModel.setSeverity =
                                        IncidentSeverity.high;
                                    _viewModel.setFilledSeverity = true;
                                  });
                                },
                                isFilled: _viewModel.filledSeverity,
                              ),
                              _SeverityButton(
                                severity: 5,
                                isSelected: _viewModel.severity ==
                                    IncidentSeverity.veryHigh,
                                onPressed: (severity) {
                                  setState(() {
                                    _viewModel.setSeverity =
                                        IncidentSeverity.veryHigh;
                                    _viewModel.setFilledSeverity = true;
                                  });
                                },
                                isFilled: _viewModel.filledSeverity,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TextWidget(
                                'Very Low',
                                12,
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.8),
                                FontWeight.normal,
                              ),
                              _TextWidget(
                                'Very High',
                                12,
                                Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.8),
                                FontWeight.normal,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TextWidget(
                            'Photos (optional)',
                            18,
                            Theme.of(context).colorScheme.secondary,
                            FontWeight.bold,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.6),
                            ),
                            iconSize: 44,
                            onPressed: () {
                              _showPhotoPickerDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Spacer(),
                          AppButton(
                            text: 'Submit',
                            color: Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 22,
                            ),
                            onPressed: () async {
                              setState(() {});
                              _viewModel.checkFormCamps();
                              if (await _viewModel.createIncident(db)) {
                                Toast.triggerToast(
                                  context,
                                  'Form successfully submitted.',
                                  true,
                                  ToastAlignment.top,
                                  null,
                                  _travelToDashboard,
                                );
                              } else {
                                Toast.triggerToast(
                                  context,
                                  'Please fill the mandatory fields.',
                                  false,
                                  ToastAlignment.top,
                                  const Duration(seconds: 4),
                                  null,
                                );
                              }
                            },
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                )));
  }
}

// ---------------------- WIdgets ------------------------------------------
BoxDecoration _containerDecoration(BuildContext context, bool filled) {
  return BoxDecoration(
    color: const Color(0xFF2d3239),
    borderRadius: BorderRadius.circular(8.0),
    border: filled
        ? null
        : Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        spreadRadius: 0,
        blurRadius: 3,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

class _TextWidget extends StatelessWidget {
  const _TextWidget(
    this.text,
    this.size,
    this.color,
    this.fontWeight,
  );

  final String text;
  final double size;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
      ),
      softWrap: true,
    );
  }
}

class _SeverityButton extends StatefulWidget {
  const _SeverityButton({
    required this.severity,
    required this.onPressed,
    required this.isSelected,
    required this.isFilled,
  });

  final int severity;
  final Function(int) onPressed;
  final bool isSelected;
  final bool isFilled;

  @override
  State<_SeverityButton> createState() => _SeverityButtonState();
}

class _SeverityButtonState extends State<_SeverityButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(50),
        border: widget.isFilled
            ? null
            : Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.error,
              ),
      ),
      child: TextButton(
          onPressed: () {
            widget.onPressed(widget.severity);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              widget.isSelected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFF4A525E),
            ),
          ),
          child: _TextWidget(
            '${widget.severity}',
            17,
            widget.isSelected
                ? Theme.of(context).colorScheme.surface
                : widget.isFilled
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.error,
            FontWeight.bold,
          )),
    );
  }
}
