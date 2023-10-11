global with sharing class DebugCall implements IExpressionFunction {
    global Object execute(List<Object> args) {
        System.debug('I was successfully called as a reference!!!: ' + args);
        return null;
    }
}
