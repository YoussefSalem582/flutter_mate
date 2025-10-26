import 'package:flutter_mate/features/roadmap/data/models/roadmap_stage.dart';

/// Repository contract for retrieving roadmap stages and tracking progress.
abstract class RoadmapRepository {
  Future<List<RoadmapStage>> fetchStages();
  Future<double> getStageProgress(String stageId);
  Future<void> updateStageProgress(String stageId, double progress);
  Future<double> getOverallProgress();
}
