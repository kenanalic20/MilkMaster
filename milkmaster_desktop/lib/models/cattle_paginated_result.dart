import 'package:milkmaster_desktop/models/cattle_model.dart';
import 'package:milkmaster_desktop/models/paginated_result.dart';

class CattlePaginatedResult extends PaginatedResult<Cattle> {
  final double totalRevenue;
  final double totalLiters;

  CattlePaginatedResult({
    required List<Cattle> items,
    required int totalCount,
    required this.totalRevenue,
    required this.totalLiters,
  }) : super(items: items, totalCount: totalCount);
}