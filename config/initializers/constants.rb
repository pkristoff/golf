module Label
  module Common
    EDIT = 'Edit'.freeze
    NEW = 'New'.freeze
  end
  module Database
    CLEAR = 'Clear DB'.freeze
    LOAD_XSXL = 'Load in XSXL File'.freeze
  end
  module Course
    COURSE = 'Course'.freeze
    DESTROY = 'Destroy course'.freeze
    EDIT = 'Edit course'.freeze
    NAME = 'Name'.freeze
    NUMBER_OF_HOLES = 'Number of holes'.freeze
    SHOW_COURSE = 'Show Course'.freeze
    STREET1 = 'Street 1'.freeze
    STREET2 = 'Street 2'.freeze
    CITY = 'City'.freeze
    STATE = 'State'.freeze
    ZIP = 'Zipcode'.freeze
  end
  module Tee
    COLOR = 'Color'.freeze
    NUMBER_OF_HOLES = 'Number of holes'.freeze
    RATING = 'Rating'.freeze
    SLOPE = 'Slope'.freeze
  end
  module Hole
    HDCP = 'HDCP'.freeze
    NUMBER = 'Number'.freeze
    PAR = 'Par'.freeze
    YARDAGE = 'Yardage'.freeze
  end
  module Round
    DATE = 'Date'.freeze
    NO_ROUNDS = 'No Rounds'.freeze
    ROUNDS = 'Rounds'.freeze
    SHOW = 'Show Round'.freeze
    EDIT = 'Edit round'.freeze
    NEW = 'New round'.freeze
  end
  module Score
    HOLE_NUMBER = 'Hole Number'.freeze
    STROKES = 'Strokes'.freeze
    PUTTS = 'Putts'.freeze
    PENALTIES = 'Penalties'.freeze
  end
end
module Button
  module Course
    CREATE = 'Create Course'.freeze
    DESTROY = 'Destroy'.freeze
    NEW = 'New Course'.freeze
    EDIT = 'Edit Course'.freeze
    UPDATE = 'Update Course'.freeze
    SHOW_COURSES = 'Show Courses'.freeze
  end
  module Tee
    SHOW_TEES = 'Show Tees'.freeze
    CREATE = 'Create Tee'.freeze
    EDIT = 'Edit Tee'.freeze
    NEW = 'New Tee'.freeze
  end
  module Hole
    EDIT = 'Edit Hole'.freeze
  end
  module Round
    CHOOSE_COURSE = 'Choose Round Course'
    EDIT = 'Edit Round'.freeze
    NEW = 'New Round'.freeze
    COURSES = 'Show Round Courses'.freeze
    TEES = 'Show Tees for Course'.freeze
    CREATE = 'Create Round'.freeze
    UPDATE = 'Update Round'.freeze
  end
end
module Fieldset
  module Course
    COURSE_BUTTONS = 'Course buttons'.freeze
  end
  module Round
    ROUND_BUTTONS = 'Round buttons'.freeze
    EDIT = 'Edit'.freeze
  end
end