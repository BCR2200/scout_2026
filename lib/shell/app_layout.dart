import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rescout_2026/shell/qr_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../databasing/provider_service.dart';
import '../../databasing/scout_data.dart';
import 'shell_library.dart';
import 'package:rescout_2026/shell/TheEnd(game).dart';
import 'package:rescout_2026/shell/aura_tab.dart';
import 'package:rescout_2026/shell/tele.dart';

// ScoutApp is the root widget of the application.
class ScoutApp extends StatelessWidget {
  final bool scoutIndexChosen; // inputted from main() async{}
  final List<Widget> tabs;
  final List<Widget> pages;

  const ScoutApp({super.key, required this.scoutIndexChosen, required this.tabs, required this.pages});

  @override
  Widget build(BuildContext context) {

    // Setting the app to only be portrait, disallowing landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    // MultiProvider allows multiple providers to be used anywhere
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScoutProvider()),
        ChangeNotifierProvider(create: (context) => ColorProvider()..loadSettings()),
      ],
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false, // Get rid of debug banner
        title: 'ReScout 2026', // App name

        // Sets some of the design elements - only the font really matters here
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white70),
            useMaterial3: true,
            fontFamily: 'FunnelDisplay'
        ),
        home: scoutIndexChosen? ScoutHomePage(tabs: tabs, pages: pages,): SetupPage(tabs: tabs, pages: pages), // Checking to send user to setup or home page
      )
    );
  } // Widget build
} // ScoutApp

// ScoutHomePage is the homepage with all the tabs
class ScoutHomePage extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> pages;

  const ScoutHomePage({super.key, required this.tabs, required this.pages});

  @override
  State<ScoutHomePage> createState() => _ScoutHomePageState();
}
class _ScoutHomePageState extends State<ScoutHomePage> with TickerProviderStateMixin{
  late final TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // This key determines whether or not to open the side bar

  // Setting default values
  int scoutIndex = 0;
  bool blueAlliance = true;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this); // Setting up the tab controller
    _loadScoutIndex(); // Load in which tablet it is
  }

  // This runs once when the widget is no longer in use
  @override
  void dispose() {
    _tabController.dispose(); // Getting rid of the controller when it is no longer used
    super.dispose();
  }

  // Function that sets the scout index and colour to based on selections in the setup page
  Future<void> _loadScoutIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Getting an instance of the SharedPreferences

    // Checking mounted so this only runs when the widget is built
    if (mounted) {
      setState(() { // Set state rebuilds the widget with the new info given from scout index
        scoutIndex = prefs.getInt('scoutIndex')!;
        scoutIndex % 2 == 0 ? blueAlliance = false : blueAlliance = true; // Determining alliance
      });
      await prefs.setBool('is_blue', blueAlliance);
    }
  } // _loadScoutIndex

  // Building the home page widget tree
  @override
  Widget build(BuildContext context) {

    List<Widget> pageList = widget.pages + [QRPage(callback: () => setState(() => _tabController.index = 0),)];

    // Setting the colours based on the tablet
    Color? colourOfTeam = blueAlliance ? Colors.blue[100] : Colors.red[100];
    Color? colourOfTeamSaturated = blueAlliance ? Colors.blue[50] : Colors.red[50];

    // Start of this widget tree. DefaultTabController is to set the 4 tabs
    return Scaffold(
      key: _scaffoldKey, // Used to determine whether or not to "open drawer"
      resizeToAvoidBottomInset: false, // Prevent keyboard pop-up squishing widgets

      // Create the top row with menu, match & team selections, and tabs
      appBar: AppBar(
        backgroundColor: colourOfTeam, // Setting the background colour

        // Setting the dimensions
        titleSpacing: 0,
        leadingWidth: 45.0,
        toolbarHeight: 80.0,

        // Creating the menu button
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(Icons.menu, size: 30,),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(), // When pressed, it will open the drawer (menu)
        ),

        // Creating a row of widgets (match and team)
        title: Row(
          children: <Widget>[

            // Putting a const divider to add some space
            VerticalDivider(),

            // Wrapping MatchSelector with expanded to fill up maximum space
            Expanded(
              child: MatchSelector(), // This custom widget is in shell_library
            ),

            // Putting a const divider to add some space
            const VerticalDivider(
            ),

            TeamSelector(), // This custom widget is in shell_library
          ],
        ),
        bottom: TabBar(
          controller: _tabController, // Setting the tab controller
          indicatorWeight: 0.01, // Indicator is required but is unwanted so it's set to the minimum
          indicatorColor: colourOfTeam,
          isScrollable: false, // There aren't too many tabs so scrollable is unnecessary
          indicatorPadding: EdgeInsets.all(0), // Makes the tabs squished together by making their spacing 0
          labelPadding: EdgeInsets.all(0),
          tabs: widget.tabs, // Getting the tab designs from the contructor
        ),
      ),

      // Creating the body/pages of each tab
      body: TabBarView(
        controller: _tabController, // Setting the controller
        children: pageList, // Getting the pages from the constructor
      ),

      drawer: SettingsWidget(
        scoutIndex: scoutIndex, // Indicating which tablet it is
        backgroundColour: colourOfTeamSaturated, // Setting the colour based on the tablet
      ),

      drawerEnableOpenDragGesture: false, // Prevent swiping from opening the menu since swiping changes tabs

      // This button make the fouls pop-up when pressed
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colourOfTeam,
        onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(

                // Setting the visual appearance
                backgroundColor: colourOfTeam,
                contentPadding: const EdgeInsets.all(35.0),
                content: NumberInputWidget(
                  column: 'fouls', // Setting the column for the database
                  scale: 1.25,
                  title: 'Fouls',
                  fontSize: 30.0,
                  fillColor: colourOfTeamSaturated,
                ),
              );
            } // builder
        ), // onPressed
        label: const BoldText(text: 'Fouls', fontSize: 20), // Button label
      ),
    );
  } // Widget build
} // _ScoutHomePageState

