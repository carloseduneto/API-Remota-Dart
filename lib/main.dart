import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Future<List<Produto>> fetchProdutos() async {
  final response =
      await http.get(Uri.parse('https://arquivos.ectare.com.br/produtos.json'));

  if (response.statusCode == 200) {
    final decodedResponse = utf8.decode(response.bodyBytes);
    return (json.decode(decodedResponse) as List)
        .map((i) => Produto.fromJson(i))
        .toList();
  } else {
    throw Exception('Falha ao carregar os produtos');
  }
}

class Produto {
  final String nome;
  final String categoria;
  final double preco;
  final int estoque;

  Produto({
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.estoque,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      nome: json['nome'],
      categoria: json['categoria'],
      preco: json['preco'].toDouble(),
      estoque: json['estoque'],
    );
  }
}

const List<String> imagensProdutos = [
  'assets/notebook.webp',
  'assets/cadeira.webp',
  'assets/mesa.jpg',
  'assets/celular.webp',
  'assets/fone.png',
  'assets/geladeira.webp',
  'assets/livro.webp',
  'assets/tenis.webp',
  'assets/bolsa.jpg',
  'assets/cafeteira.png',
];

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Produto>> futureProdutos;
  final Map<String, bool> _categoriasExpandida = {};

  @override
  void initState() {
    super.initState();
    futureProdutos = fetchProdutos();
  }

  @override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Exemplo API - Produtos',
    home: Scaffold(
      appBar: AppBar(
        toolbarHeight: 120, 
        backgroundColor: Colors.white,
        title: Center(
          child: Image.asset(
            "assets/logo.png",
            width: 110, 
            height: 110, 
          ),
        ),
      ),



        backgroundColor: Colors.white,
        body: Center(
          child: FutureBuilder<List<Produto>>(
            future: futureProdutos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Nenhum produto encontrado.');
              } else {
                final produtosPorCategoria = _agruparPorCategoria(snapshot.data!);

                return ListView(
                  children: produtosPorCategoria.entries.map((entry) {
                    final categoria = entry.key;
                    final produtos = entry.value;
                    final icone = _iconePorCategoria(categoria);
                    final isExpanded = _categoriasExpandida[categoria] ?? false;

                    return ExpansionTile(
                      leading: Icon(
                        icone,
                        size: 30,
                        color: isExpanded ? Colors.green : Colors.black, 
                      ),
                      title: Text(
                        categoria,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isExpanded ? Colors.green : Colors.black, 
                        ),
                      ),
                      children: produtos.map((produto) {
                        final imagemIndex =
                            snapshot.data!.indexOf(produto) % imagensProdutos.length;
                        final imagemUrl = imagensProdutos[imagemIndex];

                        return ListTile(
                          leading: Image.asset(imagemUrl, width: 100, height: 100),
                          title: Text(produto.nome),
                          subtitle: Text(
                              'Preço: R\$${produto.preco.toStringAsFixed(2)}\nEstoque: ${produto.estoque}'),
                        );
                      }).toList(),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _categoriasExpandida[categoria] = expanded;
                        });
                      },
                      initiallyExpanded: _categoriasExpandida[categoria] ?? false,
                    );
                  }).toList(),
                );
              }
            },
          ),
        ),
      ),
    );
  }


  Map<String, List<Produto>> _agruparPorCategoria(List<Produto> produtos) {
    final Map<String, List<Produto>> produtosPorCategoria = {};

    for (var produto in produtos) {
      if (!produtosPorCategoria.containsKey(produto.categoria)) {
        produtosPorCategoria[produto.categoria] = [];
      }
      produtosPorCategoria[produto.categoria]!.add(produto);
    }

    return produtosPorCategoria;
  }


  IconData _iconePorCategoria(String categoria) {
    switch (categoria) {
      case 'Eletrônicos':
        return Icons.computer;
      case 'Móveis':
        return Icons.chair;
      case 'Acessórios':
        return Icons.watch;
      case 'Eletrodomésticos':
        return Icons.kitchen;
      case 'Literatura':
        return Icons.menu_book;
      case 'Calçados':
        return Icons.directions_run;
      default:
        return Icons.category;
    }
  }
}
