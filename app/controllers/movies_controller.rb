class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    
    if params.has_key? :sort
      session[:sort] = params[:sort]
    end
    
    if params.has_key? :ratings
      session[:ratings] = params[:ratings]
    end
    
    if session.has_key? :ratings
      @checked_ratings = session[:ratings]
      @movies = @movies.with_ratings(@checked_ratings.keys)
    end
    
    if session.has_key? :sort
      if session[:sort] == 'title'
        @movies = @movies.order('title ASC')
        @class_title = 'hilite bg-warning'
      elsif session[:sort] == 'release_date'
        @movies = @movies.order('release_date ASC')
        @class_release_date = 'hilite bg-warning'
      end
    end
    
    flash.keep
    
    if !params.has_key?(:sort) and !params.has_key?(:ratings) and session.has_key?(:sort) and session.has_key?(:ratings)
      redirect_to movies_path([:ratings] => [session[:ratings].keys] ,:sort => session[:sort])
    end
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
