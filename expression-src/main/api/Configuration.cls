/**
 * @description Configuration class for the evaluator.
 */
global with sharing class Configuration {
    global enum SharingMode {
        WITH,
        WITHOUT
    }

    global String globalContextVariablePrefix = '@';
    global SharingMode sharing = SharingMode.WITH;
    global Boolean printAst = false;
    global Map<String, Object> customContext = new Map<String, Object>();
    global Boolean cacheFunctionResults = true;
    public Boolean withDiagnostics = false;

    global Configuration respectSharing(Boolean respect) {
        sharing = respect ? SharingMode.WITH : SharingMode.WITHOUT;
        return this;
    }

    global Configuration printAst() {
        printAst = true;
        return this;
    }

    global Configuration withDiagnostics() {
        withDiagnostics = true;
        return this;
    }

    global Configuration disableFunctionResultCaching() {
        cacheFunctionResults = false;
        return this;
    }

    global Configuration withCustomContext(Map<String, Object> objectsByStrings) {
        Map<String, Object> objectToSet = objectsByStrings ?? new Map<String, Object>();
        this.customContext = objectToSet;
        return this;
    }

    global Configuration withGlobalContextVariablePrefix(String prefix) {
        this.globalContextVariablePrefix = prefix;
        return this;
    }

    public void subscribe(EvaluatorEventNotifier notifier) {
        // Always subscribe to the event that sets the sharing mode
        // at the beginning of the evaluation regardless of configuration.
        notifier.subscribe(OnEvaluationStartEvent.class, new EvaluationSharingModeSetter());

        if (this.printAst) {
            notifier.subscribe(OnAfterParseEvent.class, new AstPrinter());
        }

        if (this.withDiagnostics) {
            EvaluationDiagnosticsListener diagnosticsListener = new EvaluationDiagnosticsListener();
            notifier.subscribe(OnEvaluationStartEvent.class, diagnosticsListener);
            notifier.subscribe(OnEvaluationEndEvent.class, diagnosticsListener);
        }
    }
}
