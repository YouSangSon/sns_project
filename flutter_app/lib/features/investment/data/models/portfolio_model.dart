import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/portfolio_entity.dart';

part 'portfolio_model.freezed.dart';
part 'portfolio_model.g.dart';

/// 포트폴리오 모델 (DTO)
@freezed
class PortfolioModel with _$PortfolioModel {
  const PortfolioModel._();

  const factory PortfolioModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @Default([]) List<HoldingModel> holdings,
    @JsonKey(name: 'total_value') @Default(0.0) double totalValue,
    @JsonKey(name: 'total_cost') @Default(0.0) double totalCost,
    @JsonKey(name: 'total_return') @Default(0.0) double totalReturn,
    @JsonKey(name: 'total_return_percent') @Default(0.0) double totalReturnPercent,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _PortfolioModel;

  factory PortfolioModel.fromJson(Map<String, dynamic> json) =>
      _$PortfolioModelFromJson(json);

  /// Entity로 변환
  PortfolioEntity toEntity() => PortfolioEntity(
        id: id,
        userId: userId,
        name: name,
        holdings: holdings.map((h) => h.toEntity()).toList(),
        totalValue: totalValue,
        totalCost: totalCost,
        totalReturn: totalReturn,
        totalReturnPercent: totalReturnPercent,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// 보유 종목 모델 (DTO)
@freezed
class HoldingModel with _$HoldingModel {
  const HoldingModel._();

  const factory HoldingModel({
    required String id,
    required String symbol,
    required String name,
    required double quantity,
    @JsonKey(name: 'average_cost') required double averageCost,
    @JsonKey(name: 'current_price') required double currentPrice,
    @JsonKey(name: 'total_value') @Default(0.0) double totalValue,
    @JsonKey(name: 'total_return') @Default(0.0) double totalReturn,
    @JsonKey(name: 'return_percent') @Default(0.0) double returnPercent,
    @JsonKey(name: 'logo_url') String? logoUrl,
  }) = _HoldingModel;

  factory HoldingModel.fromJson(Map<String, dynamic> json) =>
      _$HoldingModelFromJson(json);

  /// Entity로 변환
  HoldingEntity toEntity() => HoldingEntity(
        id: id,
        symbol: symbol,
        name: name,
        quantity: quantity,
        averageCost: averageCost,
        currentPrice: currentPrice,
        totalValue: totalValue,
        totalReturn: totalReturn,
        returnPercent: returnPercent,
        logoUrl: logoUrl,
      );
}
