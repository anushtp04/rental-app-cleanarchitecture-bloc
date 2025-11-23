import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../bloc/rental/rental_bloc.dart';
import '../bloc/car/car_bloc.dart';
import '../../domain/entities/rental.dart';
import '../../domain/entities/car.dart';
import '../../core/utils/image_helper.dart';
import '../../core/utils/document_helper.dart';
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

  void _onTotalDaysChanged(String value) {
    if (value.isEmpty) return;
    final days = int.tryParse(value);
    if (days != null && days > 0 && _rentFromDate != null) {
      setState(() {
        _rentToDate = _rentFromDate!.add(Duration(days: days));
        
        // Recalc price
        if (_selectedCarId != null) {
          final state = context.read<CarBloc>().state;
          if (state is CarLoaded && state.cars.any((c) => c.id == _selectedCarId)) {
            final car = state.cars.firstWhere((c) => c.id == _selectedCarId);
            final total = car.pricePerDay * days;
            _totalAmountController.text = total.toStringAsFixed(2);
          }
        }
      });
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
                              rangeHighlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              todayDecoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.5),
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

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final imagePath = await ImageHelper.pickImageFromCamera();
              if (imagePath != null && mounted) {
                setState(() {
                  _imagePath = imagePath;
                });
              }
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final imagePath = await ImageHelper.pickImage();
              if (imagePath != null && mounted) {
                setState(() {
                  _imagePath = imagePath;
                });
              }
            },
            child: const Text('Gallery'),
          ),
        ],
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
        totalAmount: double.parse(_totalAmountController.text.trim()),
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
      appBar: AppBar(
        title: Text(widget.rental != null ? 'Edit Rental' : 'Add Rental'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCarSelector(),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 20),
              
              _buildSectionTitle('Rental Period'),
              _buildCard([
                InkWell(
                  onTap: _showDatePickerModal,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Dates',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _rentFromDate != null && _rentToDate != null
                                    ? '${DateFormat('dd MMM').format(_rentFromDate!)} - ${DateFormat('dd MMM').format(_rentToDate!)}'
                                    : 'Tap to select dates',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_rentFromDate != null && _rentToDate != null)
                                Text(
                                  '${_pickupTime.format(context)} - ${_returnTime.format(context)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _totalDaysController,
                  label: 'Total Days',
                  icon: Icons.timer,
                  keyboardType: TextInputType.number,
                  onChanged: _onTotalDaysChanged,
                  hint: 'Edit to update return date',
                ),
              ]),

              const SizedBox(height: 20),
              _buildSectionTitle('Vehicle Details'),
              _buildCard([
                _buildTextField(
                  controller: _vehicleNumberController,
                  label: 'Vehicle Number',
                  icon: Icons.confirmation_number,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                  readOnly: _selectedCarId != null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _modelController,
                        label: 'Model',
                        icon: Icons.directions_car,
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                        readOnly: _selectedCarId != null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _yearController,
                        label: 'Year',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        readOnly: _selectedCarId != null,
                        validator: (v) {
                          if (v?.trim().isEmpty == true) return 'Required';
                          final y = int.tryParse(v!);
                          if (y == null || y < 1900 || y > DateTime.now().year + 1) return 'Invalid year';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ]),
              
              const SizedBox(height: 20),
              _buildSectionTitle('Renter Details'),
              _buildCard([
                _buildTextField(
                  controller: _rentToPersonController,
                  label: 'Rent To (Name)',
                  icon: Icons.person,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneNumberController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  maxLines: 2,
                ),
              ]),

              const SizedBox(height: 20),
              _buildSectionTitle('Payment & Docs'),
              _buildCard([
                _buildTextField(
                  controller: _totalAmountController,
                  label: 'Total Amount',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.trim().isEmpty == true) return 'Required';
                    if (double.tryParse(v!) == null) return 'Invalid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Commission Checkbox
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CheckboxListTile(
                    title: const Text(
                      'Commission Based',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text(
                      'Check if this rental is commission-based',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isCommissionBased,
                    onChanged: (value) {
                      setState(() {
                        _isCommissionBased = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDocumentPicker(),
              ]),

              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveRental,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.rental != null ? 'Update Rental' : 'Add Rental',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarSelector() {
    return BlocBuilder<CarBloc, CarState>(
      builder: (context, state) {
        if (state is CarLoaded) {
          final rentalState = context.read<RentalBloc>().state;
          List<Car> availableCars = state.cars;
          
          if (rentalState is RentalLoaded && _rentFromDate != null && _rentToDate != null) {
            availableCars = state.cars.where((car) {
              final isRented = rentalState.rentals.any((rental) {
                if (rental.carId != car.id) return false;
                if (rental.status == RentalStatus.completed) return false;
                
                final rStart = rental.rentFromDate;
                final rEnd = rental.rentToDate;
                final nStart = _rentFromDate!;
                final nEnd = _rentToDate!;
                
                return rStart.isBefore(nEnd) && rEnd.isAfter(nStart);
              });
              return !isRented;
            }).toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Select Car'),
              InkWell(
                onTap: () {
                  if (_rentFromDate == null || _rentToDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select dates first to see available cars')),
                    );
                    return;
                  }
                  _showCarSelectionModal(context, availableCars);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue.shade700),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedCarId != null && state.cars.any((c) => c.id == _selectedCarId)
                              ? '${state.cars.firstWhere((c) => c.id == _selectedCarId).make} ${state.cars.firstWhere((c) => c.id == _selectedCarId).model}'
                              : 'Tap to select a car',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _selectedCarId != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  void _showCarSelectionModal(BuildContext context, List<Car> cars) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 500,
        child: Column(
          children: [
            const Text(
              'Available Cars',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: cars.isEmpty
                  ? const Center(child: Text('No cars available for selected dates'))
                  : ListView.builder(
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        final car = cars[index];
                        return ListTile(
                          leading: car.imagePath != null
                              ? CircleAvatar(backgroundImage: FileImage(File(car.imagePath!)))
                              : const CircleAvatar(child: Icon(Icons.directions_car)),
                          title: Text('${car.make} ${car.model} (${car.year})'),
                          subtitle: Text('₹${car.pricePerDay}/day'),
                          onTap: () {
                            _onCarSelected(car);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? hint,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _selectedCarId == null ? _pickImage : null,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          image: _imagePath != null
              ? DecorationImage(
                  image: FileImage(File(_imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _imagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add vehicle image',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildDocumentPicker() {
    return InkWell(
      onTap: _documentPath == null ? _pickDocument : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.description, color: Colors.blue.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _documentPath != null
                        ? path.basename(_documentPath!)
                        : 'No document attached',
                    style: const TextStyle(fontWeight: FontWeight.w500),
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
              TextButton(
                onPressed: _pickDocument,
                child: const Text('Upload'),
              ),
          ],
        ),
      ),
    );
  }
}
