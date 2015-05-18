require 'rspec'
require 'onceler'

load 'spec/spec_helper.rb'

TEACHER_USER_ID = 1
STUDENT_USER_ID = 1
COURSE_ID = 1

def assess_with(outcome=@outcome)
  @rubric = Rubric.create!(:context => @course)
  @rubric.data = [
    {
      :points => 3,
      :description => "Outcome row",
      :id => 1,
      :ratings => [
        {
          :points => 3,
          :description => "Rockin'",
          :criterion_id => 1,
          :id => 2
        },
        {
          :points => 0,
          :description => "Lame",
          :criterion_id => 1,
          :id => 3
        }
      ],
      :learning_outcome_id => @outcome.id
    }
  ]
  @rubric.save!
  @user = user(:active_all => true)
  @e = @course.enroll_student(@user)
  @a = @rubric.associate_with(@assignment, @course, :purpose => 'grading')
  @assignment.reload
  @submission = @assignment.grade_student(@user, :grade => "10").first
  @assessment = @a.assess({
    :user => @user,
    :assessor => @user,
    :artifact => @submission,
    :assessment => {
      :assessment_type => 'grading',
      :criterion_1 => {
        :points => 2,
        :comments => "cool, yo"
      }
    }
  })
  @result = @outcome.learning_outcome_results.first
  @assessment = @a.assess({
    :user => @user,
    :assessor => @user,
    :artifact => @submission,
    :assessment => {
      :assessment_type => 'grading',
      :criterion_1 => {
        :points => 3,
        :comments => "cool, yo"
      }
    }
  })
  @result.reload
  @rubric.reload
end

course = Course.find(COURSE_ID)
outcome = course.created_learning_outcomes.create!(:title => 'outcome')
debugger
