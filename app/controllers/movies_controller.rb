class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @order_by = params['sort_by'] || session[:sort_by]
    @all_ratings = Movie.select(:rating).distinct().pluck(:rating)
    @ratings_to_show = params[:ratings] || (params[:commit] == 'Refresh' ? {} : session[:ratings_list]) 
    puts 'Awumen Alora ' + params[:ratings].to_s
    @movies = Movie.where(rating: @ratings_to_show.keys).order(@order_by)

    #@rating_list = params[:ratings]&.keys
    #@ratings_to_show = @rating_list || ''
    #@movies = Movie.with_ratings(@)
    #debugger
    session[:sort_by] = @order_by
    session[:ratings_list] = @ratings_to_show
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

end
