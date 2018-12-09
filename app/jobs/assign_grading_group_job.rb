class AssignGradingGroupJob < ApplicationJob
  queue_as :default

  def perform(assignment)
    # Do something later
    create_grades_from_assignment assignment
  end
end
