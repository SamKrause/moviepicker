require 'rest-client'

namespace :movies do
  desc "TODO"
  task create_all: :environment do
    # Can only rake 40ish pages of movies at a time to avoid 429 error so change from 1..1000 to 1..30 then 30..60 etc
    (1..1000).each do |page_num|
      puts "=======Page Number: #{page_num} of 1,000======="
      response = RestClient.get "https://api.themoviedb.org/3/discover/movie?page="+page_num.to_s+"&api_key="+ENV['MOVIES_DB_API_KEY']
      if response.code == 500
        raise "Issues with URL in movies.rake"
      else
        data = JSON.parse(response.body)
        data = data["results"]
        data.each do |movie_json|
          movie_json.symbolize_keys!
          next if movie_json[:original_language] != "en" || movie_json[:adult] == true
          params = {}
          params[:movie_id] = movie_json[:id]
          params[:title]= movie_json[:title]
          params[:overview] = movie_json[:overview]
          params[:photo] = movie_json[:poster_path]
          params[:language] = movie_json[:original_language]
          params[:adult] = movie_json[:adult]
          #params[:runtime] = movie_json[:runtime]
          params[:release_date] = movie_json[:release_date]
          params[:genre]= movie_json[:genre_ids]

            movie = Movie.find_or_initialize_by(title:params[:title])
            if params[:overview] == movie_json[:overview]
              puts "#{movie_json[:title]} created"
              Movie.create(params)
            else
              puts "#{movie_json[:title]} updated"
              movie.update_attributes(title: params[:title], genre: params[:genre], overview: params[:overview], photo: params[:photo], release_date: params[:release_date])
            end
#          begin
#            movie.save!
#          rescue
            #puts "#{movie_json[:title]} already exists"
#          end
        end
      end
    end
  end
end
