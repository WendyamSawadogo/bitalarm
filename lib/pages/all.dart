import 'package:flutter/material.dart';
import '../helpers/services.dart';
import '../components/bottom_nav.dart';
import '../components/currency_card.dart';
import '../components/all_drawer.dart';

class AllCurrenciesPage extends StatefulWidget {
  AllCurrenciesPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AllCurrenciesState createState() => new _AllCurrenciesState();
}

class _AllCurrenciesState extends State<AllCurrenciesPage> with SingleTickerProviderStateMixin {

  List<String> _watchlist = [];
  List<Object> _coins = [];
  List<Card> _list = [];
  WatchlistProvider wp = new WatchlistProvider();
  
  getList() async {
    _watchlist = await wp.getWatchlist();
    _coins = await API.getPrices();
    setState((){});
  }

  void sortList(SortOrder order) {
    setState((){
      if (order == SortOrder.losing || order == SortOrder.trending) {
        _coins.sort((Object a, Object b) {
          double aChange = double.parse(a['percent_change_24h']);
          double bChange = double.parse(b['percent_change_24h']);
          return aChange < bChange ? 1 : -1;
        });
      } else if (order == SortOrder.marketCap) {
        _coins.sort((Object a, Object b) {
          double aCap = double.parse(a['market_cap_usd']);
          double bCap = double.parse(b['market_cap_usd']);
          return aCap < bCap ? 1 : -1;
        });
      }
    });
  }

  bool inWatchlist(String ticker) => _watchlist.indexOf(ticker) >= 0;
  IconButton addToWatchlistButton (String ticker) {
    return new IconButton(
      icon: const Icon(Icons.favorite_border, color: Colors.grey),
      padding: const EdgeInsets.all(0.0),
      onPressed: () async {
        wp.addToWatchlist(ticker);
        setState(() {
          _watchlist.add(ticker);
          debugPrint("Adding: " + _watchlist.toString());
        });
      }
    );
  }
  IconButton removeFromWatchlistButton(String ticker) {
    return new IconButton(
      icon: const Icon(Icons.favorite, color: Colors.red),
      padding: const EdgeInsets.all(0.0),
      onPressed: () async {
        wp.removeFromWatchlist(ticker);
        setState(() {
          _watchlist.remove(ticker);
          debugPrint("Removing: " + _watchlist.toString());
        });
      }
    );
  }

  @override
  void initState() {
    super.initState();
    getList();
  }
  
  @override
  Widget build(BuildContext ctx) {
    _list = new List.generate(_coins.length, (int index) {
      Object coin = _coins[index];
      double change = double.parse(coin['percent_change_24h']);
      double price = double.parse(coin['price_usd']);
      String ticker = coin['symbol'];
      String name = coin['name'];
      return new Card(
        child: new Container(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: new Column(children: <Widget>[
            currencyCardTitle(name, price),
            currencyCardDetails(ticker, change),
            new Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: new Row(children: [
                inWatchlist(ticker) ?
                  removeFromWatchlistButton(ticker) :
                  addToWatchlistButton(ticker),
                new IconButton(
                  icon: const Icon(Icons.timeline),
                  onPressed: () {
                    debugPrint('Details for $ticker');
                  }
                )
              ]),
            )
          ])
        )
      );
    });
    return new Scaffold(
      bottomNavigationBar: bottomNav(ctx, 1),
      drawer: allDrawer((SortOrder order) {
        debugPrint(order.toString());
      }),
      body: new RefreshIndicator(
        onRefresh: getList,
        child: new ListView(
          children: _list,
        ),
      )
    );
  }
}
