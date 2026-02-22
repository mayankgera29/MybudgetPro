//
//  CategoryTapGesture.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//
import Foundation
import UIKit

final class CategoryTapGesture: UITapGestureRecognizer {
    let category: CategoryType

    init(category: CategoryType, target: Any?, action: Selector?) {
        self.category = category
        super.init(target: target, action: action)
    }
}
