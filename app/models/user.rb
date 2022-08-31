class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :loans
  has_many :loan_requests
  has_many :wallets

  USER_TYPES = ["Lender", "Borrower"]
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :user_type, inclusion: { in: USER_TYPES }
end