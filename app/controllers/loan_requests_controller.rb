class LoanRequestsController < ApplicationController
  before_action :set_loan, except: [:show, :update]
  def new
    # To create a new loan request
    # I need to find the loan id which comes from the url /loans/:loan_id/loan_requests/new(.:format
    # Need to take into the pages
    @loan_request = LoanRequest.new
  end

  def create
    @loan_request = LoanRequest.new(loan_request_params)
    @loan_request.loan_id = @loan.id
    @loan_request.amount = @loan.amount
    @loan_request.loan_category = @loan.loan_category

    # Logic for the wallet based on a loan auto approval

    # Check if lender wallet are nil and set to 0
    if @loan.user.wallet.amount.nil?
      @loan.user.wallet.amount = 0
    end
    # Check if borrower wallet are nil and set to 0
    if current_user.wallet.amount.nil?
      current_user.wallet.amount = 0
    end
    # if loan.approval = auto
    if @loan.instant_loan?
    # Increase the borrower wallet
      @loan.user.wallet.amount -= @loan.amount
      @loan.user.wallet.save
    # decrease the lender wallet
      current_user.wallet.amount += @loan.amount
      current_user.wallet.save
    # and change the loan_request.status to Approved
      @loan_request.status = "Active"
    # Else set loan_request.status to On process
    else
     @loan_request.status = "Pending"
    end
    ###-----NEED TO SAVE THE TRANSACTION AS A TRANSFER ------###
    @loan_request.user = current_user
    if @loan_request.save
      redirect_to loan_request_path(@loan_request.id)
    else
      render :new
    end

  end

  def show
    @loan_request = LoanRequest.find(params[:id])
    @loan = Loan.find(@loan_request.loan_id)
  end

  def update
    # @loan_request = LoanRequest.find(params[:id])
    # respond_to do |format|
    #   if @loan_request.update(item_params)
    #     format.html { redirect_to @loan_request, notice: "Item was successfully updated." }
    #     format.json { render :show, status: :ok, location: @loan_request }
    #   else
    #     format.html { render :edit, status: :unprocessable_entity }
    #     format.json { render json: @loan_request.errors, status: :unprocessable_entity }
    #   end
    @loan_request = LoanRequest.find(params[:id])
    @loan_request.status = params[:status]
    @loan = @loan_request.loan

    if @loan_request.save
      if params[:status] == "Active"
        @loan.status = "Active"
        flash[:notice] = "🎉 Congratulations, your loan has been matched to #{@loan_request.user.first_name} #{@loan_request.user.last_name}.
        The loan has been deducted from your wallet and transferred to the borrower."
      end
      respond_to do |format|
        format.json { render :show, status: :ok, location: @loan_request }
        format.html { redirect_to @loan_request, notice: 'Post was successfully updated.' }
      end
    end
  end

  private

  def set_loan
    @loan = Loan.find(params[:loan_id])
  end

  def loan_request_params
    params.require(:loan_request).permit(:description, :status)
  end

end
