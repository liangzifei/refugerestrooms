class AddVerifiedAndSevereToBedBugReports < ActiveRecord::Migration[7.1]
  def change
    add_column :bed_bug_reports, :verified, :boolean, default: false, null: false
    add_column :bed_bug_reports, :severe, :boolean, default: false, null: false
  end
end
