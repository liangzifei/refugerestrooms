# Backward compatibility alias for BedBugReportsController
# This controller is deprecated and kept only for compatibility during refactoring
# New code should use BedBugReportsController instead

class RestroomsController < BedBugReportsController
  private

  def bed_bug_reports_filters
    @filters =
      params
      .fetch(:filters, '')
      .split(',')
      .each_with_object({}) do |filter, filters|
        # Map old filter names to new ones
        filter = 'verified' if filter == 'accessible'
        filter = 'severe' if filter == 'changing_table'
        filters[filter] = true if %w[verified severe unisex].include?(filter)
      end
  end

  def list_bed_bug_reports
    @bed_bug_reports = BedBugReport.current.where(@filters)
    # Use @restrooms as an alias for @bed_bug_reports for backward compatibility
    @restrooms = @bed_bug_reports
    @bed_bug_reports =
      if params[:search].present? || params[:map] == "1"
        @bed_bug_reports.near([params[:lat], params[:long]], 20, order: 'distance')
      else
        @bed_bug_reports.reverse_order
      end
    @pagy, @bed_bug_reports = pagy(@bed_bug_reports)[0].overflow? ? pagy(@bed_bug_reports, page: 1) : pagy(@bed_bug_reports)
    @restrooms = @bed_bug_reports
  end

  def find_bed_bug_report
    @bed_bug_report = BedBugReport.find(params[:id])
    # Create @restroom alias for backward compatibility
    @restroom = @bed_bug_report
  end

  def permitted_params
    # Map old parameter names to new ones
    bed_bug_params = params[:bed_bug_report] || params[:restroom]
    return {} unless bed_bug_params

    params.require(params[:bed_bug_report] ? :bed_bug_report : :restroom).permit(
      :name,
      :street,
      :city,
      :state,
      :country,
      :verified,
      :severe,
      :directions,
      :comment,
      :longitude,
      :latitude,
      :edit_id,
      :approved
    )
  end
end
