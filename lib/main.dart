import 'package:dynamic_multiform/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  GetIt.instance.registerSingleton<MainBloc>(MainBloc());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MainBloc _mainBloc = GetIt.instance<MainBloc>();

  int _counter;

  List<Widget> _formWidgets;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _counter = 0;
    _formWidgets = <Widget>[];
    _addForm();
  }

  void _addForm() {
    setState(() {
      _mainBloc.newForm();
      _formWidgets
          .add(_ParticipantFormWidget(ValueKey(_counter), _counter, _onDelete));
      _counter++;
    });
  }

  void _onDelete(int index) {
    setState(() {
      _formWidgets[index] = null;
      _mainBloc.removeForm(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _formWidgets.length,
                itemBuilder: (context, index) {
                  if (_formWidgets[index] != null) {
                    return _formWidgets[index];
                  }
                  return Container();
                },
              ),
            ),
          ),
          Container(
            child: StreamBuilder<bool>(
                stream: _mainBloc.allFieldsValidStreamedValue.stream,
                builder: (context, snapshot) {
                  var valid = snapshot.hasData && snapshot.data;
                  return FlatButton(
                    color: Colors.greenAccent,
                    disabledColor: Colors.grey,
                    onPressed: valid
                        ? (() {
                            _mainBloc.onSubmit();
                          })
                        : null,
                    child: Text(
                      'Submit'.toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addForm,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _ParticipantFormWidget extends StatefulWidget {
  final int index;
  final Function(int) onDelete;
  final Key key;
  _ParticipantFormWidget(this.key, this.index, this.onDelete);

  @override
  __ParticipantFormWidgetState createState() => __ParticipantFormWidgetState();
}

class __ParticipantFormWidgetState extends State<_ParticipantFormWidget> {
  final MainBloc _mainBloc = GetIt.instance<MainBloc>();

  final TextEditingController _nameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameTextController.text =
        _mainBloc.nameFieldStreamedList.value[widget.index].value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(3.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Form ${widget.index}'),
          SizedBox(height: 8.0),
          StreamBuilder<String>(
              stream:
                  _mainBloc.nameFieldStreamedList.value[widget.index].stream,
              builder: (context, snapshot) {
                return TextField(
                  controller: _nameTextController,
                  onChanged: (input) => _mainBloc
                      .nameFieldStreamedList.value[widget.index].value = input,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Full Name',
                    errorText: snapshot.error,
                  ),
                );
              }),
          SizedBox(height: 8.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'someone@example.com',
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              hintText: '08098999999',
            ),
          ),
          if (widget.index != 0)
            FlatButton(
              color: Colors.redAccent,
              onPressed: (() {
                widget.onDelete(widget.index);
              }),
              child: Text(
                'Delete'.toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
