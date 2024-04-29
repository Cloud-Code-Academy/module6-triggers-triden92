public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> newOppList;
    private List<Opportunity> oldOppList;
    private Map<Id,Opportunity> newOppMap;
    private Map<Id,Opportunity> oldOppMap;
    
    public OpportunityTriggerHandler() {
        this.newOppList = (List<Opportunity>)Trigger.new;
        this.oldOppList = (List<Opportunity>)Trigger.old;
        this.newOppMap = (Map<Id,Opportunity>)Trigger.newMap;
        this.oldOppMap = (Map<Id,Opportunity>)Trigger.oldMap;

    }
    
    public override void beforeUpdate(){
        opportunityAmountValidation(newOppList);
        setOpportunityPrimaryContact(newOppList);
    }

    public override void beforeDelete(){
        deleteClosedWonBankingOpportunityValidation(oldOppList);
    }


    public static void opportunityAmountValidation(List<Opportunity> oppList){
        for(Opportunity eachOpp :oppList){
            if(eachOpp.Amount < 5000){
                eachOpp.addError('Opportunity amount must be greater than 5000');
            }
        }

    }

    public static void deleteClosedWonBankingOpportunityValidation(List<Opportunity> oppList){
        List<String> accIdList = new List<String>();
        for(Opportunity eachOpp :oppList){
            accIdList.add(eachOpp.AccountId);
        }
        List<Account> accList = [SELECT Id,Industry FROM Account WHERE Id IN :accIdList];
        Map<Id,String> accountIndustryByIdMap = new Map<Id,String>();
        for(Account acc: accList){
            accountIndustryByIdMap.put(acc.Id,acc.Industry);
        }
        
        for(Opportunity eachOpp :oppList){
            if(eachOpp.StageName == 'Closed Won' && accountIndustryByIdMap.get(eachOpp.AccountId) == 'Banking'){
                System.debug(eachOpp.StageName);
                System.debug(accountIndustryByIdMap.get(eachOpp.AccountId));
                
                
                eachOpp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
            
    }

    public static void setOpportunityPrimaryContact(List<Opportunity> oppList){
        List<Id> accIdList = new List<Id>();
        for(Opportunity eachOpp :oppList){
            accIdList.add(eachOpp.AccountId);
        }

        Map<Id,Id> contactsByAccountIdMap = new Map<Id,Id>();
        List<Contact> contactList = [SELECT Id,AccountId FROM Contact WHERE AccountId IN :accIdList AND Title = 'CEO'];
        for(Contact eachContact :contactList){
            contactsByAccountIdMap.put(eachContact.AccountId,eachContact.Id);
        }
        
        for(Opportunity eachOpp :oppList){
            if(contactsByAccountIdMap.containsKey(eachOpp.AccountId)){
                eachOpp.Primary_Contact__c = contactsByAccountIdMap.get(eachOpp.AccountId);
            }
        }

        
    }
}