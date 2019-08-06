@isTest
private class NotesTrigger_Test
{
    static testMethod void TestNote()
    { 
       Test.startTest();
       User u1 = [SELECT id,lastname,user.profile.name from User WHERE user.profile.name = 'system Administrator'  and isactive =true LIMIT 1];
       System.runas(u1){
       
       Account accObj = new account();
        accObj.name= 'Test Acc';
        insert accObj;
       
       Note n = new Note();
       n.title='Test Note';
       n.body = 'Test Notes Description';
       n.parentid = accObj.id;
       insert n;
       
       n.title= 'Test Note2';
       update n;
       Test.stopTest();
       
    }
   }
   
   static testMethod void TestNote2()
    { 
       Test.startTest();
       User u1 = [SELECT id,lastname,user.profile.name from User WHERE user.profile.name != 'system Administrator'  and isactive =true LIMIT 1];
       System.runas(u1){
       
       Account acc = new account();
        acc.name= 'Test Acc';
        insert acc;
       
       Note nn = new Note();
       nn.title='Test Note';
       nn.body = 'Test Notes Description';
       nn.parentid = acc.id;
       insert nn;
       
       nn.title= 'Test Note2';
       try{
       update nn;
       }catch(exception ex){
           Boolean expectedExceptionThrown =  ex.getMessage().contains('Update on this record is restricted, Please Contact your System Admin!') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
       }
       Test.stopTest();
       
    }
   }
    
}