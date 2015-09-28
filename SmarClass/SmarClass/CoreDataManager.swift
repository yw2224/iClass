//
//  CoreDataManager.swift
//  SmarClass
//
//  Created by PengZhao on 15/8/28.
//  Copyright (c) 2015年 PKU. All rights reserved.
//

import Foundation
import CocoaLumberjack
import CoreData
import MagicalRecord

class CoreDataManager: NSObject {
    
    static let sharedInstance = CoreDataManager()
    
    static func config() {
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStoreNamed("SmartClass")
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
        NSManagedObjectContext.MR_defaultContext().MR_saveOnlySelfAndWait()
    }
    
    func answerList(quiz_id: String) -> [Answer] {
        return Answer.MR_findByAttribute("quiz_id", withValue: quiz_id) as! [Answer]
    }
    
    func courseList() -> [Course] {
        return Course.MR_findAllSortedBy("course_id", ascending: true) as! [Course]
    }
    
    func course(courseID: String) -> Course {
        return Course.MR_findFirstByAttribute("course_id", withValue: courseID)
    }
    
    func quizList(courseID: String) -> [Quiz] {
        return Quiz.MR_findByAttribute("course_id", withValue: courseID, andOrderBy: "to", ascending: false) as! [Quiz]
    }
    
    func quizList() -> [Quiz] {
        return Quiz.MR_findAllSortedBy("to", ascending: false) as! [Quiz]
    }
    
    func quiz(quizID: String) -> Quiz {
        return Quiz.MR_findFirstByAttribute("quiz_id", withValue: quizID)
    }
    
    func question(questionID: String) -> Question {
        return Question.MR_findFirstByAttribute("question_id", withValue: questionID)
    }
    
    func quizContent(quiz_id: String) -> [Question] {
        return Question.MR_findByAttribute("quiz_id", withValue: quiz_id, andOrderBy: "no", ascending: true) as! [Question]
    }
    
    func deleteQuestions(quiz_id: String) {
        let predicate = NSPredicate(format: "quiz_id = %@", quiz_id)
        Question.MR_deleteAllMatchingPredicate(predicate)
    }
    
    func deleteQuizWithinPredicate(predicate: NSPredicate) {
        Quiz.MR_deleteAllMatchingPredicate(predicate)
    }
    
    func deleteAnswers(quiz_id: String) {
        let predicate = NSPredicate(format: "quiz_id = %@", quiz_id)
        Answer.MR_deleteAllMatchingPredicate(predicate)
    }
    
    func deleteCourseWithinPredicate(predicate: NSPredicate) {
        Course.MR_deleteAllMatchingPredicate(predicate)
    }
    
    func deleteAllCourses() {
        Course.MR_truncateAll()
    }
    
    func cachedAnswerForQuiz(quiz_id: String) -> [Answer] {
        return Answer.MR_findByAttribute("quiz_id", withValue: quiz_id) as! [Answer]
    }
}
