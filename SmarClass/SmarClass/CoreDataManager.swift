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
    
    func courseList() -> [Course] {
        return Course.MR_findAllSortedBy("course_id", ascending: true) as! [Course]
    }
    
    func quizList() -> [Quiz] {
        return Quiz.MR_findAllSortedBy("to", ascending: false) as! [Quiz]
    }
    
    func answerList(quiz_id: String) -> [Answer] {
        return Answer.MR_findByAttribute("quiz_id", withValue: quiz_id) as! [Answer]
    }
    
    func quizContent(quiz_id: String) -> [Question] {
        return Question.MR_findByAttribute("quiz_id", withValue: quiz_id, andOrderBy: "no", ascending: true) as! [Question]
    }
    
    func deleteQuestions(quiz_id: String) {
        for question in quizContent(quiz_id) {
            question.MR_deleteEntity()
        }
    }
    
    func deleteAnswers(quiz_id: String) {
        for answer in answerList(quiz_id) {
            answer.MR_deleteEntity()
        }
    }
    
    func cachedAnswerForQuiz(quiz_id: String) -> [Answer] {
        return Answer.MR_findByAttribute("quiz_id", withValue: quiz_id) as! [Answer]
    }
}
