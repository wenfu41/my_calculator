import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CalculatorHome(),
    );
  }
}

// 进制模式枚举
enum NumberBase {
  decimal, // 十进制
  binary, // 二进制
  octal, // 八进制
  hexadecimal, // 十六进制
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _output = "0";
  String _expression = ""; // 显示计算表达式
  double _num1 = 0;
  double _num2 = 0;
  String _operand = "";
  bool _isNewNumber = true; // 标记是否开始输入新数字
  NumberBase _currentBase = NumberBase.decimal; // 当前进制模式

  // 进制转换：从指定进制的字符串转换为十进制整数
  int _parseFromBase(String value, NumberBase base) {
    if (value.isEmpty || value == "0") return 0;
    try {
      switch (base) {
        case NumberBase.decimal:
          return int.parse(value);
        case NumberBase.binary:
          return int.parse(value, radix: 2);
        case NumberBase.octal:
          return int.parse(value, radix: 8);
        case NumberBase.hexadecimal:
          return int.parse(value, radix: 16);
      }
    } catch (e) {
      return 0;
    }
  }

  // 进制转换：从十进制整数转换为指定进制的字符串
  String _formatToBase(int value, NumberBase base) {
    if (value < 0) {
      // 处理负数：使用补码表示（32位）
      value = value & 0xFFFFFFFF;
    }
    switch (base) {
      case NumberBase.decimal:
        return value.toString();
      case NumberBase.binary:
        return value.toRadixString(2);
      case NumberBase.octal:
        return value.toRadixString(8);
      case NumberBase.hexadecimal:
        return value.toRadixString(16).toUpperCase();
    }
  }

  // 获取当前进制的名称
  String _getBaseName(NumberBase base) {
    switch (base) {
      case NumberBase.decimal:
        return "DEC";
      case NumberBase.binary:
        return "BIN";
      case NumberBase.octal:
        return "OCT";
      case NumberBase.hexadecimal:
        return "HEX";
    }
  }

