class PostsController < ApplicationController
  before_action :set_target_post, only: %i[show edit update destroy]
  before_action :set_form_title, only: %i[new edit]

  def index
    # @posts = Post.all
    # @posts = Post.all.order(created_at: :DESC)
    # @posts = Post.page(params[:page]).per(12)
    @posts = Post.page(params[:page]).per(12).order('created_at DESC')
  end

  def popular
    @popular_posts = Post.unscoped.joins(:likes).group(:post_id).order(Arel.sql('count(likes.user_id) desc')).page(params[:page]).per(12)
  end

  def new
    @post = Post.new(flash[:post])
  end

  def create
    post = current_user.posts.build(post_params)
    if post.save
      flash[:success] = "「#{set_address(post.prefecture.name, post.city.name)}」の記事を作成しました"
      redirect_to root_path
    else
      redirect_to new_post_path, flash: {
        post: post,
        error_messages: post.errors.full_messages
      }
    end
  end

  def destroy
    @post.destroy
    redirect_to root_path, flash: { success: "「#{set_address(@post.prefecture.name, @post.city.name)}」の記事が削除されました" }
  end

  def show
    @comment = Comment.new(post_id: @post.id)
  end

  def edit; end

  def update
    if @post.update(post_params)
      flash[:success] = "「#{set_address(@post.prefecture.name, @post.city.name)}」の記事を編集しました"
      redirect_to root_path
    else
      redirect_back fallback_location: root_path, flash: {
        user: @post,
        error_messages: @post.errors.full_messages
      }
    end
  end

  def cities_select
    if request.xhr?
      render partial: 'cities', locals: { prefecture_id: params[:prefecture_id] }
    end
  end

  private

  def post_params
    params.require(:post).permit(:caption, :image, :user_id, :prefecture_id, :city_id, :weather, :feeling, :expectation)
  end

  def set_target_post
    @post = Post.find(params[:id])
  end

  def set_form_title
    @form_title = params['action'] == 'new' ? '新しい投稿' : '投稿を編集'
    # new: 新しい投稿
    # edit: 編集
  end
end