# Backward compatibility: Restroom is now an alias for BedBugReport
# This registration is kept for compatibility but will be deprecated
ActiveAdmin.register Restroom do
  permit_params :name, :street, :city, :state, :verified, :severe, :directions,
                :comment, :latitude, :longitude, :country, :edit_id, :approved
end
