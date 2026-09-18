class Anotacao {
  String data;
  String texto;

  Anotacao({
    required this.data,
    required this.texto,
  });

  Anotacao.fromCSV(String linha)
      : data = linha.split(';')[0],
        texto = linha.split(';')[1];

  String toCSV() {
    return '$data;$texto';
  }
}
