class RenameRestroomsToBedBugReports < ActiveRecord::Migration[7.1]
  def change
    rename_table :restrooms, :bed_bug_reports
  end
end
