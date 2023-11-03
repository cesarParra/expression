global with sharing class Configuration {
    public static Configuration.SharingMode evaluationSharingMode;

    global enum SharingMode {
        WITH,
        WITHOUT
    }

    global SharingMode sharing = SharingMode.WITH;
    global Boolean printAst = false;
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
}