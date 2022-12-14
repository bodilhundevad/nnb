class LoanRequest < ApplicationRecord
  belongs_to :user
  belongs_to :loan

  LOAN_CATEGORIES = ["Education", "Health", "Insurance", "Business", "Emergency"]
  LOAN_REQUEST_STATUS = ["Submitted", "Pending", "Active", "Declined", "Closed", "Cancelled"]
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :loan_category, inclusion: { in: LOAN_CATEGORIES }
  validates :status, inclusion: { in: LOAN_REQUEST_STATUS }

  before_save :create_chatroom

  def create_chatroom
    if status == "Active"
    Chatroom.create(loan: loan)
    end
  end
end
