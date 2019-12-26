@isTest
public class Holidays_Test {

    @testsetup
    public static void testData(){

		Holiday h = new holiday(); 
        
        h.Name = 'Test_5thJuly'; 
        
        h.ActivityDate = Date.newInstance(2017, 7, 4); 
        
        h.IsAllDay = true; 
        
        //holidaylist.add(h);
        
        insert h;         

    }
    
    public testmethod static void testHoliday(){
      

        List<Holiday> holidaylist = new List<Holiday>();

        
        Holiday h = new holiday(); 
        
        h.Name = 'Test_4thJuly'; 
        
        h.ActivityDate = Date.newInstance(2017, 7, 4); 
        
        h.IsAllDay = true; 
        
        holidaylist.add(h);
        
        insert h; 
        
        Holiday mday = new holiday(); 
        
        mday.Name = 'Test_MemorialDay'; 
        
        mday.ActivityDate = Date.newInstance(2017, 29, 4); 
        
        mday.IsAllDay = true; 
        
        mday.IsRecurrence = true; 
        
        mday.RecurrenceDayOfMonth = 07; 
        
        mday.RecurrenceMonthOfYear = 'May';
        
        mday.RecurrenceStartDate = Date.newInstance(2017, 29, 4);
        
        mday.RecurrenceType = 'RecursYearly';
        
        holidaylist.add(mday);
            
        insert mday;         
        
        
               
       String day = Holidays.dayOftheWeek( Date.newInstance(2017,4,20)); 
        System.assertEquals('Thursday', day );
        
        String dayT = Holidays.dayOftheWeek( DateTime.newInstance(2017,4,20)); 
        System.assertEquals('Thursday', dayT );
        
        List<Holiday> holidaylist1 = Holidays.getHolidays();
        //
        
        //System.assertEquals(holidaylist.size(), 13);
        System.debug('List Holidays :-- ' +holidaylist);
        
        //System.assertEquals(holidaylist[0].Name, 'Test_4thJuly');
        
        Boolean isholiday =  Holidays.isHolidayOrWeekend(holidayList,Date.newInstance(2017,4,20));
        
        boolean fourthJuly = Holidays.isHolidayOrWeekend(holidayList, Date.newInstance(2017,7,4)); 
        
        System.assertEquals(isholiday,false); 
        //System.assertEquals(fourthJuly,true); 
        
        integer sunday = Holidays.dayOfTheWeekmask('Sunday');
        
        System.assertEquals(1, sunday); 
        
        integer saturday = Holidays.dayOfTheWeekmask('Saturday');
        
        System.assertEquals(2, Saturday); 
        
        integer nullWeekmask = Holidays.dayOfTheWeekmask('');
        
        System.assertEquals(null, nullWeekmask);         
        
         integer monday = Holidays.dayOfTheWeekmask('Monday');
        
        System.assertEquals(0, Monday); 
        
        integer tuesday = Holidays.dayOfTheWeekmask('Tuesday');
        
        System.assertEquals(0, Tuesday); 
        
        integer wednesday = Holidays.dayOfTheWeekmask('Wednesday');
        
        System.assertEquals(0, wednesday); 

        integer sunday2 = Holidays.holidaysInWeekDays('sunday');
        
        System.assertEquals(1, sunday2); 
        
        Boolean isweekend = Holidays.isWeekEnd('sunday');
        
        System.assert(isweekend); 
        
        integer month =  Holidays.monthOfTheYear('April'); 
        
        System.assertEquals(month, 4); 
        
        month =  Holidays.monthOfTheYear('August'); 
        
        System.assertEquals(month, 8); 
        
         month =  Holidays.monthOfTheYear('September'); 
        
        System.assertEquals(month, 9); 
        
        
         month =  Holidays.monthOfTheYear('October'); 
        
        System.assertEquals(month, 10);
        
         month =  Holidays.monthOfTheYear('November'); 
        
        System.assertEquals(month, 11);
        
         month =  Holidays.monthOfTheYear('December'); 
        
        System.assertEquals(month, 12);   
        
        month =  Holidays.monthOfTheYear(''); 
        
        System.assertEquals(month, null);
        
        Map<String,Holiday> holidaymap = Holidays.getHolidaysMap();
        
        Date workingDay = Holidays.getNextWorkingDay(HolidayMap, Date.newInstance(2017, 07, 04));
        
        System.assertEquals(Date.newInstance(2017, 07, 05),workingDay); 
        
        Date nextWorkingDay = Holidays.getNextWorkingDay(holidayList, Date.newInstance(2017, 07, 04));
        
        
        integer holidaysInWeekDays =  Holidays.holidaysInWeekDays('Monday');
        
          System.assertEquals(holidaysInWeekDays,1); 
        
        holidaysInWeekDays =  Holidays.holidaysInWeekDays('Tuesday');
        
          System.assertEquals(holidaysInWeekDays,1); 
        
        holidaysInWeekDays =  Holidays.holidaysInWeekDays('Wednesday');
        
          System.assertEquals(holidaysInWeekDays,1); 
        
        holidaysInWeekDays =  Holidays.holidaysInWeekDays('Thursday');
        
          System.assertEquals(holidaysInWeekDays,1);        
        
        holidaysInWeekDays =  Holidays.holidaysInWeekDays('Friday');
        
          System.assertEquals(holidaysInWeekDays,3); 
        
          holidaysInWeekDays =  Holidays.holidaysInWeekDays('Saturday');
        
          System.assertEquals(holidaysInWeekDays,2);

          holidaysInWeekDays =  Holidays.holidaysInWeekDays('');
        
          System.assertEquals(holidaysInWeekDays,null);           
        
        Boolean isCustomweekend = Holidays.CustomWeekend('sunday');
        
        System.assert(isweekend);                         
        
        Date dt = Holidays.calculateNthWorkingDay(Date.today(), 3);

        
    }
    
    
}