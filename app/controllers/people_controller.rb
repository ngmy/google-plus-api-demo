require 'net/https'

class PeopleController < ApplicationController
  # GET /people
  # GET /people.json
  def index
    # アクセストークン未取得または有効期限切れの場合はOAuth 2.0で認証する
    redirect_to "https://accounts.google.com/o/oauth2/auth?"\
      "client_id=#{CLIENT_ID}&"\
      "redirect_uri=#{REDIRECT_URI}&"\
      "scope=#{SCOPE}&"\
      "response_type=#{RESPONSE_TYPE}" and return if cookies[:access_token].blank?

    # 公開ストリームを取得する
    uri = URI.parse("https://www.googleapis.com/plus/v1/people/#{USER_ID}/activities/public?"\
      "access_token=#{cookies[:access_token]}")
    https = Net::HTTP.new(uri.host, 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = https.start do |https|
      request = Net::HTTP::Get.new(uri.path << '?' << uri.query)
      https.request(request)
    end

    @people = ActiveSupport::JSON.decode(response.body)
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render json: @person, status: :created, location: @person }
      else
        format.html { render action: "new" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :ok }
    end
  end

  def oauth2callback
    # アクセスを許可しなかった場合はトップ画面にリダイレクトする
    redirect_to url_for(:controller => "tops", :action => "index") and return if params["code"].nil?

    # 認可コードをアクセストークンおよびリフレッシュトークンと交換する
    uri = URI.parse("https://accounts.google.com/o/oauth2/token")
    https = Net::HTTP.new(uri.host, 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = https.start do |https|
      request = Net::HTTP::Post.new(uri.path)
      request.set_form_data({
        :code          => params[:code],
        :client_id     => CLIENT_ID,
        :client_secret => CLIENT_SECRET,
        :redirect_uri  => REDIRECT_URI,
        :grant_type    => "authorization_code"
      }, "&")
      https.request(request)
    end

    response_hash = ActiveSupport::JSON.decode(response.body)
    cookies[:access_token] = {
      :value => response_hash["access_token"],
      :expires => response_hash["expires_in"].seconds.from_now
    }
    @person = Person.new(:access_token => response_hash["access_token"])
    @person.save

    redirect_to url_for(:people)
  end
end
