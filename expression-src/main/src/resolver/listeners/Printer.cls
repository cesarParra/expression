public with sharing class Printer {
    private Printer() {}

    public static Printer instance {
        get {
            if (instance == null) {
                instance = new Printer();
            }
            return instance;
        }

        private set;
    }

    public List<Object> toPrint = new List<Object>();

    public void print(Object toPrint) {
        this.toPrint.add(toPrint);
    }
}
