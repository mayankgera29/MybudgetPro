//
//  ReportsViewModel.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//
import UIKit

final class ReportsViewModel {

    struct CategorySummary {
        let category: CategoryType
        let amount: Double
    }

    private let repository: ExpenseRepositoryProtocol = ExpenseRepository.shared

    var summaries: [CategorySummary] {
        let expenses = repository.fetchAll()
        let grouped = Dictionary(grouping: expenses, by: { $0.category })

        return grouped.map {
            CategorySummary(
                category: $0.key,
                amount: $0.value.reduce(0) { $0 + $1.amount }
            )
        }
    }

    var pieSlices: [PieChartView.Slice] {
        summaries.map {
            PieChartView.Slice(
                value: $0.amount,            // 🔥 FIXED ORDER
                color: $0.category.color
            )
        }
    }

    var totalAmount: Double {
        summaries.reduce(0) { $0 + $1.amount }
    }
}
