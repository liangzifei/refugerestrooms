# Backward compatibility alias for BedBugReport
# This file is kept for compatibility during the refactoring process
# New code should use BedBugReport directly

class Restroom < BedBugReport
  self.table_name = 'bed_bug_reports'
end
