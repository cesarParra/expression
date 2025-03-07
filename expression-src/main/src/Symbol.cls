public with sharing class Symbol {
    public final String name { get; private set; }

    public Symbol(String name) {
        if (name == null) {
            throw new IllegalArgumentException('Name cannot be null');
        }
        this.name = name;
    }

    public Boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        // TODO: Get rid of this check
        if (this == obj) {
            return true;
        }
        if (obj instanceof Symbol) {
            Symbol other = (Symbol) obj;
            return this.name.equals(other.name);
        }
        return false;
    }

    public Integer hashCode() {
        return name.hashCode();
    }
}
