// Ignorar advertencias para preferir constructores constantes
// y literales constantes para listas

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp()); // Punto de entrada principal de la aplicación
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Proveedor para el estado de la aplicación
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Antonio Reyes',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor:
                const Color.fromARGB(255, 34, 71, 255), // Color principal azul
          ),
        ),
        home: MyHomePage(), // Página principal de la aplicación
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Par de palabras aleatorias actuales
  var history = <WordPair>[]; // Historial de palabras generadas

  GlobalKey?
      historyListKey; // Clave global para manejar la lista animada de historial

  void getNext() {
    history.insert(0, current); // Inserta la palabra actual en el historial
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList
        ?.insertItem(0); // Añade la palabra al inicio de la lista animada
    current = WordPair.random(); // Genera una nueva palabra
    notifyListeners(); // Notifica los cambios
  }

  var favorites = <WordPair>[]; // Lista de favoritos

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair); // Elimina de favoritos si ya está
    } else {
      favorites.add(pair); // Añade a favoritos si no está
    }
    notifyListeners(); // Notifica los cambios
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair); // Elimina un favorito específico
    notifyListeners(); // Notifica los cambios
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Índice de la pestaña seleccionada

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Página de generador
        break;
      case 1:
        page = FavoritesPage(); // Página de favoritos
        break;
      default:
        throw UnimplementedError(
            'no widget for $selectedIndex'); // Error si no hay widget
    }

    // Contenedor para la página actual, con fondo y animación de cambio sutil
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Layout para pantallas pequeñas con BottomNavigationBar
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home', // Etiqueta de "Inicio"
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites', // Etiqueta de "Favoritos"
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value; // Cambia el índice seleccionado
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            // Layout para pantallas grandes con NavigationRail
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite; // Icono de favorito lleno
    } else {
      icon = Icons.favorite_border; // Icono de favorito vacío
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: HistoryListView()), // Vista de historial
          SizedBox(height: 10),
          BigCard(pair: pair), // Tarjeta grande con el par de palabras
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // Cambia el estado de favorito
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // Genera una nueva palabra
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({Key? key, required this.pair}) : super(key: key);

  final WordPair pair; // Par de palabras para mostrar en la tarjeta

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, // Color del texto en la tarjeta
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          // Envuelve el texto para evitar desbordamiento en pantallas pequeñas
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(pair.first,
                    style: style.copyWith(fontWeight: FontWeight.w200)),
                Text(pair.second,
                    style: style.copyWith(fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
          child: Text('No favorites yet.')); // Mensaje cuando no hay favoritos
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
              'You have ${appState.favorites.length} favorites:'), // Texto de número de favoritos
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair); // Elimina de favoritos
                    },
                  ),
                  title: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey(); // Clave para lista animada del historial

  // Gradiente para atenuar el historial
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Color.fromARGB(0, 0, 0, 0), Color.fromARGB(255, 0, 0, 0)],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key, // Clave para controlar el estado de la lista animada
        reverse: true, // Anima la lista desde el final hacia el principio
        padding: EdgeInsets.only(
            top: 100), // Espacio en la parte superior de la lista
        initialItemCount: appState
            .history.length, // Número inicial de elementos en el historial
        itemBuilder: (context, index, animation) {
          final pair = appState.history[
              index]; // Obtener el par de palabras en la posición actual
          return SizeTransition(
            sizeFactor: animation, // Transición de tamaño animado
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(
                      pair); // Cambia el estado de favorito cuando se presiona
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite,
                        size: 12) // Icono de favorito si está en favoritos
                    : SizedBox(), // Si no está en favoritos, no muestra el icono
                label: Text(
                  pair.asLowerCase, // Texto con el par de palabras en minúsculas
                  semanticsLabel: pair
                      .asPascalCase, // Etiqueta semántica con el par de palabras en formato PascalCase
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
