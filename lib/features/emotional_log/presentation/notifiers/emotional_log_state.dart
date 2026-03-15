/// Estados de creación de registro emocional manejados por [CreateLogNotifier].
sealed class CreateLogState {
  const CreateLogState();
}

class CreateLogInitial extends CreateLogState {
  const CreateLogInitial();
}

class CreateLogLoading extends CreateLogState {
  const CreateLogLoading();
}

class CreateLogSuccess extends CreateLogState {
  const CreateLogSuccess();
}

class CreateLogError extends CreateLogState {
  final String message;
  const CreateLogError(this.message);
}
