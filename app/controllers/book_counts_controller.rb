class BookCountsController < ApplicationController
  before_action :set_book_count, only: [:show, :edit, :update, :destroy]
  before_action :authorize

  # GET /book_counts
  # GET /book_counts.json
  def index
    user_type = session[:user_type]
    case user_type
    when ApplicationController::TYPE_STUDENT
      flash[:notice] = "You are not authorised to perform this action"
      redirect_to root_path
    when ApplicationController::TYPE_LIBRARIAN
      @book_counts = BookCount.fetch_book_counts_by_library(@current_user.library_id)
    when ApplicationController::TYPE_ADMIN
      @book_counts = BookCount.all
    end
  end

  # GET /book_counts/1
  # GET /book_counts/1.json
  def show
    user_type = session[:user_type]
    case user_type
    when ApplicationController::TYPE_STUDENT
      flash[:notice] = "You are not authorised to perform this action"
      redirect_to root_path
    when ApplicationController::TYPE_LIBRARIAN
      check = BookCount.check_if_authorised?(current_user.library_id, params[:id])
      if (check == false)
        flash[:notice] = "You are not authorised to perform this action"
        redirect_to root_path
      end
    when ApplicationController::TYPE_ADMIN
      # admin can see any book count
    end
  end

  # GET /book_counts/new
  def new
    user_type = session[:user_type]
    case user_type
    when ApplicationController::TYPE_STUDENT
      flash[:notice] = "You are not authorised to perform this action"
      redirect_to root_path
    else
      # admin can see any book count
      @book_count = BookCount.new
    end
  end

  # GET /book_counts/1/edit
  def edit
    user_type = session[:user_type]
    case user_type
    when ApplicationController::TYPE_STUDENT
      flash[:notice] = "You are not authorised to perform this action"
      redirect_to root_path
    when ApplicationController::TYPE_LIBRARIAN
      check = BookCount.check_if_authorised?(current_user.library_id, params[:id])
      if (check == false)
        flash[:notice] = "You are not authorised to perform this action"
        redirect_to root_path
      end
    when ApplicationController::TYPE_ADMIN
      # admin can see any book count
    end
  end

  # POST /book_counts
  # POST /book_counts.json
  def create
    @book_count = BookCount.new(book_count_params)
    book_exists = BookCount.exists?(:library_id => book_count_params[:library_id],
                                    :book_id => book_count_params[:book_id])
    respond_to do |format|
      if book_exists
        format.html { redirect_to @book_count, notice: 'This book is already present in the library.' }
      else
        if @book_count.save
          format.html { redirect_to @book_count, notice: 'Book count was successfully created.' }
          format.json { render :show, status: :created, location: @book_count }
        else
          format.html { render :new }
          format.json { render json: @book_count.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /book_counts/1
  # PATCH/PUT /book_counts/1.json
  def update
    respond_to do |format|
      if @book_count.update(book_count_params)
        format.html { redirect_to @book_count, notice: 'Book count was successfully updated.' }
        format.json { render :show, status: :ok, location: @book_count }
      else
        format.html { render :edit }
        format.json { render json: @book_count.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /book_counts/1
  # DELETE /book_counts/1.json
  def destroy
    @book_count.destroy
    respond_to do |format|
      format.html { redirect_to book_counts_url, notice: 'Book count was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_book_count
    @book_count = BookCount.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def book_count_params
    params.require(:book_count).permit(:book_id, :library_id, :book_copies)
  end
end
