class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # initialize ordering with either of params or session and revert to default 'id' if all fails
    @order_by = params['sort_by'] || session[:sort_by] || 'id'
    # Query database and extract all unique ratings
    @all_ratings = Movie.select(:rating).distinct().pluck(:rating)
    # populate ratings to show from params or session and revert to all ratings if all fails
    @ratings_to_show = params[:ratings]&.keys || 
                      (params[:commit] == 'Refresh' ? @all_ratings : 
                      (!session[:ratings_list] || session[:ratings_list].empty?) ? @all_ratings : 
                      session[:ratings_list])
    # Order movies according to ordering
    @movies = Movie.where(rating: @ratings_to_show).order(@order_by)

    session[:sort_by] = @order_by
    if params[:ratings]
    
    elsif params[:commit] == 'Refresh'
      @ratings_to_show = []
    elsif session[:ratings_list] && session[:ratings_list].empty?
      @ratings_to_show = []
    end
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

  private
  def get_class param
    mm = @order_by == param ? Array['bg-warning'] : ''
    mm
  end

  helper_method :get_class
end
