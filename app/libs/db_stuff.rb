# frozen_string_literal: true

# loading and clear db
# 
class DbStuff
  # list of all tables in db.
  #
  # === Returns:
  #
  # * <tt>Array</tt> of active_record classes
  #
  def self.db_tables
    [
      Account,
      # Course before Address - foreign key
      Course,
      Address,
      Hole,
      Round,
      Score,
      ScoreHole,
      Tee,
    ]
  end

  def self.clear_db
    DbStuff.db_tables.each { |active_record| active_record.delete_all}
  end

  def self.load_in_db(uploaded_filepath)
    GolfReader.new(uploaded_filepath)
  end
end