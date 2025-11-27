import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../domain/entities/car.dart';
import '../bloc/car/car_bloc.dart';
import '../../core/utils/image_helper.dart';

class AddCarPage extends StatefulWidget {
  final Car? car;

  const AddCarPage({super.key, this.car});

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _numberController;
  late TextEditingController _colorController;
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerPhoneController;
  late TextEditingController _priceController;
  String? _imagePath;
  TransmissionType _selectedTransmission = TransmissionType.manual;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController(text: widget.car?.make);
    _modelController = TextEditingController(text: widget.car?.model);
    _yearController = TextEditingController(text: widget.car?.year.toString());
    _numberController = TextEditingController(text: widget.car?.vehicleNumber);
    _colorController = TextEditingController(text: widget.car?.color);
    _selectedTransmission = widget.car?.transmission ?? TransmissionType.manual;
    _ownerNameController = TextEditingController(text: widget.car?.ownerName);
    _ownerPhoneController = TextEditingController(text: widget.car?.ownerPhoneNumber);
    _priceController = TextEditingController(text: widget.car?.pricePerDay.toString());
    _imagePath = widget.car?.imagePath;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _numberController.dispose();
    _colorController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await ImageHelper.pickImage();
    if (path != null) {
      setState(() => _imagePath = path);
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      final car = Car(
        id: widget.car?.id ?? const Uuid().v4(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        color: _colorController.text.trim(),
        transmission: _selectedTransmission,
        ownerName: _ownerNameController.text.trim(),
        ownerPhoneNumber: _ownerPhoneController.text.trim(),
        pricePerDay: double.parse(_priceController.text.trim()),
        imagePath: _imagePath,
        vehicleNumber: _numberController.text.trim(),
      );

      if (widget.car != null) {
        context.read<CarBloc>().add(UpdateCarEvent(car));
      } else {
        context.read<CarBloc>().add(AddCarEvent(car));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car != null ? 'Edit Vehicle' : 'Add New Vehicle'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Vehicle Details'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildModernTextField(_makeController, 'Make', Icons.branding_watermark_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildModernTextField(_modelController, 'Model', Icons.directions_car_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildModernTextField(_yearController, 'Year', Icons.calendar_today_outlined, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildModernTextField(_colorController, 'Color', Icons.palette_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              _buildModernTextField(_numberController, 'Vehicle Number', Icons.confirmation_number_outlined),
              const SizedBox(height: 16),
              _buildTransmissionSelector(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Pricing'),
              const SizedBox(height: 16),
              _buildModernTextField(_priceController, 'Price per Day (₹)', Icons.currency_rupee, isNumber: true),

              const SizedBox(height: 32),
              _buildSectionTitle('Owner Details'),
              const SizedBox(height: 16),
              _buildModernTextField(_ownerNameController, 'Owner Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildModernTextField(_ownerPhoneController, 'Owner Phone', Icons.phone_outlined, isPhone: true),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.car != null ? 'Update Vehicle' : 'Add Vehicle',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Vehicle Photo',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber
              ? TextInputType.number
              : (isPhone ? TextInputType.phone : TextInputType.text),
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) => value?.isEmpty == true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildTransmissionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transmission',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTransmission = TransmissionType.manual),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedTransmission == TransmissionType.manual ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _selectedTransmission == TransmissionType.manual
                          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings,
                          size: 18,
                          color: _selectedTransmission == TransmissionType.manual ? Colors.black : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Manual',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _selectedTransmission == TransmissionType.manual ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTransmission = TransmissionType.automatic),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedTransmission == TransmissionType.automatic ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _selectedTransmission == TransmissionType.automatic
                          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_mode,
                          size: 18,
                          color: _selectedTransmission == TransmissionType.automatic ? Colors.black : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Automatic',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _selectedTransmission == TransmissionType.automatic ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
