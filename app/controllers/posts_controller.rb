class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like, :unlike]
  before_action :authenticate_user!
  before_action :owned_post, only: [:edit, :update, :destroy]
  def index
     @posts = Post.where("user_id IN (?) OR user_id = ?", current_user.following.ids, current_user.id).order('created_at DESC').page params[:page]
     respond_to do |format|
      format.html { render 'index' }
      format.js   { render 'infinite_scroll_index' }
    end
  end

  def browse
    @posts = Post.all.order('created_at DESC').page params[:page]
    respond_to do |format|
      format.html
      format.js   { render 'infinite_scroll_index' }
    end
  end

  def show
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      flash[:success] = "Your post has been created!"
      redirect_to root_path
    else
      flash.now[:alert] = "Your new post couldn't be created!  Please check the form."
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      flash[:success] = "Post updated."
      redirect_to @post
    else
      flash.now[:alert] = "Update failed.  Please check the form."
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:success] = 'Your post has been deleted.'
    redirect_to posts_path
  end

  def like
    if @post.liked_by current_user
      create_notification @post
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    end
  end

  def unlike
    if @post.unliked_by current_user
      respond_to do |format|
        format.html { redirect_to :back }
        format.js
      end
    end
  end

  private

    def post_params
      params.require(:post).permit(:image, :caption)
    end

    def set_post
      @post = Post.find(params[:id])
    end

    def owned_post
      unless current_user == @post.user
        redirect_to root_path
      end
    end

    def create_notification(post)
        return if post.user.id == current_user.id
        Notification.create(user_id: post.user.id,
                            subscribed_user_id: current_user.id,
                            post_id: post.id,
                            identifier: post.id,
                            notice_type: 'liked')
    end
end
