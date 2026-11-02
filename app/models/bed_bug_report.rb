# Bed Bug Report model for tracking bed bug sightings and infestations

class BedBugReport < ApplicationRecord
  include PgSearch::Model
  include Rakismet::Model

  pg_search_scope(
    :search,
    against: {
      name: 'A',
      street: 'B',
      city: 'C',
      state: 'D',
      comment: 'B',
      directions: 'B',
      country: 'D'
    },
    using: { tsearch: { dictionary: "english" } },
    ignoring: :accents
  )

  validates :name, :street, :city, :state, presence: true

  geocoded_by :full_address

  reverse_geocoded_by :latitude, :longitude do |obj, results|
    geo = results.first
    if geo
      obj.name    = geo.address
      obj.street  = geo.address.split(',').first
      obj.city    = geo.city
      obj.state   = geo.state
      obj.country = geo.country_code
    end
  end

  rakismet_attrs content: proc {
    name + street + city + state + comment + directions + country
  }

  after_validation :perform_geocoding
  after_find :strip_slashes

  scope :current, lambda {
    BedBugReport.where('id IN (SELECT MAX(id) FROM bed_bug_reports WHERE approved GROUP BY edit_id)')
  }

  scope :verified, -> { where(verified: true) }
  scope :severe, -> { where(severity: 'severe') }

  scope :created_since, ->(date) { where("created_at >= ?", date) }
  scope :updated_since, ->(date) { where("updated_at >= ?", date) }

  def full_address
    "#{street}, #{city}, #{state}, #{country}"
  end

  def rated?
    upvote.positive? || downvote.positive?
  end

  def rating_percentage
    return 0 unless rated?

    upvote.to_f / (upvote + downvote) * 100
  end

  # PostgreSQL Full-Text Search for the API.
  def self.text_search(query)
    if query.present?
      search(query)
    else
      all
    end
  end

  private

  def strip_slashes
    %w[name street city state comment directions].each do |field|
      attributes[field].try(:gsub!, "\\'", "'")
    end
  end

  def perform_geocoding
    return true if Rails.env.test?
    return true if ENV["SEEDING_DONT_GEOCODE"]

    geocode
  end
end
