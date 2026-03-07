sealed class SaveContentState {
  const SaveContentState();
}

class SaveContentInitial extends SaveContentState {
  const SaveContentInitial();
}

class SaveContentLoading extends SaveContentState {
  const SaveContentLoading();
}

class SaveContentSuccess extends SaveContentState {
  const SaveContentSuccess();
}

class SaveContentError extends SaveContentState {
  final String message;
  const SaveContentError(this.message);
}
