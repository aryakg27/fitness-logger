/// A single logged set as plain data (no database involved).
class SetData {
  const SetData(this.weight, this.reps);

  final double weight;
  final int reps;
}

/// Volume of one set = weight x reps (for example 60 kg x 8 = 480).
double setVolume(SetData set) => set.weight * set.reps;

/// Total volume of many sets added together.
double totalVolume(Iterable<SetData> sets) {
  return sets.fold(0.0, (sum, set) => sum + setVolume(set));
}

/// Estimated one-rep max using the Epley formula: weight x (1 + reps / 30).
/// It lets us compare sets with different weights and reps fairly.
/// A single rep is already the max, so it returns the weight itself.
double estimatedOneRepMax(double weight, int reps) {
  if (reps <= 1) return weight;
  return weight * (1 + reps / 30);
}

/// The best estimated one-rep max among sets, or null if there are no sets.
double? bestOneRepMax(Iterable<SetData> sets) {
  double? best;
  for (final set in sets) {
    final value = estimatedOneRepMax(set.weight, set.reps);
    if (best == null || value > best) best = value;
  }
  return best;
}

/// True if [candidate] beats every one of the [previousSets].
/// With no previous sets there is nothing to beat, so it is not a PR.
bool isNewPr({
  required SetData candidate,
  required Iterable<SetData> previousSets,
}) {
  final previousBest = bestOneRepMax(previousSets);
  if (previousBest == null) return false;
  return estimatedOneRepMax(candidate.weight, candidate.reps) > previousBest;
}