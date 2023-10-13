public inherited sharing abstract class QRunner {
    public abstract List<SObject> run(Q query);

    public static QRunner getInstance() {
        if (Evaluator.evaluationSharingMode == Evaluator.SharingMode.WITH) {
            return new WithSharingRunner();
        } else {
            return new WithoutSharingRunner();
        }
    }

    private with sharing class WithSharingRunner extends QRunner {
        public override List<SObject> run(Q query) {
            System.debug('running with sharing');
            return Database.query(query.build());
        }
    }

    private without sharing class WithoutSharingRunner extends QRunner {
        public override List<SObject> run(Q query) {
            System.debug('running without sharing ' + query.build() + ' ' + AccessLevel.SYSTEM_MODE);
            return Database.query(query.build(), AccessLevel.SYSTEM_MODE);
        }
    }
}
