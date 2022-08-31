class Loan < ApplicationRecord
  belongs_to :user
  has_many :loan_payments
  has_many :loan_requests

  LOAN_CATEGORIES = ["Education", "Health", "Insurance", "Business"]
  LOAN_STATUS = ["Pending", "Listed", "Active", "Closed"]
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interest_rate, presence: true
  validates :loan_category, inclusion: { in: LOAN_CATEGORIES }
  validates :status, inclusion: { in: LOAN_STATUS }
end