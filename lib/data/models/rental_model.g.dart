// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RentalModelAdapter extends TypeAdapter<RentalModel> {
  @override
  final int typeId = 0;

  @override
  RentalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RentalModel(
      id: fields[0] as String,
      vehicleNumber: fields[1] as String,
      model: fields[2] as String,
      year: fields[3] as int,
      rentToPerson: fields[4] as String,
      contactNumber: fields[5] as String?,
      email: fields[6] as String?,
      address: fields[7] as String?,
      notes: fields[8] as String?,
      rentFromDate: fields[9] as DateTime,
      rentToDate: fields[10] as DateTime,
      totalAmount: fields[11] as double,
      imagePath: fields[12] as String?,
      documentPath: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      actualReturnDate: fields[15] as DateTime?,
      isReturnApproved: fields[16] as bool,
      isCommissionBased: fields[17] as bool,
      isCancelled: fields[18] as bool,
      cancellationAmount: fields[19] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, RentalModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleNumber)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.rentToPerson)
      ..writeByte(5)
      ..write(obj.contactNumber)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.rentFromDate)
      ..writeByte(10)
      ..write(obj.rentToDate)
      ..writeByte(11)
      ..write(obj.totalAmount)
      ..writeByte(12)
      ..write(obj.imagePath)
      ..writeByte(13)
      ..write(obj.documentPath)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.actualReturnDate)
      ..writeByte(16)
      ..write(obj.isReturnApproved)
      ..writeByte(17)
      ..write(obj.isCommissionBased)
      ..writeByte(18)
      ..write(obj.isCancelled)
      ..writeByte(19)
      ..write(obj.cancellationAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RentalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