  // 检查按钮在当前进制下是否可用
  bool _isButtonEnabled(String buttonText) {
    if (_currentBase == NumberBase.decimal) return true;

    // 数字按钮的启用规则
    if (RegExp(r'^[0-9]$').hasMatch(buttonText) || buttonText == "00") {
      int maxDigit = 0;
      switch (_currentBase) {
        case NumberBase.binary:
          maxDigit = 1;
          break;
        case NumberBase.octal:
          maxDigit = 7;
          break;
        case NumberBase.hexadecimal:
          maxDigit = 9;
          break;
        default:
          return true;
      }

      if (buttonText == "00") return int.parse("0") <= maxDigit;
      int digit = int.parse(buttonText);
      return digit <= maxDigit;
    }

    // 十六进制字母按钮
    if (RegExp(r'^[A-F]$').hasMatch(buttonText)) {
      return _currentBase == NumberBase.hexadecimal;
    }

    // 小数点和百分号仅在十进制下可用
    if (buttonText == "." || buttonText == "%") {
      return _currentBase == NumberBase.decimal;
    }

    return true;
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _clearAll();
      } else if (buttonText == "DEL") {
        _deleteDigit();
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "/" ||
          buttonText == "*") {
        _handleOperator(buttonText);
      } else if (buttonText == "%") {
        _handlePercentage();
      } else if (buttonText == ".") {
        _handleDecimal();
      } else if (buttonText == "=") {
        _calculateResult();
      } else {
        _handleNumber(buttonText);
      }
    });
  }

  // 切换进制模式
  void _switchBase(NumberBase newBase) {
    setState(() {
      if (_currentBase == newBase) return;

      // 将当前显示的数字从当前进制转换为新进制
      if (_output != "Error" && _output != "0") {
        // 如果是小数，只在十进制模式下有效
        if (_output.contains(".")) {
          if (newBase != NumberBase.decimal) {
            // 转换为整数
            int intValue = double.parse(_output).toInt();
            _output = _formatToBase(intValue, newBase);
          }
        } else {
          // 整数转换
          int currentValue = _parseFromBase(_output, _currentBase);
          _output = _formatToBase(currentValue, newBase);
        }
      }

      _currentBase = newBase;
      _expression = ""; // 切换进制时清空表达式
    });
  }

  void _clearAll() {
    _num1 = 0;
    _num2 = 0;
    _operand = "";
    _output = "0";
    _expression = "";
    _isNewNumber = true;
  }

  void _deleteDigit() {
    if (_output == "Error") return;
    if (_output.length > 1) {
      _output = _output.substring(0, _output.length - 1);
    } else {
      _output = "0";
      _isNewNumber = true;
    }
  }

  void _handleOperator(String newOperand) {
    if (_output == "Error") return;

    // 在非十进制模式下，将当前输入转换为十进制进行存储
    if (_currentBase != NumberBase.decimal) {
      int currentValue = _parseFromBase(_output, _currentBase);
      _num1 = currentValue.toDouble();
    } else {
      _num1 = double.parse(_output);
    }

    if (_operand.isNotEmpty && !_isNewNumber) {
      // 如果已经有运算符且输入了新数字，先计算之前的步骤
      _calculateIntermediate();
      _expression = "$_output $newOperand";
    } else {
      _expression = "$_output $newOperand";
    }
    _operand = newOperand;
    _isNewNumber = true;
  }

  void _calculateIntermediate() {
    if (_currentBase != NumberBase.decimal) {
      int currentValue = _parseFromBase(_output, _currentBase);
      _num2 = currentValue.toDouble();
    } else {
      _num2 = double.parse(_output);
    }
    _performCalculation();
    _num1 = double.parse(_output); // 将结果作为下一次运算的第一个数
    _operand = ""; // 暂时清空，等待新的运算符被设置
  }

  void _handlePercentage() {
    if (_output == "Error" || _currentBase != NumberBase.decimal) return;
    double current = double.parse(_output);
    _output = (current / 100).toString();
    _removeDecimalZero();
    _isNewNumber = true;
  }

  void _handleDecimal() {
    if (_output == "Error" || _currentBase != NumberBase.decimal) return;
    if (_isNewNumber) {
      _output = "0.";
      _isNewNumber = false;
    } else if (!_output.contains(".")) {
      _output = _output + ".";
    }
  }

  void _calculateResult() {
    if (_operand.isEmpty || _output == "Error") return;
    _expression = "$_expression $_output =";

    if (_currentBase != NumberBase.decimal) {
      int currentValue = _parseFromBase(_output, _currentBase);
      _num2 = currentValue.toDouble();
    } else {
      _num2 = double.parse(_output);
    }

    _performCalculation();
    _operand = ""; // 计算完成，清除运算符
    _isNewNumber = true; // 准备好开始新的计算或覆盖结果
  }

  void _performCalculation() {
    double result = 0;
    if (_operand == "+") {
      result = _num1 + _num2;
    } else if (_operand == "-") {
      result = _num1 - _num2;
    } else if (_operand == "*") {
      result = _num1 * _num2;
    } else if (_operand == "/") {
      if (_num2 == 0) {
        _output = "Error";
        return;
      }
      result = _num1 / _num2;
    }

    // 根据当前进制格式化结果
    if (_currentBase != NumberBase.decimal) {
      // 非十进制模式下，结果转换为整数
      int intResult = result.toInt();
      _output = _formatToBase(intResult, _currentBase);
    } else {
      _output = result.toString();
      _removeDecimalZero();
    }
  }

  void _removeDecimalZero() {
    if (_output.endsWith(".0")) {
      _output = _output.substring(0, _output.length - 2);
    }
  }

  void _handleNumber(String buttonText) {
    if (_output == "Error") {
      _clearAll();
      _output = buttonText;
      _isNewNumber = false;
      return;
    }

    if (_isNewNumber) {
      // 如果上一次操作是等号，且现在输入新数字，则清空表达式
      if (_operand.isEmpty && _expression.contains("=")) {
        _expression = "";
      }
      _output = buttonText;
      _isNewNumber = false;
    } else {
      if (_output == "0") {
        _output = buttonText;
      } else {
        _output = _output + buttonText;
      }
    }
  }

  Widget buildButton(
    String buttonText,
    Color buttonColor,
    Color textColor, {
    bool isSmallText = false,
  }) {
    bool enabled = _isButtonEnabled(buttonText);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6.0),
        child: SizedBox.expand(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? buttonColor : Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(0),
              elevation: enabled ? 2 : 0,
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: isSmallText ? 20.0 : 28.0,
                fontWeight: FontWeight.w500,
                color: enabled ? textColor : Colors.grey[700],
              ),
            ),
            onPressed: enabled ? () => buttonPressed(buttonText) : null,
          ),
        ),
      ),
    );
  }

  // 构建进制切换按钮
  Widget buildBaseButton(NumberBase base) {
    bool isSelected = _currentBase == base;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            _getBaseName(base),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
          ),
          onPressed: () => _switchBase(base),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Programmer Calculator"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          // 进制模式选择器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                buildBaseButton(NumberBase.decimal),
                buildBaseButton(NumberBase.binary),
                buildBaseButton(NumberBase.octal),
                buildBaseButton(NumberBase.hexadecimal),
              ],
            ),
          ),

          // 显示区域
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 24.0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _output,
                      style: const TextStyle(
                        fontSize: 80.0,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 键盘区域
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: Column(
                children: [
                  // 第一行：C, DEL, %, /
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("C", Colors.grey, Colors.black),
                        buildButton(
                          "DEL",
                          Colors.grey,
                          Colors.black,
                          isSmallText: true,
                        ),
                        buildButton("%", Colors.grey, Colors.black),
                        buildButton("/", Colors.orange, Colors.white),
                      ],
                    ),
                  ),
                  // 第二行：A, B, C(hex), *
                  if (_currentBase == NumberBase.hexadecimal)
                    Expanded(
                      child: Row(
                        children: [
                          buildButton("A", Colors.grey[850]!, Colors.white),
                          buildButton("B", Colors.grey[850]!, Colors.white),
                          buildButton("C", Colors.grey[850]!, Colors.white),
                          buildButton("*", Colors.orange, Colors.white),
                        ],
                      ),
                    ),
                  // 第三行：D, E, F, - (仅十六进制) 或 7, 8, 9, *
                  if (_currentBase == NumberBase.hexadecimal)
                    Expanded(
                      child: Row(
                        children: [
                          buildButton("D", Colors.grey[850]!, Colors.white),
                          buildButton("E", Colors.grey[850]!, Colors.white),
                          buildButton("F", Colors.grey[850]!, Colors.white),
                          buildButton("-", Colors.orange, Colors.white),
                        ],
                      ),
                    ),
                  // 数字行
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("7", Colors.grey[850]!, Colors.white),
                        buildButton("8", Colors.grey[850]!, Colors.white),
                        buildButton("9", Colors.grey[850]!, Colors.white),
                        buildButton(
                          _currentBase == NumberBase.hexadecimal ? "+" : "*",
                          Colors.orange,
                          Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("4", Colors.grey[850]!, Colors.white),
                        buildButton("5", Colors.grey[850]!, Colors.white),
                        buildButton("6", Colors.grey[850]!, Colors.white),
                        buildButton("-", Colors.orange, Colors.white),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("1", Colors.grey[850]!, Colors.white),
                        buildButton("2", Colors.grey[850]!, Colors.white),
                        buildButton("3", Colors.grey[850]!, Colors.white),
                        buildButton("+", Colors.orange, Colors.white),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        buildButton("00", Colors.grey[850]!, Colors.white),
                        buildButton("0", Colors.grey[850]!, Colors.white),
                        buildButton(".", Colors.grey[850]!, Colors.white),
                        buildButton("=", Colors.orange, Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
