class SaveBedBugReport
  def initialize(bed_bug_report)
    @bed_bug_report = bed_bug_report
  end

  def call
    if @bed_bug_report.spam?
      @bed_bug_report.errors.add(:spam, 'This report is spam')
    else
      BedBugReport.transaction do
        @bed_bug_report.save
        @bed_bug_report.update(edit_id: @bed_bug_report.id) if @bed_bug_report.approved?
      end
    end
    @bed_bug_report
  end
end
