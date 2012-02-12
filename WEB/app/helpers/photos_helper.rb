module PhotosHelper
  
  def pub_status(published)
    if published == true
      'Un-Publish'
    else
      'Publish'
    end
  end
  
end
