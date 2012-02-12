class PhotosController < ApplicationController
  
  protect_from_forgery :except => :camerasnap
  
  respond_to :html, :xml, :json
  
  def index
    if mobile_device?
      @photos = Photo.all
    else
      @photos = Photo.page(params[:page]).per(20)
    end
    respond_with @photos
  end

  def show
    @photo = Photo.find(params[:id])
    respond_with @photo
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(params[:photo])
    if @photo.save
      flash[:notice] = "Successfully created photo."
      redirect_to @photo
    else
      render :action => 'new'
    end
  end

  def edit
    @photo = Photo.find(params[:id])
  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(params[:photo])
      flash[:notice] = "Successfully updated photo."
      redirect_to photo_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    flash[:notice] = "Successfully destroyed photo."
    redirect_to photos_url
  end
  
  def cam
    if mobile_device?
      redirect_to photos_path
    else
      render :layout => 'camera'
    end
  end
   
  def camerasnap
	  #associate the param sent by Flex (content) to a variable
	  file_data = params[:content]     
	 
	  #Decodes our Base64 string sent from Flex
	  img_data = Base64.decode64(file_data)
	  
	  dateTime = Time.new
    timestamp = dateTime.to_time.to_i
      
	  #Set an image filename, with .jpg extension
	  img_filename = "tmp/#{timestamp}.jpg"
	 
	  #Opens the "example_name.jpg" and populates it with "img_data" (our decoded Base64 send from Flex)
	  img_file = File.open(img_filename, "wb") { |f| f.write(img_data) }
	 
	  @photo = Photo.create do |photo|
      photo.title = timestamp
      photo.image = File.open(img_filename)
    end
    
    File.delete(img_filename)
    
    if @photo.save
      render :xml => @photo, :status => :created, :location => @photo
     # render :json => { :status => :ok, :message => "Success!", :html => "...insert html..." }.to_json
    else
      render :xml => @photo.errors, :status => :unprocessable_entity
      #render :json => { :status => :error, :message => "Failure!", :html => "...insert html..." }.to_json
    end
    
  end
  
  def toggle_published
    @photo = Photo.find(params[:id])
    @photo.toggle!(:published)

    redirect_to photos_url
  end
  
end
