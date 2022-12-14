class LoansController < ApplicationController

  def show
    @loan = Loan.find(params[:id])
    # @loan_request = @loan.loan_requests.where(status: "Active").first
    @loan_requests = @loan.loan_requests
    @loan_payments = @loan.loan_payments
    @loan_payments_made = @loan_payments.where(payment_status: "Completed")
    sum = 0
    @already = @loan.loan_payments.where(payment_status: "Completed").sum(:amount)
    @still = @loan.amount + @loan.amount * @loan.interest_rate / 100 - @loan.loan_payments.where(payment_status: "Completed").sum(:amount)
    @loan_payments_made.each do |payment|
      sum += payment.amount
    end
    @amount_paid = sum
    @loan_payments_remaining = @loan_payments.where(payment_status: "Scheduled")
  end

  def index
    @loans = Loan.where(status: "Listed")
    if params['length'].present? && params['amount'].present?
      length_in_days = params[:length].to_i * 31
      @loans = @loans.where("amount >= #{params[:amount].to_f}").where("payback_time <= #{length_in_days}")
    elsif params['amount'].present?
      @loans = @loans.where("amount >= #{params[:amount].to_f}")
    elsif params['length'].present?
      length_in_days = params[:length].to_i * 31
      @loans = @loans.where("payback_time <= #{length_in_days}")
    end

    if params['loan'].present?
      @loans = @loans.where(loan_category: params[:loan][:loan_category])
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @loan = Loan.new
  end

  def create
    @loan = Loan.new(loan_params)
    @loan.user = current_user
    params[:loan][:instant_loan] == "Auto" ? @loan.instant_loan = true : @loan.instant_loan = false

    if @loan.instant_loan == true && current_user.wallet.amount <= @loan.amount
      @loan.status = "Pending"
    else
      @loan.status = "Listed"
    end


    if params[:loan][:payback_time] == "Month"
      @loan.payback_time = 30
    elsif params[:loan][:payback_time] == "Week"
      @loan.payback_time = 7
    elsif params[:loan][:payback_time] == "Quarter"
      @loan.payback_time = 90
    else
      @loan.payback_time = 365
    end

    @user = current_user

    if @loan.save!

      Chatroom.create(loan: @loan)

      redirect_to loan_summary_lender_path(@loan)

      # # SEED FOR AUTO REQUEST FOR PITCH
      # if @loan.user.first_name == "Bodil"
      #   amount = @loan.amount
      #   title = "education loan"
      #   description = "new car"
      #   loan_category = "Emergency"
      #   status = "Pending"
      #   user = User.find_by(first_name: "Ben")
      #   loan_request = LoanRequest.create(amount: amount, title: title, description: description, loan_category: loan_category, status: status, user: user, loan: @loan)
      # end
    else
      render :new
    end
  end

  private

  def loan_params
    params.require(:loan).permit(:amount, :payback_time, :payment_frequency, :interest_rate, :loan_category, :instant_loan)
  end
end
