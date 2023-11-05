public with sharing class EvaluatorEventNotifier {
    final Map<Type, List<EvaluatorEventListener>> listeners =
        new Map<Type, List<EvaluatorEventListener>>();

    // Holds any data received from the event handler.
    final Map<String, Object> listenerData;

    public EvaluatorEventNotifier(Map<String, Object> listenerData) {
        this.listenerData = listenerData;
    }

    public void subscribe(Type eventType, EvaluatorEventListener listener) {
        List<EvaluatorEventListener> users = listeners.get(eventType);
        if (users == null) {
            users = new List<EvaluatorEventListener>();
            listeners.put(eventType, users);
        }
        users.add(listener);
    }

    public void notify(EvaluatorEvent event) {
        Type eventType = event.getType();
        List<EvaluatorEventListener> users = listeners.get(eventType);
        if (users != null) {
            for (EvaluatorEventListener listener : users) {
                Map<String, Object> handlerResult = listener.handle(event);
                if (handlerResult != null) {
                    listenerData.putAll(handlerResult);
                }
            }
        }
    }
}