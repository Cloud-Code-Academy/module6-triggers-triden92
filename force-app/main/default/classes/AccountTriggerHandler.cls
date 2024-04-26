public with sharing class AccountTriggerHandler extends TriggerHandler{
    private List<Account> newAccList;
    private Map<Id,Account> newAccMap;
    private List<Account> oldAccList;
    private Map<Id,Account> oldAccMap;

    public AccountTriggerHandler(){
        this.newAccList = (List<Account>)Trigger.new;
        this.newAccMap = (Map<Id,Account>)Trigger.newMap;
        this.oldAccList = (List<Account>)Trigger.old;
        this.oldAccMap = (Map<Id,Account>)Trigger.oldMap;

    }
    
    public override void beforeInsert(){
        setTypeProspect(newAccList);
        addressCopy(newAccList);
        setRating(newAccList);
            
    }
    
    public override void afterInsert(){
       List<Contact> insertContacts = defaultContact(newAccList);

       insert insertContacts;

            
    }

    public static void setTypeProspect(List<Account> accList){
        List<Account> accUpdateList = new List<Account>(); 
         for(Account acc :accList){
             if(acc.Type == null){
                 acc.Type = 'Prospect';
             }
             accUpdateList.add(acc);
         }
            
     }

     public static void  addressCopy(List<Account> accList){
        List<Account> accUpdateList = new List<Account>();
        for(Account acc :accList){
            acc.BillingStreet = acc.ShippingStreet ?? '';
            acc.BillingCity = acc.ShippingCity ?? '';
            acc.BillingState = acc.ShippingState ?? '';
            acc.BillingPostalCode = acc.ShippingPostalCode ?? '';
            acc.BillingCountry = acc.ShippingCountry ?? '';

            accUpdateList.add(acc);
        }
        
    }

    public static void setRating(List<Account> accList){
        List<Account> accUpdateList = new List<Account>();
        for(Account acc :accList){
            if(acc.Phone != '' && acc.Website != '' && acc.Fax != ''){
                acc.Rating = 'Hot';

                accUpdateList.add(acc);
            }
        }
        
    }

    public static List<Contact> defaultContact(List<Account> accList){
        List<Contact> contactCreateList = new List<Contact>();
        for(Account acc :accList){
            Contact newContact = new Contact();
            newContact.LastName = 'DefaultContact';
            newContact.Email = 'default@email.com';
            newContact.AccountId = acc.Id;

            contactCreateList.add(newContact);

        }
        return contactCreateList;
    }
    
}