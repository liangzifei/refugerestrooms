module API
  module V1
    class BedBugReports < Grape::API
      PAGY_OPTIONS = { items_param: :per_page, items: 10, max_items: 100 }.freeze

      helpers Grape::Pagy::Helpers

      version 'v1'
      format :json

      # rubocop:disable Metrics/BlockLength
      resource :bed_bug_reports do
        desc "Get all bed bug report records ordered by date descending."
        params do
          use :pagy, **PAGY_OPTIONS
          optional :verified, type: Boolean, desc: "Only return reports that are verified."
          optional :severe, type: Boolean, desc: "Only return reports with severe infestations."
        end
        get do
          r = BedBugReport
          r = r.current
          r = r.verified if params[:verified].present?
          r = r.severe if params[:severe].present?

          pagy(r.order(created_at: :desc))
        end

        desc "Perform full-text search of bed bug report records."
        params do
          use :pagy, **PAGY_OPTIONS
          optional :verified, type: Boolean, desc: "Only return reports that are verified."
          optional :severe, type: Boolean, desc: "Only return reports with severe infestations."
          requires :query, type: String, desc: "Your search query."
        end
        get :search do
          r = BedBugReport
          r = r.current
          r = r.verified if params[:verified].present?
          r = r.severe if params[:severe].present?

          pagy(r.text_search(params[:query]))
        end

        desc "Search by location."
        params do
          use :pagy, **PAGY_OPTIONS
          optional :verified, type: Boolean, desc: "Only return reports that are verified."
          optional :severe, type: Boolean, desc: "Only return reports with severe infestations."
          requires :lat, type: Float, desc: "latitude"
          requires :lng, type: Float, desc: "longitude"
        end
        get :by_location do
          r = BedBugReport
          r = r.current
          r = r.verified if params[:verified].present?
          r = r.severe if params[:severe]
          pagy(r.near([params[:lat], params[:lng]], 20, order: 'distance'))
        end

        desc "Search for bed bug report records updated or created on or after a given date"
        params do
          use :pagy, **PAGY_OPTIONS
          optional :verified, type: Boolean, desc: "Only return reports that are verified."
          optional :severe, type: Boolean, desc: "Only return reports with severe infestations."
          optional(
            :updated,
            type: Boolean,
            desc: "Return report records updated (rather than created) since given date"
          )
          requires :day, type: Integer, desc: "Day"
          requires :month, type: Integer, desc: "Month"
          requires :year, type: Integer, desc: "Year"
        end
        get :by_date do
          r = BedBugReport
          r = r.current
          date = Date.new(params[:year], params[:month], params[:day])
          r = if params[:updated]
                r.updated_since(date)
              else
                r.created_since(date)
              end
          r = r.verified if params[:verified].present?
          r = r.severe if params[:severe].present?
          pagy(r.order(created_at: :desc))
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
