/**
 * Created by cesar on 11/3/2023.
 */

global without sharing class UpdateAccount implements IExpressionFunction {
    global Object execute(List<Object> args) {
        Id accountId = (Id) args[0];
        Map<Object, Object> extra = (Map<Object, Object>) args[1];
        String newName = (String) extra.get('name');
        update new Account(Id = accountId, Name = newName);
        return null;
    }
}