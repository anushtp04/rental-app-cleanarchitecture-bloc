import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/rental/rental_bloc.dart';
import '../bloc/car/car_bloc.dart';
import '../../domain/entities/rental.dart';
import '../../domain/entities/car.dart';

import '../../core/utils/document_helper.dart';
import '../widgets/car_image_widget.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:table_calendar/table_calendar.dart';

class AddRentalPage extends StatefulWidget {
  final Rental? rental;

  const AddRentalPage({super.key, this.rental});

  @override
  State<AddRentalPage> createState() => _AddRentalPageState();
}

class _AddRentalPageState extends State<AddRentalPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _rentToPersonController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _totalDaysController = TextEditingController();
  
  DateTime? _rentFromDate;
  DateTime? _rentToDate;
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 17, minute: 0);
  
  String? _imagePath;
  String? _documentPath;
  String? _selectedCarId;
  bool _isCommissionBased = false;

  @override
  void initState() {
    super.initState();
    context.read<CarBloc>().add(LoadCars());
    
    // Set default dates to today for new rentals
    if (widget.rental == null) {
      final today = DateTime.now();
      _rentFromDate = DateTime(today.year, today.month, today.day);
      _rentToDate = DateTime(today.year, today.month, today.day);
    }
    
    if (widget.rental != null) {
      _vehicleNumberController.text = widget.rental!.vehicleNumber;
      _modelController.text = widget.rental!.model;
      _yearController.text = widget.rental!.year.toString();
      _rentToPersonController.text = widget.rental!.rentToPerson;
      _phoneNumberController.text = widget.rental!.contactNumber ?? '';
      _addressController.text = widget.rental!.address ?? '';
      _totalAmountController.text = widget.rental!.totalAmount.toString();
      
      _rentFromDate = widget.rental!.rentFromDate;
      _rentToDate = widget.rental!.rentToDate;
      _pickupTime = TimeOfDay.fromDateTime(widget.rental!.rentFromDate);
      _returnTime = TimeOfDay.fromDateTime(widget.rental!.rentToDate);
      
      _imagePath = widget.rental!.imagePath;
      _documentPath = widget.rental!.documentPath;
      _selectedCarId = widget.rental!.carId;
      _isCommissionBased = widget.rental!.isCommissionBased;
      
      _calculateTotalDays();
    } else {
      // Set default dates: today and tomorrow
      _rentFromDate = DateTime.now();
      _rentToDate = DateTime.now().add(const Duration(days: 1));
      _calculateTotalDays();
    }
  }

  void _calculateTotalDays() {
    if (_rentFromDate != null && _rentToDate != null) {
      final start = DateTime(
        _rentFromDate!.year,
        _rentFromDate!.month,
        _rentFromDate!.day,
        _pickupTime.hour,
        _pickupTime.minute,
      );
      final end = DateTime(
        _rentToDate!.year,
        _rentToDate!.month,
        _rentToDate!.day,
        _returnTime.hour,
        _returnTime.minute,
      );
      
      final difference = end.difference(start);
      // Allow same-day rentals - minimum 1 day
      final days = difference.inDays > 0 ? difference.inDays : 1;
      _totalDaysController.text = days.toString();
      
      // Auto-calculate total amount if a car is selected
      if (_selectedCarId != null) {
        final state = context.read<CarBloc>().state;
        if (state is CarLoaded && state.cars.any((c) => c.id == _selectedCarId)) {
          final car = state.cars.firstWhere((c) => c.id == _selectedCarId);
          final total = car.pricePerDay * days;
          _totalAmountController.text = total.toStringAsFixed(2);
        }
      }
    }
  }


  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _rentToPersonController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _totalAmountController.dispose();
    _totalDaysController.dispose();
    super.dispose();
  }

  Future<void> _showDatePickerModal() async {
    DateTime focusedDay = _rentFromDate ?? DateTime.now();
    DateTime? tempFromDate = _rentFromDate;
    DateTime? tempToDate = _rentToDate;
    TimeOfDay tempPickupTime = _pickupTime;
    TimeOfDay tempReturnTime = _returnTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const Text(
                        'Date & Time',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _rentFromDate = tempFromDate;
                            _rentToDate = tempToDate;
                            _pickupTime = tempPickupTime;
                            _returnTime = tempReturnTime;
                            _calculateTotalDays();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TableCalendar(
                            firstDay: DateTime.now().subtract(const Duration(days: 365)),
                            lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                            focusedDay: focusedDay,
                            selectedDayPredicate: (day) => isSameDay(tempFromDate, day),
                            rangeStartDay: tempFromDate,
                            rangeEndDay: tempToDate,
                            calendarFormat: CalendarFormat.month,
                            rangeSelectionMode: RangeSelectionMode.toggledOn,
                            onDaySelected: (selectedDay, newFocusedDay) {
                              setModalState(() {
                                if (!isSameDay(tempFromDate, selectedDay)) {
                                  tempFromDate = selectedDay;
                                  focusedDay = newFocusedDay;
                                  tempToDate = null;
                                }
                              });
                            },
                            onRangeSelected: (start, end, newFocusedDay) {
                              setModalState(() {
                                tempFromDate = start;
                                // If end is null (single date selected), set it to start for same-day rental
                                tempToDate = end ?? start;
                                focusedDay = newFocusedDay;
                              });
                            },
                            onPageChanged: (newFocusedDay) {
                              focusedDay = newFocusedDay;
                            },
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              rangeStartDecoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              rangeEndDecoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              rangeHighlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              todayDecoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimePickerButton(
                                  context,
                                  label: 'Pick-up time',
                                  time: tempPickupTime,
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: tempPickupTime,
                                    );
                                    if (time != null) {
                                      setModalState(() {
                                        tempPickupTime = time;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTimePickerButton(
                                  context,
                                  label: 'Return Time',
                                  time: tempReturnTime,
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: tempReturnTime,
                                    );
                                    if (time != null) {
                                      setModalState(() {
                                        tempReturnTime = time;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimePickerButton(BuildContext context, {required String label, required TimeOfDay time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _pickDocument() async {
    final documentPath = await DocumentHelper.pickDocument();
    if (documentPath != null && mounted) {
      setState(() {
        _documentPath = documentPath;
      });
    }
  }

  void _onCarSelected(Car car) {
    setState(() {
      _selectedCarId = car.id;
      _vehicleNumberController.text = car.vehicleNumber;
      _modelController.text = car.model;
      _yearController.text = car.year.toString();
      _imagePath = car.imagePath;
      
      _calculateTotalDays();
    });
  }

  void _saveRental() {
    if (_formKey.currentState!.validate()) {
      if (_rentFromDate == null || _rentToDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date range')),
        );
        return;
      }

      final startDateTime = DateTime(
        _rentFromDate!.year,
        _rentFromDate!.month,
        _rentFromDate!.day,
        _pickupTime.hour,
        _pickupTime.minute,
      );
      
      final endDateTime = DateTime(
        _rentToDate!.year,
        _rentToDate!.month,
        _rentToDate!.day,
        _returnTime.hour,
        _returnTime.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return time cannot be before pickup time')),
        );
        return;
      }

      final rental = Rental(
        id: widget.rental?.id ?? const Uuid().v4(),
        carId: _selectedCarId,
        vehicleNumber: _vehicleNumberController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        rentToPerson: _rentToPersonController.text.trim(),
        contactNumber: _phoneNumberController.text.trim().isEmpty ? null : _phoneNumberController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        rentFromDate: startDateTime,
        rentToDate: endDateTime,
        totalAmount: double.tryParse(_totalAmountController.text.trim()) ?? 0.0,
        imagePath: _imagePath,
        documentPath: _documentPath,
        createdAt: widget.rental?.createdAt ?? DateTime.now(),
        actualReturnDate: widget.rental?.actualReturnDate,
        isReturnApproved: widget.rental?.isReturnApproved ?? false,
        isCommissionBased: _isCommissionBased,
      );

      if (widget.rental != null) {
        context.read<RentalBloc>().add(UpdateRentalEvent(rental));
      } else {
        context.read<RentalBloc>().add(AddRental(rental));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.rental != null ? 'Edit Rental' : 'New Rental',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Vehicle Information', Icons.directions_car_outlined),
              const SizedBox(height: 12),
              _buildCarSelector(),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Rental Period', Icons.calendar_today_outlined),
              const SizedBox(height: 12),
              _buildRentalPeriodCard(),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Renter Details', Icons.person_outline),
              const SizedBox(height: 12),
              _buildRenterDetailsForm(),

              const SizedBox(height: 24),
              _buildSectionHeader('Payment & Documents', Icons.payment_outlined),
              const SizedBox(height: 12),
              _buildPaymentAndDocsForm(),

              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveRental,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    widget.rental != null ? 'Update Rental' : 'Create Rental',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // A simple step indicator or just a nice header area
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.rental != null 
                  ? 'Editing rental details' 
                  : 'Fill in the details to create a new rental',
              style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCarSelector() {
    return BlocBuilder<CarBloc, CarState>(
      builder: (context, state) {
        if (state is CarLoaded) {
          // Pass all cars to the modal, availability will be checked there
          return InkWell(
            onTap: () {
              if (_rentFromDate == null || _rentToDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select dates first to see available cars'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              _showCarSelectionModal(context, state.cars);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedCarId != null ? Colors.blue : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: _selectedCarId != null ? Colors.blue : Colors.grey.shade400,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCarId != null && state.cars.any((c) => c.id == _selectedCarId)
                          ? '${state.cars.firstWhere((c) => c.id == _selectedCarId).make} ${state.cars.firstWhere((c) => c.id == _selectedCarId).model} (${state.cars.firstWhere((c) => c.id == _selectedCarId).vehicleNumber})'
                          : 'Select Vehicle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _selectedCarId != null ? FontWeight.w600 : FontWeight.normal,
                        color: _selectedCarId != null ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }


  Widget _buildRentalPeriodCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _showDatePickerModal,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.date_range, color: Colors.orange.shade700),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date Range',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _rentFromDate != null && _rentToDate != null
                              ? '${DateFormat('dd MMM').format(_rentFromDate!)} - ${DateFormat('dd MMM').format(_rentToDate!)}'
                              : 'Select dates',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_totalDaysController.text} Days',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pickupTime.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Return Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _returnTime.format(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenterDetailsForm() {
    return Column(
      children: [
        _buildModernTextField(
          controller: _rentToPersonController,
          label: 'Full Name',
          hint: 'Enter renter\'s name',
          icon: Icons.person_outline,
          validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _phoneNumberController,
          label: 'Phone Number',
          hint: 'Enter phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter full address',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPaymentAndDocsForm() {
    return Column(
      children: [
        _buildModernTextField(
          controller: _totalAmountController,
          label: 'Total Amount',
          hint: '0.00',
          icon: Icons.currency_rupee,
          keyboardType: TextInputType.number,
          validator: (v) {
            // Optional now
            if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Invalid amount';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SwitchListTile(
            title: const Text(
              'Commission Based',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Enable if this rental involves commission',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            value: _isCommissionBased,
            onChanged: (value) {
              setState(() {
                _isCommissionBased = value;
              });
            },
            activeThumbColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 16),
        _buildDocumentPicker(),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool readOnly = false,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade200),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
    );
  }


  Widget _buildDocumentPicker() {
    return InkWell(
      onTap: _documentPath == null ? _pickDocument : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _documentPath != null ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _documentPath != null ? Icons.check_circle_outline : Icons.description_outlined,
                color: _documentPath != null ? Colors.green : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental Agreement / ID',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _documentPath != null
                        ? path.basename(_documentPath!)
                        : 'Upload document (PDF/Image)',
                    style: TextStyle(
                      fontSize: 12,
                      color: _documentPath != null ? Colors.green : Colors.grey.shade500,
                      fontWeight: _documentPath != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_documentPath != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _documentPath = null;
                  });
                },
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Upload',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCarSelectionModal(BuildContext context, List<Car> cars) {
    final rentalState = context.read<RentalBloc>().state;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Vehicle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: cars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No cars found',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: cars.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final car = cars[index];
                        bool isRented = false;

                        if (rentalState is RentalLoaded && _rentFromDate != null && _rentToDate != null) {
                          isRented = rentalState.rentals.any((rental) {
                            if (rental.carId != car.id) return false;
                            if (rental.status == RentalStatus.completed) return false;
                            if (rental.isCancelled) return false;

                            // If rental is overdue, car is always unavailable (not yet returned)
                            if (rental.status == RentalStatus.overdue) return true;

                            // For ongoing and upcoming rentals, check date overlap
                            final rStart = rental.rentFromDate;
                            final rEnd = rental.rentToDate;
                            final nStart = _rentFromDate!;
                            final nEnd = _rentToDate!;

                            return rStart.isBefore(nEnd) && rEnd.isAfter(nStart);
                          });
                        }

                        return InkWell(
                          onTap: isRented
                              ? null
                              : () {
                                  _onCarSelected(car);
                                  Navigator.pop(context);
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isRented ? Colors.red.shade100 : Colors.grey.shade200,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: isRented ? Colors.red.shade50.withValues(alpha: 0.3) : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: car.imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CarImageWidget(
                                            imagePath: car.imagePath,
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          ),
                                        )
                                      : Icon(Icons.directions_car, color: Colors.grey.shade400),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${car.make} ${car.model}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isRented ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        car.vehicleNumber,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (isRented)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Running',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else ...[
                                      Text(
                                        '₹${car.pricePerDay.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const Text(
                                        '/day',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
