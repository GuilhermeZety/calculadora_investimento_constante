import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const TextStyle _bigText = TextStyle(
  color: Color(0xFF222222),
  fontSize: 30,
  fontWeight: FontWeight.w700
);

String formatPrice(double value) {
 var price = value.toString();

  final oCcy = NumberFormat("###,##0.00", "pt_BR");
  price = 'R\$${oCcy.format(double.tryParse(price) ?? 0)}';

  return price;
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}

List<_SalesData> valorComJuros = [];
List<_SalesData> valorSemJuros = [];

class _MyHomePageState extends State<MyHomePage> {
  double finalValue = 0;

  final _formKey = GlobalKey<FormState>();  
  final yearsController = TextEditingController();
  final feesController = TextEditingController();
  final amountController = TextEditingController();

  void _calcValue() {
    setState(() {
      valorComJuros = [];
      valorSemJuros = [];
    });

    int years = int.parse(yearsController.text);
    double fees = double.parse(feesController.text);
    int amount = int.parse(amountController.text);

    double resultado = 0;
    double sJuros = 0;

    //fazendo uma repetição com o tanto de anos
    for(var i = 0; i < years; i++){
      //fazendo uma repetição com o montante de meses no ano
      for(var j = 0; j < 12; j++){
        double juros = 0;
        if(resultado != 0){
          juros = (resultado / 100) * (fees / 12);
        }
        setState(() {
          resultado += amount + juros;
          sJuros += amount;
        });
      }
      setState(() {
        valorComJuros.add(_SalesData('${i + 1}', resultado));
        valorSemJuros.add(_SalesData('${i + 1}', sJuros));
      });
    }

    setState(() {
      finalValue = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
              maxWidth: 800,
            ),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(            
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Initialize the chart widget
              Container(
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(text: formatPrice(finalValue), textStyle: _bigText),
                    // Enable legend
                    legend: Legend(isVisible: true),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<_SalesData, String>>[
                      LineSeries<_SalesData, String>(
                        dataSource: valorComJuros,
                        xValueMapper: (_SalesData sales, _) => sales.year,
                        yValueMapper: (_SalesData sales, _) => sales.sales,
                        name: 'Valor final',
                        // Enable data label
                        dataLabelSettings: const DataLabelSettings(isVisible: false)
                      ),
                      LineSeries<_SalesData, String>(
                        dataSource: valorSemJuros,
                        xValueMapper: (_SalesData sales, _) => sales.year,
                        yValueMapper: (_SalesData sales, _) => sales.sales,
                        name: 'Valor investido',
                        // Enable data label
                        dataLabelSettings: const DataLabelSettings(isVisible: false)
                      )
                    ]
                    ),
              ),
              //////////////////////////////
              
              Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: Form(
                    key: _formKey,  
                    child: Column(
                      children: [
                        TextFormField(
                          controller: yearsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(  
                            icon: Icon(Icons.calendar_month),  
                            hintText: '10',  
                            labelText: 'Quantidade de anos',  
                          ),  
                        ),
                        TextFormField(
                          controller: feesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(  
                            icon: Icon(Icons.percent),  
                            hintText: '12.5',  
                            labelText: 'Juros',  
                          ),  
                        ),
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(  
                            icon: const Icon(Icons.monetization_on),  
                            hintText: formatPrice(500.0),  
                            labelText: 'Montante fixo mensal',  
                          ),  
                        ),
                        const SizedBox(height: 20,),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            elevation: MaterialStateProperty.all(5),
                            minimumSize: MaterialStateProperty.all(Size(200, 50))
                          ),
                          onPressed: _calcValue,
                          child: const Text('Calcular', style: TextStyle(color: Colors.white, fontSize: 18),)
                        )
                      ],
                    )                                
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'submit',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
