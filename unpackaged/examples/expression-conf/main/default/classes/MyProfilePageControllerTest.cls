/**
 * @description An apex class that updates details of a portal user.
 * Guest users are never able to access this page.
 */
@IsTest public with sharing class MyProfilePageControllerTest {

    @IsTest(SeeAllData=true) static void testSave() {
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT Id, ProfileId, UserRoleId FROM User WHERE UserRoleId <> NULL AND UserType = 'CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            User currentUser = [
                SELECT Id, Title, FirstName, LastName, Email, Phone, MobilePhone, Fax, Street, City, State, PostalCode, Country
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ];
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.getIsEdit() == true);
            controller.cancel();
            System.assert(controller.getIsEdit() == false);

            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));

            String randFax = Math.rint(Math.random() * 1000) + '5551234';
            controller.getUser().Fax = randFax;
            controller.save();
            System.assert(controller.getIsEdit() == false);

            currentUser = [SELECT Id, Fax FROM User WHERE Id = :currentUser.Id];
            System.assert(currentUser.Fax == randFax);
        } else {
            User existingPortalUser = existingPortalUsers[0];
            String randFax = Math.rint(Math.random() * 1000) + '5551234';

            System.runAs(existingPortalUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(existingPortalUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                controller.edit();
                System.assert(controller.getIsEdit() == true);

                controller.cancel();
                System.assert(controller.getIsEdit() == false);

                controller.getUser().Fax = randFax;
                controller.save();
                System.assert(controller.getIsEdit() == false);
            }

            // verify that the user was updated
            existingPortalUser = [SELECT Id, Fax FROM User WHERE Id = :existingPortalUser.Id];
            System.assert(existingPortalUser.Fax == randFax);
        }
    }
}
