# file: app.rb
require "sinatra"
require "sinatra/reloader"
require_relative "lib/database_connection"
require_relative "lib/album_repository"
require_relative "lib/artist_repository"

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload "lib/album_repository"
    also_reload "lib/artist_repository"
  end

  post "/albums" do
    repo = AlbumRepository.new
    new_album = Album.new
    new_album.title = params[:title]
    new_album.release_year = params[:release_year]
    new_album.artist_id = params[:artist_id]

    repo.create(new_album)
    return ("")
  end

  get "/albums" do
    repo = AlbumRepository.new
    @albums = repo.all
    @artists = ArtistRepository.new

    return erb(:albums)
  end

  post "/artists" do
    repo = ArtistRepository.new
    new_artist = Artist.new
    new_artist.name = params[:name]
    new_artist.genre = params[:genre]

    repo.create(new_artist)
    return ("")
  end

  get "/artists" do
    repo = ArtistRepository.new
    @artists = repo.all
    
    return erb(:artists)
  end

  get "/artists/new" do

    return erb(:new_artist)
  end

  post '/artists/created' do
    
    if invalid_request_parameters
      status 400
      break
    end

    # Get request body parameters
    name = params[:name]
    genre = params[:genre]
  
    # Do something useful, like creating a post
    # in a database.
    new_artist = Artist.new
    new_artist.name = name
    new_artist.genre = genre
    ArtistRepository.new.create(new_artist)
  
    # Return a view to confirm
    # the form submission or resource creation
    # to the user.
    return erb(:artist_created)
  end

  def invalid_request_parameters
    return true if params[:name] == nil || params[:genre] == nil

    return true if params[:name] == "" || params[:genre] == ""

    return false
  end

  get '/albums/new' do
    return erb(:new_album)
  end

  post '/albums/created' do

    if invalid_request_parameters?
      status 400
      break
    end
  
    title = params[:title]
    release_year = params[:release_year]
    artist_id = params[:artist_id]
  
    new_album = Album.new
    new_album.title = title
    new_album.release_year = release_year
    new_album.artist_id = artist_id
    AlbumRepository.new.create(new_album)
  
    # Return a view to confirm
    # the form submission or resource creation
    # to the user.
    return erb(:albums_created)
  end

  
  def invalid_request_parameters?
    # Are the params nil?
    return true if params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
  
    # Are they empty strings?
    return true if params[:title] == "" || params[:release_year] == "" || params[:artist_id] == ""
  
    return false
  end

  get "/albums/:id" do
    repo = AlbumRepository.new
    artists = ArtistRepository.new
    @album = repo.find(params[:id])
    @artist = artists.find(@album.artist_id)

    return erb(:album)
  end

  get "/artists/:id" do
    repo = ArtistRepository.new
    @artist = repo.find(params[:id])

    return erb(:artist)
  end
end
