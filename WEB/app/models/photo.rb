class Photo < ActiveRecord::Base
    attr_accessible :title, :image
    
    has_attached_file :image, :styles => {
									      	:micro=> "150x100#",
									      	:thumb=> "160x160#",
									      	:iphone => "320x320>",
									      	:large => "800x800>"},
									      :default_style => :large,
									      :url => "/photos/:basename_:style.:extension",
									      :path => ":rails_root/public/photos/:basename_:style.:extension"
		
end