// SetupPage opens only once, upon initial installation, to determine tablet
class SetupPage extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> pages;

  const SetupPage({super.key, required this.tabs, required this.pages}); // Constructor

  // Creating and naming the "state" to tell the widget when to update
  @override
  State<SetupPage> createState() => _SetupPageState();
} // SetupPage
class _SetupPageState extends State<SetupPage> {

  // Declaring variables
  bool _isLoading = false;
  int _scoutIndex = 0;

  // This list is all the options for selecting the tablet
  final List<String> _tabletOptions = [
    'Red Left',
    'Blue Left',
    'Red Middle',
    'Blue Middle',
    'Red Right',
    'Blue Right',
  ];

  // This method does as it says... it adds an empty match (to prevent errors)
  // It also checks if it has been run, so it only adds it once
  Future<void> _addEmptyMatch() async{

    // Getting instance of preferences to see whether or not it added it
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasRun = prefs.getBool('hasRun') ?? false;
    if (!hasRun) {
      ScoutDatabase.addEmptyMatch();
      await prefs.setBool('hasRun', true);
    }
  }

  // This method is what assigns the tablet
  Future<void> _scoutSelection(int value) async {

    // Update widget to show it's loading so it submits the right value
    setState(() {
      _isLoading = true;
    });

    // Set the value, and also let the app know it has been chosen
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scoutIndex', value);
    await prefs.setBool('scoutIndexChosen', true);

    // Set it to no longer loading
    setState(() {
      _isLoading = false;
    });

    // Routes the user to the home page of the app instead of this page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ScoutHomePage(tabs: widget.tabs, pages: widget.pages,))
    );
  } // _scoutSelection

  // This runs once, when it initializes the widget
  @override
  void initState() {
    super.initState();
    _addEmptyMatch(); // method outlined earlier
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Title area
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 20), // Spacing to the left and above the title (default will shove it in the corner)
          child: BoldText(text: 'Which Tablet Is This?', fontSize: 40),
        ),
      ),

      // Creating the body of the selection area, with some spacing at the edges
      body: Padding(
        padding: const EdgeInsets.all(20.0),

        // Creating a 2X3 grid of options
        child: GridView.count(
          crossAxisCount: 2,

          // Ensuring you can't scroll the grid
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          // Creating the 6 options with a generated list from _items
          children: List.generate(_tabletOptions.length, (index){

            // Check which option is tapped and updating the visuals
            return GestureDetector(
              onTap: () {
                setState(() {
                  _scoutIndex = index; // Set the index to the tapped tile
                });
              },
              child: Card(

                // Setting the visual appearance (whether or not selected)
                margin: const EdgeInsets.all(8.0),
                color: _scoutIndex == index? Colors.grey[400]: Colors.grey[200],
                child: Center(
                  child: BoldText(
                    text:_tabletOptions[index], // Each tile will display what the option is (BLUE/RED, L/M/R)
                    fontSize: 20.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ),
      ),

      // Button to submit the tablet (bottom right corner)
      floatingActionButton: FloatingActionButton.large(

        // When pressed, it will submit. If it is loading, it can't be pressed
        onPressed: (){
          _isLoading? null: _scoutSelection(_scoutIndex);
        },

        // Shows loading if it is loading, and submit if it isn't
        child: _isLoading? const CircularProgressIndicator(color: Colors.white,): const BoldText(text: 'Submit', fontSize: 25),
      ),
    );
  } // Widget build
} // _SetupPageState
