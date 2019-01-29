class UrlsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    if session[:user_id] == nil
      redirect_to signup_path
      return
    end
  end

  def search
  end

  def search_result
    if params[:url][:keyword].nil?
      @urls = []
    else
      @urls = Url.custom_search(params[:url])
    end
  end

  def report
    @conversions = Conversion.all
  end

  def show
    if session[:user_id] == nil
      redirect_to signup_path
    end
    @url = Url.find(params[:id])
  end

  def show_long_url
    if session[:user_id] == nil
      redirect_to signup_path
    end
    respond_to do |format|
      #@url = Url.find_by(short_url: params[:url][:short_url])
      @url = Rails.cache.fetch(params[:url][:short_url], expires_in: 15.minutes) do 
        Url.where(short_url: params[:url][:short_url]).first
      end
      if @url.present?
        HitcountWorker.perform_async(@url.id)
        format.html{redirect_to @url}
        format.json{render json:{"long_url"=>@url.long_url}}
      else
        flash[:danger] = "Short URL not found"
        format.html{redirect_to fetch_long_url_path}
        format.json{render json:{"response"=>"Not Found"}}
      end  
    end
  end

  def fetch_long_url
    if session[:user_id] == nil
      redirect_to signup_path
      return
    end
  end

  def new
    if session[:user_id] == nil
      redirect_to signup_path
      return
    end
    @url = Url.new
  end

  def create
    if session[:user_id] == nil
      redirect_to signup_path
    end
    @url = Url.new(url_params)
    require 'digest/md5'
    short_domain = params[:url][:domain][0,3]
    @url.url_digest = Digest::MD5.hexdigest(params[:url][:long_url])
    @url.short_url = 'www.' + short_domain + '.com/' + @url.url_digest[0,6]
    @url.count = 0
    respond_to do |format| 
      if @url.save
        format.html {redirect_to @url}
        format.json {render json: {"Short url" => @url.short_url}}
      else
        format.html{render 'new'}
        format.json{render json:{"response" => "Invalid Url"}}
      end
    end
  end

  private
    def url_params
      params.require(:url).permit(:long_url, :domain)
    end
end
