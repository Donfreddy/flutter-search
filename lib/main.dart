import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Search demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> kEnglishWords;

  _MySearchDelegate _delegate;

  _MyHomePageState()
      : kEnglishWords = List.from(Set.from(all))
          ..sort((w1, w2) => w1.toLowerCase().compareTo((w2.toLowerCase()))),
        super();

  @override
  void initState() {
    super.initState();
    _delegate = _MySearchDelegate(kEnglishWords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("English Word"),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              tooltip: 'Voice Search',
              icon: Icon(Icons.search),
              onPressed: () async {
                final String selected = await showSearch<String>(
                    context: context, delegate: _delegate);
                if (selected != null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('You have selected the word: $selected'),
                  ));
                }
              },
            )
          ],
        ),
        body: Scrollbar(
          child: ListView.builder(
            itemCount: kEnglishWords.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(kEnglishWords[index]),
              );
            },
          ),
        ));
  }
}

// Defines the content of the search page in `ShowSearch()`.
// SearchDelegate has a member `query` which is the query string.
class _MySearchDelegate extends SearchDelegate<String> {
  final List<String> _words;
  final List<String> _history;

  _MySearchDelegate(List<String> words)
      : _words = words,
        _history = <String>["a", "b", "c"],
        super();

  // Leading icon in search bar.
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        //SearchDelegate.close() can return values, similar to Navigator.pop()
        this.close(context, null);
      },
    );
  }

  // Widget of result page.
  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have selected the word: '),
            GestureDetector(
              child: Text(
                this.query,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                this.close(context, this.query);
              },
            )
          ],
        ),
      ),
    );
  }

  // Suggestions list while typing (this.query)
  @override
  Widget buildSuggestions(BuildContext context) {
    final Iterable<String> suggestions = this.query.isEmpty
        ? _history
        : _words.where((word) => word.startsWith(query));

    return SuggestionList(
      suggestions: suggestions.toList(),
      query: this.query,
      onSelected: (String suggestion) {
        this.query = suggestion;
        this._history.insert(0, suggestion);
        showResults(context);
      },
    );
  }

  // Action buttons at the right of search bar.
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Voice Search',
              icon: Icon(Icons.mic),
              onPressed: () {
                this.query = 'TODO: implement voice input';
              },
            )
          : IconButton(
              tooltip: 'Clear',
              icon: Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ];
  }
}

// Suggestions list widget displayed in the search page.
class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  const SuggestionList({this.suggestions, this.query, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (BuildContext context, index) {
          final String suggestion = suggestions[index];
          return ListTile(
            leading: query.isEmpty ? Icon(Icons.history) : Icon(null),
            // Highlight the substring that matched the query
            title: RichText(
              text: TextSpan(
                  text: suggestion.substring(0, query.length),
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: suggestion.substring(query.length),
                    )
                  ]),
            ),
            onTap: () {
              onSelected(suggestion);
            },
          );
        });
  }
}
