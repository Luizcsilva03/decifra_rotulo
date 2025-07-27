// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      productName: fields[0] as String,
      brands: fields[1] as String,
      imageUrl: fields[2] as String,
      nutriments: fields[3] as Nutriments,
      barcode: fields[4] as String,
      ingredientsText: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.brands)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.nutriments)
      ..writeByte(4)
      ..write(obj.barcode)
      ..writeByte(5)
      ..write(obj.ingredientsText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NutrimentsAdapter extends TypeAdapter<Nutriments> {
  @override
  final int typeId = 1;

  @override
  Nutriments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nutriments(
      energyKcal: fields[0] as double?,
      fat: fields[1] as double?,
      carbohydrates: fields[2] as double?,
      sugars: fields[3] as double?,
      proteins: fields[4] as double?,
      salt: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Nutriments obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.energyKcal)
      ..writeByte(1)
      ..write(obj.fat)
      ..writeByte(2)
      ..write(obj.carbohydrates)
      ..writeByte(3)
      ..write(obj.sugars)
      ..writeByte(4)
      ..write(obj.proteins)
      ..writeByte(5)
      ..write(obj.salt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutrimentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
