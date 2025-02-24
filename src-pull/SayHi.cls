global with sharing class SayHi implements IExpressionFunction {
    global Object execute(List<Object> args) {
        String name = (String) args[0];

        return 'Hi, ' + name + '!';
    }
}
