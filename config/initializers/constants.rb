module Label
  module Common
    EDIT = 'Edit'.freeze
    DESTROY = 'Destroy'.freeze
    NEW = 'New'.freeze
  end
  module Course
    NAME = 'Name'.freeze
    NUMBER_OF_HOLES = 'Number of holes'
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
    DATE='Date'.freeze
    NO_ROUNDS='No Rounds'.freeze
  end
  module Score
    HOLE_NUMBER='Hole Number'.freeze
    STROKES='Strokes'.freeze
    PUTTS='Putts'.freeze
    PENALTIES='Penalties'.freeze
  end
end
module Button
  module Course
    CREATE = 'Create Course'.freeze
    EDIT = 'Edit Course'.freeze
    UPDATE = 'Update Course'.freeze
    SHOW_COURSES = 'Show Courses'.freeze
  end
  module Tee
    CREATE = 'Create Tee'.freeze
    EDIT = 'Edit Tee'.freeze
    NEW = 'New Tee'.freeze
  end
  module Hole
    EDIT = 'Edit Hole'.freeze
  end
  module Round
    EDIT='Edit Round'.freeze
    NEW='New Round'.freeze
    COURSES = 'Show Round Courses'.freeze
    TEES = 'Show Tees for Course'.freeze
  end
end