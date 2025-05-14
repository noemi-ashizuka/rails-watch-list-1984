require 'rest-client'
require 'faker'

puts 'Cleaning the db'

Bookmark.destroy_all
List.destroy_all
Movie.destroy_all

puts 'Cleaning done'

puts 'Fetching genres'
genres_url = "https://api.themoviedb.org/3/genre/movie/list?api_key=#{ENV['MOVIES_API']}&language=en-US"

genres_doc = JSON.parse(RestClient.get(genres_url))

genre_ids = genres_doc['genres'].map { |genre| genre['id'] }

puts 'Genres created'

puts 'Creating movies'


movies = genre_ids.map do |genre_id|
  url = "https://api.themoviedb.org/3/discover/movie?api_key=#{ENV['MOVIES_API']}&with_genres=#{genre_id}&sort_by=revenue.desc"

  movies_doc = JSON.parse(RestClient.get(url))

  movies_doc['results'].first(10)
end

movies.flatten.each do |movie_data|
  movie = Movie.find_by(title: movie_data['title'])
  unless movie
    movie = Movie.create!(
      title: movie_data['title'],
      overview: movie_data['overview'],
      poster_url: "https://image.tmdb.org/t/p/w500/#{movie_data['poster_path']}",
      rating: movie_data['vote_average'].to_f.round(1)
    )
  end
  p "Creating #{movie.title}"
end

puts "There are #{Movie.count} movies in the database"
