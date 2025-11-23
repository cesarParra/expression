public with sharing class Stack {
    private final List<Object> items = new List<Object>();

    public void push(Object item) {
        items.add(item);
    }

    public Object pop() {
        if (!canPop()) {
            throw new StackException('Cannot pop from empty stack');
        }
        return items.remove(items.size() - 1);
    }

    public Object peek() {
        if (!canPop()) {
            throw new StackException('Cannot peek from empty stack');
        }
        return items[items.size() - 1];
    }

    public Boolean canPop() {
        return !items.isEmpty();
    }

    public Boolean isEmpty() {
        return items.isEmpty();
    }

    public class StackException extends Exception {}
}
