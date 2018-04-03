class Dog

  attr_accessor :name, :breed, :id

  def  initialize(name:, breed:, id: nil)
    # hash.each {|key, value| self.send(("#{key}="), value)}

    # name:, breed:, id: nil
    @id = id
    @name = name
    @breed = breed
end

def self.create_table
  sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
end

def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
      if self.id
        self.update
      else
      sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES(?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
   new_dog = self.new(row[0], row[1], row[2])
  new_dog
end


  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create(name:, breed:)
    dog_attr = {name: name, breed: breed}
    dog = Dog.new(dog_attr)
    # dog.save
    dog_attr.each {|key, value| self.send(("#{key}="), value)}
     
    self.save
    self
  end

  def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
      else
        dog = self.create(name: name, breed: breed)
      end
      dog
    end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

end
