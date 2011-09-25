require 'net/https'

class ActivitiesController < ApplicationController
  # GET /activities
  # GET /activities.json
  def index
    # アクセストークン未取得または有効期限切れの場合はOAuth 2.0で認証する
    redirect_to "https://accounts.google.com/o/oauth2/auth?"\
      "client_id=#{CLIENT_ID}&"\
      "redirect_uri=#{REDIRECT_URI}&"\
      "scope=#{SCOPE}&"\
      "response_type=#{RESPONSE_TYPE}" and return if cookies[:access_token].blank?

    # 公開ストリームを取得する
    uri = URI.parse("https://www.googleapis.com/plus/v1/people/me/activities/public?"\
      "access_token=#{cookies[:access_token]}")
    https = Net::HTTP.new(uri.host, 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = https.start do |https|
      request = Net::HTTP::Get.new(uri.path << '?' << uri.query)
      https.request(request)
    end

    @activities = ActiveSupport::JSON.decode(response.body)
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
    @activity = Activity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @activity }
    end
  end

  # GET /activities/new
  # GET /activities/new.json
  def new
    @activity = Activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @activity }
    end
  end

  # GET /activities/1/edit
  def edit
    @activity = Activity.find(params[:id])
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(params[:activity])

    respond_to do |format|
      if @activity.save
        format.html { redirect_to @activity, notice: 'Activity was successfully created.' }
        format.json { render json: @activity, status: :created, location: @activity }
      else
        format.html { render action: "new" }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.json
  def update
    @activity = Activity.find(params[:id])

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to activities_url }
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
    @activity = Activity.new(:access_token => response_hash["access_token"])
    @activity.save

    redirect_to url_for(:activities)
  end
end
