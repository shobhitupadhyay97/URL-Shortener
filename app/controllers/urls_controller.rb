class UrlsController < ApplicationController
	def home
	end

	def search
	end

	def search_result
				@url = Url.search(params[:url][:keyword])
	end

	def show
		@url = Url.find(params[:id])
	end

	def show_long_url
		#@url = Url.find_by(short_url: params[:url][:short_url])
		#Rails.cache.clear
		#puts params
		@url = Rails.cache.fetch(params[:url][:short_url], expires_in: 15.minutes) do 
					Url.where(short_url: params[:url][:short_url]).first
    end
    puts params
    puts 'ysjfsakdbmnsdfbmasnbfdmnasbfmnsbdfmnsbmdfnbanmb'
    if @url != nil
      HitcountWorker.perform_async(@url.id)
			redirect_to @url
		else
			flash[:danger] = "Short URL not found"
			redirect_to fetch_long_url_path
		end
	end

	def fetch_long_url
		if session[:user_id] == nil
      redirect_to signup_path
  	end
	end

	def new
		@url = Url.new
	end

	def create
		@url = Url.new(url_params)
		require 'digest/md5'
		@url.url_digest = Digest::MD5.hexdigest(params[:url][:long_url])
		@url.short_url = @url.url_digest[0,6]
		@url.count = 0
		if @url.save
			redirect_to @url
		else
			render 'new'
		end
	end

	private
		def url_params
			params.require(:url).permit(:long_url, :domain)
		end
end
