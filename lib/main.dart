import 'package:auto_size_text/auto_size_text.dart';
import 'package:calculator/deque.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const EdgeInsets _buttonPadding = EdgeInsets.all(6);
  static const double _buttonHeight = 100;
  static const double _buttonWidth = 100;
  static const Color _lightGrey = Color(0xFFDDDDDD);
  static const Color _darkGrey = Color(0xFF555555);

  double _register = 0;
  String _display = "0";
  CalculateOperator _currentMode = CalculateOperator.complete;
  final Deque _displayNumberDeque = Deque();

  @override
  void initState() {
    super.initState();
    _initializeDeque();
  }

  void _initializeDeque(){
    _displayNumberDeque.popAll();
    _displayNumberDeque.addRight("0");
  }

  void _calculate(CalculateOperator op){
    String condition = _displayNumberDeque.toString();
    if(condition.isEmpty || condition == "-"){
      debugPrint("연산하면 안되는 경우");
      return;
    }

    if(_currentMode == CalculateOperator.complete){
      if(op == CalculateOperator.complete) { return; }

      setState(() {
        _register = double.parse(_displayNumberDeque.toString());
        _display = "0";
      });
      _currentMode = op;
      _initializeDeque();
      return;
    }

    double result = 0;
    double displaying = double.parse(_displayNumberDeque.toString());
    switch(_currentMode){
      case CalculateOperator.add:
        result = _register + displaying;
        break;
      case CalculateOperator.subtract:
        result = _register - displaying;
        break;
      case CalculateOperator.multiply:
        result = _register * displaying;
        break;
      case CalculateOperator.divide:
        if(displaying == 0){
          _alertToast("0으로 나눌 수 없습니다!!");
          return;
        }
        result = _register / displaying;
        break;
      case CalculateOperator.modular:
        if(displaying == 0){
          _alertToast("0으로 나눌 수 없습니다!!");
          return;
        }
        result = _register % displaying;
        break;
      default:
        debugPrint("씨발 무슨 일이 일어난거야");
        break;
    }

    if(op == CalculateOperator.complete){
      _initializeDeque();
      setState(() {
        _register = 0;
        _display = doubleFormatting(result);
      });

      List<String> arr = _display.split("");
      _displayNumberDeque.popRight(); // 이거 안해주면 0이 들어간 상태로 결괏값이 덱에 들어가는 참사가 벌어짐
      for(final c in arr){
        _displayNumberDeque.addRight(c);
      }
    }
    else{
      _initializeDeque();
      setState(() {
        _register = result;
        _display = "0";
      });
    }

    _currentMode = op;

    return;
  }

  String _registerToFormattedString(){
    return doubleFormatting(_register);
  }

  String doubleFormatting(double value){
    if(value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

  void _addNumberIntoDisplayList(String number){
    if(_displayNumberDeque.toString() == "0") { _displayNumberDeque.popRight(); }
    _displayNumberDeque.addRight(number);
    setState(() {
      _display = _displayNumberDeque.toString();
    });
  }

  void _alertToast(String message){
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      fontSize: 24
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단여백
          Container(
            decoration: const BoxDecoration(
              color: Colors.black
            ),
            height: 50,
          ),
          // 상단여백

          // 숫자 디스플레이
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black
              ),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 레지스터에 저장된 숫자
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12
                    ),
                    child: AutoSizeText(
                      _registerToFormattedString(),
                      maxLines: 1,
                      minFontSize: 8,
                      style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white
                      ),
                    ),
                  ),
                  // 레지스터에 저장된 숫자

                  // 입력한 숫자 디스플레이
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AutoSizeText(
                      _display,
                      maxLines: 1,
                      minFontSize: 12,
                      style: const TextStyle(
                        fontSize: 108,
                        color: Colors.white
                      ),
                    ),
                  ),
                  // 입력한 숫자 디스플레이
                ],
              ),
            ),
          ),
          // 숫자 디스플레이

          // 숫자판
          Container(
            decoration: const BoxDecoration(
              color: Colors.black
            ),
            height: 600,
            child: Column(
              children: [
                // AC, +/-, %, 나눗셈 연산버튼
                Row(
                  children: [
                    _buildAllClearButton(),
                    _buildNPConversionButton(),
                    _buildModularButton(),
                    _buildDivisionButton(),
                  ],
                ),
                // AC, +/-, %, 나눗셈 연산버튼

                // 1, 2, 3, 곱셈버튼
                Row(
                  children: [
                    _buildNumberButton("1"),
                    _buildNumberButton("2"),
                    _buildNumberButton("3"),
                    _buildMultiplicationButton(),
                  ],
                ),
                // 1, 2, 3, 곱셈버튼

                // 4, 5, 6, 뺄셈버튼
                Row(
                  children: [
                    _buildNumberButton("4"),
                    _buildNumberButton("5"),
                    _buildNumberButton("6"),
                    _buildSubtractionButton(),
                  ],
                ),
                // 4, 5, 6, 뺄셈버튼

                // 7, 8, 9, 덧셈버튼
                Row(
                  children: [
                    _buildNumberButton("7"),
                    _buildNumberButton("8"),
                    _buildNumberButton("9"),
                    _buildAdditionButton(),
                  ],
                ),
                // 7, 8, 9, 덧셈버튼

                // 하나지우기, 0, 소숫점, 결과 버튼
                Row(
                  children: [
                    _buildBackspaceButton(),
                    _buildZeroButton(),
                    _buildDecimalPointButton(),
                    _buildResultButton(),
                  ],
                ),
                // 하나지우기, 0, 소숫점, 결과 버튼
              ],
            ),
          ),
          // 숫자판

          // 하단여백
          Container(
            decoration: const BoxDecoration(
                color: Colors.black
            ),
            height: 10,
          ),
          // 하단여백
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint(number);
            _addNumberIntoDisplayList(number);
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _darkGrey
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZeroButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("0");
            String condition = _displayNumberDeque.toString();
            if(condition == "0") { return; }
            _displayNumberDeque.addRight("0");
            setState(() {
              _display = _displayNumberDeque.toString();
            });
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _darkGrey
            ),
            child: const Center(
              child: Text(
                "0",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllClearButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("AC");
            _currentMode = CalculateOperator.complete;
            _initializeDeque();
            setState(() {
              _display = "0";
              _register = 0;
            });
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _lightGrey
            ),
            child: const Center(
              child: Text(
                "AC",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNPConversionButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("+/-");
            String displaying = _displayNumberDeque.toString();
            if(displaying == "0") { return; }

            if(_displayNumberDeque.getLeft() == "-"){
              _displayNumberDeque.popLeft();
            }
            else{
              _displayNumberDeque.addLeft("-");
            }

            setState(() {
              _display = _displayNumberDeque.toString();
            });
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _lightGrey,
            ),
            child: const Center(
              child: Text(
                "+/-",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModularButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("%");
            _calculate(CalculateOperator.modular);
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _lightGrey,
            ),
            child: const Center(
              child: Text(
                "%",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivisionButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("divide");
            _calculate(CalculateOperator.divide);
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orangeAccent,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.divide,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplicationButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("multiply");
            _calculate(CalculateOperator.multiply);
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orangeAccent,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.xmark,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtractionButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("subtract");

            String condition = _displayNumberDeque.toString();
            if(condition == "0"){
              debugPrint("-만 붙임 ㅇ");
              _displayNumberDeque.addLeft("-");
              _displayNumberDeque.popRight();
              setState(() {
                _display = "${_displayNumberDeque}0";
              });
              return;
            }
            if(_displayNumberDeque.getLeft() == "-" && _displayNumberDeque.getRight() == "-"){
              debugPrint("현재 덱 상태: ${_displayNumberDeque.toString()}");
              return;
            }

            _calculate(CalculateOperator.subtract);
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orangeAccent,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.minus,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("add");
            _calculate(CalculateOperator.add);
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orangeAccent,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.plus,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("result");
            _calculate(CalculateOperator.complete);
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orangeAccent,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.equals,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("backspace");
            _displayNumberDeque.popRight();
            String condition = _displayNumberDeque.toString();
            debugPrint(condition);
            if(condition == "-" || condition == "0") {
              _displayNumberDeque.popLeft();
              condition = _displayNumberDeque.toString();
            }
            setState(() {
              _display = condition.isEmpty ? "0" : condition;
            });
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _darkGrey
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.arrowLeftLong,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecimalPointButton(){
    return Expanded(
      child: Padding(
        padding: _buttonPadding,
        child: InkWell(
          onTapUp: (e) {
            debugPrint("decimal point");
            String condition = _displayNumberDeque.toString();
            if(condition.isEmpty || condition == "-") { _displayNumberDeque.addRight("0"); }
            if(_displayNumberDeque.getRight() == ".") { return; }
            _displayNumberDeque.addRight(".");
            setState(() {
              _display = _displayNumberDeque.toString();
            });
          },
          child: Container(
            height: _buttonHeight,
            width: _buttonWidth,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _darkGrey
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.solidCircle,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum CalculateOperator{
  add,
  subtract,
  multiply,
  divide,
  modular,
  complete,
}
