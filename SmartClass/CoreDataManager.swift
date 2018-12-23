//
//  CoreDataManager.swift
//  SmartClass
//
//  Created by PengZhao on 15/8/28.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import MagicalRecord

class CoreDataManager: NSObject {
    
    // MARK: Singleton
    static let sharedInstance = CoreDataManager()
    
    static func config() {
        MagicalRecord.setupAutoMigratingCoreDataStack()
    }
    
    static func cleanup() {
        MagicalRecord.cleanUp()
    }
    
    func saveInBackground() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion {
            (success, error) in
            DDLogInfo("save in background: \(success) \(error)")
        }
    }
    
    func saveInForeground() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
//    /**
//     Methods retrieving data from local data base (Core Data)
//     */
   /*func lessonList(courseID: String) -> [Lesson] {
        
    }*/
    func notificationList(courseID: String) -> [Notification] {
        return Notification.MR_findByAttribute("courseID", withValue: courseID) as! [Notification]
    }
    
    func exList(courseID: String) -> [EX] {
        return EX.MR_findByAttribute("courseID", withValue: courseID) as! [EX]
    }
    
    func lessonList(courseID: String) -> [Lesson] {
        return Lesson.MR_findByAttribute("courseID", withValue: courseID) as! [Lesson]
    }//??
    func lessonFileList(lessonName: String) -> [File] {
        return File.MR_findByAttribute("lessonName", withValue: lessonName) as! [File]
    }//??
    
    func answerList(quizID: String) -> [Answer] {
        return Answer.MR_findByAttribute("quiz_id", withValue: quizID) as! [Answer]
    }
    
    func courseList() -> [Course] {
        return Course.MR_findAllSortedBy("name", ascending: true) as! [Course]
    }
    
    func courseList(predicate: NSPredicate) -> [Course] {
        return Course.MR_findAllSortedBy("course_id", ascending: true, withPredicate: predicate) as! [Course]
    }
    
    func course(courseID: String) -> Course {
        return Course.MR_findFirstByAttribute("course_id", withValue: courseID)!
    }
    
    func quizList(courseID: String) -> [Quiz] {
        return Quiz.MR_findByAttribute("course_id", withValue: courseID, andOrderBy: "to", ascending: false) as! [Quiz]
    }
    
    func quizList() -> [Quiz] {
        return Quiz.MR_findAllSortedBy("to", ascending: false) as! [Quiz]
    }
    
    func quiz(quizID: String) -> Quiz {
        return Quiz.MR_findFirstByAttribute("quiz_id", withValue: quizID)!
    }
    
    func question(questionID: String) -> Question {
        return Question.MR_findFirstByAttribute("question_id", withValue: questionID)!
    }
    
    func quizContent(quizID: String) -> [Question] {
        return Question.MR_findByAttribute("quiz_id", withValue: quizID, andOrderBy: "no", ascending: true) as! [Question]
    }
    

    
    /**
     Methods deleting data from local data base (Core Data)
     */
    
    func deleteQuestions(quizID: String) {
        Question.MR_deleteAllMatchingPredicate(NSPredicate(format: "quiz_id = %@", quizID))
    }
    
    func deleteQuizWithinPredicate(predicate: NSPredicate) {
        Quiz.MR_deleteAllMatchingPredicate(predicate)
    }
    
    func deleteAnswers(quizID: String) {
        Answer.MR_deleteAllMatchingPredicate(NSPredicate(format: "quiz_id = %@", quizID))
    }
    
    func deleteCourseWithinPredicate(predicate: NSPredicate) {
        Course.MR_deleteAllMatchingPredicate(predicate)
    }
    
    func deleteAllCourses() {
        Course.MR_truncateAll()
    }
    
   
    func deleteLessonList(courseID: String) {
        Lesson.MR_deleteAllMatchingPredicate(NSPredicate(format: "courseID = %@", courseID))
    }//??
    
    
    func cachedAnswerForQuiz(quizID: String) -> [Answer] {
        return Answer.MR_findByAttribute("quiz_id", withValue: quizID) as! [Answer]
    }
    
    /**
     Truncate all data
     */
    
    func truncateData() {
        User.MR_truncateAll()
        Course.MR_truncateAll()
        Quiz.MR_truncateAll()
        Question.MR_truncateAll()
        Answer.MR_truncateAll()
        Lesson.MR_truncateAll() //??
    }
}
