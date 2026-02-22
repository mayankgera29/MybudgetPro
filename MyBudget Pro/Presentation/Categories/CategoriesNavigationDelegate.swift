//
//  CategoriesNavigationDelegate.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//


import Foundation

protocol CategoriesNavigationDelegate: AnyObject {
    func openCategoryDetail(category: CategoryType)
}