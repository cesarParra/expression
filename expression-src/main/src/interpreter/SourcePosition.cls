public with sharing class SourcePosition {
    public final Integer lineStart;
    public final Integer lineEnd;
    public final Integer columnStart;
    public final Integer columnEnd;

    public SourcePosition(Integer lineStart, Integer columnStart, Integer columnEnd) {
        this.lineStart = lineStart;
        this.lineEnd = lineStart;
        this.columnStart = columnStart;
        this.columnEnd = columnEnd;
    }

    public SourcePosition(Integer lineStart, Integer lineEnd, Integer columnStart, Integer columnEnd) {
        this.lineStart = lineStart;
        this.lineEnd = lineEnd;
        this.columnStart = columnStart;
        this.columnEnd = columnEnd;
    }
}
