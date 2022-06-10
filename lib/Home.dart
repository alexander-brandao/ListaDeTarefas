import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas =  [];
  TextEditingController _controllerTarefa = TextEditingController();
  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  Future<File> _getFile() async{

    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa(){

    String textoDigitado = _controllerTarefa.text;
    //criar dados
    Map<String, dynamic> tarefa = Map();
    tarefa['titulo'] = textoDigitado;
    tarefa['realizada'] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  _salvarArquivo() async{

    var arquivo = await _getFile();
    String dados = json.encode( _listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerAquivo() async{

    try{
      final arquivo = await _getFile();
      return arquivo.readAsString();
    }catch(e){
      return null;
    }
  }

  @override
  void initState(){

    super.initState();
    _lerAquivo().then( (dados){
              setState(() {
                _listaTarefas = json.decode(dados);
              });
    });
  }

  Widget _criarItemLista(context, index){


    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){

          //recupera ultimo item excluido
          _ultimaTarefaRemovida = _listaTarefas[index];


          //remover item da lista
          _listaTarefas.removeAt(index);
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
            content: Text("Tarefa removida!"),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                  //insere novamente o item excluido na lista
                  setState(() {
                    _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  });
                  _salvarArquivo();
              },
            ),
          );

          Scaffold.of(context).showSnackBar(snackbar);


        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text(_listaTarefas[index]['titulo']),
          value: _listaTarefas[index]['realizada'],
          onChanged: (valorAlterado){
            setState(() {
              _listaTarefas[index]['realizada'] = valorAlterado;
            });
            _salvarArquivo();
          },
        ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                        labelText: "Digite sua tarefa"
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text("Salvar"),
                    )
                  ],
                );
              }
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),

      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                itemBuilder: _criarItemLista,
              ),
          )
        ],
      ),
    );
  }
}
