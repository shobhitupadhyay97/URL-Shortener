class UrlsController < ApplicationController
  skip_before_action :verify_authenticity_token
=begin
  **Author:** Shobhit Upadhyay <br/>
  **Common Name:** URL Shortener <br />
  **Request Type:** GET <br />
  **Route :** /urls <br />
  **Authentication Required:** yes <br />
=end
  def index
    if session[:user_id] == nil
      redirect_to signup_path
      return
    end
  end
=begin
  **Common Name:** Create shorturl from the input longurl and domain
  **End points:** Other services
  **Request Type:** POST
  **Route:** urls_path
  **url:**  URI("http://localhost:3000/urls/new")
  **Paramas:** { "long_url" : " ",
            "domain"  : " "
          }
  **Cookies:** {
    Name : URL-Shortener
    Value : 
    Domain : localhost
    HttpOnly : True
    Secure : false
  }
  **Content-Type:** application/json; charset=utf-8
  **Input Type:** JSON
  **Input Fields:** longurl,domain 
  **Output Type:** JSON
  **Output Fields:** status, shorturl
  **Host:** localhost:3000
  **Cache-Control:** no-cache
  **Custom Status Messages:** {
    a)Message : "already_exist"
    Status  : 200 OK
    Description : If the input longurl already exists in the database,
    it will just find the shorturl correponding to that longurl in the database and 
    return that shorturl along with above mentioned message.
    b)Message  : "new created shorturl"
    Status   :  200 OK
    Description : If the input longurl is not already present in the database,
    and new shorturl is created correponding to that longurl and domain.
    It is than saved in the database and return the newly generated shorturl alongwith the above message.
    c)Message : "error occured"
    Status : 200 OK
    Description : If the input url is not according to the validations mentioned in the url model,
    than an error message will be displayed to the user as mentioned above
    d)Status : 404 Internal server error
    Description : If the longurl is not defined in the input params
    e)Message : "Short Domain not found,please add short domain" 
    Status : 404 OK
    Description : if domain entered by user in not in shortdomain table
  }   
=end
  def new
    if session[:user_id] == nil
      redirect_to signup_path
      return
    end
    @url = Url.new
  end
=begin
  **Author:** Shobhit Upadhyay <br/>
  **Common Name:** URL Shortener <br />
  **Request Type:** POST <br />
  **Route :** /urls/create <br />
  **Authentication Required:** yes <br />
=end
  def create
    if session[:user_id] == nil
      redirect_to signup_path
    end
    @url = Url.new(url_params)
    require 'digest/md5'
    @domain = Domain.find_by(domain_name: params[:url][:domain].downcase)
    if @domain.present?
      @check = Url.find_by(long_url: params[:url][:long_url])
      if @check.present?
        flash[:danger] = "Long Url already present."
        redirect_to @check
        return
      else
        short_domain = @domain.short_domain
        @url.url_digest = Digest::MD5.hexdigest(params[:url][:long_url])
        @url.short_url = short_domain + '/' + @url.url_digest[0,6]
        @url.count = 0
      end
    else
      flash[:danger] = "Ask admin to update Domain table"
      render 'new'
      return
    end
    respond_to do |format| 
      if @url.save
        format.html {redirect_to @url}
        format.json {render json: {"Short url" => @url.short_url}}
      else
        format.html{render 'new',:status=>404}
        format.json{render json:{"response" => "Invalid Url"},:status=>404}
      end
    end
  end
=begin
  **Author:** Shobhit Upadhyay <br/>
  **Common Name:** URL Shortener <br />
  **Request Type:** GET <br />
  **Route :** /urls/show <br />
  **Authentication Required:** yes <br />
=end
  def show
    if session[:user_id] == nil
      redirect_to signup_path
    end
    @url = Url.find(params[:id])
  end
=begin
  **Common Name:**Search for longurl from input shorturl
  **End points:** Other services
  **Request Type** : GET
  **Routes** : fetch_long_url_path
  **url:** URI("http://localhost:3000/fetch_long_url")
  **Params:** KEY->short_url , VALUE-> '' , DESCRIPTION-> 'ShortUrl Input to get longurl in return'
  **Cookies:**{
    Name : URL-Shortener
    Value : 
    Domain : localhost
    HttpOnly : True
    Secure : false
  }
  **Content-Type:** application/json; charset=utf-8
  **Output Type:** JSON
  **Output Fields:** status,longurl
  **Host:** localhost:3000
  **Cache-Control:**  no-cache
  **Custom Status Messages:**{
    a)Message : "longurl corresponding to shorturl is found"
    Status  : 200 OK
    Description : Since the input shorturl is already existed in the database,
    it will just find the longurl correponding to that shorturl in the database and 
    return that longurl along with above mentioned message.
    b)Message  : "Invalid shorturl"
    Status   :  404 OK
    Description : If the input shorturl is not already present in the database,
    it will return the above message
    c)Status : 500 Internal server error
    Description : If the shorturl key is not mentioned in the input params
  }
=end
  def fetch_long_url
    if session[:user_id] == nil
      redirect_to signup_path
      return
    end
  end
=begin
  **Author:** Shobhit Upadhyay <br/>
  **Common Name:** URL Shortener <br />
  **Request Type:** GET <br />
  **Route :** /urls/show_long_url <br />
  **Authentication Required:** yes <br />
=end
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
        format.html{render :fetch_long_url,:status=>404}
        format.json{render json:{"response"=>"Not Found"},:status=>404}
      end  
    end
  end
=begin
  **Author:** Shobhit Upadhyay <br/>
  **Common Name:** URL Shortener <br />
  **Request Type:** GET <br />
  **Route :** /urls/search <br />
  **Authentication Required:** yes <br />
=end
  def search
  end
=begin
  **Author:** Shobhit Upadhyay <br/>
  **Common Name:** URL Shortener <br />
  **Request Type:** GET <br />
  **Route :** /urls/search_result <br />
  **Authentication Required:** yes <br />
=end
  def search_result
    if params[:url][:keyword].nil?
      @urls = []
    else
      @urls = Url.custom_search(params[:url])
    end
  end
=begin
  **Author:** Shobhit Upadhyay <br/>
  **Common Name:** URL Shortener <br />
  **Request Type:** GET <br />
  **Route :** /urls/report <br />
  **Authentication Required:** yes <br />
=end
  def report
    @conversions = Conversion.all
  end

  private
    def url_params
      params.require(:url).permit(:long_url, :domain)
    end
end
