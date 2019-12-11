trigger DeleteFileFormS3 on AWS_Document__c (before insert,after insert, after delete) {
    new AWS_DocumentHandler().run();
}