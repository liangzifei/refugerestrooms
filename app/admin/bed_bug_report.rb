ActiveAdmin.register BedBugReport do
  permit_params :name, :street, :city, :state, :verified, :severe, :directions,
                :comment, :latitude, :longitude, :country, :edit_id, :approved
end
