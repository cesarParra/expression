public with sharing class CallStack {
    private final List<String> stack = new List<String>();
    private CallStack() {}

    public static CallStack instance {
        get {
            if (instance == null) {
                instance = new CallStack();
            }
            return instance;
        }
        private set;
    }

    public Boolean isEmpty() {
        return stack.isEmpty();
    }

    public Integer size() {
        return stack.size();
    }

    public void push(String methodName) {
        stack.add(methodName);
    }

    public void pop() {
        stack.remove(stack.size() - 1);
    }

    public String peek() {
        return stack[stack.size() - 1];
    }

    public String peekN(Integer n) {
        return stack[stack.size() - n];
    }

    public override String toString() {
        return String.join(stack, ' > ');
    }
}
