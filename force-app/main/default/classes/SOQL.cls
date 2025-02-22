/**
 * The SOQL class serves as a primer into the Salesforce Object Query Language in Apex.
 * It covers fundamental aspects such as SELECT statements, WHERE clauses, Relationship queries, and LIMIT keyword.
 *
 * This class introduces developers to the concept of retrieving data from Salesforce using SOQL. It provides
 * a step-by-step guide on how to construct SOQL queries, filter results using WHERE clause, retrieve related
 * records, and manage data volume using the LIMIT keyword.
 *
 * Topics covered in this class include:
 * - Understanding the structure of a SOQL query.
 * - Crafting basic SELECT statements in SOQL.
 * - Applying filters using the WHERE clause in SOQL.
 * - Fetching related records using Relationship queries.
 * - Controlling the amount of data retrieved using the LIMIT keyword.
 *
 * Users of this class can expect to gain a solid understanding of SOQL in Apex and
 * be prepared to handle data retrieval tasks in Salesforce development.
 *
 * @author Temitayo Oluwalade
 */

 public with sharing class SOQL {

    /**
     * Question 1
     * Returns all leads from Salesforce Org
     * @return List<Lead> List of all leads with Id, LastName, Company, Phone, Email
     */
    public static List<Lead> getAllLeads() {
        try {
            return [SELECT Id, LastName, Company, Phone, Email
                    FROM Lead
                    WHERE LastName != null
                    LIMIT 50000];
        } catch(Exception e) {
            return new List<Lead>();
        }
    }

    /**
     * Question 2
     * Returns all contacts with first name of John
     * @return List<Contact> A list of Contact records
     */
    public static List<Contact> getContactsByFirstName() {
        try {
            return [SELECT Id, FirstName, LastName, Name
                    FROM Contact
                    WHERE FirstName = 'John'
                    AND LastName != null
                    LIMIT 50000];
        } catch(Exception e) {
            return new List<Contact>();
        }
    }

    /**
     * Question 3
     * Returns Contact Ids for contacts with specific last names
     * @return List<Id> A list of Contact Ids
     */
    public static List<Id> getContactIdsByLastName() {
        try {
            List<Id> contactIds = new List<Id>();
            for(Contact c : [SELECT Id
                           FROM Contact
                           WHERE LastName IN ('Smith', 'Jones')
                           AND LastName != null
                           LIMIT 50000]) {
                contactIds.add(c.Id);
            }
            return contactIds;
        } catch(Exception e) {
            return new List<Id>();
        }
    }

    /**
     * Question 4
     * Returns List of closed won opportunities for a specific Account
     * @param accountId The ID of the Account
     * @return List<Opportunity> List of filtered opportunities
     */
    public static List<Opportunity> getClosedWonOpportunityCountByAccount(Id accountId) {
        try {
            if(accountId == null) {
                return new List<Opportunity>();
            }
            return [SELECT Id, Name, Amount, CloseDate, AccountId, stageName
                    FROM Opportunity
                    WHERE AccountId = :accountId
                    AND StageName = 'Closed Won'
                    AND Amount != null
                    LIMIT 50000];
        } catch(Exception e) {
            return new List<Opportunity>();
        }
    }

    /**
     * Question 5
     * Returns the total count of Account records
     * @return Integer The count of Account records
     */
    public static Integer getAccountCount() {
        try {
            Integer count = [SELECT COUNT() FROM Account WHERE Name != null];
            return count != null ? count : 0;
        } catch(Exception e) {
            return 0;
        }
    }

    /**
     * Question 6
     * Returns tasks due within next 7 days
     * @return Map<Id, Task> Map of Task Ids to Task records
     */
    public static Map<Id, Task> getTasksDueNextWeek() {
        try {
            Date today = Date.today();
            Date nextWeek = today.addDays(7);

            List<Task> tasks = [SELECT Id, Subject, ActivityDate, Status
                               FROM Task
                               WHERE ActivityDate >= :today
                               AND ActivityDate <= :nextWeek
                               AND Subject != null
                               LIMIT 50000];
            return new Map<Id, Task>(tasks);
        } catch(Exception e) {
            return new Map<Id, Task>();
        }
    }

    /**
     * Question 7
     * Returns contacts with example.com email domain
     * @return List<Contact> List of filtered contacts
     */
    public static List<Contact> getContactsByEmailDomain() {
        try {
            return [SELECT Id, Name, Email
                    FROM Contact
                    WHERE Email LIKE '%example.com'
                    AND Email != null
                    LIMIT 50000];
        } catch(Exception e) {
            return new List<Contact>();
        }
    }

    /**
     * Question 8
     * Returns opportunities containing specific keyword in name
     * @param keyword The keyword to search in Opportunity Name
     * @return List<Opportunity> List of filtered opportunities
     */
    public static List<Opportunity> getOpportunitiesByNameKeyword(String keyword) {
        if (String.isBlank(keyword)) {
            return new List<Opportunity>();
        }

        String searchTerm = '%' + keyword + '%';
        return [SELECT Id, Name
                FROM Opportunity
                WHERE Name LIKE :searchTerm
                LIMIT 50000];
    }

    /**
     * Question 9
     * Returns cases with specific origin criteria
     * @return List<Case> List of filtered cases
     */
    public static List<Case> getFilterCaseOrigins() {
        return [SELECT Id, Origin
                FROM Case
                WHERE Origin NOT IN ('Web', 'Email')
                AND Origin != null
                LIMIT 50000];
    }

    /**
     * Question 10
     * Returns leads by source or title keyword
     * @param leadSource The Lead Source to filter by
     * @param keyword The keyword to search in Title
     * @return List<Lead> List of filtered leads
     */
    public static List<Lead> getLeadsBySourceOrTitle(String leadSource, String keyword) {
        try {
            if(String.isBlank(leadSource) || String.isBlank(keyword)) {
                return new List<Lead>();
            }

            String searchTerm = '%' + keyword + '%';
            return [SELECT Id, Title, LeadSource, LastName, Company, Phone, Email
                    FROM Lead
                    WHERE (LeadSource = :leadSource
                    OR Title LIKE :searchTerm)
                    AND LastName != null
                    LIMIT 50000];
        } catch(Exception e) {
            return new List<Lead>();
        }
    }

    /**
     * Question 11
     * Returns contact names for an account
     * @param accountId The Account Id to query contacts for
     * @return List<String> List of contact last names
     */
    public static List<String> getContactNamesByAccount(Id accountId) {
        List<String> contactNames = new List<String>();
        for (Contact cont : [SELECT LastName
                           FROM Contact
                           WHERE AccountId = :accountId
                           LIMIT 50000]) {
            contactNames.add(cont.LastName);
        }
        return contactNames;
    }

    /**
     * Question 12
     * Returns total revenue for opportunities in specific stage
     * @param stage The stage to filter by
     * @return Decimal The total revenue
     */
    public static Decimal getTotalRevenueByStage(String stage) {
        AggregateResult[] results = [
            SELECT SUM(Amount) total
            FROM Opportunity
            WHERE StageName = :stage
        ];
        return (results.isEmpty()) ? 0 : (Decimal)results[0].get('total');
    }

    /**
     * Question 13
     * Returns first 10 accounts ordered by name
     * @return List<Account> List of accounts
     */
    public static List<Account> getFirstTenAccounts() {
        return [SELECT Id, Name
                FROM Account
                ORDER BY Name
                LIMIT 10];
    }

    /**
     * Question 14
     * Returns high value opportunities
     * @return List<Opportunity> List of filtered opportunities
     */
    public static List<Opportunity> getHighValueOpportunities() {
        return [SELECT Id, Name, Amount, CloseDate
                FROM Opportunity
                WHERE Amount > 100000
                ORDER BY CloseDate
                LIMIT 5];
    }

    /**
     * Question 15
     * Returns contacts ordered by birthdate
     * @return List<Contact> List of filtered contacts
     */
    public static List<Contact> getBirthdateContacts() {
        return [SELECT Id, Name, Birthdate
                FROM Contact
                WHERE Birthdate != null
                ORDER BY Birthdate DESC
                LIMIT 3];
    }

    /**
     * Question 16
     * Returns cases with offset pagination
     * @return List<Case> List of filtered cases
     */
    public static List<Case> getCasesWithStatus() {
        return [SELECT Id, Status, CreatedDate
                FROM Case
                WHERE Status = 'Open'
                ORDER BY CreatedDate
                LIMIT 10 OFFSET 5];
    }

    /**
     * Question 17
     * Returns set of case ids for an account
     * @param accountId The Account Id to query cases for
     * @return Set<Id> Set of case ids
     */
    public static Set<Id> getCaseIdsByAccount(Id accountId) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : [SELECT Id
                      FROM Case
                      WHERE AccountId = :accountId
                      LIMIT 50000]) {
            caseIds.add(c.Id);
        }
        return caseIds;
    }

    /**
     * Question 18
     * Returns account map filtered by country
     * @param country The country to exclude
     * @return Map<Id, String> Map of account ids to names
     */
    public static Map<Id, String> getAccountIdsToNamesNotInCountry(String country) {
        Map<Id, String> accountMap = new Map<Id, String>();
        for (Account acc : [SELECT Id, Name
                          FROM Account
                          WHERE BillingCountry != :country
                          LIMIT 50000]) {
            accountMap.put(acc.Id, acc.Name);
        }
        return accountMap;
    }

    /**
     * Question 19
     * Returns account name for a contact
     * @param contactId The Contact Id
     * @return String The account name
     */
    public static String getAccountNameForContact(String contactId) {
        try {
            Contact cont = [SELECT Account.Name
                           FROM Contact
                           WHERE Id = :contactId
                           LIMIT 1];
            return cont.Account.Name;
        } catch(Exception e) {
            return '';
        }
    }

    /**
     * Question 20
     * Returns account with related opportunities
     * @param accountId The Account Id
     * @return Account The account with opportunities
     */
    public static Account getAccountAndOpportunitiesFromAccountId(Id accountId) {
        return [SELECT Id, Name,
                (SELECT Id, Name, Amount, CloseDate FROM Opportunities)
                FROM Account
                WHERE Id = :accountId
                LIMIT 1];
    }

    /**
     * Question 21
     * Returns contacts matching account state
     * @param accountId The Account Id
     * @return List<Contact> List of filtered contacts
     */
    public static List<Contact> getAccountsWithContactsByState(Id accountId) {
        Account acc = [SELECT BillingState
                      FROM Account
                      WHERE Id = :accountId];
        return [SELECT Id, Name, MailingState
                FROM Contact
                WHERE MailingState = :acc.BillingState
                LIMIT 50000];
    }

    /**
     * Question 22
     * Returns accounts matching lead email domains
     * @param leadIds Set of Lead Ids
     * @return List<Account> List of matching accounts
     */
    public static List<Account> findAccountsByLeadEmailDomains(Set<Id> leadIds) {
        Set<String> emailDomains = new Set<String>();

        for(Lead ld : [SELECT Email FROM Lead WHERE Id IN :leadIds LIMIT 50000]) {
            if(String.isNotBlank(ld.Email)) {
                String[] parts = ld.Email.split('@');
                if(parts.size() > 1) {
                    emailDomains.add(parts[1]);
                }
            }
        }

        return [SELECT Id, Website
                FROM Account
                WHERE Website LIKE :'%' + String.join(new List<String>(emailDomains), '%') + '%'
                LIMIT 50000];
    }

    /**
     * Question 23
     * Clones opportunity line items
     * @param origOppId Original Opportunity Id
     * @param cloneOppIds List of cloned Opportunity Ids
     */
    public static void cloneLineItems(Id origOppId, List<Id> cloneOppIds) {
        List<OpportunityLineItem> originalItems = [
            SELECT Quantity, PricebookEntryId, UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :origOppId
            LIMIT 50000
        ];

        List<OpportunityLineItem> newItems = new List<OpportunityLineItem>();
        Integer randomAdd = (Integer)(Math.random() * 3) + 1;

        for(Id cloneId : cloneOppIds) {
            for(OpportunityLineItem oli : originalItems) {
                OpportunityLineItem newItem = new OpportunityLineItem(
                    OpportunityId = cloneId,
                    Quantity = oli.Quantity + randomAdd,
                    PricebookEntryId = oli.PricebookEntryId,
                    UnitPrice = oli.UnitPrice
                );
                newItems.add(newItem);
            }
        }

        if(!newItems.isEmpty()) {
            insert newItems;
        }
    }

    /**
     * Question 24
     * Returns closed won opportunity details
     * @return List<Opportunity> List of filtered opportunities
     */
    public static List<Opportunity> getOpportunityDetailsForClosedWon() {
        return [SELECT Id, Name, Account.Name, Owner.Name
                FROM Opportunity
                WHERE StageName = 'Closed Won'
                LIMIT 50000];
    }

    /**
     * Question 25
     * Sets primary contact for closed won opportunities
     */
    public static void setPrimaryContact() {
        List<Opportunity> opps = getOpportunityDetailsForClosedWon();
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : opps) {
            accountIds.add(opp.AccountId);
        }

        Map<Id, Contact> accountToContactMap = new Map<Id, Contact>();
        for(Contact con : [SELECT Id, AccountId, FirstName
                         FROM Contact
                         WHERE AccountId IN :accountIds
                         ORDER BY FirstName ASC
                         LIMIT 50000]) {
            if(!accountToContactMap.containsKey(con.AccountId)) {
                accountToContactMap.put(con.AccountId, con);
            }
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity opp : opps) {
            if(accountToContactMap.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = accountToContactMap.get(opp.AccountId).Id;
                oppsToUpdate.add(opp);
            }
        }

        if(!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}
