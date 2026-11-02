class Contact < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: URI::MailTo::EMAIL_REGEXP
  attribute :bed_bug_report_id, allow_blank: true
  attribute :bed_bug_report_name, allow_blank: true
  # Backward compatibility aliases
  attribute :restroom_id, allow_blank: true
  attribute :restroom_name, allow_blank: true
  attribute :message
  attribute :nickname, captcha: true

  validate :report_must_exist

  def report_must_exist
    report_id = bed_bug_report_id || restroom_id
    report_name = bed_bug_report_name || restroom_name
    return if report_id.blank?
    return if BedBugReport.exists?(id: report_id, name: report_name)

    errors.add(:base, "Must be valid bed bug report ID and name")
  end

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    report_id = bed_bug_report_id || restroom_id
    {
      subject: "My Contact Form #{report_id}",
      to: "refugerestrooms@gmail.com",
      from: %("#{name}" <#{email}>), # :from overriden by google smtp config
      reply_to: %("#{name}" <#{email}>)
    }
  end
end
