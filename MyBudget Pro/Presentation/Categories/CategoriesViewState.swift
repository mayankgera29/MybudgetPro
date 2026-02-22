//
//  CategoriesViewState.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//


import Foundation

struct CategoriesViewState {
    let categories: [(category: CategoryType, total: Double)]
    let maxValue: Double
}