trigger DeleteFileFormS3 on AWS_Document__c (after insert, after delete) {
    new AWS_DocumentHandler().run();
}