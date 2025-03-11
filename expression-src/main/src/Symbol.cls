public with sharing class Symbol {
    public final String name { get; private set; }

    public Symbol(String name) {
        if (name == null) {
            throw new IllegalArgumentException('Name cannot be null');
        }
        this.name = name.toLowerCase();
    }

    public Boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (obj instanceof Symbol) {
            Symbol other = (Symbol) obj;
            return this.name.equalsIgnoreCase(other.name);
        }
        return false;
    }

    public Integer hashCode() {
        return name.hashCode();
    }
}
