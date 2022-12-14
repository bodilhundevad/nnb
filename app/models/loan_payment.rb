class LoanPayment < ApplicationRecord
  belongs_to :loan
  belongs_to :tranfers, optional: true

  LOAN_PAYMENT_STATUS = ["Scheduled", "Completed"]
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_create :set_profit

  def set_profit
    total_profit = (self.loan.interest_rate / 100) * self.amount
    self.update(profit: total_profit)
  end
end
