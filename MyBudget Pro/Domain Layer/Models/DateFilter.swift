//
//  DateFilter.swift
//  MyBudget Pro
//
//  Created by mayank gera on 20/01/26.
//


import Foundation

enum DateFilter {
    case all
    case today
    case thisMonth
    case custom(from: Date, to: Date)
}
