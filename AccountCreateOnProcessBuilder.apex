public class AccountCreateOnProcessBuilder {
    @InvocableMethod
    /**
     * 1) Create apex class that can be lunched from Process Builder (for Account).
	   2) Apex class should make next logic: When new Account is created, 
          create new Task object with Subject “Negotiations with {Account.Name}”,
          link created Account with this Task.
       3) If Account is updated and Account has more than 3 Tasks => assign all Tasks 
        to one User (random active User)  
     */
    public static void createAccount(List<ID> ids){
        
        List<Account> accountToBeUpdated = new List<Account>();
        List <task> taskToInsert = new List <task> ();
        List<Account> accounts = [Select Name,OwnerId,(Select Subject,OwnerId,WhatId from Tasks ),Id From Account WHERE Id in :ids];
        List <User> allUser = [Select  ID  From User LIMIT 100];
        List <task> taskToBeUpdated = new List <task> ();
        for(Account account: accounts){
            
            if(account.Tasks.size()>3){
                 accountToBeUpdated.add(account);
                 Integer randomNumber = Integer.valueof((Math.random() * (allUser.size()-1)  ));
                 User usr = allUser.get(randomNumber);
                 for( task t: account.Tasks){
                     t.OwnerId = usr.ID;
                     taskToBeUpdated.add(t);
                 }
            }else{
                task t = new task ();
                t.Subject = 'Negotiations with '+account.Name;
                t.OwnerId = account.OwnerId;
                t.WhatId = account.Id;
                account.Name = account.Name + ' Test';
                accountToBeUpdated.add(account);
                taskToInsert.add(t);
            }
            
        }
        insert taskToInsert;
        update accountToBeUpdated;
        update taskToBeUpdated;
    }
}