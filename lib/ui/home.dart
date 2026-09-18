import '../root/file.dart';
import '../models/anotacao.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Anotacao> anotacoes = [];

  String texto = "";

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    String conteudo = await GerenciarArquivo.abrir();

    if (conteudo.isEmpty) {
      return;
    }

    List<String> linhas = conteudo.split('\n');

    setState(() {
      anotacoes = linhas
          .where((linha) => linha.trim().isNotEmpty)
          .map((linha) => Anotacao.fromCSV(linha))
          .toList();
    });
  }

  void salvarDados() {
    String conteudo = anotacoes
        .map((anotacao) => anotacao.toCSV())
        .join('\n');

    GerenciarArquivo.salvar(conteudo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anotações"),
        actions: [
          GestureDetector(
            onTap: cadastrar,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: const Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ListView.separated(
          itemBuilder: (context, i) => ListTile(
            title: Text(anotacoes[i].data),
            subtitle: Text(anotacoes[i].texto),
            trailing: GestureDetector(
              onTap: () => excluir(i),
              child: const Icon(Icons.delete),
            ),
          ),
          separatorBuilder: (_, _) => const Divider(),
          itemCount: anotacoes.length,
        ),
      ),
    );
  }

  void cadastrar() {
    texto = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova anotação"),
        content: TextField(
          decoration: const InputDecoration(
            hintText: "Digite sua anotação",
          ),
          onChanged: (value) {
            texto = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (texto.trim().isEmpty) {
                return;
              }

              Navigator.of(context).pop();

              String data =
                  DateTime.now().toString().substring(0, 16);

              setState(() {
                anotacoes.add(
                  Anotacao(
                    data: data,
                    texto: texto,
                  ),
                );
              });

              salvarDados();
            },
            child: const Text("Cadastrar"),
          ),
        ],
      ),
    );
  }

  void excluir(int indice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir anotação"),
        content: const Text(
          "Confirma a exclusão desta anotação?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              setState(() {
                anotacoes.removeAt(indice);
              });

              salvarDados();
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }
}