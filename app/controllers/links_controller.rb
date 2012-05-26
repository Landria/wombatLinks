class LinksController < ApplicationController
  # GET /links
  # GET /links.json

  before_filter :authorize, :only => [:update, :destroy]

  load_and_authorize_resource
  def index
    if signed_in?
      @links = Link.find(:all,:conditions=>["user_id=:user_id",{:user_id=>current_user.id}])
    else
      @links = Link.all(:conditions => 'user_id IS NULL OR user_id = FALSE')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @links }
    end
  end

  # GET /links/1
  # GET /links/1.json
  def show
    @link = Link.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @link }
    end
  end

  # GET /links/new
  # GET /links/new.json
  def new

    @link = Link.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @link }
    end
  end

  # GET /links/1/edit
  def edit
    @link = Link.find(params[:id])
  end

  def get_data_for_link(url)
    require 'net/http'
    data = Net::HTTP.get_response(URI.parse(URI.encode(url))).body

    title_regexp = /<title>(.*)<\/title>/
    description_regexp = /meta.*description.*content=[",'](.*)[",']/

    title = data.scan(title_regexp)[0].to_s
    description = data.scan(description_regexp)[0].to_s
    p = {"title" => title, "description" => description}
   
    return p
  end

  # POST /links
  # POST /links.json
  def create
    form_data = params[:link]

    if((form_data[:title] =='') or (form_data[:description] ==''))
      data = get_data_for_link(form_data[:link]);

      if(form_data[:title] =='')
        form_data[:title] = data["title"]
      end

      if(form_data[:description] =='')
        form_data[:description] = data["description"]
      end
    end

    @link = Link.new(form_data)

    respond_to do |format|
      if @link.save
        format.html { redirect_to @link, :notice => t(:created) }
        format.json { render :json => @link, :status => :created, :location => @link }
      else
        format.html { render :action => "new" }
        format.json { render :json => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.json
  def update
    @link = Link.find(params[:id])

    respond_to do |format|
      if @link.update_attributes(params[:link])
        format.html { redirect_to @link, :notice => 'Link was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    @link = Link.find(params[:id])
    @link.destroy

    respond_to do |format|
      format.html { redirect_to links_url }
      format.json { head :no_content }
    end
  end

  def validate_password(password)
    reg = /^(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){8,40}$/

    return (reg.match(password))? true : false
  end
end
