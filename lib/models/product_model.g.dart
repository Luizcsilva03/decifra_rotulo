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
      nutritionGrades: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.ingredientsText)
      ..writeByte(6)
      ..write(obj.nutritionGrades);
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
      dataPer: fields[0] as String,
      energyKcal: fields[1] as double?,
      fat: fields[2] as double?,
      saturatedFat: fields[3] as double?,
      transFat: fields[4] as double?,
      carbohydrates: fields[5] as double?,
      sugars: fields[6] as double?,
      fiber: fields[7] as double?,
      proteins: fields[8] as double?,
      salt: fields[9] as String?,
      sodium: fields[10] as double?,
      vitaminA: fields[11] as double?,
      vitaminC: fields[12] as double?,
      vitaminD: fields[13] as double?,
      vitaminB1: fields[14] as double?,
      vitaminB6: fields[15] as double?,
      vitaminB12: fields[16] as double?,
      calcium: fields[17] as double?,
      iron: fields[18] as double?,
      magnesium: fields[19] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Nutriments obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.dataPer)
      ..writeByte(1)
      ..write(obj.energyKcal)
      ..writeByte(2)
      ..write(obj.fat)
      ..writeByte(3)
      ..write(obj.saturatedFat)
      ..writeByte(4)
      ..write(obj.transFat)
      ..writeByte(5)
      ..write(obj.carbohydrates)
      ..writeByte(6)
      ..write(obj.sugars)
      ..writeByte(7)
      ..write(obj.fiber)
      ..writeByte(8)
      ..write(obj.proteins)
      ..writeByte(9)
      ..write(obj.salt)
      ..writeByte(10)
      ..write(obj.sodium)
      ..writeByte(11)
      ..write(obj.vitaminA)
      ..writeByte(12)
      ..write(obj.vitaminC)
      ..writeByte(13)
      ..write(obj.vitaminD)
      ..writeByte(14)
      ..write(obj.vitaminB1)
      ..writeByte(15)
      ..write(obj.vitaminB6)
      ..writeByte(16)
      ..write(obj.vitaminB12)
      ..writeByte(17)
      ..write(obj.calcium)
      ..writeByte(18)
      ..write(obj.iron)
      ..writeByte(19)
      ..write(obj.magnesium);
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
