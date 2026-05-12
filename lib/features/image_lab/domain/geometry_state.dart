class GeometryState {
  final int rotationQuarterTurns; // 0, 1, 2, 3 (0=0, 1=90CW, 2=180, 3=270CW/90CCW)
  final bool flipHorizontal;
  final bool flipVertical;
  final double scaleFactor;

  const GeometryState({
    this.rotationQuarterTurns = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.scaleFactor = 1.0,
  });

  GeometryState copyWith({
    int? rotationQuarterTurns,
    bool? flipHorizontal,
    bool? flipVertical,
    double? scaleFactor,
  }) {
    return GeometryState(
      rotationQuarterTurns: rotationQuarterTurns ?? this.rotationQuarterTurns,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      scaleFactor: scaleFactor ?? this.scaleFactor,
    );
  }

  GeometryState rotateRight() => copyWith(
    rotationQuarterTurns: (rotationQuarterTurns + 1) % 4,
  );

  GeometryState rotateLeft() => copyWith(
    rotationQuarterTurns: (rotationQuarterTurns + 3) % 4,
  );

  GeometryState toggleFlipHorizontal() => copyWith(
    flipHorizontal: !flipHorizontal,
  );

  GeometryState toggleFlipVertical() => copyWith(
    flipVertical: !flipVertical,
  );

  bool get isIdentity =>
    rotationQuarterTurns == 0 &&
    !flipHorizontal &&
    !flipVertical &&
    scaleFactor == 1.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeometryState &&
          runtimeType == other.runtimeType &&
          rotationQuarterTurns == other.rotationQuarterTurns &&
          flipHorizontal == other.flipHorizontal &&
          flipVertical == other.flipVertical &&
          scaleFactor == other.scaleFactor;

  @override
  int get hashCode =>
      rotationQuarterTurns.hashCode ^
      flipHorizontal.hashCode ^
      flipVertical.hashCode ^
      scaleFactor.hashCode;
}
