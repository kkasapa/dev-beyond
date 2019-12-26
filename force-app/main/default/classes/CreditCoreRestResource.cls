/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Exposed REST API class for Credit Core
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2019-10-16
* @modified       2019-10-16
* @Layer          REST API 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/creditCore/*')
global with sharing class CreditCoreRestResource {
	@HttpGet
    global static string getDetails() {
    	return null;    
    }
}