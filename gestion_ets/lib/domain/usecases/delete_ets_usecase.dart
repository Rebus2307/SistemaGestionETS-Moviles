import '../repositories/ets_repository.dart';

class DeleteEtsUseCase {
  final EtsRepository repository;

  DeleteEtsUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteEts(id);
  }
}
