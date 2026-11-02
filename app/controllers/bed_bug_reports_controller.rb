require_relative '../helpers/recaptcha_helper'

# rubocop:disable Metrics/ClassLength
class BedBugReportsController < ApplicationController
  respond_to :html, :json

  before_action :bed_bug_reports_filters, only: [:index]
  before_action :list_bed_bug_reports, only: [:index]
  before_action :find_bed_bug_report, only: %i[show update edit]

  def index
    @view = params[:view] || 'list'
    if params[:nearby]
      render :nearby, layout: false
    else
      respond_with @bed_bug_reports
    end
  end

  def show; end

  # rubocop:disable Metrics/MethodLength
  def new
    if params[:edit_id]
      @bed_bug_report = find_bed_bug_report
      @bed_bug_report.edit_id = params[:edit_id]
      @bed_bug_report.approved = false
    elsif params[:guess]
      @bed_bug_report = BedBugReport.new(permitted_params)
      @bed_bug_report.reverse_geocode
      render 'new', layout: false
    else
      @bed_bug_report = BedBugReport.new
    end
  end
  # rubocop:enable Metrics/MethodLength

  def edit; end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def create
    @bed_bug_report = BedBugReport.new(permitted_params)

    # Verify recaptcha code
    recaptcha_response = params['g-recaptcha-response']
    unless RecaptchaHelper.valid_token? recaptcha_response
      flash.now[:error] = I18n.t('helpers.reCAPTCHA.failed')
      render 'new'
      return
    end

    @bed_bug_report = SaveBedBugReport.new(@bed_bug_report).call

    if @bed_bug_report.errors.empty?
      if @bed_bug_report.approved?
        flash[:notice] = I18n.t('bed_bug_report.flash.new', name: @bed_bug_report.name)
        redirect_to @bed_bug_report
      else
        flash[:notice] = I18n.t('bed_bug_report.flash.edit', name: @bed_bug_report.name)
        redirect_to bed_bug_report_path(@bed_bug_report.edit_id)
      end
    elsif @bed_bug_report.errors.key?(:spam)
      flash.now[:notice] = I18n.t('bed_bug_report.flash.spam')
      render 'new'
    else
      display_errors
      render 'new'
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def update
    if params[:bed_bug_report][:downvote]
      BedBugReport.increment_counter(:downvote, @bed_bug_report.id) # rubocop:disable Rails/SkipsModelValidations
    elsif params[:bed_bug_report][:upvote]
      BedBugReport.increment_counter(:upvote, @bed_bug_report.id) # rubocop:disable Rails/SkipsModelValidations
    elsif @bed_bug_report.update(permitted_params)
      flash.now[:notice] = I18n.t('bed_bug_report.flash.updated')
    else
      display_errors
      render 'edit'
    end

    redirect_to @bed_bug_report
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def bed_bug_reports_filters
    @filters =
      params
      .fetch(:filters, '')
      .split(',')
      .each_with_object({}) do |filter, filters|
        filters[filter] = true if %w[verified severe].include?(filter)
      end
  end

  # rubocop:disable Metrics/AbcSize
  def list_bed_bug_reports
    @bed_bug_reports = BedBugReport.current.where(@filters)
    @bed_bug_reports =
      if params[:search].present? || params[:map] == "1"
        @bed_bug_reports.near([params[:lat], params[:long]], 20, order: 'distance')
      else
        @bed_bug_reports.reverse_order
      end
    @pagy, @bed_bug_reports = pagy(@bed_bug_reports)[0].overflow? ? pagy(@bed_bug_reports, page: 1) : pagy(@bed_bug_reports)
  end
  # rubocop:enable Metrics/AbcSize

  def display_errors
    if @bed_bug_report.errors.any?
      @bed_bug_report.errors.each do
        flash[:alert] = I18n.t('bed_bug_report.flash.field')
      end
    else
      flash[:alert] = I18n.t('bed_bug_report.flash.unexpected')
    end
  end

  def find_bed_bug_report
    @bed_bug_report = BedBugReport.find(params[:id])
  end

  # rubocop:disable Metrics/MethodLength
  def permitted_params
    params.require(:bed_bug_report).permit(
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
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/ClassLength
