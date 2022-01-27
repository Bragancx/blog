class ArticlesController < ApplicationController
  include Paginable

  before_action :authenticate_user!, except: %i[index show]
  before_action :set_article, only: %i[edit update destroy]
  before_action :set_categories, only: %i[new create edit update]

  def index
    @archives = Article.group_by_month(:created_at, format: '%B %Y', locale: :en).count

    @categories = Category.sorted
    category = @categories.select { |c| c.name == params[:category] }[0] if params[:category].present?
    month_year = @archives.select { |m| m[0] == params[:month_year] }&.first if params[:month_year].present?
    
    @highlights = Article
      .includes(:category, :user)
      .filter_by_category(category)
      .filter_by_archive(month_year)
      .desc_order
      .first(3)
      
      highlights_ids = @highlights.pluck(:id).join(",")
      
      
      @articles = Article.without_highlights(highlights_ids)
      .includes(:category, :user)
      .filter_by_category(category)
      .filter_by_archive(month_year)
      .desc_order
      .page(current_page)

    end

  def new
    @article = current_user.articles.new()
  end

  def create
    @article = current_user.articles.new(article_params)

    if @article.save
      redirect_to @article, notice: t('.sucess')
    else
      render :new, status: :unprocessable_entity
    end  
  end

  def show
    @article = Article.includes(comments: :user).find(params[:id])
    authorize @article
  end

  def edit; end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: t('.sucess')
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: t('.sucess') }
      format.json { head :no_content }
    end

  end

  private

  def article_params
    params.require(:article).permit(:title, :body, :category_id)
  end

  def set_article
    @article = Article.find(params[:id])
    authorize @article
  end

  def set_categories
    @categories = Category.sorted
  end
end
