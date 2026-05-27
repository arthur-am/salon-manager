class Cliente {
  const Cliente({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  final int id;
  final String nome;
  final String email;
  final String telefone;
}

class ClienteDraft {
  const ClienteDraft({
    required this.nome,
    required this.email,
    required this.telefone,
  });

  final String nome;
  final String email;
  final String telefone;
}
