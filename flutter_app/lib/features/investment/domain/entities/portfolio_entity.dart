import 'package:freezed_annotation/freezed_annotation.dart';

part 'portfolio_entity.freezed.dart';

/// 포트폴리오 엔티티
@freezed
class PortfolioEntity with _$PortfolioEntity {
  const factory PortfolioEntity({
    required String id,
    required String userId,
    required String name,
    @Default([]) List<HoldingEntity> holdings,
    @Default(0.0) double totalValue,
    @Default(0.0) double totalCost,
    @Default(0.0) double totalReturn,
    @Default(0.0) double totalReturnPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PortfolioEntity;
}

/// 보유 종목 엔티티
@freezed
class HoldingEntity with _$HoldingEntity {
  const factory HoldingEntity({
    required String id,
    required String symbol,
    required String name,
    required double quantity,
    required double averageCost,
    required double currentPrice,
    @Default(0.0) double totalValue,
    @Default(0.0) double totalReturn,
    @Default(0.0) double returnPercent,
    String? logoUrl,
  }) = _HoldingEntity;
}
