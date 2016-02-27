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
//    func answerList(quizID: String) -> [Answer] {
//        return Answer.MR_findByAttribute("quiz_id", withValue: quizID) as! [Answer]
//    }
//    
//    func courseList() -> [Course] {
//        return Course.MR_findAllSortedBy("name", ascending: true) as! [Course]
//    }
//    
//    func courseList(predicate: NSPredicate) -> [Course] {
//        return Course.MR_findAllSortedBy("course_id", ascending: true, withPredicate: predicate) as! [Course]
//    }
//    
//    func course(courseID: String) -> Course {
//        return Course.MR_findFirstByAttribute("course_id", withValue: courseID)
//    }
//    
//    func quizList(courseID: String) -> [Quiz] {
//        return Quiz.MR_findByAttribute("course_id", withValue: courseID, andOrderBy: "to", ascending: false) as! [Quiz]
//    }
//    
//    func quizList() -> [Quiz] {
//        return Quiz.MR_findAllSortedBy("to", ascending: false) as! [Quiz]
//    }
//    
//    func quiz(quizID: String) -> Quiz {
//        return Quiz.MR_findFirstByAttribute("quiz_id", withValue: quizID)
//    }
//    
//    func question(questionID: String) -> Question {
//        return Question.MR_findFirstByAttribute("question_id", withValue: questionID)
//    }
//    
//    func quizContent(quizID: String) -> [Question] {
//        return Question.MR_findByAttribute("quiz_id", withValue: quizID, andOrderBy: "no", ascending: true) as! [Question]
//    }
//    
//    func project(projectID: String) -> Project {
//        return Project.MR_findFirstByAttribute("project_id", withValue: projectID)
//    }
//    
//    func problemList(projectID: String) -> [Problem] {
//        return Problem.MR_findByAttribute("project_id", withValue: projectID, andOrderBy: "name", ascending: true) as! [Problem]
//    }
//    
//    func projectList(courseID: String) -> [Project] {
//        return Project.MR_findByAttribute("course_id", withValue: courseID, andOrderBy: "to", ascending: false) as! [Project]
//    }
//    
//    func teammateList(courseID: String) -> [Teammate] {
//        return Teammate.MR_findByAttribute("course_id", withValue: courseID, andOrderBy: "name", ascending: true) as! [Teammate]
//    }
//    
//    func creatorList(projectID: String) -> [Group] {
//        let predicate = NSPredicate(format: "project_id = %@ && created = %@", projectID, true)
//        return Group.MR_findAllSortedBy("name", ascending: true, withPredicate: predicate) as! [Group]
//    }
//    
//    func memberList(projectID: String) -> [Group] {
//        let predicate = NSPredicate(format: "project_id = %@ && created = %@", projectID, false)
//        return Group.MR_findAllSortedBy("name", ascending: true, withPredicate: predicate) as! [Group]
//    }
    
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
    
    func deleteProjectList(courseID: String) {
        Project.MR_deleteAllMatchingPredicate(NSPredicate(format: "course_id = %@", courseID))
    }
    
    func deleteGroupList(projectID: String) {
        Group.MR_deleteAllMatchingPredicate(NSPredicate(format: "project_id = %@", projectID))
    }
    
    func deleteProblemList(projectID: String) {
        Problem.MR_deleteAllMatchingPredicate(NSPredicate(format: "project_id = %@", projectID))
    }
    
    func deleteTeammateList(courseID: String) {
        Teammate.MR_deleteAllMatchingPredicate(NSPredicate(format: "course_id = %@", courseID))
    }
    
//    func cachedAnswerForQuiz(quizID: String) -> [Answer] {
//        return Answer.MR_findByAttribute("quiz_id", withValue: quizID) as! [Answer]
//    }
    
    /**
     Truncate all data
     */
    
    func truncateData() {
        User.MR_truncateAll()
        Course.MR_truncateAll()
        Quiz.MR_truncateAll()
        Group.MR_truncateAll()
        Project.MR_truncateAll()
        Teammate.MR_truncateAll()
        Problem.MR_truncateAll()
        Question.MR_truncateAll()
        Answer.MR_truncateAll()
    }
}
